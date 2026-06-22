from typing import Dict, FrozenSet, Set, Tuple

Vertex = int
Graph = Tuple[FrozenSet[Vertex], FrozenSet[FrozenSet[Vertex]]]


def neighbors(G: Graph, v: Vertex) -> Set[Vertex]:
    V, E = G
    return {w for w in V if w != v and frozenset((v, w)) in E}


def greedy_independent_set(G: Graph, B: FrozenSet[Vertex]) -> Set[Vertex]:
    """Return an independent set inside B of size >= |B| / (Delta + 1)."""
    remaining: Set[Vertex] = set(B)
    chosen: Set[Vertex] = set()
    while remaining:
        v = min(remaining)            # any deterministic choice
        chosen.add(v)
        remaining -= {v} | neighbors(G, v)
    return chosen
