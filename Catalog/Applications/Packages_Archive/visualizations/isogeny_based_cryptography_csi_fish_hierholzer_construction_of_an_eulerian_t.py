from typing import List, Dict, Optional


def hierholzer(
    endpt1: List[int], endpt2: List[int], n_vertices: int
) -> Optional[List[int]]:
    """Construct an Eulerian trail (as a vertex sequence) if one exists,
    in O(E) time, via Hierholzer's algorithm.

    The parity identity deg(v) + s(v) + e(v) = 2 * vis(v) guarantees that a
    greedy walk can only get stuck at an odd-degree vertex (a valid endpoint),
    which is exactly what makes the detour-splicing step terminate correctly.

    Returns None if the multigraph fails the parity test (more than two odd
    vertices). Assumes the graph is connected on its non-isolated vertices.
    """
    E = len(endpt1)
    deg: List[int] = [0] * n_vertices
    adj: Dict[int, List[int]] = {v: [] for v in range(n_vertices)}
    for e in range(E):
        a, b = endpt1[e], endpt2[e]
        deg[a] += 1
        deg[b] += 1
        adj[a].append(e)
        adj[b].append(e)
    odd = [v for v in range(n_vertices) if deg[v] % 2 == 1]
    if len(odd) not in (0, 2):
        return None

    start = odd[0] if len(odd) == 2 else next(
        (v for v in range(n_vertices) if deg[v] > 0), 0)

    used = [False] * E
    ptr = {v: 0 for v in range(n_vertices)}
    stack = [start]
    trail: List[int] = []
    while stack:
        v = stack[-1]
        while ptr[v] < len(adj[v]) and used[adj[v][ptr[v]]]:
            ptr[v] += 1
        if ptr[v] == len(adj[v]):
            trail.append(v)
            stack.pop()
        else:
            e = adj[v][ptr[v]]
            used[e] = True
            w = endpt2[e] if endpt1[e] == v else endpt1[e]
            stack.append(w)
    trail.reverse()
    return trail if len(trail) == E + 1 else None
