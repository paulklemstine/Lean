"""Numerical demonstrations of the cyclotomic Gauss-sum matrix factorization.

This self-contained script verifies, over the complex numbers, the main results
concerning the matrix

    A[i, j] = sum_a eta[a] * omega ** (a * (i + j)),

where omega is a primitive n-th root of unity and eta is a vector of "Gauss
periods".  We demonstrate:

  1. The factorization  A = W D W^T.
  2. Symmetry of W and A.
  3. The determinant identity  det A = (det W)^2 * prod(eta).
  4. The invertibility criterion over a field.
  5. Discrete Fourier orthogonality  (W^T W)[a, b] = n * [n | a + b].
  6. Fourier inversion recovering the periods from the zeroth column of A.
  7. The refutation of the naive conjecture  W^T W = n * I  (n >= 3).

Only the Python standard library (``cmath``, ``math``) is used, so the script
runs anywhere with no third-party dependencies.
"""

from __future__ import annotations

import cmath
import math
from typing import List

Complex = complex
Matrix = List[List[Complex]]


# --------------------------------------------------------------------------- #
# Core constructions
# --------------------------------------------------------------------------- #
def primitive_root(n: int) -> Complex:
    """Return the primitive n-th root of unity omega = exp(2*pi*i / n)."""
    return cmath.exp(2j * math.pi / n)


def W_matrix(n: int, omega: Complex) -> Matrix:
    """Discrete Fourier / Vandermonde matrix W[i][a] = omega ** (a * i)."""
    return [[omega ** (a * i) for a in range(n)] for i in range(n)]


def D_matrix(eta: List[Complex]) -> Matrix:
    """Diagonal matrix D = diag(eta)."""
    n = len(eta)
    return [[eta[i] if i == j else 0j for j in range(n)] for i in range(n)]


def A_matrix(n: int, omega: Complex, eta: List[Complex]) -> Matrix:
    """Gauss-sum matrix A[i][j] = sum_a eta[a] * omega ** (a * (i + j))."""
    return [
        [sum(eta[a] * omega ** (a * (i + j)) for a in range(n)) for j in range(n)]
        for i in range(n)
    ]


# --------------------------------------------------------------------------- #
# Small dense linear algebra (no numpy)
# --------------------------------------------------------------------------- #
def transpose(M: Matrix) -> Matrix:
    return [list(row) for row in zip(*M)]


def matmul(X: Matrix, Y: Matrix) -> Matrix:
    n, m, p = len(X), len(Y), len(Y[0])
    return [
        [sum(X[i][k] * Y[k][j] for k in range(m)) for j in range(p)]
        for i in range(n)
    ]


def determinant(M: Matrix) -> Complex:
    """Determinant via Gaussian elimination with partial pivoting."""
    n = len(M)
    a = [row[:] for row in M]
    det = 1 + 0j
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-14:
            return 0j
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv = 1 / a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] * inv
            for c in range(col, n):
                a[r][c] -= factor * a[col][c]
    return det


def max_abs_diff(X: Matrix, Y: Matrix) -> float:
    return max(
        abs(X[i][j] - Y[i][j]) for i in range(len(X)) for j in range(len(X[0]))
    )


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_factorization(n: int, eta: List[Complex]) -> None:
    print(f"\n=== Factorization A = W D W^T  (n = {n}) ===")
    omega = primitive_root(n)
    W = W_matrix(n, omega)
    D = D_matrix(eta)
    A = A_matrix(n, omega, eta)
    WDWt = matmul(matmul(W, D), transpose(W))
    print(f"  max |A - W D W^T| = {max_abs_diff(A, WDWt):.2e}")


def demo_symmetry(n: int, eta: List[Complex]) -> None:
    print(f"\n=== Symmetry of W and A  (n = {n}) ===")
    omega = primitive_root(n)
    W = W_matrix(n, omega)
    A = A_matrix(n, omega, eta)
    print(f"  max |W - W^T| = {max_abs_diff(W, transpose(W)):.2e}")
    print(f"  max |A - A^T| = {max_abs_diff(A, transpose(A)):.2e}")


