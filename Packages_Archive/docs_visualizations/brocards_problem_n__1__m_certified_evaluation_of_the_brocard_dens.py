import math
from typing import Tuple

def density_partial_sum(N: int) -> float:
    """S_N = sum_{n=0}^N 1/sqrt(n!) computed with incremental factorial."""
    s: float = 0.0
    fact: int = 1
    for n in range(N + 1):
        if n > 0:
            fact *= n
        s += 1.0 / math.sqrt(fact)
    return s

def density_with_tail_bound(N: int) -> Tuple[float, float]:
    """Return (S_N, tail_bound) where tail_bound rigorously bounds the
    remainder via 1/sqrt(n!) <= sqrt(2)*(1/sqrt(2))^n (geometric, ratio<1)."""
    S: float = density_partial_sum(N)
    r: float = 1.0 / math.sqrt(2.0)
    tail: float = math.sqrt(2.0) * r ** (N + 1) / (1.0 - r)
    return S, tail

if __name__ == "__main__":
    for N in (5, 10, 20, 50):
        S, tail = density_with_tail_bound(N)
        print(f"N={N}: S_N={S:.10f}  tail<= {tail:.3e}  enclosed in "
              f"[{S:.6f}, {S + tail:.6f}]")
