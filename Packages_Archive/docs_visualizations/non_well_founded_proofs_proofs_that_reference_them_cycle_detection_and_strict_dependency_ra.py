from typing import Dict, Hashable, List, Optional, Set, Tuple, TypeVar
N = TypeVar("N", bound=Hashable)

def rank_dependencies(graph: Dict[N, Set[N]]) -> Tuple[bool, Optional[Dict[N, int]]]:
    nodes = set(graph)
    for targets in graph.values(): nodes.update(targets)
    state: Dict[N, int] = {v: 0 for v in nodes}
    rank: Dict[N, int] = {}
    def visit(v: N) -> bool:
        if state[v] == 1: return False
        if state[v] == 2: return True
        state[v] = 1
        if not all(visit(w) for w in graph.get(v, set())): return False
        state[v] = 2
        rank[v] = 0 if not graph.get(v, set()) else 1 + max(rank[w] for w in graph[v])
        return True
    return (True, rank) if all(visit(v) for v in nodes) else (False, None)
