from dataclasses import dataclass
from typing import Optional

@dataclass
class Expr:
    op: str                         # 'leaf' | 'add' | 'mul'
    left: Optional["Expr"] = None
    right: Optional["Expr"] = None

def vdepth(e: Expr) -> int:
    """Valuation depth of an arithmetic expression under the unit-cost law
    depth(x # y) = max(depth x, depth y) + 1, with leaves of depth 0.

    Complexity: O(size of tree), one pass with the tropical (max,+) recurrence."""
    if e.op == "leaf":
        return 0
    assert e.left is not None and e.right is not None
    return max(vdepth(e.left), vdepth(e.right)) + 1

def num_leaves(e: Expr) -> int:
    if e.op == "leaf":
        return 1
    assert e.left is not None and e.right is not None
    return num_leaves(e.left) + num_leaves(e.right)
