from functools import lru_cache
from typing import List, Optional, Tuple

BinTree = Optional[Tuple["BinTree", "BinTree"]]  # None = leaf


@lru_cache(maxsize=None)
def trees_of_num_nodes_eq(n: int) -> Tuple[BinTree, ...]:
    """Enumerate every binary tree with exactly n internal nodes. An internal
    node distributes the remaining n-1 nodes between left and right subtrees.
    The count equals the Catalan number C_n ~ 4^n / n^(3/2)."""
    if n == 0:
        return (None,)
    trees: List[BinTree] = []
    for a in range(n):
        b = n - 1 - a
        for left in trees_of_num_nodes_eq(a):
            for right in trees_of_num_nodes_eq(b):
                trees.append((left, right))
    return tuple(trees)


def triangulations_of_polygon(m: int) -> Tuple[BinTree, ...]:
    """Triangulations of a convex m-gon as binary trees with m-2 internal nodes
    (the dual-tree model). Count = Catalan(m-2)."""
    return trees_of_num_nodes_eq(m - 2)
