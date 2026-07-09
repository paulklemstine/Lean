from __future__ import annotations
from dataclasses import dataclass
from typing import Union


@dataclass(frozen=True)
class Const:
    c: float
@dataclass(frozen=True)
class X:
    pass
@dataclass(frozen=True)
class Add:
    a: "Term"; b: "Term"
@dataclass(frozen=True)
class Mul:
    a: "Term"; b: "Term"
@dataclass(frozen=True)
class Neg:
    a: "Term"
@dataclass(frozen=True)
class Exp:
    a: "Term"

Term = Union[Const, X, Add, Mul, Neg, Exp]


def comp(s: Term, t: Term) -> Term:
    """Substitute t for every X-leaf of s (Term.comp).

    Realizes function composition: eval(comp(s, t))(x) == eval(s)(eval(t)(x)).
    """
    if isinstance(s, Const):
        return s
    if isinstance(s, X):
        return t
    if isinstance(s, Add):
        return Add(comp(s.a, t), comp(s.b, t))
    if isinstance(s, Mul):
        return Mul(comp(s.a, t), comp(s.b, t))
    if isinstance(s, Neg):
        return Neg(comp(s.a, t))
    if isinstance(s, Exp):
        return Exp(comp(s.a, t))
    raise TypeError(f"unknown term: {s!r}")
