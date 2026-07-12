"""Numerical demonstrations for
"The Periodic Table as a Spectrum: Elements as Eigenvalues of a Self-Adjoint Operator".

This self-contained script constructs the nuclear Hamiltonian

    H_n = diag(1, 2, ..., n)

a diagonal, self-adjoint operator on R^n whose diagonal entries are the atomic
numbers of the first n elements, and verifies numerically the theorems of the
paper:

  * H_n is self-adjoint (Hermitian).
  * The spectrum of H_n is exactly {1, 2, ..., n}.
  * trace(H_n)         = n(n+1)/2      (triangular number).
  * det(H_n)           = n!            (factorial).
  * trace(H_n^k)       = 1^k + ... + n^k  (power-sum ladder).
  * charpoly(H_n)      = prod_{k=1}^n (X - k).
  * Newton's identities link the power sums to the charpoly coefficients.

Only the Python standard library is required (no numpy), so the script runs
anywhere. All arithmetic uses Fraction where exactness matters.
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial
from typing import List


# --------------------------------------------------------------------------- #
# Construction
# --------------------------------------------------------------------------- #
def atomic_numbers(n: int) -> List[int]:
    """Return the atomic numbers of the first n elements: [1, 2, ..., n]."""
    return [i + 1 for i in range(n)]


def nuclear_hamiltonian(n: int) -> List[List[Fraction]]:
    """Return H_n = diag(1, 2, ..., n) as a dense n x n matrix of Fractions."""
    z = atomic_numbers(n)
    return [
        [Fraction(z[i]) if i == j else Fraction(0) for j in range(n)]
        for i in range(n)
    ]


# --------------------------------------------------------------------------- #
# Basic linear-algebra helpers (exact, standard library only)
# --------------------------------------------------------------------------- #
def is_hermitian(mat: List[List[Fraction]]) -> bool:
    """Over the reals, self-adjoint means symmetric: M[i][j] == M[j][i]."""
    n = len(mat)
    return all(mat[i][j] == mat[j][i] for i in range(n) for j in range(n))


def trace(mat: List[List[Fraction]]) -> Fraction:
    """Sum of the diagonal entries."""
    return sum((mat[i][i] for i in range(len(mat))), Fraction(0))


def matmul(a: List[List[Fraction]], b: List[List[Fraction]]) -> List[List[Fraction]]:
    """Naive matrix product."""
    n, m, p = len(a), len(b), len(b[0])
    return [
        [sum((a[i][k] * b[k][j] for k in range(m)), Fraction(0)) for j in range(p)]
        for i in range(n)
    ]


def matpow(mat: List[List[Fraction]], k: int) -> List[List[Fraction]]:
    """k-th power of a square matrix (k >= 0); the 0-th power is the identity."""
    n = len(mat)
    result = [[Fraction(1) if i == j else Fraction(0) for j in range(n)] for i in range(n)]
    for _ in range(k):
        result = matmul(result, mat)
    return result


def diag_determinant(mat: List[List[Fraction]]) -> Fraction:
    """Determinant of a diagonal matrix: the product of the diagonal entries."""
    prod = Fraction(1)
    for i in range(len(mat)):
        prod *= mat[i][i]
    return prod


def eigenvalues_of_diagonal(mat: List[List[Fraction]]) -> List[Fraction]:
    """For a diagonal matrix the eigenvalues are the diagonal entries."""
    return sorted(mat[i][i] for i in range(len(mat)))


# --------------------------------------------------------------------------- #
# Polynomial helpers for the characteristic polynomial
# --------------------------------------------------------------------------- #
def poly_mul(p: List[Fraction], q: List[Fraction]) -> List[Fraction]:
    """Multiply two polynomials given as coefficient lists (ascending degree)."""
    result = [Fraction(0)] * (len(p) + len(q) - 1)
    for i, pi in enumerate(p):
        for j, qj in enumerate(q):
            result[i + j] += pi * qj
    return result


def charpoly_from_roots(roots: List[int]) -> List[Fraction]:
    """Coefficients (ascending degree) of prod_k (X - root_k)."""
    poly: List[Fraction] = [Fraction(1)]
    for r in roots:
        poly = poly_mul(poly, [Fraction(-r), Fraction(1)])  # (X - r)
    return poly


def elementary_symmetric(values: List[int]) -> List[Fraction]:
    """Return [e_0, e_1, ..., e_n] for the given values."""
    e: List[Fraction] = [Fraction(1)]
    for v in values:
        new = e + [Fraction(0)]
        for k in range(len(e), 0, -1):
            new[k] = e[k] if k < len(e) else Fraction(0)
            new[k] += e[k - 1] * v
        e = new
    return e


def newton_e_from_power_sums(power_sums: List[Fraction], n: int) -> List[Fraction]:
    """Recover e_1..e_n from power sums p_1..p_n via Newton's identities."""
    e: List[Fraction] = [Fraction(1)]  # e_0
    for k in range(1, n + 1):
        acc = Fraction(0)
        for j in range(1, k + 1):
            acc += Fraction((-1) ** (j - 1)) * e[k - j] * power_sums[j - 1]
        e.append(acc / k)
    return e


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo(n: int) -> None:
    print("=" * 70)
    print(f"Nuclear Hamiltonian H_{n} = diag(1, ..., {n})")
    print("=" * 70)

    H = nuclear_hamiltonian(n)
    z = atomic_numbers(n)

    # Self-adjointness
    print(f"Self-adjoint (symmetric): {is_hermitian(H)}")

    # Spectrum equals the atomic numbers
    spec = eigenvalues_of_diagonal(H)
    print(f"Spectrum          : {[int(v) for v in spec]}")
    print(f"Atomic numbers    : {z}")
    print(f"Spectrum == table : {[int(v) for v in spec] == z}")

    # Trace = triangular number
    tr = trace(H)
    triangular = Fraction(n * (n + 1), 2)
    print(f"trace(H)          = {tr}   n(n+1)/2 = {triangular}   match: {tr == triangular}")

    # Determinant = factorial
    det = diag_determinant(H)
    print(f"det(H)            = {det}   n! = {factorial(n)}   match: {det == factorial(n)}")

    # Power-sum ladder
    print("Power-sum ladder  trace(H^k) vs 1^k + ... + n^k:")
    for k in range(0, 5):
        trk = trace(matpow(H, k))
        psum = sum(Fraction(v) ** k for v in z)
        print(f"    k={k}: trace(H^k) = {str(trk):>12}   power sum = {str(psum):>12}   match: {trk == psum}")

    # Characteristic polynomial
    cp = charpoly_from_roots(z)
    print("charpoly(H) coefficients (ascending degree):")
    print(f"    {[str(c) for c in cp]}")
    # Its roots are exactly the atomic numbers (checked by evaluation).
    def evaluate(poly: List[Fraction], x: int) -> Fraction:
        return sum((c * Fraction(x) ** i for i, c in enumerate(poly)), Fraction(0))
    roots_ok = all(evaluate(cp, k) == 0 for k in z)
    print(f"    all atomic numbers are roots: {roots_ok}")

    # Newton's identities: recover elementary symmetric polys from power sums
    power_sums = [sum(Fraction(v) ** k for v in z) for k in range(1, n + 1)]
    e_newton = newton_e_from_power_sums(power_sums, n)
    e_direct = elementary_symmetric(z)
    print("Newton's identities: e_k from power sums matches direct e_k:",
          e_newton == e_direct)
    # The charpoly coefficient of X^{n-k} is (-1)^k e_k.
    charpoly_matches = all(
        cp[n - k] == Fraction((-1) ** k) * e_direct[k] for k in range(0, n + 1)
    )
    print(f"    charpoly coeffs equal signed elementary symmetric polys: {charpoly_matches}")
    print()


def main() -> None:
    for n in (5, 10, 18):
        demo(n)
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
