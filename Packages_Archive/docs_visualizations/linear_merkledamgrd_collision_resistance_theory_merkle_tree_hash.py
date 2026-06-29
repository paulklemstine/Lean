from dataclasses import dataclass
from typing import Callable, Generic, TypeVar, Union
A = TypeVar('A'); G = TypeVar('G')

@dataclass(frozen=True)
class Leaf(Generic[G]):
    value: G

@dataclass(frozen=True)
class Node(Generic[G]):
    left: 'BTree'
    right: 'BTree'

BTree = Union[Leaf, Node]

def tree_hash(g: Callable[[G], A], h: Callable[[A, A], A], t: BTree) -> A:
    """treeHash g h (Definition 7.2)."""
    if isinstance(t, Leaf):
        return g(t.value)
    return h(tree_hash(g, h, t.left), tree_hash(g, h, t.right))
