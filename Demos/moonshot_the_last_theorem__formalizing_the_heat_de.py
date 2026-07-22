#!/usr/bin/env python3
"""Numerical demonstrations for countable theorem libraries and finite resources.

The script uses only Python's standard library. It illustrates:
1. reciprocal decay of the finite-budget discoverable fraction;
2. quadratic Bekenstein--Hawking entropy scaling in Planck units;
3. crossover of quadratic and linear storage laws; and
4. finite holographic capacity followed by zero-density decay.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import floor, pi
from typing import Iterable, Sequence


@dataclass(frozen=True)
class FractionSample:
    """A sample of finite-budget coverage at one prefix length."""

    prefix_size: int
    reachable: int
    fraction: float


@dataclass(frozen=True)
class EntropySample:
    """An entropy value and its ratio to a unit-mass reference."""

    mass: float
    entropy: float
    ratio_to_unit_mass: float


def discoverable_fraction(budget: int, prefix_size: int) -> float:
    """Return min(budget, prefix_size) / prefix_size, with value 0 at zero.

    Args:
        budget: Maximum number of distinct theorems available; must be nonnegative.
        prefix_size: Number of enumerated theorems considered; must be nonnegative.
    """
    if budget < 0 or prefix_size < 0:
        raise ValueError("budget and prefix_size must be nonnegative")
    if prefix_size == 0:
        return 0.0
    return min(budget, prefix_size) / prefix_size


def fraction_profile(budget: int, prefix_sizes: Iterable[int]) -> list[FractionSample]:
    """Evaluate the finite-budget fraction at supplied prefix sizes."""
    samples: list[FractionSample] = []
    for n in prefix_sizes:
        fraction = discoverable_fraction(budget, n)
        samples.append(FractionSample(n, min(budget, n), fraction))
    return samples


def schwarzschild_radius(a: float, mass: float) -> float:
    """Return the idealized Schwarzschild radius r = a M."""
    return a * mass


def horizon_area(radius: float) -> float:
    """Return spherical horizon area A = 4 pi r^2."""
    return 4.0 * pi * radius**2


def bekenstein_entropy(a: float, mass: float) -> float:
    """Return S = A/4 = pi a^2 M^2 in Planck units."""
    return horizon_area(schwarzschild_radius(a, mass)) / 4.0


def entropy_profile(a: float, masses: Iterable[float]) -> list[EntropySample]:
    """Compute entropy and its ratio to entropy at unit mass."""
    baseline = bekenstein_entropy(a, 1.0)
    samples: list[EntropySample] = []
    for mass in masses:
        entropy = bekenstein_entropy(a, mass)
        ratio = entropy / baseline if baseline != 0.0 else float("nan")
        samples.append(EntropySample(mass, entropy, ratio))
    return samples


def quadratic_linear_crossover(k: float, c: float) -> float:
    """Return the nonnegative threshold M = c/k where k M^2 meets c M."""
    if k <= 0.0 or c < 0.0:
        raise ValueError("k must be positive and c must be nonnegative")
    return c / k


def holographic_theorem_budget(a: float, mass: float) -> int:
    """Return max(0, floor(S)) as an idealized theorem capacity."""
    return max(0, floor(bekenstein_entropy(a, mass)))


def format_table(headers: Sequence[str], rows: Sequence[Sequence[str]]) -> str:
    """Format a compact plain-text table."""
    widths = [len(header) for header in headers]
    for row in rows:
        for index, cell in enumerate(row):
            widths[index] = max(widths[index], len(cell))
    line = "-+-".join("-" * width for width in widths)
    output = [" | ".join(h.ljust(widths[i]) for i, h in enumerate(headers)), line]
    output.extend(" | ".join(cell.rjust(widths[i]) for i, cell in enumerate(row)) for row in rows)
    return "\n".join(output)


def run_finite_budget_demo() -> None:
    """Print reciprocal decay for a representative fixed theorem budget."""
    budget = 1_000
    prefixes = [1, 10, 100, 1_000, 10_000, 100_000, 1_000_000]
    samples = fraction_profile(budget, prefixes)
    rows = [
        (f"{s.prefix_size:,}", f"{s.reachable:,}", f"{s.fraction:.6g}")
        for s in samples
    ]
    print("\nFINITE-BUDGET DISCOVERY FRACTION")
    print(format_table(("prefix n", "reachable", "min(N,n)/n"), rows))
    assert samples[-1].fraction == budget / prefixes[-1]


def run_entropy_scaling_demo() -> None:
    """Print the quadratic entropy profile and check the scaling law."""
    a = 2.0
    masses = [0.5, 1.0, 2.0, 3.0, 10.0]
    samples = entropy_profile(a, masses)
    rows = [
        (f"{s.mass:g}", f"{s.entropy:.6f}", f"{s.ratio_to_unit_mass:.6g}")
        for s in samples
    ]
    print("\nQUADRATIC HORIZON ENTROPY")
    print(format_table(("mass M", "S = pi a^2 M^2", "S(M)/S(1)"), rows))
    unit = bekenstein_entropy(a, 1.0)
    assert abs(bekenstein_entropy(a, 2.0) - 4.0 * unit) < 1e-12
    assert abs(bekenstein_entropy(a, 3.0) - 9.0 * unit) < 1e-12


def run_crossover_demo() -> None:
    """Compare a quadratic capacity with a linear capacity around crossover."""
    k, c = 3.0, 24.0
    threshold = quadratic_linear_crossover(k, c)
    masses = [threshold / 2.0, threshold, 2.0 * threshold, 10.0 * threshold]
    rows: list[tuple[str, str, str, str]] = []
    for mass in masses:
        quadratic = k * mass**2
        linear = c * mass
        rows.append(
            (f"{mass:g}", f"{linear:.3f}", f"{quadratic:.3f}", str(quadratic >= linear))
        )
    print("\nQUADRATIC--LINEAR CROSSOVER")
    print(f"Threshold c/k = {threshold:g}")
    print(format_table(("mass M", "cM", "kM^2", "quadratic >= linear"), rows))


def run_holographic_fraction_demo() -> None:
    """Turn finite entropy into an integer budget and display density decay."""
    a, mass = 2.0, 10.0
    budget = holographic_theorem_budget(a, mass)
    prefixes = [budget, 10 * budget, 100 * budget, 1_000 * budget]
    samples = fraction_profile(budget, prefixes)
    rows = [(f"{s.prefix_size:,}", f"{s.fraction:.6g}") for s in samples]
    print("\nFINITE HOLOGRAPHIC CAPACITY")
    print(f"a = {a:g}, M = {mass:g}, floor(S) = {budget:,} theorem slots")
    print(format_table(("prefix n", "covered fraction"), rows))


def main() -> None:
    """Run all numerical demonstrations."""
    run_finite_budget_demo()
    run_entropy_scaling_demo()
    run_crossover_demo()
    run_holographic_fraction_demo()


if __name__ == "__main__":
    main()
