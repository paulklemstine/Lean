from __future__ import annotations
from dataclasses import dataclass
from typing import TypeAlias
@dataclass(frozen=True)
class Hyp: formula: str
@dataclass(frozen=True)
class Named: name: str; formula: str
@dataclass(frozen=True)
class Restate: formula: str; child: "Tree"
@dataclass(frozen=True)
class MP: formula: str; left: "Tree"; right: "Tree"
Tree: TypeAlias = Hyp | Named | Restate | MP

def conclusion(t: Tree) -> str:
    return t.formula

def strip(t: Tree) -> Tree:
    return t.child if isinstance(t, Restate) else t

def normalize(t: Tree) -> Tree:
    if isinstance(t, Hyp): return t
    if isinstance(t, Named): return Hyp(t.formula)
    if isinstance(t, MP): return MP(t.formula, strip(normalize(t.left)), strip(normalize(t.right)))
    child = normalize(t.child)
    return child if conclusion(child) == t.formula else Restate(t.formula, child)
