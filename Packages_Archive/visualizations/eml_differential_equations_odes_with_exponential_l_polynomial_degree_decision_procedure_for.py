from __future__ import annotations
from typing import List

Poly = List[float]


def trim(p: Poly) -> Poly:
    q = list(p)
    while q and abs(q[-1]) < 1e-12:
        q.pop()
    return q


def degree(p: Poly) -> int:
    return len(trim(p)) - 1


def add(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return trim([(a[i] if i < len(a) else 0.0) + (b[i] if i < len(b) else 0.0)
                 for i in range(n)])


def scale(a: Poly, c: float) -> Poly:
    return trim([c * x for x in a])


def mul(a: Poly, b: Poly) -> Poly:
    if not a or not b:
        return []
    out = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return trim(out)


def deriv(p: Poly) -> Poly:
    return trim([i * p[i] for i in range(1, len(p))])


def shift_X(p: Poly) -> Poly:
    return [] if not trim(p) else trim([0.0] + list(p))


def airy_coeff(q: Poly, p: Poly) -> Poly:
    """airyCoeff(q, p) = q'' + 2 q' p' + q p'' + q (p')^2."""
    qp, pp = deriv(q), deriv(p)
    qpp, ppp = deriv(qp), deriv(pp)
    return add(add(add(qpp, scale(mul(qp, pp), 2.0)),
                   mul(q, ppp)), mul(q, mul(pp, pp)))


def decide_qexpp_solves_airy(q: Poly, p: Poly) -> bool:
    """Return True iff q*exp(p) (q != 0) solves y'' = x y, by testing the
    reduced polynomial identity airyCoeff(q,p) == X*q. Always False for q != 0,
    certified by the degree/parity obstruction."""
    if not trim(q):
        raise ValueError("q must be nonzero")
    residual = add(airy_coeff(q, p), scale(shift_X(q), -1.0))
    return trim(residual) == []
