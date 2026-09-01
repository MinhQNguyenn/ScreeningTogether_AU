# ScreeningTogether AU — Database Documentation

This document explains what's in the database, where it came from, and how to query it. Read this before writing any query against the data.

## Source

All data comes from the **AIHW National Cervical Screening Program monitoring report 2025**, two workbooks:
- `AIHW_CAN166_recruitment_data_tables.xlsx` — participation, screening volume, response to invitation
- `AIHW_CAN166_outcomes_data_tables.xlsx` — cervical cancer incidence and mortality

These are official government-published statistics, not scraped or estimated data. Extraction code lives in `backend/data_pipeline/scripts/AIHW_data_extraction.py`; the loading code lives in `load_data_to_db.py`.

## Schema shape

Five **lookup tables** hold shared reference data, referenced by four **fact tables** holding the actual numbers.

**Lookup tables:**
- `lookup_report_table` — one row per source AIHW table (e.g. `S1.2a`), with a description and which file it came from
- `lookup_geography` — states, SA3 areas, and socioeconomic quintiles, tagged by `geo_level`
- `lookup_age_group` — age brackets, in their natural order
- `lookup_metric` — the different kinds of numbers reported (counts, rates, population)
- `lookup_letter_type` — invitation letter categories (A1, B1, C1, D1)

**Fact tables:**
- `screening_participation` — the main table, powers the app's year/state filters
- `response_to_invitation` — response rates to screening invitations
- `monthly_test_volume` — HPV test counts by month
- `cancer_outcomes` — cervical cancer incidence and mortality (background/citation data, not used by the app directly)

## Table-by-table

### `screening_participation`

Participation counts, percentages, and populations, broken down by age group and one of three geography levels (state, SA3, or socioeconomic quintile).

| Column | Meaning |
|---|---|
| `geo_code` | Links to `lookup_geography` — could be a state, SA3 area, or socioeconomic quintile |
| `metric_code` | `number`, `per_cent`, or `population` |
| `year_start` / `year_end` | The reporting window (see "Understanding the year windows" below) |
| `is_suppressed` | `true` if AIHW withheld this value for privacy (small counts). When true, `value` is `NULL` |

**Sources loaded:** S1.2 (state), S1.4 (socioeconomic), S1.8 (SA3) — all three reporting windows each.

**Not loaded:** S1.7 (SA2). SA2 was dropped deliberately — it has a much higher suppression rate (~15%) than SA3 (~3%), and SA3 areas are simply an aggregation of SA2 areas, so no independent information is lost by skipping it. The extraction code for S1.7 still exists if a future iteration needs it.

**Example query — participation trend for one area across all three windows:**
```sql
SELECT g.geo_name, a.age_label, f.year_start, f.year_end, f.value
FROM screening_participation f
JOIN lookup_geography g ON f.geo_code = g.geo_code
JOIN lookup_age_group a ON f.age_code = a.age_code
WHERE g.geo_name = 'NSW' AND a.age_code = '35-39' AND f.metric_code = 'number'
ORDER BY f.year_start;
```

### `response_to_invitation`

How many people were invited to screen, and how many responded, broken down by age, state, or letter type (never more than one breakdown at a time).

| Column | Meaning |
|---|---|
| `age_code` | Always set. If the row is broken down by state or letter type instead of age, this is `all_ages` |
| `geo_code` | Only set for state-level rows (from S2.2). `NULL` otherwise |
| `letter_type_code` | Only set for letter-type rows (from S2.3). `NULL` otherwise |
| `year` | A real, individual year (2019–2024) — not a window |
| `metric_code` | `invited`, `responded`, or `crude_rate` |

**Sources loaded:** S2.1 (by age), S2.2 (by state), S2.3 (by letter type).

**Known limitation:** this table doesn't have an `is_suppressed` flag. Suppressed values (`n.p.` in the source) are silently skipped during loading rather than flagged — a small number of small-count rows are simply missing, not marked as missing.

