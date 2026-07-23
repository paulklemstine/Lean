from typing import Sequence

def rref(a: Sequence[Sequence[float]], tol: float = 1e-10) -> tuple[list[list[float]], list[int]]:
    m = [list(map(float, row)) for row in a]; pivots: list[int] = []; r = 0
    for c in range(len(m[0]) if m else 0):
        p = max(range(r, len(m)), key=lambda i: abs(m[i][c]), default=-1)
        if p < 0 or abs(m[p][c]) <= tol: continue
        m[r], m[p] = m[p], m[r]; q = m[r][c]; m[r] = [x/q for x in m[r]]
        for i in range(len(m)):
            if i != r:
                q = m[i][c]; m[i] = [x-q*y for x,y in zip(m[i],m[r])]
        pivots.append(c); r += 1
        if r == len(m): break
    return m, pivots

def nullspace(a: list[list[float]]) -> list[list[float]]:
    m, pivots = rref(a); n = len(a[0]); out: list[list[float]] = []
    for f in (j for j in range(n) if j not in pivots):
        v = [0.0]*n; v[f] = 1.0
        for i,p in enumerate(pivots): v[p] = -m[i][f]
        out.append(v)
    return out
