from typing import List, Optional

Matrix = List[List[bool]]

def find_sink_transitive(adj: Matrix) -> Optional[int]:
    """Find a sink in a transitive oriented graph (a Seymour vertex).

    A transitive asymmetric relation is a strict order; a minimal element of
    the reversed relation is a sink. Runs in O(n^2).
    """
    n: int = len(adj)
    for v in range(n):
        if not any(adj[v][w] for w in range(n)):
            return v
    return None
