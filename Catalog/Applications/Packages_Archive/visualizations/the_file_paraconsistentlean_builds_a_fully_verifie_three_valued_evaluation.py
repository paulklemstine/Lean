from __future__ import annotations
from dataclasses import dataclass
from enum import IntEnum
from typing import Dict


class LP(IntEnum):
    ff = 0  # false only
    bb = 1  # both (glut)
    tt = 2  # true only


def neg(x: LP) -> LP:
    return {LP.ff: LP.tt, LP.bb: LP.bb, LP.tt: LP.ff}[x]


def conj(x: LP, y: LP) -> LP:  # min on ff < bb < tt
    return LP(min(int(x), int(y)))


def disj(x: LP, y: LP) -> LP:  # max on ff < bb < tt
    return LP(max(int(x), int(y)))


@dataclass(frozen=True)
class Form:
    kind: str
    n: int = -1
    a: "Form | None" = None
    b: "Form | None" = None


def eval_form(v: Dict[int, LP], f: Form) -> LP:
    """Three-valued evaluation by recursive descent (O(size of f))."""
    if f.kind == "atom":
        return v.get(f.n, LP.ff)
    if f.kind == "neg":
        return neg(eval_form(v, f.a))
    if f.kind == "conj":
        return conj(eval_form(v, f.a), eval_form(v, f.b))
    if f.kind == "disj":
        return disj(eval_form(v, f.a), eval_form(v, f.b))
    raise ValueError(f.kind)
