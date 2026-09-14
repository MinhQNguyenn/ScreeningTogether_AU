from pydantic import BaseModel, Field

# Schema layout convention:
# Group models by api function (e.g. GP)
# Within each resource group, order as: base model -> request model(s) -> response model(s).
# e.g.
#   class GPBase(BaseModel): ...    # base model
#   class GPQuery(GPBase): ...      # request
#   class GPResponse(GPBase): ...   # response


class GPBase(BaseModel):
    postcode: str = Field(pattern=r"^\d{4}$")


class GPQuery(GPBase):
    pass


class GPResponse(GPBase):
    name: str
    address: str
    suburb: str
    state: str
    latitude: float | None = None
    longitude: float | None = None


class ParticipationBase(BaseModel):
    # geo_code: "Australia" (national) or a state/territory (NSW, Vic, Qld, WA, SA, Tas, ACT, NT).
    state: str = "Australia"


class ParticipationQuery(ParticipationBase):
    pass


# most recent national participation % across all states, 25-74 age total. No filters.
class ParticipationPercentageResponse(BaseModel):
    percent: float
    year_start: int
    year_end: int
    label: str  # reporting window, e.g. "2020-2024"


# participation % for the 25-74 total. Filterable by state or all of Australia.
class ParticipationGraphPoint(BaseModel):
    year_start: int
    year_end: int
    percent: float
    label: str  # x-axis label, e.g. "2020-2024"


class ParticipationGraphResponse(ParticipationBase):
    points: list[ParticipationGraphPoint]
