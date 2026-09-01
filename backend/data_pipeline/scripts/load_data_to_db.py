"""
Loads the extracted AIHW CSVs into the Postgres schema defined in schema.sql
"""

import argparse
import re
from pathlib import Path

import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv
import os


def discover_geography(filepath: Path, geo_level: str):
    """
    Reads the state or socioeconomic column headers from a real CSV file
    instead of typing them out by hand, so the lookup values always match
    what's actually in the data.
    """
    df = pd.read_csv(filepath)
    label_col = df.columns[0]
    result = []
    for col in df.columns:
        if col == label_col:
            continue
        # socioeconomic labels are long (e.g. "1 (most disadvantaged)"),
        # so use just the leading number as the code if there is one
        leading_digit = re.match(r"^(\d+)", col)
        code = leading_digit.group(1) if leading_digit else col
        result.append((code, col, geo_level))
    return result


def discover_age_groups(filepath: Path):
    """Reads age group labels from the first column of a real file, keeping their natural order."""
    df = pd.read_csv(filepath)
    labels = df.iloc[:, 0].dropna().unique().tolist()
    skip = {"Crude rate", "AS rate"}  # these are summary rows, not age groups
    result = []
    for order, label in enumerate(labels):
        if label in skip:
            continue
        code = str(label).replace("\u2013", "-").replace(" ", "_").lower() #turn "25–29" into "25-29", "All ages" into "all_ages" etc
        result.append((code, label, order))
    return result


#letter types are a small, fixed set (only 4 real values), so these are just typed out
#directly rather than discovered from a file the way states/age groups are
LETTER_TYPES = [
    ("A1", "A1"),
    ("B1", "B1"),
    ("C1", "C1"),
    ("D1", "D1"),
]

#same idea: metrics are a small known set across all the tables, safe to hardcode
METRICS = [
    ("number", "Number", "count"),
    ("per_cent", "Per cent", "rate"),
    ("population", "Population", "population"),
    ("new_cases", "Number of new cases", "count"),
    ("new_cases_per_100k", "Number of new cases per 100,000 women", "rate"),
    ("deaths", "Number of deaths", "count"),
    ("deaths_per_100k", "Number of deaths per 100,000 women", "rate"),
    ("invited", "Invited", "count"),
    ("responded", "Responded", "count"),
    ("crude_rate", "Crude rate", "rate"),
]


def populate_lookup_tables(cur, states, socioeconomic, age_groups):
    """Inserts the lookup values. Uses ON CONFLICT so it's safe to run more than once."""
    execute_values(cur, "INSERT INTO lookup_geography (geo_code, geo_name, geo_level) VALUES %s ON CONFLICT (geo_code) DO NOTHING", states + socioeconomic)
    execute_values(cur, "INSERT INTO lookup_age_group (age_code, age_label, sort_order) VALUES %s ON CONFLICT (age_code) DO NOTHING", age_groups)
    execute_values(cur, "INSERT INTO lookup_letter_type (letter_type_code, letter_type_label) VALUES %s ON CONFLICT (letter_type_code) DO NOTHING", LETTER_TYPES)
    execute_values(cur, "INSERT INTO lookup_metric (metric_code, metric_label, category) VALUES %s ON CONFLICT (metric_code) DO NOTHING", METRICS)


def register_report_table(cur, table_code, description, indicator_category, source_file):
    """Adds one row to lookup_report_table so every fact row's table_code links back to something meaningful."""
    cur.execute(
        "INSERT INTO lookup_report_table (table_code, description, indicator_category, source_file) "
        "VALUES (%s, %s, %s, %s) ON CONFLICT (table_code) DO NOTHING",
        (table_code, description, indicator_category, source_file),
    )


def build_lookup_dicts(states, socioeconomic, age_groups):
    """
    Turns the discovered values into label -> code dictionaries for quick
    lookup while loading. Note the direction: you look these up BY LABEL
    (e.g. "All ages") and get back the CODE (e.g. "all_ages"), not the
    other way around.
    """
    state_lookup = {name: code for code, name, _ in states}
    ses_lookup = {name: code for code, name, _ in socioeconomic}
    age_lookup = {label: code for code, label, _ in age_groups}
    return state_lookup, ses_lookup, age_lookup


