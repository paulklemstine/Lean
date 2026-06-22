from typing import List

Matrix = List[List[int]]


def rank_mod2(matrix: Matrix) -> int:
    """Rank of a 0/1 matrix over the binary field F2 via Gaussian elimination."""
    if not matrix or not matrix[0]:
        return 0
    m: Matrix = [row[:] for row in matrix]
    rows, cols = len(m), len(m[0])
    rank, pivot = 0, 0
    for col in range(cols):
        sel = next((r for r in range(pivot, rows) if m[r][col] % 2), -1)
        if sel == -1:
            continue
        m[pivot], m[sel] = m[sel], m[pivot]
        for r in range(rows):
            if r != pivot and m[r][col] % 2:
                m[r] = [(x ^ y) for x, y in zip(m[r], m[pivot])]
        rank += 1
        pivot += 1
        if pivot == rows:
            break
    return rank


def mat_mul_mod2(a: Matrix, b: Matrix) -> Matrix:
    """Matrix product over F2."""
    rows, inner, cols = len(a), len(b), len(b[0]) if b else 0
    out: Matrix = [[0] * cols for _ in range(rows)]
    for i in range(rows):
        for k in range(inner):
            if a[i][k] % 2:
                for j in range(cols):
                    out[i][j] ^= b[k][j] % 2
    return out


def css_logical_qubits(d1: Matrix, d2: Matrix, n: int) -> int:
    """Number of logical qubits k of the CSS code of a chain complex.

    d2 : F^m -> F^n  (n x m matrix),  d1 : F^n -> F^p  (p x n matrix).
    Requires the chain condition d1.d2 = 0.  Returns
        k = beta_1 = dim ker(d1) - dim im(d2) = (n - rank(d1)) - rank(d2).
    """
    prod = mat_mul_mod2(d1, d2)
    assert all(e % 2 == 0 for row in prod for e in row), "chain condition fails"
    dim_cycles = n - rank_mod2(d1)      # dim ker(d1)
    dim_boundaries = rank_mod2(d2)      # dim im(d2)
    return dim_cycles - dim_boundaries
