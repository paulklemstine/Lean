from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Generic, TypeVar, Union

K = TypeVar('K')

@dataclass(frozen=True)
class Leaf(Generic[K]):
    value: K

@dataclass(frozen=True)
class Node(Generic[K]):
    left: 'OpTree[K]'
    right: 'OpTree[K]'

OpTree = Union[Leaf, Node]

def evaluate(t: OpTree, op: Callable[[K, K], K]) -> K:
    if isinstance(t, Leaf):
        return t.value
    return op(evaluate(t.left, op), evaluate(t.right, op))

def height(t: OpTree) -> int:
    if isinstance(t, Leaf):
        return 0
    return max(height(t.left), height(t.right)) + 1

def unit_cost_add(x: int, y: int) -> int:
    return max(x, y) + 1
