from __future__ import annotations
from typing import List, Tuple

BinVec = Tuple[int, ...]

def direct_sum(C: List[BinVec], D: List[BinVec]) -> List[BinVec]:
    """Coordinate concatenation code C (+) D = { append(a,b) : a in C, b in D }.
       By the injectivity of (a,b) -> append(a,b), |C (+) D| = |C| * |D|."""
    return [tuple(a) + tuple(b) for a in C for b in D]
