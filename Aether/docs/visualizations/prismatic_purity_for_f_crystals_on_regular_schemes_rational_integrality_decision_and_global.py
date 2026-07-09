from fractions import Fraction
from typing import Optional, Sequence


def is_root_of_monic(q: Fraction, monic_lower_coeffs: Sequence[int]) -> bool:
    """Test whether q is a root of x^n + c_{n-1} x^{n-1} + ... + c_0,
    where monic_lower_coeffs = [c_0, ..., c_{n-1}] and the x^n term is 1."""
    coeffs = list(monic_lower_coeffs) + [1]
    acc = Fraction(0)
    power = Fraction(1)
    for c in coeffs:
        acc += c * power
        power *= q
    return acc == 0


def hartogs_Z_extend(q: Fraction, monic_lower_coeffs: Sequence[int]) -> Optional[int]:
    """Realize `hartogs_Z`: if q in Q is integral over Z (a root of the given monic
    integer polynomial), return the unique integer n with n == q; otherwise None.
    By the rational root theorem a monic integer polynomial can only have integer
    rational roots, so an integral rational is automatically an integer."""
    if not is_root_of_monic(q, monic_lower_coeffs):
        return None
    return q.numerator if q.denominator == 1 else None
