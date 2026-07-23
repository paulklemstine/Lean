from __future__ import annotations

_NU_ONE = frozenset({0, 3, 7, 13, 14, 17, 21, 27})
_NU_TWO = frozenset({5, 6, 12, 20, 24})
_EXCEPTIONAL = frozenset({10, 19, 26})


def valuation_lookup(m: int) -> int | None:
    """
    O(1) 2-adic valuation of R_m - 1 for regular residues.
    Returns None on the three exceptional classes {10, 19, 26} mod 28,
    where the valuation is unbounded and needs the refinement algorithm.
    """
    r = m % 28
    if r in _EXCEPTIONAL:
        return None
    if r in _NU_ONE:
        return 1
    if r in _NU_TWO:
        return 2
    return 0
