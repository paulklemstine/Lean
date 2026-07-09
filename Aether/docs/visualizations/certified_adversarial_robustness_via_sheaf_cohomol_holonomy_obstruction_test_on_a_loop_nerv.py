from __future__ import annotations
from typing import List, Sequence
import math


def score(w: Sequence[float], x: Sequence[float]) -> float:
    """Linear score s_w(x) = sum_i w_i x_i."""
    return sum(wi * xi for wi, xi in zip(w, x))


def weight_l1(w: Sequence[float]) -> float:
    """Weight L1 norm = dual norm to L-infinity."""
    return sum(abs(wi) for wi in w)


def stalk_certified_radius(w: Sequence[float], x0: Sequence[float]) -> float:
    """Tight L-infinity certified radius R = |s_w(x0)| / ||w||_1."""
    margin = abs(score(w, x0))
    n1 = weight_l1(w)
    if n1 == 0.0:
        return math.inf if margin > 0.0 else 0.0
    return margin / n1


def tree_glue(g: Sequence[float]) -> List[float]:
    """Global potential f with delta^0 f = g on a path nerve (partial sums)."""
    f = [0.0]
    for gi in g:
        f.append(f[-1] + gi)
    return f


def holonomy(g: Sequence[float]) -> float:
    """Loop holonomy = sum of the 1-cochain around the cycle."""
    return sum(g)


def global_tree_certified(weights: Sequence[Sequence[float]],
                          refs: Sequence[Sequence[float]],
                          R: float) -> bool:
    """Uniform per-region margin test on a tree cover."""
    return all(weight_l1(w) * R < abs(score(w, x0))
               for w, x0 in zip(weights, refs))
