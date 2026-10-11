from fastapi import APIRouter, Depends

from schemas import ChoroplethAllResponse, ChoroplethQuery, ChoroplethResponse
from services import choropleth

router = APIRouter(prefix="/choropleth", tags=["choropleth"])


@router.get("", response_model=ChoroplethResponse)
def get_sa3_statistics(query: ChoroplethQuery = Depends()):
    return choropleth.get_sa3_statistics(query.sa3_code)

@router.get("/all", response_model=list[ChoroplethResponse])
def get_all_sa3_statistics():
    return choropleth.get_all_sa3_statistics()
