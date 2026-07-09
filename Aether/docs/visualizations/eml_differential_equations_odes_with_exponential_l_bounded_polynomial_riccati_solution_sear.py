import itertools
from typing import List, Optional
Poly = List[float]

def _trim(p: Poly) -> Poly:
    q = list(p)
    while len(q) > 1 and abs(q[-1]) < 1e-12:
        q.pop()
    return q

def _deg(p: Poly) -> int:
    q = _trim(p)
    return -1 if (len(q) == 1 and abs(q[0]) < 1e-12) else len(q) - 1

def _mul(a: Poly, b: Poly) -> Poly:
    out = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return _trim(out)

def _deriv(p: Poly) -> Poly:
    return _trim([i * p[i] for i in range(1, len(p))]) if len(p) > 1 else [0.0]

def _sub(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return _trim([(a[i] if i < len(a) else 0.0) - (b[i] if i < len(b) else 0.0)
                  for i in range(n)])

def _add(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return _trim([(a[i] if i < len(a) else 0.0) + (b[i] if i < len(b) else 0.0)
                  for i in range(n)])

def bounded_polynomial_riccati_search(f: Poly, max_deg: int = 4) -> Optional[Poly]:
    grid = [c / 2 for c in range(-6, 7)]
    for d in range(0, max_deg + 1):
        for coeffs in itertools.product(grid, repeat=d + 1):
            p = _trim(list(coeffs))
            if _deg(_sub(_add(_deriv(p), _mul(p, p)), f)) < 0:
                return p
    return None
