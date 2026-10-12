-- ScreeningTogether AU — Database Schema
-- 6 lookup tables, 5 fact tables, 4 views
-- Target: Neon Postgres

-- Lookup tables

CREATE TABLE lookup_report_table (
    table_code          VARCHAR(20) PRIMARY KEY,
    description          TEXT NOT NULL,
    indicator_category   VARCHAR(50) NOT NULL,
    source_file          VARCHAR(255) NOT NULL
);

CREATE TABLE lookup_geography (
    geo_code    VARCHAR(20) PRIMARY KEY,
    geo_name    VARCHAR(100) NOT NULL,
    geo_level   VARCHAR(20) NOT NULL
);

CREATE TABLE lookup_age_group (
    age_code    VARCHAR(20) PRIMARY KEY,
    age_label   VARCHAR(20) NOT NULL,
    sort_order  INTEGER NOT NULL
);

CREATE TABLE lookup_metric (
    metric_code   VARCHAR(50) PRIMARY KEY,
    metric_label  VARCHAR(100) NOT NULL,
    category      VARCHAR(30) NOT NULL
);

CREATE TABLE lookup_letter_type (
    letter_type_code   VARCHAR(20) PRIMARY KEY,
    letter_type_label  VARCHAR(50) NOT NULL
);

-- Fact tables

CREATE TABLE screening_participation (
    participation_id  SERIAL PRIMARY KEY,
    table_code         VARCHAR(20) NOT NULL REFERENCES lookup_report_table(table_code),
    geo_code           VARCHAR(20) NOT NULL REFERENCES lookup_geography(geo_code),
    age_code           VARCHAR(20) NOT NULL REFERENCES lookup_age_group(age_code),
    metric_code        VARCHAR(50) NOT NULL REFERENCES lookup_metric(metric_code),
    year_start         INTEGER NOT NULL,
    year_end           INTEGER NOT NULL,
    value              NUMERIC,
    is_suppressed      BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE cancer_outcomes (
    outcome_id   SERIAL PRIMARY KEY,
    table_code   VARCHAR(20) NOT NULL REFERENCES lookup_report_table(table_code),
    geo_code     VARCHAR(20) NOT NULL REFERENCES lookup_geography(geo_code),
    age_code     VARCHAR(20) NOT NULL REFERENCES lookup_age_group(age_code),
    metric_code  VARCHAR(50) NOT NULL REFERENCES lookup_metric(metric_code),
    year         INTEGER NOT NULL,
    value        NUMERIC
);

CREATE TABLE monthly_test_volume (
    volume_id   SERIAL PRIMARY KEY,
    table_code  VARCHAR(20) NOT NULL REFERENCES lookup_report_table(table_code),
    age_code    VARCHAR(20) NOT NULL REFERENCES lookup_age_group(age_code),
    year        INTEGER NOT NULL,
    month       INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    test_type   VARCHAR(30) NOT NULL,
    value       NUMERIC
);

CREATE TABLE response_to_invitation (
    response_id        SERIAL PRIMARY KEY,
    table_code          VARCHAR(20) NOT NULL REFERENCES lookup_report_table(table_code),
    age_code             VARCHAR(20) NOT NULL REFERENCES lookup_age_group(age_code),
    geo_code             VARCHAR(20) REFERENCES lookup_geography(geo_code),
    letter_type_code     VARCHAR(20) REFERENCES lookup_letter_type(letter_type_code),
    year                 INTEGER NOT NULL,
    metric_code          VARCHAR(50) NOT NULL REFERENCES lookup_metric(metric_code),
    value                NUMERIC
);

-- Census tables (ABS 2011, 2016,2021, SA3)
CREATE TABLE lookup_census_variable (
    variable_code   VARCHAR(120) PRIMARY KEY,
    table_code      VARCHAR(20)  NOT NULL REFERENCES lookup_report_table(table_code),
    source_column   VARCHAR(100) NOT NULL,          -- ABS short header, as in the CSV
    variable_label  TEXT         NOT NULL,          -- ABS long descriptor
    topic           VARCHAR(30)  NOT NULL,          -- population / language / proficiency / birthplace
    sex             CHAR(1)      NOT NULL CHECK (sex IN ('F', 'M', 'P')),
    age_label       VARCHAR(30),                     -- Census's own age band, e.g. '25-34'; NULL = all ages.
                                                    -- Deliberately NOT a FK to lookup_age_group:
                                                    -- Census bands don't match AIHW's 5-year bands.
    standard_name   VARCHAR(40)                     -- our plain-English name for what is counted, same every year
);

CREATE TABLE census_area_value (
    census_value_id  SERIAL PRIMARY KEY,
    geo_code         VARCHAR(20)  NOT NULL REFERENCES lookup_geography(geo_code),
    variable_code    VARCHAR(120) NOT NULL REFERENCES lookup_census_variable(variable_code),
    census_year      INTEGER      NOT NULL CHECK (census_year IN (2011, 2016, 2021, 2026)),
    value            NUMERIC      NOT NULL CHECK (value >= 0),
    UNIQUE (geo_code, variable_code, census_year)
);

-- Views (calculated on read; store no data)
CREATE VIEW v_sa3_participation_2574 AS
SELECT
    p.geo_code,
    g.geo_name,
    p.year_start,
    p.year_end,
    MAX(p.value) FILTER (WHERE p.metric_code = 'number')      AS screened,
    MAX(p.value) FILTER (WHERE p.metric_code = 'population')  AS eligible_pop,
    -- AIHW's published per cent, not number/population: SA3 populations are
    -- published rounded to whole people, so recomputing drifts in tiny areas.
    ROUND(MAX(p.value) FILTER (WHERE p.metric_code = 'per_cent'), 1) AS rate_pct,
    BOOL_OR(p.is_suppressed)                                    AS is_suppressed,
    COALESCE(MAX(p.value) FILTER (WHERE p.metric_code = 'per_cent') > 100, FALSE) AS over_100
FROM screening_participation p
JOIN lookup_geography g ON g.geo_code = p.geo_code
WHERE p.table_code LIKE 'S1.8%'
  AND p.age_code = 'ages_25-74_years'
  AND g.geo_level = 'sa3'
GROUP BY p.geo_code, g.geo_name, p.year_start, p.year_end;
 

CREATE VIEW v_sa3_census_measures AS
WITH c AS (
    SELECT c.geo_code,
           SUM(c.value) FILTER (WHERE v.standard_name = 'women_25_74_total')                 AS women_25_74,
           SUM(c.value) FILTER (WHERE v.standard_name = 'women_25_74_born_australia')        AS born_australia,
           SUM(c.value) FILTER (WHERE v.standard_name = 'women_25_74_birthplace_not_stated') AS birthplace_ns,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_english_only')          AS english_only,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_other_language')        AS other_language,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_english_well')          AS eng_well,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_english_not_well')      AS eng_not_well,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_language_total')        AS females_all_ages
    FROM census_area_value c
    JOIN lookup_census_variable v USING (variable_code)
    WHERE c.census_year = 2021
    GROUP BY c.geo_code
)
SELECT geo_code,
       women_25_74,
       females_all_ages,
       ROUND(100 * (women_25_74 - born_australia - birthplace_ns)
                 / NULLIF(women_25_74 - birthplace_ns, 0), 1)                    AS pct_born_overseas,
       ROUND(100 * other_language / NULLIF(english_only + other_language, 0), 1) AS pct_other_language,
       ROUND(100 * eng_not_well
                 / NULLIF(english_only + eng_well + eng_not_well, 0), 1)          AS pct_low_proficiency,
       ROUND(100 * birthplace_ns / NULLIF(women_25_74, 0), 1)                     AS pct_birthplace_ns
