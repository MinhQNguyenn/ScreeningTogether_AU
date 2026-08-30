from pydantic import BaseModel, ConfigDict

# Schema layout convention:
# Group models by api function (e.g. GP)
# Within each resource group, order as: shared base -> request model(s) -> response model(s).
# e.g.
#   class GPBase(BaseModel): ...
#   class GPQuery(GPBase): ...             # request (e.g. search params for healthdirect lookup)
#   class GPResponse(GPBase):              # response
#       model_config = ConfigDict(from_attributes=True)
#       id: str


class ScreeningStatsBase(BaseModel):
    state: str
    reporting_period: str  # e.g. "2018-2022", a rolling 5-year window, not a calendar year


class ScreeningStatsQuery(BaseModel):
    state: str | None = None
    reporting_period: str | None = None


class ScreeningStatsResponse(ScreeningStatsBase):
    model_config = ConfigDict(from_attributes=True)

    age_group: str
    number: int
    crude_rate: float
    as_rate: float | None = None
