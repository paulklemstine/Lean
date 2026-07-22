from typing import List, Tuple

def region_counts(N: int) -> Tuple[List[int], List[int]]:
    """Return (p, c) with p[n] the lazy caterer number and c[n] the cake number,
    for n = 0..N, computed by additions only."""
    p: List[int] = [1] * (N + 1)
    c: List[int] = [1] * (N + 1)
    for n in range(N):
        p[n + 1] = p[n] + (n + 1)
        c[n + 1] = c[n] + p[n]
    return p, c
