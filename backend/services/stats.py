"""
Screening statistics derived from the AIHW data in Postgres.

Reads screening_participation (see backend/data_pipeline/DATASET_README.md).
Only the state-level tables (table_code S1.2x) are used here.
"""

from fastapi import HTTPException
from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from db.models import Geography, ScreeningParticipation
from db.session import SessionLocal
from schemas import ParticipationGraphPoint, ParticipationGraphResponse, ParticipationPercentageResponse

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
        windows = _participation_totals(session, NATIONAL_GEO_CODE)

    if not windows:
        raise HTTPException(status_code=404, detail="No participation data available")

    latest = windows[-1]  # _participation_totals is ordered oldest first
    return ParticipationPercentageResponse(
        percent=latest.percent,
        year_start=latest.year_start,
        year_end=latest.year_end,
        label=latest.label,
    )


def participation_graph(state: str) -> ParticipationGraphResponse:
    """
    Participation % for the 25-74 age total, one point per reporting window
    (oldest first), for the given state or all of Australia.
    """
    with SessionLocal() as session:
        geo_code = _resolve_geo_code(session, state)
        windows = _participation_totals(session, geo_code)

    return ParticipationGraphResponse(
        state=geo_code,
        points=[
            ParticipationGraphPoint(
                year_start=w.year_start, year_end=w.year_end, percent=w.percent, label=w.label
            )
            for w in windows
        ],
    )


class _Window:
    def __init__(self, year_start: int, year_end: int, percent: float):
        self.year_start = year_start
        self.year_end = year_end
        self.percent = percent
        self.label = f"{year_start}-{year_end}"


def _participation_totals(session: Session, geo_code: str) -> list[_Window]:
    """
    derived 25-74 participation % (number / population * 100) for one geography,
    one entry per reporting window, ordered by year_end ascending.
    """
    rows = session.execute(
        select(
            ScreeningParticipation.year_start,
            ScreeningParticipation.year_end,
            func.sum(
                case((ScreeningParticipation.metric_code == "number", ScreeningParticipation.value))
            ).label("number"),
            func.sum(
                case((ScreeningParticipation.metric_code == "population", ScreeningParticipation.value))
            ).label("population"),
        )
        .where(
            ScreeningParticipation.geo_code == geo_code,
            ScreeningParticipation.age_code == AGE_TOTAL_CODE,
            ScreeningParticipation.table_code.like(STATE_TABLE_PREFIX),
            ScreeningParticipation.metric_code.in_(("number", "population")),
        )
        .group_by(ScreeningParticipation.year_start, ScreeningParticipation.year_end)
        # oldest window first, so points/labels are already left-to-right for the chart
        .order_by(ScreeningParticipation.year_start, ScreeningParticipation.year_end)
    ).all()

    return [
        _Window(r.year_start, r.year_end, round(float(r.number) / float(r.population) * 100, 1))
        for r in rows
        if r.number and r.population
    ]


def _resolve_geo_code(session: Session, state: str) -> str:
    """Validate the state filter against lookup_geography, or 404 if it isn't a known state."""
    geo_code = session.execute(
        select(Geography.geo_code).where(
            Geography.geo_level == "state",
            func.lower(Geography.geo_code) == state.strip().lower(),
        )
    ).scalar_one_or_none()

    if geo_code is None:
        raise HTTPException(status_code=404, detail=f"Unknown state: {state!r}")
    return geo_code
