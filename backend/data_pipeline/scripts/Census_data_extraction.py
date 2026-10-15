"""
Extract the Census 2021 variables we need from the ABS General Community Profile
DataPack (SA3) into ONE tidy CSV, mirroring AIHW_data_extraction.py.

No database needed. Output: data/extracted/census_2021_sa3_long.csv
(one row per SA3 x variable), which load_census_to_db.py then loads.

Usage (from a terminal, or with ! in a notebook cell):
    python census_extraction.py find "not stated"    # search the metadata for column names
    python census_extraction.py extract              # write the extracted CSV

Unlike the AIHW workbooks, DataPack CSVs are already clean tables (one header row,
one row per area, numbers only), so "extraction" here means: pick the columns we
need, stitch the split parts together, drop non-spatial areas, and reshape to long.
"""
import argparse
import re
from pathlib import Path
import pandas as pd

#What to extract, per Census year
"""
Each entry: (ABS table, ABS short header, topic, sex, age_label, standard_name),
ex: ("G09", "F_Tot_25_44", "population", "F", "25-44", "women_25_74_total")
'standard_name' is the plain name for what the column counts, the SAME in every year, whatever ABS calls the column. 
Views calculate from standard names. Column names confirmed from the real DataPack headers.
Defines lists and settings for each Census year, so the same code can extract 2011, 2016, or 2021.
"""

AGE_RANGES = ["25_44", "45_54", "55_64", "65_74"] #same as AIHW screening data

def g09_rows():
    """
    2016/2021 G09: women 25-74 by band, plus all-ages totals (for comparing with 2011).
    builds the G09 list for how many women were born overseas.    
    """
    rows = []

    # the 3 things we want for each age range (women 25-74)
    categories = [
        ("Tot", "population", "women_25_74_total"),
        ("Australia", "birthplace", "women_25_74_born_australia"),
        ("COB_NS", "birthplace", "women_25_74_birthplace_not_stated")]

    # loop through each age range, then each category
    for age in AGE_RANGES:
        for cat, topic, standard_name in categories:
            column = "F_" + cat + "_" + age   #ex: F_Tot_25_44
            age_label = age.replace("_", "-") #ex: 25-44
            rows.append(("G09", column, topic, "F", age_label, standard_name))

    # all-ages totals (needed to compare with 2011, which has no age split)
    # note: don't use 'Elsewhere', it is not "born overseas"
    # born overseas = Tot - Australia - COB_NS (not_stated) (calculated later in SQL)
    rows.append(("G09", "F_Tot_Tot", "population", "F", None, "all_females_birthplace_total"))
    rows.append(("G09", "F_Australia_Tot", "birthplace", "F", None, "all_females_born_australia"))
    rows.append(("G09", "F_COB_NS_Tot", "birthplace", "F", None, "all_females_birthplace_not_stated"))

    return rows

def g13_rows(year):
    """
    ABS spells some G13 columns differently each Census:
    - 2021 uses "UOLSE" (uses other language) and "LUatH" (language used at home)
    - 2016 uses "SOLSE" (speaks other language) and "LSatH" (language spoken at home)
    """
    if year == 2021:
        other = "UOLSE"
        not_stated = "LUatH"
    else:
        other = "SOLSE"
        not_stated = "LSatH"

    rows = []

    # language used at home (females, all ages)
    rows.append(("G13", "FSEO_Tot", "language", "F", None, "all_females_english_only"))
    rows.append(("G13", "FOL_Tot_Tot", "language", "F", None, "all_females_other_language"))
    rows.append(("G13", "F_" + not_stated + "_NS_Tot", "language", "F", None, "all_females_language_not_stated"))

    # English proficiency (only for women who speak another language)
    rows.append(("G13", "F_Tot_" + other + "_VWorW", "proficiency", "F", None, "all_females_english_well"))
    rows.append(("G13", "F_Tot_" + other + "_NWorNAA", "proficiency", "F", None, "all_females_english_not_well"))
    rows.append(("G13", "F_Tot_NS", "proficiency", "F", None, "all_females_english_not_stated"))

    # total females (the denominator)
    rows.append(("G13", "F_Tot_Tot", "population", "F", None, "all_females_language_total"))

    return rows

