"""
SA3 2021 Census demographic breakdown, for the choropleth map.

Reads v_sa3_census_measures (see backend/data_pipeline/DATASET_README.md).
"""

from fastapi import HTTPException
from sqlalchemy import select

from db.models import Geography, Sa3CensusMeasures
from db.session import SessionLocal
from schemas import ChoroplethResponse


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    with SessionLocal() as session:
        row = session.execute(
            select(Sa3CensusMeasures, Geography.geo_name)
            .join(Geography, Geography.geo_code == Sa3CensusMeasures.geo_code)
            .where(Sa3CensusMeasures.geo_code == sa3_code)
        ).one_or_none()

    if row is None:
        raise HTTPException(status_code=404, detail=f"Unknown SA3 code: {sa3_code!r}")

    measures, geo_name = row
    return ChoroplethResponse(
        sa3_code=measures.geo_code,
        geo_name=geo_name,
        women_25_74=measures.women_25_74,
        females_all_ages=measures.females_all_ages,
        pct_born_overseas=measures.pct_born_overseas,
        pct_other_language=measures.pct_other_language,
        pct_low_proficiency=measures.pct_low_proficiency,
        pct_birthplace_ns=measures.pct_birthplace_ns,
    )
