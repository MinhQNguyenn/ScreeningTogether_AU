from fastapi import APIRouter, Depends

from schemas import (
    AgeParticipationResponse,
    ParticipationGraphResponse,
    ParticipationPercentageResponse,
    ParticipationQuery,
    SelfCollectionResponse,
    SocioeconomicResponse,
)
from services import stats

router = APIRouter(prefix="/stats", tags=["stats"])


@router.get("/participation-percentage", response_model=ParticipationPercentageResponse)
def participation_percentage():
    return stats.participation_percentage()


@router.get("/participation-graph", response_model=ParticipationGraphResponse)
def participation_graph(query: ParticipationQuery = Depends()):
    return stats.participation_graph(query.state)

@router.get("/participation-age", response_model=AgeParticipationResponse)
def participation_age(state: str = "Australia", window: str | None = None):
    # e.g. /stats/participation-age?state=NSW&window=2020-2024 (window optional: latest by default)
    return stats.participation_by_age(state, window)


@router.get("/participation-socioeconomic", response_model=SocioeconomicResponse)
def participation_socioeconomic(window: str | None = None):
    # national only: AIHW doesn't split socioeconomic groups by state
    return stats.participation_by_socioeconomic(window)


@router.get("/self-collection", response_model=SelfCollectionResponse)
def self_collection():
    return stats.self_collection()
