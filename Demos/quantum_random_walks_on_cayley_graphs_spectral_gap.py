#!/usr/bin/env python3
"""Numerical demonstrations of periodic quantum-walk mixing obstructions.

The script uses only the Python standard library.  It compares instantaneous
Born distributions with Cesàro averages for finite cyclic shifts, verifies
exact recurrence, and audits the unit-modulus spectrum analytically.
"""

from __future__ import annotations

import argparse
import cmath
import math
from typing import Iterable, Sequence

Vector = list[complex]
Distribution = list[float]


def cyclic_shift(state: Sequence[complex], steps: int = 1) -> Vector:
    """Apply the clockwise cyclic shift by ``steps`` positions."""
    size = len(state)
    if size == 0:
        raise ValueError("state must be nonempty")
    shift = steps % size
    return [complex(state[(x - shift) % size]) for x in range(size)]


def born_distribution(state: Sequence[complex]) -> Distribution:
    """Return coordinatewise squared moduli."""
    return [abs(amplitude) ** 2 for amplitude in state]


def total_variation(p: Sequence[float], q: Sequence[float]) -> float:
    """Compute one half of the L1 distance between finite distributions."""
    if len(p) != len(q):
        raise ValueError("distributions must have the same size")
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def mean_distributions(distributions: Iterable[Sequence[float]]) -> Distribution:
    """Compute the coordinatewise arithmetic mean of finite distributions."""
    rows = [list(row) for row in distributions]
    if not rows:
        raise ValueError("at least one distribution is required")
    size = len(rows[0])
    if any(len(row) != size for row in rows):
        raise ValueError("all distributions must have the same size")
    return [sum(row[x] for row in rows) / len(rows) for x in range(size)]


def cyclic_probabilities(size: int, horizon: int) -> list[Distribution]:
    """Generate Born distributions for a localized cyclic-shift walk."""
    if size <= 1:
        raise ValueError("size must exceed one")
    if horizon <= 0:
        raise ValueError("horizon must be positive")
    initial: Vector = [1.0 + 0.0j] + [0.0j] * (size - 1)
    return [born_distribution(cyclic_shift(initial, n)) for n in range(horizon)]


def cyclic_eigenvalues(size: int) -> Vector:
    """Return the eigenvalues of the cyclic shift, the size-th roots of unity."""
    if size <= 0:
        raise ValueError("size must be positive")
    return [cmath.exp(2.0j * math.pi * j / size) for j in range(size)]


def format_distribution(p: Sequence[float]) -> str:
    """Format a distribution compactly for terminal output."""
    return "[" + ", ".join(f"{value:.4f}" for value in p) + "]"


def demonstrate_localized_cycle(size: int, periods: int) -> None:
    """Show recurrence, failed instantaneous mixing, and successful averaging."""
    horizon = size * periods
    probabilities = cyclic_probabilities(size, horizon)
    uniform = [1.0 / size] * size
    distances = [total_variation(p, uniform) for p in probabilities]
    average = mean_distributions(probabilities)

    print(f"\nLocalized cyclic shift on Z/{size}Z")
    print("first period:")
    for n, p in enumerate(probabilities[:size]):
        print(f"  n={n:2d}: P_n={format_distribution(p)}  TV={distances[n]:.6f}")
    recurrent = born_distribution(cyclic_shift([1.0 + 0.0j] + [0.0j] * (size - 1), size))
    print(f"P_{size} equals P_0: {recurrent == probabilities[0]}")
    print(f"constant instantaneous TV distance: {distances[0]:.6f}")
    print(f"Cesaro average through T={horizon}: {format_distribution(average)}")
    print(f"Cesaro TV distance: {total_variation(average, uniform):.3e}")

    assert all(abs(d - (1.0 - 1.0 / size)) < 1e-12 for d in distances)
    assert total_variation(average, uniform) < 1e-12


def demonstrate_uniform_initial_state(size: int) -> None:
    """Show that an initially uniform Born profile remains uniform under a shift."""
    state = [1.0 / math.sqrt(size) + 0.0j] * size
    initial = born_distribution(state)
    evolved = born_distribution(cyclic_shift(state, 1))
    print(f"\nUniform-amplitude state on {size} positions")
    print(f"P_0: {format_distribution(initial)}")
    print(f"P_1: {format_distribution(evolved)}")
    print(f"unchanged: {all(abs(a - b) < 1e-12 for a, b in zip(initial, evolved))}")


def demonstrate_spectrum(size: int) -> None:
    """Show that cyclic-shift eigenvalues all have modulus one."""
    eigenvalues = cyclic_eigenvalues(size)
    moduli = [abs(value) for value in eigenvalues]
    phases = [cmath.phase(value) for value in eigenvalues]
    modulus_gap = 1.0 - sorted(moduli, reverse=True)[1] if size > 1 else 0.0
    print(f"\nSpectrum of the {size}-cycle shift")
    for index, (value, phase) in enumerate(zip(eigenvalues, phases)):
        print(
            f"  lambda_{index}={value.real:+.6f}{value.imag:+.6f}i, "
            f"|lambda|={abs(value):.12f}, phase={phase:+.6f}"
        )
    print(f"modulus gap 1-|lambda_2|: {modulus_gap:.3e}")
    assert max(abs(modulus - 1.0) for modulus in moduli) < 1e-12


def main() -> None:
    """Run all numerical demonstrations."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--size", type=int, default=5, help="cycle size, at least 2")
    parser.add_argument("--periods", type=int, default=2, help="number of full periods")
    args = parser.parse_args()
    if args.size < 2 or args.periods < 1:
        parser.error("--size must be at least 2 and --periods must be positive")

    demonstrate_localized_cycle(args.size, args.periods)
    demonstrate_uniform_initial_state(args.size)
    demonstrate_spectrum(args.size)


if __name__ == "__main__":
    main()
