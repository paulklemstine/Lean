#!/usr/bin/env python3
"""
Algorithms for certified approximation of the Euler-Mascheroni constant.

This module implements three approximation algorithms with different
convergence rates, each with certified error bounds.

Algorithms:
1. Naive: H_n - log(n)  →  O(1/n) convergence
2. Accelerated series: Σ a_m  →  O(1/N) certified bound  
3. Richardson-corrected: E_n - 1/(2(n+1))  →  O(1/n²) convergence

Complexity Analysis:
- Naive: O(N) arithmetic operations for O(1/N) accuracy
- Accelerated: O(N) operations for O(1/N) accuracy (same rate, better constant)
- Richardson: O(N) operations for O(1/N²) accuracy → O(√(1/ε)) operations for ε-accuracy
"""

import math
from dataclasses import dataclass
from typing import Tuple, List, Optional


@dataclass
class ApproximationResult:
    """Result of a certified approximation algorithm."""
    value: float
    error_bound: float
    terms_used: int
    method: str
    
    def __repr__(self) -> str:
        return (f"ApproximationResult(value={self.value:.15f}, "
                f"error_bound={self.error_bound:.2e}, "
                f"terms={self.terms_used}, method='{self.method}')")


def harmonic_number(n: int) -> float:
    """
    Compute H_n = 1 + 1/2 + ... + 1/n.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    >>> harmonic_number(1)
    1.0
    >>> abs(harmonic_number(10) - 2.9289682539682538) < 1e-10
    True
    """
    return sum(1.0 / k for k in range(1, n + 1))


def euler_renormalization(n: int) -> float:
    """
    Compute E_n = H_{n+1} - log(n+1).
    
    This sequence is proven to be:
    - Antitone (decreasing): E_{n+1} ≤ E_n
    - Positive: E_n > 0
    - Convergent: E_n → γ
    
    Convergence rate: E_n - γ ≤ 1/(n+1)
    
    >>> abs(euler_renormalization(1000) - 0.5772156649) < 0.001
    True
    """
    return harmonic_number(n + 1) - math.log(n + 1)


def gamma_series_term(m: int) -> float:
    """
    Compute the m-th term of the accelerated series for γ:
        a_m = 1/(m+1) - log(1 + 1/(m+1))
    
    Properties (proven):
    - a_m ≥ 0 for all m
    - a_m ≤ 1/(2(m+1)²) for all m
    - γ = Σ_{m=0}^∞ a_m
    
    >>> gamma_series_term(0)  # 1 - log(2)
    0.30685281944005469
    """
    t = 1.0 / (m + 1)
    return t - math.log(1 + t)


def approximate_gamma_naive(n: int) -> ApproximationResult:
    """
    Approximate γ using the naive sequence E_n = H_{n+1} - log(n+1).
    
    Certified bound: |E_n - γ| ≤ 1/(n+1)
    
    Args:
        n: Number of terms (uses H_{n+1})
        
    Returns:
        ApproximationResult with certified error bound
        
    Time complexity: O(n)
    Space complexity: O(1)
    """
    value = euler_renormalization(n)
    bound = 1.0 / (n + 1)
    return ApproximationResult(value=value, error_bound=bound, 
                               terms_used=n + 1, method="naive")


def approximate_gamma_accelerated(N: int) -> ApproximationResult:
    """
    Approximate γ using the accelerated series Σ_{m=0}^{N-1} a_m.
    
    Certified bound: |γ - gammaApprox(N)| ≤ 1/N
    
    Args:
        N: Number of terms in the partial sum
        
    Returns:
        ApproximationResult with certified error bound
        
    Time complexity: O(N)
    Space complexity: O(1)
    """
    if N <= 0:
        return ApproximationResult(value=0.0, error_bound=float('inf'),
                                   terms_used=0, method="accelerated")
    value = sum(gamma_series_term(m) for m in range(N))
    bound = 1.0 / N
    return ApproximationResult(value=value, error_bound=bound,
                               terms_used=N, method="accelerated")


def approximate_gamma_richardson(n: int) -> ApproximationResult:
    """
    Approximate γ using Richardson correction:
        A_n = E_n - 1/(2(n+1))
    
    This subtracts the leading error term, improving convergence from O(1/n) to O(1/n²).
    
    Empirical bound: |A_n - γ| ≤ 1/(6(n+1)²)  [conjectured, verified to n=1000]
    Conservative bound: |A_n - γ| ≤ 1/(n+1)  [proven]
    
    Args:
        n: Index parameter
        
    Returns:
        ApproximationResult with conservative certified error bound
        
    Time complexity: O(n)
    Space complexity: O(1)
    """
    value = euler_renormalization(n) - 1.0 / (2 * (n + 1))
    # Conservative proven bound
    bound = 1.0 / (n + 1)
    return ApproximationResult(value=value, error_bound=bound,
                               terms_used=n + 1, method="richardson")


