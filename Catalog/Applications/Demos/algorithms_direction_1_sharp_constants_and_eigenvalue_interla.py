#!/usr/bin/env python3
"""
algorithms.py — Spectral Algorithms for Augmented Discrete Tori

Implements the core algorithms for computing spectral gaps, eigenvalues,
and mixing time estimates on Cayley graphs of (ℤ/nℤ)^d.

Algorithm 1: Exact Fourier Symbol Computation — O(n^d) per frequency
Algorithm 2: Spectral Gap via Closed-Form Formula — O(1)
Algorithm 3: Full Spectrum Enumeration — O(n^d)
Algorithm 4: Mixing Time Bound — O(1) from spectral gap

All algorithms are exact (no approximation) up to floating-point precision.
"""

import math
from itertools import product
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Fourier Symbol Evaluation
# ============================================================

def fourier_symbol_local(n: int, d: int, freq: Tuple[int, ...]) -> float:
    """
    Evaluate the local Laplacian Fourier symbol at frequency k.

    λ_loc(k) = Σⱼ (2 - 2cos(2πkⱼ/n))

    Time: O(d)
    Space: O(1)

    Args:
        n: modulus (n ≥ 2)
        d: dimension (d ≥ 1)
        freq: frequency vector (k₁, ..., k_d) with kⱼ ∈ {0,...,n-1}

    Returns:
        The local Laplacian eigenvalue at frequency k.
    """
    return sum(2 - 2 * math.cos(2 * math.pi * k_j / n) for k_j in freq)


def fourier_symbol_diagonal(n: int, d: int, freq: Tuple[int, ...]) -> float:
    """
    Evaluate the diagonal generator's Fourier symbol at frequency k.

    λ_diag(k) = 2 - 2cos(2π(k₁+...+k_d)/n)

    Time: O(d) for sum, O(1) for cosine
    Space: O(1)
    """
    s = sum(freq) % n
    return 2 - 2 * math.cos(2 * math.pi * s / n)


def fourier_symbol_hybrid(n: int, d: int, freq: Tuple[int, ...]) -> float:
    """
    Evaluate the hybrid Laplacian Fourier symbol at frequency k.

    λ_hyb(k) = λ_loc(k) + λ_diag(k)

    This is the spectral additivity principle in action:
    eigenvalues of the union graph = sum of eigenvalues of components.

    Time: O(d)
    Space: O(1)
    """
    return fourier_symbol_local(n, d, freq) + fourier_symbol_diagonal(n, d, freq)


# ============================================================
# Algorithm 2: Closed-Form Spectral Gap
# ============================================================

def spectral_gap_local(n: int, d: int) -> float:
    """
    Compute the local spectral gap using the exact formula.

    γ_loc(n,d) = 4sin²(π/n)

    This is INDEPENDENT of d — the minimum over nonzero frequencies
    is always achieved at a coordinate frequency eᵢ.

    Time: O(1)
    Space: O(1)

    Theorem A: Proved in TorusSpectralAnatomy.lean
    """
    return 4 * math.sin(math.pi / n) ** 2


def spectral_gap_hybrid(n: int, d: int) -> float:
    """
    Compute the hybrid spectral gap using the exact formula.

    γ_hyb(n,d) = 2 × γ_loc(n,d) = 8sin²(π/n)

    This is INDEPENDENT of d — proved as Theorem C.

    Time: O(1)
    Space: O(1)

    Theorem C: Proved in TorusSpectralAnatomy.lean
    """
    return 2 * spectral_gap_local(n, d)


def spectral_gap_ratio(n: int, d: int) -> float:
    """
    The universal spectral gap ratio.

    γ_hyb / γ_loc = 2 for all n ≥ 2, d ≥ 1.

    Time: O(1)
    """
    return 2.0


# ============================================================
# Algorithm 3: Full Spectrum Enumeration
# ============================================================

