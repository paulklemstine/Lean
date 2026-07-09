from itertools import combinations
from typing import Dict, List, Set, Tuple

Graph = Tuple[Set[int], Dict[int, Set[int]]]

def make_graph(vertices, edges) -> Graph:
    V: Set[int] = set(vertices)
    adj: Dict[int, Set[int]] = {v: set() for v in V}
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    return V, adj

def degree(g: Graph, i: int) -> int:
    return len(g[1][i])

def deg_in(g: Graph, S: Set[int], i: int) -> int:
    return sum(1 for j in g[1][i] if j in S)

def is_dominant_by_criterion(g: Graph, D: Set[int]) -> bool:
    """Whole-diagram criterion: for all i in D, deg(i) + deg_D(i) >= 2."""
    return all(degree(g, i) + deg_in(g, D, i) >= 2 for i in D)

def singleton_profile(graph: Graph):
    """Vertices carrying a dominant singleton, plus cycle/tree verdict (connected G)."""
    V = graph[0]
    accepted = sorted(v for v in V if degree(graph, v) >= 2)
    has_cycle = (len(accepted) == len(V))
    return accepted, has_cycle, (not has_cycle)
