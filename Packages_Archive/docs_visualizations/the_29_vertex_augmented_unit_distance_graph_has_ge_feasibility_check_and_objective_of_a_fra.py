from fractions import Fraction
from typing import Dict, FrozenSet, Set

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


def is_independent(g: Graph, s: FrozenSet[Vertex]) -> bool:
    verts = list(s)
    for i in range(len(verts)):
        for j in range(i + 1, len(verts)):
            if verts[j] in g[verts[i]]:
                return False
    return True


def feasible_and_objective(
    g: Graph, weights: Dict[FrozenSet[Vertex], Fraction]
) -> tuple[bool, Fraction]:
    """Verify a candidate fractional coloring and return its objective.

    Returns (feasible, total). Feasible requires: nonnegative weights,
    positive weight only on independent sets, and every vertex covered to
    level at least 1. `total` is an explicit upper bound on chi_f(G)."""
    for s, w in weights.items():
        if w < 0:
            return (False, Fraction(0))
        if w > 0 and not is_independent(g, s):
            return (False, Fraction(0))
    for v in g:
        cover = sum((w for s, w in weights.items() if v in s), Fraction(0))
        if cover < 1:
            return (False, Fraction(0))
    return (True, sum(weights.values(), Fraction(0)))
