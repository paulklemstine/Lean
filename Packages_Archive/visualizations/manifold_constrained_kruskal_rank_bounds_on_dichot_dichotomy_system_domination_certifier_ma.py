from typing import Callable
from math import comb

def dominated_by_cover(g: Callable[[int, int], int],
                       max_N: int, max_d: int) -> bool:
    """Certify g is a dichotomy system and hence bounded by Cover's function."""
    def C(N: int, d: int) -> int:
        return 2 * sum(comb(N - 1, k) for k in range(d))
    base_pt  = all(g(1, d) <= 2 for d in range(1, max_d + 1))
    base_dim = all(g(N, 1) <= 2 for N in range(1, max_N + 1))
    rec = all(g(N+1, d+1) <= g(N, d+1) + g(N, d)
              for N in range(1, max_N) for d in range(1, max_d))
    if not (base_pt and base_dim and rec):
        return False
    return all(g(N, d) <= C(N, d)
               for N in range(1, max_N + 1) for d in range(1, max_d + 1))
