from __future__ import annotations
from dataclasses import dataclass
from math import exp

@dataclass(frozen=True)
class ETerm:
    kind: str
    left: 'ETerm | None' = None
    right: 'ETerm | None' = None

def var() -> ETerm:
    return ETerm('var')

def add(s: ETerm, t: ETerm) -> ETerm:
    return ETerm('add', s, t)

def exp_of(t: ETerm) -> ETerm:
    return ETerm('exp', t)

def rep_add(k: int) -> ETerm:
    t = var()
    for _ in range(k):
        t = add(var(), t)
    return t

def exp_basis(k: int) -> ETerm:
    return exp_of(rep_add(k))

def size(t: ETerm) -> int:
    if t.kind == 'var':
        return 1
    if t.kind in ('add', 'mul'):
        return size(t.left) + size(t.right) + 1
    return size(t.left) + 1

def eval_term(t: ETerm, x: float) -> float:
    if t.kind == 'var':
        return x
    if t.kind == 'add':
        return eval_term(t.left, x) + eval_term(t.right, x)
    if t.kind == 'exp':
        return exp(eval_term(t.left, x))
    raise ValueError(t.kind)

def K_upper_bound(k: int) -> int:
    return 2 * k + 2
