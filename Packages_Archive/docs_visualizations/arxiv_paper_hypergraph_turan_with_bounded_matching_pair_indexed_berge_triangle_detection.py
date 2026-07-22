from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Iterable, Optional, Tuple
Vertex = str
Edge = FrozenSet[Vertex]
def find_berge_triangle(vertices: Iterable[Vertex], edges: Iterable[Edge]) -> Optional[Tuple[Vertex, Vertex, Vertex]]:
    vv, ee = tuple(vertices), tuple(edges)
    for a, b, c in combinations(vv, 3):
        lists = [[e for e in ee if pair <= e] for pair in (frozenset((a,b)), frozenset((b,c)), frozenset((c,a)))]
        if any(e1 != e2 and e2 != e3 and e3 != e1 for e1 in lists[0] for e2 in lists[1] for e3 in lists[2]):
            return a, b, c
    return None
if __name__ == "__main__":
    s, t = 3, 5
    vertices = [f"p{i}_{b}" for i in range(s) for b in (0,1)] + [f"x{j}" for j in range(t)]
    edges = [frozenset((f"p{i}_0", f"p{i}_1", f"x{j}")) for i in range(s) for j in range(t)]
    print(find_berge_triangle(vertices, edges))
