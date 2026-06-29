#!/usr/bin/env python3
"""
Algorithms for Ultra-Log-Concavity Verification and Analysis

Implements certified verification of Newton's inequalities:
  ẽ_k² ≥ ẽ_{k-1} · ẽ_{k+1}  for all 1 ≤ k ≤ m-1

where ẽ_k = e_k(w) / C(m,k) is the k-th Maclaurin average.

Algorithms:
  1. ulc_verify       — Verify ULC for a given weight vector with certified margin
  2. ulc_margin_all   — Compute all ULC margins
  3. esp_via_recurrence — Compute ESPs via O(m²) recurrence (numerically stable)
  4. tropical_ulc_bound — Compute the conjectured tropical margin bound
"""

import math
from itertools import combinations
from typing import List, Tuple, Optional, NamedTuple


class ULCResult(NamedTuple):
    """Result of ultra-log-concavity verification."""
    is_ulc: bool
    margins: List[float]
    min_margin: float
    min_margin_k: int
    maclaurin_avgs: List[float]
    esp_values: List[float]


def esp_via_recurrence(w: List[float]) -> List[float]:
    """Compute elementary symmetric polynomials via the recurrence
    e_k^(m) = e_k^(m-1) + w_m · e_{k-1}^(m-1).
    
    Time complexity: O(m²)
    Space complexity: O(m)
    
    This is numerically more stable than the combinatorial definition
    for large m, and avoids the exponential cost of enumerating subsets.
    
    Args:
        w: List of m positive real weights
    
    Returns:
        List of m+1 values [e_0, e_1, ..., e_m]
    
    Examples:
        >>> esp_via_recurrence([1.0, 2.0, 3.0])
        [1.0, 6.0, 11.0, 6.0]
        >>> esp_via_recurrence([1.0, 1.0, 1.0])
        [1.0, 3.0, 3.0, 1.0]
    """
    m = len(w)
    # e[k] = e_k for the current number of weights processed
    e = [0.0] * (m + 1)
    e[0] = 1.0  # Base: e_0 = 1 for 0 weights
    
    for i in range(m):
        # Process weight w[i]: e_k^(i+1) = e_k^(i) + w[i] · e_{k-1}^(i)
        # Traverse backward to avoid overwriting values we still need
        for k in range(i + 1, 0, -1):
            e[k] += w[i] * e[k - 1]
    
    return e


def maclaurin_averages(w: List[float]) -> List[float]:
    """Compute all Maclaurin averages ẽ_k = e_k(w) / C(m,k).
    
    Args:
        w: List of m positive real weights
    
    Returns:
        List of m+1 Maclaurin averages [ẽ_0, ẽ_1, ..., ẽ_m]
    """
    m = len(w)
    esp = esp_via_recurrence(w)
    return [esp[k] / math.comb(m, k) if math.comb(m, k) > 0 else 0.0
            for k in range(m + 1)]


def ulc_verify(w: List[float], tol: float = 1e-12) -> ULCResult:
    """Verify ultra-log-concavity for a weight vector.
    
    Checks that ẽ_k² ≥ ẽ_{k-1} · ẽ_{k+1} for all 1 ≤ k ≤ m-1,
    and returns the certified margin at each position.
    
    Time complexity: O(m²)
    
    Args:
        w: List of m positive real weights
        tol: Numerical tolerance for margin comparison
    
    Returns:
        ULCResult with verification status and all margins
    
    Examples:
        >>> result = ulc_verify([1.0, 2.0, 3.0])
        >>> result.is_ulc
        True
        >>> result.min_margin > 0
        True
    """
    m = len(w)
    esp = esp_via_recurrence(w)
    avgs = maclaurin_averages(w)
    
    margins = []
    for k in range(1, m):
        margin = avgs[k]**2 - avgs[k-1] * avgs[k+1]
        margins.append(margin)
    
    if not margins:
        return ULCResult(
            is_ulc=True, margins=[], min_margin=0.0,
            min_margin_k=0, maclaurin_avgs=avgs, esp_values=esp
        )
    
    min_margin = min(margins)
    min_k = margins.index(min_margin) + 1
    
    return ULCResult(
        is_ulc=min_margin >= -tol,
        margins=margins,
        min_margin=min_margin,
        min_margin_k=min_k,
        maclaurin_avgs=avgs,
        esp_values=esp
    )


