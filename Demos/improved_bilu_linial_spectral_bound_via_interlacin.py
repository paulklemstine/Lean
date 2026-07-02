"""
Numerical demonstrations for:

    "A Constructive Witness for Bilu-Linial Spectral Suppression:
     The Unbalanced 4-Cycle Attains Spectral Radius sqrt(2)"

This self-contained script verifies, by direct numerical computation, the
central claims of the paper:

  1. The signed adjacency matrix B of the unbalanced 4-cycle satisfies B^2 = 2 I.
  2. Every eigenvalue mu of B satisfies mu^2 = 2, i.e. |mu| = sqrt(2).
  3. The spectral radius sqrt(2) is strictly below the maximum-degree bound 2.
  4. The unsigned (all-+) 4-cycle saturates the degree ceiling with radius 2.
  5. The general balance/unbalance dichotomy and the moment-method intuition:
     averaging the trace of A_sigma^{2k} over all signings counts even closed
     walks, illustrating the cancellation that drives the Bilu-Linial bound.

Only the Python standard library is used (no numpy required) so the script runs
anywhere. Small dense linear algebra is implemented inline with type hints.
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import List, Sequence, Tuple

Matrix = List[List[float]]


# ---------------------------------------------------------------------------
# Minimal, dependency-free linear algebra
# ---------------------------------------------------------------------------

def zeros(n: int, m: int) -> Matrix:
    """Return an n x m matrix of zeros."""
    return [[0.0 for _ in range(m)] for _ in range(n)]


def identity(n: int) -> Matrix:
    """Return the n x n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two conformable matrices."""
    n, k, m = len(a), len(b), len(b[0])
    out = zeros(n, m)
    for i in range(n):
        for t in range(k):
            aij = a[i][t]
            if aij == 0.0:
                continue
            for j in range(m):
                out[i][j] += aij * b[t][j]
    return out


def scalar_mul(c: float, a: Matrix) -> Matrix:
    """Multiply matrix a by scalar c."""
    return [[c * x for x in row] for row in a]


def max_abs_diff(a: Matrix, b: Matrix) -> float:
    """Return the largest absolute entrywise difference of two same-shape matrices."""
    return max(abs(a[i][j] - b[i][j]) for i in range(len(a)) for j in range(len(a[0])))


def trace(a: Matrix) -> float:
    """Return the trace (sum of diagonal entries) of a square matrix."""
    return sum(a[i][i] for i in range(len(a)))


# ---------------------------------------------------------------------------
# Eigenvalues via the characteristic polynomial (n = 4 is tiny; use companion
# roots through the Faddeev-LeVerrier coefficients + numpy-free polynomial roots)
# ---------------------------------------------------------------------------

def char_poly_coeffs(a: Matrix) -> List[float]:
    """
    Faddeev-LeVerrier algorithm: return coefficients [c_n, ..., c_1, c_0] of the
    characteristic polynomial det(xI - A) = x^n + c_{n-1} x^{n-1} + ... + c_0.
    Returns the monic coefficients in descending degree order (length n+1).
    """
    n = len(a)
    coeffs = [1.0]
    M = identity(n)  # M_1 = I
    for k in range(1, n + 1):
        AM = matmul(a, M)
        c = -trace(AM) / k
        coeffs.append(c)
        # M_{k+1} = A M_k + c I
        M = [[AM[i][j] + (c if i == j else 0.0) for j in range(n)] for i in range(n)]
    return coeffs


def poly_roots(coeffs: Sequence[float]) -> List[complex]:
    """
    Find all roots of a real polynomial given in descending-degree order using
    the Durand-Kerner (Weierstrass) iteration. Suitable for small polynomials.
    """
    # Normalize to monic.
    lead = coeffs[0]
    c = [x / lead for x in coeffs]
    n = len(c) - 1
    if n == 0:
        return []
    # Initial guesses spread around a circle.
    roots: List[complex] = [cmath.exp(2j * math.pi * k / n) * (0.4 + 0.9j) for k in range(n)]

    def evalp(z: complex) -> complex:
        acc = 0j
        for coef in c:
            acc = acc * z + coef
        return acc

    for _ in range(2000):
        new = []
        for i in range(n):
            zi = roots[i]
            denom = 1 + 0j
            for j in range(n):
                if j != i:
                    denom *= (zi - roots[j])
            new.append(zi - evalp(zi) / denom)
        if max(abs(new[i] - roots[i]) for i in range(n)) < 1e-14:
            roots = new
            break
        roots = new
    return roots


def eigenvalues(a: Matrix) -> List[float]:
    """Return the (real parts of the) eigenvalues of a symmetric matrix, sorted."""
    coeffs = char_poly_coeffs(a)
    roots = poly_roots(coeffs)
    return sorted(r.real for r in roots)


def spectral_radius(a: Matrix) -> float:
    """Return max |eigenvalue| of a symmetric matrix."""
    return max(abs(v) for v in eigenvalues(a))


# ---------------------------------------------------------------------------
# The graphs of interest
# ---------------------------------------------------------------------------

# Unbalanced 4-cycle: signs +,+,+,- around the cycle 0-1-2-3-0.
B_UNBALANCED: Matrix = [
    [0.0, 1.0, 0.0, -1.0],
    [1.0, 0.0, 1.0, 0.0],
    [0.0, 1.0, 0.0, 1.0],
    [-1.0, 0.0, 1.0, 0.0],
]

# Unsigned (all +) 4-cycle.
C4_UNSIGNED: Matrix = [
    [0.0, 1.0, 0.0, 1.0],
    [1.0, 0.0, 1.0, 0.0],
    [0.0, 1.0, 0.0, 1.0],
    [1.0, 0.0, 1.0, 0.0],
]

# Edges of C_4 as ordered vertex pairs.
C4_EDGES: List[Tuple[int, int]] = [(0, 1), (1, 2), (2, 3), (3, 0)]


def cycle_sign_product(mat: Matrix, edges: Sequence[Tuple[int, int]]) -> float:
    """Product of the signed adjacency entries along the given cycle edges."""
    prod = 1.0
    for (i, j) in edges:
        prod *= mat[i][j]
    return prod


def max_degree(mat: Matrix) -> int:
    """Maximum absolute row sum (= max degree for a signed adjacency matrix)."""
    return int(round(max(sum(abs(x) for x in row) for row in mat)))


# ---------------------------------------------------------------------------
# Moment-method illustration: average trace of A_sigma^{2k} over all signings.
# ---------------------------------------------------------------------------

def signed_adjacency(edges: Sequence[Tuple[int, int]], signs: Sequence[int], n: int) -> Matrix:
    """Build the symmetric signed adjacency matrix from edges and a sign per edge."""
    mat = zeros(n, n)
    for (i, j), s in zip(edges, signs):
        mat[i][j] = float(s)
        mat[j][i] = float(s)
    return mat


def average_trace_power(edges: Sequence[Tuple[int, int]], n: int, power: int) -> float:
    """
    Average over all 2^{|E|} signings of trace(A_sigma^power). By the moment
    method this equals the number of *even* closed walks of that length, since
    odd-crossing walks cancel in the average.
    """
    total = 0.0
    count = 0
    for signs in itertools.product((+1, -1), repeat=len(edges)):
        A = signed_adjacency(edges, signs, n)
        Ak = identity(n)
        for _ in range(power):
            Ak = matmul(A, Ak)
        total += trace(Ak)
        count += 1
    return total / count


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Unbalanced 4-cycle: constructive Bilu-Linial spectral suppression")
    print("=" * 70)

    # 1. B^2 = 2 I
    B2 = matmul(B_UNBALANCED, B_UNBALANCED)
    target = scalar_mul(2.0, identity(4))
    err = max_abs_diff(B2, target)
    print("\n[1] Squaring identity  B^2 = 2 I")
    print("    B^2 =", [[int(x) for x in row] for row in B2])
    print(f"    max|B^2 - 2I| = {err:.2e}   ->  identity holds: {err < 1e-12}")

    # 2. Eigenvalues and |mu| = sqrt(2)
    evals = eigenvalues(B_UNBALANCED)
    print("\n[2] Eigenvalues of B")
    print("    eigenvalues =", [round(v, 6) for v in evals])
    print("    mu^2 for each =", [round(v * v, 6) for v in evals])
    print(f"    sqrt(2) = {math.sqrt(2):.6f}")

    # 3. Spectral radius vs. degree bound
    rho = spectral_radius(B_UNBALANCED)
    dmax = max_degree(B_UNBALANCED)
    print("\n[3] Spectral radius vs. maximum-degree bound")
    print(f"    spectral radius rho(B) = {rho:.6f}")
    print(f"    maximum degree Delta   = {dmax}")
    print(f"    strict improvement rho < Delta: {rho < dmax - 1e-9}  "
          f"({rho:.4f} < {dmax})")

    # 4. Balance / unbalance
    prod = cycle_sign_product(B_UNBALANCED, C4_EDGES)
    print("\n[4] Balance of the cycle")
    print(f"    product of edge signs around the cycle = {prod:.0f}  "
          f"->  {'UNBALANCED' if prod < 0 else 'balanced'}")

    # 5. Unsigned comparison
    rho0 = spectral_radius(C4_UNSIGNED)
    print("\n[5] Unsigned 4-cycle (all + signs)")
    print("    eigenvalues =", [round(v, 6) for v in eigenvalues(C4_UNSIGNED)])
    print(f"    spectral radius = {rho0:.6f}  (saturates the degree ceiling 2)")
    print(f"    reduction from signing: {100 * (rho0 - rho) / rho0:.1f}%")

    # 6. Moment-method / even-walk illustration
    print("\n[6] Moment method: average of trace(A_sigma^{2k}) over all signings")
    for k in (1, 2, 3):
        avg = average_trace_power(C4_EDGES, 4, 2 * k)
        print(f"    2k = {2*k}:  average trace = {avg:.1f}   "
              f"(counts even closed walks of length {2*k})")

    print("\nAll checks completed.")


if __name__ == "__main__":
    main()
