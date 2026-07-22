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
