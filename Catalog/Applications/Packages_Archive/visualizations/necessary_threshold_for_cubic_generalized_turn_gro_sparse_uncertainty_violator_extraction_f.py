from fractions import Fraction
from itertools import combinations
from typing import List, Optional, Tuple

Matrix = List[List[Fraction]]
Vector = List[Fraction]

def det(M: Matrix) -> Fraction:
    n = len(M); A = [row[:] for row in M]; d = Fraction(1)
    for c in range(n):
        pr = next((r for r in range(c, n) if A[r][c] != 0), None)
        if pr is None:
            return Fraction(0)
        if pr != c:
            A[c], A[pr] = A[pr], A[c]; d = -d
        d *= A[c][c]
        for r in range(c + 1, n):
            f = A[r][c] / A[c][c]
            A[r] = [a - f * b for a, b in zip(A[r], A[c])]
    return d

def kernel_vector(A: Matrix) -> Optional[Vector]:
    """A nonzero kernel vector of a singular square matrix, via RREF."""
    k = len(A); M = [row[:] for row in A]; pivots: List[int] = []; row = 0
    for col in range(k):
        sel = next((r for r in range(row, k) if M[r][col] != 0), None)
        if sel is None:
            continue
        M[row], M[sel] = M[sel], M[row]
        pv = M[row][col]; M[row] = [x / pv for x in M[row]]
        for r in range(k):
            if r != row and M[r][col] != 0:
                fac = M[r][col]; M[r] = [a - fac * b for a, b in zip(M[r], M[row])]
        pivots.append(col); row += 1
    free = [c for c in range(k) if c not in pivots]
    if not free:
        return None
    x = [Fraction(0)] * k; x[free[0]] = Fraction(1)
    for r, pc in enumerate(pivots):
        x[pc] = -M[r][free[0]]
    return x

def extract_violator(M: Matrix) -> Optional[Vector]:
    """
    Given a NON-MDS matrix, produce a sparse vector f != 0 with
    |supp(f)| + |supp(Mf)| <= n  (constructive content of
    not_mds_implies_violator).  Steps: find a singular square submatrix,
    take a kernel vector of it, and pad with zeros along the chosen columns.
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = [[M[r][c] for c in cols] for r in rows]
                if det(sub) == 0:
                    v = kernel_vector(sub)
                    if v is None:
                        continue
                    f = [Fraction(0)] * n
                    for idx, c in enumerate(cols):
                        f[c] = v[idx]
                    return f
    return None
