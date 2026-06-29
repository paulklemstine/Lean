from __future__ import annotations
from typing import Callable, FrozenSet

Elem = FrozenSet[int]

def box(n: int, s: Elem) -> Elem:
    """Provability box of the frame (Fin n, <): x proves S iff every y<x is in S."""
    return frozenset(x for x in range(n) if all((y in s) for y in range(x)))

def himp(n: int, a: Elem, b: Elem) -> Elem:
    """Heyting implication a => b = (complement a) OR b in the Boolean algebra."""
    return (frozenset(range(n)) - a) | b

def sambin_fixed_point(n: int, c: Elem) -> Elem:
    """Constructive de Jongh-Sambin fixed point of  p |-> box p => c.

    The map f is antitone, so we iterate its MONOTONE square g = f.f from TOP.
    The stabilised value is a fixed point of g; by uniqueness it is the fixed
    point of f, and it provably equals the closed form  glFix c = box c => c.
    """
    f: Callable[[Elem], Elem] = lambda p: himp(n, box(n, p), c)
    g: Callable[[Elem], Elem] = lambda p: f(f(p))
    x: Elem = frozenset(range(n))
    while True:
        x_next = g(x)
        if x_next == x:
            return x
        x = x_next
