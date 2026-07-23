from fractions import Fraction
from typing import List, Sequence, Tuple

Vector = Tuple[Fraction, ...]

def moment_vector(points: Sequence[Vector],
                  weights: Sequence[Fraction]) -> Vector:
    """Exact moment / Futaki vector M = sum_i w_i * p_i."""
    d = len(points[0])
    acc = [Fraction(0)] * d
    for p, w in zip(points, weights):
        for j in range(d):
            acc[j] += w * p[j]
    return tuple(acc)

def existence_test(points: Sequence[Vector],
                   weights: Sequence[Fraction]) -> Tuple[bool, Vector]:
    """Return (admits_KE, destabilizing_direction).

    admits_KE is True iff the moment vector is zero (barycenter at origin).
    When False, the returned vector xi = M satisfies Fut(xi) = <M,M> != 0,
    an explicit destabilizing direction. O(m*d) exact rational operations."""
    W = sum(weights, Fraction(0))
    if W == 0:
        raise ValueError("degenerate datum: total weight is zero")
    M = moment_vector(points, weights)
    balanced = all(m == 0 for m in M)
    return balanced, (tuple(Fraction(0) for _ in M) if balanced else M)
