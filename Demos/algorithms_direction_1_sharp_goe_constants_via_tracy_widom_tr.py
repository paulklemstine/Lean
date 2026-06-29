#!/usr/bin/env python3
"""
algorithms.py — Certified failure probability algorithms for
Lorentzian signature stability under GOE perturbation.

Implements the sharp GOE constants framework:
- SharpFailureUpperBound computation
- Certified checker for failure probability
- Gap requirement solver
- Edge-scaled gap computation
"""

import numpy as np
from typing import Tuple, Optional
from dataclasses import dataclass


@dataclass
class EdgeScaledGap:
    """The dimensionless rescaled gap variable governing the phase transition.

    Attributes:
        n: Matrix dimension
        sigma: Noise standard deviation parameter
        eps: Lorentzian spectral gap
        value: The rescaled variable (ε − 2σ) · n^(2/3) / σ
    """
    n: int
    sigma: float
    eps: float

    @property
    def value(self) -> float:
        """Compute the edge-scaled gap variable."""
        return (self.eps - 2 * self.sigma) * self.n ** (2/3) / self.sigma

    @property
    def is_above_edge(self) -> bool:
        """Whether the gap exceeds the semicircle edge 2σ."""
        return self.eps > 2 * self.sigma

    def __repr__(self) -> str:
        return (f"EdgeScaledGap(n={self.n}, σ={self.sigma:.4f}, "
                f"ε={self.eps:.4f}, value={self.value:.4f})")


def sharp_failure_upper_bound(C: float, sigma: float, eps: float, n: float) -> float:
    """Compute SharpFailureUpperBound(C, σ, ε, n).

    Returns exp(−(max(ε − 2σ, 0))² · n / (C · σ²)).

    Args:
        C: Universal constant (> 0)
        sigma: Noise parameter (> 0)
        eps: Lorentzian spectral gap
        n: Dimension (≥ 0)

    Returns:
        The failure probability upper bound in [0, 1].

    Examples:
        >>> sharp_failure_upper_bound(1.0, 1.0, 1.5, 100)  # below edge
        1.0
        >>> sharp_failure_upper_bound(1.0, 1.0, 2.5, 100)  # above edge
        1.388...e-11
    """
    if C <= 0 or sigma <= 0:
        raise ValueError(f"Need C > 0 and σ > 0, got C={C}, σ={sigma}")
    gap = max(eps - 2 * sigma, 0)
    exponent = -gap ** 2 * n / (C * sigma ** 2)
    return np.exp(exponent)


def goe_edge_window(sigma: float, n: float, t: float) -> float:
    """Compute the GOE edge window: 2σ + t · σ / n^(2/3).

    Args:
        sigma: Noise parameter
        n: Dimension
        t: Rescaled variable

    Returns:
        The edge threshold value.
    """
    if n <= 0:
        raise ValueError(f"Need n > 0, got n={n}")
    return 2 * sigma + t * sigma / n ** (2/3)


def certify_failure_prob(
    C: float, sigma: float, eps: float, n: float, delta: float
) -> Tuple[bool, float]:
    """Certified checker: does the sharp bound certify P(failure) ≤ δ?

    Checks whether (max(ε−2σ, 0))² · n / (Cσ²) ≥ −ln(δ).

    Args:
        C: Universal constant (> 0)
        sigma: Noise parameter (> 0)
        eps: Lorentzian spectral gap
        n: Dimension
        delta: Target failure probability (0 < δ < 1)

    Returns:
        (certified, bound): Whether certification succeeds and the actual bound.

    Examples:
        >>> certify_failure_prob(1.0, 1.0, 3.0, 100, 1e-5)
        (True, 5.24e-44)
    """
    if delta <= 0 or delta >= 1:
        raise ValueError(f"Need 0 < δ < 1, got δ={delta}")
    bound = sharp_failure_upper_bound(C, sigma, eps, n)
    certified = bound <= delta
    return certified, bound


def required_gap_for_confidence(
    C: float, sigma: float, n: float, delta: float
) -> float:
    """Compute the minimum gap ε needed to certify P(failure) ≤ δ.

    Solves: (ε − 2σ)² · n / (Cσ²) ≥ −ln(δ)
    giving: ε ≥ 2σ + σ · √(C · ln(1/δ) / n)

    Args:
        C: Universal constant
        sigma: Noise parameter
        n: Dimension
        delta: Target failure probability

    Returns:
        Minimum spectral gap ε.
    """
    if delta <= 0 or delta >= 1:
        raise ValueError(f"Need 0 < δ < 1")
    neg_ln_delta = -np.log(delta)
    gap_needed = sigma * np.sqrt(C * neg_ln_delta / n)
    return 2 * sigma + gap_needed


def bits_of_precision_needed(
    C: float, sigma: float, eps: float, n: float, delta: float
) -> float:
    """Compute bits of precision (−log₂(δ)) achievable with given parameters.

    Args:
        C, sigma, eps, n: Problem parameters
        delta: Not used directly; returns achievable bits.

    Returns:
        Number of bits of confidence: −log₂(SharpFailureUpperBound).
    """
    bound = sharp_failure_upper_bound(C, sigma, eps, n)
    if bound <= 0:
        return float('inf')
    return -np.log2(bound)


# ---- Demonstration ----

if __name__ == "__main__":
    print("=== Sharp GOE Constants: Algorithm Demonstrations ===\n")

    # Example 1: Basic bound computation
    print("1. SharpFailureUpperBound for various parameters:")
    for n in [10, 50, 100, 500]:
        for eps_ratio in [1.5, 2.0, 2.5, 3.0]:
            sigma = 1.0
            eps = eps_ratio * sigma
            bound = sharp_failure_upper_bound(1.0, sigma, eps, n)
            print(f"   n={n:4d}, ε/σ={eps_ratio:.1f}: bound = {bound:.6e}")
    print()

    # Example 2: Certification
    print("2. Certification examples (target δ = 10⁻⁶):")
    delta = 1e-6
    for n in [10, 50, 200]:
        eps_needed = required_gap_for_confidence(1.0, 1.0, n, delta)
        certified, bound = certify_failure_prob(1.0, 1.0, eps_needed, n, delta)
        print(f"   n={n:4d}: need ε ≥ {eps_needed:.4f}, "
              f"certified={certified}, bound={bound:.6e}")
    print()

    # Example 3: Edge-scaled gap
    print("3. Edge-scaled gap values:")
    for n in [10, 50, 200]:
        for eps in [1.8, 2.0, 2.2, 2.5, 3.0]:
            esg = EdgeScaledGap(n=n, sigma=1.0, eps=eps)
            print(f"   {esg}")
    print()

    # Example 4: Bits of precision
    print("4. Bits of confidence achievable:")
    for n in [10, 50, 200, 1000]:
        bits = bits_of_precision_needed(1.0, 1.0, 3.0, n, 0.01)
        print(f"   n={n:5d}, ε=3.0, σ=1.0: {bits:.1f} bits of confidence")
