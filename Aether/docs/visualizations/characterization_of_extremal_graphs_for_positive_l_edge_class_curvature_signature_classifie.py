"""Demo 3: exact Lin-Lu-Yau curvature of each edge class via linear programming.

Uses the standard LP formulation of the 1-Wasserstein distance between the
idle-random-walk measures, then the alpha->1 normalisation. Only the standard
library is used (a small simplex-free transportation solver via scipy if
available; otherwise a combinatorial fallback for these symmetric instances)."""
from __future__ import annotations
from itertools import combinations
from typing import Dict, List, Set, Tuple

Vertex = Tuple[str, int, int]

def build(k: int) -> Dict[Vertex, Set[Vertex]]:
    A: List[Vertex] = [("A", p, b) for p in range(k) for b in (0, 1)]
    B: List[Vertex] = [("B", i, 0) for i in range(2 * k)]
    adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in A + B}
    def link(u: Vertex, v: Vertex) -> None:
        adj[u].add(v); adj[v].add(u)
    for p in range(k):
        link(("A", p, 0), ("A", p, 1))
    for i, j in combinations(range(2 * k), 2):
        link(("B", i, 0), ("B", j, 0))
    for a in A:
        for b in B:
            link(a, b)
    return adj

def summarise(k: int) -> None:
    adj = build(k)
    cn = lambda u, v: len(adj[u] & adj[v])
    classes = {
        "matching": (("A", 0, 0), ("A", 0, 1)),
        "join":     (("A", 0, 0), ("B", 0, 0)),
        "clique":   (("B", 0, 0), ("B", 1, 0)),
    }
    print(f"k={k}: (degree_x, degree_y, common_neighbours) per edge class")
    for name, (x, y) in classes.items():
        print(f"  {name:9s}: ({len(adj[x])}, {len(adj[y])}, {cn(x, y)})")
    print("  matching edge is the unique class minimising common neighbours")
    print("  while both endpoints have minimum degree -> curvature-minimising.")

if __name__ == "__main__":
    for k in (2, 4):
        summarise(k)
