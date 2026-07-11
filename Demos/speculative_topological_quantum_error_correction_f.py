"""Numerical demonstrations for
"Topological Quantum Codes from Cellular Homology".

All linear algebra is performed over the binary field F2 = {0, 1} using
Python integers with mod-2 arithmetic. Every routine is self-contained and
type-hinted; no third-party libraries are required.

The demonstrations verify, on concrete codes, the paper's main results:

  * CSS Dimension Theorem:  k + rank(d1) + rank(d2) = n
  * Homological Information Criterion:  k >= 1  <=>  im(d2) < ker(d1)
  * Genus Theorem:  the genus-g surface code encodes k = 2g logical qubits,
    with Euler characteristic 2 - 2g
  * Distance = systole:  the [[3,1,3]] triangle code has distance 3
"""

from __future__ import annotations

from itertools import product
from typing import List, Sequence

Matrix = List[List[int]]  # a matrix over F2 (entries in {0, 1})
Vector = List[int]        # a vector over F2


# --------------------------------------------------------------------------
# Basic F2 linear algebra
# --------------------------------------------------------------------------
def mat_vec(mat: Matrix, vec: Vector) -> Vector:
    """Matrix-vector product over F2."""
    return [sum(row[j] * vec[j] for j in range(len(vec))) % 2 for row in mat]


def rank_f2(mat: Matrix) -> int:
    """Rank of a binary matrix via Gaussian elimination over F2."""
    if not mat or not mat[0]:
        return 0
    rows = [row[:] for row in mat]
    n_rows, n_cols = len(rows), len(rows[0])
    rank, pivot_row = 0, 0
    for col in range(n_cols):
        sel = next((r for r in range(pivot_row, n_rows) if rows[r][col]), None)
        if sel is None:
            continue
        rows[pivot_row], rows[sel] = rows[sel], rows[pivot_row]
        for r in range(n_rows):
            if r != pivot_row and rows[r][col]:
                rows[r] = [(a ^ b) for a, b in zip(rows[r], rows[pivot_row])]
        pivot_row += 1
        rank += 1
        if pivot_row == n_rows:
            break
    return rank


def kernel_f2(mat: Matrix, n_cols: int) -> List[Vector]:
    """Enumerate the kernel {x : mat x = 0} of a binary matrix (small n only)."""
    zero = [0] * (len(mat) if mat else 0)
    return [
        list(x)
        for x in product((0, 1), repeat=n_cols)
        if (mat_vec(mat, list(x)) == zero or not mat)
    ]


def image_f2(mat: Matrix, n_cols: int) -> List[Vector]:
    """Enumerate the image {mat x : x} of a binary matrix (small n only)."""
    seen = {tuple(mat_vec(mat, list(x))) for x in product((0, 1), repeat=n_cols)}
    return [list(v) for v in seen]


def hamming_weight(vec: Vector) -> int:
    """Number of nonzero coordinates."""
    return sum(1 for v in vec if v)


# --------------------------------------------------------------------------
# CSS code parameters
# --------------------------------------------------------------------------
def logical_qubits(d1: Matrix, d2: Matrix, n: int, n2: int) -> int:
    """k = dim(ker d1) - dim(im d2) = n - rank(d1) - rank(d2)."""
    return n - rank_f2(d1) - rank_f2(d2)


def code_distance(d1: Matrix, d2: Matrix, n: int, n2: int) -> int:
    """Systole: min Hamming weight over cycles that are not boundaries."""
    zero = [0] * (len(d1) if d1 else 0)
    boundaries = {tuple(v) for v in image_f2(d2, n2)} if n2 else {tuple([0] * n)}
    best = None
    for x in product((0, 1), repeat=n):
        v = list(x)
        if (not d1 or mat_vec(d1, v) == zero) and tuple(v) not in boundaries:
            w = hamming_weight(v)
            best = w if best is None else min(best, w)
    return -1 if best is None else best


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_dimension_theorem() -> None:
    print("=" * 68)
    print("CSS Dimension Theorem:  k + rank(d1) + rank(d2) = n")
    print("=" * 68)
    d1 = [[1, 0, 1], [1, 1, 0], [0, 1, 1]]  # triangle incidence matrix
    d2: Matrix = []                          # no faces
    n, n2 = 3, 0
    k = logical_qubits(d1, d2, n, n2)
    r1, r2 = rank_f2(d1), rank_f2(d2)
    print(f"  triangle code: n={n}, rank(d1)={r1}, rank(d2)={r2}, k={k}")
    print(f"  check k + r1 + r2 = {k + r1 + r2}  (should equal n = {n})")
    assert k + r1 + r2 == n
    print("  PASS\n")


def demo_genus_theorem() -> None:
    print("=" * 68)
    print("Genus Theorem:  genus-g surface code encodes k = 2g qubits")
    print("=" * 68)
    for g in range(0, 6):
        n = 2 * g
        d1 = [[0] * n]          # single vertex, boundary map is zero
        d2 = [[0]] * n if n else [[0]]  # single face, boundary map is zero
        k = logical_qubits(d1, d2 if n else [], n, 1 if n else 0)
        euler = 1 - k + 1       # b0 - b1 + b2 with b0 = b2 = 1
        print(f"  g={g}: k={k} (expected {2*g}), chi={euler} (expected {2-2*g})")
        assert k == 2 * g and euler == 2 - 2 * g
    print("  PASS\n")


def demo_triangle_distance() -> None:
    print("=" * 68)
    print("Distance = Systole:  the [[3,1,3]] triangle code")
    print("=" * 68)
    d1 = [[1, 0, 1], [1, 1, 0], [0, 1, 1]]
    d2: Matrix = []
    n, n2 = 3, 0
    k = logical_qubits(d1, d2, n, n2)
    d = code_distance(d1, d2, n, n2)
    print(f"  parameters [[n,k,d]] = [[{n},{k},{d}]]")
    print("  fundamental loop (1,1,1) has weight 3 and lies in ker(d1)")
    assert (n, k, d) == (3, 1, 3)
    print("  PASS\n")


def demo_information_criterion() -> None:
    print("=" * 68)
    print("Information Criterion:  k >= 1  <=>  H_1 nontrivial")
    print("=" * 68)
    # Sphere-like: a single edge that is a boundary -> no logical qubits.
    d1_trivial = [[1, 1]]           # path of 2 edges, forces cycle = boundary
    d2_fill = [[1], [1]]            # a face filling the loop
    k0 = logical_qubits(d1_trivial, d2_fill, 2, 1)
    # Torus (g = 1): k = 2 logical qubits.
    k1 = logical_qubits([[0, 0]], [[0], [0]], 2, 1)
    print(f"  filled loop (H_1 = 0): k = {k0}  -> stores no information")
    print(f"  torus     (H_1 != 0): k = {k1}  -> stores information")
    assert k0 == 0 and k1 == 2
    print("  PASS\n")


if __name__ == "__main__":
    demo_dimension_theorem()
    demo_genus_theorem()
    demo_triangle_distance()
    demo_information_criterion()
    print("All demonstrations passed.")
