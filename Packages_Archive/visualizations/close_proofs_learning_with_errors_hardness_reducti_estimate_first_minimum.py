from __future__ import annotations
import itertools, math
from typing import Sequence

def estimate_first_minimum(
    basis: Sequence[Sequence[float]], coeff_range: int
) -> float:
    """Brute-force estimate of lambda_1 over a coefficient box."""
    dim = len(basis)
    best = math.inf
    for coeffs in itertools.product(
        range(-coeff_range, coeff_range + 1), repeat=dim
    ):
        if all(c == 0 for c in coeffs):
            continue
        vec = [
            sum(coeffs[i] * basis[i][j] for i in range(dim))
            for j in range(len(basis[0]))
        ]
        best = min(best, math.sqrt(sum(x * x for x in vec)))
    return best
