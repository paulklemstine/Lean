from __future__ import annotations
from dataclasses import dataclass
from typing import List, Union


@dataclass(frozen=True)
class Leaf:
    label: str


@dataclass(frozen=True)
class Node:
    left: "Tree"
    right: "Tree"


Tree = Union[Leaf, Node]


def flatten(t: Tree) -> List[str]:
    if isinstance(t, Leaf):
        return [t.label]
    return flatten(t.left) + flatten(t.right)


def of_list(word: List[str]) -> Tree:
    """Canonical right-nested tree of a nonempty word."""
    node: Tree = Leaf(word[-1])
    for label in reversed(word[:-1]):
        node = Node(Leaf(label), node)
    return node


def normalize(t: Tree) -> Tree:
    """Transport a tree to its canonical right-nested normal form."""
    return of_list(flatten(t))
