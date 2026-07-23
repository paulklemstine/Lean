from typing import Callable, Dict, Hashable, List, Tuple
from itertools import combinations

def single_linkage_dendrogram(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
) -> List[Tuple[float, Hashable, Hashable]]:
    """Single-linkage merge sequence = minimum spanning tree edges sorted by weight.
    Each returned (scale, p, q) is a merge event; the scale equals the bottleneck
    distance between the merged clusters. Over an ultrametric input these merge
    scales reconstruct the pairwise distances exactly (subdominant ultrametric)."""
    edges = sorted(
        ((dist(p, q), p, q) for p, q in combinations(points, 2)),
        key=lambda e: e[0],
    )
    parent: Dict[Hashable, Hashable] = {p: p for p in points}

    def find(p: Hashable) -> Hashable:
        while parent[p] != p:
            parent[p] = parent[parent[p]]
            p = parent[p]
        return p

    merges: List[Tuple[float, Hashable, Hashable]] = []
    for w, p, q in edges:
        rp, rq = find(p), find(q)
        if rp != rq:
            parent[rp] = rq
            merges.append((w, p, q))
        if len(merges) == len(points) - 1:
            break
    return merges
