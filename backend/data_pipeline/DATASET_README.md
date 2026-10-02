# ScreeningTogether AU — Database Documentation

This document explains what's in the database, where it came from, and how to query it. **Read this before writing any query against the data**, especially the sections "Rules that prevent wrong numbers" and "Using the data for the heatmap".

## Contents

1. Sources
2. Schema shape
3. Rules that prevent wrong numbers
4. AIHW tables
5. Census tables (new)
6. Views (new)
7. Using the data for the heatmap
8. Checking the data is correct
9. Re-running the pipeline
10. Things that look like bugs but aren't
11. Known limitations
12. Attribution

---

## 1. Sources

| Source | What it gives us | Licence |
|---|---|---|
| **AIHW** National Cervical Screening Program monitoring report 2025 (`AIHW_CAN166_recruitment_data_tables.xlsx`, `AIHW_CAN166_outcomes_data_tables.xlsx`) | Screening participation, test volumes, invitation responses, cancer incidence and mortality | CC BY 4.0 |
| **ABS** 2021 Census, General Community Profile DataPack, SA3 level (`2021_GCP_SA3_for_AUS_short-header`) | Birthplace, language at home and English proficiency per SA3 area | CC BY 4.0 (confirm on the DataPack page) |

All data is official, government-published statistics: nothing is scraped or estimated.

**Not in the database:** the Healthdirect NHSD clinic directory (GP finder). Its licence for public display is still being confirmed with AURIN, so it is kept out of the shared database for now.

## 2. Schema shape

**6 lookup tables, 5 fact tables, 3 views.**

```
LOOKUPS                        FACTS                              VIEWS (calculated on read)
lookup_report_table ─┐         screening_participation  (AIHW) ─┐
lookup_geography ────┤         response_to_invitation   (AIHW)  ├─► v_sa3_participation_2574 ─┐
lookup_age_group ────┼────────►monthly_test_volume      (AIHW)  │                              ├─► v_sa3_linked
lookup_metric ───────┤         cancer_outcomes          (AIHW)  │                              │   (used by the heatmap)
lookup_letter_type ──┤         census_area_value        (ABS) ──┴─► v_sa3_census_measures ─────┘
lookup_census_variable (new) ─┘
```

**Lookup tables** hold shared reference data:
- `lookup_report_table`: one row per source table (AIHW e.g. `S1.2a`; Census e.g. `G09`), with description and source file
- `lookup_geography`: states, socioeconomic quintiles and the 340 SA3 areas, tagged by `geo_level`. **AIHW and Census data share these same SA3 rows; that's how they link**
- `lookup_age_group`: AIHW age brackets, in natural order
- `lookup_metric`: kinds of AIHW numbers (counts, rates, population)
- `lookup_letter_type`: invitation letter categories (A1, B1, C1, D1)
- `lookup_census_variable` *(new)*: one row per Census column loaded, with its meaning, topic, sex and age band

**Fact tables** hold the numbers: four AIHW tables plus `census_area_value` *(new)*.

**Views** store no data. They are saved queries that recalculate from the tables every time you read them, so they are always in sync with the data.

## 3. Rules that prevent wrong numbers

These are the mistakes that are easiest to make with this data. Every one has been made at least once on this project.

1. **Never sum across age rows.** `screening_participation` contains individual brackets (`25-29` … `70-74`) *and* summary rows (`<25`, `75+`, `ages_25-74_years`, `all_ages`) that overlap them. Summing everything double- or triple-counts. For the screening-age population, use only `age_code = 'ages_25-74_years'`.
2. **Never average age-bracket percentages.** That weights a small bracket like a large one. The correct rate is `number ÷ population` on the `ages_25-74_years` row. This reproduces AIHW's published crude rate exactly (national: 80.8% / 78.6% / 77.9%).
3. **Never subtract one window from another.** Windows overlap and count unique people, so the difference is not a single year's figure.
4. **Suppressed is not zero.** When `is_suppressed = true`, the value is `NULL` because AIHW withheld it. Exclude these rows; never treat them as 0.
5. **Don't rank or compare states for users.** AIHW's own notes advise against direct state comparisons, and our tone rules forbid comparative shaming by area.
6. **Counts are not rates.** A state with more women screened may simply have more women. Compare rates, not counts.

## 4. AIHW tables

### `screening_participation`

Participation counts, percentages and populations by age group and one of three geography levels (state, SA3 or socioeconomic quintile).

