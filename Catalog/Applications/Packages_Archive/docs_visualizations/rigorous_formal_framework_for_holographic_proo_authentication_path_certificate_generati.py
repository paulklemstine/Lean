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
    if isinstance(t, Leaf):
        return t.value
    return h(merkle_root(h, t.left), merkle_root(h, t.right))


def auth_path(h: Hash, t: PTree, p: List[bool]) -> List[int]:
    """Generate the authentication path (certificate) for the leaf addressed
    by path p (False = left, True = right).

    At each internal node we emit the root of the *sibling* branch (the one not
    taken) and descend into the chosen branch. The result has one entry per
    level, i.e. length = length of p. Cost: O(depth) entries; recomputing
    sibling roots naively costs O(n), or O(depth) per query after caching all
    subtree roots in an O(n) preprocessing pass.
    """
    if isinstance(t, Leaf):
        return []
    if p[0] is False:
        return [merkle_root(h, t.right)] + auth_path(h, t.left, p[1:])
    return [merkle_root(h, t.left)] + auth_path(h, t.right, p[1:])
