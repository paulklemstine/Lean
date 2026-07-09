from __future__ import annotations
from typing import List, Optional, Tuple

Poly = List[float]  # [c0, c1, c2, ...] meaning c0 + c1 x + c2 x^2 + ...

def poly_trim(p: Poly) -> Poly:
    q = list(p)
    while len(q) > 1 and abs(q[-1]) < 1e-12:
        q.pop()
    return q

def poly_degree(p: Poly) -> int:
    q = poly_trim(p)
    if len(q) == 1 and abs(q[0]) < 1e-12:
        return -1
    return len(q) - 1

def poly_add(p: Poly, q: Poly) -> Poly:
    n = max(len(p), len(q))
    return poly_trim([(p[i] if i < len(p) else 0.0) + (q[i] if i < len(q) else 0.0)
                      for i in range(n)])

def poly_mul(p: Poly, q: Poly) -> Poly:
    out = [0.0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i + j] += a * b
    return poly_trim(out)

def poly_deriv(p: Poly) -> Poly:
    if len(p) <= 1:
        return [0.0]
    return poly_trim([i * p[i] for i in range(1, len(p))])

def poly_eq(p: Poly, q: Poly, tol: float = 1e-9) -> bool:
    n = max(len(p), len(q))
    return all(abs((p[i] if i < len(p) else 0.0) -
                   (q[i] if i < len(q) else 0.0)) < tol for i in range(n))

def kovacic_first_step(f: Poly,
                       max_height: int = 6) -> Tuple[bool, Optional[Poly]]:
    """Decide the Kovacic first step for y'' = f*y on a polynomial coefficient f.

    Returns (solvable, v) where, when solvable, v is a polynomial with
    v' + v^2 = f (so y = exp(integral v)). The negative branch is *certified*
    by the odd-degree parity obstruction (no rational Riccati solution exists).
    """
    d = poly_degree(f)
    if d < 0:
        return (True, [0.0])
    if d % 2 == 1:
        return (False, None)  # odd degree: provably no rational Riccati solution
    target = d // 2
    menu = [c / 2.0 for c in range(-2 * max_height, 2 * max_height + 1)]

    def enum(deg: int) -> List[Poly]:
        if deg == 0:
            return [[c] for c in menu]
        return [s + [c] for s in enum(deg - 1) for c in menu]

    for v in enum(target):
        if poly_eq(poly_add(poly_deriv(v), poly_mul(v, v)), f):
            return (True, poly_trim(v))
    return (False, None)
