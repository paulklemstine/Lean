#!/usr/bin/env python3
"""
Algorithms for M-Convexity Inheritance and Exchange Cascade Computation

Implements the core algorithms from the research:
1. Exchange cascade computation (iterated weighted derivative)
2. Exchange property verification
3. Tropical exchange slack computation
4. Greedy optimization on exchange sequences
5. Newton polygon analysis
"""

import numpy as np
from typing import Optional


def weighted_derivative(a: list[float]) -> list[float]:
    """Compute the weighted derivative of a sequence.
    
    (Da)[k] = (k+1) * a[k+1]
    
    This corresponds to differentiating the generating polynomial
    p(x) = sum_k a[k] x^k and reading off coefficients of p'(x).
    
    Time complexity: O(n) where n = len(a)
    Space complexity: O(n)
    
    Args:
        a: A positive sequence of length n ≥ 2.
    
    Returns:
        The weighted derivative, a sequence of length n-1.
    
    Example:
        >>> weighted_derivative([1, 2, 3, 4])
        [2, 6, 12]
    """
    return [(k + 1) * a[k + 1] for k in range(len(a) - 1)]


def exchange_cascade(a: list[float], depth: int) -> list[list[float]]:
    """Compute the exchange cascade of a sequence up to given depth.
    
    Returns the tower [a, Da, D²a, ..., D^depth(a)] where D is
    the weighted derivative operator.
    
    Time complexity: O(depth * n) where n = len(a)
    Space complexity: O(depth * n)
    
    Args:
        a: Base sequence (positive, with exchange property).
        depth: Number of derivatives to compute.
    
    Returns:
        List of sequences, cascade[k] = D^k(a).
    
    Example:
        >>> cascade = exchange_cascade([1, 3, 3, 1], 2)
        >>> cascade[0]  # original
        [1, 3, 3, 1]
        >>> cascade[1]  # first derivative
        [3, 6, 3]
        >>> cascade[2]  # second derivative
        [6, 6]
    """
    result = [a]
    current = a
    for _ in range(depth):
        if len(current) < 2:
            break
        current = weighted_derivative(current)
        result.append(current)
    return result


def verify_exchange_property(a: list[float], tol: float = 1e-10) -> tuple[bool, Optional[tuple[int, int]]]:
    """Verify whether a sequence satisfies the exchange property.
    
    Checks: a[i]*a[j+1] <= a[i+1]*a[j] for all i <= j.
    
    Time complexity: O(n²) where n = len(a)
    
    Args:
        a: Sequence to check.
        tol: Numerical tolerance for floating-point comparison.
    
    Returns:
        (True, None) if exchange property holds.
        (False, (i, j)) if violated at indices (i, j).
    
    Example:
        >>> verify_exchange_property([1, 3, 3, 1])
        (True, None)
    """
    n = len(a)
    for i in range(n - 1):
        for j in range(i, n - 1):
            if a[i] * a[j + 1] > a[i + 1] * a[j] + tol:
                return False, (i, j)
    return True, None


def tropical_exchange_slack(a: list[float]) -> np.ndarray:
    """Compute the full matrix of tropical exchange slacks.
    
    slack(i,j) = log(a[i+1]*a[j]) - log(a[i]*a[j+1])
    
    The exchange property holds iff all slacks for i <= j are nonneg.
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    
    Args:
        a: Positive sequence.
    
    Returns:
        2D numpy array of exchange slacks.
    """
    n = len(a) - 1
    log_a = np.log(np.array(a))
    slack = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            slack[i, j] = (log_a[i + 1] + log_a[j]) - (log_a[i] + log_a[j + 1])
    return slack


def greedy_optimize(a: list[float], d: int) -> int:
    """Find the peak of a unimodal exchange sequence by greedy ascent.
    
    For sequences with the exchange property, the greedy algorithm
    is guaranteed to find the global maximum on [0, d].
    
    Time complexity: O(d) — linear in the search range!
    
    This is the algorithmic payoff of M-convexity: polynomial-time
    optimization without exhaustive search.
    
    Args:
        a: Positive sequence with exchange property.
        d: Search range upper bound.
    
    Returns:
        Index of the maximum on [0, d].
    
    Example:
        >>> from math import comb
        >>> a = [comb(10, k) for k in range(11)]
        >>> greedy_optimize(a, 10)
        5
    """
    k = 0
    while k < d and a[k + 1] > a[k]:
        k += 1
    return k


def newton_polygon(a: list[float]) -> list[float]:
    """Compute the Newton polygon slopes of a positive sequence.
    
    For an exchange sequence, these slopes are guaranteed to be
    nonincreasing (concave Newton polygon), which is the tropical
    analog of the Lorentzian property.
    
    Time complexity: O(n)
    
    Args:
        a: Positive sequence.
    
    Returns:
        List of slopes [log(a[1]/a[0]), log(a[2]/a[1]), ...].
    """
    return [np.log(a[k + 1] / a[k]) for k in range(len(a) - 1)]


def cascade_newton_analysis(a: list[float], depth: int) -> dict:
    """Analyze Newton polygon concavity across all cascade levels.
    
    Returns a dictionary with analysis results for each level.
    
    Args:
        a: Base sequence.
        depth: Cascade depth.
    
    Returns:
        Dictionary with keys 'levels', each containing slopes and
        concavity status.
    """
    cascade = exchange_cascade(a, depth)
    results = {}
    for level, seq in enumerate(cascade):
        if len(seq) < 2:
            break
        slopes = newton_polygon(seq)
        is_concave = all(
            slopes[i] >= slopes[i + 1] - 1e-10
            for i in range(len(slopes) - 1)
        )
        results[level] = {
            'sequence_length': len(seq),
            'slopes': slopes,
            'is_concave': is_concave,
            'peak_index': greedy_optimize(seq, len(seq) - 1),
        }
    return results


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    from math import comb
    
    print("Exchange Cascade Algorithm Demo")
    print("=" * 50)
    
    # Binomial coefficients
    n = 10
    a = [float(comb(n, k)) for k in range(n + 1)]
    print(f"\nBase: C({n}, k) = {a}")
    
    # Compute cascade
    cascade = exchange_cascade(a, 4)
    for level, seq in enumerate(cascade):
        ok, viol = verify_exchange_property(seq)
        print(f"\nLevel {level}: {[round(x, 1) for x in seq]}")
        print(f"  Exchange: {'✓' if ok else f'✗ at {viol}'}")
        print(f"  Peak at: {greedy_optimize(seq, len(seq) - 1)}")
    
    # Newton polygon analysis
    print("\nNewton Polygon Analysis:")
    analysis = cascade_newton_analysis(a, 3)
    for level, info in analysis.items():
        slopes_str = [f"{s:.3f}" for s in info['slopes']]
        print(f"  Level {level}: concave={info['is_concave']}, slopes={slopes_str}")
    
    # Exchange slack matrix
    print("\nExchange Slack Matrix (base level):")
    slack = tropical_exchange_slack(a[:6])
    print(np.round(slack, 3))
    print(f"  All upper-triangular entries ≥ 0: {np.all(slack[np.triu_indices(5)] >= -1e-10)}")
