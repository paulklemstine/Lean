from math import comb
from typing import Tuple

def layered_star_value(n: int, d: int, k: int) -> int:
    """Size of the depth-k layered star: sum_{i=0}^{k} C(n-2i-1, d-2i)."""
    return sum(comb(n - 2 * i - 1, d - 2 * i) for i in range(k + 1))

def conjectured_optimum(n: int, d: int) -> Tuple[int, int]:
    """Return (M_d(n), best_k) maximizing over 0 <= k <= floor(d/2)."""
    best_val, best_k = -1, 0
    for k in range(d // 2 + 1):
        v = layered_star_value(n, d, k)
        if v > best_val:
            best_val, best_k = v, k
    return best_val, best_k
