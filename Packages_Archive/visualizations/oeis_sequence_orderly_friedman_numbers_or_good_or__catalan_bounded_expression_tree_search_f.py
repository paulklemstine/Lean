from __future__ import annotations
from dataclasses import dataclass
from typing import Iterator, List, Optional, Union

OPS = ("add", "mul", "pow")
POW_CAP = 10 ** 9


def op_apply(op: str, a: int, b: int) -> Optional[int]:
    if op == "add":
        return a + b
    if op == "mul":
        return a * b
    e = max(b, 0)
    if abs(a) > 1 and e > 64:
        return None
    v = a ** e
    return None if abs(v) > POW_CAP else v


@dataclass(frozen=True)
class Lit:
    d: int


@dataclass(frozen=True)
class Neg:
    e: "Expr"


@dataclass(frozen=True)
class Bin:
    op: str
    l: "Expr"
    r: "Expr"


Expr = Union[Lit, Neg, Bin]


def evaluate(e: Expr) -> Optional[int]:
    if isinstance(e, Lit):
        return e.d
    if isinstance(e, Neg):
        v = evaluate(e.e)
        return None if v is None else -v
    a, b = evaluate(e.l), evaluate(e.r)
    return None if a is None or b is None else op_apply(e.op, a, b)


def trees(digits: List[int]) -> Iterator[Expr]:
    if len(digits) == 1:
        yield Lit(digits[0]); yield Neg(Lit(digits[0])); return
    for s in range(1, len(digits)):
        for l in trees(digits[:s]):
            for r in trees(digits[s:]):
                for op in OPS:
                    n = Bin(op, l, r); yield n; yield Neg(n)


def decide_orderly(n: int) -> Optional[Expr]:
    """Return a reading-order witness for n, or None. O(Catalan(k-1) * 3^(k-1) * 2^k)."""
    digits = [int(c) for c in str(n)]
    if len(digits) < 2:
        return None
    for e in trees(digits):
        if evaluate(e) == n:
            return e
    return None
