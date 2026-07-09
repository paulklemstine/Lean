from __future__ import annotations
from itertools import product
from typing import Optional, Set

OPS = ("add", "mul", "pow")


def op_apply(op: str, a: int, b: int) -> Optional[int]:
    if op == "add":
        return a + b
    if op == "mul":
        return a * b
    e = max(b, 0)
    if abs(a) > 1 and e > 64:
        return None
    return a ** e


def reachable2(a: int, b: int) -> Set[int]:
    """Exact set of values a two-leaf order-(a,b) expression can evaluate to.

    Constant time: 2^3 sign assignments x 3 operations = 24 candidates.
    """
    out: Set[int] = set()
    for s0, s1, s2 in product((1, -1), repeat=3):
        for op in OPS:
            v = op_apply(op, s1 * a, s2 * b)
            if v is not None:
                out.add(s0 * v)
    return out


def no_two_digit_orderly() -> bool:
    for n in range(10, 100):
        a, b = (int(c) for c in str(n))
        if n in reachable2(a, b):
            return False
    return True
