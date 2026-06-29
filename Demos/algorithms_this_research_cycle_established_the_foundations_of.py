#!/usr/bin/env python3
"""
Algorithms for Hyperbolic Number Theory

Implements the core algorithms from the research paper:
1. Free group ball/sphere size computation
2. Kesten spectral radius and gap
3. Berggren matrix trace classification
4. Translation length computation
5. Trace sequence via Cayley-Hamilton recurrence
6. Prime geodesic counting prediction
7. Random walk mixing time estimation

All algorithms include docstrings, type hints, and example usage.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class HyperbolicType(Enum):
    """Classification of SL₂ matrices by trace."""
    ELLIPTIC = "elliptic"      # |tr| < 2
    PARABOLIC = "parabolic"    # |tr| = 2
    HYPERBOLIC = "hyperbolic"  # |tr| > 2


@dataclass
class KestenDualityData:
    """
    The Kesten spectral-growth duality for F_k.
    
    Encodes the triangle: exponential growth ↔ spectral gap ↔ non-amenability.
    
    Attributes:
        k: Number of generators (≥ 2)
        growth_rate: 2k - 1 (exponential growth base)
        spectral_radius: √(2k-1)/k (Kesten's formula)
        spectral_gap: 1 - spectral_radius
        cheeger_lower: (1 - spectral_radius) / 2 (Cheeger-Buser lower bound)
    """
    k: int
    growth_rate: float
    spectral_radius: float
    spectral_gap: float
    cheeger_lower: float
    
    @classmethod
    def from_generators(cls, k: int) -> 'KestenDualityData':
        """Construct the standard Kesten duality for F_k.
        
        Args:
            k: Number of free generators, must be ≥ 2.
            
        Returns:
            KestenDualityData with all fields computed.
            
        Example:
            >>> d = KestenDualityData.from_generators(2)
            >>> d.growth_rate
            3.0
            >>> d.spectral_radius  # √3/2
            0.8660254037844386
        """
        if k < 2:
            raise ValueError(f"Need k ≥ 2, got k={k}")
        growth = 2 * k - 1
        rho = np.sqrt(growth) / k
        gap = 1 - rho
        cheeger = gap / 2
        return cls(k=k, growth_rate=float(growth), spectral_radius=rho,
                   spectral_gap=gap, cheeger_lower=cheeger)


def sphere_size(k: int, n: int) -> int:
    """
    Sphere size |S(n)| in the Cayley graph of F_k.
    
    S(0) = 1, S(n) = 2k(2k-1)^{n-1} for n ≥ 1.
    
    Args:
        k: Number of generators.
        n: Radius (non-negative integer).
        
    Returns:
        Number of elements at distance exactly n from the identity.
        
    Time: O(log n) for exponentiation.
    Space: O(1).
    
    Example:
        >>> sphere_size(2, 0)
        1
        >>> sphere_size(2, 1)
        4
        >>> sphere_size(2, 3)
        36
    """
    if n == 0:
        return 1
    return 2 * k * (2 * k - 1) ** (n - 1)


def ball_size(k: int, n: int) -> int:
    """
    Ball size |B(n)| = |{g ∈ F_k : |g| ≤ n}| in the Cayley graph.
    
    For k=2: B(n) = 2·3^n - 1 (exact closed form).
    General: B(n) = 1 + 2k·∑_{i=0}^{n-1} (2k-1)^i = 1 + k·((2k-1)^n - 1)/(k-1) for k ≥ 2.
    
    Args:
        k: Number of generators (≥ 1).
        n: Radius (non-negative integer).
        
    Returns:
        Number of elements at distance ≤ n from the identity.
        
    Time: O(n) iterative, O(log n) with closed form.
    Space: O(1).
    
    Example:
        >>> ball_size(2, 0)
        1
        >>> ball_size(2, 3)
        53
        >>> ball_size(2, 5)
        485
    """
    return sum(sphere_size(k, i) for i in range(n + 1))


def ball_size_closed_form(k: int, n: int) -> int:
    """
    Closed-form ball size computation.
    
    For k ≥ 2: B(n) = 1 + k·((2k-1)^n - 1)/(k-1).
    For k = 1: B(n) = 2n + 1.
    
    Time: O(log n) for exponentiation.
    Space: O(1).
    """
    if k == 1:
        return 2 * n + 1
    growth = 2 * k - 1
    return 1 + k * (growth ** n - 1) // (k - 1)


def kesten_spectral_radius(k: int) -> float:
    """
    Kesten spectral radius for the free group F_k.
    
    ρ = √(2k-1) / k
    
    Theorem: ρ < 1 for k ≥ 2 (spectral gap exists).
    Proof: ρ² = (2k-1)/k² < 1 ⟺ (k-1)² > 0.
    
    Args:
        k: Number of generators (≥ 2).
        
    Returns:
        Spectral radius ρ ∈ (0, 1).
    """
    return np.sqrt(2 * k - 1) / k


def classify_sl2_matrix(trace: int) -> HyperbolicType:
    """
    Classify an SL₂(ℤ) matrix by its trace.
    
    |tr| < 2: elliptic (finite order, rotation)
    |tr| = 2: parabolic (infinite order, horocyclic translation)
    |tr| > 2: hyperbolic (infinite order, geodesic translation)
    
    Args:
        trace: Integer trace of the matrix.
        
    Returns:
        HyperbolicType classification.
    """
    abs_tr = abs(trace)
    if abs_tr < 2:
        return HyperbolicType.ELLIPTIC
    elif abs_tr == 2:
        return HyperbolicType.PARABOLIC
    else:
        return HyperbolicType.HYPERBOLIC


def translation_length(trace: float) -> float:
    """
    Hyperbolic translation length from matrix trace.
    
    For |tr| > 2: ℓ = 2·arccosh(|tr|/2)
    For |tr| ≤ 2: ℓ = 0 (not hyperbolic)
    
    The translation length equals the length of the corresponding
    closed geodesic on the quotient surface.
    
    Properties (proved in Lean 4):
    - Positive for |tr| > 2
    - Monotone increasing in |tr|
    
    Args:
        trace: Trace of the SL₂ matrix.
        
    Returns:
        Translation length (≥ 0).
    """
    t = abs(trace)
    if t <= 2:
        return 0.0
    return 2 * np.arccosh(t / 2)


def trace_sequence(initial_trace: int, n: int) -> List[int]:
    """
    Compute tr(M), tr(M²), ..., tr(Mⁿ) using Cayley-Hamilton recurrence.
    
    For M ∈ SL₂ with tr(M) = t:
        tr(Mⁿ⁺²) = t · tr(Mⁿ⁺¹) - tr(Mⁿ)
    
    This is equivalent to the Chebyshev polynomial recurrence.
    
    Args:
        initial_trace: tr(M) of the base matrix.
        n: Number of powers to compute.
        
    Returns:
        List of traces [tr(M), tr(M²), ..., tr(Mⁿ)].
        
    Time: O(n).
    Space: O(n) for output, O(1) working.
    
    Example:
        >>> trace_sequence(3, 5)
        [3, 7, 18, 47, 123]
    """
    if n == 0:
        return []
    t = initial_trace
    traces = [2, t]  # tr(I) = 2, tr(M) = t
    for _ in range(2, n + 1):
        traces.append(t * traces[-1] - traces[-2])
    return traces[1:]


def geodesic_length_spectrum(initial_trace: int, n: int) -> List[Tuple[int, float]]:
    """
    Compute the geodesic length spectrum for powers of a hyperbolic matrix.
    
    Returns pairs (trace, translation_length) for M, M², ..., Mⁿ.
    
    Args:
        initial_trace: tr(M) of the base hyperbolic matrix.
        n: Number of powers.
        
    Returns:
        List of (trace, length) pairs.
    """
    traces = trace_sequence(initial_trace, n)
    return [(tr, translation_length(tr)) for tr in traces]


def prime_geodesic_prediction(L: float) -> float:
    """
    Predict π(L) using the prime geodesic theorem leading term.
    
    Conjecture: π(L) ~ e^L / L as L → ∞.
    
    This is the hyperbolic analog of the prime number theorem π(x) ~ x/ln(x).
    
    Args:
        L: Maximum geodesic length.
        
    Returns:
        Predicted count of primitive closed geodesics.
    """
    if L <= 0:
        return 0.0
    return np.exp(L) / L


def mixing_time(k: int, epsilon: float) -> int:
    """
    Estimate the mixing time for random walk on F_k Cayley graph.
    
    After n steps, variation distance ≤ ρ^n.
    Mixing time ≈ log(1/ε) / log(1/ρ).
    
    Args:
        k: Number of generators.
        epsilon: Target variation distance.
        
    Returns:
        Number of steps for ε-mixing.
    """
    rho = kesten_spectral_radius(k)
    return int(np.ceil(np.log(1 / epsilon) / np.log(1 / rho)))


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Kesten Duality for F₂:")
    d = KestenDualityData.from_generators(2)
    print(f"  Growth rate: {d.growth_rate}")
    print(f"  Spectral radius: {d.spectral_radius:.6f}")
    print(f"  Spectral gap: {d.spectral_gap:.6f}")
    print(f"  Cheeger lower bound: {d.cheeger_lower:.6f}")
    
    print("\nBall sizes (closed form vs iterative):")
    for n in range(6):
        b1 = ball_size(2, n)
        b2 = ball_size_closed_form(2, n)
        print(f"  n={n}: iterative={b1}, closed_form={b2}, match={b1==b2}")
    
    print("\nBerggren trace classification:")
    for name, tr in [("M1", 1), ("M2", 3), ("M3", 2)]:
        cls = classify_sl2_matrix(tr)
        tl = translation_length(tr)
        print(f"  {name}: tr={tr}, type={cls.value}, ℓ={tl:.4f}")
    
    print("\nGeodesic length spectrum (M₂ powers):")
    spectrum = geodesic_length_spectrum(3, 6)
    for i, (tr, length) in enumerate(spectrum, 1):
        print(f"  M₂^{i}: tr={tr:>6d}, ℓ={length:.6f}")
    
    print(f"\nMixing time for ε=0.01: {mixing_time(2, 0.01)} steps")
    print(f"Mixing time for ε=0.001: {mixing_time(2, 0.001)} steps")
