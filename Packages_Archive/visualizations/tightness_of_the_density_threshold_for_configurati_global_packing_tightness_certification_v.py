from itertools import combinations
from math import comb
from typing import FrozenSet, List, Set, Tuple

Edge = FrozenSet[int]


def certify_global_tightness(n: int, r: int, edges: List[Edge]) -> dict:
    """Verify r-uniformity, linearity, and the packing equality m*C(r,2)=C(n,2).

    Returns a report dict including whether the family is a Steiner system,
    cross-validating Theorem 1: equality holds iff every pair is covered.
    """
    uniform: bool = all(len(e) == r for e in edges)
    linear: bool = all(len(a & b) <= 1 for a, b in combinations(edges, 2))
    covered: Set[Tuple[int, int]] = set()
    for e in edges:
        for p in combinations(sorted(e), 2):
            covered.add(p)
    universe: Set[Tuple[int, int]] = set(combinations(range(n), 2))
    lhs: int = len(edges) * comb(r, 2)
    rhs: int = comb(n, 2)
    equality: bool = (lhs == rhs)
    is_steiner: bool = linear and uniform and (covered == universe)
    return {
        "uniform": uniform,
        "linear": linear,
        "pairs_used": lhs,
        "pairs_available": rhs,
        "packing_equality": equality,
        "covers_all_pairs": covered == universe,
        "is_steiner": is_steiner,
        "theorem1_consistent": equality == (covered == universe and linear),
    }
