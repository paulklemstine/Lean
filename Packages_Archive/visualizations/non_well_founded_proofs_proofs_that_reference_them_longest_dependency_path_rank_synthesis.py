from __future__ import annotations
from typing import Dict, List, Mapping

def construct_ranks(edges: Mapping[str, List[str]]) -> Dict[str, int]:
    state: Dict[str, int] = {v: 0 for v in edges}
    rank: Dict[str, int] = {}
    def visit(v: str) -> int:
        if state[v] == 1:
            raise ValueError("cycle prevents strict descent")
        if state[v] == 2:
            return rank[v]
        state[v] = 1
        children = edges[v]
        rank[v] = 0 if not children else 1 + max(visit(w) for w in children)
        state[v] = 2
        return rank[v]
    for vertex in edges:
        visit(vertex)
    return rank

if __name__ == "__main__":
    print(construct_ranks({"root": ["leaf"], "leaf": []}))
