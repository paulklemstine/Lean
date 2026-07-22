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


def all_bracketings(word: List[str]) -> List[Tree]:
    """Enumerate every parenthesization tree with the given (nonempty) leaf-word."""
    if len(word) == 1:
        return [Leaf(word[0])]
    out: List[Tree] = []
    for i in range(1, len(word)):
        for left in all_bracketings(word[:i]):
            for right in all_bracketings(word[i:]):
                out.append(Node(left, right))
    return out
