from itertools import combinations
from typing import Callable, FrozenSet, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
AdjPred = Callable[[Vertex, Vertex], bool]


def block_coloring(k: int, n: int) -> Tuple[int, Set[Edge], Set[Edge]]:
    """
    Extremal disjoint-clique coloring witnessing R(T_n, K_k) > (k-1)(n-1).

    Vertices 0..N-1 with N=(k-1)(n-1) are split into b=k-1 blocks of size
    s=n-1. An edge is RED iff its endpoints share a block, BLUE otherwise.
    Returns (N, red_edges, blue_edges).
    """
    s: int = n - 1
    b: int = k - 1
    N: int = b * s
    red: Set[Edge] = set()
    blue: Set[Edge] = set()
    for u, v in combinations(range(N), 2):
        if u // s == v // s:
            red.add(frozenset((u, v)))
        else:
            blue.add(frozenset((u, v)))
    return N, red, blue
