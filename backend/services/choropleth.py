"""
SA3 screening participation + 2021 Census demographics, for the choropleth map.

Reads v_sa3_linked (see backend/data_pipeline/DATASET_README.md).
"""

import statistics

from fastapi import HTTPException
from sqlalchemy import select

from db.models import Sa3Linked
from db.session import SessionLocal
from schemas import ChoroplethAllResponse, ChoroplethAreaRate, ChoroplethResponse
from services.stats import participation_percentage


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    with SessionLocal() as session:
        row = session.execute(
            select(Sa3Linked)
            .where(Sa3Linked.geo_code == sa3_code)
            .order_by(Sa3Linked.year_end.desc()) # order by most recent first
            .limit(1) # select only the most recent
        ).scalar_one_or_none()

    if row is None:
        raise HTTPException(status_code=404, detail=f'Unknown SA3 code: {sa3_code!r}')

    participation_reliable = not row.is_suppressed and not row.over_100

    gap_pct = None
    if participation_reliable and row.rate_pct is not None:
        national = participation_percentage()
        # only compare against the national figure if it's the same reporting window
        if national.year_start == row.year_start and national.year_end == row.year_end:
            # compute gap percentage
            gap_pct = round(row.rate_pct - national.percent, 1)

    return ChoroplethResponse(
        sa3_code = row.geo_code,
        geo_name = row.geo_name,
        year_start = row.year_start if participation_reliable else None,
        year_end = row.year_end if participation_reliable else None,
        label = f"{row.year_start}-{row.year_end}" if participation_reliable else None,
        rate_pct = row.rate_pct if participation_reliable else None,
        women_25_74 = row.women_25_74,
        pct_born_overseas = row.pct_born_overseas,
        pct_other_language = row.pct_other_language,
        pct_low_proficiency = row.pct_low_proficiency,
        pct_birthplace_ns = row.pct_birthplace_ns,
        gap_pct = gap_pct,
    )


# ABS slightly adjusts small counts to protect privacy, which can push a tiny area's
# percentage outside 0-100 (e.g. Jervis Bay -5.5%). Those values are not shown.
def _valid_pct(value) -> float | None:
    if value is None:
        return None
    value = float(value)
    return value if 0 <= value <= 100 else None


def _born_overseas_cutoffs(rows) -> tuple[float, float] | None:
    """
    Tercile cut-offs of % born overseas (2021 Census), from every SA3 area
    with a valid (0-100%) figure. Returns (low_max, mid_max).
    """
    values = sorted(
        _valid_pct(r.pct_born_overseas)
        for r in rows
        if _valid_pct(r.pct_born_overseas) is not None
    )
    if len(values) < 3:
        return None
    low_max, mid_max = statistics.quantiles(values, n=3, method="inclusive")
    return round(low_max, 1), round(mid_max, 1)


def _born_overseas_tier(row: Sa3Linked, cutoffs) -> str | None:
    """'low' | 'mid' | 'high', or None = show no label.
    Hard rule: no label when the figure is missing or unreliable."""
    if cutoffs is None or _valid_pct(row.pct_born_overseas) is None:
        return None
    if row.is_suppressed or row.over_100:
        return None
    low_max, mid_max = cutoffs
    value = _valid_pct(row.pct_born_overseas)
    if value <= low_max:
        return "low"
    if value <= mid_max:
        return "mid"
    return "high"


def _latest_rows(session) -> dict[str, Sa3Linked]:
    """Most recent reporting window for every SA3 area."""
    rows = (
        session.execute(
            select(Sa3Linked).order_by(Sa3Linked.geo_code, Sa3Linked.year_end.desc())
        )
        .scalars()
        .all()
    )
    latest: dict[str, Sa3Linked] = {}
    for row in rows:
        latest.setdefault(row.geo_code, row)  # first row per area = most recent
    return latest


def _to_response(row: Sa3Linked, cutoffs) -> ChoroplethResponse:
    participation_reliable = not row.is_suppressed and not row.over_100

    return ChoroplethResponse(
        sa3_code=row.geo_code,
        geo_name=row.geo_name,
        year_start=row.year_start if participation_reliable else None,
        year_end=row.year_end if participation_reliable else None,
        label=f"{row.year_start}-{row.year_end}" if participation_reliable else None,
        rate_pct=row.rate_pct if participation_reliable else None,
        women_25_74=row.women_25_74,
        pct_born_overseas=_valid_pct(row.pct_born_overseas),
        pct_other_language=_valid_pct(row.pct_other_language),
        pct_low_proficiency=_valid_pct(row.pct_low_proficiency),
        pct_birthplace_ns=_valid_pct(row.pct_birthplace_ns),
        born_overseas_tier=_born_overseas_tier(row, cutoffs),
    )


def get_sa3_statistics(sa3_code: str) -> ChoroplethResponse:
    with SessionLocal() as session:
        latest = _latest_rows(session)

    row = latest.get(sa3_code)
    if row is None:
        raise HTTPException(status_code=404, detail=f"Unknown SA3 code: {sa3_code!r}")

    # cut-offs always come from ALL areas, never just the one requested
    return _to_response(row, _born_overseas_cutoffs(latest.values()))


def get_all_sa3_statistics() -> list[ChoroplethResponse]:
    with SessionLocal() as session:
        latest = _latest_rows(session)

    cutoffs = _born_overseas_cutoffs(latest.values())
    return [_to_response(row, cutoffs) for row in latest.values()]
