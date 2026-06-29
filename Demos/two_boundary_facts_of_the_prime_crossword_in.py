"""
Numerical demonstrations of the MDS--Uncertainty Theorem.

For a square matrix M over a finite field F_p, we illustrate:

  * IsMDS:  every square submatrix has nonzero determinant.
  * The strongest additive uncertainty bound:
        |supp(f)| + |supp(M f)| >= n + 1   for every nonzero f.
  * mds_iff_uncertainty:  MDS  <=>  the n+1 bound holds for all nonzero f.
  * not_mds_implies_violator:  a non-MDS matrix admits a vector f with
        |supp(f)| + |supp(M f)| <= n   (constructed from a singular minor).
  * singleton_bound (tightness):  the unit spike e_0 attains <= n+1.
  * mds_transpose:  the transpose of an MDS matrix is MDS.

Everything is exact arithmetic over F_p (no floating point), so all
assertions are mathematically rigorous within the demo's finite scope.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import List, Optional, Sequence, Tuple

Vector = List[int]
Matrix = List[List[int]]


# --------------------------------------------------------------------------- #
# Finite field F_p arithmetic                                                  #
# --------------------------------------------------------------------------- #
def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a (mod p) for prime p, via Fermat."""
    return pow(a % p, p - 2, p)


def mat_det(M: Matrix, p: int) -> int:
    """Determinant of a square matrix over F_p by Gaussian elimination."""
    n = len(M)
    A = [[x % p for x in row] for row in M]
    det = 1
    for col in range(n):
        pivot = next((r for r in range(col, n) if A[r][col] % p != 0), None)
        if pivot is None:
            return 0
        if pivot != col:
            A[col], A[pivot] = A[pivot], A[col]
            det = (-det) % p
        det = (det * A[col][col]) % p
        inv = inv_mod(A[col][col], p)
        for r in range(col + 1, n):
            factor = (A[r][col] * inv) % p
            if factor:
                A[r] = [(A[r][k] - factor * A[col][k]) % p for k in range(n)]
    return det % p


def matvec(M: Matrix, f: Vector, p: int) -> Vector:
    """Matrix-vector product over F_p."""
    n = len(M)
    return [sum(M[i][j] * f[j] for j in range(n)) % p for i in range(n)]


def support(v: Sequence[int], p: int) -> List[int]:
    """Indices where v is nonzero (mod p)."""
    return [i for i, x in enumerate(v) if x % p != 0]


def submatrix(M: Matrix, rows: Sequence[int], cols: Sequence[int]) -> Matrix:
    """The submatrix M[rows, cols]."""
    return [[M[r][c] for c in cols] for r in rows]


def transpose(M: Matrix) -> Matrix:
    n = len(M)
    return [[M[j][i] for j in range(n)] for i in range(n)]


# --------------------------------------------------------------------------- #
# MDS test and uncertainty test                                               #
# --------------------------------------------------------------------------- #
def is_mds(M: Matrix, p: int) -> bool:
    """True iff every square submatrix of M is invertible over F_p."""
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                if mat_det(submatrix(M, rows, cols), p) == 0:
                    return False
    return True


def min_support_sum(M: Matrix, p: int) -> Tuple[int, Optional[Vector]]:
    """
    Brute force over all nonzero f in F_p^n the minimum of
    |supp(f)| + |supp(M f)|, returning the minimum and a minimizer.
    """
    n = len(M)
    best = 2 * n + 5
    best_f: Optional[Vector] = None
    for f in product(range(p), repeat=n):
        if all(x == 0 for x in f):
            continue
        fv = list(f)
        s = len(support(fv, p)) + len(support(matvec(M, fv, p), p))
        if s < best:
            best, best_f = s, fv
    return best, best_f


def satisfies_uncertainty(M: Matrix, p: int, bound: int) -> bool:
    """Check |supp(f)| + |supp(Mf)| >= bound for every nonzero f."""
    return min_support_sum(M, p)[0] >= bound


# --------------------------------------------------------------------------- #
# Constructive violator (proof of not_mds_implies_violator)                    #
# --------------------------------------------------------------------------- #
def kernel_vector(A: Matrix, p: int) -> Optional[Vector]:
    """A nonzero kernel vector of square A over F_p, or None if invertible."""
    n = len(A)
    M = [[x % p for x in row] for row in A]
    where = [-1] * n
    row = 0
    for col in range(n):
        piv = next((r for r in range(row, n) if M[r][col] % p != 0), None)
        if piv is None:
            continue
        M[row], M[piv] = M[piv], M[row]
        inv = inv_mod(M[row][col], p)
        M[row] = [(x * inv) % p for x in M[row]]
        for r in range(n):
            if r != row and M[r][col] % p != 0:
                f = M[r][col]
                M[r] = [(M[r][k] - f * M[row][k]) % p for k in range(n)]
        where[col] = row
        row += 1
    free = next((c for c in range(n) if where[c] == -1), None)
    if free is None:
        return None  # full rank, no nontrivial kernel
    x = [0] * n
    x[free] = 1
    for col in range(n):
        if where[col] != -1:
            x[col] = (-M[where[col]][free]) % p
    return x