def demo_determinant(n: int, eta: List[Complex]) -> None:
    print(f"\n=== Determinant identity det A = (det W)^2 * prod(eta)  (n = {n}) ===")
    omega = primitive_root(n)
    W = W_matrix(n, omega)
    A = A_matrix(n, omega, eta)
    detA = determinant(A)
    detW = determinant(W)
    prod_eta = math.prod(eta) if eta else 1
    rhs = detW ** 2 * prod_eta
    print(f"  det A               = {detA:.6f}")
    print(f"  (det W)^2 * prod eta= {rhs:.6f}")
    print(f"  difference          = {abs(detA - rhs):.2e}")


def demo_invertibility(n: int) -> None:
    print(f"\n=== Invertibility criterion  (n = {n}) ===")
    omega = primitive_root(n)
    # All periods nonzero -> invertible.
    eta_ok = [1 + a for a in range(n)]
    # One period zero -> singular.
    eta_bad = eta_ok[:]
    eta_bad[1] = 0j
    for label, eta in (("all eta nonzero", eta_ok), ("one eta = 0", eta_bad)):
        A = A_matrix(n, omega, eta)
        d = determinant(A)
        status = "invertible" if abs(d) > 1e-9 else "singular"
        print(f"  {label:16s}: |det A| = {abs(d):.4e}  -> {status}")


def demo_orthogonality(n: int) -> None:
    print(f"\n=== Fourier orthogonality (W^T W)[a,b] = n*[n | a+b]  (n = {n}) ===")
    omega = primitive_root(n)
    W = W_matrix(n, omega)
    G = matmul(transpose(W), W)
    ok = True
    for a in range(n):
        for b in range(n):
            expected = n if (a + b) % n == 0 else 0
            if abs(G[a][b] - expected) > 1e-9:
                ok = False
    print(f"  matches n*[n | a+b] for all (a,b): {ok}")
    print("  W^T W (rounded):")
    for row in G:
        print("   ", [round(x.real) for x in row])


def demo_inversion(n: int, eta: List[Complex]) -> None:
    print(f"\n=== Fourier inversion recovers the Gauss periods  (n = {n}) ===")
    omega = primitive_root(n)
    A = A_matrix(n, omega, eta)
    recovered = []
    for c in range(n):
        s = sum((omega ** (c * i)) ** (-1) * A[i][0] for i in range(n))
        recovered.append(s / n)
    err = max(abs(recovered[c] - eta[c]) for c in range(n))
    print(f"  original  eta = {[round(x.real, 3) for x in eta]}")
    print(f"  recovered eta = {[round(x.real, 3) for x in recovered]}")
    print(f"  max recovery error = {err:.2e}")


def demo_refutation(n: int) -> None:
    print(f"\n=== Refutation of W^T W = n I  (n = {n}) ===")
    omega = primitive_root(n)
    W = W_matrix(n, omega)
    G = matmul(transpose(W), W)
    entry = G[1][n - 1]
    print(f"  (W^T W)[1, n-1] = {entry:.4f}  (should be n = {n}, not 0)")
    print(f"  identity would give 0 here, so W^T W != n I for n = {n} >= 3.")


def main() -> None:
    print("Cyclotomic Gauss-Sum Matrix Factorization -- numerical demonstrations")
    eta5 = [2 + 0j, -1 + 0j, 3 + 0j, 1 + 0j, -2 + 0j]
    demo_factorization(5, eta5)
    demo_symmetry(5, eta5)
    demo_determinant(5, eta5)
    demo_invertibility(5)
    demo_orthogonality(5)
    demo_inversion(5, eta5)
    demo_refutation(5)
    # A larger example for the factorization and inversion.
    eta8 = [float(a * a % 7 + 1) + 0j for a in range(8)]
    demo_factorization(8, eta8)
    demo_inversion(8, eta8)
    demo_orthogonality(8)


if __name__ == "__main__":
    main()
