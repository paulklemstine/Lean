from typing import Tuple
import cmath, math

def count_points_Fp(a: int, b: int, p: int) -> int:
    """#E(F_p) for y^2 = x^3 + a x + b, including the point at infinity."""
    squares = {(y * y) % p for y in range(p)}
    count = 1
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        count += 1 if rhs == 0 else (2 if rhs in squares else 0)
    return count

def trace_and_eigenvalues(a: int, b: int, p: int) -> Tuple[int, complex, complex, bool]:
    """Return (a_p, alpha, beta, hasse_ok) where a_p = p+1-#E(F_p),
    alpha,beta are roots of X^2 - a_p X + p, and hasse_ok tests a_p^2 <= 4p
    (equivalently |alpha| = |beta| = sqrt(p))."""
    ap = p + 1 - count_points_Fp(a, b, p)
    disc = cmath.sqrt(ap * ap - 4 * p)
    alpha, beta = (ap + disc) / 2, (ap - disc) / 2
    hasse_ok = ap * ap <= 4 * p
    return ap, alpha, beta, hasse_ok
