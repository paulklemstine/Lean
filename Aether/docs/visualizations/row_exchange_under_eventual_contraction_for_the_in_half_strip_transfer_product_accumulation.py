from typing import List

Matrix = List[List[float]]


def identity(n: int) -> Matrix:
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    n, k, m = len(a), len(b), len(b[0])
    out = [[0.0] * m for _ in range(n)]
    for i in range(n):
        for t in range(k):
            v = a[i][t]
            if v:
                for j in range(m):
                    out[i][j] += v * b[t][j]
    return out


def linfty_norm(a: Matrix) -> float:
    return max(sum(abs(x) for x in row) for row in a)


def prod_down_with_certificate(ms: List[Matrix], dim: int, c: float, N: int):
    """Accumulate P_{m+1} = M_m P_m (P_0 = I) and emit the collapse certificate.

    For m >= N the returned certificate equals ||P_N|| * c^(m-N), the geometric
    upper bound guaranteed by the eventual-contraction collapse theorem when
    ||M_k|| <= c < 1 for all k >= N. Yields (m, ||P_m||, certificate_or_None).
    """
    p = identity(dim)
    pN_norm = None
    for m in range(len(ms) + 1):
        nrm = linfty_norm(p)
        if m == N:
            pN_norm = nrm
        cert = (pN_norm * c ** (m - N)) if (pN_norm is not None and m >= N) else None
        yield m, nrm, cert
        if m < len(ms):
            p = matmul(ms[m], p)
