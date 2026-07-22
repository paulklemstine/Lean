from __future__ import annotations
from typing import FrozenSet, Tuple
Vertex = str
Edge = FrozenSet[Vertex]
def pair_star(s: int, t: int) -> Tuple[Tuple[Vertex, ...], Tuple[Edge, ...]]:
    if s < 0 or t < 0:
        raise ValueError("parameters must be nonnegative")
    vertices = tuple([f"p{i}_{b}" for i in range(s) for b in (0, 1)] + [f"x{j}" for j in range(t)])
    edges = tuple(frozenset((f"p{i}_0", f"p{i}_1", f"x{j}")) for i in range(s) for j in range(t))
    return vertices, edges
if __name__ == "__main__":
    vertices, edges = pair_star(3, 6)
    print(len(vertices), len(edges), all(len(e) == 3 for e in edges))