# G11 (2021 only): sensitivity check on English proficiency
# covers PERSONS (men and women) aged 25-74, totals over all years of arrival
# no standard_name, because no view uses it
G11_AGE_RANGES = ["25_34", "35_44", "45_54", "55_64", "65_74"]
G11_CATEGORIES = ["SEO", "UOLSE_VWW", "UOLSE_NWNAA", "T"]   # English only, well, not well, total

G11 = []
for age in G11_AGE_RANGES:
    for categories in G11_CATEGORIES:
        column = "A" + age + "_" + categories + "_T"      #ex: A25_34_SEO_T
        age_label = age.replace("_", "-")          #ex: 25-34
        G11.append(("G11", column, "proficiency", "P", age_label, None))

# 2011 uses a different table set (B-tables), so its columns are listed by hand.
# B09 has no age split and B13 has no proficiency, so we only get females of all ages.
B_2011 = [
    ("B09", "Tot_F", "population", "F", None, "all_females_birthplace_total"),
    ("B09", "Australia_F", "birthplace", "F", None, "all_females_born_australia"),
    ("B09", "Country_birth_not_stated_F", "birthplace", "F", None, "all_females_birthplace_not_stated"),
    ("B13", "SEO_Females", "language", "F", None, "all_females_english_only"),
    ("B13", "SOL_Tot_F", "language", "F", None, "all_females_other_language"),
    ("B13", "Total_F", "population", "F", None, "all_females_language_total")
    ]

# settings for each Census year:
# folder = which DataPack folder to read
# prefix = added to table codes for older years (ex: "2016_G09") so years don't clash
# variables = the list of columns to extract
YEARS = {
    2021: {
        "folder": "2021_GCP_SA3_for_AUS_short-header",
        "prefix": "",
        "variables": g09_rows() + g13_rows(2021) + G11,
    },
    2016: {
        "folder": "2016_GCP_SA3_for_AUS_short-header",
        "prefix": "2016_",
        "variables": g09_rows() + g13_rows(2016),
    },
    2011: {
        "folder": "2011_BCP_SA3_for_AUST_short-header",
        "prefix": "2011_",
        "variables": B_2011,
    },
}

# 2021 table codes stay unprefixed ('G09') so existing rows don't change;
# earlier years are prefixed ('2016_G09', '2011_B09') so source stays per year.

# ABS non-spatial SA3 codes: one 'migratory/offshore/shipping' (x9797) and one 'no usual address' (x9999) per state = 18 codes. Verified against the real G09A file.
NON_SPATIAL = re.compile(r"^\d(9797|9999)$")


# Reading the DataPack files
def find_metadata_file(datapack_dir):
    """
    Find the metadata Excel file in the DataPack folder.
    It explains what each short column name means (ex: F_Tot_25_44 = females aged 25-44, total).
    """
    for path in datapack_dir.rglob("*.xlsx"):
        name = path.name.lower()
        # skip the geography metadata file, we want the column descriptions
        if "metadata" in name and "geog" not in name:
            return path
 
    raise FileNotFoundError(f"No metadata .xlsx found under {datapack_dir}")
 
 
