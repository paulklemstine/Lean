#!/usr/bin/env python3
"""Numerical demonstrations of sparse binary neural-code mathematics."""

from __future__ import annotations

from dataclasses import dataclass
from math import comb, log2, sqrt
from typing import Iterable


@dataclass(frozen=True)
class CapacityRow:
    """Summary statistics for an exact-energy neural codebook."""

    neurons: int
    spikes: int
    exact_capacity: int
    budget_capacity: int
    polynomial_ceiling: int
    information_bits: float
    bits_per_spike: float | None
    rate_ceiling: float | None


def validate_parameters(neurons: int, spikes: int) -> None:
    """Raise ValueError unless 0 <= spikes <= neurons."""
    if neurons < 0:
        raise ValueError("neurons must be nonnegative")
    if not 0 <= spikes <= neurons:
        raise ValueError("spikes must satisfy 0 <= spikes <= neurons")


def exact_energy_capacity(neurons: int, spikes: int) -> int:
    """Return the number C(neurons, spikes) of exact-weight patterns."""
    validate_parameters(neurons, spikes)
    return comb(neurons, spikes)


def budget_capacity(neurons: int, budget: int) -> int:
    """Return the number of patterns whose Hamming weight is at most budget."""
    validate_parameters(neurons, budget)
    return sum(comb(neurons, weight) for weight in range(budget + 1))


def layer_histogram_by_enumeration(neurons: int) -> list[int]:
    """Enumerate all binary patterns and count them by Hamming weight.

    This deliberately exponential routine is intended only for small populations.
    """
    if neurons < 0:
        raise ValueError("neurons must be nonnegative")
    counts = [0] * (neurons + 1)
    for pattern in range(1 << neurons):
        counts[pattern.bit_count()] += 1
    return counts


def capacity_row(neurons: int, spikes: int) -> CapacityRow:
    """Compute exact, cumulative, and information-theoretic quantities."""
    exact = exact_energy_capacity(neurons, spikes)
    info = log2(exact) if exact > 0 else float("-inf")
    rate = info / spikes if spikes > 0 else None
    ceiling = log2(neurons) if neurons >= 1 and spikes > 0 else None
    return CapacityRow(
        neurons=neurons,
        spikes=spikes,
        exact_capacity=exact,
        budget_capacity=budget_capacity(neurons, spikes),
        polynomial_ceiling=neurons**spikes,
        information_bits=info,
        bits_per_spike=rate,
        rate_ceiling=ceiling,
    )


def population_standard_error(single_neuron_sd: float, neurons: int) -> float:
    """Return sigma/sqrt(N) for independent equal-variance measurements."""
    if single_neuron_sd < 0:
        raise ValueError("standard deviation must be nonnegative")
    if neurons <= 0:
        raise ValueError("neurons must be positive")
    return single_neuron_sd / sqrt(neurons)


def print_rows(rows: Iterable[CapacityRow]) -> None:
    """Print a compact capacity and energy table."""
    header = (
        "N", "k", "C(N,k)", "sum_{j<=k} C(N,j)", "N^k", "bits", "bits/spike", "log2(N)"
    )
    print(" | ".join(f"{name:>22}" for name in header))
    print("-" * 205)
    for row in rows:
        rate = "n/a" if row.bits_per_spike is None else f"{row.bits_per_spike:.6f}"
        ceiling = "n/a" if row.rate_ceiling is None else f"{row.rate_ceiling:.6f}"
        values = (
            str(row.neurons),
            str(row.spikes),
            str(row.exact_capacity),
            str(row.budget_capacity),
            str(row.polynomial_ceiling),
            f"{row.information_bits:.6f}",
            rate,
            ceiling,
        )
        print(" | ".join(f"{value:>22}" for value in values))


def main() -> None:
    """Run exact checks, sparse-capacity examples, and the precision law."""
    print("Small-population enumeration")
    enumerated = layer_histogram_by_enumeration(4)
    formula = [comb(4, k) for k in range(5)]
    assert enumerated == formula == [1, 4, 6, 4, 1]
    print(f"Weight layers for N=4: {enumerated}")
    print(f"Budgets k=0,1,2: {[budget_capacity(4, k) for k in range(3)]}")

    print("\nSparse capacity and information")
    examples = [
        capacity_row(16, 1),
        capacity_row(16, 2),
        capacity_row(100, 1),
        capacity_row(1000, 10),
    ]
    for row in examples:
        assert row.exact_capacity <= row.polynomial_ceiling
        if row.bits_per_spike is not None and row.rate_ceiling is not None:
            assert row.bits_per_spike <= row.rate_ceiling + 1e-12
    print_rows(examples)

    one_hot = capacity_row(100, 1)
    assert abs((one_hot.bits_per_spike or 0.0) - log2(100)) < 1e-12
    print("\nOne-hot coding attains log2(N) bits per spike.")

    print("\nIndependent population precision")
    sigma = 1.0
    for neurons in (1, 4, 16, 100):
        error = population_standard_error(sigma, neurons)
        print(f"N={neurons:>3}: standard error = {error:.6f}, precision = {1/error:.3f}")


if __name__ == "__main__":
    main()
