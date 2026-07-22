"""Demo 1: full exact local profile of the matching-clique join H(k)."""
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

def profile(k: int) -> None:
    adj = build(k)
    deg_A = len(adj[("A", 0, 0)])
    deg_B = len(adj[("B", 0, 0)])
    edges = sum(len(s) for s in adj.values()) // 2
    cn = lambda u, v: len(adj[u] & adj[v])
    print(f"k={k}: deg_A={deg_A}=2k+1, deg_B={deg_B}=4k-1, |E|={edges}=6k^2")
    print(f"       common(matching)={cn(('A',0,0),('A',0,1))}=2k, "
          f"common(join)={cn(('A',0,0),('B',0,0))}=2k, "
          f"common(clique)={cn(('B',0,0),('B',1,0))}=4k-2")

if __name__ == "__main__":
    for k in (2, 3, 5, 8):
        profile(k)
