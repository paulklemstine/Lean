from dataclasses import dataclass
from typing import Callable, List, Tuple, Union

Predicate = Callable[[int], bool]


@dataclass
class Nil:
    """Depth-0 adaptive system (leaf)."""


@dataclass
class Node:
    """Ask `pred`; branch into `if_false` / `if_true` on the answer."""
    pred: Predicate
    if_false: "AdaptiveObs"
    if_true: "AdaptiveObs"


AdaptiveObs = Union[Nil, Node]


def transcript(tree: AdaptiveObs, state: int) -> Tuple[bool, ...]:
    """The length-n answer transcript of `state` under the decision tree."""
    answers: List[bool] = []
    node: AdaptiveObs = tree
    while isinstance(node, Node):
        b = node.pred(state)
        answers.append(b)
        node = node.if_true if b else node.if_false
    return tuple(answers)
