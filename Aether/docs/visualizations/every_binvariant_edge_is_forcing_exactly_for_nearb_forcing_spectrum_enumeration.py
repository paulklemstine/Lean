from __future__ import annotations
from typing import FrozenSet, List, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[Set[int], Set[Edge]]


def forcing_spectrum(g: Graph,
                     is_forcing_edge) -> List[Edge]:
    """Return every forcing edge of g by applying the deletion test edge by edge.

    `is_forcing_edge(g, u, v)` is the per-edge oracle from Algorithm A.
    """
    out: List[Edge] = []
    for e in g[1]:
        u, v = tuple(e)
        if is_forcing_edge(g, u, v):
            out.append(e)
    return out


def forcing_fraction(g: Graph, is_forcing_edge) -> float:
    """Fraction of edges that are forcing (a graph invariant)."""
    E = g[1]
    if not E:
        return 0.0
    return len(forcing_spectrum(g, is_forcing_edge)) / len(E)
