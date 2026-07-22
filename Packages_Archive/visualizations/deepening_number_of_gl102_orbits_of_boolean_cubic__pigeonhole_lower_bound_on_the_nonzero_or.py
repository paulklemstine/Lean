from __future__ import annotations
from math import comb


def pigeonhole_floor_nonzero(n: int, d: int = 3, q: int = 2) -> int:
    """Proven lower bound on the number of nonzero GL(n,q)-orbits of Boolean
    degree-d forms: ceil((q^C(n,d) - 1) / |GL(n,q)|)."""
    forms: int = q ** comb(n, d)
    order: int = 1
    for i in range(n):
        order *= q**n - q**i
    return -(-(forms - 1) // order)
