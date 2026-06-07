#!/usr/bin/env python3
"""
Algorithms for EML (Exponential-Multiply-Logarithm) Network Approximation

Type-hinted implementations of the core algorithms from the research.
"""

import numpy as np
from typing import Callable, Optional


def build_exp_vandermonde(
    x: np.ndarray,
    degree: int
) -> np.ndarray:
    """
    Build the exponential Vandermonde matrix.

    Given points x_1, ..., x_n and degree d, constructs the matrix:
        V[i, j] = exp(j * x_i)   for i = 0..n-1, j = 0..d

    This replaces the standard Vandermonde matrix x_i^j with
    exponential monomials, enabling EML approximation.

    Args:
        x: Array of evaluation points, shape (n,)
        degree: Maximum exponent degree d

    Returns:
        Vandermonde-like matrix of shape (n, d+1)
    """
    return np.column_stack([np.exp(k * x) for k in range(degree + 1)])


def eml_least_squares(
    f: Callable[[np.ndarray], np.ndarray],
    degree: int,
    interval: tuple[float, float] = (0.0, 1.0),
    n_points: int = 1000
) -> tuple[np.ndarray, float]:
    """
    Find the best EML approximation of degree d to f on [a, b].

    Solves: min_{c_0, ..., c_d} ||f - sum_j c_j exp(j*x)||_2

    This is the computational realization of the density theorem:
    as degree → ∞, the error → 0 for any continuous f.

    Args:
        f: Target function
        degree: Number of exponential monomials minus 1
        interval: Domain [a, b]
        n_points: Number of grid points for least squares

    Returns:
        (coefficients, sup_norm_error)
    """
    a, b = interval
    x = np.linspace(a, b, n_points)
    V = build_exp_vandermonde(x, degree)
    y = f(x)

    coeffs, _, _, _ = np.linalg.lstsq(V, y, rcond=None)
    approx = V @ coeffs
    error = float(np.max(np.abs(approx - y)))

    return coeffs, error


def eml_evaluate(
    coeffs: np.ndarray,
    x: np.ndarray
) -> np.ndarray:
    """
    Evaluate an EML polynomial at given points.

    Computes: sum_{k=0}^{d} coeffs[k] * exp(k * x)

    Args:
        coeffs: Coefficient array of shape (d+1,)
        x: Evaluation points

    Returns:
        Function values at x
    """
    result = np.zeros_like(x, dtype=float)
    for k, c in enumerate(coeffs):
        result += c * np.exp(k * x)
    return result


def adaptive_eml_approximation(
    f: Callable[[np.ndarray], np.ndarray],
    epsilon: float,
    interval: tuple[float, float] = (0.0, 1.0),
    max_degree: int = 100,
    n_points: int = 2000
) -> tuple[np.ndarray, int, float]:
    """
    Adaptively find EML approximation to within epsilon.

    Increases degree until the sup-norm error drops below epsilon.
    By the Stone-Weierstrass density theorem, this is guaranteed
    to terminate for continuous f (given sufficient numerical precision).

    Args:
        f: Target continuous function
        epsilon: Desired approximation accuracy
        interval: Domain [a, b]
        max_degree: Maximum degree to try
        n_points: Grid resolution

    Returns:
        (coefficients, degree_used, achieved_error)
    """
    for d in range(1, max_degree + 1):
        coeffs, error = eml_least_squares(f, d, interval, n_points)
        if error < epsilon:
            return coeffs, d, error

    # Return best found even if epsilon not achieved
    return coeffs, max_degree, error


def separation_witness(
    x: float,
    y: float
) -> tuple[float, float]:
    """
    Compute the separation witness for two distinct points.

    By the injective generator theorem, exp(x) != exp(y) whenever x != y.
    Returns (exp(x), exp(y)) as the separating values.

    This is the constructive content of the separation property
    used in the Stone-Weierstrass proof.

    Args:
        x: First point
        y: Second point (must differ from x)

    Returns:
        (exp(x), exp(y)) — guaranteed distinct when x != y
    """
    assert x != y, "Points must be distinct for separation"
    return np.exp(x), np.exp(y)


def exp_composition_chain(
    x: np.ndarray,
    depth: int
) -> np.ndarray:
    """
    Compute the depth-d composition exp^(d)(x) = exp(exp(...exp(x)...)).

    By the composition depth theorem, each exp^(d) individually
    generates a dense algebra — but deeper compositions grow
    dramatically faster, suggesting a depth hierarchy.

    Args:
        x: Input points
        depth: Number of exp applications

    Returns:
        exp^(d)(x)
    """
    result = x.copy().astype(float)
    for _ in range(depth):
        # Clip to prevent overflow
        result = np.clip(result, -500, 500)
        result = np.exp(result)
    return result


def condition_number_comparison(
    n: int,
    activations: Optional[dict[str, Callable]] = None
) -> dict[str, float]:
    """
    Compare condition numbers of Vandermonde matrices for different activations.

    For each activation σ, builds the matrix M[i,j] = σ(x_i)^j
    and computes its condition number. Lower condition numbers
    indicate better numerical stability for approximation.

    Args:
        n: Matrix size (n×n)
        activations: Dict of activation name -> function.
            Defaults to exp, tanh, sigmoid.

    Returns:
        Dict of activation name -> condition number
    """
    if activations is None:
        activations = {
            "exp": np.exp,
            "tanh": np.tanh,
            "sigmoid": lambda x: 1 / (1 + np.exp(-x)),
        }

    x = np.linspace(0.01, 0.99, n)
    results = {}

    for name, sigma in activations.items():
        V = np.column_stack([sigma(x)**j for j in range(n)])
        try:
            results[name] = float(np.linalg.cond(V))
        except np.linalg.LinAlgError:
            results[name] = float('inf')

    return results


if __name__ == "__main__":
    # Quick test
    f = lambda x: np.sin(2 * np.pi * x)
    coeffs, degree, error = adaptive_eml_approximation(f, epsilon=1e-6)
    print(f"Approximated sin(2πx) to error {error:.2e} using degree {degree}")

    # Condition number comparison
    for n in [5, 10, 20]:
        conds = condition_number_comparison(n)
        print(f"\nCondition numbers (n={n}):")
        for name, cond in sorted(conds.items()):
            print(f"  {name:>10}: {cond:.2e}")
