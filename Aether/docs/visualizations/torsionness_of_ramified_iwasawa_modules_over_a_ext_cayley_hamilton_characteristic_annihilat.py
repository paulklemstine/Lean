from typing import List

Matrix = List[List[int]]
Poly = List[int]  # low-degree-first coefficients

def mat_mul(a: Matrix, b: Matrix, mod: int) -> Matrix:
    n = len(a)
    out: Matrix = [[0] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            if a[i][k]:
                for j in range(n):
                    out[i][j] = (out[i][j] + a[i][k] * b[k][j]) % mod
    return out

def mat_identity(n: int) -> Matrix:
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]

def mat_apply(a: Matrix, v: List[int], mod: int) -> List[int]:
    n = len(a)
    return [sum(a[i][j] * v[j] for j in range(n)) % mod for i in range(n)]

def char_poly_berkowitz(a: Matrix, mod: int) -> Poly:
    """Division-free characteristic polynomial det(X*I - A) over Z/mod,
    returned low-degree-first.  Monic of degree n; equals the Cayley-Hamilton
    annihilator q with q(A) = 0 (so q(T) annihilates the module M)."""
    n = len(a)
    if n == 0:
        return [1]
    poly_vec: List[int] = [1 % mod, (-a[0][0]) % mod]
    for r in range(1, n):
        R = [a[r][j] % mod for j in range(r)]
        S = [a[i][r] % mod for i in range(r)]
        M = [[a[i][j] % mod for j in range(r)] for i in range(r)]
        col: List[int] = [1 % mod, (-a[r][r]) % mod]
        Mk = mat_identity(r)
        for _ in range(r):
            MkS = mat_apply(Mk, S, mod)
            col.append((-sum(R[i] * MkS[i] for i in range(r))) % mod)
            Mk = mat_mul(Mk, M, mod)
        new_vec: List[int] = [0] * (r + 2)
        for i in range(r + 2):
            acc = 0
            for j in range(r + 1):
                idx = i - j
                if 0 <= idx < len(col):
                    acc += col[idx] * poly_vec[j]
            new_vec[i] = acc % mod
        poly_vec = new_vec
    return list(reversed(poly_vec))