def read_cell_descriptors(datapack_dir):
    """
    Read the metadata file into a table with 3 columns: table, short, long.
    ex: table = G09, short = F_Tot_25_44, long = Females_25_44_years_Total
    The header row is not on row 1 (ABS puts a title above it),
    so we look for the row that contains both "Short" and "Long".
    """
    meta_file = find_metadata_file(datapack_dir)
 
    for sheet in pd.ExcelFile(meta_file).sheet_names:
        # look at the first 30 rows only, without a header
        raw = pd.read_excel(meta_file, sheet_name=sheet, header=None, nrows=30)
 
        for row_number, row in raw.iterrows():
            cells = [str(v) for v in row if pd.notna(v)]
            has_short = any("Short" in c for c in cells)
            has_long = any("Long" in c for c in cells)
 
            if has_short and has_long:
                # found the header row, so read the sheet again using it
                df = pd.read_excel(meta_file, sheet_name=sheet, header=row_number)
 
                # find the column names that contain "Short", "Long" and the table name
                short_col = None
                long_col = None
                table_col = None
                for col in df.columns:
                    if "Short" in str(col) and short_col is None:
                        short_col = col
                    if "Long" in str(col) and long_col is None:
                        long_col = col
                    if ("DataPack" in str(col) or "Profile table" in str(col)) and table_col is None:
                        table_col = col
 
                result = pd.DataFrame()
                if table_col is not None:
                    result["table"] = df[table_col]
                else:
                    result["table"] = "?"
                result["short"] = df[short_col]
                result["long"] = df[long_col]
 
                # drop empty rows
                result = result.dropna(subset=["short", "long"])
                return result
 
    raise ValueError(f"Couldn't find a sheet with 'Short' and 'Long' columns in {meta_file.name}")
 
 
def find_sa3_csvs(datapack_dir, table):
    """
    Find all the CSV files for one table at SA3 level.
    Big tables are split into parts, ex: G09 -> G09A, G09B ... G09H,
    so we return every part.
    2011 file names end in "_SA3_short.csv", 2016/2021 end in "_SA3.csv".
    """
    #ex: matches 2021Census_G09A_AUST_SA3.csv and 2011Census_B09_AUST_SA3_short.csv
    pattern = re.compile(rf"Census_{table}[A-Z]?_.*SA3[^/]*\.csv$", re.IGNORECASE)
 
    files = []
    for path in datapack_dir.rglob("*.csv"):
        if pattern.search(path.name):
            files.append(path)
 
    if len(files) == 0:
        raise FileNotFoundError(f"No SA3 CSV for {table} under {datapack_dir}")
 
    return sorted(files)
 
 
def read_census_table(datapack_dir, table):
    """
    Read every part of one table and join them side by side on the SA3 code,
    so G09A + G09B + ... become one wide table.
    """
    merged = None
 
    for path in find_sa3_csvs(datapack_dir, table):
        # read everything as text, so codes like '10102' stay exactly as they are
        df = pd.read_csv(path, dtype=str)
 
        # the first column is the area code; its name differs by year
        # (SA3_CODE_2021, SA3_CODE_2016, region_id in 2011), so rename it
        df = df.rename(columns={df.columns[0]: "geo_code"})
 
        if merged is None:
            merged = df
        else:
            merged = merged.merge(df, on="geo_code", how="outer")
 
    return merged
 
 
