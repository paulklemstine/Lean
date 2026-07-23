from typing import Sequence

def rank(a: Sequence[Sequence[float]], tol: float = 1e-10) -> int:
    m = [list(map(float, row)) for row in a]
    if not m: return 0
    rows, cols, r = len(m), len(m[0]), 0
    for c in range(cols):
        p = max(range(r, rows), key=lambda i: abs(m[i][c]), default=-1)
        if p < 0 or abs(m[p][c]) <= tol: continue
        m[r], m[p] = m[p], m[r]
        q = m[r][c]
        m[r] = [x / q for x in m[r]]
        for i in range(rows):
            if i != r:
                q = m[i][c]
                m[i] = [x - q*y for x, y in zip(m[i], m[r])]
        r += 1
        if r == rows: break
    return r

def h1_dimension(d0: list[list[float]], d1: list[list[float]]) -> int:
    product = [[sum(d1[i][k]*d0[k][j] for k in range(len(d0)))
                for j in range(len(d0[0]))] for i in range(len(d1))]
    if any(abs(x) > 1e-10 for row in product for x in row):
        raise ValueError("not a cochain complex")
    return len(d0) - rank(d0) - rank(d1)
