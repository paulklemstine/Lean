from itertools import combinations
from typing import Dict, FrozenSet, List, Optional, Sequence, Set, Tuple

Graph = Dict[int, Set[int]]
Clique = FrozenSet[int]


def is_clique(g: Graph, s: Sequence[int]) -> bool:
    return all(v in g[u] for u, v in combinations(s, 2))


def maximal_cliques(g: Graph) -> List[Clique]:
    verts = list(g)
    out: List[Clique] = []
    for r in range(1, len(verts) + 1):
        for combo in combinations(verts, r):
            if is_clique(g, combo) and all(
                not is_clique(g, tuple(combo) + (w,))
                for w in verts if w not in combo
            ):
                out.append(frozenset(combo))
    return out


def find_bad_triple(
    cliques: Sequence[Clique],
) -> Optional[Tuple[Clique, Clique, Clique]]:
    """Return a bad triple (pairwise intersecting, empty total overlap)
    among the maximal cliques, or None. A found triple certifies BOTH
    non-balancedness and non-clique-Helly-ness."""
    for k0, k1, k2 in combinations(cliques, 3):
        if (k0 & k1) and (k0 & k2) and (k1 & k2) and not (k0 & k1 & k2):
            return (k0, k1, k2)
    return None


def certify(g: Graph) -> Optional[Tuple[Clique, Clique, Clique]]:
    return find_bad_triple(maximal_cliques(g))
