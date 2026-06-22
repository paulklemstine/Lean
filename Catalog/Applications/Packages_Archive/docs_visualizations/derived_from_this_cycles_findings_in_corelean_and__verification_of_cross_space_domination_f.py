from __future__ import annotations
import itertools, math
from typing import Callable, Sequence, Tuple

Point = Tuple[float, ...]

def euclidean(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))

def verify_domination(alpha: Sequence[Point],
                      beta: Sequence[Point],
                      f_index: Sequence[int],
                      scales: Sequence[float],
                      dist: Callable[[Point, Point], float] = euclidean) -> bool:
    """Check the hypotheses and conclusion of the domination theorem.

    Verifies (1) f is injective (distinct indices), (2) f is nonexpanding, and
    (3) E_alpha(r) <= E_beta(r) for every r. Returns True iff a valid instance.
    Complexity: O(n^2) for the nonexpansion check, O((|alpha|^2 + |beta|^2) * |scales|)
    for the edge-count comparison (or O(.. log ..) with sorted distances).
    """
    if len(set(f_index)) != len(f_index):
        return False  # f not injective
    nonexp = all(dist(beta[f_index[i]], beta[f_index[j]]) <= dist(alpha[i], alpha[j])
                 for i, j in itertools.combinations(range(len(alpha)), 2))
    if not nonexp:
        return False
    def ec(P: Sequence[Point], r: float) -> int:
        n = len(P)
        return sum(1 for i in range(n) for j in range(i + 1, n)
                   if dist(P[i], P[j]) <= r)
    return all(ec(alpha, r) <= ec(beta, r) for r in scales)
