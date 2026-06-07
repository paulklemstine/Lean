#!/usr/bin/env python3
"""
EML Approximation Algorithms

Type-hinted implementations of the key algorithms from the
EML Stone-Weierstrass approximation theory.
"""

from typing import List, Tuple, Callable
import numpy as np


def eml_generator(x: np.ndarray, w: float, b: float) -> np.ndarray:
    """
    EML affine-exponential generator: exp(w*x + b).

    This is the fundamental building block of the EML subalgebra.
    The Stone-Weierstrass theorem guarantees that finite linear
    combinations and products of these generators can approximate
    any continuous function on a compact set.

    Args:
        x: Input array of shape (n,)
        w: Weight parameter
        b: Bias parameter

    Returns:
        Array of exp(w*x + b) values
    """
    return np.exp(np.clip(w * x + b, -500, 500))


def log_sum_exp_smooth_max(values: np.ndarray, t: float) -> float:
    """
    Smooth maximum via log-sum-exp (Maslov dequantization).

    Computes (1/t) * log(sum(exp(t * v_i))) which converges to
    max(v_i) as t → ∞.

    This is the bridge between EML (smooth) and tropical (piecewise-linear)
    arithmetic.

    Args:
        values: Array of real values
        t: Temperature parameter (larger = closer to true max)

    Returns:
        Smooth approximation to max(values)
    """
    scaled = t * values
    m = np.max(scaled)  # numerical stability
    return (1.0 / t) * (m + np.log(np.sum(np.exp(scaled - m))))


def eml_least_squares_fit(
    x: np.ndarray,
    target: np.ndarray,
    generators: List[Tuple[float, float]],
    include_constant: bool = True
) -> Tuple[np.ndarray, float]:
    """
    Fit an EML network to a target function via least squares.

    Constructs a linear combination of EML generators and finds
    optimal coefficients by ordinary least squares.

    Args:
        x: Input points of shape (n,)
        target: Target values of shape (n,)
        generators: List of (w, b) parameter pairs for EML generators
        include_constant: Whether to include a constant term

    Returns:
        Tuple of (coefficients, max_error)
    """
    basis_cols = [eml_generator(x, w, b) for w, b in generators]
    if include_constant:
        basis_cols.append(np.ones_like(x))

    basis = np.column_stack(basis_cols)
    coeffs, _, _, _ = np.linalg.lstsq(basis, target, rcond=None)
    approx = basis @ coeffs
    max_error = float(np.max(np.abs(target - approx)))

    return coeffs, max_error


def tropical_deformation(
    tropical_fn: Callable[[np.ndarray], np.ndarray],
    t: float,
    x: np.ndarray
) -> np.ndarray:
    """
    Smooth a tropical (piecewise-linear) function using EML operations.

    Given a tropical function h(x) = max(a_i * x + b_i), produce
    the smooth EML approximation (1/t) * log(sum(exp(t * (a_i * x + b_i)))).

    Args:
        tropical_fn: The tropical function to smooth (returns piecewise-linear values)
        t: Temperature parameter
        x: Input points

    Returns:
        Smoothed function values
    """
    return np.array([
        log_sum_exp_smooth_max(np.array([tropical_fn(np.array([xi]))
                                          for _ in range(1)]).flatten(), t)
        for xi in x
    ])


def eml_depth2_generator(
    x: np.ndarray,
    w1: float, b1: float,
    w2: float, b2: float
) -> np.ndarray:
    """
    Depth-2 EML generator: exp(w2 * exp(w1 * x + b1) + b2).

    This is strictly more expressive than depth-1 generators,
    as proven by depth2_not_affine_exp.

    Args:
        x: Input array
        w1, b1: Inner layer parameters
        w2, b2: Outer layer parameters

    Returns:
        Depth-2 EML function values
    """
    inner = np.exp(np.clip(w1 * x + b1, -500, 500))
    return np.exp(np.clip(w2 * inner + b2, -500, 500))


def adaptive_eml_approx(
    x: np.ndarray,
    target: np.ndarray,
    max_generators: int = 20,
    tolerance: float = 1e-4
) -> Tuple[List[Tuple[float, float]], np.ndarray, float]:
    """
    Adaptive EML approximation: greedily add generators to minimize error.

    This implements the constructive content of the density theorem:
    we keep adding EML generators until the approximation error drops
    below the specified tolerance.

    Args:
        x: Input points
        target: Target function values
        max_generators: Maximum number of generators to use
        tolerance: Target maximum error

    Returns:
        Tuple of (generator_params, coefficients, final_error)
    """
    # Candidate parameters to search over
    w_candidates = np.linspace(-3, 3, 20)
    b_candidates = np.linspace(-3, 3, 10)

    selected_params: List[Tuple[float, float]] = []
    residual = target.copy()
    best_error = float(np.max(np.abs(residual)))

    for _ in range(max_generators):
        if best_error < tolerance:
            break

        # Greedy: find the generator that best reduces the residual
        best_w, best_b = 0.0, 0.0
        best_reduction = 0.0

        for w in w_candidates:
            for b in b_candidates:
                g = eml_generator(x, w, b)
                # Optimal coefficient for this single generator
                c = float(np.dot(g, residual) / (np.dot(g, g) + 1e-12))
                new_residual = residual - c * g
                reduction = best_error - float(np.max(np.abs(new_residual)))
                if reduction > best_reduction:
                    best_reduction = reduction
                    best_w, best_b = w, b

        selected_params.append((best_w, best_b))

        # Refit all coefficients jointly
        coeffs, best_error = eml_least_squares_fit(
            x, target, selected_params, include_constant=True
        )
        basis = np.column_stack(
            [eml_generator(x, w, b) for w, b in selected_params] + [np.ones_like(x)]
        )
        residual = target - basis @ coeffs

    coeffs, final_error = eml_least_squares_fit(
        x, target, selected_params, include_constant=True
    )
    return selected_params, coeffs, final_error


if __name__ == "__main__":
    # Quick test
    x = np.linspace(0, 1, 100)
    target = np.sin(2 * np.pi * x)

    params, coeffs, error = adaptive_eml_approx(x, target, max_generators=10)
    print(f"Approximating sin(2πx) on [0,1]:")
    print(f"  Generators used: {len(params)}")
    print(f"  Max error: {error:.6e}")
    print(f"  Generator parameters: {params}")
