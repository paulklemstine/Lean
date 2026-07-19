#!/usr/bin/env python3
"""Exact numerical demonstrations of eigenvalue leakage in min-plus powers."""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence, TypeAlias

Scalar: TypeAlias = Fraction
Vector: TypeAlias = list[Scalar]
Matrix: TypeAlias = list[list[Scalar]]


def validate_matrix(a: Sequence[Sequence[Scalar]]) -> int:
    """Return the positive dimension of a square matrix, or raise ValueError."""
    n = len(a)
    if n == 0 or any(len(row) != n for row in a):
        raise ValueError("a min-plus matrix must be nonempty and square")
    return n


def min_plus_multiply(a: Matrix, b: Matrix) -> Matrix:
    """Compute the dense min-plus matrix product in O(n^3) time."""
    n = validate_matrix(a)
    if validate_matrix(b) != n:
        raise ValueError("matrix dimensions must agree")
    return [
        [min(a[i][k] + b[k][j] for k in range(n)) for j in range(n)]
        for i in range(n)
    ]


def min_plus_action(a: Matrix, v: Vector) -> Vector:
    """Apply a dense min-plus matrix to a vector in O(n^2) time."""
    n = validate_matrix(a)
    if len(v) != n:
        raise ValueError("vector dimension must match the matrix")
    return [min(a[i][j] + v[j] for j in range(n)) for i in range(n)]


def positive_power(a: Matrix, k: int) -> Matrix:
    """Return P_k(A), which has k+1 factors, using the defining recurrence."""
    if k < 0:
        raise ValueError("the positive-power index must be nonnegative")
    result = [row[:] for row in a]
    for _ in range(k):
        result = min_plus_multiply(a, result)
    return result


def observed_eigenvalue(a: Matrix, v: Vector) -> Scalar:
    """Return lambda if A⊗v=lambda+v; raise ValueError otherwise."""
    acted = min_plus_action(a, v)
    offsets = [x - y for x, y in zip(acted, v)]
    if not offsets or any(x != offsets[0] for x in offsets[1:]):
        raise ValueError("the supplied vector is not a min-plus eigenvector")
    return offsets[0]


def recover_power_index(base_lambda: Scalar, power_mu: Scalar) -> int:
    """Recover k from mu=(k+1)lambda using exact rational arithmetic."""
    if base_lambda == 0:
        raise ValueError("a zero base eigenvalue does not identify the exponent")
    candidate = power_mu / base_lambda - 1
    if candidate.denominator != 1 or candidate < 0:
        raise ValueError("the observations do not encode a nonnegative integer index")
    return candidate.numerator


def shift_matrix(a: Matrix, c: Scalar) -> Matrix:
    """Add c uniformly to every matrix entry."""
    validate_matrix(a)
    return [[c + entry for entry in row] for row in a]


def format_matrix(a: Matrix) -> str:
    """Format an exact matrix compactly."""
    return "[\n  " + ",\n  ".join(str(row) for row in a) + "\n]"


def demonstrate_power_law() -> None:
    """Show exact scaling and exponent recovery for a two-state matrix."""
    a = [[Fraction(2), Fraction(5)], [Fraction(4), Fraction(2)]]
    v = [Fraction(0), Fraction(1)]
    lam = observed_eigenvalue(a, v)
    print("Base matrix A =", format_matrix(a))
    print(f"Eigenvector v = {v}; base eigenvalue lambda = {lam}\n")
    for k in range(6):
        power = positive_power(a, k)
        mu = observed_eigenvalue(power, v)
        recovered = recover_power_index(lam, mu)
        predicted = (k + 1) * lam
        assert mu == predicted and recovered == k
        print(
            f"k={k}: observed mu={mu}, predicted (k+1)lambda={predicted}, "
            f"recovered k={recovered}"
        )


def demonstrate_injectivity() -> None:
    """Confirm that the first several powers are distinct when lambda is nonzero."""
    a = [[Fraction(2), Fraction(5)], [Fraction(4), Fraction(2)]]
    powers = [positive_power(a, k) for k in range(8)]
    encodings = {tuple(tuple(row) for row in power) for power in powers}
    assert len(encodings) == len(powers)
    print(f"\nInjectivity sample: all {len(powers)} powers P_0(A),...,P_7(A) differ.")


def demonstrate_shifts() -> None:
    """Show the eigenvalue shift law and the unique exceptional offset."""
    a = [[Fraction(2), Fraction(5)], [Fraction(4), Fraction(2)]]
    v = [Fraction(0), Fraction(1)]
    lam = observed_eigenvalue(a, v)
    print("\nUniform entry shifts:")
    for c in (Fraction(-2), Fraction(-1), Fraction(0), Fraction(1), Fraction(3)):
        shifted_lambda = observed_eigenvalue(shift_matrix(a, c), v)
        assert shifted_lambda == c + lam
        status = "exceptional zero clock" if shifted_lambda == 0 else "nonzero clock"
        print(f"c={str(c):>2}: shifted eigenvalue={str(shifted_lambda):>2} ({status})")


def main() -> None:
    """Run all exact demonstrations."""
    demonstrate_power_law()
    demonstrate_injectivity()
    demonstrate_shifts()
    print("\nAll exact checks passed.")


if __name__ == "__main__":
    main()
