from __future__ import annotations
from math import comb


def orbit_window_report(n: int, proposed: int, d: int = 3, q: int = 2) -> dict[str, object]:
    """Assemble the two-sided window and check a proposed exact orbit count."""
    forms: int = q ** comb(n, d)
    order: int = 1
    for i in range(n):
        order *= q**n - q**i
    floor_nz: int = -(-(forms - 1) // order)
    return {
        "lower_bound": floor_nz,
        "upper_bound": forms - 1,
        "proposed": proposed,
        "fits_window": floor_nz <= proposed <= forms - 1,
        "defect_above_floor": proposed - floor_nz,
        "relative_gap": proposed / floor_nz,
    }
