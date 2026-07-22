from dataclasses import dataclass
from typing import Callable, List, Union


@dataclass(frozen=True)
class Leaf:
    value: int


@dataclass(frozen=True)
class Node:
    left: "PTree"
    right: "PTree"


PTree = Union[Leaf, Node]
Hash = Callable[[int, int], int]


def merkle_root(h: Hash, t: PTree) -> int:
    """Compute the Merkle root of a proof tree under binary hash h.

    Post-order traversal: a leaf returns its own digest; an internal node
    returns h(root(left), root(right)). Cost: O(n) hash evaluations for n
    leaves, O(depth) recursion stack.
    """
    if isinstance(t, Leaf):
        return t.value
    return h(merkle_root(h, t.left), merkle_root(h, t.right))
