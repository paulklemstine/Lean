from __future__ import annotations
from dataclasses import dataclass
from typing import TypeAlias
@dataclass(frozen=True)
class Leaf: named: bool = False
@dataclass(frozen=True)
class Unary: child: "Tree"
@dataclass(frozen=True)
class Binary: left: "Tree"; right: "Tree"
Tree: TypeAlias = Leaf | Unary | Binary

def statistics(t: Tree) -> tuple[int, int, int]:
    if isinstance(t, Leaf): return (1, 0, int(t.named))
    if isinstance(t, Unary):
        n, d, m = statistics(t.child); return (n + 1, d + 1, m)
    nl, dl, ml = statistics(t.left); nr, dr, mr = statistics(t.right)
    return (1 + nl + nr, 1 + max(dl, dr), ml + mr)

def audited_cost(t: Tree) -> int: return sum(statistics(t))