def construct_violator(M: Matrix, p: int) -> Optional[Vector]:
    """
    If M is not MDS, find a singular submatrix M[rows, cols], take a kernel
    vector v, and inflate it (zero-padding outside `cols`) to a vector f with
    |supp(f)| + |supp(Mf)| <= n.
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = submatrix(M, rows, cols)
                if mat_det(sub, p) == 0:
                    v = kernel_vector(sub, p)
                    if v is None:
                        continue
                    f = [0] * n
                    for idx, c in enumerate(cols):
                        f[c] = v[idx] % p
                    if any(x % p for x in f):
                        return f
    return None


# --------------------------------------------------------------------------- #
# Example matrices                                                             #
# --------------------------------------------------------------------------- #
def vandermonde(nodes: Sequence[int], n: int, p: int) -> Matrix:
    """Vandermonde matrix V[i][j] = nodes[i]^j (an MDS / Reed-Solomon matrix)."""
    return [[pow(nodes[i], j, p) for j in range(n)] for i in range(n)]


def cauchy(xs: Sequence[int], ys: Sequence[int], p: int) -> Matrix:
    """Cauchy matrix C[i][j] = 1/(xs[i] - ys[j]) (also MDS when entries valid)."""
    return [[inv_mod((xs[i] - ys[j]) % p, p) for j in range(len(ys))]
            for i in range(len(xs))]


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_cauchy_uncertainty() -> None:
    print("=" * 70)
    print("DEMO 1: An MDS (Cauchy) matrix obeys the n+1 uncertainty bound")
    print("=" * 70)
    p = 11
    xs, ys = [1, 2, 3, 4], [5, 6, 7, 8]
    C = cauchy(xs, ys, p)
    n = len(C)
    print(f"Field F_{p}, n = {n}, xs = {xs}, ys = {ys}")
    for row in C:
        print("   ", row)
    mds = is_mds(C, p)
    m, fmin = min_support_sum(C, p)
    print(f"is_mds              = {mds}")
    print(f"min support sum     = {m}  (threshold n+1 = {n + 1})")
    print(f"minimizer f         = {fmin},  Mf = {matvec(C, fmin, p)}")
    assert mds and m == n + 1
    assert satisfies_uncertainty(C, p, n + 1)
    print("OK: MDS  <=>  uncertainty bound n+1 holds, and is tight.")


def demo_vandermonde_field_size() -> None:
    print("\n" + "=" * 70)
    print("DEMO 1b: Vandermonde is MDS only over a large enough field")
    print("=" * 70)
    nodes = [1, 2, 3, 4]
    n = 4
    for p in (7, 11, 13):
        V = vandermonde(nodes, n, p)
        print(f"  p = {p:2d}:  is_mds(Vandermonde) = {is_mds(V, p)}")
    print("Vandermonde minors are Schur polynomials in the nodes; they can")
    print("vanish modulo small primes, so MDS-ness depends on field size.")


def demo_cauchy_mds() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: Cauchy matrix is MDS")
    print("=" * 70)
    p = 11
    xs, ys = [1, 2, 3], [4, 5, 6]
    C = cauchy(xs, ys, p)
    print(f"Field F_{p}, xs = {xs}, ys = {ys}")
    for row in C:
        print("   ", row)
    n = len(C)
    print(f"is_mds          = {is_mds(C, p)}")
    print(f"min support sum = {min_support_sum(C, p)[0]} (threshold {n + 1})")
    assert is_mds(C, p)
    assert satisfies_uncertainty(C, p, n + 1)
    print("OK.")


def demo_non_mds_violator() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: A non-MDS matrix and its constructed violator")
    print("=" * 70)
    p, n = 7, 3
    # Identity-like matrix: many 1x1 zero minors (off-diagonal zeros) => not MDS.
    M = [[1, 0, 0],
         [0, 1, 0],
         [0, 0, 1]]
    print(f"Field F_{p}, M = identity (off-diagonal 1x1 minors vanish):")
    for row in M:
        print("   ", row)
    print(f"is_mds = {is_mds(M, p)}")
    assert not is_mds(M, p)
    f = construct_violator(M, p)
    s = len(support(f, p)) + len(support(matvec(M, f, p), p))
    print(f"violator f = {f},  Mf = {matvec(M, f, p)}")
    print(f"|supp(f)| + |supp(Mf)| = {s}  <=  n = {n}  (beats the n+1 bound)")
    assert f is not None and s <= n
    print("OK: not_mds_implies_violator confirmed.")


def demo_transpose_and_invertible() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4: mds_transpose and mds_invertible")
    print("=" * 70)
    p = 11
    V = cauchy([1, 2, 3, 4], [5, 6, 7, 8], p)
    VT = transpose(V)
    print(f"is_mds(C)        = {is_mds(V, p)}")
    print(f"is_mds(C^T)      = {is_mds(VT, p)}")
    print(f"det(C) mod {p}    = {mat_det(V, p)}  (nonzero => invertible)")
    assert is_mds(V, p) and is_mds(VT, p) and mat_det(V, p) != 0
    print("OK: MDS is transpose-stable and implies invertibility.")


def demo_iff_sweep() -> None:
    print("\n" + "=" * 70)
    print("DEMO 5: mds_iff_uncertainty over a random-ish sweep")
    print("=" * 70)
    p, n = 3, 3
    checked = 0
    for entries in product(range(p), repeat=n * n):
        M = [list(entries[i * n:(i + 1) * n]) for i in range(n)]
        lhs = is_mds(M, p)
        rhs = satisfies_uncertainty(M, p, n + 1)
        assert lhs == rhs, (M, lhs, rhs)
        checked += 1
    print(f"Checked all {checked} matrices in F_{p}^({n}x{n}):")
    print("  is_mds(M)  ==  satisfies_uncertainty(M, n+1)  for EVERY matrix.")
    print("OK: the equivalence is verified exhaustively.")


if __name__ == "__main__":
    demo_cauchy_uncertainty()
    demo_vandermonde_field_size()
    demo_cauchy_mds()
    demo_non_mds_violator()
    demo_transpose_and_invertible()
    demo_iff_sweep()
    print("\nAll demonstrations passed.")
