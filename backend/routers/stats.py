from fastapi import APIRouter, Depends

from schemas import (
    ParticipationGraphResponse,
    ParticipationPercentageResponse,
    ParticipationQuery,
)
from services import stats

router = APIRouter(prefix="/stats", tags=["stats"])


@router.get("/participation-percentage", response_model=ParticipationPercentageResponse)
def participation_percentage():
    return stats.participation_percentage()


@router.get("/participation-graph", response_model=ParticipationGraphResponse)
def participation_graph(query: ParticipationQuery = Depends()):
    return stats.participation_graph(query.state)
