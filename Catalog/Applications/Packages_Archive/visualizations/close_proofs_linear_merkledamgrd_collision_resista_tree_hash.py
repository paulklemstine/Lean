from typing import Callable, Union

class Leaf:
    def __init__(self, value: int) -> None:
        self.value = value

class Node:
    def __init__(self, left: "Tree", right: "Tree") -> None:
        self.left = left
        self.right = right

Tree = Union[Leaf, Node]

def tree_hash(leaf_map: Callable[[int], int],
              combine: Callable[[int, int], int], t: Tree) -> int:
    """Bottom-up Merkle-tree hash."""
    if isinstance(t, Leaf):
        return leaf_map(t.value)
    return combine(tree_hash(leaf_map, combine, t.left),
                   tree_hash(leaf_map, combine, t.right))
