#!/usr/bin/env python3
"""
Social Credit Score Dynamics: Core Algorithms

Type-hinted implementations of the mathematical algorithms
formalized in Lean 4.
"""

from typing import Callable
import math


def logistic_map(mu: float, x: float) -> float:
    """
    The logistic scoring function f_μ(x) = μ·x·(1-x).

    Parameters:
        mu: Feedback intensity parameter (μ ∈ [0, 4] for [0,1] → [0,1])
        x: Current score value

    Returns:
        Updated score value
    """
    return mu * x * (1.0 - x)


def logistic_derivative(mu: float, x: float) -> float:
    """
    Derivative of the logistic map: f'_μ(x) = μ·(1 - 2x).

    Parameters:
        mu: Feedback intensity parameter
        x: Point at which to evaluate the derivative

    Returns:
        Derivative value f'_μ(x)
    """
    return mu * (1.0 - 2.0 * x)


def nontrivial_fixed_point(mu: float) -> float:
    """
    Non-trivial fixed point of the logistic map: x* = 1 - 1/μ.

    Parameters:
        mu: Feedback intensity (must be nonzero)

    Returns:
        The non-trivial fixed point x* = (μ-1)/μ

    Raises:
        ValueError: if mu is zero
    """
    if mu == 0:
        raise ValueError("μ must be nonzero")
    return 1.0 - 1.0 / mu


def classify_fixed_point_stability(mu: float) -> str:
    """
    Classify the stability of the non-trivial fixed point of f_μ.

    Returns one of:
        "nonexistent" (μ ≤ 0): no viable non-trivial fixed point
        "pre_bifurcation" (0 < μ < 1): x* < 0, only x=0 is viable
        "bifurcation" (μ = 1): transcritical bifurcation, x* = 0
        "stable" (1 < μ < 3): |f'(x*)| < 1, linearly stable
        "marginal" (μ = 3): |f'(x*)| = 1, onset of period doubling
        "unstable" (μ > 3): |f'(x*)| > 1, period doubling cascade
    """
    if mu <= 0:
        return "nonexistent"
    if mu < 1:
        return "pre_bifurcation"
    if mu == 1:
        return "bifurcation"
    if mu < 3:
        return "stable"
    if mu == 3:
        return "marginal"
    return "unstable"


def iterate_scoring(
    f: Callable[[float], float],
    x0: float,
    n_iterations: int
) -> list[float]:
    """
    Iterate a scoring function f starting from x0 for n iterations.

    Parameters:
        f: Scoring function (maps [0,1] → [0,1])
        x0: Initial score
        n_iterations: Number of iterations

    Returns:
        List of score values [x0, f(x0), f²(x0), ..., fⁿ(x0)]
    """
    trajectory: list[float] = [x0]
    x = x0
    for _ in range(n_iterations):
        x = f(x)
        trajectory.append(x)
    return trajectory


def find_fixed_point_bisection(
    f: Callable[[float], float],
    a: float = 0.0,
    b: float = 1.0,
    tol: float = 1e-14,
    max_iter: int = 200
) -> float:
    """
    Find a fixed point of f in [a,b] using bisection on g(x) = f(x) - x.

    Requires g(a) and g(b) to have opposite signs (guaranteed if f: [0,1] → [0,1]).

    Parameters:
        f: Continuous function mapping [a,b] to [a,b]
        a, b: Interval endpoints
        tol: Tolerance for convergence
        max_iter: Maximum bisection steps

    Returns:
        Approximate fixed point x* with |f(x*) - x*| < tol
    """
    def g(x: float) -> float:
        return f(x) - x

    ga = g(a)
    for _ in range(max_iter):
        mid = (a + b) / 2.0
        gm = g(mid)
        if abs(gm) < tol:
            return mid
        if ga * gm <= 0:
            b = mid
        else:
            a = mid
            ga = gm
    return (a + b) / 2.0


def cantor_stage_measure(n: int) -> float:
    """
    Measure of the Cantor set after n stages of middle-third removal.

    The measure is (2/3)^n, which converges to 0 as n → ∞.

    Parameters:
        n: Number of removal stages

    Returns:
        Total Lebesgue measure of remaining intervals
    """
    return (2.0 / 3.0) ** n


def cantor_interval_count(n: int) -> int:
    """Number of intervals remaining after n Cantor stages: 2^n."""
    return 2 ** n


def cantor_interval_length(n: int) -> float:
    """Length of each interval after n Cantor stages: (1/3)^n."""
    return (1.0 / 3.0) ** n


def bifurcation_diagram(
    mu_min: float = 0.5,
    mu_max: float = 4.0,
    mu_steps: int = 1000,
    n_warmup: int = 500,
    n_plot: int = 200,
    x0: float = 0.5
) -> list[tuple[float, float]]:
    """
    Compute the bifurcation diagram of the logistic map.

    For each μ value, iterate the logistic map from x0, discard transients,
    and record the attractor points.

    Parameters:
        mu_min, mu_max: Parameter range
        mu_steps: Number of μ values to sample
        n_warmup: Iterations to discard (transient)
        n_plot: Iterations to record (attractor)
        x0: Initial condition

    Returns:
        List of (μ, x) pairs representing the bifurcation diagram
    """
    points: list[tuple[float, float]] = []
    for i in range(mu_steps):
        mu = mu_min + (mu_max - mu_min) * i / (mu_steps - 1)
        x = x0
        # Warm up
        for _ in range(n_warmup):
            x = logistic_map(mu, x)
        # Record attractor
        for _ in range(n_plot):
            x = logistic_map(mu, x)
            points.append((mu, x))
    return points


def feigenbaum_ratio(mu_values: list[float]) -> list[float]:
    """
    Compute successive Feigenbaum ratios from bifurcation parameter values.

    Given μ₁, μ₂, μ₃, ..., computes (μₙ - μₙ₋₁)/(μₙ₊₁ - μₙ) for each n.
    These ratios should approach the Feigenbaum constant δ ≈ 4.6692...

    Parameters:
        mu_values: List of successive bifurcation parameters

    Returns:
        List of Feigenbaum ratios
    """
    ratios: list[float] = []
    for i in range(1, len(mu_values) - 1):
        gap_prev = mu_values[i] - mu_values[i - 1]
        gap_next = mu_values[i + 1] - mu_values[i]
        if abs(gap_next) > 1e-15:
            ratios.append(gap_prev / gap_next)
    return ratios


if __name__ == "__main__":
    # Quick self-test
    print("Logistic map at μ=2.5, x=0.5:", logistic_map(2.5, 0.5))
    print("Non-trivial fixed point at μ=2.5:", nontrivial_fixed_point(2.5))
    print("Stability at μ=2.5:", classify_fixed_point_stability(2.5))
    print("Cantor measure at n=10:", cantor_stage_measure(10))

    # Feigenbaum test
    known_bifurcations = [3.0, 1 + math.sqrt(6), 3.5441, 3.5644]
    ratios = feigenbaum_ratio(known_bifurcations)
    print("Feigenbaum ratios:", [f"{r:.3f}" for r in ratios])
