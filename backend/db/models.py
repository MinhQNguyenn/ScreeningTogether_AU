"""
SQLAlchemy models mirroring backend/data_pipeline/scripts/schema.sql.

This describes the schema for querying purposes, but it does not create the
tables. Any changes in schema.sql must be updated here as well.
"""

from sqlalchemy import ForeignKey
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


# --- Lookup tables ---


class ReportTable(Base):
    __tablename__ = "lookup_report_table"

    table_code: Mapped[str] = mapped_column(primary_key=True)
    description: Mapped[str]
    indicator_category: Mapped[str]
    source_file: Mapped[str]


class Geography(Base):
    __tablename__ = "lookup_geography"

    geo_code: Mapped[str] = mapped_column(primary_key=True)
    geo_name: Mapped[str]
    geo_level: Mapped[str]


class AgeGroup(Base):
    __tablename__ = "lookup_age_group"

    age_code: Mapped[str] = mapped_column(primary_key=True)
    age_label: Mapped[str]
    sort_order: Mapped[int]


class Metric(Base):
    __tablename__ = "lookup_metric"

    metric_code: Mapped[str] = mapped_column(primary_key=True)
    metric_label: Mapped[str]
    category: Mapped[str]


class LetterType(Base):
    __tablename__ = "lookup_letter_type"

    letter_type_code: Mapped[str] = mapped_column(primary_key=True)
    letter_type_label: Mapped[str]


# --- Fact tables ---


class ScreeningParticipation(Base):
    __tablename__ = "screening_participation"

    participation_id: Mapped[int] = mapped_column(primary_key=True)
    table_code: Mapped[str] = mapped_column(ForeignKey("lookup_report_table.table_code"))
    geo_code: Mapped[str] = mapped_column(ForeignKey("lookup_geography.geo_code"))
    age_code: Mapped[str] = mapped_column(ForeignKey("lookup_age_group.age_code"))
    metric_code: Mapped[str] = mapped_column(ForeignKey("lookup_metric.metric_code"))
    year_start: Mapped[int]
    year_end: Mapped[int]
    value: Mapped[float | None]
    is_suppressed: Mapped[bool] = mapped_column(default=False)


class CancerOutcome(Base):
    __tablename__ = "cancer_outcomes"

    outcome_id: Mapped[int] = mapped_column(primary_key=True)
    table_code: Mapped[str] = mapped_column(ForeignKey("lookup_report_table.table_code"))
    geo_code: Mapped[str] = mapped_column(ForeignKey("lookup_geography.geo_code"))
    age_code: Mapped[str] = mapped_column(ForeignKey("lookup_age_group.age_code"))
    metric_code: Mapped[str] = mapped_column(ForeignKey("lookup_metric.metric_code"))
    year: Mapped[int]
    value: Mapped[float | None]


class MonthlyTestVolume(Base):
    __tablename__ = "monthly_test_volume"

    volume_id: Mapped[int] = mapped_column(primary_key=True)
    table_code: Mapped[str] = mapped_column(ForeignKey("lookup_report_table.table_code"))
    age_code: Mapped[str] = mapped_column(ForeignKey("lookup_age_group.age_code"))
    year: Mapped[int]
    month: Mapped[int]
    test_type: Mapped[str]
    value: Mapped[float | None]


class ResponseToInvitation(Base):
    __tablename__ = "response_to_invitation"

    response_id: Mapped[int] = mapped_column(primary_key=True)
    table_code: Mapped[str] = mapped_column(ForeignKey("lookup_report_table.table_code"))
    age_code: Mapped[str] = mapped_column(ForeignKey("lookup_age_group.age_code"))
    geo_code: Mapped[str | None] = mapped_column(ForeignKey("lookup_geography.geo_code"))
    letter_type_code: Mapped[str | None] = mapped_column(ForeignKey("lookup_letter_type.letter_type_code"))
    year: Mapped[int]
    metric_code: Mapped[str] = mapped_column(ForeignKey("lookup_metric.metric_code"))
    value: Mapped[float | None]
