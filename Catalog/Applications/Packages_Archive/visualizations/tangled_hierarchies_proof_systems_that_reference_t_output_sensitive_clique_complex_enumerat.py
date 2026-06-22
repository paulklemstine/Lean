from itertools import combinations
from typing import FrozenSet, List, Set, Tuple

Vertex = int
Face = FrozenSet[Vertex]


def clique_complex(vertices: Set[Vertex],
                   edges: Set[FrozenSet[Vertex]]) -> Set[Face]:
    """
    Enumerate every face of the clique complex of a simple graph.

    A face is a finite clique: a vertex set all of whose distinct pairs are
    edges. We grow cliques from the empty set, extending each clique C by any
    vertex adjacent to *all* members of C, which guarantees downward closure
    and avoids generating non-cliques. Output is exponential in |V| in the
    worst case (the complete graph yields 2^|V| faces), so the routine is
    output-sensitive.
    """
    def adj(a: Vertex, b: Vertex) -> bool:
        return a != b and frozenset((a, b)) in edges

    faces: Set[Face] = {frozenset()}
    frontier: List[Tuple[Face, List[Vertex]]] = [(frozenset(), sorted(vertices))]
    while frontier:
        clique, candidates = frontier.pop()
        for i, v in enumerate(candidates):
            new_clique = clique | {v}
            faces.add(new_clique)
            # candidates for further extension: later vertices adjacent to all
            new_candidates = [u for u in candidates[i + 1:]
                              if all(adj(u, w) for w in new_clique)]
            if new_candidates:
                frontier.append((new_clique, new_candidates))
    return faces
