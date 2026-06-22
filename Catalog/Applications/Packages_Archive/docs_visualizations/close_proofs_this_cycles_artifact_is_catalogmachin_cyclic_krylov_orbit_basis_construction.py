from typing import List

Matrix = List[List[int]]; Vector = List[int]

def cyclic_basis(A: Matrix, v: Vector, p: int) -> List[Vector]:
    """Krylov/orbit basis {v, Av, ..., A^{n-1} v}. For a certified A
    (irreducible charpoly) and v != 0 these n vectors form a basis of F_p^n,
    by the Orbit Spanning Theorem, putting A into companion form."""
    n = len(A)
    rows, w = [], v[:]
    for _ in range(n):
        rows.append(w[:])
        w = [sum(A[i][j] * w[j] for j in range(n)) % p for i in range(n)]
    assert _rank(rows, p) == n, "orbit must span (guaranteed if charpoly irred.)"
    return rows
