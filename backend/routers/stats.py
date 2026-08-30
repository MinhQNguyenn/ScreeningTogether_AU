from fastapi import APIRouter, Depends

from schemas import ScreeningStatsQuery, ScreeningStatsResponse
from services import stats

router = APIRouter(prefix="/stats/cervical-screening", tags=["stats"])


@router.get("", response_model=list[ScreeningStatsResponse])
def list_cervical_screening_stats(query: ScreeningStatsQuery = Depends()):
    return stats.get_cervical_screening_stats(
        state=query.state,
        reporting_period=query.reporting_period,
    )
