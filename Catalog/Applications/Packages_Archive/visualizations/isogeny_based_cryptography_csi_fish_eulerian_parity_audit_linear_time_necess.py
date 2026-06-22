from typing import List, Set, Tuple


def eulerian_parity_audit(
    endpt1: List[int], endpt2: List[int], n_vertices: int
) -> Tuple[str, Set[int]]:
    """Decide, in O(E + V) time, the necessary parity condition for an
    Eulerian trail in a finite undirected multigraph with loops.

    A loop (endpt1[e] == endpt2[e]) automatically contributes 2 to its
    vertex's degree because both endpoint slots increment the same index.

    Returns a verdict string and the set of odd-degree vertices.
    """
    deg: List[int] = [0] * n_vertices
    for e in range(len(endpt1)):
        deg[endpt1[e]] += 1
        deg[endpt2[e]] += 1          # loop hits the same index twice
    odd: Set[int] = {v for v in range(n_vertices) if deg[v] % 2 == 1}
    if len(odd) == 0:
        return ("closed Eulerian trail possible (all even degrees)", odd)
    if len(odd) == 2:
        return ("open Eulerian trail possible; endpoints are the odd vertices", odd)
    return ("no Eulerian trail exists (more than two odd-degree vertices)", odd)
