from itertools import permutations
from typing import Callable, FrozenSet, Set

Vertex = int
Edge = FrozenSet[Vertex]
AdjPred = Callable[[Vertex, Vertex], bool]


def contains_copy(n_small: int, edges_small: Set[Edge],
                  n_big: int, adj_big: AdjPred) -> bool:
    """
    Decide whether the small graph (n_small vertices, edges_small) embeds
    into the big graph on range(n_big) given by adjacency predicate adj_big.

    An embedding is an injection f with (x,y) in edges_small implying
    adj_big(f(x), f(y)). Brute-force over injections; complexity
    O(n_big!/(n_big-n_small)! * |edges_small|). Used for small verification.
    """
    for f in permutations(range(n_big), n_small):
        if all(adj_big(f[tuple(e)[0]], f[tuple(e)[1]]) for e in edges_small):
            return True
    return False