def load_wide_participation_csv(cur, filepath, table_code, metric_code, year_start, year_end, age_lookup, geo_lookup):
    """
    Loads one wide-format CSV (state or socioeconomic participation) into
    screening_participation. Each row is one age group, and each remaining
    column is a geography value (e.g. NSW, Vic, ...).
    """
    df = pd.read_csv(filepath)
    label_col = df.columns[0]

    rows = []
    skipped = []
    for _, row in df.iterrows():
        age_label = row[label_col]
        age_code = age_lookup.get(str(age_label))
        if age_code is None:
            #Crude rate / AS rate are summary rows at the bottom of the table, not real age groups - expected to be skipped
            if str(age_label) not in ("Crude rate", "AS rate"):
                skipped.append(age_label)
            continue
        for geo_name, geo_code in geo_lookup.items():
            if geo_name not in df.columns: #this file might not have every geography (e.g. socioeconomic file has no state columns)
                continue
            value = row[geo_name]
            if pd.isna(value):
                continue
            rows.append((table_code, geo_code, age_code, metric_code, year_start, year_end, float(value), False))

    if skipped:
        print(f"  skipped {len(skipped)} unmapped age group(s) in {filepath.name}: {skipped}")

    if rows:
        execute_values(
            cur,
            "INSERT INTO screening_participation "
            "(table_code, geo_code, age_code, metric_code, year_start, year_end, value, is_suppressed) VALUES %s",
            rows,
        )
    return len(rows)


def discover_sa_geography(filepath, geo_level):
    """Gets the unique SA3 codes and names from the file — too many to type by hand."""
    df = pd.read_csv(filepath)
    code_col, name_col = df.columns[0], df.columns[1]
    unique_areas = df[[code_col, name_col]].drop_duplicates()
    # normalize codes to clean integer strings (e.g. "10102", never "10102.0")
    # so the same real code always produces the same geo_code, even if a
    # NaN elsewhere in the column upcasts it to float in pandas
    return [(str(int(row[code_col])), row[name_col], geo_level) for _, row in unique_areas.iterrows()]


def load_sa_participation_csv(cur, filepath, table_code, year_start, year_end, age_lookup):
    """
    Loads a long-format SA3 file into screening_participation. Each row
    already has one area + age group, with three metrics side by side
    (Participated / Population / Participation %), so this splits each row
    into three fact rows, one per metric, keeping that metric's own
    suppression flag.
    """
    df = pd.read_csv(filepath)
    code_col = df.columns[0]
    metric_map = {"Participated": "number", "Population": "population", "Participation (%)": "per_cent"}

    rows = []
    skipped = []
    for _, row in df.iterrows():
        age_code = age_lookup.get(str(row["Age group"]))
        if age_code is None:
            skipped.append(row["Age group"])
            continue
        geo_code = str(int(row[code_col])) #same int() cleanup as discover_sa_geography, so codes always match
        for source_col, metric_code in metric_map.items():
            value = row[source_col]
            is_suppressed = bool(row[f"{source_col}_suppressed"])
            rows.append((table_code, geo_code, age_code, metric_code, year_start, year_end,
                         None if pd.isna(value) else float(value), is_suppressed)) #suppressed rows keep a NULL value, not a fake zero

    if skipped:
        print(f"  skipped {len(set(skipped))} unmapped age group(s) in {filepath.name}: {set(skipped)}")

    execute_values(
        cur,
        "INSERT INTO screening_participation "
        "(table_code, geo_code, age_code, metric_code, year_start, year_end, value, is_suppressed) VALUES %s",
        rows,
    )
    return len(rows)


def load_response_to_invitation_csv(cur, filepath, breakdown, age_lookup, state_lookup, letter_lookup):
    """
    Loads one S2.x CSV into response_to_invitation. Column names are like
    "2019_Invited", "2019_Responded", "2019_Crude rate" — this pulls the
    year and metric out of each column name.

    breakdown is "age" (S2.1), "state" (S2.2), or "letter" (S2.3). Only
    S2.1 actually varies by age group — S2.2 and S2.3 are totals across
    all ages, so those rows use the "All ages" -> "all_ages" code instead.
    """
    df = pd.read_csv(filepath)
    label_col = df.columns[0]
    metric_lookup = {"Invited": "invited", "Responded": "responded", "Crude rate": "crude_rate"}

    rows = []
    for _, row in df.iterrows():
        label = str(row[label_col])

        #each breakdown type fills in a different combination of age/geo/letter -
        #the other two stay NULL since they genuinely don't apply to that row
        if breakdown == "age":
            age_code = age_lookup.get(label)
            geo_code = None
            letter_type_code = None
            if age_code is None:
                continue
        elif breakdown == "state":
            age_code = age_lookup.get("All ages")
            geo_code = state_lookup.get(label)
            letter_type_code = None
            if geo_code is None:
                continue
        else:  # letter type
            if label == "Australia":  # national total across letter types, skip
                continue
            age_code = age_lookup.get("All ages")
            geo_code = None
            letter_type_code = letter_lookup.get(label)
            if letter_type_code is None:
                continue

        for col in df.columns:
            if col == label_col:
                continue
            year_str, metric_label = col.split("_", 1) #column name is like "2019_Invited" - split on the first underscore
            metric_code = metric_lookup.get(metric_label)
            if metric_code is None:
                continue
            value = row[col]
            if pd.isna(value):
                continue
            try:
                value = float(value)
            except (ValueError, TypeError):
                continue  # non-numeric marker like 'n.p.' (suppressed) or '. .' (not applicable)
            rows.append((age_code, geo_code, letter_type_code, int(year_str), metric_code, value))

    table_code = "S2.1" if breakdown == "age" else ("S2.2" if breakdown == "state" else "S2.3")
    if rows:
        execute_values(
            cur,
            "INSERT INTO response_to_invitation "
            "(table_code, age_code, geo_code, letter_type_code, year, metric_code, value) VALUES %s",
            [(table_code, r[0], r[1], r[2], r[3], r[4], r[5]) for r in rows],
        )
    return len(rows)


