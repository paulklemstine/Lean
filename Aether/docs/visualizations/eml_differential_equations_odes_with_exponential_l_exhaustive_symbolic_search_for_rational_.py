from __future__ import annotations
from itertools import product
from fractions import Fraction
from typing import List, Tuple, Optional

Poly = List[Fraction]  # coefficient list, index = power of x

def trim(p: Poly) -> Poly:
    q = list(p)
    while q and q[-1] == 0:
        q.pop()
    return q

def degree(p: Poly) -> int:
    t = trim(p)
    return 0 if not t else len(t) - 1

def is_zero(p: Poly) -> bool:
    return len(trim(p)) == 0

def add(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    out = [Fraction(0)] * n
    for i, c in enumerate(a):
        out[i] += c
    for i, c in enumerate(b):
        out[i] += c
    return trim(out)

def sub(a: Poly, b: Poly) -> Poly:
    return add(a, [-c for c in b])

def mul(a: Poly, b: Poly) -> Poly:
    a, b = trim(a), trim(b)
    if not a or not b:
        return []
    out = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, ca in enumerate(a):
        for j, cb in enumerate(b):
            out[i + j] += ca * cb
    return trim(out)

def deriv(p: Poly) -> Poly:
    if len(p) <= 1:
        return []
    return trim([p[i] * i for i in range(1, len(p))])

def riccati_identity_holds(f: Poly, p: Poly, q: Poly) -> bool:
    lhs = add(sub(mul(deriv(p), q), mul(p, deriv(q))), mul(p, p))
    rhs = mul(f, mul(q, q))
    return is_zero(sub(lhs, rhs))

def search_riccati_solution(
    f: Poly, max_deg: int, coeff_set: Tuple[int, ...] = (-2, -1, 0, 1, 2)
) -> Optional[Tuple[Poly, Poly]]:
    """Brute-force search for p, q (q != 0) with the cleared Riccati identity."""
    cs = [Fraction(c) for c in coeff_set]
    for dq in range(0, max_deg + 1):
        for q_tail in product(cs, repeat=dq):
            for q_lead in cs:
                if q_lead == 0:
                    continue
                q: Poly = list(q_tail) + [q_lead]
                for dp in range(0, max_deg + 1):
                    for p_full in product(cs, repeat=dp + 1):
                        p: Poly = list(p_full)
                        if riccati_identity_holds(f, p, q):
                            return (trim(p), trim(q))
    return None
