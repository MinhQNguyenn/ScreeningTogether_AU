"""
SA3 screening participation + 2021 Census demographics, for the choropleth map.

Reads v_sa3_linked (see backend/data_pipeline/DATASET_README.md).
"""

from fastapi import HTTPException
from sqlalchemy import select

from db.models import Sa3Linked
from db.session import SessionLocal
from schemas import ChoroplethResponse


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    with SessionLocal() as session:
        row = session.execute(
            select(Sa3Linked)
            .where(Sa3Linked.geo_code == sa3_code)
            .order_by(Sa3Linked.year_end.desc())  # order by most recent first
            .limit(1)  # select only the most recent
        ).scalar_one_or_none()

    if row is None:
        raise HTTPException(status_code=404, detail=f"Unknown SA3 code: {sa3_code!r}")

    participation_reliable = not row.is_suppressed and not row.over_100

    return ChoroplethResponse(
        sa3_code=row.geo_code,
        geo_name=row.geo_name,
        year_start=row.year_start if participation_reliable else None,
        year_end=row.year_end if participation_reliable else None,
        label=f"{row.year_start}-{row.year_end}" if participation_reliable else None,
        rate_pct=row.rate_pct if participation_reliable else None,
        women_25_74=row.women_25_74,
        pct_born_overseas=row.pct_born_overseas,
        pct_other_language=row.pct_other_language,
        pct_low_proficiency=row.pct_low_proficiency,
        pct_birthplace_ns=row.pct_birthplace_ns,
    )


def _to_response(row: Sa3Linked) -> ChoroplethResponse:
    participation_reliable = not row.is_suppressed and not row.over_100

    return ChoroplethResponse(
        sa3_code=row.geo_code,
        geo_name=row.geo_name,
        year_start=row.year_start if participation_reliable else None,
        year_end=row.year_end if participation_reliable else None,
        label=f"{row.year_start}-{row.year_end}" if participation_reliable else None,
        rate_pct=row.rate_pct if participation_reliable else None,
        women_25_74=row.women_25_74,
        pct_born_overseas=row.pct_born_overseas,
        pct_other_language=row.pct_other_language,
        pct_low_proficiency=row.pct_low_proficiency,
        pct_birthplace_ns=row.pct_birthplace_ns,
    )


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    with SessionLocal() as session:
        row = session.execute(
            select(Sa3Linked)
            .where(Sa3Linked.geo_code == sa3_code)
            .order_by(Sa3Linked.year_end.desc())
            .limit(1)
        ).scalar_one_or_none()

        if row is None:
            raise HTTPException(
                status_code=404, detail=f"Unknown SA3 code: {sa3_code!r}"
            )

        return _to_response(row)


def get_all_sa3_statistics() -> list[ChoroplethResponse]:
    with SessionLocal() as session:
        rows = (
            session.execute(
                select(Sa3Linked).order_by(
                    Sa3Linked.geo_code, Sa3Linked.year_end.desc()
                )
            )
            .scalars()
            .all()
        )

        latest: dict[str, Sa3Linked] = {}
        for row in rows:
            latest.setdefault(row.geo_code, row)  # first row per area = most recent

        return [_to_response(row) for row in latest.values()]