| Column | Meaning |
|---|---|
| `geo_code` | Links to `lookup_geography`: a state, SA3 area or socioeconomic quintile |
| `age_code` | Links to `lookup_age_group`. Use `ages_25-74_years` for the screening population |
| `metric_code` | `number`, `per_cent` or `population` |
| `year_start` / `year_end` | The reporting window (see "Understanding the year windows" below) |
| `is_suppressed` | `true` if AIHW withheld this value for privacy. When true, `value` is `NULL` |

**Sources loaded:** S1.2 (state), S1.4 (socioeconomic), S1.8 (SA3), all three reporting windows each.

**SA3 now includes the official 25–74 total.** In the source file the SA3 summary row is labelled `25–74` (not `Ages 25–74 years` as in other tables). The loader now maps it to `ages_25-74_years`, so every SA3 has AIHW's own published total. SA3 data: 340 areas, 33,660 rows, 909 suppressed (2.7%). Only 3 areas have a suppressed 25–74 total: Illawarra Catchment Reserve, Blue Mountains – South and Jervis Bay.

**Not loaded:** S1.7 (SA2). It has much higher suppression (~15%) than SA3 (~3%), and SA3 areas are built from whole SA2 areas, so nothing independent is lost. The extraction code for S1.7 still exists if needed.

#### Understanding the year windows

Each window label (e.g. 2018–2022) describes the **population denominator**: the average population of women aged 25–74 over those years, adjusted to exclude women who have had a hysterectomy. The **numerator** counts women tested over **5.5 years**: for 2018–2022, tests from 1 January 2018 to 30 June 2023. This is confirmed in the source footnotes for S1.2 and S1.8.

| Window | Tests counted |
|---|---|
| 2018–2022 | 1 Jan 2018 – 30 Jun 2023 |
| 2019–2023 | 1 Jan 2019 – 30 Jun 2024 |
| 2020–2024 | 1 Jan 2020 – 30 Jun 2025 |

**Example: participation rate for each state, latest window**
```sql
SELECT geo_code,
       ROUND(100 * MAX(value) FILTER (WHERE metric_code = 'number')
                 / MAX(value) FILTER (WHERE metric_code = 'population'), 1) AS rate_pct
FROM screening_participation
WHERE table_code = 'S1.2c' AND age_code = 'ages_25-74_years'
GROUP BY geo_code
ORDER BY geo_code;
```

### `response_to_invitation`

How many people were invited to screen and how many responded, broken down by age, state or letter type (never more than one breakdown at a time).

| Column | Meaning |
|---|---|
| `age_code` | Always set. If the row is broken down by state or letter type instead, this is `all_ages` |
| `geo_code` | Only set for state rows (S2.2). `NULL` otherwise |
| `letter_type_code` | Only set for letter-type rows (S2.3). `NULL` otherwise |
| `year` | A real, individual year (2019–2024), not a window |
| `metric_code` | `invited`, `responded` or `crude_rate` |

**Known limitation:** no `is_suppressed` flag. Suppressed values (`n.p.`) were skipped during loading, so a missing row may mean "withheld", not "no data".

### `monthly_test_volume`

HPV tests performed each month, nationally (no geography).

| Column | Meaning |
|---|---|
| `year` / `month` | A real calendar month |
| `test_type` | `hpv_test` (all tests) or `self_collected` |

`table_code` follows `S1.5a` = 2018 … `S1.5h` = 2025. **2025 is a partial year** (January–June only).

### `cancer_outcomes`

Cervical cancer incidence and mortality. **Background and citation evidence only; it does not power any app feature.**

**Important:** for the windowed tables (S19.5, S19.7: 2017–2021; S20.3, S20.5: 2019–2023), `year` stores the **window's end year**, not a single year. Check `lookup_report_table.description` for the real window. Indigenous-status tables (S19.4, S20.2) are excluded per the project's no-go constraints.

## 5. Census tables (new)

All Census data is from **Census night, 10 August 2021**: one snapshot, at SA3 level, for the same 340 areas as AIHW.

### `lookup_census_variable`

One row per Census column loaded (39 in total).

| Column | Meaning |
|---|---|
| `variable_code` | `<table>:<ABS column>`, e.g. `G09:F_Tot_25_44` |
| `table_code` | ABS table: `G09`, `G11` or `G13` |
| `source_column` | The ABS column name exactly as in the DataPack CSV |
| `variable_label` | ABS's long description of the column |
| `topic` | `population`, `birthplace`, `language` or `proficiency` |
| `sex` | `F` (females) or `P` (persons, all sexes) |
| `age_label` | The Census age band, e.g. `25-44`. `NULL` means all ages. **Deliberately not linked to `lookup_age_group`**: Census age bands differ from AIHW's |

