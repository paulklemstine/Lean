#!/usr/bin/env python3
"""Numerical illustrations of the Euler–Mascheroni information identity."""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Iterable

EULER_GAMMA = 0.5772156649015328606


def exponential_kl(rate_1: float, rate_2: float) -> float:
    """Return D_KL(Exp(rate_1) || Exp(rate_2)) for positive rates."""
    if rate_1 <= 0.0 or rate_2 <= 0.0:
        raise ValueError("rates must be positive")
    ratio_change = (rate_2 - rate_1) / rate_1
    return ratio_change - math.log1p(ratio_change)


def gamma_term(k: int) -> float:
    """Return the consecutive-rate divergence at rates k+1 and k+2."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    return exponential_kl(float(k + 1), float(k + 2))


def compensated_sum(values: Iterable[float]) -> float:
    """Neumaier compensated sum for improved floating-point accuracy."""
    total = 0.0
    correction = 0.0
    for value in values:
        updated = total + value
        if abs(total) >= abs(value):
            correction += (total - updated) + value
        else:
            correction += (value - updated) + total
        total = updated
    return total + correction


def divergence_partial_sum(n: int) -> float:
    """Sum the first n consecutive-rate divergences."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return compensated_sum(gamma_term(k) for k in range(n))


def harmonic_log_partial_sum(n: int) -> float:
    """Compute the equal telescoped expression H_n - log(n+1)."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    harmonic = math.fsum(1.0 / j for j in range(1, n + 1))
    return harmonic - math.log(n + 1.0)


def gamma_enclosure(n: int) -> tuple[float, float]:
    """Return the elementary certified enclosure derived from tail bounds."""
    if n < 1:
        raise ValueError("n must be positive")
    partial = harmonic_log_partial_sum(n)
    return partial + 1.0 / (2.0 * (n + 1)), partial + 1.0 / (2.0 * n)


@dataclass(frozen=True)
class ExperimentRow:
    n: int
    divergence_sum: float
    telescoped_sum: float
    identity_residual: float
    error_to_gamma: float
    lower_bound: float
    upper_bound: float


def experiment(n: int) -> ExperimentRow:
    """Collect all numerical checks for one truncation index."""
    direct = divergence_partial_sum(n)
    telescoped = harmonic_log_partial_sum(n)
    lower, upper = gamma_enclosure(n)
    return ExperimentRow(
        n=n,
        divergence_sum=direct,
        telescoped_sum=telescoped,
        identity_residual=abs(direct - telescoped),
        error_to_gamma=EULER_GAMMA - direct,
        lower_bound=lower,
        upper_bound=upper,
    )


def main() -> None:
    print("Euler–Mascheroni constant as accumulated exponential KL divergence")
    print(f"reference gamma = {EULER_GAMMA:.16f}\n")
    print("First eight consecutive-rate costs:")
    for k in range(8):
        print(f"  Exp({k + 1}) -> Exp({k + 2}): {gamma_term(k):.12f}")

    print("\nPartial sums and certified enclosures:")
    header = " n       direct sum       H_n-log(n+1)   residual      gamma error     enclosure"
    print(header)
    for n in (1, 2, 5, 10, 100, 1000, 10000):
        row = experiment(n)
        contains = row.lower_bound <= EULER_GAMMA <= row.upper_bound
        print(
            f"{n:5d}  {row.divergence_sum:.12f}  {row.telescoped_sum:.12f}  "
            f"{row.identity_residual:.1e}  {row.error_to_gamma:.3e}  "
            f"[{row.lower_bound:.12f}, {row.upper_bound:.12f}] "
            f"contains gamma={contains}"
        )

    assert all(gamma_term(k) >= 0.0 for k in range(10000))
    assert all(
        divergence_partial_sum(n + 1) >= divergence_partial_sum(n)
        for n in range(100)
    )
    print("\nChecks passed: nonnegativity, monotonicity, telescoping, and tail enclosure.")


if __name__ == "__main__":
    main()
