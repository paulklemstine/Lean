#!/usr/bin/env python3
"""
EML Fixed-Point Algorithms

Type-hinted implementations of the core algorithms from the EML fixed-point theory.
Each algorithm comes with certified convergence guarantees proven in Lean 4.
"""

import math
from typing import Tuple, List, Optional, Callable


def eml_operator(a: float, c: float) -> Callable[[float], float]:
    """
    Construct the EML operator T(x) = exp(a) * log(x + c).

    Args:
        a: Exponential scaling parameter
        c: Logarithmic shift parameter (must satisfy c > 0 for positivity)

    Returns:
        A callable implementing T(x).

    The operator is well-defined for x > -c.
    """
    exp_a = math.exp(a)
    def T(x: float) -> float:
        return exp_a * math.log(x + c)
    return T


def eml_contraction_constant(a: float, c: float, L: float) -> float:
    """
    Compute the contraction constant K = exp(a) / (L + c).

    This is the sharp Lipschitz constant of the EML operator on [L, ∞).
    The operator is a contraction iff K < 1, i.e., exp(a) < L + c.

    Args:
        a: Exponential scaling parameter
        c: Logarithmic shift
        L: Left endpoint of the domain

    Returns:
        The contraction constant K.
    """
    return math.exp(a) / (L + c)


def check_contraction(a: float, c: float, L: float = 0.0) -> Tuple[bool, float]:
    """
    Check whether the EML operator is a contraction on [L, ∞).

    Returns (is_contraction, K) where K is the contraction constant.

    Theorem (Lean 4 verified):
        If 0 < a < 1 and c ≥ 3, then K < 1 (eml_small_param_contraction).
        More generally, K < 1 iff exp(a) < L + c (eml_K_lt_one).
    """
    K = eml_contraction_constant(a, c, L)
    return K < 1, K


def fixed_point_iteration(
    a: float,
    c: float,
    x0: float,
    tol: float = 1e-12,
    max_iter: int = 10000
) -> Tuple[float, List[float], int]:
    """
    Compute the fixed point of T(x) = exp(a) * log(x + c) by iteration.

    Theorem (Lean 4 verified):
        If K = exp(a)/(L+c) < 1 and x0 ≥ L with L+c > 0, the iterates
        x_{n+1} = T(x_n) converge to the unique fixed point x* satisfying
        x* = exp(a) * log(x* + c), at geometric rate:
        |x_n - x*| ≤ K^n * |x_0 - x*|.
        (eml_iteration_geometric_bound, eml_fixed_point_unique)

    Args:
        a: Exponential scaling parameter
        c: Logarithmic shift
        x0: Starting point (must satisfy x0 + c > 0)
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        (fixed_point, history, iterations)
    """
    T = eml_operator(a, c)
    x = x0
    history = [x]

    for i in range(max_iter):
        x_new = T(x)
        history.append(x_new)
        if abs(x_new - x) < tol:
            return x_new, history, i + 1
        x = x_new

    return x, history, max_iter


def spectral_analysis(
    a: float,
    c: float,
    x_star: float
) -> dict:
    """
    Compute the spectral-dynamical quantities at a fixed point.

    Theorem (Lean 4 verified):
        At a fixed point x*, the derivative equals exp(a)/(x*+c),
        and the contraction rate satisfies the self-consistency relation:
        |T'(x*)| = x* / ((x*+c) * log(x*+c))
        (eml_spectral_contraction_bridge, eml_contraction_rate_at_fixedpoint)

    Args:
        a: Exponential scaling parameter
        c: Logarithmic shift
        x_star: The fixed point

    Returns:
        Dictionary with spectral quantities.
    """
    deriv = math.exp(a) / (x_star + c)
    log_val = math.log(x_star + c)
    rate_alt = x_star / ((x_star + c) * log_val) if log_val != 0 else float('inf')

    return {
        'derivative': deriv,
        'spectral_radius': abs(deriv),
        'is_stable': abs(deriv) < 1,
        'contraction_rate_alt': rate_alt,
        'self_consistency_error': abs(deriv - rate_alt),
        'asymptotic_convergence_factor': abs(deriv),
        'bits_per_iteration': -math.log2(abs(deriv)) if abs(deriv) > 0 else float('inf'),
    }


def parameter_space_scan(
    a_range: Tuple[float, float] = (0.01, 2.0),
    c_range: Tuple[float, float] = (0.5, 10.0),
    n_points: int = 50
) -> List[dict]:
    """
    Scan the (a, c) parameter space to classify EML dynamics.

    For each (a, c) pair, determines:
    - Whether the operator is a contraction (K < 1)
    - The fixed point (if it converges)
    - The spectral radius at the fixed point

    Returns:
        List of dictionaries with parameter space data.
    """
    results = []
    da = (a_range[1] - a_range[0]) / n_points
    dc = (c_range[1] - c_range[0]) / n_points

    for i in range(n_points + 1):
        for j in range(n_points + 1):
            a = a_range[0] + i * da
            c = c_range[0] + j * dc

            is_contraction, K = check_contraction(a, c)

            if is_contraction:
                try:
                    x_star, _, iters = fixed_point_iteration(a, c, 1.0, max_iter=500)
                    spec = spectral_analysis(a, c, x_star)
                    results.append({
                        'a': a, 'c': c, 'K': K,
                        'is_contraction': True,
                        'x_star': x_star,
                        'spectral_radius': spec['spectral_radius'],
                        'iterations': iters,
                    })
                except (ValueError, OverflowError):
                    results.append({
                        'a': a, 'c': c, 'K': K,
                        'is_contraction': True,
                        'x_star': None,
                        'spectral_radius': None,
                        'iterations': None,
                    })
            else:
                results.append({
                    'a': a, 'c': c, 'K': K,
                    'is_contraction': False,
                    'x_star': None,
                    'spectral_radius': None,
                    'iterations': None,
                })

    return results


if __name__ == "__main__":
    print("EML Fixed-Point Algorithms")
    print("=" * 50)

    # Example: find fixed point for a=0.5, c=3.0
    a, c = 0.5, 3.0
    is_contr, K = check_contraction(a, c)
    print(f"\nParameters: a={a}, c={c}")
    print(f"Contraction: {is_contr}, K={K:.6f}")

    x_star, history, iters = fixed_point_iteration(a, c, 1.0)
    print(f"Fixed point: x* = {x_star:.15f}")
    print(f"Iterations: {iters}")

    spec = spectral_analysis(a, c, x_star)
    print(f"\nSpectral analysis at fixed point:")
    for key, val in spec.items():
        print(f"  {key}: {val}")
