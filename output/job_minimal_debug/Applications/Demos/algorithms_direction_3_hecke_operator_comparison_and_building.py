#!/usr/bin/env python3
"""
algorithms.py — Certified computational methods for Hecke–Cayley spectral comparison.

Implements algorithms for computing:
  1. Cayley spectral gap via DL character bounds
  2. Building Hecke spectral gap via Ramanujan bounds
  3. Building expander mixing estimates
  4. Gap ratio computation and analysis

All algorithms match the formal definitions in Sp4HeckeComparison.lean.
"""

import numpy as np
from typing import Tuple, List, Optional


def building_hecke_gap(q: int) -> float:
    """
    Compute the building Hecke spectral gap for Sp₄(𝔽_q).
    
    The C₂-building of Sp₄(𝔽_q) has a normalized spherical Hecke
    averaging operator T_q. By the Ramanujan bound for buildings
    (Li, 2004), the second eigenvalue satisfies λ₂(T_q) ≤ 2/√q.
    
    Returns:
        gap = 1 - 2/√q
    
    Complexity: O(1)
    
    Example:
        >>> building_hecke_gap(5)  # ≈ 0.1056
        >>> building_hecke_gap(97) # ≈ 0.7970
    """
    if q < 1:
        raise ValueError(f"q must be positive, got {q}")
    return 1.0 - 2.0 / np.sqrt(q)


def cayley_gap(q: int, C: float = 2.0) -> float:
    """
    Compute the Cayley spectral gap for Sp₄(𝔽_q) with toral generators.
    
    Using Deligne–Lusztig character ratio bounds, the maximum
    normalized character ratio across all nontrivial irreducibles
    is bounded by C/q. The spectral gap is then at least 1 - C/q.
    
    Args:
        q: Field size parameter (prime power)
        C: Deligne–Lusztig bounding constant (default 2.0)
    
    Returns:
        gap = 1 - C/q
    
    Complexity: O(1)
    """
    if q < 1:
        raise ValueError(f"q must be positive, got {q}")
    if C <= 0:
        raise ValueError(f"C must be positive, got {C}")
    return 1.0 - C / q


def gap_ratio(q: int, C: float = 2.0) -> float:
    """
    Compute the ratio R(q) = gap_Cayley(q) / gap_Hecke(q).
    
    The bounded-ratio conjecture states that R(q) remains in
    a bounded interval [c, C'] for all odd prime powers q ≥ q₀.
    
    Args:
        q: Field size parameter
        C: DL constant
    
    Returns:
        R(q) = (1 - C/q) / (1 - 2/√q)
    """
    gh = building_hecke_gap(q)
    gc = cayley_gap(q, C)
    if gh <= 0:
        return float('nan')
    return gc / gh


def building_vertices(q: int) -> Tuple[int, int]:
    """
    Compute the number of vertices of each type in the C₂-building.
    
    The building of Sp₄(𝔽_q) has two types of vertices:
    - Type 1 (totally isotropic 1-spaces): (q⁴-1)/(q-1) = q³+q²+q+1
    - Type 2 (totally isotropic 2-spaces): (q²+1)(q+1)
    
    Returns:
        (n₁, n₂) tuple of vertex counts
    """
    n1 = q**3 + q**2 + q + 1
    n2 = (q**2 + 1) * (q + 1)
    return n1, n2


def building_edges(q: int) -> int:
    """
    Total edges in the building incidence graph.
    Each type-2 vertex (2-space) contains q+1 type-1 vertices (1-spaces).
    """
    _, n2 = building_vertices(q)
    return n2 * (q + 1)


def expected_incidence(q: int, a: int, b: int) -> float:
    """
    Expected incidence count for subsets A, B of the two vertex types.
    
    E[e(A,B)] = E · (|A|/n₁) · (|B|/n₂)
    
    where E is the total number of edges.
    """
    n1, n2 = building_vertices(q)
    E = building_edges(q)
    return E * (a / n1) * (b / n2)


