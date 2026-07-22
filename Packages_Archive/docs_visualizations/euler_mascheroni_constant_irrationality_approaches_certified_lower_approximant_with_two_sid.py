from __future__ import annotations
import math

def gamma_lower_bracket(n: int) -> tuple[float, float, float]:
    """Certified lower approximant L_n = H_n - ln(n+1) for the
    Euler-Mascheroni constant, with a guaranteed enclosing bracket
    L_n < gamma < L_n + 1/(2n) (valid for n >= 1).

    Returns (L_n, lower=L_n, upper=L_n + 1/(2n))."""
    H_n: float = 0.0
    for k in range(1, n + 1):
        H_n += 1.0 / k
    L_n: float = H_n - math.log(n + 1)
    return L_n, L_n, L_n + 1.0 / (2 * n)
