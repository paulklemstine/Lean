"""
Algorithms for Novikov Self-Consistency via Fixed-Point Theory

Implements the core algorithms for finding self-consistent solutions
to time-travel scenarios modeled as causal loops.
"""

from typing import Callable, Tuple, Optional
import math


def fixed_point_iteration(
    f: Callable[[float], float],
    x0: float,
    K: float,
    epsilon: float = 1e-10,
    max_iter: int = 10000,
) -> Tuple[float, int, float]:
    """Find the fixed point of a contractive map f with factor K.

    Uses Banach's iteration: x_{n+1} = f(x_n).
    Guaranteed to converge if K < 1.

    Args:
        f: The causal map (contraction with factor K)
        x0: Initial state guess
        K: Contraction factor (must be < 1)
        epsilon: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        (fixed_point, iterations, final_severity)
    """
    if K >= 1:
        raise ValueError(f"Contraction factor K={K} must be < 1")

    x = x0
    for i in range(max_iter):
        fx = f(x)
        severity = abs(x - fx)
        if severity < epsilon:
            return fx, i + 1, severity
        x = fx

    return x, max_iter, abs(x - f(x))


def affine_fixed_point(a: float, b: float) -> float:
    """Compute the fixed point of f(x) = ax + b with |a| < 1.

    The unique fixed point is x* = b / (1 - a).

    Args:
        a: Slope (must satisfy |a| < 1)
        b: Offset

    Returns:
        The fixed point b / (1 - a)
    """
    if abs(a) >= 1:
        raise ValueError(f"|a| = {abs(a)} must be < 1")
    return b / (1 - a)


def paradox_severity(
    f: Callable[[float], float], x: float
) -> float:
    """Compute the paradox severity: |x - f(x)|.

    A severity of 0 means x is a self-consistent state.

    Args:
        f: The causal map
        x: The state to evaluate

    Returns:
        |x - f(x)|
    """
    return abs(x - f(x))


def polynomial_deriv_bound(coeffs: list[float], r: float) -> float:
    """Compute the derivative bound for a polynomial on [-r, r].

    For f(x) = sum_i coeffs[i] * x^i, the derivative bound is
    sum_i i * |coeffs[i]| * r^(i-1).

    If this is < 1, f is a contraction on [-r, r].

    Args:
        coeffs: Polynomial coefficients [a0, a1, a2, ...]
        r: Radius of the interval

    Returns:
        The derivative bound
    """
    bound = 0.0
    for i, a in enumerate(coeffs):
        if i > 0:
            bound += i * abs(a) * r ** (i - 1)
    return bound


def polynomial_eval(coeffs: list[float], x: float) -> float:
    """Evaluate a polynomial at x using Horner's method.

    Args:
        coeffs: Polynomial coefficients [a0, a1, a2, ...]
        x: Point to evaluate at

    Returns:
        f(x)
    """
    result = 0.0
    for a in reversed(coeffs):
        result = result * x + a
    return result


def perturbation_stability(
    a: float, b1: float, b2: float
) -> Tuple[float, float]:
    """Compute how much the fixed point shifts when the offset changes.

    For f1(x) = ax + b1 and f2(x) = ax + b2:
    |x1* - x2*| = |b1 - b2| / |1 - a|

    Args:
        a: Common slope
        b1: First offset
        b2: Second offset

    Returns:
        (shift, amplification_factor)
        where shift = |b1-b2| / |1-a| and amplification = 1/|1-a|
    """
    if abs(a) >= 1:
        raise ValueError(f"|a| = {abs(a)} must be < 1")
    shift = abs(b1 - b2) / abs(1 - a)
    amplification = 1 / abs(1 - a)
    return shift, amplification


def compose_causal_loops(
    f1: Callable[[float], float],
    f2: Callable[[float], float],
    K1: float,
    K2: float,
) -> Tuple[Callable[[float], float], float]:
    """Compose two causal loops (nested time travel).

    The composition f1 ∘ f2 has contraction factor K1 * K2.

    Args:
        f1: First causal map
        f2: Second causal map
        K1: Contraction factor of f1
        K2: Contraction factor of f2

    Returns:
        (composed_map, composed_contraction_factor)
    """
    return lambda x: f1(f2(x)), K1 * K2


def multi_traveler_fixed_point(
    maps: list[Callable[[float], float]],
    x0s: list[float],
    Ks: list[float],
    epsilon: float = 1e-10,
    max_iter: int = 10000,
) -> list[Tuple[float, int, float]]:
    """Find self-consistent states for multiple independent travelers.

    Each traveler has their own causal map and contraction factor.

    Args:
        maps: List of causal maps
        x0s: List of initial guesses
        Ks: List of contraction factors

    Returns:
        List of (fixed_point, iterations, severity) for each traveler
    """
    return [
        fixed_point_iteration(f, x0, K, epsilon, max_iter)
        for f, x0, K in zip(maps, x0s, Ks)
    ]


def is_grandfather_paradox(f: Callable[[float], float], test_points: list[float]) -> bool:
    """Check if a causal map behaves like the grandfather paradox.

    The grandfather paradox corresponds to f(x) = -x (state negation).
    We check if f approximately negates all test points.

    Args:
        f: The causal map to test
        test_points: Points to test

    Returns:
        True if f behaves like state negation
    """
    for x in test_points:
        if x != 0 and abs(f(x) + x) > abs(f(x) - x):
            return False
    return True
