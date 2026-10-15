"""
Load the extracted Census CSV (made by Census_data_extraction.py) into the database,
like load_data_to_db.py does for AIHW.

Before running: the database must already have the Census tables (schema.sql, or
migrations 002-004), and the AIHW data must be loaded first, because the SA3 areas
come from the AIHW load (lookup_geography).

How to run (from a terminal, or with ! in a notebook cell):
    python load_census_data_to_db.py check -> compare area codes, writes nothing
    python load_census_data_to_db.py load  -> 2021 (default file)
    python load_census_data_to_db.py load --csv ../data/extracted/census_2016_sa3_long.csv
    python load_census_data_to_db.py load --csv ../data/extracted/census_2011_sa3_long.csv

Safe to re-run: rows that already exist are updated, not duplicated.
"""
import argparse
import os
from pathlib import Path

import pandas as pd
import psycopg2
from dotenv import load_dotenv
from psycopg2.extras import execute_values


def check_geography(cur, census_codes):
    """
    Compare the area codes in the Census file with the SA3 areas already in the database.
    Only areas found in both can be loaded (the database rejects unknown areas).
    Returns the set of matching codes.
    """
    cur.execute("SELECT geo_code, geo_name FROM lookup_geography WHERE geo_level = 'sa3'")
    aihw = {}
    for code, name in cur.fetchall():
        aihw[code] = name

    matched = set()
    only_census = []
    only_aihw = []

    for code in census_codes:
        if code in aihw:
            matched.add(code)
        else:
            only_census.append(code)     #in the Census file but not in the database

    for code in aihw:
        if code not in census_codes:
            only_aihw.append((code, aihw[code]))   #in the database but not in the Census file

    only_census.sort()
    only_aihw.sort()

    print(f"AIHW SA3 codes:   {len(aihw)}")
    print(f"Census SA3 codes: {len(census_codes)}")
    print(f"Matched:          {len(matched)}")
    print(f"In Census only:   {len(only_census)} {only_census}")
    print(f"In AIHW only:     {len(only_aihw)} {only_aihw}")
    print("   (expected: 0 for 2016 and 2021; 18 for 2011, the areas created after 2011)")
    return matched


def load(cur, df):
    """
    Write one year's Census CSV into the 3 tables, in order.
    """

    #keep only the areas that exist in the database
    matched = check_geography(cur, set(df["geo_code"]))
    df = df[df["geo_code"].isin(matched)]

    #lookup_report_table: one row per ABS table (where the data came from)
    tables = df[["table_code", "source_file", "census_year"]].drop_duplicates()
    for _, t in tables.iterrows():
        abs_table = t["table_code"].split("_")[-1]       # '2016_G09' -> 'G09'
        description = f"ABS {t['census_year']} Census table {abs_table} (SA3)"
        cur.execute(
            "INSERT INTO lookup_report_table (table_code, description, indicator_category, source_file) "
            "VALUES (%s, %s, 'census', %s) ON CONFLICT (table_code) DO NOTHING",
            (t["table_code"], description, t["source_file"]))

    #lookup_census_variable: one row per Census column (what each number means)
    var_cols = ["variable_code", "table_code", "source_column", "variable_label",
                "topic", "sex", "age_label", "standard_name"]
    variables = df[var_cols].drop_duplicates()

    var_rows = []
    for _, row in variables.iterrows():
        values = []
        for col in var_cols:
            if pd.isna(row[col]):
                values.append(None)      #empty cell (ex: no age band) -> NULL in the database
            else:
                values.append(row[col])
        var_rows.append(tuple(values))

    #if the variable already exists, update its label and standard name instead of failing
    execute_values(cur,
        "INSERT INTO lookup_census_variable (" + ", ".join(var_cols) + ") VALUES %s "
        "ON CONFLICT (variable_code) DO UPDATE SET variable_label = EXCLUDED.variable_label, "
        "standard_name = EXCLUDED.standard_name",
        var_rows)

    #census_area_value: the numbers, one row per area per variable per year
    value_rows = []
    for _, row in df.iterrows():
        value_rows.append((row["geo_code"], row["variable_code"],
                           int(row["census_year"]), float(row["value"])))

    #if the same area + variable + year already exists, update the value (no duplicates)
    execute_values(cur,
        "INSERT INTO census_area_value (geo_code, variable_code, census_year, value) VALUES %s "
        "ON CONFLICT (geo_code, variable_code, census_year) DO UPDATE SET value = EXCLUDED.value",
        value_rows)

    print(f"\nLoaded {len(var_rows)} variables and {len(value_rows):,} values")


def main():
    #default file: the 2021 CSV, found relative to where this script lives
    script_dir = Path(__file__).resolve().parent
    default_csv = script_dir.parent / "data" / "extracted" / "census_2021_sa3_long.csv"

    #read the command, e.g. "load --csv ...2016.csv"
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["check", "load"])
    parser.add_argument("--csv", default=str(default_csv))
    args = parser.parse_args()

    #read the CSV; keep codes as text so '10102' stays exactly as it is
    df = pd.read_csv(args.csv, dtype={"geo_code": str})

    #connect using DATABASE_URL from the .env file
    load_dotenv()
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    cur = conn.cursor()

    try:
        if args.mode == "check":
            check_geography(cur, set(df["geo_code"]))
        else:
            load(cur, df)
            conn.commit()      #save everything at once: all of it lands, or none of it
    except Exception:
        conn.rollback()        #something failed: undo this run's changes
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()