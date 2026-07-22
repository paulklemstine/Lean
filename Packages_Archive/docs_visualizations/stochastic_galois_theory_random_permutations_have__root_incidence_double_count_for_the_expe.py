from itertools import product
from typing import Tuple

def eval_monic(coeffs: Tuple[int, ...], r: int, p: int) -> int:
    val = pow(r, len(coeffs), p)
    for i, c in enumerate(coeffs):
        val = (val + c * pow(r, i, p)) % p
    return val

def count_roots(coeffs: Tuple[int, ...], p: int) -> int:
    """Count roots in F_p of the monic polynomial with lower coeffs `coeffs`."""
    return sum(1 for r in range(p) if eval_monic(coeffs, r, p) == 0)

def total_incidences(p: int, n: int) -> int:
    """Total (polynomial, root) incidences; equals p^n by the theorem."""
    return sum(count_roots(c, p) for c in product(range(p), repeat=n))
