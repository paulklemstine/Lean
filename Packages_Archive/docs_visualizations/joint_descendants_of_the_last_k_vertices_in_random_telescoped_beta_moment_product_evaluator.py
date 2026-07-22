import math
from typing import List, Sequence, Tuple


def beta_moment(alpha: float, beta: float, p: float) -> float:
    """p-th moment of Beta(alpha, beta)."""
    return (math.gamma(alpha + p) * math.gamma(alpha + beta)) / (
        math.gamma(alpha) * math.gamma(alpha + beta + p))


def telescoped_product(alpha: Sequence[float], beta: Sequence[float],
                       p: float, tol: float = 1e-9) -> Tuple[float, float]:
    """Return (direct_product, endpoint_value) for a chained Beta-moment product.

    Requires additive chaining alpha[j+1] == alpha[j] + beta[j]. Under that
    condition the two returned numbers agree; the caller can assert closeness.
    Complexity: O(n) Gamma evaluations for the direct product, O(1) for the
    endpoint formula."""
    n = len(alpha)
    for j in range(n - 1):
        assert abs(alpha[j + 1] - (alpha[j] + beta[j])) < tol, "chain broken"
    alpha_n = alpha[-1] + beta[-1]
    direct = 1.0
    for a, b in zip(alpha, beta):
        direct *= beta_moment(a, b, p)
    endpoint = (math.gamma(alpha[0] + p) * math.gamma(alpha_n)) / (
        math.gamma(alpha[0]) * math.gamma(alpha_n + p))
    return direct, endpoint
