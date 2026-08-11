"""
Numerical demonstrations for
"The CSS Dictionary, Homological Distance, and the Hypercube Code".

Everything here is elementary linear algebra over the two-element field F_2,
written from scratch with no external dependencies (standard library only).

The script demonstrates, by direct computation:

  1. The CSS dictionary.  For a pair of binary parity-check matrices
     (H_X, H_Z) the three conditions
        (a) rowspace(H_Z) subset of ker(H_X)      [nested classical codes]
        (b) H_X H_Z^T = 0                          [matrix orthogonality]
        (c) the generated Pauli group is isotropic [abelian stabilizer]
     agree on every example tested.

  2. The dimension formula  k + rank(H_X) + rank(H_Z) = N.

  3. The distance theorem  d = min(d_X, d_Z), where d is the least weight of
     an undetectable non-stabilizer Pauli error and d_X, d_Z are the
     single-sector (systolic / cosystolic) distances.

  4. The Steane code: from the [7,4,3] Hamming check matrix one gets
     exactly [[7, 1, 3]].

  5. The hypercube homological code Q_n: N = n 2^(n-1) physical qubits,
     rank(d_1) = 2^n - 1, k = 2^(n-1)(n-2) + 1, and distance exactly 1,
     even though the cube graph has girth 4.

  6. The graph obstruction: an incidence matrix of a graph always satisfies
     rank(M) + 1 <= |V|, so a CSS code with independent X-checks (such as the
     Steane code) admits no graph model.

  7. The quantum Singleton comparison at the correct block length.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Vector = Tuple[int, ...]
Matrix = List[List[int]]


# ----------------------------------------------------------------------
# Basic F_2 linear algebra
# ----------------------------------------------------------------------

def mat_vec(M: Matrix, v: Sequence[int]) -> Vector:
    """Matrix-vector product over F_2."""
    return tuple(sum(row[j] * v[j] for j in range(len(v))) % 2 for row in M)


def transpose(M: Matrix) -> Matrix:
    """Transpose of a matrix."""
    if not M:
        return []
    return [[M[i][j] for i in range(len(M))] for j in range(len(M[0]))]


def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Matrix product over F_2."""
    n = len(B)
    p = len(B[0]) if B else 0
    return [[sum(A[i][k] * B[k][j] for k in range(n)) % 2 for j in range(p)]
            for i in range(len(A))]


def is_zero(M: Matrix) -> bool:
    """Test whether every entry vanishes."""
    return all(x % 2 == 0 for row in M for x in row)


def rank_f2(M: Matrix) -> int:
    """Rank over F_2 by Gaussian elimination.  Complexity O(m n min(m,n))."""
    rows = [row[:] for row in M]
    if not rows or not rows[0]:
        return 0
    ncols = len(rows[0])
    rank = 0
    pivot_row = 0
    for col in range(ncols):
        pivot = None
        for r in range(pivot_row, len(rows)):
            if rows[r][col] % 2 == 1:
                pivot = r
                break
        if pivot is None:
            continue
        rows[pivot_row], rows[pivot] = rows[pivot], rows[pivot_row]
        for r in range(len(rows)):
            if r != pivot_row and rows[r][col] % 2 == 1:
                rows[r] = [(a + b) % 2 for a, b in zip(rows[r], rows[pivot_row])]
        pivot_row += 1
        rank += 1
        if pivot_row == len(rows):
            break
    return rank


def all_vectors(n: int) -> Iterable[Vector]:
    """Enumerate F_2^n (2^n vectors)."""
    return product((0, 1), repeat=n)


def row_space(M: Matrix, n: int) -> set:
    """All F_2 combinations of the rows of M, as a set of length-n tuples."""
    space = {tuple([0] * n)}
    for row in M:
        r = tuple(x % 2 for x in row)
        space |= {tuple((a + b) % 2 for a, b in zip(v, r)) for v in space}
    return space


def kernel(M: Matrix, n: int) -> set:
    """All v in F_2^n with M v = 0 (brute force; use for small n)."""
    return {v for v in all_vectors(n) if all(x == 0 for x in mat_vec(M, v))}


def weight(v: Sequence[int]) -> int:
    """Hamming weight."""
    return sum(1 for x in v if x % 2 == 1)


