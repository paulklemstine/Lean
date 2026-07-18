#!/usr/bin/env python3
"""Numerical demonstrations for pure two-qubit concurrence.

The script uses only Python's standard library. It evaluates exact benchmark
states, checks the sharp unit-interval bound on reproducible random states,
and displays the distance of concurrence from the nearest integer endpoint.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import sqrt
from random import Random
from typing import Iterable, Sequence


@dataclass(frozen=True)
class TwoQubitState:
    """Computational-basis amplitudes (alpha, beta, gamma, delta)."""

    alpha: complex
    beta: complex
    gamma: complex
    delta: complex

    @property
    def amplitudes(self) -> tuple[complex, complex, complex, complex]:
        return (self.alpha, self.beta, self.gamma, self.delta)


def norm_squared(state: TwoQubitState) -> float:
    """Return |alpha|^2 + |beta|^2 + |gamma|^2 + |delta|^2."""
    return sum(abs(z) ** 2 for z in state.amplitudes)


def normalize(state: TwoQubitState) -> TwoQubitState:
    """Return the unit normalization of a nonzero state."""
    squared = norm_squared(state)
    if squared <= 0.0:
        raise ValueError("the zero amplitude vector cannot be normalized")
    scale = sqrt(squared)
    a, b, c, d = (z / scale for z in state.amplitudes)
    return TwoQubitState(a, b, c, d)


def determinant(state: TwoQubitState) -> complex:
    """Return the exterior-product coordinate alpha*delta-beta*gamma."""
    return state.alpha * state.delta - state.beta * state.gamma


def concurrence(state: TwoQubitState, *, normalize_input: bool = False) -> float:
    """Compute 2*|alpha*delta-beta*gamma|.

    Set normalize_input=True when arbitrary nonzero amplitudes should first be
    projected to the unit sphere.
    """
    state = normalize(state) if normalize_input else state
    return 2.0 * abs(determinant(state))


def nearest_integer_distance(value: float) -> float:
    """Distance from a real value to the nearest integer."""
    return abs(value - round(value))


def benchmark_states() -> dict[str, TwoQubitState]:
    """Return product, Bell, and half-concurrence benchmark states."""
    q = 1.0 / sqrt(2.0)
    return {
        "Product |00>": TwoQubitState(1, 0, 0, 0),
        "Bell Phi+": TwoQubitState(q, 0, 0, q),
        "Bell Phi-": TwoQubitState(q, 0, 0, -q),
        "Bell Psi+": TwoQubitState(0, q, q, 0),
        "Bell Psi-": TwoQubitState(0, q, -q, 0),
        "Half-concurrence witness": TwoQubitState(0.5, q, 0, 0.5),
    }


def random_normalized_state(rng: Random) -> TwoQubitState:
    """Draw and normalize four independent complex Gaussian amplitudes."""
    values = [complex(rng.gauss(0.0, 1.0), rng.gauss(0.0, 1.0)) for _ in range(4)]
    return normalize(TwoQubitState(*values))


def sample_concurrences(count: int, seed: int = 20260718) -> list[float]:
    """Compute concurrence for reproducible random normalized states."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    rng = Random(seed)
    return [concurrence(random_normalized_state(rng)) for _ in range(count)]


def histogram(values: Sequence[float], bins: int = 10) -> list[int]:
    """Count values in equal-width bins covering [0, 1]."""
    if bins <= 0:
        raise ValueError("bins must be positive")
    counts = [0] * bins
    for value in values:
        index = min(int(max(0.0, value) * bins), bins - 1)
        counts[index] += 1
    return counts


def print_benchmarks() -> None:
    print("Exact benchmark states")
    print("-" * 78)
    print(f"{'state':30s} {'norm^2':>12s} {'concurrence':>14s} {'integer gap':>14s}")
    for name, state in benchmark_states().items():
        c = concurrence(state)
        print(f"{name:30s} {norm_squared(state):12.9f} {c:14.9f} "
              f"{nearest_integer_distance(c):14.9f}")
    print()


def print_random_experiment(count: int = 1000) -> None:
    values = sample_concurrences(count)
    tolerance = 1e-12
    assert all(-tolerance <= value <= 1.0 + tolerance for value in values)
    print(f"Random normalized-state experiment ({count} samples)")
    print("-" * 78)
    print(f"minimum concurrence: {min(values):.9f}")
    print(f"maximum concurrence: {max(values):.9f}")
    print(f"mean concurrence:    {sum(values) / len(values):.9f}")
    print("histogram on [0,1]:")
    for index, frequency in enumerate(histogram(values)):
        lo, hi = index / 10.0, (index + 1) / 10.0
        bar = "#" * round(40 * frequency / max(histogram(values)))
        print(f"  [{lo:.1f}, {hi:.1f}]: {frequency:4d} {bar}")
    print()
    print("The random experiment illustrates continuity; the exact 1/2 witness")
    print("is the decisive obstruction to any universally integer-valued model.")


def main() -> None:
    print_benchmarks()
    print_random_experiment()


if __name__ == "__main__":
    main()
