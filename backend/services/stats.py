"""
Screening statistics derived from the AIHW data in Postgres.

Reads screening_participation (see backend/data_pipeline/DATASET_README.md).
Only the state-level tables (table_code S1.2x) are used here.
"""

from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from db.models import Geography, MonthlyTestVolume, ScreeningParticipation
from schemas import (
    AgeParticipationPoint, AgeParticipationResponse,
    ParticipationGraphPoint, ParticipationGraphResponse, ParticipationPercentageResponse,
    SelfCollectionMonth, SelfCollectionResponse, SelfCollectionYear,
    SocioeconomicPoint, SocioeconomicResponse,
)
from db.session import SessionLocal

STATE_TABLE_PREFIX = "S1.2%"
# geo_codes with geo_level='state': Australia, NSW, Vic, Qld, WA, SA, Tas, ACT, NT.
# "Australia" is the national total; the frontend sends the geo_code directly.
NATIONAL_GEO_CODE = "Australia"
AGE_TOTAL_CODE = "ages_25-74_years"


def participation_percentage() -> ParticipationPercentageResponse:
    """
    national participation across all states for the 25-74 age total, 
    from the most recent reporting window.
    """
    with SessionLocal() as session:
        points = _participation_totals(session, NATIONAL_GEO_CODE)

    if not points:
        raise HTTPException(status_code=404, detail="No participation data available")

    # _participation_totals is ordered oldest first, and a graph point already
    # has every field this response needs.
    return ParticipationPercentageResponse(**points[-1].model_dump())


def participation_graph(state: str) -> ParticipationGraphResponse:
    """
    Participation % for the 25-74 age total, one point per reporting window
    (oldest first), for the given state or all of Australia.
    """
    with SessionLocal() as session:
        geo_code = _resolve_geo_code(session, state)
        points = _participation_totals(session, geo_code)

    return ParticipationGraphResponse(state=geo_code, points=points)


def _participation_totals(session: Session, geo_code: str) -> list[ParticipationGraphPoint]:
    """
    Derived 25-74 participation % (number / population * 100) for one geography,
    one point per reporting window, ordered oldest first.
    """
    SP = ScreeningParticipation
    rows = session.execute(
        select(
            SP.year_start,
            SP.year_end,
            func.sum(SP.value).filter(SP.metric_code == "number").label("number"),
            func.sum(SP.value).filter(SP.metric_code == "population").label("population"),
        )
        .where(SP.geo_code == geo_code, SP.age_code == AGE_TOTAL_CODE, SP.table_code.like(STATE_TABLE_PREFIX))
        .group_by(SP.year_start, SP.year_end)
        # oldest window first, so points/labels are already left-to-right for the chart
        .order_by(SP.year_start, SP.year_end)
    ).all()

    return [
        ParticipationGraphPoint(
            year_start=r.year_start,
            year_end=r.year_end,
            percent=round(float(r.number) / float(r.population) * 100, 1),
            label=f"{r.year_start}-{r.year_end}",
        )
        for r in rows
        if r.number and r.population
    ]


def _resolve_geo_code(session: Session, state: str) -> str:
    """
    Validate the state filter against lookup_geography, or 404 if it isn't a known state.
    """
    geo_code = session.execute(
        select(Geography.geo_code).where(
            Geography.geo_level == "state",
            func.lower(Geography.geo_code) == state.strip().lower(),
        )
    ).scalar_one_or_none()

    if geo_code is None:
        raise HTTPException(status_code=404, detail=f"Unknown state: {state!r}")
    return geo_code


AGE_GROUPS = ["25-29", "30-34", "35-39", "40-44", "45-49",
              "50-54", "55-59", "60-64", "65-69", "70-74"]
SES_TABLE_PREFIX = "S1.4%"          # participation by socioeconomic area (national only)
QUINTILES = ["1", "2", "3", "4", "5"]  # 1 = most disadvantaged, 5 = least


def participation_by_age(state: str, window: str | None = None) -> AgeParticipationResponse:
    """
    Participation % for each 5-year age group (25-29 ... 70-74) in one reporting window,
    for one state or all of Australia. window looks like "2020-2024"; default = latest.
    """
    with SessionLocal() as session:
        geo_code = _resolve_geo_code(session, state)
        windows = _available_windows(session, STATE_TABLE_PREFIX)
        year_start, year_end = _pick_window(windows, window)

        SP = ScreeningParticipation
        rows = session.execute(
            select(
                SP.age_code,
                func.sum(SP.value).filter(SP.metric_code == "number").label("number"),
                func.sum(SP.value).filter(SP.metric_code == "population").label("population"),
            )
            .where(SP.table_code.like(STATE_TABLE_PREFIX), SP.geo_code == geo_code,
                   SP.age_code.in_(AGE_GROUPS),
                   SP.year_start == year_start, SP.year_end == year_end)
            .group_by(SP.age_code)
            .order_by(SP.age_code)          # '25-29' < '30-34' < ... sorts correctly as text
        ).all()

    points = [
        AgeParticipationPoint(
            age_group=r.age_code.replace("-", "–"),
            percent=round(float(r.number) / float(r.population) * 100, 1),
            number=int(r.number),
            population=round(float(r.population)),
        )
        for r in rows
        if r.number and r.population
    ]
    if not points:
        raise HTTPException(status_code=404, detail="No age data for this state and window")

    highest = max(points, key=lambda p: p.percent)
    lowest = min(points, key=lambda p: p.percent)
    return AgeParticipationResponse(
        state=geo_code,
        window=f"{year_start}-{year_end}",
        windows=[f"{s}-{e}" for s, e in windows],
        points=points,
        highest_age_group=highest.age_group, highest_percent=highest.percent,
        lowest_age_group=lowest.age_group, lowest_percent=lowest.percent,
    )


