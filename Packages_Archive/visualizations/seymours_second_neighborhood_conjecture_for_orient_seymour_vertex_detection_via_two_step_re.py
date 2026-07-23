from typing import List, Set

Matrix = List[List[bool]]

def detect_seymour_vertex(adj: Matrix) -> int:
    """Return a Seymour vertex index, or -1 if none exists.

    Computes one-step and two-step reachability via Boolean matrix
    reasoning; runs in O(n^3) time for n vertices.
    """
    n: int = len(adj)
    for v in range(n):
        first: Set[int] = {w for w in range(n) if adj[v][w]}
        two_step: Set[int] = set()
        for x in first:
            for w in range(n):
                if adj[x][w]:
                    two_step.add(w)
        second: Set[int] = {w for w in two_step if w != v and w not in first}
        if len(first) <= len(second):
            return v
    return -1
