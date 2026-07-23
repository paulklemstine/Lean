from __future__ import annotations
from dataclasses import dataclass
from typing import Generic, List, TypeVar, Union

K = TypeVar('K')

@dataclass(frozen=True)
class Leaf(Generic[K]):
    value: K

@dataclass(frozen=True)
class Node(Generic[K]):
    left: 'OpTree[K]'
    right: 'OpTree[K]'

OpTree = Union[Leaf, Node]

def rebalance(leaves: List[K]) -> OpTree:
    level: List[OpTree] = [Leaf(v) for v in leaves]
    while len(level) > 1:
        nxt: List[OpTree] = []
        for i in range(0, len(level), 2):
            if i + 1 < len(level):
                nxt.append(Node(level[i], level[i + 1]))
            else:
                nxt.append(level[i])
        level = nxt
    return level[0]
