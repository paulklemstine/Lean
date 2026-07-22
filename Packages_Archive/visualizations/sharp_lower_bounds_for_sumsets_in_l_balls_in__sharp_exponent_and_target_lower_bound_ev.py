from __future__ import annotations
import math

def sharp_exponent(n: int, m: int) -> float:
    """Return p(n,m) = n*log(m+1)/log(n*m+1), the sharp sumset exponent.

    Satisfies 1 <= p <= n and (m+1)^(n/p) = n*m+1 exactly.
    Complexity: O(1) (two logarithms).
    """
    if n < 1 or m < 1:
        raise ValueError("require n >= 1 and m >= 1")
    return n * math.log(m + 1) / math.log(n * m + 1)

def target_lower_bound(sizes: list[int], n: int, m: int) -> float:
    """(prod_j |A_j|)^(1/p): the conjectured sharp lower bound on |sumset|."""
    p = sharp_exponent(n, m)
    prod = math.prod(sizes)
    return prod ** (1.0 / p)