#used to turn a month column name like "January" into the number 1, for the year/month columns in monthly_test_volume
MONTH_NUMBERS = {
    "January": 1, "February": 2, "March": 3, "April": 4, "May": 5, "June": 6,
    "July": 7, "August": 8, "September": 9, "October": 10, "November": 11, "December": 12,
}


def load_monthly_volume_csv(cur, filepath, table_code, year, test_type, age_lookup):
    """
    Loads one S1.5/S1.6 CSV into monthly_test_volume. Each file has an Age
    group column, twelve month columns, and (except for a partial year like
    2025) one extra column holding the year's total — that total column and
    any blank spacer columns get skipped, only real months are loaded.
    """
    df = pd.read_csv(filepath)
    label_col = df.columns[0]

    rows = []
    for _, row in df.iterrows():
        age_code = age_lookup.get(str(row[label_col]))
        if age_code is None:
            continue
        for col in df.columns:
            month = MONTH_NUMBERS.get(col)
            if month is None:  # skips the label column, the annual total column, and any spacer columns
                continue
            value = row[col]
            if pd.isna(value):
                continue
            rows.append((table_code, age_code, year, month, test_type, float(value)))

    if rows:
        execute_values(
            cur,
            "INSERT INTO monthly_test_volume (table_code, age_code, year, month, test_type, value) VALUES %s",
            rows,
        )
    return len(rows)


def load_outcomes_by_year_csv(cur, filepath, table_code, metric_code, age_lookup):
    """
    Loads S19.1/S20.1 into cancer_outcomes. These have individual years as
    columns (1982, 1983, ...) with one national value per year, not broken
    down by state.
    """
    df = pd.read_csv(filepath)
    label_col = df.columns[0]

    rows = []
    for _, row in df.iterrows():
        age_code = age_lookup.get(str(row[label_col]))
        if age_code is None:
            continue
        for col in df.columns:
            if col == label_col or not col.strip().isdigit(): #only real year columns, skip the label column and anything else
                continue
            value = row[col]
            if pd.isna(value):
                continue
            rows.append((table_code, "Australia", age_code, metric_code, int(col), float(value))) #national data, so geo_code is always "Australia"

    if rows:
        execute_values(
            cur,
            "INSERT INTO cancer_outcomes (table_code, geo_code, age_code, metric_code, year, value) VALUES %s",
            rows,
        )
    return len(rows)


def load_outcomes_by_geography_csv(cur, filepath, table_code, metric_code, year, geo_lookup, age_lookup):
    """
    Loads S19.5/S19.7/S20.3/S20.5 into cancer_outcomes. These are broken
    down by state or socioeconomic area, but cover one reporting window
    rather than individual years — the window's end year is stored as
    "year" here, since cancer_outcomes only has a single year column
    (unlike screening_participation, which has year_start/year_end).
    """
    df = pd.read_csv(filepath)
    label_col = df.columns[0]

    rows = []
    for _, row in df.iterrows():
        age_code = age_lookup.get(str(row[label_col]))
        if age_code is None:
            continue
        for geo_name, geo_code in geo_lookup.items():
            if geo_name not in df.columns:
                continue
            value = row[geo_name]
            if pd.isna(value):
                continue
            rows.append((table_code, geo_code, age_code, metric_code, year, float(value)))

    if rows:
        execute_values(
            cur,
            "INSERT INTO cancer_outcomes (table_code, geo_code, age_code, metric_code, year, value) VALUES %s",
            rows,
        )
    return len(rows)


