from fractions import Fraction
from typing import List, Tuple
Matrix = List[List[Fraction]]

def gaussian_rank(rows: Matrix) -> int:
    """Exact rank over the rationals via Gaussian elimination."""
    if not rows or not rows[0]:
        return 0
    m: Matrix = [r[:] for r in rows]
    n_rows, n_cols, rank, pc = len(m), len(m[0]), 0, 0
    for r in range(n_rows):
        if pc >= n_cols:
            break
        piv = None
        while pc < n_cols:
            for i in range(r, n_rows):
                if m[i][pc] != 0:
                    piv = i
                    break
            if piv is not None:
                break
            pc += 1
        if piv is None:
            break
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][pc]
        m[r] = [x / inv for x in m[r]]
        for i in range(n_rows):
            if i != r and m[i][pc] != 0:
                f = m[i][pc]
                m[i] = [a - f * b for a, b in zip(m[i], m[r])]
        rank += 1
        pc += 1
    return rank

def betti(d2: Matrix, d1: Matrix) -> Tuple[int, int, int, int]:
    """Return (dim C1, rank Z, rank B, beta) for C2 -d2-> C1 -d1-> C0."""
    dim_c1 = len(d1[0]) if (d1 and d1[0]) else (len(d2) if d2 else 0)
    rank_z = dim_c1 - gaussian_rank(d1)
    rank_b = gaussian_rank(d2)
    beta = rank_z - rank_b
    assert beta + rank_b == rank_z
    assert beta <= dim_c1
    return dim_c1, rank_z, rank_b, beta
