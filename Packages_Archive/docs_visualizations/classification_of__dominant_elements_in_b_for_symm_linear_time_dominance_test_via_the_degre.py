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

def is_dominant(graph: Graph, D: Set[int]) -> bool:
    """Test dominance of lambda_{D,V} using the degree-sum criterion."""
    return is_dominant_by_criterion(graph, D)
