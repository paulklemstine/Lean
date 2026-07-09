import math


def series_sum_gamma(num_terms: int) -> tuple[float, float]:
    """Sum the nonnegative telescoping series for gamma.
    Returns (estimate, certified_one_sided_error_bound)."""
    total: float = 0.0
    for k in range(num_terms):
        term: float = 1.0 / (k + 1) - math.log((k + 2) / (k + 1))
        total += term
    return total, 1.0 / num_terms