def main():
    #default folder is relative to this script's own location, not wherever it's run from
    default_data_dir = Path(__file__).resolve().parent.parent / "data" / "extracted"

    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", default=str(default_data_dir))
    args = parser.parse_args()
    data_dir = Path(args.data_dir)

    load_dotenv()
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    cur = conn.cursor()

    # get the real geography/age group values from a reference file
    # rather than hardcoding them, so they match the actual data
    states = discover_geography(data_dir / "s1_2c_participation_state_number.csv", "state")
    socioeconomic = discover_geography(data_dir / "s1_4c_participation_socioeconomic_number.csv", "socioeconomic")
    age_groups = discover_age_groups(data_dir / "s1_2c_participation_state_number.csv")
    state_lookup, ses_lookup, age_lookup = build_lookup_dicts(states, socioeconomic, age_groups)

    print(f"Found {len(states)} states, {len(socioeconomic)} socioeconomic areas, {len(age_groups)} age groups")

    print("Loading lookup tables...")
    populate_lookup_tables(cur, states, socioeconomic, age_groups)
    conn.commit()

    #clear old data first so re-running this script doesn't create duplicates
    print("Clearing screening_participation before reload...")
    cur.execute("TRUNCATE TABLE screening_participation, cancer_outcomes, monthly_test_volume, response_to_invitation RESTART IDENTITY")
    conn.commit()

    # ---- S1.2 (state) and S1.4 (socioeconomic), all three reporting windows ----
    windows = [("a", 2018, 2022), ("b", 2019, 2023), ("c", 2020, 2024)]

    for suffix, year_start, year_end in windows:
        register_report_table(cur, f"S1.2{suffix}", "Participation, by age, state and territory", "participation", "AIHW_CAN166_recruitment_data_tables.xlsx")
        register_report_table(cur, f"S1.4{suffix}", "Participation, by age and socioeconomic area", "participation", "AIHW_CAN166_recruitment_data_tables.xlsx")

    total = 0
    for suffix, year_start, year_end in windows:
        for metric in ["number", "per_cent", "population"]:
            path = data_dir / f"s1_2{suffix}_participation_state_{metric}.csv"
            total += load_wide_participation_csv(cur, path, f"S1.2{suffix}", metric, year_start, year_end, age_lookup, state_lookup)
        for metric in ["number", "per_cent"]:  # S1.4 doesn't have a population section
            path = data_dir / f"s1_4{suffix}_participation_socioeconomic_{metric}.csv"
            total += load_wide_participation_csv(cur, path, f"S1.4{suffix}", metric, year_start, year_end, age_lookup, ses_lookup)

    conn.commit()
    print(f"Loaded {total} rows for S1.2 and S1.4")

    # ---- S1.8 (SA3), all three reporting windows ----
    sa3_geo = discover_sa_geography(data_dir / "s1_8_participation_sa3_2018_2022.csv", "sa3")
    execute_values(cur, "INSERT INTO lookup_geography (geo_code, geo_name, geo_level) VALUES %s ON CONFLICT (geo_code) DO NOTHING", sa3_geo)
    conn.commit()
    print(f"Found {len(sa3_geo)} SA3 areas")

    sa3_total = 0
    for year_start, year_end in [(2018, 2022), (2019, 2023), (2020, 2024)]:
        table_code = f"S1.8_{year_start}_{year_end}"
        register_report_table(cur, table_code, "Participation by Statistical Area Level 3", "participation", "AIHW_CAN166_recruitment_data_tables.xlsx")
        path = data_dir / f"s1_8_participation_sa3_{year_start}_{year_end}.csv"
        sa3_total += load_sa_participation_csv(cur, path, table_code, year_start, year_end, age_lookup)

    conn.commit()
    print(f"Loaded {sa3_total} rows for S1.8")

    # ---- S2.1, S2.2, S2.3 (response to invitation) ----
    letter_lookup = {code: code for code, _ in LETTER_TYPES}

    response_total = 0
    register_report_table(cur, "S2.1", "Response to invitation within 6 months, by age", "response_to_invitation", "AIHW_CAN166_recruitment_data_tables.xlsx")
    response_total += load_response_to_invitation_csv(cur, data_dir / "s2_1_response_to_invitation_by_age.csv", "age", age_lookup, state_lookup, letter_lookup)

    register_report_table(cur, "S2.2", "Response to invitation within 6 months, by state and territory", "response_to_invitation", "AIHW_CAN166_recruitment_data_tables.xlsx")
    response_total += load_response_to_invitation_csv(cur, data_dir / "s2_2_response_to_invitation_by_state.csv", "state", age_lookup, state_lookup, letter_lookup)

    register_report_table(cur, "S2.3", "Response to invitation within 6 months, by letter type", "response_to_invitation", "AIHW_CAN166_recruitment_data_tables.xlsx")
    response_total += load_response_to_invitation_csv(cur, data_dir / "s2_3_response_to_invitation_by_letter_type.csv", "letter", age_lookup, state_lookup, letter_lookup)

    conn.commit()
    print(f"Loaded {response_total} rows for S2.1/S2.2/S2.3")

    # ---- S1.5 and S1.6 (monthly test volume) ----
    year_by_suffix = {"a": 2018, "b": 2019, "c": 2020, "d": 2021, "e": 2022, "f": 2023, "g": 2024, "h": 2025}

    volume_total = 0
    for suffix, year in year_by_suffix.items():
        table_code = f"S1.5{suffix}"
        register_report_table(cur, table_code, "Number of HPV tests, by month", "monthly_volume", "AIHW_CAN166_recruitment_data_tables.xlsx")
        filename = f"s1_5_s1.5{suffix}_hpv_tests_by_month_number.csv" if suffix != "h" else "s1_5_s1.5h_hpv_tests_by_month.csv" #2025 (h) has a different filename since it's a partial year
        path = data_dir / filename
        if path.exists():
            volume_total += load_monthly_volume_csv(cur, path, table_code, year, "hpv_test", age_lookup)

        table_code = f"S1.6{suffix}"
        register_report_table(cur, table_code, "Number of self-collected HPV tests, by month", "monthly_volume", "AIHW_CAN166_recruitment_data_tables.xlsx")
        filename = f"s1_6_s1.6{suffix}_self_collected_by_month_number.csv"
        path = data_dir / filename
        if path.exists():
            volume_total += load_monthly_volume_csv(cur, path, table_code, year, "self_collected", age_lookup)

    conn.commit()
    print(f"Loaded {volume_total} rows for S1.5/S1.6")

    # ---- S19/S20 (cancer incidence and mortality) — background/citation data only, not used by the app ----
    outcomes_total = 0

    register_report_table(cur, "S19.1", "Cervical cancer incidence, by age, 1982-2021", "outcomes", "AIHW_CAN166_outcomes_data_tables.xlsx")
    outcomes_total += load_outcomes_by_year_csv(cur, data_dir / "s19_1_incidence_mortality_number_of_new_cases.csv", "S19.1", "new_cases", age_lookup)

    register_report_table(cur, "S20.1", "Cervical cancer mortality, by age, 1982-2023", "outcomes", "AIHW_CAN166_outcomes_data_tables.xlsx")
    outcomes_total += load_outcomes_by_year_csv(cur, data_dir / "s20_1_incidence_mortality_number_of_deaths.csv", "S20.1", "deaths", age_lookup)

    register_report_table(cur, "S19.5", "Cervical cancer incidence, by age and state, 2017-2021", "outcomes", "AIHW_CAN166_outcomes_data_tables.xlsx")
    outcomes_total += load_outcomes_by_geography_csv(cur, data_dir / "s19_5_incidence_mortality_number_of_new_cases.csv", "S19.5", "new_cases", 2021, state_lookup, age_lookup)

    register_report_table(cur, "S19.7", "Cervical cancer incidence, by age and socioeconomic area, 2017-2021", "outcomes", "AIHW_CAN166_outcomes_data_tables.xlsx")
    outcomes_total += load_outcomes_by_geography_csv(cur, data_dir / "s19_7_incidence_mortality_number_of_new_cases.csv", "S19.7", "new_cases", 2021, ses_lookup, age_lookup)

    register_report_table(cur, "S20.3", "Cervical cancer mortality, by age and state, 2019-2023", "outcomes", "AIHW_CAN166_outcomes_data_tables.xlsx")
    outcomes_total += load_outcomes_by_geography_csv(cur, data_dir / "s20_3_incidence_mortality_number_of_deaths.csv", "S20.3", "deaths", 2023, state_lookup, age_lookup)

    register_report_table(cur, "S20.5", "Cervical cancer mortality, by age and socioeconomic area, 2019-2023", "outcomes", "AIHW_CAN166_outcomes_data_tables.xlsx")
    outcomes_total += load_outcomes_by_geography_csv(cur, data_dir / "s20_5_incidence_mortality_number_of_deaths.csv", "S20.5", "deaths", 2023, ses_lookup, age_lookup)

    conn.commit()
    print(f"Loaded {outcomes_total} rows for S19/S20")

    cur.close()
    conn.close()
    print("Done.")


if __name__ == "__main__":
    main()