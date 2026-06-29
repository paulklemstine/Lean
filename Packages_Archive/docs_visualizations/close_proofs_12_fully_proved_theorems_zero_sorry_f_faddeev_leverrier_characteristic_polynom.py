from typing import Tuple
Matrix = Tuple[Tuple[int, ...], ...]
Poly = Tuple[int, ...]

def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)

def mat_mul(a: Matrix, b: Matrix, p: int) -> Matrix:
    n, m, k = len(a), len(b[0]), len(b)
    return tuple(tuple(sum(a[i][t] * b[t][j] for t in range(k)) % p
                       for j in range(m)) for i in range(n))

def charpoly(a: Matrix, p: int) -> Poly:
    n = len(a)
    M = tuple(tuple(0 for _ in range(n)) for _ in range(n))
    coeffs = [0] * (n + 1); coeffs[n] = 1
    for k in range(1, n + 1):
        AM = mat_mul(a, M, p)
        c_prev = coeffs[n - k + 1]
        M = tuple(tuple((AM[i][j] + (c_prev if i == j else 0)) % p
                        for j in range(n)) for i in range(n))
        trace = sum(mat_mul(a, M, p)[i][i] for i in range(n)) % p
        coeffs[n - k] = (-inv_mod(k, p) * trace) % p
    return tuple(coeffs)
