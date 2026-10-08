# ScreeningTogether AU — Database Documentation

This document explains what's in the database, where it came from, and how to query it. **Read this before writing any query against the data**, especially "Rules that prevent wrong numbers", "Using the data for the heatmap" and "Using the data for change over time".

## Contents

1. Sources
2. Schema shape
3. Rules that prevent wrong numbers
4. AIHW tables
5. Census tables
6. Views
7. Using the data for the heatmap
8. Using the data for change over time
9. Checking the data is correct
10. Building and re-running the pipeline
11. Things that look like bugs but aren't
12. Known limitations
13. Attribution

---

## 1. Sources

| Source | What it gives us | Licence |
|---|---|---|
| **AIHW** National Cervical Screening Program monitoring report 2025 (`AIHW_CAN166_recruitment_data_tables.xlsx`, `AIHW_CAN166_outcomes_data_tables.xlsx`) | Screening participation, test volumes, invitation responses, cancer incidence and mortality | CC BY 4.0 |
| **ABS** 2021 Census, General Community Profile DataPack, SA3 (`2021_GCP_SA3_for_AUS_short-header`) | Birthplace, language at home and English proficiency per SA3 | CC BY 4.0 |
| **ABS** 2016 Census, General Community Profile DataPack, SA3 (`2016_GCP_SA3_for_AUS_short-header`) | Birthplace, language at home and English proficiency per SA3 | CC BY 4.0 |
| **ABS** 2011 Census, Basic Community Profile DataPack, SA3 (`2011_BCP_SA3_for_AUST_short-header`) | Birthplace and language at home per SA3 (no proficiency, no age split) | CC BY 4.0 |

All data is official, government-published statistics: nothing is scraped or estimated.

**Not in the database:** the Healthdirect NHSD clinic directory (GP finder). Its licence for public display is still being confirmed with AURIN, so it is kept out of the shared database for now.

## 2. Schema shape

**6 lookup tables, 5 fact tables, 4 views.**

```
LOOKUPS                        FACTS                               VIEWS (calculated on read)
lookup_report_table ─┐         screening_participation  (AIHW) ──► v_sa3_participation_2574 ─┐
lookup_geography ────┤         response_to_invitation   (AIHW)                                ├─► v_sa3_linked
lookup_age_group ────┼────────►monthly_test_volume      (AIHW)                                │   (heatmap: 2021 only)
lookup_metric ───────┤         cancer_outcomes          (AIHW)    ┌─► v_sa3_census_measures ──┘
lookup_letter_type ──┤         census_area_value        (ABS) ────┤
lookup_census_variable ───────┘                                    └─► v_sa3_census_trend
                                                                       (change over time: 2011/2016/2021)
```

**Lookup tables** hold shared reference data:
- `lookup_report_table`: one row per source table (AIHW e.g. `S1.2a`; Census e.g. `G09`, `2016_G09`, `2011_B09`), with description and source file
- `lookup_geography`: states, socioeconomic quintiles and the 340 SA3 areas, tagged by `geo_level`. **AIHW and Census data share these same SA3 rows; that's how they link**
- `lookup_age_group`: AIHW age brackets, in natural order
- `lookup_metric`: kinds of AIHW numbers (counts, rates, population)
- `lookup_letter_type`: invitation letter categories (A1, B1, C1, D1)
- `lookup_census_variable`: one row per Census column loaded, with its meaning, topic, sex, age band and **standard name**

**Fact tables** hold the numbers: four AIHW tables plus `census_area_value`.

**Views** store no data. They are saved queries that recalculate from the tables every time you read them, so they are always in sync with the data.

## 3. Rules that prevent wrong numbers

These are the mistakes that are easiest to make with this data. Every one has been made at least once on this project.

