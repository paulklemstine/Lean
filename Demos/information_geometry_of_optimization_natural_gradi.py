#!/usr/bin/env python3
"""Numerical demonstrations for matched natural-gradient dynamics.

The script uses only the Python standard library. It checks the exact constant-step
and harmonic-step energy laws, compares natural and Euclidean gradient descent as
conditioning varies, and exhibits a variable-metric Euler endpoint that is not a
geodesic midpoint.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, sqrt
from typing import Iterable, List, Sequence, Tuple

Vector = List[float]


def fisher_energy(weights: Sequence[float], x: Sequence[float]) -> float:
    """Return E_w(x) = (1/2) sum_i w_i x_i^2."""
    if len(weights) != len(x):
        raise ValueError("weights and x must have the same dimension")
    if any(weight <= 0.0 for weight in weights):
        raise ValueError("all metric weights must be positive")
    return 0.5 * sum(weight * value * value for weight, value in zip(weights, x))


def matched_natural_step(x: Sequence[float], eta: float) -> Vector:
    """Apply the matched natural-gradient update x <- (1-eta)x."""
    return [(1.0 - eta) * value for value in x]


def euclidean_gradient_step(
    weights: Sequence[float], x: Sequence[float], alpha: float
) -> Vector:
    """Apply ordinary gradient descent to E_w with step alpha."""
    if len(weights) != len(x):
        raise ValueError("weights and x must have the same dimension")
    return [(1.0 - alpha * weight) * value for weight, value in zip(weights, x)]


def constant_orbit(
    x0: Sequence[float], eta: float, iterations: int
) -> List[Vector]:
    """Return all matched constant-step iterates from x_0 through x_iterations."""
    if iterations < 0:
        raise ValueError("iterations must be nonnegative")
    orbit: List[Vector] = [list(x0)]
    for _ in range(iterations):
        orbit.append(matched_natural_step(orbit[-1], eta))
    return orbit


def harmonic_orbit(x0: Sequence[float], iterations: int) -> List[Vector]:
    """Use eta_k=1/(k+2) at the transition from k to k+1."""
    if iterations < 0:
        raise ValueError("iterations must be nonnegative")
    orbit: List[Vector] = [list(x0)]
    for k in range(iterations):
        orbit.append(matched_natural_step(orbit[-1], 1.0 / (k + 2.0)))
    return orbit


def geodesic_midpoint_square_metric(start: float, target: float) -> float:
    """Midpoint for ds^2=4x^2 dx^2 on positive x, using Phi(x)=x^2."""
    if start <= 0.0 or target <= 0.0:
        raise ValueError("the demonstration uses the positive half-line")
    return sqrt((start * start + target * target) / 2.0)


def euler_endpoint(
    start: float, inverse_metric: float, loss_derivative: float
) -> float:
    """Return one unit-multiplier natural-gradient Euler endpoint."""
    return start - inverse_metric * loss_derivative


def demonstrate_constant_rate() -> None:
    """Check the exact geometric energy law for highly unequal weights."""
    weights = [1.0, 100.0, 1_000_000.0]
    x0 = [3.0, -2.0, 0.01]
    eta = 0.2
    initial = fisher_energy(weights, x0)
    print("\n1. Exact constant-step energy law")
    print(" k       computed energy          exact energy       abs. error")
    for k, x in enumerate(constant_orbit(x0, eta, 8)):
        computed = fisher_energy(weights, x)
        exact = ((1.0 - eta) ** 2) ** k * initial
        assert isclose(computed, exact, rel_tol=1e-12, abs_tol=1e-12)
        print(f"{k:2d}  {computed:20.10f}  {exact:20.10f}  {abs(computed-exact):.2e}")


def demonstrate_harmonic_rate() -> None:
    """Check x_k=x_0/(k+1) and E_k=E_0/(k+1)^2."""
    weights = [0.5, 7.0, 250.0]
    x0 = [4.0, -3.0, 2.0]
    initial = fisher_energy(weights, x0)
    print("\n2. Exact harmonic-step laws")
    print(" k      max parameter error       energy error")
    for k, x in enumerate(harmonic_orbit(x0, 10)):
        expected_x = [value / (k + 1.0) for value in x0]
        parameter_error = max(abs(a - b) for a, b in zip(x, expected_x))
        energy_error = abs(fisher_energy(weights, x) - initial / (k + 1.0) ** 2)
        assert parameter_error < 1e-12
        assert energy_error < 1e-10
        print(f"{k:2d}  {parameter_error:23.3e}  {energy_error:17.3e}")


def demonstrate_conditioning() -> None:
    """Compare matched natural and Euclidean descent over condition numbers."""
    eta = 0.2
    iterations = 20
    # Initialize the slow, low-curvature mode so total energy does not hide it.
    x0 = [1.0, 0.0]
    print("\n3. Conditioning comparison after 20 iterations")
    print(" kappa       natural relative E      Euclidean relative E")
    for kappa in [10.0, 100.0, 10_000.0, 1_000_000.0]:
        weights = [1.0, kappa]
        natural = list(x0)
        euclidean = list(x0)
        alpha = 1.0 / kappa
        for _ in range(iterations):
            natural = matched_natural_step(natural, eta)
            euclidean = euclidean_gradient_step(weights, euclidean, alpha)
        initial = fisher_energy(weights, x0)
        natural_ratio = fisher_energy(weights, natural) / initial
        euclidean_ratio = fisher_energy(weights, euclidean) / initial
        exact_natural_ratio = ((1.0 - eta) ** 2) ** iterations
        assert isclose(natural_ratio, exact_natural_ratio, rel_tol=1e-12)
        print(f"{kappa:8.0f}  {natural_ratio:23.8e}  {euclidean_ratio:24.8e}")


def demonstrate_geodesic_separation() -> None:
    """Show that Euler natural gradient misses the intrinsic midpoint."""
    start, target = 2.0, 1.0
    midpoint = geodesic_midpoint_square_metric(start, target)
    endpoint = euler_endpoint(start, inverse_metric=1.0 / 16.0, loss_derivative=8.0)
    intrinsic_midpoint_square = (start * start + target * target) / 2.0
    print("\n4. Euler endpoint versus geodesic midpoint")
    print(f"Euler endpoint:                  {endpoint:.10f}")
    print(f"Geodesic midpoint:              {midpoint:.10f}")
    print(f"Euler squared coordinate:       {endpoint**2:.10f}")
    print(f"Required midpoint square:       {intrinsic_midpoint_square:.10f}")
    assert not isclose(endpoint * endpoint, intrinsic_midpoint_square)


def main() -> None:
    """Run all demonstrations and their numerical consistency checks."""
    demonstrate_constant_rate()
    demonstrate_harmonic_rate()
    demonstrate_conditioning()
    demonstrate_geodesic_separation()


if __name__ == "__main__":
    main()