def full_spectrum(n: int, d: int, graph_type: str = "hybrid") -> List[Tuple[Tuple[int, ...], float]]:
    """
    Enumerate all eigenvalues of the Cayley Laplacian.

    Returns list of (frequency, eigenvalue) pairs sorted by eigenvalue.

    Time: O(n^d · d)
    Space: O(n^d)

    Args:
        n: modulus
        d: dimension
        graph_type: "local", "hybrid", or "diagonal"
    """
    symbol_fn = {
        "local": fourier_symbol_local,
        "hybrid": fourier_symbol_hybrid,
        "diagonal": fourier_symbol_diagonal,
    }[graph_type]

    spectrum = []
    for freq in product(range(n), repeat=d):
        eigenvalue = symbol_fn(n, d, freq)
        spectrum.append((freq, eigenvalue))

    spectrum.sort(key=lambda x: x[1])
    return spectrum


def eigenvalue_multiplicities(n: int, d: int, graph_type: str = "hybrid",
                               tol: float = 1e-10) -> List[Tuple[float, int]]:
    """
    Compute eigenvalue multiplicities.

    Returns list of (eigenvalue, multiplicity) pairs.

    Time: O(n^d · d)
    Space: O(n^d)
    """
    spectrum = full_spectrum(n, d, graph_type)
    result = []
    current_val = None
    current_mult = 0

    for _, val in spectrum:
        if current_val is None or abs(val - current_val) > tol:
            if current_val is not None:
                result.append((current_val, current_mult))
            current_val = val
            current_mult = 1
        else:
            current_mult += 1

    if current_val is not None:
        result.append((current_val, current_mult))

    return result


# ============================================================
# Algorithm 4: Mixing Time Bounds
# ============================================================

def relaxation_time(n: int, d: int, graph_type: str = "hybrid") -> float:
    """
    Compute the relaxation time t_rel = 1/γ.

    For the hybrid graph: t_rel = 1/(8sin²(π/n))
    For the local graph:  t_rel = 1/(4sin²(π/n))

    The hybrid walk relaxes TWICE as fast.

    Time: O(1)
    """
    if graph_type == "hybrid":
        return 1.0 / spectral_gap_hybrid(n, d)
    else:
        return 1.0 / spectral_gap_local(n, d)


def l2_mixing_time(n: int, d: int, graph_type: str = "hybrid",
                    epsilon: float = 0.01) -> float:
    """
    Compute the L² mixing time t_mix(ε) such that
    ‖P^t f - E[f]‖₂ ≤ ε ‖f - E[f]‖₂ for t ≥ t_mix.

    t_mix(ε) = -ln(ε) / γ

    Time: O(1)
    """
    gap = spectral_gap_hybrid(n, d) if graph_type == "hybrid" else spectral_gap_local(n, d)
    return -math.log(epsilon) / gap


def mixing_speedup_factor(n: int, d: int) -> float:
    """
    The ratio t_mix^loc / t_mix^hyb = γ_hyb / γ_loc = 2.

    Adding one diagonal generator provides a universal 2× speedup.

    Time: O(1)
    """
    return 2.0


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Spectral Algorithms for Augmented Discrete Tori")
    print("=" * 55)

    # Algorithm 2: Closed-form spectral gaps
    print("\n--- Closed-Form Spectral Gaps ---")
    for n in [5, 10, 20, 50, 100]:
        for d in [1, 2, 3]:
            gl = spectral_gap_local(n, d)
            gh = spectral_gap_hybrid(n, d)
            print(f"  n={n:>3}, d={d}: γ_loc={gl:.6f}, γ_hyb={gh:.6f}, ratio={gh/gl:.1f}")

    # Algorithm 3: Spectrum example
    print("\n--- Eigenvalue Multiplicities (n=5, d=2, hybrid) ---")
    mults = eigenvalue_multiplicities(5, 2, "hybrid")
    for val, mult in mults:
        print(f"  λ = {val:>8.4f}  (multiplicity {mult})")

    # Algorithm 4: Mixing times
    print("\n--- Mixing Time Comparison ---")
    for n in [10, 50, 100]:
        t_loc = l2_mixing_time(n, 2, "local")
        t_hyb = l2_mixing_time(n, 2, "hybrid")
        print(f"  n={n:>3}, d=2: t_mix^loc={t_loc:.1f}, t_mix^hyb={t_hyb:.1f}, speedup={t_loc/t_hyb:.1f}×")