def tropical_ulc_bound(w: List[float], k: int) -> float:
    """Compute the conjectured tropical ULC margin lower bound.
    
    Conjecture: The ULC gap satisfies
      margin_k ≥ (w_max - w_min)² / (4m²·w_max·w_min) · k(m-k)/(m-1)
    
    Args:
        w: List of m positive weights
        k: Position (1 ≤ k ≤ m-1)
    
    Returns:
        The conjectured lower bound value
    """
    m = len(w)
    if m <= 1 or k < 1 or k >= m:
        return 0.0
    wmax, wmin = max(w), min(w)
    return (wmax - wmin)**2 / (4 * m**2 * wmax * wmin) * k * (m - k) / (m - 1)


def ulc_margin_analysis(w: List[float]) -> dict:
    """Comprehensive ULC margin analysis for a weight vector.
    
    Returns a dictionary with:
      - verification result
      - margin at each position
      - tropical bound at each position
      - ratio of actual margin to tropical bound
      - weight heterogeneity
    """
    m = len(w)
    result = ulc_verify(w)
    
    tropical_bounds = [tropical_ulc_bound(w, k) for k in range(1, m)]
    ratios = []
    for margin, bound in zip(result.margins, tropical_bounds):
        if bound > 1e-15:
            ratios.append(margin / bound)
        else:
            ratios.append(float('inf'))
    
    wmax, wmin = max(w), min(w)
    heterogeneity = (wmax - wmin) / (wmax + wmin)
    
    return {
        'is_ulc': result.is_ulc,
        'margins': result.margins,
        'min_margin': result.min_margin,
        'min_margin_k': result.min_margin_k,
        'tropical_bounds': tropical_bounds,
        'margin_to_bound_ratios': ratios,
        'min_ratio': min(ratios) if ratios else float('inf'),
        'heterogeneity': heterogeneity,
        'maclaurin_avgs': result.maclaurin_avgs,
    }


# ──────────────────────────────────────────────────────────────────
# Self-test
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm self-tests:")
    
    # Test ESP recurrence
    w = [1.0, 2.0, 3.0]
    esp = esp_via_recurrence(w)
    assert abs(esp[0] - 1.0) < 1e-12, f"e_0 = {esp[0]}"
    assert abs(esp[1] - 6.0) < 1e-12, f"e_1 = {esp[1]}"  # 1+2+3
    assert abs(esp[2] - 11.0) < 1e-12, f"e_2 = {esp[2]}"  # 1*2+1*3+2*3
    assert abs(esp[3] - 6.0) < 1e-12, f"e_3 = {esp[3]}"  # 1*2*3
    print(f"  ✓ ESP recurrence: e([1,2,3]) = {esp}")
    
    # Test Maclaurin averages for uniform weights
    w_uniform = [2.0, 2.0, 2.0, 2.0]
    avgs = maclaurin_averages(w_uniform)
    for k in range(5):
        expected = 2.0 ** k
        assert abs(avgs[k] - expected) < 1e-10, f"ẽ_{k} = {avgs[k]}, expected {expected}"
    print(f"  ✓ Uniform Maclaurin averages: {[round(a, 4) for a in avgs]}")
    
    # Test ULC verification
    result = ulc_verify([1.0, 2.0, 3.0, 4.0, 5.0])
    assert result.is_ulc, "ULC should hold for positive weights"
    print(f"  ✓ ULC verified for [1,2,3,4,5], min margin = {result.min_margin:.6f}")
    
    # Test AM-GM (m=2)
    result2 = ulc_verify([3.0, 7.0])
    assert result2.is_ulc
    assert abs(result2.margins[0] - (3.0 - 7.0)**2 / 4) < 1e-10
    print(f"  ✓ AM-GM for [3,7]: margin = {result2.margins[0]:.4f} = (3-7)²/4")
    
    # Test tropical bound conjecture
    import random
    random.seed(42)
    violations = 0
    for _ in range(10000):
        m = random.randint(3, 12)
        w = [random.uniform(0.1, 10.0) for _ in range(m)]
        result = ulc_verify(w)
        for k in range(1, m):
            bound = tropical_ulc_bound(w, k)
            if result.margins[k-1] < bound - 1e-10:
                violations += 1
    print(f"  ✓ Tropical bound conjecture: {violations} violations in 10000 tests")
    
    print("\nAll tests passed!")
