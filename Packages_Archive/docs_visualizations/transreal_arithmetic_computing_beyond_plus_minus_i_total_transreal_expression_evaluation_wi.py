from __future__ import annotations
from dataclasses import dataclass
from typing import Union
from demo import TReal  # reference transreal arithmetic

Expr = Union["Bin", "Un", "Leaf"]

@dataclass
class Leaf:
    val: TReal

@dataclass
class Un:
    op: str          # "neg" or "recip"
    a: "Expr"

@dataclass
class Bin:
    op: str          # "+" or "*" or "/"
    a: "Expr"
    b: "Expr"


def evaluate(e: "Expr") -> TReal:
    """Bottom-up evaluation with Phi short-circuiting."""
    if isinstance(e, Leaf):
        return e.val
    if isinstance(e, Un):
        v = evaluate(e.a)
        return -v if e.op == "neg" else v.recip()
    # Bin
    a = evaluate(e.a)
    # Phi short-circuit: any Phi operand poisons + and *
    from demo import Kind
    if a.kind == Kind.PHI and e.op in ("+", "*"):
        return TReal.phi()
    b = evaluate(e.b)
    if e.op == "+":
        return a + b
    if e.op == "*":
        return a * b
    return a / b
