from sqlalchemy import func, select

from db.models import CervicalScreeningStat
from db.session import SessionLocal
from schemas import ScreeningStatsResponse


def get_cervical_screening_stats(
    state: str | None = None,
    reporting_period: str | None = None,
) -> list[ScreeningStatsResponse]:
    with SessionLocal() as session:
        # Default to the latest period when none is requested
        if reporting_period is None:
            reporting_period = session.scalar(select(func.max(CervicalScreeningStat.reporting_period)))

        stmt = select(CervicalScreeningStat)
        if state:
            stmt = stmt.where(CervicalScreeningStat.state == state)
        if reporting_period:
            stmt = stmt.where(CervicalScreeningStat.reporting_period == reporting_period)

        rows = session.scalars(stmt).all()
        return [ScreeningStatsResponse.model_validate(row) for row in rows]
