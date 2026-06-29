#!/usr/bin/env python3
"""
Tropical Equivalence Algorithms

Implementations of algorithms from the research paper on certified tropical
invariants for ranking preservation.
"""

import numpy as np
from typing import Tuple, Optional, List


def trop_equiv_check(x: np.ndarray, y: np.ndarray, tol: float = 1e-12) -> Tuple[bool, Optional[float]]:
    """
    Algorithm 1: Check exact tropical equivalence.
    
    Two vectors x, y ∈ ℝⁿ are tropically equivalent if there exists c ∈ ℝ
    such that y[i] = x[i] + c for all i.
    
    Args:
        x: First vector (n,)
        y: Second vector (n,), same length as x
        tol: Numerical tolerance for equality
        
    Returns:
        (is_equivalent, shift_constant): Boolean and the shift c (or None)
        
    Complexity: O(n) time, O(1) space
    
    >>> trop_equiv_check(np.array([1.0, 2.0, 3.0]), np.array([4.0, 5.0, 6.0]))
    (True, 3.0)
    >>> trop_equiv_check(np.array([1.0, 2.0, 3.0]), np.array([4.0, 5.0, 7.0]))
    (False, None)
    """
    assert len(x) == len(y), "Vectors must have the same length"
    
    if len(x) == 0:
        return True, 0.0
    
    c = float(y[0] - x[0])
    for i in range(1, len(x)):
        if abs((y[i] - x[i]) - c) > tol:
            return False, None
    
    return True, c


def approx_trop_equiv_check(
    x: np.ndarray, y: np.ndarray, epsilon: float
) -> Tuple[bool, float, float]:
    """
    Algorithm 2: Check approximate tropical equivalence.
    
    Checks whether there exists c ∈ ℝ such that |y[i] - x[i] - c| ≤ ε for all i.
    Uses the median of differences as the optimal shift estimate.
    
    Args:
        x: First vector (n,)
        y: Second vector (n,), same length as x
        epsilon: Tolerance for approximate equivalence
        
    Returns:
        (is_approx_equiv, best_shift, max_deviation)
        
    Complexity: O(n log n) time (due to median), O(n) space
    
    >>> x = np.array([1.0, 2.0, 3.0])
    >>> y = np.array([4.1, 5.0, 5.9])
    >>> ok, c, dev = approx_trop_equiv_check(x, y, 0.15)
    >>> ok
    True
    """
    assert len(x) == len(y), "Vectors must have the same length"
    
    diffs = y - x
    c = float(np.median(diffs))
    max_dev = float(np.max(np.abs(diffs - c)))
    
    return max_dev <= epsilon, c, max_dev


def min_score_gap(x: np.ndarray) -> float:
    """
    Algorithm 3: Compute minimum gap between distinct sorted values.
    
    The minimum gap δ determines the robustness radius: rankings are
    preserved under approximate tropical shifts with ε < δ/2.
    
    Args:
        x: Score vector (n,)
        
    Returns:
        Minimum gap between consecutive distinct sorted values.
        Returns inf if all values are equal.
        
    Complexity: O(n log n) time, O(n) space
    
    >>> min_score_gap(np.array([3.0, 1.0, 5.0, 2.0]))
    1.0
    >>> min_score_gap(np.array([1.0, 1.0, 1.0]))
    inf
    """
    unique_sorted = np.sort(np.unique(x))
    if len(unique_sorted) < 2:
        return float('inf')
    return float(np.min(np.diff(unique_sorted)))


def ranking_permutation(x: np.ndarray) -> np.ndarray:
    """
    Compute the ranking permutation of a vector.
    
    Returns an array r where r[i] is the rank of x[i] (0 = smallest).
    Ties are broken by index (stable sort).
    
    Args:
        x: Score vector (n,)
        
    Returns:
        Rank array (n,) with values in {0, ..., n-1}
        
    Complexity: O(n log n) time, O(n) space
    """
    return np.argsort(np.argsort(x))


def argmin_indices(x: np.ndarray, tol: float = 1e-12) -> List[int]:
    """
    Compute the argmin set of a vector.
    
    Returns the list of all indices achieving the minimum value.
    
    Args:
        x: Score vector (n,)
        tol: Numerical tolerance for minimum comparison
        
    Returns:
        Sorted list of indices where x achieves its minimum
        
    Complexity: O(n) time, O(k) space where k = |argmin set|
    """
    m = np.min(x)
    return sorted(int(i) for i in np.where(np.abs(x - m) <= tol)[0])


