"""
SA3 screening participation + 2021 Census demographics, for the choropleth map.

Reads v_sa3_linked (see backend/data_pipeline/DATASET_README.md).
"""

from schemas import ChoroplethResponse


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    raise NotImplementedError
