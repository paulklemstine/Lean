#!/usr/bin/env python3
"""Numerical demonstrations for local Ihara factors and Lucas power sums.

The script uses only Python's standard library. It demonstrates:
1. exact Lucas-recurrence coefficients;
2. critical-circle zeros in and outside the Ramanujan range;
3. the finite explicit formula and its truncation boundary.
"""

from __future__ import annotations

import cmath
from dataclasses import dataclass
from typing import Sequence


Number = complex | float | int


@dataclass(frozen=True)
class LocalFactorReport:
    """Computed data for the quadratic factor 1 - lam*u + q*u^2."""

    lam: float
    q: float
    zeros: tuple[complex, complex]
    critical_radius: float
    ramanujan_bound_holds: bool


def spectral_power_sums(lam: Number, q: Number, count: int) -> list[Number]:
    """Return S_0,...,S_(count-1) using S_(n+2)=lam*S_(n+1)-q*S_n."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    if count == 0:
        return []
    values: list[Number] = [2]
    if count == 1:
        return values
    values.append(lam)
    for _ in range(count - 2):
        values.append(lam * values[-1] - q * values[-2])
    return values


def local_factor(lam: Number, q: Number, u: complex) -> complex:
    """Evaluate 1 - lam*u + q*u^2."""
    return complex(1 - lam * u + q * u * u)


def local_zeros(lam: float, q: float) -> tuple[complex, complex]:
    """Return the two zeros of 1 - lam*u + q*u^2 for q != 0."""
    if q == 0:
        raise ValueError("q must be nonzero for a quadratic factor")
    discriminant = complex(lam * lam - 4.0 * q)
    root = cmath.sqrt(discriminant)
    return ((lam + root) / (2.0 * q), (lam - root) / (2.0 * q))


def critical_circle_report(lam: float, q: float) -> LocalFactorReport:
    """Compute zeros and test the local Ramanujan inequality lam^2 <= 4q."""
    if q <= 0:
        raise ValueError("q must be positive")
    return LocalFactorReport(
        lam=lam,
        q=q,
        zeros=local_zeros(lam, q),
        critical_radius=1.0 / q**0.5,
        ramanujan_bound_holds=lam * lam <= 4.0 * q + 1e-12,
    )


def truncated_series(coefficients: Sequence[Number], u: complex, n: int) -> complex:
    """Evaluate T_n(u)=sum_(k=0)^n S_(k+1)u^k by Horner's method."""
    if n < 0 or len(coefficients) < n + 2:
        raise ValueError("coefficients must contain S_0 through S_(n+1)")
    value = 0j
    for k in range(n, -1, -1):
        value = value * u + coefficients[k + 1]
    return complex(value)


def explicit_formula_residual(lam: Number, q: Number, n: int, u: complex) -> complex:
    """Return left side minus right side of the finite explicit formula."""
    sums = spectral_power_sums(lam, q, n + 3)
    left = local_factor(lam, q, u) * truncated_series(sums, u, n)
    right = (
        lam
        - 2 * q * u
        - sums[n + 2] * u ** (n + 1)
        + q * sums[n + 1] * u ** (n + 2)
    )
    return complex(left - right)


def print_circle_demo(lam: float, q: float) -> None:
    """Print a readable critical-circle diagnostic."""
    report = critical_circle_report(lam, q)
    print(f"lambda={lam:g}, q={q:g}")
    print(f"  Ramanujan inequality: {report.ramanujan_bound_holds}")
    print(f"  critical radius: {report.critical_radius:.12g}")
    for index, zero in enumerate(report.zeros, start=1):
        print(f"  zero {index}: {zero:.12g}; modulus={abs(zero):.12g}")


def main() -> None:
    """Run three reproducible demonstrations."""
    print("DEMO 1 — Lucas coefficients for lambda=2, q=2")
    coefficients = spectral_power_sums(2, 2, 8)
    print("  S_0,...,S_7 =", coefficients)
    assert coefficients == [2, 2, 0, -4, -8, -8, 0, 16]

    print("\nDEMO 2 — Critical-circle comparison")
    print_circle_demo(2, 2)
    print_circle_demo(3, 2)
    good = critical_circle_report(2, 2)
    assert all(abs(abs(z) - good.critical_radius) < 1e-12 for z in good.zeros)

    print("\nDEMO 3 — Exact finite explicit formula (up to rounding)")
    test_points = [0.1 + 0.2j, -0.25 + 0.05j, 0.3 - 0.1j]
    for n in (0, 3, 7):
        for u in test_points:
            residual = explicit_formula_residual(2, 2, n, u)
            print(f"  N={n}, u={u}: |residual|={abs(residual):.3e}")
            assert abs(residual) < 1e-10


if __name__ == "__main__":
    main()
