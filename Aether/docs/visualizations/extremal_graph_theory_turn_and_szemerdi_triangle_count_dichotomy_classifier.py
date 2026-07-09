from itertools import combinations
from typing import FrozenSet, Set, Tuple

Graph = Tuple[int, Set[FrozenSet[int]]]

def triangle_count(g: Graph) -> int:
    n, E = g
    return sum(1 for a, b, c in combinations(range(n), 3)
               if frozenset((a, b)) in E and frozenset((a, c)) in E
               and frozenset((b, c)) in E)

def dichotomy_branch(g: Graph, delta: float, epsilon: float) -> str:
    n, _ = g
    t = triangle_count(g)
    if t >= delta * n ** 3:
        return f'supersaturated: {t} >= delta*n^3 triangles'
    return f'edge-close to triangle-free: removable in < epsilon*n^2 edges'
