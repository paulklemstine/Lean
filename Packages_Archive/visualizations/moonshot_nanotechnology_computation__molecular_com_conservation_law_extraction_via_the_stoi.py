from __future__ import annotations
from fractions import Fraction
from typing import List, Tuple

Vec = List[Fraction]

def stoichiometry(reactions: List[Tuple[List[int], List[int]]]) -> List[Vec]:
    """Rows are (product - reactant) vectors for each reaction."""
    return [[Fraction(p - r) for r, p in zip(reac, prod)] for reac, prod in reactions]

def conservation_laws(reactions: List[Tuple[List[int], List[int]]]) -> List[Vec]:
    """Return a basis of the left null space (balanced functionals w with S^T w = 0)."""
    rows = stoichiometry(reactions)             # m reactions x n species
    if not rows:
        return []
    n = len(rows[0])
    # Build augmented columns as the transpose; find kernel of the m x n matrix.
    A = [row[:] for row in rows]
    m = len(A)
    pivots: List[int] = []
    r = 0
    for c in range(n):
        piv = next((i for i in range(r, m) if A[i][c] != 0), None)
        if piv is None:
            continue
        A[r], A[piv] = A[piv], A[r]
        inv = Fraction(1) / A[r][c]
        A[r] = [v * inv for v in A[r]]
        for i in range(m):
            if i != r and A[i][c] != 0:
                f = A[i][c]
                A[i] = [a - f * b for a, b in zip(A[i], A[r])]
        pivots.append(c)
        r += 1
        if r == m:
            break
    free = [c for c in range(n) if c not in pivots]
    basis: List[Vec] = []
    for fc in free:
        w = [Fraction(0)] * n
        w[fc] = Fraction(1)
        for ri, pc in enumerate(pivots):
            w[pc] = -A[ri][fc]
        basis.append(w)
    return basis