FROM c;

-- Change over time. One row per SA3 per Census year, FEMALES OF ALL AGES
--    (the only definition 2011 supports). Not linked to participation, by design.
--    pct_low_proficiency is NULL for 2011: the 2011 Census has no comparable table.
CREATE VIEW v_sa3_census_trend AS
WITH c AS (
    SELECT c.geo_code, c.census_year,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_birthplace_total')      AS birth_total,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_born_australia')        AS born_australia,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_birthplace_not_stated') AS birthplace_ns,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_english_only')          AS english_only,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_other_language')        AS other_language,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_english_well')          AS eng_well,
           MAX(c.value) FILTER (WHERE v.standard_name = 'all_females_english_not_well')      AS eng_not_well
    FROM census_area_value c
    JOIN lookup_census_variable v USING (variable_code)
    GROUP BY c.geo_code, c.census_year
)
SELECT c.geo_code, g.geo_name, c.census_year,
       c.birth_total AS females_all_ages,
       ROUND(100 * (birth_total - born_australia - birthplace_ns)
                 / NULLIF(birth_total - birthplace_ns, 0), 1)                    AS pct_born_overseas,
       ROUND(100 * other_language / NULLIF(english_only + other_language, 0), 1) AS pct_other_language,
       ROUND(100 * eng_not_well
                 / NULLIF(english_only + eng_well + eng_not_well, 0), 1)          AS pct_low_proficiency
FROM c
JOIN lookup_geography g USING (geo_code);


CREATE VIEW v_sa3_linked AS
SELECT p.geo_code, p.geo_name, p.year_start, p.year_end,
       p.screened, p.eligible_pop, p.rate_pct, p.is_suppressed, p.over_100,
       m.women_25_74,
       ROUND(p.eligible_pop / NULLIF(m.women_25_74, 0), 2) AS pop_ratio,   -- validation: AIHW vs Census
       m.pct_born_overseas, m.pct_other_language, m.pct_low_proficiency, m.pct_birthplace_ns
FROM v_sa3_participation_2574 p
JOIN v_sa3_census_measures m USING (geo_code);


-- Indexes
CREATE INDEX idx_participation_geo ON screening_participation(geo_code);
CREATE INDEX idx_participation_year ON screening_participation(year_start, year_end);
CREATE INDEX idx_outcomes_geo ON cancer_outcomes(geo_code);
CREATE INDEX idx_outcomes_year ON cancer_outcomes(year);
CREATE INDEX idx_monthly_year_month ON monthly_test_volume(year, month);
CREATE INDEX idx_response_year ON response_to_invitation(year);

