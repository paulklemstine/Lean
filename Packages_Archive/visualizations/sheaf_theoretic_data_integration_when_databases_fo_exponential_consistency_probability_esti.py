from math import log10
from typing import Tuple

def overlap_constraint_count(n: int, n_rows: int, n_cols: int) -> int:
    return n * (n - 1) // 2 * (n_rows * n_cols)

def consistency_probability_log10(r: float, n: int, k: int) -> Tuple[int, float]:
    assert 0.0 < r < 1.0
    C = overlap_constraint_count(n, k, n)
    return C, C * log10(1.0 - r)

def consistency_probability(r: float, constraint_count: int) -> float:
    return (1.0 - r) ** constraint_count
