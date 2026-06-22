from math import ceil, log2
from dataclasses import dataclass
from typing import Union


@dataclass
class Leaf:
    value: int


@dataclass
class Node:
    left: "OpTree"
    right: "OpTree"


OpTree = Union[Leaf, Node]


def height(t: OpTree) -> int:
    if isinstance(t, Leaf):
        return 0
    return max(height(t.left), height(t.right)) + 1


def num_leaves(t: OpTree) -> int:
    if isinstance(t, Leaf):
        return 1
    return num_leaves(t.left) + num_leaves(t.right)


def clog2(m: int) -> int:
    return 0 if m <= 1 else ceil(log2(m))


def certify_sandwich(t: OpTree) -> bool:
    """Verify the universal duality ceil(log2 numLeaves) <= height <= numLeaves - 1."""
    h: int = height(t)
    nl: int = num_leaves(t)
    return clog2(nl) <= h <= nl - 1