def pair_weight(a: Sequence[int], b: Sequence[int]) -> int:
    """Weight of the Pauli operator (a | b): qubits where it acts nontrivially."""
    return sum(1 for x, y in zip(a, b) if x % 2 == 1 or y % 2 == 1)


# ----------------------------------------------------------------------
# The CSS dictionary
# ----------------------------------------------------------------------

def commutes(hx: Matrix, hz: Matrix) -> bool:
    """Condition (b): H_X H_Z^T = 0."""
    return is_zero(mat_mul(hx, transpose(hz)))


def nested_codes(hx: Matrix, hz: Matrix, n: int) -> bool:
    """Condition (a): rowspace(H_Z) is contained in ker(H_X)."""
    return all(all(x == 0 for x in mat_vec(hx, w)) for w in row_space(hz, n))


def symplectic(p: Tuple[Vector, Vector], q: Tuple[Vector, Vector]) -> int:
    """Pauli commutation form <(a1|b1), (a2|b2)> = a1.b2 + a2.b1 over F_2."""
    a1, b1 = p
    a2, b2 = q
    return (sum(x * y for x, y in zip(a1, b2)) +
            sum(x * y for x, y in zip(a2, b1))) % 2


def stabilizer_group(hx: Matrix, hz: Matrix, n: int) -> List[Tuple[Vector, Vector]]:
    """The additive group generated by the X-checks and Z-checks."""
    xs = sorted(row_space(hx, n))
    zs = sorted(row_space(hz, n))
    return [(a, b) for a in xs for b in zs]


def isotropic(hx: Matrix, hz: Matrix, n: int) -> bool:
    """Condition (c): the generated Pauli group is abelian."""
    group = stabilizer_group(hx, hz, n)
    return all(symplectic(p, q) == 0 for p in group for q in group)


# ----------------------------------------------------------------------
# CSS parameters
# ----------------------------------------------------------------------

def num_logical(hx: Matrix, hz: Matrix, n: int) -> int:
    """k = N - rank(H_X) - rank(H_Z)."""
    return n - rank_f2(hx) - rank_f2(hz)


def dX(hx: Matrix, hz: Matrix, n: int) -> int:
    """Primal (systolic) distance: min weight of a in ker(H_Z) \\ rowspace(H_X)."""
    trivial = row_space(hx, n)
    best = None
    for a in all_vectors(n):
        if hz and any(x != 0 for x in mat_vec(hz, a)):
            continue
        if a in trivial:
            continue
        w = weight(a)
        if best is None or w < best:
            best = w
    return -1 if best is None else best


def dZ(hx: Matrix, hz: Matrix, n: int) -> int:
    """Dual (cosystolic) distance: min weight of b in ker(H_X) \\ rowspace(H_Z)."""
    trivial = row_space(hz, n)
    best = None
    for b in all_vectors(n):
        if hx and any(x != 0 for x in mat_vec(hx, b)):
            continue
        if b in trivial:
            continue
        w = weight(b)
        if best is None or w < best:
            best = w
    return -1 if best is None else best


def css_distance(hx: Matrix, hz: Matrix, n: int) -> int:
    """Operational distance: min pair-weight of an undetectable non-stabilizer."""
    triv_x = row_space(hx, n)
    triv_z = row_space(hz, n)
    ker_z = [a for a in all_vectors(n)
             if not hz or all(x == 0 for x in mat_vec(hz, a))]
    ker_x = [b for b in all_vectors(n)
             if not hx or all(x == 0 for x in mat_vec(hx, b))]
    best = None
    for a in ker_z:
        for b in ker_x:
            if a in triv_x and b in triv_z:
                continue          # a genuine stabilizer, not a logical error
            w = pair_weight(a, b)
            if best is None or w < best:
                best = w
    return -1 if best is None else best


# ----------------------------------------------------------------------
# Examples: the Steane code
# ----------------------------------------------------------------------

STEANE_H: Matrix = [
    [1, 0, 1, 0, 1, 0, 1],
    [0, 1, 1, 0, 0, 1, 1],
    [0, 0, 0, 1, 1, 1, 1],
]


# ----------------------------------------------------------------------
# Examples: the hypercube graph code
# ----------------------------------------------------------------------

