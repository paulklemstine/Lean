#!/usr/bin/env python3
"""Numerical demonstrations for finite-scale uncertainty on residue trees.

The program uses only the Python standard library.  It constructs digit-restricted
sets, evaluates normalized discrete Fourier restrictions, and compares measured
energy with the universal cardinality and porous-tree bounds.
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Iterable, Sequence

ComplexSignal = Callable[[int], complex]
Phase = Callable[[int, int], float]


@dataclass(frozen=True)
class ExperimentResult:
    """Summary of one restricted-transform experiment."""

    q: int
    depth: int
    x_size: int
    y_size: int
    ambient_size: int
    input_energy: float
    output_energy: float
    cardinality_bound: float
    porous_bound: float

    @property
    def measured_ratio(self) -> float:
        return self.output_energy / self.input_energy if self.input_energy else 0.0


def digit_restricted_set(q: int, depth: int, digits: Sequence[int]) -> list[int]:
    """Return residues whose base-q digits all belong to ``digits``.

    Runtime and output storage are Theta(len(digits) ** depth).
    """
    if q < 2 or depth < 0:
        raise ValueError("q must be at least 2 and depth must be nonnegative")
    chosen = tuple(sorted(set(digits)))
    if any(d < 0 or d >= q for d in chosen):
        raise ValueError("each retained digit must lie between 0 and q - 1")
    residues = [0]
    place = 1
    for _ in range(depth):
        residues = [x + d * place for x in residues for d in chosen]
        place *= q
    return residues


def energy(values: Iterable[complex]) -> float:
    """Compute squared l2 energy."""
    return sum(abs(z) ** 2 for z in values)


def restricted_transform(
    x_set: Sequence[int],
    y_set: Sequence[int],
    ambient_size: int,
    signal: ComplexSignal,
    phase: Phase,
) -> list[complex]:
    """Evaluate a normalized oscillatory transform in O(|X||Y|) time."""
    if ambient_size <= 0:
        raise ValueError("ambient_size must be positive")
    scale = math.sqrt(ambient_size)
    return [
        sum(cmath.exp(1j * phase(y, x)) * signal(x) for x in x_set) / scale
        for y in y_set
    ]


def uncertainty_factor(q: int, a: int, b: int, depth: int) -> Fraction:
    """Return the exact porous energy factor ((a*b)/q)^depth."""
    if q <= 0 or min(a, b, depth) < 0:
        raise ValueError("parameters must be nonnegative and q must be positive")
    return Fraction((a * b) ** depth, q**depth)


def run_fourier_experiment(
    q: int,
    depth: int,
    x_digits: Sequence[int],
    y_digits: Sequence[int],
    signal: ComplexSignal,
) -> ExperimentResult:
    """Construct digital supports and test the normalized Fourier restriction."""
    n_ambient = q**depth
    x_set = digit_restricted_set(q, depth, x_digits)
    y_set = digit_restricted_set(q, depth, y_digits)
    phase = lambda y, x: 2.0 * math.pi * x * y / n_ambient
    inputs = [signal(x) for x in x_set]
    outputs = restricted_transform(x_set, y_set, n_ambient, signal, phase)
    input_energy = energy(inputs)
    cardinality_factor = len(x_set) * len(y_set) / n_ambient
    porous_factor = float(uncertainty_factor(q, len(set(x_digits)), len(set(y_digits)), depth))
    return ExperimentResult(
        q=q,
        depth=depth,
        x_size=len(x_set),
        y_size=len(y_set),
        ambient_size=n_ambient,
        input_energy=input_energy,
        output_energy=energy(outputs),
        cardinality_bound=cardinality_factor * input_energy,
        porous_bound=porous_factor * input_energy,
    )


def print_result(title: str, result: ExperimentResult) -> None:
    """Print a compact, reproducible report."""
    print(f"\n{title}")
    print("-" * len(title))
    print(f"ambient q^n:       {result.ambient_size}")
    print(f"|X|, |Y|:          {result.x_size}, {result.y_size}")
    print(f"input energy:      {result.input_energy:.12g}")
    print(f"output energy:     {result.output_energy:.12g}")
    print(f"measured ratio:    {result.measured_ratio:.12g}")
    print(f"cardinality bound: {result.cardinality_bound:.12g}")
    print(f"porous bound:      {result.porous_bound:.12g}")
    tolerance = 1e-9 * max(1.0, result.porous_bound)
    assert result.output_energy <= result.cardinality_bound + tolerance
    assert result.output_energy <= result.porous_bound + tolerance


def demo_quintic_depth_three() -> None:
    """Demonstrate the exact 64/125 energy factor."""
    factor = uncertainty_factor(5, 2, 2, 3)
    print("Exact quintic depth-three factor:", factor, "=", float(factor))
    result = run_fourier_experiment(
        5, 3, (0, 1), (0, 2), lambda x: complex(math.cos(x), math.sin(x / 3.0))
    )
    print_result("Quintic depth-three Fourier restriction", result)


def demo_exponential_decay() -> None:
    """Display scale-by-scale decay for q=5 and a=b=2."""
    print("\nStrong-porosity factors for q=5, a=b=2")
    print("depth | exact factor | decimal")
    for depth in range(1, 11):
        factor = uncertainty_factor(5, 2, 2, depth)
        print(f"{depth:5d} | {str(factor):>12s} | {float(factor):.9f}")


def demo_phase_independence() -> None:
    """Check the same support bound for several unrelated phases."""
    q, depth = 5, 3
    n_ambient = q**depth
    x_set = digit_restricted_set(q, depth, (0, 1))
    y_set = digit_restricted_set(q, depth, (0, 2))
    signal = lambda x: complex(1.0 + (x % 7) / 10.0, ((3 * x) % 5) / 8.0)
    phases: list[tuple[str, Phase]] = [
        ("Fourier", lambda y, x: 2.0 * math.pi * x * y / n_ambient),
        ("quadratic", lambda y, x: 2.0 * math.pi * (x * x + 3 * y * x) / n_ambient),
        ("nonlinear", lambda y, x: math.sin(x + 2 * y) + math.sqrt(x + y + 1)),
    ]
    input_energy = energy(signal(x) for x in x_set)
    bound = len(x_set) * len(y_set) * input_energy / n_ambient
    print("\nPhase-independent normalized-kernel bound")
    for name, phase in phases:
        output_energy = energy(
            restricted_transform(x_set, y_set, n_ambient, signal, phase)
        )
        print(f"{name:10s}: output={output_energy:.9f}, bound={bound:.9f}")
        assert output_energy <= bound + 1e-9 * max(1.0, bound)


def main() -> None:
    demo_quintic_depth_three()
    demo_exponential_decay()
    demo_phase_independence()


if __name__ == "__main__":
    main()
