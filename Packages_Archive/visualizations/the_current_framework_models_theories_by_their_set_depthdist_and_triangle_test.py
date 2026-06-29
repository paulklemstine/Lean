"""Algorithm B: depthDist and the triangle-inequality test on PTOs.

Given theories presented by their proof-theoretic ordinals (PTOs) in Cantor
normal form, compute the symmetric ordinal separation
    depthDist(p, q) = (p - q) + (q - p)
and test whether a triple (p, q, r) obeys the triangle inequality
    depthDist(p, r) <= depthDist(p, q) + depthDist(q, r).

Along a monotone chain p <= q <= r this holds with EQUALITY (exact additivity);
the absorbing arrangement (w+1, w, 0) makes it FAIL because 1 + w = w.
"""
from __future__ import annotations
from typing import List, Tuple

Term = Tuple[int, int]
CNF = Tuple[Term, ...]


def ord_lt(a: CNF, b: CNF) -> bool:
    return list(a) < list(b)


def ord_le(a: CNF, b: CNF) -> bool:
    return a == b or ord_lt(a, b)


def ord_add(a: CNF, b: CNF) -> CNF:
    """Ordinal addition (non-commutative)."""
    if not b:
        return a
    lead = b[0][0]
    kept: List[Term] = [(e, c) for (e, c) in a if e > lead]
    same: List[Term] = [(e, c) for (e, c) in a if e == lead]
    rest: List[Term] = list(b)
    if same:
        rest = [(lead, same[0][1] + rest[0][1])] + rest[1:]
    return tuple(kept + rest)


def ord_sub(a: CNF, b: CNF) -> CNF:
    """Ordinal left-subtraction (see Algorithm A)."""
    if ord_le(a, b):
        return ()
    al, bl = list(a), list(b)
    i = 0
    while i < len(bl):
        ea, ca = al[i]
        eb, cb = bl[i]
        if ea > eb:
            return tuple(al[i:])
        if ca > cb:
            return tuple([(ea, ca - cb)] + al[i + 1:])
        i += 1
    return tuple(al[i:])


def depth_dist(p: CNF, q: CNF) -> CNF:
    return ord_add(ord_sub(p, q), ord_sub(q, p))


def triangle_holds(p: CNF, q: CNF, r: CNF) -> bool:
    return ord_le(depth_dist(p, r), ord_add(depth_dist(p, q), depth_dist(q, r)))


if __name__ == "__main__":
    w = ((1, 1),)
    w1 = ((1, 1), (0, 1))
    zero: CNF = ()
    print("chain (0, w, w*2) holds:", triangle_holds(zero, w, ((1, 2),)))
    print("absorbing (w+1, w, 0) holds:", triangle_holds(w1, w, zero))  # False