**Example query — NSW's response metrics for one year:**
```sql
SELECT r.metric_code, r.value
FROM response_to_invitation r
JOIN lookup_geography g ON r.geo_code = g.geo_code
WHERE g.geo_name = 'NSW' AND r.year = 2019;
```

### `monthly_test_volume`

Number of HPV tests performed each month, nationally (no geography breakdown at all).

| Column | Meaning |
|---|---|
| `year` / `month` | A real calendar month |
| `test_type` | `hpv_test` (all tests) or `self_collected` (self-collection only) |

**Sources loaded:** S1.5 (all HPV tests) and S1.6 (self-collected only), every available year 2018–2025.

**Note on 2025:** this is a partial year — only January–June data exists, since the source report was published mid-2025.

**Example query — monthly trend for one year:**
```sql
SELECT month, value FROM monthly_test_volume
WHERE table_code = 'S1.5a' AND age_code = '25-29'
ORDER BY month;
```
(`table_code` follows the pattern `S1.5a` = 2018, `S1.5b` = 2019, ... `S1.5h` = 2025.)

### `cancer_outcomes`

Cervical cancer incidence (new cases) and mortality (deaths), by age group and geography.

**This table is background/citation evidence only — it doesn't power any current app feature.** It exists to support written claims in the project proposal (e.g. survival statistics), not to drive a UI.

| Column | Meaning |
|---|---|
| `year` | For S19.1/S20.1, this is a real individual year. For the geography-broken-down tables (S19.5/S19.7/S20.3/S20.5), this is the **end year of a 5-year reporting window** — see note below |
| `metric_code` | `new_cases`, `new_cases_per_100k`, `deaths`, or `deaths_per_100k` |

**Important:** unlike `screening_participation`, this table only has a single `year` column, not `year_start`/`year_end`. For S19.5 (2017–2021 window) and S20.3 (2019–2023 window), the stored `year` is the **window's end year**, used as an approximation — it does not mean the value is specific to that one year. Check `lookup_report_table.description` for the real window a given `table_code` covers.

**Sources loaded:** S19.1, S19.5, S19.7 (incidence); S20.1, S20.3, S20.5 (mortality). This does **not** include Indigenous-status breakdowns (S19.4, S20.2) — excluded per the project's no-go constraints.

**Example query — national incidence trend:**
```sql
SELECT year, value FROM cancer_outcomes
WHERE table_code = 'S19.1' AND geo_code = 'Australia'
ORDER BY year DESC;
```

## Things that look like bugs but aren't

**Values showing as `31.0` instead of `31`.** This is normal — `value` columns are `NUMERIC` type because some metrics are genuinely fractional (rates like `crude_rate`). Postgres displays whole numbers stored this way with a trailing `.0`. It doesn't affect any calculation, filter, or join. Round it in your query (`ROUND(value)::INTEGER`) or handle formatting in the frontend if you want a cleaner display.

**"Skipped 1 unmapped age group(s)" warnings during loading.** Expected — this is the small-area summary row (labeled `25–74` in the source, differently from every other table's `Ages 25–74 years`) being correctly skipped, not a real age group. Safe to ignore.

**Some geography rows are missing from small-area tables.** Small SA3 areas sometimes have their counts withheld by AIHW for privacy when the underlying number is very small. Check `is_suppressed` before assuming a missing value means zero participation.

## Re-running the pipeline

If AIHW publishes a new report edition, or you need to reload the data:

```bash
cd backend/data_pipeline/scripts
python3 AIHW_data_extraction.py   # re-extracts everything from the raw Excel files
python3 load_schema.py            # only needed if the schema itself changed
python3 load_data_to_db.py        # safe to re-run — clears and reloads fact tables automatically
```

`load_data_to_db.py` truncates all four fact tables before reloading, so re-running it never creates duplicates. Lookup tables use `ON CONFLICT DO NOTHING`, so they're also safe to reload repeatedly.