def hypercube_vertices(n: int) -> List[Vector]:
    """The 2^n vertices of Q_n, as bit strings."""
    return list(all_vectors(n))


def hypercube_edges(n: int) -> List[Tuple[Vector, int]]:
    """Edges of Q_n, named by (lower endpoint x with x_i = 0, direction i)."""
    return [(x, i) for i in range(n) for x in all_vectors(n) if x[i] == 0]


def flip(x: Vector, i: int) -> Vector:
    """Flip the i-th coordinate of a bit string."""
    y = list(x)
    y[i] ^= 1
    return tuple(y)


def hypercube_incidence(n: int) -> Matrix:
    """The boundary matrix d_1 of Q_n over F_2: rows = vertices, cols = edges."""
    verts = hypercube_vertices(n)
    index: Dict[Vector, int] = {v: k for k, v in enumerate(verts)}
    edges = hypercube_edges(n)
    M: Matrix = [[0] * len(edges) for _ in verts]
    for c, (x, i) in enumerate(edges):
        M[index[x]][c] ^= 1
        M[index[flip(x, i)]][c] ^= 1
    return M


def is_graph_incidence(M: Matrix) -> bool:
    """Every column is the indicator of two distinct vertices."""
    if not M:
        return False
    ncols = len(M[0])
    for c in range(ncols):
        col = [M[r][c] % 2 for r in range(len(M))]
        if sum(col) != 2:
            return False
    return True


# ----------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------

def banner(text: str) -> None:
    print()
    print("=" * 72)
    print(text)
    print("=" * 72)


def demo_dictionary() -> None:
    banner("1.  The CSS dictionary: three equivalent conditions")
    tests: List[Tuple[str, Matrix, Matrix, int]] = [
        ("Steane  (H_X = H_Z = Hamming)", STEANE_H, STEANE_H, 7),
        ("Shor-like pair (commuting)", [[1, 1, 1, 1]], [[1, 1, 0, 0], [0, 0, 1, 1]], 4),
        ("Non-commuting pair", [[1, 1, 0, 0]], [[1, 0, 0, 0]], 4),
        ("Repetition / trivial Z", [[1, 1, 0], [0, 1, 1]], [[0, 0, 0]], 3),
    ]
    print(f"{'example':34s} {'nested':>8s} {'HxHz^T=0':>10s} {'isotropic':>10s}")
    for name, hx, hz, n in tests:
        a = nested_codes(hx, hz, n)
        b = commutes(hx, hz)
        c = isotropic(hx, hz, n)
        print(f"{name:34s} {str(a):>8s} {str(b):>10s} {str(c):>10s}")
        assert a == b == c, "the dictionary failed!"
    print("\nAll three conditions agree on every example: the dictionary holds.")


def demo_steane() -> None:
    banner("2.  The Steane code is [[7, 1, 3]]")
    print("H =")
    for row in STEANE_H:
        print("   ", row)
    print("\nH H^T =", mat_mul(STEANE_H, transpose(STEANE_H)))
    assert commutes(STEANE_H, STEANE_H)
    r = rank_f2(STEANE_H)
    k = num_logical(STEANE_H, STEANE_H, 7)
    print(f"rank H            = {r}")
    print(f"k = N - 2 rank H  = 7 - {r} - {r} = {k}")
    dx = dX(STEANE_H, STEANE_H, 7)
    dz = dZ(STEANE_H, STEANE_H, 7)
    d = css_distance(STEANE_H, STEANE_H, 7)
    print(f"d_X (systole)     = {dx}")
    print(f"d_Z (cosystole)   = {dz}")
    print(f"d   (operational) = {d}   [ = min(d_X, d_Z) = {min(dx, dz)} ]")
    assert (k, d) == (1, 3) and d == min(dx, dz)
    print(f"\nQuantum Singleton: k + 2(d-1) = {k + 2 * (d - 1)} <= N = 7   "
          f"(slack {7 - k - 2 * (d - 1)}, so not quantum-MDS)")


