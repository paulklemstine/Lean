from typing import Callable


def nearest_int_distance(y: float) -> float:
    """||y|| = distance from y to the nearest integer, in [0, 1/2]."""
    return abs(y - round(y))


def approx(x: float, q: int) -> float:
    """approx(x, q) = q * ||q x||."""
    return q * nearest_int_distance(q * x)


def empirical_lagrange_constant(x: float, q_max: int) -> float:
    """Estimate Lc(x) = liminf_{q->inf} q*||q x|| by the minimum over 1..q_max.

    By `Lc_le_one_of_irrational` the result is <= 1 for irrational x; for a
    Liouville number it tends to 0 (`Lc_eq_zero_of_liouville`)."""
    return min(approx(x, q) for q in range(1, q_max + 1))
