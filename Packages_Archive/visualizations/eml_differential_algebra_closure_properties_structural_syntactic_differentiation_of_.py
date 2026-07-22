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


def D(t: Term) -> Term:
    """Syntactic derivative of an EML term (Term.D).

    Applies the constant/identity base rules, linearity for + and neg,
    the product rule for *, and the exponential chain rule for exp.
    """
    if isinstance(t, Const):
        return Const(0.0)
    if isinstance(t, X):
        return Const(1.0)
    if isinstance(t, Add):
        return Add(D(t.a), D(t.b))
    if isinstance(t, Mul):
        return Add(Mul(D(t.a), t.b), Mul(t.a, D(t.b)))
    if isinstance(t, Neg):
        return Neg(D(t.a))
    if isinstance(t, Exp):
        return Mul(D(t.a), Exp(t.a))
    raise TypeError(f"unknown term: {t!r}")
