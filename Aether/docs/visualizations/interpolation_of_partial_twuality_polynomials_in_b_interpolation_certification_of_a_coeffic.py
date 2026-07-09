from typing import List, Tuple


def interpolation_range(coeffs: List[int]) -> Tuple[int, int]:
    """Return (lo, hi): least and greatest index carrying a positive coefficient."""
    support: List[int] = [k for k, c in enumerate(coeffs) if c > 0]
    return support[0], support[-1]


def is_interpolating(coeffs: List[int]) -> bool:
    """True iff the support of `coeffs` is a contiguous interval [lo, hi].

    A polynomial is *interpolating* when its nonzero coefficients occupy a gap-free
    range; for single-feasible-set partial-twuality polynomials this always returns
    True with range (0, |E|).
    """
    lo, hi = interpolation_range(coeffs)
    return all(coeffs[k] > 0 for k in range(lo, hi + 1))