1. **Never sum across age rows.** `screening_participation` contains individual brackets (`25-29` … `70-74`) *and* summary rows (`<25`, `75+`, `ages_25-74_years`, `all_ages`) that overlap them. Summing everything double- or triple-counts. For the screening-age population, use only `age_code = 'ages_25-74_years'`.
2. **Never average age-bracket percentages.** That weights a small bracket like a large one. The correct rate is `number ÷ population` on the `ages_25-74_years` row. This reproduces AIHW's published crude rate exactly (national: 80.8% / 78.6% / 77.9%).
3. **Never subtract one window from another.** Windows overlap and count unique people, so the difference is not a single year's figure.
4. **Suppressed is not zero.** When `is_suppressed = true`, the value is `NULL` because AIHW withheld it. Exclude these rows; never treat them as 0.
5. **Don't rank or compare states for users.** AIHW's own notes advise against direct state comparisons, and our tone rules forbid comparative shaming by area.
6. **Counts are not rates.** A state with more women screened may simply have more women. Compare rates, not counts.
7. **Never select Census columns by name pattern** (e.g. `LIKE 'F_Tot_%'`). Use `standard_name`. A pattern match once silently inflated the women 25–74 total 2.6 times by catching an all-ages column.
8. **Never link 2011 or 2016 Census data to participation.** Only the 2021 Census overlaps the AIHW windows (2018–2025), and screening before December 2017 was a different program (Pap tests).

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

**SA3 includes the official 25–74 total.** In the source file the SA3 summary row is labelled `25–74` (not `Ages 25–74 years` as in other tables). The loader maps it to `ages_25-74_years`, so every SA3 has AIHW's own published total. SA3 data: 340 areas, 33,660 rows, 909 suppressed (2.7%). Only 3 areas have a suppressed 25–74 total: Illawarra Catchment Reserve, Blue Mountains – South and Jervis Bay.

**Not loaded:** S1.7 (SA2). It has much higher suppression (~15%) than SA3 (~3%), and SA3 areas are built from whole SA2 areas, so nothing independent is lost. The extraction code for S1.7 still exists if needed.

#### Understanding the year windows

Each window label (e.g. 2018–2022) describes the **population denominator**: the average population of women aged 25–74 over those years, adjusted to exclude women who have had a hysterectomy. The **numerator** counts women tested over **5.5 years**: for 2018–2022, tests from 1 January 2018 to 30 June 2023. This is confirmed in the source footnotes for S1.2 and S1.8.

| Window | Tests counted |
|---|---|
| 2018–2022 | 1 Jan 2018 – 30 Jun 2023 |
| 2019–2023 | 1 Jan 2019 – 30 Jun 2024 |
| 2020–2024 | 1 Jan 2020 – 30 Jun 2025 |

The windows **cannot be split into single years**, by subtraction or any other calculation: they count unique women, and the overlap between windows isn't published. For month-level timing, use `monthly_test_volume` (national test counts).

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

## 5. Census tables

Three Censuses at SA3 level: **2011, 2016 and 2021** (each taken on one night in August of that year).

### `lookup_census_variable`

One row per Census column loaded: **70 in total** (2021: 42, 2016: 22, 2011: 6).

| Column | Meaning |
|---|---|
| `variable_code` | `<table>:<ABS column>`. 2021 tables have no prefix (`G09:F_Tot_25_44`); earlier years do (`2016_G09:F_Tot_25_44`, `2011_B09:Tot_F`) |
| `table_code` | ABS table: `G09`, `G11`, `G13` (2021); `2016_G09`, `2016_G13`; `2011_B09`, `2011_B13` |
| `source_column` | The ABS column name exactly as in the DataPack CSV |
| `variable_label` | ABS's long description (or the column name, if the metadata couldn't be read) |
| `topic` | `population`, `birthplace`, `language` or `proficiency` |
| `sex` | `F` (females) or `P` (persons, all sexes) |
| `age_label` | The Census age band, e.g. `25-44`. `NULL` means all ages. **Deliberately not linked to `lookup_age_group`**: Census age bands differ from AIHW's |
| `standard_name` | **Our plain-English name for what the column counts, the same in every year.** Views calculate from this, never from `source_column`. `NULL` only for the 20 G11 columns (sensitivity check, not used by any view) |

#### Why `standard_name` exists

ABS spells the same thing differently each Census. `standard_name` gives it one name:

| Census | `source_column` (ABS) | `standard_name` (ours) |
|---|---|---|
| 2011 | `SEO_Females` | `all_females_english_only` |
| 2016 | `FSEO_Tot` | `all_females_english_only` |
| 2021 | `FSEO_Tot` | `all_females_english_only` |
| 2016 | `F_Tot_SOLSE_NWorNAA` | `all_females_english_not_well` |
| 2021 | `F_Tot_UOLSE_NWorNAA` | `all_females_english_not_well` |

#### All standard names

| standard_name | Counts | Years |
|---|---|---|
| `women_25_74_total` | Women aged 25–74 | 2016, 2021 |
| `women_25_74_born_australia` | …of whom born in Australia | 2016, 2021 |
| `women_25_74_birthplace_not_stated` | …of whom didn't state their birthplace | 2016, 2021 |
| `all_females_birthplace_total` | All females, any age (birthplace table) | 2011, 2016, 2021 |
| `all_females_born_australia` | …of whom born in Australia | 2011, 2016, 2021 |
| `all_females_birthplace_not_stated` | …of whom didn't state their birthplace | 2011, 2016, 2021 |
| `all_females_english_only` | Females who speak only English at home | 2011, 2016, 2021 |
| `all_females_other_language` | Females who speak another language at home | 2011, 2016, 2021 |
| `all_females_language_not_stated` | Females who didn't state their language | 2016, 2021 |
| `all_females_english_well` | Other language, and English very well or well | 2016, 2021 |
| `all_females_english_not_well` | Other language, and English not well or not at all | 2016, 2021 |
| `all_females_english_not_stated` | Didn't state how well they speak English | 2016, 2021 |
| `all_females_language_total` | All females, any age (language table) | 2011, 2016, 2021 |

Women 25–74 names exist in 2016 too, but only 2021 is used for the participation analysis.

### `census_area_value`

The Census numbers: one row per SA3 per variable per year (**23,692 rows**: 2021 14,280; 2016 7,480; 2011 1,932). Values are **counts of people**, not percentages.

| Column | Meaning |
|---|---|
| `geo_code` | The SA3 area, linking to `lookup_geography` (the same codes as AIHW) |
| `variable_code` | Links to `lookup_census_variable` |
| `census_year` | 2011, 2016 or 2021 |
| `value` | A count of people |

UNIQUE on `(geo_code, variable_code, census_year)`, so reloading updates rows instead of duplicating them.

### What was loaded, and why

| Year | ABS table | Who it covers | Used for |
|---|---|---|---|
| 2021 | **G09** Country of birth × age × sex | Women 25–74 (four bands 25–44, 45–54, 55–64, 65–74 = exactly 25–74), plus all-ages totals | Born-overseas share (heatmap and trend) |
| 2021 | **G13** Language × English proficiency × sex | Females, all ages | Other-language and low-proficiency shares |
| 2021 | **G11** Proficiency × year of arrival × age | Persons 25–74, probably overseas-born only | Sensitivity check only (no view uses it) |
| 2016 | **G09**, **G13** | As 2021 (G13 says "speaks" (`SOLSE`) where 2021 says "uses" (`UOLSE`)) | Trend |
| 2011 | **B09** Country of birth × sex | Females, **all ages** (no age split in 2011) | Trend |
| 2011 | **B13** Language spoken at home × sex | Females, all ages, **no proficiency** | Trend |

**Watch out: `Elsewhere` in G09 does NOT mean "born overseas".** It is the leftover group for countries not listed individually. Born overseas = **Total − Australia − Not stated**. The views do this correctly.

**Non-spatial Census areas are dropped** (codes ending `9797` "migratory/offshore" and `9999` "no usual address", two per state, 18 per year).

