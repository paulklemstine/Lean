from __future__ import annotations
import math
from typing import Tuple


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log2 p - (1-p) log2(1-p)."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def exponential_base(alpha: float) -> float:
    """Exponential base 2^H(alpha); at alpha=1/3 this is 3/2^(2/3)."""
    return 2.0 ** binary_entropy(alpha)


def partial_binomial_sum(n: int, alpha: float) -> int:
    """Exact sum_{k<=alpha n} C(n,k)."""
    top = int(math.floor(alpha * n))
    return sum(math.comb(n, k) for k in range(0, top + 1))


def entropy_estimate(n: int, alpha: float) -> float:
    """Leading estimate  c(alpha) * 2^{n H(alpha)} / sqrt(n)  for the partial sum."""
    if alpha >= 0.5:
        return float(2 ** n)
    c = (1 - alpha) / (1 - 2 * alpha)
    return c / math.sqrt(2 * math.pi * alpha * (1 - alpha) * n) * 2.0 ** (n * binary_entropy(alpha))


def base_identities() -> Tuple[float, float, float, float]:
    """Return (3/2^(2/3), 2^H(1/3), (3/2^(2/3))^3, 27/4)."""
    base = 3.0 / 2.0 ** (2.0 / 3.0)
    return base, exponential_base(1 / 3), base ** 3, 27.0 / 4.0
