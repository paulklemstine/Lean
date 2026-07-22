from __future__ import annotations
from typing import List, Tuple

Elem = Tuple[int, bool, int]  # (col, side: False='a'/True='b', idx)

def fold(w: int, x: Elem) -> int:
    """Column-folding map: b(i) -> i, a(i) -> i+1 (mod w)."""
    col, side, _ = x
    return col if side else (col + 1) % w

def leq(w: int, x: Elem, y: Elem) -> bool:
    xc, xs, xi = x
    yc, ys, yi = y
    chain = (xs == ys) and (xc == yc) and (xi <= yi)
    cross = (xs is False) and (ys is True) and (yc == (xc + 1) % w)
    return chain or cross

def certify_width_upper_bound(w: int, antichain: List[Elem]) -> bool:
    """Return True if the folding certificate bounds |antichain| by w."""
    values = [fold(w, x) for x in antichain]
    if len(set(values)) != len(values):
        return False  # not actually an antichain / fold not injective
    return all(0 <= v < w for v in values) and len(antichain) <= w

def width_lower_bound_witness(w: int) -> List[Elem]:
    """The all-lower antichain {a(i,0)} of size w witnessing width >= w."""
    return [(i, False, 0) for i in range(w)]
