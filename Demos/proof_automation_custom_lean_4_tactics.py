#!/usr/bin/env python3
"""Numerical demonstrations of min-plus identities, trial primality, and row-sum bounds."""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, pi, sqrt
from typing import Iterable, Sequence

Matrix = Sequence[Sequence[float]]


def tropical_add(a: float, b: float) -> float:
    """Return min-plus addition a ⊕ b = min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Return min-plus multiplication a ⊗ b = a + b."""
    return a + b


def tropical_distribution_demo(a: float, costs: Sequence[float]) -> tuple[float, float]:
    """Evaluate a common-prefix choice before and after tropical distribution."""
    if not costs:
        raise ValueError("costs must be nonempty")
    undistributed = tropical_mul(a, min(costs))
    distributed = min(tropical_mul(a, cost) for cost in costs)
    return undistributed, distributed


@dataclass(frozen=True)
class PrimalityCertificate:
    """Result of exhaustive trial division; divisor is present exactly for composites."""

    n: int
    is_prime: bool
    divisor: int | None
    tested: int


def trial_prime(n: int) -> PrimalityCertificate:
    """Test every proper divisor d with 2 <= d < n."""
    if n < 2:
        return PrimalityCertificate(n, False, None, 0)
    tested = 0
    for d in range(2, n):
        tested += 1
        if n % d == 0:
            return PrimalityCertificate(n, False, d, tested)
    return PrimalityCertificate(n, True, None, tested)


def absolute_row_sums(matrix: Matrix) -> list[float]:
    """Compute the sum of absolute values in every row of a square matrix."""
    size = len(matrix)
    if any(len(row) != size for row in matrix):
        raise ValueError("matrix must be square")
    return [sum(abs(value) for value in row) for row in matrix]


def spectral_interval(matrix: Matrix) -> tuple[float, float]:
    """Return [-B, B], where B is the maximum absolute row sum."""
    rows = absolute_row_sums(matrix)
    bound = max(rows, default=0.0)
    return -bound, bound


def symmetric_tridiagonal_eigenvalues(n: int, diagonal: float, off_diagonal: float) -> list[float]:
    """Exact formula for eigenvalues of a symmetric Toeplitz tridiagonal matrix."""
    if n <= 0:
        raise ValueError("n must be positive")
    return [diagonal + 2.0 * off_diagonal * cos(k * pi / (n + 1)) for k in range(1, n + 1)]


def verify_values_in_interval(values: Iterable[float], interval: tuple[float, float], tolerance: float = 1e-12) -> bool:
    """Check whether all values lie in a closed interval, up to numerical tolerance."""
    lower, upper = interval
    return all(lower - tolerance <= value <= upper + tolerance for value in values)


def main() -> None:
    print("MIN-PLUS DISTRIBUTION")
    before, after = tropical_distribution_demo(4.0, [7.0, 2.0, 5.0])
    print(f"4 + min(7, 2, 5) = {before:g}")
    print(f"min(4+7, 4+2, 4+5) = {after:g}")
    assert before == after == 6.0

    print("\nEXHAUSTIVE TRIAL PRIMALITY")
    for n in (97, 91, 1):
        certificate = trial_prime(n)
        if certificate.is_prime:
            print(f"{n} is prime; all {certificate.tested} candidates were rejected.")
        elif certificate.divisor is not None:
            other = n // certificate.divisor
            print(f"{n} is composite: {n} = {certificate.divisor} * {other}.")
        else:
            print(f"{n} is not prime because it is below 2.")
    assert trial_prime(97).is_prime
    assert trial_prime(91).divisor == 7

    print("\nABSOLUTE ROW-SUM SPECTRAL BOUND")
    matrix = [[2.0, -1.0, 0.0], [-1.0, 2.0, -1.0], [0.0, -1.0, 2.0]]
    row_sums = absolute_row_sums(matrix)
    interval = spectral_interval(matrix)
    eigenvalues = symmetric_tridiagonal_eigenvalues(3, 2.0, -1.0)
    print(f"absolute row sums: {row_sums}")
    print(f"certified interval for every real eigenvalue: {interval}")
    print("known eigenvalues:", [round(value, 6) for value in eigenvalues])
    assert verify_values_in_interval(eigenvalues, interval)
    assert abs(min(eigenvalues) - (2.0 - sqrt(2.0))) < 1e-12


if __name__ == "__main__":
    main()
