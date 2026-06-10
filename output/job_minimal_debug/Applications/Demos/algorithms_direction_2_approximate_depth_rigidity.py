#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Approximate Tower Rigidity

Implements the mathematical algorithms from the research paper:
1. Iterated exponential computation with overflow protection
2. Derivative cascade computation
3. Certified depth bound calculator
4. Tower gap estimator
5. Relative approximation checker

All functions include docstrings, type hints, and example usage.
"""

import math
from typing import Optional, Tuple, List


def iter_exp(n: int, x: float) -> float:
    """Compute the iterated exponential iterExp(n, x).
    
    iterExp(0, x) = x
    iterExp(n+1, x) = exp(iterExp(n, x))
    
    Args:
        n: Number of exponential applications (non-negative integer).
        x: Input value.
    
    Returns:
        iterExp(n, x), or float('inf') on overflow.
    
    Examples:
        >>> iter_exp(0, 2.0)
        2.0
        >>> iter_exp(1, 1.0)  # e^1 ≈ 2.718
        2.718281828459045
        >>> iter_exp(2, 1.0)  # e^(e^1) ≈ 15.15
        15.15426224147926
        >>> iter_exp(3, 1.0)  # e^(e^(e^1)) ≈ 3814279
        3814279.1047601813
    """
    if n < 0:
        raise ValueError(f"n must be non-negative, got {n}")
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
            if result > 1e308:
                return float('inf')
        except OverflowError:
            return float('inf')
    return result


def deriv_iter_exp(n: int, x: float) -> float:
    """Compute the derivative of iterExp(n) at x using the cascade product.
    
    deriv(iterExp(n))(x) = ∏_{k=1}^{n} iterExp(k, x)
    
    This implements the formally verified derivative cascade identity.
    
    Args:
        n: Tower level (non-negative integer).
        x: Point at which to evaluate the derivative.
    
    Returns:
        The derivative value, or float('inf') on overflow.
    
    Examples:
        >>> deriv_iter_exp(0, 1.0)  # deriv(id) = 1
        1.0
        >>> deriv_iter_exp(1, 1.0)  # deriv(exp)(1) = e
        2.718281828459045
        >>> deriv_iter_exp(2, 1.0)  # exp(1) * exp(exp(1)) ≈ 41.19
        41.19361258213178
    """
    if n == 0:
        return 1.0
    product = 1.0
    for k in range(1, n + 1):
        val = iter_exp(k, x)
        if val == float('inf') or product > 1e308:
            return float('inf')
        product *= val
    return product


def approx_depth_bound(n: int, eps: float) -> int:
    """Compute the certified depth lower bound for ε-relative approximation.
    
    Returns n - ⌈log₂(log₂(1/ε))⌉ - 3, floored at 0.
    
    This is the main result: any inverse-free DAG that ε-relatively-
    approximates iterExp(n) on [1, 10] must have depth ≥ this value.
    
    Args:
        n: Tower level.
        eps: Relative approximation error (0 < eps < 1/2).
    
    Returns:
        Certified depth lower bound (non-negative integer).
    
    Examples:
        >>> approx_depth_bound(10, 1e-3)
        3
        >>> approx_depth_bound(10, 1e-6)
        2
        >>> approx_depth_bound(10, 1e-100)
        0
        >>> approx_depth_bound(20, 1e-6)
        12
    """
    if eps <= 0:
        return n
    if eps >= 0.5:
        return 0
    try:
        log_inv_eps = math.log2(1.0 / eps)
        if log_inv_eps <= 1:
            return max(0, n - 3)
        loglog = math.ceil(math.log2(log_inv_eps))
    except (ValueError, OverflowError):
        return 0
    return max(0, n - loglog - 3)


def tower_gap(n: int, d: int) -> float:
    """Compute the tower gap between levels n and D.
    
    TowerGap(n, D) = iterExp(n, 1) / (iterExp(D, 10) + 1)
    
    This ratio quantifies the inherent separation between tower levels.
    When n > D, it is super-exponentially large.
    
    Args:
        n: Upper tower level.
        d: Lower tower level.
    
    Returns:
        The tower gap ratio, or float('inf') if it overflows.
    
    Examples:
        >>> tower_gap(1, 0)  # e / 11 ≈ 0.247
        0.24711653131...
        >>> tower_gap(2, 1)  # e^e / (e^10 + 1) ≈ 0.000688
        0.000688...
    """
    numerator = iter_exp(n, 1.0)
    denominator = iter_exp(d, 10.0)
    
    if numerator == float('inf'):
        if denominator == float('inf'):
            return float('nan')  # indeterminate
        return float('inf')
    
    if denominator == float('inf'):
        return 0.0
    
    return numerator / (denominator + 1)


def check_relative_approximation(
    f_values: List[float],
    g_values: List[float],
    x_values: List[float],
    eps: float,
    a: float,
    b: float
) -> Tuple[bool, float]:
    """Check if g ε-relatively-approximates f on [a, b].
    
    Verifies: ∀ x ∈ [a, b], |f(x) - g(x)| < ε * |f(a)|
    
    Args:
        f_values: Values of f at sample points.
        g_values: Values of g at the same sample points.
        x_values: The sample points (must be in [a, b]).
        eps: Target relative error.
        a: Left endpoint.
        b: Right endpoint.
    
    Returns:
        Tuple of (is_approximation, max_relative_error).
    
    Examples:
        >>> xs = [1.0, 2.0, 3.0]
        >>> fs = [2.718, 7.389, 20.086]  # approx exp
        >>> gs = [2.72, 7.39, 20.1]
        >>> check_relative_approximation(fs, gs, xs, 0.01, 1.0, 3.0)
        (True, ...)
    """
    if len(f_values) != len(g_values) or len(f_values) != len(x_values):
        raise ValueError("All input lists must have the same length")
    
    f_a = abs(f_values[0])  # |f(a)|
    if f_a == 0:
        return False, float('inf')
    
    max_rel_error = 0.0
    for fx, gx, x in zip(f_values, g_values, x_values):
        if a <= x <= b:
            error = abs(fx - gx) / f_a
            max_rel_error = max(max_rel_error, error)
    
    return max_rel_error < eps, max_rel_error


def depth_savings_table(n_values: List[int], eps_values: List[float]) -> str:
    """Generate a formatted table of depth savings for given n and epsilon values.
    
    Args:
        n_values: List of tower levels.
        eps_values: List of approximation errors.
    
    Returns:
        Formatted string table.
    
    Examples:
        >>> print(depth_savings_table([5, 10, 20], [1e-3, 1e-6, 1e-12]))
        ...
    """
    header = f"{'n':>4} | "
    header += " | ".join(f"eps={e:.0e}" for e in eps_values)
    separator = "-" * len(header)
    
    lines = [header, separator]
    for n in n_values:
        row = f"{n:>4} | "
        row += " | ".join(
            f"{approx_depth_bound(n, e):>{len(f'eps={e:.0e}')}}"
            for e in eps_values
        )
        lines.append(row)
    
    return "\n".join(lines)


# Example usage
if __name__ == '__main__':
    print("="*50)
    print("ALGORITHMS — Example Usage")
    print("="*50)
    
    print("\n--- Iterated Exponential Values ---")
    for n in range(6):
        val = iter_exp(n, 1.0)
        if val < 1e20:
            print(f"  iterExp({n}, 1) = {val:.6f}")
        elif val < float('inf'):
            print(f"  iterExp({n}, 1) = {val:.2e}")
        else:
            print(f"  iterExp({n}, 1) = OVERFLOW")
    
    print("\n--- Derivative Cascade Values ---")
    for n in range(5):
        val = deriv_iter_exp(n, 1.0)
        if val < 1e20:
            print(f"  deriv(iterExp({n}))(1) = {val:.6f}")
        else:
            print(f"  deriv(iterExp({n}))(1) = {val:.2e}")
    
    print("\n--- Depth Bound Table ---")
    print(depth_savings_table(
        [5, 8, 10, 15, 20, 50, 100],
        [1e-3, 1e-6, 1e-12, 1e-100]
    ))
    
    print("\n--- Tower Gap ---")
    for n in range(1, 5):
        for d in range(n):
            gap = tower_gap(n, d)
            if gap < 1e20:
                print(f"  TowerGap({n}, {d}) = {gap:.6f}")
            elif gap == float('inf'):
                print(f"  TowerGap({n}, {d}) = INFINITY")
            else:
                print(f"  TowerGap({n}, {d}) = {gap:.2e}")
