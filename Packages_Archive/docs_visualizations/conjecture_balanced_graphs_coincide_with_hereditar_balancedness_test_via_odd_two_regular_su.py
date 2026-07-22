from itertools import combinations
from typing import List, Sequence

Matrix = List[List[int]]


def is_two_per_row_col_odd(sub: Matrix) -> bool:
    k = len(sub)
    if k % 2 == 0 or any(len(r) != k for r in sub):
        return False
    if not all(sum(r) == 2 for r in sub):
        return False
    return all(sum(sub[i][j] for i in range(k)) == 2 for j in range(k))


def is_balanced(matrix: Matrix, max_order: int = 7) -> bool:
    """A 0/1 matrix is (heuristically, up to max_order) balanced if it has no
    odd square submatrix that is two-per-row-and-column. Returns False as soon
    as such a submatrix is found."""
    m = len(matrix)
    n = len(matrix[0]) if m else 0
    for k in range(3, max_order + 1, 2):
        if k > m or k > n:
            break
        for rows in combinations(range(m), k):
            for cols in combinations(range(n), k):
                sub = [[matrix[r][c] for c in cols] for r in rows]
                if is_two_per_row_col_odd(sub):
                    return False
    return True
