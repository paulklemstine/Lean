from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, List, Sequence, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Pair = Tuple[Vertex, Vertex]


def classify_linear_hypergraph(
    edges: List[Edge], r: int, vertices: Sequence[Vertex]
) -> Dict[str, object]:
    """
    Verify uniformity, linearity, and the Steiner property of a hypergraph by
    a single pass over all edge-pairs, building the pair-multiplicity table.

    Returns a dictionary reporting each predicate together with the two sides
    of the density threshold m*C(r,2) <= C(n,2) and whether equality holds.

    Complexity: O(m * r^2) time to enumerate all per-edge pairs, O(C(n,2))
    auxiliary space for the multiplicity table.
    """
    n: int = len(vertices)
    m: int = len(edges)

    uniform: bool = all(len(e) == r for e in edges)

    multiplicity: Dict[Pair, int] = {}
    for e in edges:
        for p in combinations(sorted(e), 2):
            key: Pair = (p[0], p[1])
            multiplicity[key] = multiplicity.get(key, 0) + 1

    linear: bool = all(c <= 1 for c in multiplicity.values())

    universe = {(a, b) for a, b in combinations(sorted(vertices), 2)}
    covers_all: bool = universe <= set(multiplicity.keys())

    steiner: bool = uniform and linear and covers_all

    lhs: int = m * comb(r, 2)
    rhs: int = comb(n, 2)

    return {
        "n": n,
        "m": m,
        "r": r,
        "uniform": uniform,
        "linear": linear,
        "covers_all_pairs": covers_all,
        "steiner": steiner,
        "lhs_m_choose": lhs,
        "rhs_n_choose": rhs,
        "threshold_holds": lhs <= rhs,
        "equality": lhs == rhs,
        "max_edges_floor": rhs // comb(r, 2),
    }
