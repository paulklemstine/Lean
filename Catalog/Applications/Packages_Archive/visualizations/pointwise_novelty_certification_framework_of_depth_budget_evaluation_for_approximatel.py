from math import isclose
from typing import Tuple


def approx_compose(K2: float, c2: float, K1: float, c1: float) -> Tuple[float, float]:
    """Affine error composition: (K2,c2) o (K1,c1) = (K2*K1, K2*c1 + c2)."""
    return (K2 * K1, K2 * c1 + c2)


def approx_iterate_closed_form(K: float, c: float, n: int) -> Tuple[float, float]:
    """Depth budget: (K^n, c*(K^n - 1)/(K - 1)) for K != 1, else (1, c*n)."""
    if isclose(K, 1.0):
        return (1.0, c * n)
    return (K ** n, c * (K ** n - 1.0) / (K - 1.0))


def approx_novel_transfer_threshold(eps: float, K: float, c: float) -> float:
    """Error-aware transport (Theorem 5.6): eps -> (eps - c) / K."""
    return (eps - c) / K