def demo_hypercube() -> None:
    banner("3.  The hypercube homological code Q_n")
    print(f"{'n':>3s} {'N=n2^(n-1)':>11s} {'rank d_1':>9s} {'2^n-1':>7s} "
          f"{'k':>6s} {'2^(n-1)(n-2)+1':>15s} {'d_X':>5s} {'d':>4s}")
    for n in range(2, 6):
        M = hypercube_incidence(n)
        N = n * 2 ** (n - 1)
        r = rank_f2(M)
        k = N - r                      # no Z-checks: k = N - rank d_1
        closed = 2 ** (n - 1) * (n - 2) + 1
        assert r == 2 ** n - 1 and k == closed
        if n <= 3:
            no_z: Matrix = []
            dx = dX(M, no_z, N)
            d = css_distance(M, no_z, N)
        else:
            dx = d = -1                 # brute force too large; theory gives 1
        dxs = str(dx) if dx >= 0 else "1*"
        ds = str(d) if d >= 0 else "1*"
        print(f"{n:>3d} {N:>11d} {r:>9d} {2 ** n - 1:>7d} {k:>6d} "
              f"{closed:>15d} {dxs:>5s} {ds:>4s}")
    print("\n(* = value predicted by the theorem; brute force skipped for size.)")
    print("The cube graph has girth 4, yet the code distance is 1: a single edge")
    print("is never a cut of a bridgeless graph, so it is an undetectable error")
    print("that is not a stabilizer.")


def demo_graph_obstruction() -> None:
    banner("4.  Not every CSS complex comes from a graph")
    M = hypercube_incidence(3)
    print("Q_3 boundary matrix: every column has weight 2 ->",
          is_graph_incidence(M))
    print(f"   rank + 1 = {rank_f2(M) + 1} <= |V| = {len(M)}   (equality: Q_3 connected)")
    print("\nSteane H: columns have weights",
          [sum(STEANE_H[r][c] for r in range(3)) for c in range(7)])
    print("   is a graph incidence matrix ->", is_graph_incidence(STEANE_H))
    print(f"   rank H = {rank_f2(STEANE_H)} = number of rows, so rank + 1 > |V|:")
    print("   the Steane code has NO graph model, on any vertex set.")
    assert rank_f2(STEANE_H) == len(STEANE_H)
    print("\nMinimal counterexample: the 1x1 matrix [1] is a perfectly good")
    print("binary differential but cannot be a graph incidence matrix, since one")
    print("column would have to mark two distinct vertices among a single vertex.")


def demo_distance_theorem() -> None:
    banner("5.  d = min(d_X, d_Z) on a family of random-ish small codes")
    examples: List[Tuple[str, Matrix, Matrix, int]] = [
        ("Steane", STEANE_H, STEANE_H, 7),
        ("4-qubit [[4,2,2]]", [[1, 1, 1, 1]], [[1, 1, 1, 1]], 4),
        ("Q_2 graph code", hypercube_incidence(2), [], 4),
        ("Q_3 graph code", hypercube_incidence(3), [], 12),
        ("degenerate k = 0", [[1, 1, 0], [0, 1, 1]], [[1, 1, 1]], 3),
    ]
    print(f"{'code':20s} {'N':>4s} {'k':>4s} {'d_X':>5s} {'d_Z':>5s} {'d':>4s} "
          f"{'min':>5s}")
    for name, hx, hz, n in examples:
        k = n - rank_f2(hx) - (rank_f2(hz) if hz else 0)
        dx = dX(hx, hz, n)
        dz = dZ(hx, hz, n)
        d = css_distance(hx, hz, n)
        present = [x for x in (dx, dz) if x >= 0]
        m = min(present) if present else -1
        print(f"{name:20s} {n:>4d} {k:>4d} {dx:>5d} {dz:>5d} {d:>4d} {m:>5d}")
        assert d == m
    print("\n(-1 marks an empty minimisation.)  Whenever logical qubits exist, the")
    print("operational distance equals the smaller of the two single-sector")
    print("distances, exactly as the distance theorem predicts.  The last row is")
    print("the degenerate case k = 0: no logical operators exist at all, the")
    print("nondegeneracy hypotheses fail, and the distance is undefined.")


def main() -> None:
    demo_dictionary()
    demo_steane()
    demo_hypercube()
    demo_graph_obstruction()
    demo_distance_theorem()
    banner("All checks passed.")


if __name__ == "__main__":
    main()
