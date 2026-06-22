from itertools import combinations
from typing import Callable, Hashable, List, Sequence, Set, FrozenSet, Tuple

Vertex = Hashable

def vietoris_rips_filtration(
        vertices: Sequence[Vertex],
        d: Callable[[Vertex, Vertex], float],
        scales: Sequence[float]
) -> List[Tuple[float, Set[FrozenSet[Vertex]]]]:
    """Build the nested Vietoris-Rips complexes at an increasing list of scales.

    At each scale eps we threshold the dissimilarity symmetrically to form the
    proximity graph, then take its clique complex. By the monotonicity theorem the
    returned face sets are nested: faces[i] subset faces[i+1]."""
    result: List[Tuple[float, Set[FrozenSet[Vertex]]]] = []
    for eps in sorted(scales):
        edges = [(u, v) for u, v in combinations(vertices, 2)
                 if d(u, v) <= eps and d(v, u) <= eps]
        adj = {frozenset(e) for e in edges}
        faces: Set[FrozenSet[Vertex]] = {frozenset()}
        for k in range(1, len(vertices) + 1):
            for combo in combinations(vertices, k):
                if all(frozenset((u, v)) in adj for u, v in combinations(combo, 2)):
                    faces.add(frozenset(combo))
        result.append((eps, faces))
    return result
