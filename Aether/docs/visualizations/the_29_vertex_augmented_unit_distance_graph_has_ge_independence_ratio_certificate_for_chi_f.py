from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


def independence_number(g: Graph) -> int:
    """Maximum size of an independent set via branch and bound."""
    verts = sorted(g)
    n = len(verts)
    best = 0

    def expand(idx: int, chosen: List[Vertex]) -> None:
        nonlocal best
        if len(chosen) + (n - idx) <= best:
            return
        if idx == n:
            best = max(best, len(chosen))
            return
        v = verts[idx]
        if all(v not in g[c] for c in chosen):
            expand(idx + 1, chosen + [v])
        expand(idx + 1, chosen)

    expand(0, [])
    return best


def certify_chi_f_above_four(g: Graph) -> Tuple[bool, Fraction]:
    """Return (certified, lower_bound) where certified is True iff
    4 * alpha(G) < |V|, and lower_bound = |V| / alpha(G) >= chi_f(G)."""
    alpha = independence_number(g)
    n = len(g)
    lower_bound = Fraction(n, alpha)
    return (4 * alpha < n, lower_bound)
