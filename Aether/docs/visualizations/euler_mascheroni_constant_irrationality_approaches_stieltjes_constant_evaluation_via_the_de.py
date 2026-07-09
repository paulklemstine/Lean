from __future__ import annotations
import math

def stieltjes_constant(m: int, n: int) -> float:
    """Approximate the m-th Stieltjes constant via its defining sequence
    S_m(n) = sum_{k=1}^n (ln k)^m / k - (ln n)^{m+1}/(m+1).
    For m = 0 this returns H_n - ln n, which converges to gamma."""
    s: float = 0.0
    for k in range(1, n + 1):
        s += (math.log(k) ** m) / k
    return s - (math.log(n) ** (m + 1)) / (m + 1)
