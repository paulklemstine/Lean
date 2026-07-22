from __future__ import annotations
from itertools import combinations
from typing import Dict, List, Set

Graph = Dict[int, Set[int]]


def clique_matrix(maximal: List[frozenset], n: int) -> List[List[int]]:
    """Build the 0/1 vertex-by-clique incidence matrix."""
    cols = sorted(maximal, key=lambda c: sorted(c))
    return [[1 if v in c else 0 for c in cols] for v in range(n)]


def has_odd_two_regular_submatrix(mat: List[List[int]]) -> bool:
    """Detect an odd square submatrix with all row and column sums equal to 2.

    Such a submatrix is the incidence matrix of an odd cycle and witnesses that
    the matrix is NOT balanced. Brute force over odd-sized row/column subsets.
    """
    R, C = len(mat), (len(mat[0]) if mat else 0)
    max_k = min(R, C)
    for k in range(3, max_k + 1, 2):          # odd orders only
        for rows in combinations(range(R), k):
            for cols in combinations(range(C), k):
                ok = True
                for r in rows:
                    if sum(mat[r][c] for c in cols) != 2:
                        ok = False
                        break
                if not ok:
                    continue
                if all(sum(mat[r][c] for r in rows) == 2 for c in cols):
                    return True
    return False


def is_balanced(mat: List[List[int]]) -> bool:
    """A 0/1 matrix is balanced iff it has no odd 2-regular square submatrix."""
    return not has_odd_two_regular_submatrix(mat)