### `census_area_value`

The Census numbers: one row per SA3 per variable (13,260 rows = 39 variables × 340 areas). Values are **counts of people**, not percentages.

| Column | Meaning |
|---|---|
| `geo_code` | The SA3 area, linking to `lookup_geography` (the same codes as AIHW) |
| `variable_code` | Links to `lookup_census_variable` |
| `census_year` | Always 2021 |
| `value` | A count of people |

This table has a UNIQUE constraint on `(geo_code, variable_code, census_year)`, so reloading updates rows instead of duplicating them.

### What was loaded, and why

| ABS table | What it contains | Who it covers | Used for |
|---|---|---|---|
| **G09** Country of birth × age × sex | Female total, born in Australia, birthplace not stated, in four bands (25–44, 45–54, 55–64, 65–74) | **Women aged 25–74**: exactly the AIHW screening population | Born-overseas share |
| **G13** Language at home × English proficiency × sex | English only, other language, language not stated, English well / not well / not stated, total | **Females of all ages** (G13 has no age split) | Other-language and low-proficiency shares |
| **G11** Proficiency × year of arrival × age | English only, well, not well, total, in 10-year bands 25–34 … 65–74 | **Persons aged 25–74**, probably overseas-born only | Sensitivity check on proficiency (not used in the views) |

**Watch out: `Elsewhere` in G09 does NOT mean "born overseas".** It is the leftover group for countries not listed individually. Born overseas must be calculated as **Total − Australia − Not stated**. The views already do this correctly.

**18 non-spatial Census areas were dropped** (codes ending `9797` "migratory/offshore" and `9999` "no usual address", two per state). They have no AIHW equivalent.

## 6. Views (new)

Three saved queries, building on each other. **For the heatmap, you only need `v_sa3_linked`.**

### `v_sa3_participation_2574`: AIHW side

AIHW SA3 participation tidied into **one row per area per window**, women aged 25–74. 1,020 rows (340 areas × 3 windows).

| Column | Meaning |
|---|---|
| `geo_code`, `geo_name` | The area's code and name |
| `year_start`, `year_end` | The AIHW window |
| `screened` | Women aged 25–74 who had a screening test |
| `eligible_pop` | Women aged 25–74 who could have screened (AIHW estimate) |
| `rate_pct` | **Participation rate (%)**: AIHW's published figure |
| `is_suppressed` | `true` if AIHW withheld the area: **exclude** |
| `over_100` | `true` if the rate exceeds 100% (an artefact of the 5.5-year numerator against an average population): **exclude** |

`rate_pct` uses AIHW's published percentage rather than recomputing `screened ÷ eligible_pop`, because SA3 populations are published rounded to whole people, which makes recomputed rates drift slightly in tiny areas.

### `v_sa3_census_measures`: Census side

Census counts turned into **percentages**, so big and small areas can be compared. One row per area (340 rows).

| Column | Meaning | Who it covers |
|---|---|---|
| `women_25_74` | Women aged 25–74 counted in the Census | Women 25–74 |
| `females_all_ages` | All females counted | Females, all ages |
| `pct_born_overseas` | % born outside Australia | Women 25–74 |
| `pct_other_language` | % speaking a language other than English at home | Females, all ages |
| `pct_low_proficiency` | % speaking English "not well" or "not at all" | Females, all ages |
| `pct_birthplace_ns` | % who didn't state their birthplace: **a quality flag**; high values make that area's shares less reliable | Women 25–74 |

All percentages use **"stated" denominators**: people who didn't answer are removed from both the top and bottom of the fraction, so non-response doesn't drag shares down.

### `v_sa3_linked`: the link

Both sides joined on `geo_code`: **one row per area per AIHW window** (1,020 rows), with participation next to the Census percentages. Contains all columns from the two views above, plus:

| Column | Meaning |
|---|---|
| `pop_ratio` | AIHW eligible women ÷ Census women 25–74. **A quality check, not a finding.** All areas fall between 0.80 and 1.05, which confirmed AIHW and Census describe the same areas |

The Census values are **identical across an area's three rows** (one Census), while participation changes by window.

## 7. Using the data for the heatmap

### What the analysis is

A **cross-sectional, area-level** comparison: each SA3 is one data point, with its participation rate and its Census profile. The question is: *do areas with a higher share of X tend to have higher or lower participation?* It is not a time series: one Census (2021) is compared across places, and 2021 falls inside every AIHW window.

