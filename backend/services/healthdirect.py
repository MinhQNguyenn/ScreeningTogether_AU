"""
Client for retrieving GP data.

Uses Geoscience Australia's public GIS republication of healthdirect's API, 
since it require a formal integration and approval process before issuing API credentials.

This dataset requires no authentication.
"""

import httpx
from fastapi import HTTPException

from schemas import GPResponse

GP_LAYER_URL = (
    'https://services.ga.gov.au/gis/rest/services/'
    'National_HealthDirect_Health_Facilities/MapServer/0/query'
)


def search_gps_by_postcode(postcode: str) -> list[GPResponse]:
    try:
        response = httpx.get(
            GP_LAYER_URL,
            params={
                'where': f'postcode={postcode}',
                'outFields': 'organisation_name,address,suburb,postcode,state,latitude,longitude',
                'f': 'json',
            },
        )
        response.raise_for_status()
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=502, detail="Unable to reach GP directory") from exc

    features = response.json().get('features', [])

    gps = []
    for feature in features:
        attributes = feature['attributes']
        if not attributes.get('organisation_name'):
            continue
        gps.append(
            GPResponse(
                name=attributes['organisation_name'],
                address=attributes['address'],
                suburb=attributes['suburb'],
                state=attributes['state'],
                postcode=str(attributes['postcode']),
                latitude=attributes.get('latitude'),
                longitude=attributes.get('longitude'),
            )
        )
    return gps
