from dataclasses import dataclass
from typing import List, Union


@dataclass(frozen=True)
class Leaf:
    value: int


@dataclass(frozen=True)
class Node:
    left: "PTree"
    right: "PTree"


PTree = Union[Leaf, Node]


def depth(t: PTree) -> int:
    if isinstance(t, Leaf):
        return 0
    return 1 + max(depth(t.left), depth(t.right))


def compose(t1: PTree, t2: PTree) -> PTree:
    """Binary composition: a Merkle join of two proofs."""
    return Node(t1, t2)


def chain(ts: List[PTree]) -> PTree:
    """Right-leaning sequential composition of a list of proofs.

    chain([]) = Leaf(0); chain([t]) = t; chain(t :: ts) = compose(t, chain ts).
    The resulting depth obeys depth(chain ts) <= sum(depth ti) + len(ts), so the
    certificate length is subadditive up to a +k overhead (k = len(ts)).
    Cost: O(len(ts)) joins.
    """
    if len(ts) == 0:
        return Leaf(0)
    if len(ts) == 1:
        return ts[0]
    return compose(ts[0], chain(ts[1:]))
