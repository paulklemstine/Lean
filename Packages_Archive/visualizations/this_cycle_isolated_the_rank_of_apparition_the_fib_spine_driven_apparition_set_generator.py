from typing import List

def fib_rank(m: int) -> int:
    a, b = 0, 1
    for k in range(1, m * m + 1):
        a, b = b, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable")

def apparition_set(m: int, n_max: int) -> List[int]:
    """Exact { n <= n_max : m | F_n }, via the spine (no per-index test)."""
    r = fib_rank(m)
    return list(range(r, n_max + 1, r))
