from typing import Tuple, List

def abscissa_sum(a: float, b: float, c: float, d: float) -> float:
    return a + b + c + d

def _solve3(A: List[List[float]], b: List[float]) -> Tuple[float, float, float]:
    def det3(m: List[List[float]]) -> float:
        return (m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])
              - m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])
              + m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]))
    d = det3(A)
    if abs(d) < 1e-15:
        raise ValueError('collinear / degenerate')
    out = []
    for j in range(3):
        m = [row[:] for row in A]
        for i in range(3):
            m[i][j] = b[i]
        out.append(det3(m)/d)
    return out[0], out[1], out[2]

def concyclic(a: float, b: float, c: float, d: float, tol: float = 1e-9) -> bool:
    if abs(abscissa_sum(a, b, c, d)) >= tol:
        return False
    pts = [(t, t*t) for t in (a, b, c)]
    A = [[x, y, 1.0] for (x, y) in pts]
    rhs = [-(x*x + y*y) for (x, y) in pts]
    D, E, F = _solve3(A, rhs)
    res = d*d*d*d + d*d + D*d + E*d*d + F
    return abs(res) < 1e-6
