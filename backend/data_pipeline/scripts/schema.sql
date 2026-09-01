-- ScreeningTogether AU — Database Schema
-- 5 dimension tables, 4 fact tables
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

-- Indexes

CREATE INDEX idx_participation_geo ON screening_participation(geo_code);
CREATE INDEX idx_participation_year ON screening_participation(year_start, year_end);
CREATE INDEX idx_outcomes_geo ON cancer_outcomes(geo_code);
CREATE INDEX idx_outcomes_year ON cancer_outcomes(year);
CREATE INDEX idx_monthly_year_month ON monthly_test_volume(year, month);
CREATE INDEX idx_response_year ON response_to_invitation(year);