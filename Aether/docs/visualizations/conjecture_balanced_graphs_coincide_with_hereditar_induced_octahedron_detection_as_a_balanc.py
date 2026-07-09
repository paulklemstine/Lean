from __future__ import annotations
from itertools import combinations
from typing import Dict, List, Optional, Set, Tuple

Graph = Dict[int, Set[int]]


def induced_is_octahedron(graph: Graph, six: Tuple[int, ...]) -> bool:
    """Return True iff the 6 vertices induce K_{2,2,2}.

    The octahedron is the unique 3-regular graph on six vertices equal to the
    complement of a perfect matching: each vertex is non-adjacent to exactly one
    other (its "antipode") and adjacent to the remaining four.
    """
    s = set(six)
    for v in six:
        nbrs_in = graph[v] & s
        if len(nbrs_in) != 4:           # must miss exactly one partner
            return False
    return True


def find_induced_octahedron(graph: Graph) -> Optional[Tuple[int, ...]]:
    """Search all 6-subsets for an induced octahedron; O(n^6) worst case."""
    verts = sorted(graph)
    for six in combinations(verts, 6):
        if induced_is_octahedron(graph, six):
            return six
    return None


def is_octahedron_free(graph: Graph) -> bool:
    """Conjectured certificate: balanced clique matrix iff octahedron-free."""
    return find_induced_octahedron(graph) is None