### Getting the analysis-ready data

Use `queries/link_query.sql`. It returns one row per SA3 for the latest window, with the standard exclusions applied (337 rows):

```sql
SELECT geo_code, geo_name, rate_pct, eligible_pop,
       pct_born_overseas, pct_other_language, pct_low_proficiency
FROM v_sa3_linked
WHERE year_start = 2020
  AND NOT is_suppressed
  AND NOT over_100
ORDER BY geo_code;
```

In a notebook:

```python
import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()                                            # reads DATABASE_URL from .env
engine = create_engine(os.getenv("DATABASE_URL"))
query = Path("../queries/link_query.sql").read_text()   # adjust the path to where your notebook is
df = pd.read_sql(query, engine)
```

### Recommended analysis rules (decide before looking at results)

| Rule | Why |
|---|---|
| **Main analysis:** exclude suppressed areas, over-100% areas and areas with **fewer than 1,000 women aged 25–74** (9 areas) | In tiny areas, ABS's random confidentiality adjustments dominate. One tiny area even produces a negative born-overseas share (−5.5%) |
| **Sensitivity check 1:** rerun with all areas included | Shows whether the exclusions change the result |
| **Sensitivity check 2:** exclude areas where `pct_birthplace_ns > 10` (34 areas) | Shares are less reliable where many people didn't answer |
| **Stability check:** repeat for `year_start` 2018, 2019 and 2020 | The Census is fixed and only participation changes, so a consistent result across windows is more trustworthy |
| **Use Spearman, not Pearson, correlation** | Rank-based, so robust to outliers and skewed measures |

### Things that will mislead you if ignored

- **Ecological fallacy.** A correlation between areas says nothing about individuals. "Areas with more overseas-born women have lower participation" does **not** mean overseas-born women participate less. Never word findings that way.
- **Age is a confounder.** AIHW SA3 rates are **crude, not age-standardised**, and participation varies strongly by age (ages 70–74 participate at about 50%). Areas differ in age structure, so part of any correlation could be age, not birthplace or language. Control for it, e.g. with a partial correlation using the share of women aged 65–74 (available from `G09:F_Tot_65_74` ÷ `women_25_74`).
- **The three Census measures are not independent.** Born overseas, other language and low proficiency will correlate strongly with each other. Check this before presenting them as three separate findings.
- **Age-range mismatch.** Born overseas covers women 25–74 (an exact match to AIHW). The two language measures cover females **of all ages**. G11 (persons 25–74) exists as a sensitivity check.
- **Timing.** The Census is one night in August 2021; each AIHW window spans 5.5 years of tests. They overlap, but not perfectly.
- **Structural proxies only.** AIHW does not publish participation by CALD status. These measures describe areas, not CALD women's own screening.

### Two kinds of heatmap

| Type | What it shows | Needs | Risk |
|---|---|---|---|
| **Matrix heatmap** | A grid, e.g. correlations of participation with each Census measure, across the three windows | Only this database | Low: names no areas |
| **Map (choropleth)** | SA3 areas coloured by participation or a Census measure | ABS SA3 boundary files (ASGS Edition 3, 2021), **not yet loaded** | High: visually names places |

### What can be shown to users

Anything that **names or ranks an SA3 area** should be treated as **analyst-only** by default: it risks stigmatising communities and breaks our tone rules (no comparative shaming by area, barriers framed as structural). National-level, non-comparative messages are the candidates for user-facing content. Score every output against the project's suitability criteria before it goes into the app.

## 8. Checking the data is correct

Run these after any reload. All are read-only (`SELECT` only) and safe to run anywhere, including in the Neon SQL Editor block by block.

**`queries/reconcile_db.sql`**: compares the database with the AIHW source. Expected:

| Check | Expected |
|---|---|
| National crude rates | 80.8 / 78.6 / 77.9% (5,562,882 / 5,485,448 / 5,513,616 screened) |
| Duplicate natural keys | No rows returned |
| SA3 shape | 340 areas, 33,660 rows, 909 suppressed, 3,060 rows for `ages_25-74_years` |
| SA3 suppression by window | 306 / 303 / 300 |

**Census load check** (expect G09: 12 variables, 4,080 rows; G11: 20, 6,800; G13: 7, 2,380):
```sql
SELECT v.table_code, COUNT(DISTINCT v.variable_code) AS vars, COUNT(*) AS rows
FROM census_area_value c JOIN lookup_census_variable v USING (variable_code)
GROUP BY 1 ORDER BY 1;
```

