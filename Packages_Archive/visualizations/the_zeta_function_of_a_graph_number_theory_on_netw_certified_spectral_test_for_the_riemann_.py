from __future__ import annotations
import math
from typing import List

def symmetric_eigenvalues(mat: List[List[float]], iters: int = 100) -> List[float]:
    """Jacobi rotation eigen-solver for a real symmetric matrix."""
    n = len(mat)
    a = [row[:] for row in mat]
    for _ in range(iters):
        p, qi, best = 0, 1, 0.0
        for i in range(n):
            for j in range(i + 1, n):
                if abs(a[i][j]) > best:
                    best, p, qi = abs(a[i][j]), i, j
        if best < 1e-12:
            break
        app, aqq, apq = a[p][p], a[qi][qi], a[p][qi]
        theta = 0.5 * math.atan2(2.0 * apq, aqq - app) if aqq != app else math.pi / 4
        c, s = math.cos(theta), math.sin(theta)
        for k in range(n):
            akp, akq = a[k][p], a[k][qi]
            a[k][p], a[k][qi] = c * akp - s * akq, s * akp + c * akq
        for k in range(n):
            akp, akq = a[p][k], a[qi][k]
            a[p][k], a[qi][k] = c * akp - s * akq, s * akp + c * akq
    return sorted((a[i][i] for i in range(n)), reverse=True)

def certified_rh_test(adjacency: List[List[float]]) -> bool:
    """Return True iff the Ihara zeta function of the given (q+1)-regular graph
    satisfies the Riemann Hypothesis, i.e. the graph is Ramanujan."""
    eigs = symmetric_eigenvalues(adjacency)
    q = int(round(eigs[0])) - 1                 # top eigenvalue = q+1
    if q <= 0:
        return True
    bound = 2.0 * math.sqrt(q)
    return all(abs(l) <= bound + 1e-6 for l in eigs[1:])   # skip trivial eigenvalue
