from fastapi import APIRouter, Depends

from schemas import ChoroplethQuery, ChoroplethResponse
from services import choropleth

router = APIRouter(prefix="/choropleth", tags=["choropleth"])


@router.get("", response_model=ChoroplethResponse)
def get_sa3_statistics(query: ChoroplethQuery = Depends()):
    return choropleth.get_sa3_statistics(query.sa3_code)
