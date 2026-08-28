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
