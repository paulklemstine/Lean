from __future__ import annotations

import itertools
import math
from typing import List


def expected_inner_sq(n: int, theta: List[float]) -> float:
    """Exact E[<theta,x>^2] over {-1,1}^n by enumeration; predicted = sum theta_k^2.

    Complexity: Theta(2^n * n) time, Theta(1) extra space.
    """
    total = 0.0
    for bits in itertools.product((1, -1), repeat=n):
        s = 0.0
        for k in range(n):
            s += theta[k] * bits[k]
        total += s * s
    return total / (2 ** n)


def normalize(theta: List[float]) -> List[float]:
    """Return the Euclidean-unit direction of theta."""
    norm = math.sqrt(sum(t * t for t in theta))
    if norm == 0.0:
        raise ValueError("zero vector has no direction")
    return [t / norm for t in theta]


def isotropic_constant(n: int, theta: List[float]) -> float:
    """E[<u,x>^2] for the unit direction u = theta/|theta|; the theorem says it is 1."""
    return expected_inner_sq(n, normalize(theta))
