from __future__ import annotations
from typing import List
from fractions import Fraction

Poly = List[Fraction]

def degree(p: Poly) -> int:
    q = list(p)
    while q and q[-1] == 0:
        q.pop()
    return 0 if not q else len(q) - 1

def reducible_case_fails_by_parity(f: Poly) -> bool:
    """
    O(1) decision rule (Theorem no_rational_solves_riccati_odd_deg):
    if deg f is odd, the reducible case of Kovacic's algorithm has no rational
    Riccati solution for y'' = f y, so v' + v^2 = f is unsolvable in R(X).
    """
    return degree(f) % 2 == 1
