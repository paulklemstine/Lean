from __future__ import annotations
from typing import Optional, Tuple

def escher_product(esc_R: bool, esc_S: bool) -> bool:
    """Esc(R x S) <=> Esc(R) or Esc(S). O(1)."""
    return esc_R or esc_S

def locate_witnessing_coordinate(esc_R: bool, esc_S: bool) -> Optional[str]:
    """Return which coordinate carries the product staircase, or None if neither does."""
    if esc_R:
        return "R"
    if esc_S:
        return "S"
    return None

def escher_polynomial(esc_R: bool) -> bool:
    """Esc(R[x]) <=> Esc(R): single-variable adjunction is neutral. O(1)."""
    return esc_R
