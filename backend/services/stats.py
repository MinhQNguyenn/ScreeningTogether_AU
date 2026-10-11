"""
Screening statistics derived from the AIHW data in Postgres.

Reads screening_participation (see backend/data_pipeline/DATASET_README.md).
Only the state-level tables (table_code S1.2x) are used here.
"""

from fastapi import HTTPException
from sqlalchemy import func, select
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
