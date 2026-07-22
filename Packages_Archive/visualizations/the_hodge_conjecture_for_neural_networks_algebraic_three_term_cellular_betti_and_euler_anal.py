from fractions import Fraction
from typing import Sequence

Number = int | Fraction

def exact_matrix_rank(rows: Sequence[Sequence[Number]]) -> int:
    """Return matrix rank over the rational numbers."""
    a = [[Fraction(x) for x in row] for row in rows]
    if not a:
        return 0
    if any(len(row) != len(a[0]) for row in a):
        raise ValueError("ragged matrix")
    m, n, r = len(a), len(a[0]), 0
    for col in range(n):
        pivot = next((i for i in range(r, m) if a[i][col] != 0), None)
        if pivot is None:
            continue
        a[r], a[pivot] = a[pivot], a[r]
        scale = a[r][col]
        a[r] = [x / scale for x in a[r]]
        for i in range(m):
            if i != r and a[i][col] != 0:
                scale = a[i][col]
                a[i] = [x - scale*y for x, y in zip(a[i], a[r])]
        r += 1
        if r == m:
            break
    return r


def betti_numbers(d1: Sequence[Sequence[Number]],
                   d2: Sequence[Sequence[Number]]) -> tuple[int, int, int]:
    """Compute the Betti vector of a three-term rational chain complex."""
    c0 = len(d1)
    c1 = len(d1[0]) if d1 else len(d2)
    c2 = len(d2[0]) if d2 else 0
    if len(d2) != c1:
        raise ValueError("incompatible dimensions")
    product = [[sum(Fraction(d1[i][k]) * Fraction(d2[k][j])
                    for k in range(c1))
                for j in range(c2)] for i in range(c0)]
    if any(x != 0 for row in product for x in row):
        raise ValueError("d1*d2 must vanish")
    r1, r2 = exact_matrix_rank(d1), exact_matrix_rank(d2)
    return c0-r1, c1-r1-r2, c2-r2

D1 = [[-1,0,1],[1,-1,0],[0,1,-1]]
D2 = [[1],[1],[1]]
print(betti_numbers(D1,D2))  # (1, 0, 0)
