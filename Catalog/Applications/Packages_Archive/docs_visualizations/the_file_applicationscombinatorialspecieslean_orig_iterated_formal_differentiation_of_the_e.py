from fractions import Fraction
from typing import List

def formal_derivative(coeffs: List[Fraction]) -> List[Fraction]:
    """(D f)_n = (n+1) * f_{n+1} on Q[[X]] truncated to a list."""
    return [(n + 1) * coeffs[n + 1] for n in range(len(coeffs) - 1)]

def iterate_derivative(coeffs: List[Fraction], k: int) -> List[Fraction]:
    """The k-fold formal derivative D^k applied to a coefficient list."""
    out: List[Fraction] = list(coeffs)
    for _ in range(k):
        out = formal_derivative(out)
    return out