def participation_by_socioeconomic(window: str | None = None) -> SocioeconomicResponse:
    """
    Participation % (ages 25-74) for the 5 socioeconomic groups, national only.

    The loader keeps only the age-group rows of S1.4 (number + per cent), not the
    25-74 'Crude rate' row, so the 25-74 rate is rebuilt:
        population of each age group = number / (per cent / 100), then add up.
    Checked against the AIHW workbook (2020-2024: 69.8 / 73.8 / 77.4 / 80.3 / 87.2).
    """
    with SessionLocal() as session:
        windows = _available_windows(session, SES_TABLE_PREFIX)
        year_start, year_end = _pick_window(windows, window)

        SP = ScreeningParticipation
        rows = session.execute(
            select(
                SP.geo_code, SP.age_code,
                func.sum(SP.value).filter(SP.metric_code == "number").label("number"),
                func.sum(SP.value).filter(SP.metric_code == "per_cent").label("per_cent"),
            )
            .where(SP.table_code.like(SES_TABLE_PREFIX), SP.geo_code.in_(QUINTILES),
                   SP.age_code.in_(AGE_GROUPS),
                   SP.year_start == year_start, SP.year_end == year_end)
            .group_by(SP.geo_code, SP.age_code)
        ).all()

    totals = {q: {"number": 0.0, "population": 0.0} for q in QUINTILES}
    for r in rows:
        if r.number and r.per_cent:
            totals[r.geo_code]["number"] += float(r.number)
            totals[r.geo_code]["population"] += float(r.number) / (float(r.per_cent) / 100)

    points = [
        SocioeconomicPoint(
            quintile=int(q),
            percent=round(t["number"] / t["population"] * 100, 1),
            number=int(t["number"]),
        )
        for q, t in totals.items()
        if t["population"] > 0
    ]
    if len(points) != 5:
        raise HTTPException(status_code=404, detail="Socioeconomic data incomplete for this window")

    return SocioeconomicResponse(window=f"{year_start}-{year_end}",
                                 windows=[f"{s}-{e}" for s, e in windows], points=points)


def self_collection() -> SelfCollectionResponse:
    """
    Self-collected HPV tests and all HPV tests (ages 25-74), by month and by year.
    A year with fewer than 12 months (2025 = Jan-Jun) is marked partial, so the
    chart can label it instead of showing it as a fall.
    Yearly totals match AIHW (e.g. 535,817 self-collected tests in 2024).
    """
    MTV = MonthlyTestVolume
    with SessionLocal() as session:
        rows = session.execute(
            select(
                MTV.year, MTV.month,
                func.sum(MTV.value).filter(MTV.test_type == "self_collected").label("self_collected"),
                func.sum(MTV.value).filter(MTV.test_type == "hpv_test").label("all_tests"),
            )
            .where(MTV.age_code == AGE_TOTAL_CODE)
            .group_by(MTV.year, MTV.month)
            .order_by(MTV.year, MTV.month)
        ).all()

    if not rows:
        raise HTTPException(status_code=404, detail="No test volume data available")

    months = [
        SelfCollectionMonth(
            year=r.year, month=r.month,
            self_collected=int(r.self_collected or 0), all_tests=int(r.all_tests or 0),
            self_collected_percent=round(float(r.self_collected or 0) / float(r.all_tests) * 100, 1)
            if r.all_tests else None,
        )
        for r in rows
    ]

    years = []
    for year in sorted({m.year for m in months}):
        in_year = [m for m in months if m.year == year]
        self_total = sum(m.self_collected for m in in_year)
        all_total = sum(m.all_tests for m in in_year)
        years.append(SelfCollectionYear(
            year=year,
            months_covered=len(in_year),
            partial_year=len(in_year) < 12,
            self_collected=self_total,
            all_tests=all_total,
            self_collected_percent=round(self_total / all_total * 100, 1) if all_total else None,
        ))

    latest_full = [y for y in years if not y.partial_year][-1]
    return SelfCollectionResponse(months=months, years=years, latest_full_year=latest_full.year)


def _available_windows(session: Session, table_prefix: str) -> list[tuple[int, int]]:
    """All reporting windows in a table group, oldest first, e.g. [(2018, 2022), ...]."""
    SP = ScreeningParticipation
    return [tuple(r) for r in session.execute(
        select(SP.year_start, SP.year_end)
        .where(SP.table_code.like(table_prefix))
        .distinct()
        .order_by(SP.year_start, SP.year_end)
    ).all()]


def _pick_window(windows: list[tuple[int, int]], window: str | None) -> tuple[int, int]:
    """'2020-2024' -> (2020, 2024). No window = the latest one. Unknown window = 404."""
    if not windows:
        raise HTTPException(status_code=404, detail="No reporting windows available")
    if window is None:
        return windows[-1]
    for start, end in windows:
        if window.replace("–", "-").strip() == f"{start}-{end}":
            return start, end
    raise HTTPException(status_code=404, detail=f"Unknown window: {window!r}")