**Link check** (expect every `pop_ratio` between about 0.80 and 1.05):
```sql
SELECT geo_code, geo_name, eligible_pop, women_25_74, pop_ratio
FROM v_sa3_linked
WHERE year_start = 2020 AND NOT is_suppressed
ORDER BY pop_ratio;
```

## 9. Re-running the pipeline

```
backend/data_pipeline/
├── scripts/
│   ├── AIHW_data_extraction.py      # AIHW Excel  → data/extracted/*.csv
│   ├── load_data_to_db.py           # AIHW CSVs   → database
│   ├── census_data_extraction.py    # ABS DataPack → data/extracted/census_2021_sa3_long.csv
│   ├── load_census_data_to_db.py    # Census CSV  → database
│   └── schema.sql                   # full schema: tables + views
├── queries/                          # read-only analysis and checking queries
│   ├── reconcile_db.sql
│   ├── check_sa3_2574.sql
│   └── link_query.sql
└── data/                             # raw files are git-ignored
    ├── extracted/
    └── 2021_GCP_SA3_for_AUS_short-header/
```

**AIHW (if a new report edition is published):**
```bash
cd backend/data_pipeline/scripts
python3 AIHW_data_extraction.py
python3 load_schema.py               # only if the schema itself changed
python3 load_data_to_db.py           # safe to re-run: truncates and reloads the 4 AIHW fact tables
```

**Census:**
```bash
python3 census_data_extraction.py find "not stated"   # optional: search ABS column names
python3 census_data_extraction.py extract             # no database needed
python3 load_census_data_to_db.py check               # compares SA3 codes; writes nothing
python3 load_census_data_to_db.py load                # safe to re-run: upserts
```
Expected: `kept 340` for each table, `Saved 13,260 rows`, `Matched: 340`, `In AIHW only: 0`. **If any code appears under "In AIHW only", stop**: it means a geography edition mismatch.

**Order matters:** the AIHW load and the Census load are independent, but `schema.sql` (or migrations `002` then `003` on an existing database) must exist first. The views work on empty tables and fill in automatically once data is loaded.

**Building a fresh database:** run `schema.sql` once. **Don't** run it on an existing database: the tables already exist and it will fail with "already exists".

**Always experiment on a Neon branch,** not the main database.

## 10. Things that look like bugs but aren't

**Values showing as `31.0` instead of `31`.** `value` columns are `NUMERIC` because some metrics are fractional. Postgres shows whole numbers stored this way with `.0`. Round in the query (`ROUND(value)::INTEGER`) or format in the frontend.

**Some SA3 areas have `NULL` participation.** AIHW withheld them for privacy (3 areas). Check `is_suppressed`; never treat these as zero.

**Two SA3 areas have 0 women aged 25–74 in the Census.** These are near-unpopulated areas (e.g. Illawarra Catchment Reserve). Their percentages are `NULL`, not an error. Illawarra Catchment Reserve is also suppressed by AIHW, so the standard filters exclude it; any zero-population area that isn't suppressed is removed by the "fewer than 1,000 women" rule.

**`pop_ratio` is mostly below 1.** Expected. AIHW's population excludes women who have had a hysterectomy (more common at older ages), so older areas show lower ratios (about 0.80). Young or fast-growing areas (e.g. Melbourne City, NT) can exceed 1 because AIHW averages the population over several years.

**Census parts don't add up exactly to totals.** ABS makes small random adjustments to every cell to protect confidentiality, so G13's parts sum to between 0.97 and 1.01 of the total.

**"Skipped 1 unmapped age group(s)" during the AIHW load.** This used to appear for every S1.8 file, before the `25–74` fix. **It should no longer appear.** If you see it, the fix in `load_sa_participation_csv` is missing (check for the en dash `–` in `"25–74"`).

## 11. Known limitations

- AIHW does not publish participation by CALD status; Census measures are area-level structural proxies only.
- Language and proficiency measures cover females of all ages, not just 25–74.
- G11's population is probably overseas-born people only (confirm in the DataPack metadata).
- SA3 participation rates are crude, not age-standardised.
- Census (August 2021) and AIHW windows (2018–2025 tests) overlap but don't match exactly.
- `response_to_invitation` has no suppression flag.
- SA3 codes match between the sources (340/340) and the population ratios are consistent, but identical boundaries are not formally proven.

## 12. Attribution

Any output using this data must credit both sources:

- *Based on Australian Institute of Health and Welfare material.*
- *Based on Australian Bureau of Statistics data* (because we derive percentages, rather than reproducing ABS figures unchanged).
