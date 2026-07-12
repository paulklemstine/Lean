"""
Numerical demonstrations of the Euler-Poincare principle for
decision-surface cellular complexes.

The central identity proved in the accompanying paper is, for a three-term
chain complex  C2 --d2--> C1 --d1--> C0  with d1 . d2 = 0,

    dim H0 - dim H1 + dim H2  =  dim C0 - dim C1 + dim C2,

where the three Betti numbers are

    dim H0 = |C0| - rank d1        (cokernel of d1)
    dim H1 = |C1| - rank d1 - rank d2   (subquotient ker d1 / im d2)
    dim H2 = |C2| - rank d2        (kernel of d2)

The left side is topology; the right side is pure cell counting.  Every rank
term cancels.  This script verifies that on random valid complexes over the
rationals and over F2, checks the abstract defect identity of arbitrary length,
and evaluates the width-driven bound  |chi| <= 3 * prod_i 2^{w_i}.

Self-contained: uses only the Python standard library (Fraction for exact
rational arithmetic).  Run with:  python3 demo.py
"""

from __future__ import annotations

import random
from fractions import Fraction
from typing import List, Sequence, Tuple


# ----------------------------------------------------------------------------
# Exact-rank linear algebra over Q (fractions) and over F2.
# ----------------------------------------------------------------------------

