from fractions import Fraction
from typing import Tuple


def threshold_verifier(n: int, alpha: int) -> Tuple[bool, Fraction]:
    """Return (is_strict, lower_bound) where is_strict = (4*alpha < n) and
    lower_bound = n/alpha is the guaranteed lower bound on the fractional
    chromatic number. If is_strict is True then chi_f(G) > 4."""
    strict: bool = 4 * alpha < n
    bound: Fraction = Fraction(n, alpha) if alpha > 0 else Fraction(0)
    return strict, bound
