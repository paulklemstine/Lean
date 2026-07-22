from math import comb
from typing import List

def ramsey_binomial_table(max_s: int, max_t: int) -> List[List[int]]:
    """Erdos-Szekeres upper-bound table U[s][t] = C(s+t-2, s-1) >= R(s,t),
    computed by Pascal's recursion U[s][t] = U[s-1][t] + U[s][t-1]."""
    U = [[0] * (max_t + 1) for _ in range(max_s + 1)]
    for s in range(1, max_s + 1):
        for t in range(1, max_t + 1):
            if s == 1 or t == 1:
                U[s][t] = 1
            else:
                U[s][t] = U[s - 1][t] + U[s][t - 1]
    return U

def es_bound(s: int, t: int) -> int:
    """Closed form: R(s, t) <= C(s + t - 2, s - 1)."""
    return comb(s + t - 2, s - 1)