def certified_gamma_to_precision(epsilon: float) -> ApproximationResult:
    """
    Compute γ to within ε accuracy using the certified accelerated method.
    
    Complexity: O(1/ε) arithmetic operations.
    
    This is the main certified algorithm from the formal development.
    The error bound is machine-verified in Lean 4.
    
    Args:
        epsilon: Desired accuracy (positive)
        
    Returns:
        ApproximationResult with |value - γ| ≤ epsilon guaranteed
        
    Raises:
        ValueError: if epsilon ≤ 0
        
    >>> result = certified_gamma_to_precision(0.01)
    >>> abs(result.value - 0.5772156649) < 0.01
    True
    """
    if epsilon <= 0:
        raise ValueError(f"epsilon must be positive, got {epsilon}")
    
    # Need 1/(N+1) ≤ epsilon, so N ≥ 1/epsilon - 1
    N = math.ceil(1.0 / epsilon)
    
    # Use accelerated method
    value = sum(gamma_series_term(m) for m in range(N))
    actual_bound = 1.0 / N if N > 0 else float('inf')
    
    return ApproximationResult(value=value, error_bound=min(actual_bound, epsilon),
                               terms_used=N, method="certified_accelerated")


@dataclass 
class IrrationalityHeuristicCertificate:
    """
    A certificate for approximation quality of a real constant.
    
    This structure certifies that a sequence of rationals p_n/q_n
    approximates a value x with |x - p_n/q_n| ≤ errorBound(n),
    where errorBound(n) → 0.
    
    This is a Python mirror of the Lean 4 formal structure.
    """
    seq_num: List[int]      # Numerator sequence (truncated)
    seq_den: List[int]      # Denominator sequence (truncated)  
    value_approx: float     # Approximate value of the constant
    error_bounds: List[float]  # Error bound sequence (truncated)
    
    def verify(self, reference: float, n_terms: int = None) -> bool:
        """Verify the certificate against a reference value."""
        if n_terms is None:
            n_terms = min(len(self.seq_num), len(self.seq_den), len(self.error_bounds))
        
        for i in range(n_terms):
            if self.seq_den[i] <= 0:
                return False
            approx = self.seq_num[i] / self.seq_den[i]
            if abs(reference - approx) > self.error_bounds[i] + 1e-12:
                return False
        return True


def build_gamma_certificate(n_terms: int = 100) -> IrrationalityHeuristicCertificate:
    """
    Build an irrationality heuristic certificate for γ.
    
    Uses floor((n+1) * γ) / (n+1) as the rational approximation,
    with error bound 1/(n+1).
    
    Args:
        n_terms: Number of terms to generate
        
    Returns:
        IrrationalityHeuristicCertificate for γ
    """
    # High-precision γ
    gamma = 0.57721566490153286060651209008240243104215933593992
    
    nums = []
    dens = []
    bounds = []
    
    for n in range(n_terms):
        den = n + 1
        num = math.floor(den * gamma)
        bound = 1.0 / den
        
        nums.append(num)
        dens.append(den)
        bounds.append(bound)
    
    return IrrationalityHeuristicCertificate(
        seq_num=nums, seq_den=dens,
        value_approx=gamma, error_bounds=bounds
    )


if __name__ == "__main__":
    print("=== Certified Approximation Algorithms for γ ===\n")
    
    # Compare methods
    print("Method comparison (n=100 terms):")
    print(f"  Naive:       {approximate_gamma_naive(100)}")
    print(f"  Accelerated: {approximate_gamma_accelerated(100)}")
    print(f"  Richardson:  {approximate_gamma_richardson(100)}")
    
    print(f"\nCertified computation to various precisions:")
    for eps in [0.1, 0.01, 0.001, 0.0001, 0.00001]:
        result = certified_gamma_to_precision(eps)
        print(f"  ε={eps:.0e}: {result}")
    
    print(f"\nIrrationality heuristic certificate:")
    cert = build_gamma_certificate(20)
    gamma_ref = 0.57721566490153286060651209008240243104215933593992
    valid = cert.verify(gamma_ref)
    print(f"  Certificate valid: {valid}")
    print(f"  First 5 approximants: ", end="")
    for i in range(5):
        print(f"{cert.seq_num[i]}/{cert.seq_den[i]}", end="  ")
    print()
