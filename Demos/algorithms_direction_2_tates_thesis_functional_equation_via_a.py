#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for computing local/global zeta integrals
and Euler products, tied to the formal theorems in TateThesis/Theorems.lean.

Algorithms:
1. Euler factor computation via geometric series
2. Truncated Euler product with error bounds
3. Completed zeta function approximation
4. Prime sieve for Euler product computation
"""

from math import gamma, pi, log, exp, floor, sqrt
from typing import List, Tuple, Optional


def sieve_of_eratosthenes(bound: int) -> List[int]:
    """Compute all primes up to `bound` using the Sieve of Eratosthenes.
    
    Time complexity: O(n log log n)
    Space complexity: O(n)
    
    Args:
        bound: Upper bound for prime search
    
    Returns:
        Sorted list of all primes p ≤ bound
    
    Example:
        >>> sieve_of_eratosthenes(20)
        [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(sqrt(bound)) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i in range(2, bound + 1) if sieve[i]]


def euler_factor(p: int, s: float) -> float:
    """Compute the local Euler factor (1 - p^{-s})^{-1}.
    
    This corresponds to the formally verified theorem:
        local_zeta_eq_eulerFactor: localZetaIntegral p s = eulerFactor p s
    
    The local zeta integral ∑_{n≥0} p^{-ns} converges to (1-p^{-s})^{-1}
    for s > 0 by the geometric series formula.
    
    Time complexity: O(1)
    
    Args:
        p: Prime number (p ≥ 2)
        s: Real parameter (s > 0 for convergence)
    
    Returns:
        (1 - p^{-s})^{-1}
    
    Raises:
        ValueError: If p < 2 or s ≤ 0
    
    Example:
        >>> euler_factor(2, 2.0)
        1.3333333333333333
    """
    if p < 2:
        raise ValueError(f"p must be ≥ 2, got {p}")
    if s <= 0:
        raise ValueError(f"s must be > 0, got {s}")
    return 1.0 / (1.0 - p ** (-s))


def local_zeta_partial_sum(p: int, s: float, num_terms: int = 100) -> Tuple[float, float]:
    """Compute local zeta integral via partial sum with error bound.
    
    Computes ∑_{n=0}^{N-1} p^{-ns} and provides an upper bound on the
    truncation error |∑_{n≥N} p^{-ns}|.
    
    Corresponds to: local_zeta_shell_decomposition
    
    Time complexity: O(num_terms)
    
    Args:
        p: Prime number
        s: Real parameter (s > 0)
        num_terms: Number of terms N in partial sum
    
    Returns:
        Tuple of (partial_sum, error_bound)
    
    Example:
        >>> local_zeta_partial_sum(2, 2.0, 50)
        (1.3333333333333333, 0.0)
    """
    r = p ** (-s)  # Common ratio
    partial = sum(r ** n for n in range(num_terms))
    # Error bound: |∑_{n≥N} r^n| = r^N / (1-r) for |r| < 1
    error = r ** num_terms / (1.0 - r) if r < 1 else float('inf')
    return partial, error


def truncated_euler_product(primes: List[int], s: float) -> float:
    """Compute truncated Euler product ∏_{p ∈ S} (1-p^{-s})^{-1}.
    
    Corresponds to: euler_product_factorization and truncated_euler_monotone
    
    The formally verified theorem euler_product_factorization shows this
    equals the truncated adelic zeta integral for the standard test function.
    
    Time complexity: O(|primes|)
    
    Args:
        primes: List of primes
        s: Real parameter (s > 0)
    
    Returns:
        The finite Euler product
    
    Example:
        >>> truncated_euler_product([2, 3, 5, 7], 2.0)
        1.5950520833333333
    """
    result = 1.0
    for p in primes:
        result *= euler_factor(p, s)
    return result


def truncated_euler_product_with_bound(
    bound: int, s: float
) -> Tuple[float, float, float]:
    """Compute truncated Euler product with convergence analysis.
    
    Returns the product, the Dirichlet series tail bound, and the
    relative error estimate.
    
    Time complexity: O(bound / ln(bound))  [dominated by sieve]
    
    Args:
        bound: Include all primes ≤ bound
        s: Real parameter (s > 1 for absolute convergence)
    
    Returns:
        Tuple of (product, tail_bound, relative_error_estimate)
    """
    primes = sieve_of_eratosthenes(bound)
    product = truncated_euler_product(primes, s)
    
    # Tail bound: ∏_{p>B} (1-p^{-s})^{-1} ≈ 1 + ∑_{p>B} p^{-s} + ...
    # Simple bound: the missing factor is ≈ 1 + 1/(B^{s-1} * (s-1))
    if s > 1 and bound > 0:
        tail_bound = 1.0 / (bound ** (s - 1) * (s - 1))
        rel_error = tail_bound / product if product > 0 else float('inf')
    else:
        tail_bound = float('inf')
        rel_error = float('inf')
    
    return product, tail_bound, rel_error


def completed_zeta_real(s: float, zeta_terms: int = 50000) -> float:
    """Compute ξ(s) = π^{-s/2} Γ(s/2) ζ(s) for real s > 1.
    
    Corresponds to: completed_zeta_functional_equation_real
    
    The formally verified theorem states ξ(1-s) = ξ(s) for all s.
    
    Time complexity: O(zeta_terms)
    
    Args:
        s: Real parameter (s > 1)
        zeta_terms: Number of terms for ζ(s) approximation
    
    Returns:
        ξ(s)
    """
    if s <= 1:
        raise ValueError(f"s must be > 1 for direct computation, got {s}")
    
    zeta_val = sum(n ** (-s) for n in range(1, zeta_terms + 1))
    gamma_val = gamma(s / 2)
    pi_factor = pi ** (-s / 2)
    return pi_factor * gamma_val * zeta_val


def archimedean_gamma_factor(s: float) -> float:
    """Compute the archimedean gamma factor π^{-s/2} Γ(s/2).
    
    This is the archimedean contribution to the completed zeta function.
    In Tate's thesis, it arises as the Mellin transform of the Gaussian
    e^{-πx²} against |x|^s.
    
    Args:
        s: Real parameter (s > 0)
    
    Returns:
        π^{-s/2} Γ(s/2)
    """
    return pi ** (-s / 2) * gamma(s / 2)


if __name__ == "__main__":
    print("=== Algorithms Demo ===")
    print()
    
    # Euler factors
    print("Euler factors at s=2:")
    for p in [2, 3, 5, 7, 11, 13]:
        ef = euler_factor(p, 2.0)
        ps, err = local_zeta_partial_sum(p, 2.0, 50)
        print(f"  p={p:2d}: factor = {ef:.10f}, "
              f"partial sum error = {err:.2e}")
    
    print()
    print("Truncated Euler product convergence (s=2, ζ(2)=π²/6):")
    target = pi ** 2 / 6
    for bound in [10, 100, 1000, 10000]:
        prod, tail, rel = truncated_euler_product_with_bound(bound, 2.0)
        actual_err = abs(prod - target) / target
        print(f"  B={bound:6d}: product={prod:.10f}, "
              f"est_rel_err={rel:.2e}, actual_rel_err={actual_err:.2e}")
    
    print()
    print("Completed zeta values:")
    for s in [2.0, 3.0, 4.0, 5.0, 10.0]:
        xi = completed_zeta_real(s)
        print(f"  ξ({s:.0f}) = {xi:.10f}")
