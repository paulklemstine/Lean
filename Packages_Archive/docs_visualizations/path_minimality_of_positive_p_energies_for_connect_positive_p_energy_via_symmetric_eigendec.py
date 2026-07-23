from __future__ import annotations
from typing import List
import math

def symmetric_eigenvalues(m: List[List[float]], it: int = 300, tol: float = 1e-13) -> List[float]:
    n = len(m); a = [r[:] for r in m]
    for _ in range(it):
        off = 0.0; p, q = 0, 1
        for i in range(n):
            for j in range(i + 1, n):
                if abs(a[i][j]) > off: off = abs(a[i][j]); p, q = i, j
        if off < tol: break
        if a[p][p] == a[q][q]:
            th = math.pi / 4 if a[p][q] > 0 else -math.pi / 4
        else:
            th = 0.5 * math.atan2(2 * a[p][q], a[p][p] - a[q][q])
        c, s = math.cos(th), math.sin(th)
        for k in range(n):
            akp, akq = a[k][p], a[k][q]; a[k][p] = c*akp + s*akq; a[k][q] = -s*akp + c*akq
        for k in range(n):
            apk, aqk = a[p][k], a[q][k]; a[p][k] = c*apk + s*aqk; a[q][k] = -s*apk + c*aqk
    return sorted((a[i][i] for i in range(n)), reverse=True)

def positive_p_energy(adj: List[List[float]], p: float) -> float:
    eigs = symmetric_eigenvalues(adj)
    return sum(lam ** p for lam in eigs if lam > 1e-9)