def threshold_indices(x: np.ndarray, tau: float) -> List[int]:
    """
    Compute the threshold (sublevel) set {i | x[i] ≤ τ}.
    
    Under tropical shift by c, the theorem guarantees:
    {i | x[i] ≤ τ} = {i | (x+c)[i] ≤ τ+c}
    
    Args:
        x: Score vector (n,)
        tau: Threshold value
        
    Returns:
        Sorted list of indices where x[i] ≤ τ
        
    Complexity: O(n) time, O(k) space where k = |threshold set|
    """
    return sorted(int(i) for i in np.where(x <= tau + 1e-12)[0])


def robustness_radius(x: np.ndarray) -> float:
    """
    Compute the maximum perturbation ε for which rankings are guaranteed
    to be preserved under approximate tropical shifts.
    
    By Theorem 11 (gap-stability), rankings are preserved when ε < δ/2
    where δ is the minimum score gap.
    
    Args:
        x: Score vector (n,)
        
    Returns:
        Maximum safe perturbation radius ε = δ/2
        
    Complexity: O(n log n) time, O(n) space
    """
    return min_score_gap(x) / 2.0


def tropical_normalize(x: np.ndarray, method: str = "zero_min") -> Tuple[np.ndarray, float]:
    """
    Apply tropical normalization (additive shift) to a vector.
    
    All methods produce tropically equivalent vectors, so rankings
    are guaranteed preserved by the invariance theorems.
    
    Args:
        x: Score vector (n,)
        method: One of "zero_min", "mean_center", "zero_max", "median_center"
        
    Returns:
        (normalized_vector, shift_constant)
    """
    if method == "zero_min":
        c = -np.min(x)
    elif method == "mean_center":
        c = -np.mean(x)
    elif method == "zero_max":
        c = -np.max(x)
    elif method == "median_center":
        c = -np.median(x)
    else:
        raise ValueError(f"Unknown method: {method}")
    
    return x + c, float(c)


def verify_ranking_invariance(
    x: np.ndarray, y: np.ndarray
) -> Tuple[bool, Optional[float]]:
    """
    Verify that two vectors have the same ranking structure and check
    whether they are tropically equivalent.
    
    This is the computational analogue of the main theorem:
    TropEquiv x y → ∀ i j, x[i] ≤ x[j] ↔ y[i] ≤ y[j]
    
    Args:
        x, y: Score vectors of the same length
        
    Returns:
        (rankings_match, shift_if_tropequiv)
    """
    rank_x = ranking_permutation(x)
    rank_y = ranking_permutation(y)
    rankings_match = np.array_equal(rank_x, rank_y)
    
    is_equiv, shift = trop_equiv_check(x, y)
    
    return rankings_match, shift if is_equiv else None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Equivalence Algorithms — Examples\n")
    
    # Example 1: Exact equivalence
    x = np.array([2.0, 5.0, 1.0, 7.0, 3.0])
    y = np.array([5.0, 8.0, 4.0, 10.0, 6.0])
    
    equiv, c = trop_equiv_check(x, y)
    print(f"x = {x}")
    print(f"y = {y}")
    print(f"Tropically equivalent: {equiv}, shift = {c}")
    print(f"Rankings of x: {ranking_permutation(x)}")
    print(f"Rankings of y: {ranking_permutation(y)}")
    print(f"Argmin of x: {argmin_indices(x)}")
    print(f"Argmin of y: {argmin_indices(y)}")
    print()
    
    # Example 2: Robustness radius
    scores = np.array([1.0, 3.0, 3.5, 6.0, 10.0])
    radius = robustness_radius(scores)
    print(f"Scores: {scores}")
    print(f"Min gap: {min_score_gap(scores)}")
    print(f"Robustness radius: {radius}")
    print(f"Rankings safe for perturbations < {radius}")
    print()
    
    # Example 3: Normalization invariance
    raw = np.array([0.35, 0.15, 0.25, 0.10, 0.15])
    for method in ["zero_min", "mean_center", "zero_max", "median_center"]:
        normed, c = tropical_normalize(raw, method)
        match, _ = verify_ranking_invariance(raw, normed)
        print(f"{method:>15s}: {normed} (shift={c:+.2f}, ranking preserved={match})")
