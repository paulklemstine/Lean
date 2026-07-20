#!/usr/bin/env python3
"""Numerical demonstrations of exact Cesàro averaging for periodic walks."""

from __future__ import annotations

from typing import Sequence

Vector = list[float]
Period = list[Vector]


def validate_period(period: Sequence[Sequence[float]], tolerance: float = 1e-12) -> None:
    """Check that a nonempty table consists of probability vectors of equal size."""
    if not period or not period[0]:
        raise ValueError("The period and its state space must be nonempty.")
    width = len(period[0])
    for row in period:
        if len(row) != width:
            raise ValueError("All probability vectors must have the same length.")
        if any(value < -tolerance for value in row):
            raise ValueError("Probabilities must be nonnegative.")
        if abs(sum(row) - 1.0) > tolerance:
            raise ValueError("Every row must sum to one.")


def empirical_mean(period: Sequence[Sequence[float]], steps: int) -> Vector:
    """Average a periodically repeated probability table over a chosen window."""
    validate_period(period)
    if steps <= 0:
        raise ValueError("The observation length must be positive.")
    width = len(period[0])
    totals = [0.0] * width
    for n in range(steps):
        row = period[n % len(period)]
        for x, probability in enumerate(row):
            totals[x] += probability
    return [total / steps for total in totals]


def one_period_equilibrium(period: Sequence[Sequence[float]]) -> Vector:
    """Compute the canonical empirical equilibrium from one complete period."""
    return empirical_mean(period, len(period))


def complete_block_error(period: Sequence[Sequence[float]], blocks: int) -> float:
    """Return the largest coordinate error between one and many complete periods."""
    if blocks <= 0:
        raise ValueError("The number of blocks must be positive.")
    baseline = one_period_equilibrium(period)
    repeated = empirical_mean(period, blocks * len(period))
    return max(abs(a - b) for a, b in zip(baseline, repeated))


def uniform_deviation(distribution: Sequence[float]) -> float:
    """Compute maximum coordinate deviation from the uniform distribution."""
    if not distribution:
        raise ValueError("The distribution must be nonempty.")
    target = 1.0 / len(distribution)
    return max(abs(value - target) for value in distribution)


def cyclic_shift_period(size: int) -> Period:
    """Return one period of a localized walker shifted around a cycle."""
    if size <= 0:
        raise ValueError("The cycle size must be positive.")
    return [[1.0 if x == n else 0.0 for x in range(size)] for n in range(size)]


def print_vector(label: str, values: Sequence[float]) -> None:
    formatted = ", ".join(f"{value:.6f}" for value in values)
    print(f"{label}: [{formatted}]")


def main() -> None:
    """Run uniform, nonuniform, and incomplete-window demonstrations."""
    cycle = cyclic_shift_period(4)
    print("Example 1: localized shift on a four-cycle")
    print_vector("one period", one_period_equilibrium(cycle))
    for blocks in (1, 2, 5, 25):
        mean = empirical_mean(cycle, blocks * len(cycle))
        print_vector(f"{blocks:2d} complete block(s)", mean)
        print(f"  maximum identity error: {complete_block_error(cycle, blocks):.3e}")

    trapped: Period = [[1.0, 0.0], [1.0, 0.0]]
    print("\nExample 2: periodic evolution with nonuniform equilibrium")
    trapped_mean = one_period_equilibrium(trapped)
    print_vector("one-period equilibrium", trapped_mean)
    print(f"uniform deviation: {uniform_deviation(trapped_mean):.6f}")
    print_vector("ten complete blocks", empirical_mean(trapped, 20))

    biased: Period = [
        [1.0, 0.0, 0.0],
        [0.5, 0.5, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
    ]
    print("\nExample 3: complete blocks versus remainders")
    print_vector("one-period equilibrium", one_period_equilibrium(biased))
    for steps in (4, 8, 9, 10, 12):
        print_vector(f"first {steps:2d} observations", empirical_mean(biased, steps))


if __name__ == "__main__":
    main()
