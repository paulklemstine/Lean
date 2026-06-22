from __future__ import annotations
from itertools import product
from typing import List, Optional, Tuple

Matrix = Tuple[Tuple[int, ...], ...]
Vector = Tuple[int, ...]

def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)

def mat_vec(M: Matrix, v: Vector, p: int) -> Vector:
    n = len(M)
    return tuple(sum(M[i][j] * v[j] for j in range(n)) % p
                 for i in range(n))

def rank_mod(rows: List[Vector], p: int) -> int:
    a = [list(r) for r in rows]
    if not a: return 0
    ncol = len(a[0]); r = 0
    for col in range(ncol):
        piv = next((i for i in range(r, len(a)) if a[i][col] % p), None)
        if piv is None: continue
        a[r], a[piv] = a[piv], a[r]
        iv = inv_mod(a[r][col], p); a[r] = [(x * iv) % p for x in a[r]]
        for i in range(len(a)):
            if i != r and a[i][col] % p:
                f = a[i][col]
                a[i] = [(a[i][c] - f * a[r][c]) % p for c in range(ncol)]
        r += 1
        if r == len(a): break
    return r

def orbit_rank(M: Matrix, v: Vector, p: int) -> int:
    n = len(M); vecs = []; cur = v
    for _ in range(n + 1):
        vecs.append(cur); cur = mat_vec(M, cur, p)
    return rank_mod(vecs, p)

def has_proper_invariant_subspace(M: Matrix, p: int
                                  ) -> Tuple[bool, Optional[Vector]]:
    n = len(M)
    for v in product(range(p), repeat=n):
        if any(v) and orbit_rank(M, v, p) < n:
            return True, v
    return False, None
