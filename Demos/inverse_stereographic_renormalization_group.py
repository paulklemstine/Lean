#!/usr/bin/env python3
"""Numerical demonstrations for inverse-stereographic Ising decimation."""

from __future__ import annotations

from math import hypot
from typing import Iterable, Tuple

Point = Tuple[float, float]


def ising_rg(g: float) -> float:
    """Return the exact one-step coupling update R(g) = g^2."""
    return g * g


def beta_discrete(g: float) -> float:
    """Return the finite-step displacement B(g) = R(g) - g."""
    return ising_rg(g) - g


def rg_derivative(g: float) -> float:
    """Return R'(g) = 2g."""
    return 2.0 * g


def beta_derivative(g: float) -> float:
    """Return B'(g) = 2g - 1."""
    return 2.0 * g - 1.0


def inverse_stereographic(g: float) -> Point:
    """Map a finite real coupling to the unit circle."""
    denominator = 1.0 + g * g
    return (2.0 * g / denominator, (1.0 - g * g) / denominator)


def circle_rg(point: Point) -> Point:
    """Apply the rational circle-coordinate renormalization map."""
    x, y = point
    return (x * x / (2.0 - x * x), 2.0 * y / (1.0 + y * y))


def conjugacy_residual(g: float) -> float:
    """Measure ||S(R(g)) - C(S(g))||_2 in floating-point arithmetic."""
    left = inverse_stereographic(ising_rg(g))
    right = circle_rg(inverse_stereographic(g))
    return hypot(left[0] - right[0], left[1] - right[1])


def circle_residual(g: float) -> float:
    """Measure |x^2 + y^2 - 1| for S(g)."""
    x, y = inverse_stereographic(g)
    return abs(x * x + y * y - 1.0)


def iterate_rg(g: float, steps: int) -> list[float]:
    """Return g, R(g), ..., R^steps(g)."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    orbit = [g]
    for _ in range(steps):
        g = ising_rg(g)
        orbit.append(g)
    return orbit


def print_table(couplings: Iterable[float]) -> None:
    """Print update, beta, derivative, and geometric residual data."""
    header = "{:>8} {:>12} {:>12} {:>12} {:>12} {:>13} {:>13}".format(
        "g", "R(g)", "B(g)", "R'(g)", "B'(g)", "circle err", "conj. err"
    )
    print(header)
    print("-" * len(header))
    for g in couplings:
        print(
            f"{g:8.4f} {ising_rg(g):12.8f} {beta_discrete(g):12.8f} "
            f"{rg_derivative(g):12.8f} {beta_derivative(g):12.8f} "
            f"{circle_residual(g):13.3e} {conjugacy_residual(g):13.3e}"
        )


def main() -> None:
    """Run the small-case table and display representative RG orbits."""
    samples = [0.0, 0.25, 0.5, 0.75, 1.0, -0.5, 2.0]
    print("Inverse-stereographic Ising renormalization\n")
    print_table(samples)

    print("\nPhysical coupling orbits:")
    for initial in (0.25, 0.5, 0.75, 1.0):
        orbit = iterate_rg(initial, 6)
        formatted = " -> ".join(f"{value:.8g}" for value in orbit)
        print(f"g0={initial:.2f}: {formatted}")

    tolerance = 1.0e-12
    assert all(circle_residual(g) < tolerance for g in samples)
    assert all(conjugacy_residual(g) < tolerance for g in samples)
    assert ising_rg(0.25) == 0.0625
    assert ising_rg(0.5) == 0.25
    assert ising_rg(0.75) == 0.5625
    print("\nAll numerical diagnostics passed.")


if __name__ == "__main__":
    main()
