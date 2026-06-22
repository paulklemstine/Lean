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


def mk_balanced(k: int, m: int) -> OpTree:
    """Median-split optimal combination tree with m >= 1 leaves and height ceil(log2 m)."""
    if m <= 1:
        return Leaf(k)
    top: int = (m + 1) // 2   # ceil(m/2)
    bot: int = m // 2         # floor(m/2)
    return Node(mk_balanced(k, top), mk_balanced(k, bot))


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


if __name__ == "__main__":
    for m in range(1, 17):
        t = mk_balanced(0, m)
        assert num_leaves(t) == m and height(t) == clog2(m)
    print("mkBalanced attains ceil(log2 m) for all m in [1,16]")
