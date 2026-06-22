from dataclasses import dataclass
from typing import Callable, Union


@dataclass
class Leaf:
    value: int


@dataclass
class Node:
    left: "OpTree"
    right: "OpTree"


OpTree = Union[Leaf, Node]


def evaluate(add: Callable[[int, int], int], t: OpTree) -> int:
    """Fold a combination tree under a binary operation `add`."""
    if isinstance(t, Leaf):
        return t.value
    return add(evaluate(add, t.left), evaluate(add, t.right))


def cost_add(c: int) -> Callable[[int, int], int]:
    """The cost-c combining operation max(x, y) + c (c = 1 is the unit-cost law)."""
    return lambda x, y: max(x, y) + c