# Extraction
def extract(datapack_dir, year):
    """
    Pull out the columns listed in YEARS[year] and turn them into one long table:
    one row per area per variable.
    """
    settings = YEARS[year]
    variables = settings["variables"]
 
    # long labels (nice to have; if the metadata can't be read, use the short names instead)
    try:
        descriptors = read_cell_descriptors(datapack_dir)
        labels = dict(zip(descriptors["short"], descriptors["long"]))
    except (FileNotFoundError, ValueError, StopIteration) as e:
        print(f"(no long labels: {e}); using column names as labels")
        labels = {}
 
    # which tables do we need this year? (ex: G09, G11, G13)
    tables = []
    for entry in variables:
        if entry[0] not in tables:
            tables.append(entry[0])
    tables.sort()
 
    pieces = []
 
    for table in tables:
        # the entries for this table only
        wanted = []
        for entry in variables:
            if entry[0] == table:
                wanted.append(entry)
 
        wanted_columns = []
        for entry in wanted:
            wanted_columns.append(entry[1])
 
        data = read_census_table(datapack_dir, table)
 
        # 3. stop early if a column name is wrong
        missing = []
        for col in wanted_columns:
            if col not in data.columns:
                missing.append(col)
        if len(missing) > 0:
            raise KeyError(f"{table}: columns not in CSV: {missing}. Use `find` to get the real names.")
 
        # drop the 18 fake areas (migratory / no usual address)
        n_before = len(data)
        data = data[~data["geo_code"].str.match(NON_SPATIAL)]
        print(f"{table}: {n_before} areas, dropped {n_before - len(data)} non-spatial, kept {len(data)}")
 
        # wide -> long: one row per area per column
        # ex: (10102, F_Tot_25_44, 4253)
        long = data.melt(id_vars="geo_code", value_vars=wanted_columns,
                         var_name="source_column", value_name="value")
 
        # every value should be a number (DataPacks have no 'n.p.'); stop if not
        long["value"] = pd.to_numeric(long["value"], errors="raise")
 
        # attach the description of each column (topic, sex, age, standard name)
        info = pd.DataFrame(wanted, columns=["table_code", "source_column", "topic",
                                             "sex", "age_label", "standard_name"])
        info["table_code"] = settings["prefix"] + info["table_code"]   # ex: 2016_G09
        long = long.merge(info, on="source_column", how="left")
 
        # extra columns the loader needs
        long["variable_code"] = long["table_code"] + ":" + long["source_column"]   # ex: 2016_G09:F_Tot_25_44
        long["variable_label"] = long["source_column"].map(labels).fillna(long["source_column"])
        long["census_year"] = year
 
        file_names = []
        for path in find_sa3_csvs(datapack_dir, table):
            file_names.append(path.name)
        long["source_file"] = ", ".join(file_names)
 
        pieces.append(long)
 
    # stack all tables together, in a fixed column order
    out = pd.concat(pieces, ignore_index=True)
    column_order = ["geo_code", "variable_code", "table_code", "source_column", "variable_label",
                    "topic", "sex", "age_label", "standard_name", "census_year", "value", "source_file"]
    return out[column_order]
 
 
# Running the script
def main():
    # folders are worked out from where this script lives, so it works from any folder
    script_dir = Path(__file__).resolve().parent
    data_dir = script_dir.parent / "data"
 
    # read the command, ex: "extract --year 2016"
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["find", "extract"])
    parser.add_argument("phrase", nargs="?", help="for `find`: text to search in long labels")
    parser.add_argument("--year", type=int, default=2021, choices=sorted(YEARS))
    parser.add_argument("--datapack-dir", help="defaults to the folder for --year under data/")
    parser.add_argument("--out", help="defaults to data/extracted/census_<year>_sa3_long.csv")
    args = parser.parse_args()
 
    # where to read from
    if args.datapack_dir:
        datapack_dir = Path(args.datapack_dir)
    else:
        datapack_dir = data_dir / YEARS[args.year]["folder"]
 
    if not datapack_dir.exists():
        raise FileNotFoundError(f"DataPack folder not found: {datapack_dir.resolve()}")
 
    # where to save to
    if args.out:
        out_path = Path(args.out)
    else:
        out_path = data_dir / "extracted" / f"census_{args.year}_sa3_long.csv"
 
    # mode 1: "find" searches the metadata for a phrase, to look up column names
    if args.mode == "find":
        d = read_cell_descriptors(datapack_dir)
        label = d["long"].astype(str).str.replace("_", " ")   # ABS long labels use underscores
        phrase = (args.phrase or "").replace("_", " ")
        hits = d[label.str.contains(phrase, case=False, regex=False)]
        if len(hits) > 0:
            print(hits.to_string(index=False, max_colwidth=90))
        else:
            print("no matches")
        return
 
    # mode 2: "extract" builds the long table and saves it as a CSV
    out = extract(datapack_dir, args.year)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out.to_csv(out_path, index=False)
    print(f"\nSaved {len(out):,} rows ({out['variable_code'].nunique()} variables x "
          f"{out['geo_code'].nunique()} areas) -> {out_path}")
 
 
if __name__ == "__main__":
    main()
