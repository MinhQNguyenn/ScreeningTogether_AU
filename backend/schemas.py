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
