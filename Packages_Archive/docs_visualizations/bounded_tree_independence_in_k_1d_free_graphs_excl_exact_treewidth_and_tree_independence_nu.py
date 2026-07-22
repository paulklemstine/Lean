from itertools import combinations, permutations
from typing import Dict, FrozenSet, List, Set, Tuple

Vertex = int
Graph = Tuple[FrozenSet[Vertex], FrozenSet[FrozenSet[Vertex]]]


def neighbors(G: Graph, v: Vertex) -> Set[Vertex]:
    V, E = G
    return {w for w in V if w != v and frozenset((v, w)) in E}


def induced_independence_number(G: Graph, B: FrozenSet[Vertex]) -> int:
    _, E = G
    Bl = list(B)
    for k in range(len(Bl), -1, -1):
        for s in combinations(Bl, k):
            if all(frozenset((u, w)) not in E for u, w in combinations(s, 2)):
                return k
    return 0


def _elimination_bags(G: Graph, order: Tuple[Vertex, ...]) -> List[FrozenSet[Vertex]]:
    V, _ = G
    adj: Dict[Vertex, Set[Vertex]] = {v: set(neighbors(G, v)) for v in V}
    alive: Set[Vertex] = set(V)
    bags: List[FrozenSet[Vertex]] = []
    for v in order:
        later = {w for w in adj[v] if w in alive}
        bags.append(frozenset({v} | later))
        for a, b in combinations(later, 2):
            adj[a].add(b); adj[b].add(a)
        alive.discard(v)
    return bags


def treewidth(G: Graph) -> int:
    Vl = list(G[0])
    if not Vl:
        return 0
    return min(max(len(b) for b in _elimination_bags(G, o)) - 1
               for o in permutations(Vl))


def tree_independence_number(G: Graph) -> int:
    Vl = list(G[0])
    if not Vl:
        return 0
    return min(max(induced_independence_number(G, b) for b in _elimination_bags(G, o))
               for o in permutations(Vl))
