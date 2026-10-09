"""
SA3 screening participation + 2021 Census demographics, for the choropleth map.

Reads v_sa3_linked (see backend/data_pipeline/DATASET_README.md).
"""

from fastapi import HTTPException
from sqlalchemy import select

from db.models import Sa3Linked
from db.session import SessionLocal
from schemas import ChoroplethAllResponse, ChoroplethAreaRate, ChoroplethResponse
from services.stats import participation_percentage


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    with SessionLocal() as session:
        row = session.execute(
            select(Sa3Linked)
            .where(Sa3Linked.geo_code == sa3_code)
            .order_by(Sa3Linked.year_end.desc()) # order by most recent first
            .limit(1) # select only the most recent
        ).scalar_one_or_none()

    if row is None:
        raise HTTPException(status_code=404, detail=f'Unknown SA3 code: {sa3_code!r}')

    participation_reliable = not row.is_suppressed and not row.over_100

    gap_pct = None
    if participation_reliable and row.rate_pct is not None:
        national = participation_percentage()
        # only compare against the national figure if it's the same reporting window
        if national.year_start == row.year_start and national.year_end == row.year_end:
            # compute gap percentage
            gap_pct = round(row.rate_pct - national.percent, 1)

    return ChoroplethResponse(
        sa3_code = row.geo_code,
        geo_name = row.geo_name,
        year_start = row.year_start if participation_reliable else None,
        year_end = row.year_end if participation_reliable else None,
        label = f"{row.year_start}-{row.year_end}" if participation_reliable else None,
        rate_pct = row.rate_pct if participation_reliable else None,
        women_25_74 = row.women_25_74,
        pct_born_overseas = row.pct_born_overseas,
        pct_other_language = row.pct_other_language,
        pct_low_proficiency = row.pct_low_proficiency,
        pct_birthplace_ns = row.pct_birthplace_ns,
        gap_pct = gap_pct,
    )


def get_all_sa3_statistics() -> ChoroplethAllResponse:
    with SessionLocal() as session:
        latest_window = session.execute(
            select(Sa3Linked.year_start, Sa3Linked.year_end)
            .distinct()
            # tiebreak on year_start too, so the result is deterministic if two
            # windows ever shared the same year_end
            .order_by(Sa3Linked.year_end.desc(), Sa3Linked.year_start.desc())
            .limit(1)
        ).one_or_none()

        if latest_window is None:
            raise HTTPException(status_code=404, detail="No participation data available")
        latest_year_start, latest_year_end = latest_window

        rows = session.execute(
            select(Sa3Linked.geo_code, Sa3Linked.geo_name, Sa3Linked.rate_pct, Sa3Linked.is_suppressed, Sa3Linked.over_100)
            .where(Sa3Linked.year_end == latest_year_end)
        ).all()

    # retrieve all SA3 codes and participation rates
    areas = []
    for row in rows:
        participation_reliable = not row.is_suppressed and not row.over_100
        areas.append(
            ChoroplethAreaRate(
                sa3_code=row.geo_code,
                geo_name=row.geo_name,
                rate_pct=row.rate_pct if participation_reliable else None,
            )
        )
    return ChoroplethAllResponse(label=f'{latest_year_start}-{latest_year_end}', areas=areas)
