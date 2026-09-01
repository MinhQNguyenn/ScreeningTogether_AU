from fastapi import APIRouter, Depends

from schemas import GPQuery, GPResponse
from services import healthdirect

router = APIRouter(prefix="/gp", tags=["gp"])


@router.get("", response_model=list[GPResponse])
def list_gps(query: GPQuery = Depends()):
    return healthdirect.search_gps_by_postcode(query.postcode)
