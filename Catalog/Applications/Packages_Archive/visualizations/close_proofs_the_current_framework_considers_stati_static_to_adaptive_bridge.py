from __future__ import annotations
from typing import Callable, Dict, List, Sequence, Tuple, Union


class Leaf:
    pass


class Node:
    def __init__(self, query: Callable[[int], bool],
                 if_false: "Union[Node, Leaf]",
                 if_true: "Union[Node, Leaf]") -> None:
        self.query = query
        self.if_false = if_false
        self.if_true = if_true


def from_preds(preds: Sequence[Callable[[int], bool]]) -> "Union[Node, Leaf]":
    if not preds:
        return Leaf()
    sub = from_preds(preds[1:])
    return Node(preds[0], sub, sub)


def transcript(tree: "Union[Node, Leaf]", a: int) -> Tuple[bool, ...]:
    out: List[bool] = []
    node = tree
    while isinstance(node, Node):
        ans = node.query(a)
        out.append(ans)
        node = node.if_true if ans else node.if_false
    return tuple(out)


def tree_depth(tree: "Union[Node, Leaf]") -> int:
    if isinstance(tree, Leaf):
        return 0
    return 1 + max(tree_depth(tree.if_false), tree_depth(tree.if_true))


def adaptive_distinguishes(tree: "Union[Node, Leaf]",
                           elements: Sequence[int]) -> bool:
    seen: Dict[Tuple[bool, ...], int] = {}
    for a in elements:
        t = transcript(tree, a)
        if t in seen:
            return False
        seen[t] = a
    return True