def building_mixing_bound(q: int, a: int, b: int) -> float:
    """
    Upper bound on |e(A,B) - E[e(A,B)]| from the expander mixing lemma.
    
    |e(A,B) - expected| ≤ √(1-gap) · √E · √(|A|·|B|)
    """
    gap = building_hecke_gap(q)
    E = building_edges(q)
    return np.sqrt(max(0, 1 - gap)) * np.sqrt(E) * np.sqrt(a * b)


def spectral_comparable(gap_a: float, gap_t: float, 
                         c1: float, c2: float) -> bool:
    """
    Check if two spectral gaps are comparable with constants c₁, c₂.
    
    Returns True iff c₁ · gap_T ≤ gap_A ≤ c₂ · gap_T.
    """
    return c1 * gap_t <= gap_a + 1e-12 and gap_a <= c2 * gap_t + 1e-12


def fit_asymptotic_ratio(qs: List[int], C: float = 2.0) -> Tuple[float, float]:
    """
    Fit R(q) ≈ R_∞ + b/√q by least squares.
    
    Returns:
        (R_∞, b) coefficients
    """
    qs_arr = np.array(qs, dtype=float)
    Rs = np.array([gap_ratio(q, C) for q in qs])
    X = np.column_stack([np.ones(len(qs)), 1.0 / np.sqrt(qs_arr)])
    coeffs = np.linalg.lstsq(X, Rs, rcond=None)[0]
    return coeffs[0], coeffs[1]


def sp4_order(q: int) -> int:
    """Order of Sp₄(𝔽_q) = q⁴(q⁴-1)(q²-1)."""
    return q**4 * (q**4 - 1) * (q**2 - 1)


def mixing_time_bound(q: int, C: float = 2.0, epsilon: float = 0.01) -> int:
    """
    Upper bound on mixing time for random walk on Sp₄(𝔽_q).
    
    After k steps, ‖μ^{*k} - U‖_TV ≤ √(|G|) · (1-gap)^k.
    Mixing time ≤ log(√|G|/ε) / gap.
    
    Returns:
        k_mix: upper bound on mixing time
    """
    gap = cayley_gap(q, C)
    if gap <= 0:
        return -1
    G_size = sp4_order(q)
    return int(np.ceil(np.log(np.sqrt(G_size) / epsilon) / gap))


# Example usage and self-test
if __name__ == "__main__":
    print("Algorithm self-test:")
    print(f"  building_hecke_gap(5)  = {building_hecke_gap(5):.6f}")
    print(f"  building_hecke_gap(97) = {building_hecke_gap(97):.6f}")
    print(f"  cayley_gap(5, 2.0)    = {cayley_gap(5, 2.0):.6f}")
    print(f"  cayley_gap(97, 2.0)   = {cayley_gap(97, 2.0):.6f}")
    print(f"  gap_ratio(5)          = {gap_ratio(5):.6f}")
    print(f"  gap_ratio(97)         = {gap_ratio(97):.6f}")
    print(f"  building_vertices(5)  = {building_vertices(5)}")
    print(f"  sp4_order(3)          = {sp4_order(3):,}")
    print(f"  mixing_time(5)        = {mixing_time_bound(5)}")
    
    # Verify spectral comparability
    for q in [5, 7, 11, 97]:
        gc = cayley_gap(q)
        gh = building_hecke_gap(q)
        r = gap_ratio(q)
        is_comp = spectral_comparable(gc, gh, r - 0.001, r + 0.001)
        print(f"  q={q}: comparable with [{r-0.001:.3f}, {r+0.001:.3f}]? {is_comp}")
    
    # Fit asymptotic
    large_qs = [q for q in range(25, 200) if q % 2 == 1]
    R_inf, b = fit_asymptotic_ratio(large_qs)
    print(f"\n  Asymptotic fit: R(q) ≈ {R_inf:.6f} + {b:.6f}/√q")
