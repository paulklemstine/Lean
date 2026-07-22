import cmath
from typing import Tuple

def legendre_symbol(a: int, p: int) -> int:
    a_mod: int = a % p
    if a_mod == 0:
        return 0
    r: int = pow(a_mod, (p - 1) // 2, p)
    return -1 if r == p - 1 else r

def gauss_sum_square_check(p: int) -> Tuple[complex, complex]:
    """Return (g^2, predicted = (-1)^((p-1)/2) * p)."""
    g: complex = sum(
        legendre_symbol(x, p) * cmath.exp(2j * cmath.pi * x / p)
        for x in range(p)
    )
    sign: int = -1 if ((p - 1) // 2) % 2 else 1
    return g * g, complex(sign * p, 0.0)