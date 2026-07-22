from math import comb
from typing import List


def worpitzky_expand(m: int, n: int, eulerian_row: List[int]) -> int:
    """Given row n of the Eulerian triangle, return sum_k <n,k> C(m+k, n),
    which equals m^n (Worpitzky's identity).  Time O(n)."""
    return sum(eulerian_row[k] * comb(m + k, n) for k in range(len(eulerian_row)))