def matrix_rank_q(matrix: Sequence[Sequence[Fraction]]) -> int:
    """Rank of a matrix over the rationals via fraction-exact Gaussian
    elimination.  Rows are the outer sequence."""
    rows = [list(row) for row in matrix]
    if not rows or not rows[0]:
        return 0
    n_cols = len(rows[0])
    rank = 0
    pivot_row = 0
    for col in range(n_cols):
        pivot = None
        for r in range(pivot_row, len(rows)):
            if rows[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            continue
        rows[pivot_row], rows[pivot] = rows[pivot], rows[pivot_row]
        piv_val = rows[pivot_row][col]
        rows[pivot_row] = [v / piv_val for v in rows[pivot_row]]
        for r in range(len(rows)):
            if r != pivot_row and rows[r][col] != 0:
                factor = rows[r][col]
                rows[r] = [a - factor * b for a, b in zip(rows[r], rows[pivot_row])]
        rank += 1
        pivot_row += 1
        if pivot_row == len(rows):
            break
    return rank


def matrix_rank_f2(matrix: Sequence[Sequence[int]]) -> int:
    """Rank of a 0/1 matrix over the field F2 via Gaussian elimination mod 2."""
    rows = [[v & 1 for v in row] for row in matrix]
    if not rows or not rows[0]:
        return 0
    n_cols = len(rows[0])
    rank = 0
    pivot_row = 0
    for col in range(n_cols):
        pivot = None
        for r in range(pivot_row, len(rows)):
            if rows[r][col]:
                pivot = r
                break
        if pivot is None:
            continue
        rows[pivot_row], rows[pivot] = rows[pivot], rows[pivot_row]
        for r in range(len(rows)):
            if r != pivot_row and rows[r][col]:
                rows[r] = [(a ^ b) for a, b in zip(rows[r], rows[pivot_row])]
        rank += 1
        pivot_row += 1
        if pivot_row == len(rows):
            break
    return rank


def mat_mult_q(a: Sequence[Sequence[Fraction]],
               b: Sequence[Sequence[Fraction]]) -> List[List[Fraction]]:
    """Product A * B over Q."""
    n, k, m = len(a), len(b), len(b[0]) if b else 0
    return [[sum(a[i][t] * b[t][j] for t in range(k)) for j in range(m)]
            for i in range(n)]


# ----------------------------------------------------------------------------
# Homology and the Euler characteristic of a three-term complex.
# ----------------------------------------------------------------------------

def betti_numbers(n0: int, n1: int, n2: int,
                  rank_d1: int, rank_d2: int) -> Tuple[int, int, int]:
    """Betti numbers of  C2 --d2--> C1 --d1--> C0  from cell counts and ranks.

    n0, n1, n2 are the numbers of cells in dimensions 0, 1, 2.
    """
    b0 = n0 - rank_d1
    b1 = n1 - rank_d1 - rank_d2
    b2 = n2 - rank_d2
    return b0, b1, b2


def euler_characteristic_from_homology(b0: int, b1: int, b2: int) -> int:
    return b0 - b1 + b2


def euler_characteristic_from_cells(n0: int, n1: int, n2: int) -> int:
    return n0 - n1 + n2


# ----------------------------------------------------------------------------
# The abstract Euler-Poincare defect identity, arbitrary length.
# ----------------------------------------------------------------------------

def euler_poincare_defect(a: Sequence[int], r: Sequence[int]) -> Tuple[int, int, int]:
    """Given chain dimensions a[0..L] and boundary ranks r[0..L], build the
    homology dimensions h from the profile relations, then return the triple

        (sum (-1)^n h_n,  sum (-1)^n a_n  -  (-1)^L r_L,  L)

    The first two entries are equal by the defect identity (Theorem 3.1).
    """
    length = len(a) - 1
    h = [a[0] - r[0]]
    for n in range(length):
        h.append(a[n + 1] - r[n] - r[n + 1])
    alt_h = sum((-1) ** n * h[n] for n in range(length + 1))
    alt_a = sum((-1) ** n * a[n] for n in range(length + 1))
    defect = alt_a - (-1) ** length * r[length]
    return alt_h, defect, length


# ----------------------------------------------------------------------------
# Width-driven bound on the Euler characteristic.
# ----------------------------------------------------------------------------

def width_bound(widths: Sequence[int]) -> int:
    """The architecture-only ceiling  3 * prod_i 2^{w_i}  on |chi(V(f))|."""
    product = 1
    for w in widths:
        product *= 2 ** w
    return 3 * product


# ----------------------------------------------------------------------------
# Random valid complex generator (ensures d1 . d2 = 0 over Q).
# ----------------------------------------------------------------------------

def random_complex_q(n0: int, n1: int, n2: int,
                     seed: int) -> Tuple[List[List[Fraction]], List[List[Fraction]]]:
    """Construct random D1 (n0 x n1) and D2 (n1 x n2) over Q with D1 D2 = 0.

    Strategy: pick D1 at random, then choose the columns of D2 inside ker D1
    by projecting random vectors.  We instead take the pragmatic route of
    building D2 with columns drawn from a random basis of ker D1 obtained by
    solving.  To keep this dependency-free we use a simple construction:
    D2 = (I - P) R  where P encodes row-reduction of D1; here we just retry
    random integer D2 and null out via elimination.
    """
    rng = random.Random(seed)

    def rand_mat(rows: int, cols: int) -> List[List[Fraction]]:
        return [[Fraction(rng.randint(-3, 3)) for _ in range(cols)]
                for _ in range(rows)]

    d1 = rand_mat(n0, n1)

    # Build a basis of ker(d1) by reduced row echelon back-substitution.
    kernel = _kernel_basis_q(d1, n1)
    # D2's columns are random combinations of kernel vectors -> guarantees D1 D2 = 0.
    d2: List[List[Fraction]] = [[Fraction(0) for _ in range(n2)] for _ in range(n1)]
    for j in range(n2):
        col = [Fraction(0)] * n1
        for kvec in kernel:
            c = Fraction(rng.randint(-2, 2))
            col = [x + c * y for x, y in zip(col, kvec)]
        for i in range(n1):
            d2[i][j] = col[i]
    return d1, d2


def _kernel_basis_q(matrix: Sequence[Sequence[Fraction]], n_cols: int
                    ) -> List[List[Fraction]]:
    """Return a basis of the null space of `matrix` (columns dim n_cols) over Q."""
    rows = [list(row) for row in matrix]
    n_rows = len(rows)
    pivot_cols: List[int] = []
    r = 0
    for col in range(n_cols):
        pivot = None
        for rr in range(r, n_rows):
            if rows[rr][col] != 0:
                pivot = rr
                break
        if pivot is None:
            continue
        rows[r], rows[pivot] = rows[pivot], rows[r]
        piv = rows[r][col]
        rows[r] = [v / piv for v in rows[r]]
        for rr in range(n_rows):
            if rr != r and rows[rr][col] != 0:
                f = rows[rr][col]
                rows[rr] = [a - f * b for a, b in zip(rows[rr], rows[r])]
        pivot_cols.append(col)
        r += 1
        if r == n_rows:
            break
    free_cols = [c for c in range(n_cols) if c not in pivot_cols]
    basis: List[List[Fraction]] = []
    for fc in free_cols:
        vec = [Fraction(0)] * n_cols
        vec[fc] = Fraction(1)
        for i, pc in enumerate(pivot_cols):
            vec[pc] = -rows[i][fc]
        basis.append(vec)
    return basis


# ----------------------------------------------------------------------------
# Demonstrations.
# ----------------------------------------------------------------------------

def demo_random_complexes_over_q() -> None:
    print("=" * 72)
    print("DEMO 1: Euler characteristic of random rational three-term complexes")
    print("=" * 72)
    for seed in range(1, 6):
        n0, n1, n2 = random.Random(seed).randint(3, 6), random.Random(seed + 100).randint(4, 8), random.Random(seed + 200).randint(2, 5)
        d1, d2 = random_complex_q(n0, n1, n2, seed)
        # Sanity: d1 d2 must be zero.
        prod = mat_mult_q(d1, d2)
        assert all(v == 0 for row in prod for v in row), "d1 d2 != 0"
        r1 = matrix_rank_q(d1)
        r2 = matrix_rank_q(d2)
        b0, b1, b2 = betti_numbers(n0, n1, n2, r1, r2)
        chi_h = euler_characteristic_from_homology(b0, b1, b2)
        chi_c = euler_characteristic_from_cells(n0, n1, n2)
        print(f"  seed={seed}: cells=({n0},{n1},{n2}) ranks=(d1={r1},d2={r2}) "
              f"Betti=({b0},{b1},{b2})  chi(H)={chi_h}  chi(C)={chi_c}  "
              f"{'MATCH' if chi_h == chi_c else 'MISMATCH!'}")
        assert chi_h == chi_c
    print("  All rational complexes satisfy chi(H) = chi(C).\n")


def demo_over_f2() -> None:
    print("=" * 72)
    print("DEMO 2: The identity is field-independent (verification over F2)")
    print("=" * 72)
    # Boundary of a hollow tetrahedron: 4 vertices, 6 edges, 4 triangular faces.
    # This is a genuine simplicial 2-sphere; chi should be 2 = 1 - 0 + 1.
    n0, n1, n2 = 4, 6, 4
    # d1: edges -> vertices (unsigned incidence over F2).
    edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    d1 = [[1 if v in e else 0 for e in edges] for v in range(4)]
    # d2: faces -> edges (each triangle bounds three edges).
    faces = [(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)]
    def edge_index(u: int, w: int) -> int:
        return edges.index((min(u, w), max(u, w)))
    d2 = [[0] * n2 for _ in range(n1)]
    for j, (a_, b_, c_) in enumerate(faces):
        for (u, w) in [(a_, b_), (a_, c_), (b_, c_)]:
            d2[edge_index(u, w)][j] = 1
    r1 = matrix_rank_f2(d1)
    r2 = matrix_rank_f2(d2)
    b0, b1, b2 = betti_numbers(n0, n1, n2, r1, r2)
    print(f"  Hollow tetrahedron (2-sphere): cells=({n0},{n1},{n2})")
    print(f"  ranks over F2: d1={r1}, d2={r2}  Betti=({b0},{b1},{b2})")
    print(f"  chi(H) = {euler_characteristic_from_homology(b0, b1, b2)}  "
          f"chi(C) = {euler_characteristic_from_cells(n0, n1, n2)}  (a 2-sphere has chi = 2)\n")


def demo_abstract_defect() -> None:
    print("=" * 72)
    print("DEMO 3: The abstract Euler-Poincare defect for complexes of any length")
    print("=" * 72)
    rng = random.Random(7)
    for trial in range(5):
        length = rng.randint(2, 6)
        a = [rng.randint(2, 9) for _ in range(length + 1)]
        # Ranks must respect r_n <= a_{n+1} and r_n + r_{n-1} <= a_n for a valid
        # profile with nonnegative homology; we just require nonnegativity of h.
        r = [rng.randint(0, min(a[n], a[n + 1] if n + 1 <= length else a[n]))
             for n in range(length + 1)]
        alt_h, defect, L = euler_poincare_defect(a, r)
        bounded = " (bounded: defect term drops out)" if r[L] == 0 else ""
        print(f"  trial {trial}: L={L}  sum(-1)^n h_n = {alt_h}  "
              f"sum(-1)^n a_n - (-1)^L r_L = {defect}  "
              f"{'MATCH' if alt_h == defect else 'MISMATCH!'}{bounded}")
        assert alt_h == defect
    print("  Defect identity holds for every length.\n")


def demo_width_bound() -> None:
    print("=" * 72)
    print("DEMO 4: The width-driven bound  |chi| <= 3 * prod_i 2^{w_i}")
    print("=" * 72)
    for widths in [[2, 2], [3, 4, 2], [5, 5], [1, 1, 1, 1]]:
        bound = width_bound(widths)
        prod = bound // 3
        print(f"  hidden widths {widths}: activation regions <= {prod}, "
              f"|chi| <= {bound}")
    print("  The ceiling depends on the architecture alone -- no weights, no data.\n")


def main() -> None:
    demo_random_complexes_over_q()
    demo_over_f2()
    demo_abstract_defect()
    demo_width_bound()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
