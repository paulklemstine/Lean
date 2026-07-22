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
    """Return the underlying leaf-word of a parenthesization tree."""
    if isinstance(t, Leaf):
        return [t.label]
    return flatten(t.left) + flatten(t.right)
