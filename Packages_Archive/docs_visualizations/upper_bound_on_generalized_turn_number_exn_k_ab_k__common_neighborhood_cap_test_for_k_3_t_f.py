from itertools import combinations
from typing import Dict, Set, Tuple

Graph = Tuple[int, Dict[int, Set[int]]]

def is_K3t_free(g: Graph, t: int) -> bool:
    """True iff G contains no K_{3,t}, i.e. every triple has < t common neighbors."""
    n, adj = g
    for x, y, z in combinations(range(n), 3):
        if len(adj[x] & adj[y] & adj[z]) >= t:
            return False
    return True

if __name__ == "__main__":
    adj = {v: set() for v in range(6)}
    for u in (0, 1, 2):
        for v in (3, 4, 5):
            adj[u].add(v); adj[v].add(u)
    g = (6, adj)
    print(is_K3t_free(g, 3))  # False (it is a K_{3,3})
    print(is_K3t_free(g, 4))  # True
