from __future__ import annotations
from dataclasses import dataclass
from math import log2

@dataclass(frozen=True)
class Result:
    candidates: int
    information_bits: float | None
    worst_case_queries: int

def analyze_uniform_tree(q: int, depth: int) -> Result:
    if q < 0 or depth < 0:
        raise ValueError("q and depth must be nonnegative")
    candidates = pow(q, depth)
    information = log2(candidates) if candidates > 0 else None
    return Result(candidates, information, candidates)