**2011 covers 322 of the 340 areas.** 18 areas were created or reorganised after 2011 (e.g. 10101 split into Goulburn – Mulwaree and Young – Yass; outback WA's 6 areas became 7; Norfolk Island joined in 2016). They are excluded from 2011, and the 11 old 2011-only codes are skipped automatically. 2016 and 2021 codes are identical (all 340).

## 6. Views

Four saved queries. **For the heatmap you only need `v_sa3_linked`; for change over time you only need `v_sa3_census_trend`.**

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

### `v_sa3_census_measures`: Census side, 2021 only

Census counts turned into **percentages**, so big and small areas can be compared. One row per area (340 rows). **2021 Census only.**

| Column | Meaning | Who it covers |
|---|---|---|
| `women_25_74` | Women aged 25–74 counted in the Census | Women 25–74 |
| `females_all_ages` | All females counted | Females, all ages |
| `pct_born_overseas` | % born outside Australia | Women 25–74 |
| `pct_other_language` | % speaking a language other than English at home | Females, all ages |
| `pct_low_proficiency` | % speaking English "not well" or "not at all" | Females, all ages |
| `pct_birthplace_ns` | % who didn't state their birthplace: **a quality flag** | Women 25–74 |

All percentages use **"stated" denominators**: people who didn't answer are removed from both the top and bottom of the fraction, so non-response doesn't drag shares down.

### `v_sa3_linked`: the link (heatmap)

Both sides joined on `geo_code`: **one row per area per AIHW window** (1,020 rows), with participation next to the 2021 Census percentages. Contains all columns from the two views above, plus:

| Column | Meaning |
|---|---|
| `pop_ratio` | AIHW eligible women ÷ Census women 25–74. **A quality check, not a finding.** All areas fall between 0.80 and 1.05, which confirmed AIHW and Census describe the same areas |

The Census values are **identical across an area's three rows** (one Census), while participation changes by window.

### `v_sa3_census_trend`: change over time

**One row per area per Census year** (2011, 2016, 2021), for **females of all ages**, the only definition all three Censuses support. **Not linked to participation, by design.**

| Column | Meaning | Years available |
|---|---|---|
| `geo_code`, `geo_name` | The area | |
| `census_year` | 2011, 2016 or 2021 | |
| `females_all_ages` | All females counted | All three |
| `pct_born_overseas` | % born outside Australia (females, all ages) | All three |
| `pct_other_language` | % speaking another language at home | All three |
| `pct_low_proficiency` | % speaking English not well or not at all | **2016, 2021 only** (`NULL` for 2011) |

Note: `pct_born_overseas` here covers **all ages**, so it differs from the heatmap's 25–74 measure. Don't mix the two.

## 7. Using the data for the heatmap

### What the analysis is

A **cross-sectional, area-level** comparison: each SA3 is one data point, with its participation rate and its 2021 Census profile. The question is: *do areas with a higher share of X tend to have higher or lower participation?* It is not a time series: one Census (2021) is compared across places, and 2021 falls inside every AIHW window.

### Getting the analysis-ready data

Use `link_query.sql`. It returns one row per SA3 for the latest window, with the standard exclusions applied (337 rows):

```sql
SELECT geo_code, geo_name, rate_pct, eligible_pop,
       pct_born_overseas, pct_other_language, pct_low_proficiency
FROM v_sa3_linked
WHERE year_start = 2020
  AND NOT is_suppressed
  AND NOT over_100
ORDER BY geo_code;
```

It doesn't drop tiny areas: that rule is applied in Python, so results can be compared with and without it.

### Connecting from a notebook

```python
import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv("../scripts/.env")        # .env lives in scripts/, not above the notebook folder
assert os.getenv("DATABASE_URL"), "DATABASE_URL not found: check the path to .env"

# Name the driver explicitly: newer SQLAlchemy defaults to psycopg v3, this project uses psycopg2
url = os.getenv("DATABASE_URL").replace("postgres://", "postgresql://", 1)
engine = create_engine(url.replace("postgresql://", "postgresql+psycopg2://", 1))

query = Path("../scripts/link_query.sql").read_text()      # adjust to where link_query.sql lives
df = pd.read_sql(text(query), engine)
```

Three things in this snippet each fixed a real error:
- `load_dotenv("../scripts/.env")`: a plain `load_dotenv()` searches the notebook folder and the folders *above* it, never the sibling `scripts/` folder.
- `postgresql+psycopg2://`: without it, newer SQLAlchemy looks for a driver this project doesn't use.
- `text(query)`: stops the driver misreading `%` in `LIKE` patterns as parameters.

**Never print `DATABASE_URL`** in a notebook: it contains the password, and notebook outputs are saved into the `.ipynb` file.

The full analysis (heatmap, age control, sensitivity checks, scatters) is in `sa3_correlation_heatmap.py`, as notebook cells.

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
- **Age is a confounder.** AIHW SA3 rates are **crude, not age-standardised**, and participation varies strongly by age (ages 70–74 participate at about 50%). Control for it, e.g. with a partial correlation using the share of women aged 65–74 (`G09:F_Tot_65_74` ÷ `women_25_74`).
- **The three Census measures are not independent.** Born overseas, other language and low proficiency will correlate strongly with each other. Check this before presenting them as three separate findings.
- **Age-range mismatch.** Born overseas covers women 25–74 (an exact match to AIHW). The two language measures cover females **of all ages**. G11 (persons 25–74) exists as a sensitivity check.
- **Timing.** The Census is one night in August 2021; each AIHW window spans 5.5 years of tests. They overlap, but not perfectly.
- **p-values are optimistic.** Neighbouring SA3s resemble each other, so areas aren't fully independent. Lean on the size and stability of the correlation, not on p-values.
- **Structural proxies only.** AIHW does not publish participation by CALD status. These measures describe areas, not CALD women's own screening.

### Two kinds of heatmap

| Type | What it shows | Needs | Risk |
|---|---|---|---|
| **Matrix heatmap** | A grid, e.g. correlations of participation with each Census measure, across the three windows | Only this database | Low: names no areas |
| **Map (choropleth)** | SA3 areas coloured by participation or a Census measure | ABS SA3 boundary files (ASGS Edition 3, 2021, GDA2020), **not loaded**: keep them as a static GeoJSON file, not in the database | High: visually names places |

### What can be shown to users

Anything that **names or ranks an SA3 area** should be treated as **analyst-only** by default: it risks stigmatising communities and breaks our tone rules (no comparative shaming by area, barriers framed as structural). National-level, non-comparative messages are the candidates for user-facing content. Score every output against the project's suitability criteria before it goes into the app.

## 8. Using the data for change over time

`v_sa3_census_trend` describes **how areas' populations changed** between 2011, 2016 and 2021. It is context for the "hindsight" part of the analysis, **never** a partner for participation (see Rule 8).

```sql
SELECT geo_code, geo_name, census_year, pct_born_overseas, pct_other_language, pct_low_proficiency
FROM v_sa3_census_trend
ORDER BY geo_code, census_year;
```

**Things to know:**
- **All measures are females of all ages**, because 2011 has no age split. They are not comparable with the heatmap's women 25–74 measure.
- **2011 covers 322 areas.** Compare 2011 with other years on those 322; compare 2016 with 2021 on all 340.
- **Proficiency is 2016–2021 only.** The 2011 Census has no comparable table for all residents (its only proficiency table, B11, covers overseas-born people only).
- **In fast-growing areas, a change in share largely reflects who moved in**, not a change among long-term residents. 41 areas grew by more than 30% between 2011 and 2021 (e.g. Wyndham +77%, Rouse Hill – McGraths Hill +113%, Gungahlin +84%). Word findings accordingly.
- The same tone rules apply: area-level change can still stigmatise, so named-area results are analyst-only.

## 9. Checking the data is correct

Run these after any reload. All are read-only (`SELECT` only) and safe to run anywhere, including in the Neon SQL Editor, one block at a time.

### AIHW: `reconcile_db.sql`

| Check | Expected |
|---|---|
| National crude rates | 80.8 / 78.6 / 77.9% (5,562,882 / 5,485,448 / 5,513,616 screened) |
| Duplicate natural keys | No rows returned |
| SA3 shape | 340 areas, 33,660 rows, 909 suppressed, 3,060 rows for `ages_25-74_years` |
| SA3 suppression by window | 306 / 303 / 300 |

### Census: rows per year

```sql
SELECT census_year, COUNT(DISTINCT variable_code) AS vars, COUNT(*) AS rows, COUNT(DISTINCT geo_code) AS areas
FROM census_area_value GROUP BY 1 ORDER BY 1;
```
Expect 2011: 6 variables, 1,932 rows, 322 areas · 2016: 22, 7,480, 340 · 2021: 42, 14,280, 340.

### Census: standard names filled in

```sql
SELECT COUNT(*) FROM lookup_census_variable WHERE standard_name IS NULL;
```
Expect **20** (the G11 columns only). A higher number means a load ran with an old loader: re-run the loads.

### Census: trend view

```sql
SELECT census_year, COUNT(*) AS areas, COUNT(pct_born_overseas) AS with_birthplace,
       COUNT(pct_low_proficiency) AS with_proficiency
FROM v_sa3_census_trend GROUP BY 1 ORDER BY 1;
```
Expect 2011: 322 / 322 / 0 · 2016: 340 / 339 / 338 · 2021: 340 / 338 / 338.

### Link check

```sql
SELECT geo_code, geo_name, eligible_pop, women_25_74, pop_ratio
FROM v_sa3_linked
WHERE year_start = 2020 AND NOT is_suppressed
ORDER BY pop_ratio;
```
Expect every `pop_ratio` between about 0.80 and 1.05, and 337 rows from `link_query.sql`.

### Validated results (for reference)

- **2016 vs 2021 born-overseas share, Spearman = 0.992**: areas rank almost identically five years apart, confirming the standard-name mapping is correct.
- **Female population change 2011 → 2021:** 43 areas beyond ±30%. 41 are genuine growth areas (outer-suburban corridors, inner-city densification, coastal growth); the only 2 declines are near-empty reserves (Illawarra Catchment Reserve 8 → 0, Blue Mountains – South 4 → 0). No sign of boundary changes behind matching codes.

## 10. Building and re-running the pipeline

```
backend/data_pipeline/
├── scripts/
│   ├── .env                              # DATABASE_URL (never commit)
│   ├── AIHW_data_extraction.py           # AIHW Excel    → data/extracted/*.csv
│   ├── load_data_to_db.py                # AIHW CSVs     → database
│   ├── Census_data_extraction.py         # ABS DataPacks → data/extracted/census_<year>_sa3_long.csv
│   ├── load_census_data_to_db.py         # Census CSVs   → database
│   ├── schema.sql                        # full design, for FRESH databases only
│   ├── migrations/                       # step-by-step changes, for EXISTING databases
│   │   ├── 002_add_census.sql
│   │   ├── 003_census_measures.sql
│   │   └── 004_census_multi_year.sql
│   └── (queries) reconcile_db.sql, check_sa3_2574.sql, link_query.sql
├── EDA notebooks/
└── data/                                 # raw files are git-ignored
    ├── extracted/
    ├── 2011_BCP_SA3_for_AUST_short-header/
    ├── 2016_GCP_SA3_for_AUS_short-header/
    └── 2021_GCP_SA3_for_AUS_short-header/
```

Adjust paths if your files live elsewhere: none of the scripts read the `.sql` files; you paste those into Neon yourself.

### Which route applies to you

| Situation | Run |
|---|---|
| **Brand-new empty database** | `schema.sql` once (it already includes everything from 002, 003 and 004), then load all data below |
| **Existing database with 002 and 003 applied** | `004_census_multi_year.sql` once, then reload the Census |
| **Existing database with 004 applied** | Nothing: just reload data if needed |

**Never run `schema.sql` on an existing database** (it fails with "already exists"), and **never run a migration twice** (the error is harmless: it means it's already applied).

### AIHW data

```bash
cd backend/data_pipeline/scripts
python3 AIHW_data_extraction.py
python3 load_data_to_db.py           # safe to re-run: truncates and reloads the 4 AIHW fact tables
```

### Census data (from a notebook in `EDA notebooks`, prefix each line with `!`)

```bash
python ../scripts/Census_data_extraction.py extract --year 2021
python ../scripts/Census_data_extraction.py extract --year 2016
python ../scripts/Census_data_extraction.py extract --year 2011

python ../scripts/load_census_data_to_db.py load
python ../scripts/load_census_data_to_db.py load --csv ../data/extracted/census_2016_sa3_long.csv
python ../scripts/load_census_data_to_db.py load --csv ../data/extracted/census_2011_sa3_long.csv
```

| Year | Extraction | Load |
|---|---|---|
| 2021 | `Saved 14,280 rows (42 variables x 340 areas)` | `Matched: 340`, `In AIHW only: 0`, `Loaded 42 variables and 14,280 values` |
| 2016 | `Saved 7,480 rows (22 variables x 340 areas)` | `Matched: 340`, `In AIHW only: 0`, `Loaded 22 variables and 7,480 values` |
| 2011 | `Saved 1,998 rows (6 variables x 333 areas)` | `Matched: 322`, `In AIHW only: 18`, `Loaded 6 variables and 1,932 values` |

Loads are **safe to re-run**: they update rows instead of duplicating them.

Other commands: `Census_data_extraction.py find "not stated"` searches ABS column names in the metadata; `load_census_data_to_db.py check --csv <file>` compares SA3 codes without writing anything.

**Adding a future Census (e.g. 2026):** add a `2026` entry to `YEARS` in `Census_data_extraction.py`, mapping its column names to the existing standard names. The `census_year` CHECK already allows 2026, and all views work without changes.

**Always experiment on a Neon branch,** not the main database.

## 11. Things that look like bugs but aren't

**Values showing as `31.0` instead of `31`.** `value` columns are `NUMERIC` because some metrics are fractional. Postgres shows whole numbers stored this way with `.0`. Round in the query (`ROUND(value)::INTEGER`) or format in the frontend.

**Some SA3 areas have `NULL` participation.** AIHW withheld them for privacy (3 areas). Check `is_suppressed`; never treat these as zero.

**Some Census percentages are `NULL`.** Near-unpopulated areas (e.g. Illawarra Catchment Reserve, Blue Mountains – South) have zero females, so their shares are blank rather than divided by zero. That's why the trend view shows 338 or 339 areas with values instead of 340.

**`In AIHW only: 18` when loading 2011.** Expected: the 18 areas created after 2011. The 11 `In Census only` codes are old 2011 areas that no longer exist; they are skipped automatically.

**"(no long labels ...) using column names as labels" during extraction.** The metadata Excel couldn't be read for that year. Harmless: only the `variable_label` text is affected.

**`pop_ratio` is mostly below 1.** AIHW's population excludes women who have had a hysterectomy (more common at older ages), so older areas show lower ratios (about 0.80). Young or fast-growing areas (e.g. Melbourne City, NT) can exceed 1 because AIHW averages the population over several years.

**Census parts don't add up exactly to totals.** ABS makes small random adjustments to every cell to protect confidentiality, so G13's parts sum to between 0.97 and 1.01 of the total.

**`DATABASE_URL` is `None` in a notebook** (`'NoneType' object has no attribute 'replace'`). Use `load_dotenv("../scripts/.env")`: see section 7.

**"Skipped 1 unmapped age group(s)" during the AIHW load.** This used to appear before the `25–74` fix. **It should no longer appear.** If you see it, the fix in `load_sa_participation_csv` is missing (check for the en dash `–` in `"25–74"`).

## 12. Known limitations

- AIHW does not publish participation by CALD status; Census measures are area-level structural proxies only.
- In the heatmap, language and proficiency measures cover females of all ages, not just 25–74.
- G11's population is probably overseas-born people only (confirm in the DataPack metadata).
- SA3 participation rates are crude, not age-standardised.
- Census (August 2021) and AIHW windows (2018–2025 tests) overlap but don't match exactly.
- `response_to_invitation` has no suppression flag.
- SA3 codes match between AIHW and Census 2016/2021 (340/340), and population checks are consistent, but identical boundaries are not formally proven.
- 18 SA3 areas created after 2011 (mostly regional, including outback WA) are excluded from comparisons involving 2011, slightly under-representing regional Australia.
- Comparisons across Census years use females of all ages, because the 2011 Census does not split birthplace by age at SA3 level.
- English proficiency is compared for 2016–2021 only; the 2011 Census has no comparable table for all residents.
- Census years are used to describe population change only; they are not linked to screening participation.

## 13. Attribution

Any output using this data must credit both sources:

- *Based on Australian Institute of Health and Welfare material.*
- *Based on Australian Bureau of Statistics data* (because we derive percentages, rather than reproducing ABS figures unchanged).
