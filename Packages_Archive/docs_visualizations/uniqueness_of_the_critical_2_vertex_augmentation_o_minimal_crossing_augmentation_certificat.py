from fractions import Fraction
from typing import Tuple, Dict


def below_quarter(a: int, m: int) -> bool:
    """Exact test a/m < 1/4 via the integer inequality 4a < m (m > 0)."""
    if m <= 0:
        raise ValueError("m must be positive")
    return 4 * a < m


def least_augmentation(a: int, n: int) -> int:
    """Least k with a/(n+k) < 1/4, given n <= 4a. Returns 4a - n + 1."""
    if n <= 0:
        raise ValueError("n must be positive")
    if not (n <= 4 * a):
        raise ValueError("require n <= 4a (base at/above threshold)")
    return 4 * a - n + 1


def augmentation_certificate(a: int, n: int) -> Dict[str, object]:
    """Full certificate: minimal k, boundary check, and fractional bounds."""
    k = least_augmentation(a, n)
    return {
        "a": a,
        "n": n,
        "k_min": k,
        "base_ratio": Fraction(a, n),
        "base_forces_gt4": below_quarter(a, n),
        "boundary_ratio": Fraction(a, n + k - 1),
        "boundary_forces_gt4": below_quarter(a, n + k - 1),
        "crossed_ratio": Fraction(a, n + k),
        "crossed_forces_gt4": below_quarter(a, n + k),
        "chi_f_lower_bound_crossed": Fraction(n + k, a),
    }
