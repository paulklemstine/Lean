import random
from itertools import combinations
from typing import Dict, Set, Tuple

Graph = Tuple[int, Dict[int, Set[int]]]

def random_K3bp1_free(n: int, b: int, seed: int = 0) -> Graph:
    """Return a random K_{3,b+1}-free graph: every triple keeps <= b common nbrs."""
    rng = random.Random(seed)
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    edges = list(combinations(range(n), 2)); rng.shuffle(edges)
    for u, v in edges:
        adj[u].add(v); adj[v].add(u)
        bad = any(len(adj[x] & adj[y] & adj[z]) > b
                  for x, y, z in combinations(range(n), 3)
                  if u in (x, y, z) or v in (x, y, z))
        if bad:
            adj[u].discard(v); adj[v].discard(u)
    return (n, adj)

if __name__ == "__main__":
    n, adj = random_K3bp1_free(10, 3, seed=1)
    print("edges:", sum(len(s) for s in adj.values()) // 2)
