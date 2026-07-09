from math import isqrt
from typing import Tuple

def elliptic_trace(a: int, b: int, p: int) -> int:
    """Trace of Frobenius a_p = p + 1 - #E(F_p) for y^2 = x^3 + a x + b."""
    affine = sum(1
                 for x in range(p)
                 for y in range(p)
                 if (y * y - (x ** 3 + a * x + b)) % p == 0)
    return p + 1 - (affine + 1)   # +1 for the point at infinity

def zeta_numerator(a_p: int, p: int) -> Tuple[int, int, int]:
    """Coefficients (c0, c1, c2) of P(T) = 1 - a_p T + p T^2."""
    return (1, -a_p, p)

def certify_numerator(a: int, b: int, p: int) -> dict:
    """Certify p-reciprocity and the Weil bound for the CY 1-fold numerator."""
    a_p = elliptic_trace(a, b, p)
    c0, c1, c2 = zeta_numerator(a_p, p)
    reciprocal_ok = (c2 == p * c0)               # eulerFactor_funeq
    weil_ok = (a_p * a_p <= 4 * p)               # zeta_frobenius_weil
    return {
        "p": p, "a_p": a_p, "P": (c0, c1, c2),
        "reciprocal_ok": reciprocal_ok,
        "weil_ok": weil_ok,
        "hasse_interval": (p + 1 - 2 * isqrt(p), p + 1 + 2 * isqrt(p) + 1),
    }
