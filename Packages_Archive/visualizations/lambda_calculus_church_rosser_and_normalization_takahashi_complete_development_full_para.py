from __future__ import annotations
from dataclasses import dataclass

@dataclass(frozen=True)
class Term: ...
@dataclass(frozen=True)
class Var(Term):
    idx: int
@dataclass(frozen=True)
class Lam(Term):
    body: Term
@dataclass(frozen=True)
class App(Term):
    fn: Term
    arg: Term

def lift(cut: int, t: Term) -> Term:
    if isinstance(t, Var):
        return Var(t.idx + 1) if t.idx >= cut else t
    if isinstance(t, Lam):
        return Lam(lift(cut + 1, t.body))
    return App(lift(cut, t.fn), lift(cut, t.arg))

def subst(j: int, s: Term, t: Term) -> Term:
    if isinstance(t, Var):
        if t.idx == j:
            return s
        return Var(t.idx - 1) if t.idx > j else t
    if isinstance(t, Lam):
        return Lam(subst(j + 1, lift(0, s), t.body))
    return App(subst(j, s, t.fn), subst(j, s, t.arg))

def subst0(u: Term, t: Term) -> Term:
    return subst(0, u, t)

def cd(t: Term) -> Term:
    if isinstance(t, Var):
        return t
    if isinstance(t, Lam):
        return Lam(cd(t.body))
    if isinstance(t.fn, Lam):
        return subst0(cd(t.arg), cd(t.fn.body))
    return App(cd(t.fn), cd(t.arg))
