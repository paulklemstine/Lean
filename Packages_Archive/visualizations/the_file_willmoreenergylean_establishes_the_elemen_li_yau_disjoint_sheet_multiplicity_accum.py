from __future__ import annotations
from typing import Sequence
import math

FOUR_PI: float = 4.0 * math.pi

def li_yau_sheet_bound(
    sheets_positive_gauss_mass: Sequence[float],
) -> dict[str, float]:
    """Li-Yau sheet accumulation (Algorithm 8.2).

    Each entry is the positive Gaussian-curvature mass integral_{A_i} K^+ dmu of
    a disjoint sheet A_i.  A sheet is a valid '4*pi-sheet' if its mass >= 4*pi.
    The Willmore energy is bounded below by the number of valid sheets times
    4*pi (each sheet's energy >= its positive curvature mass >= 4*pi).
    """
    valid = [m for m in sheets_positive_gauss_mass if m >= FOUR_PI - 1e-9]
    n = len(valid)
    return {
        "num_valid_sheets": float(n),
        "li_yau_lower_bound": FOUR_PI * n,
        "embedded_forced": float(FOUR_PI * n < 2 * FOUR_PI),  # W < 8*pi => embedded
    }