#!/usr/bin/env python3
"""
Algorithms for Tropical Convexity and the Tropical Helly Theorem

Implements:
1. Tropical halfspace intersection (Farkas construction) — O(mn)
2. Tropical Helly checker — O(|F|^{n+1} * mn)
3. Tropical convex hull membership test
4. Tropical fractional Helly test

All algorithms correspond to theorems verified in the Lean formalization.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional, Set


class TropicalHalfspace:
    """A tropical halfspace H(a, b) = {x ∈ ℝⁿ | max_i(a_i + x_i) ≥ b}.
    
    This is the max-plus analogue of a classical linear inequality aᵀx ≥ b.
    Corresponds to the Lean definition `TropHalfspace` in TropicalHelly.lean.
    """
    
    def __init__(self, a: np.ndarray, b: float):
        """Initialize a tropical halfspace.
        
        Args:
            a: Normal vector (n-dimensional)
            b: Threshold value
        """
        self.a = np.asarray(a, dtype=float)
        self.b = float(b)
        self.n = len(self.a)
    
    def contains(self, x: np.ndarray) -> bool:
        """Check if x ∈ H(a, b), i.e., max_i(a_i + x_i) ≥ b."""
        return float(np.max(self.a + x)) >= self.b - 1e-10
    
    def __repr__(self):
        return f"TropHalfspace(a={self.a}, b={self.b})"


def tropical_combination(x: np.ndarray, y: np.ndarray, s: float, t: float) -> np.ndarray:
    """Compute the tropical convex combination.
    
    Returns: i ↦ max(s + x_i, t + y_i)
    
    Requires: max(s, t) = 0 (tropical normalization).
    Corresponds to the definition of IsTropConvex in TropicalHelly.lean.
    """
    return np.maximum(s + x, t + y)


def farkas_construction(halfspaces: List[TropicalHalfspace]) -> Optional[np.ndarray]:
    """Find a point in the intersection of tropical halfspaces.
    
    Uses the constructive Farkas method:
        x_i = max_j (b_j - a_{ji})
    
    This is the algorithm behind Theorem 3.8 (tropical_farkas_weak).
    
    Complexity: O(mn) where m = len(halfspaces), n = dimension.
    
    Returns:
        A point in ⋂H_j, or None if infeasible.
    """
    if not halfspaces:
        return np.zeros(0)
    
    m = len(halfspaces)
    n = halfspaces[0].n
    
    # Construct candidate point: x_i = max_j (b_j - a_{ji})
    A = np.array([h.a for h in halfspaces])
    b = np.array([h.b for h in halfspaces])
    
    x = np.zeros(n)
    for i in range(n):
        x[i] = np.max(b - A[:, i])
    
    # Verify feasibility
    for h in halfspaces:
        if not h.contains(x):
            return None
    
    return x


def tropical_helly_check(
    halfspaces: List[TropicalHalfspace],
    dimension: int
) -> Tuple[bool, Optional[np.ndarray], List]:
    """Check the tropical Helly condition and find a witness point.
    
    For a family of m tropical halfspaces in ℝⁿ, checks whether every
    subfamily of size n+1 has nonempty intersection. If so, by the
    tropical Helly theorem, the full intersection is nonempty.
    
    Corresponds to: tropical_helly in TropicalHelly.lean.
    
    Args:
        halfspaces: Family of tropical halfspaces
        dimension: Ambient dimension n
    
    Returns:
        (helly_holds, witness_point, failing_subfamilies)
    
    Complexity: O(m^{n+1} * mn) for the check.
    """
    m = len(halfspaces)
    helly_number = dimension + 1
    failing = []
    
    # Check all (n+1)-subfamilies
    for combo in combinations(range(m), min(helly_number, m)):
        subset = [halfspaces[i] for i in combo]
        point = farkas_construction(subset)
        if point is None:
            failing.append(list(combo))
    
    if failing:
        return False, None, failing
    
    # Helly condition holds — find witness
    witness = farkas_construction(halfspaces)
    return True, witness, []


def tropical_convex_hull_membership(
    point: np.ndarray,
    generators: List[np.ndarray],
    max_depth: int = 20
) -> bool:
    """Approximate test: is `point` in the tropical convex hull of `generators`?
    
    Uses iterative tropical combination to approximate the hull.
    Not guaranteed to find membership in all cases (the hull may
    require many combinations).
    
    Returns:
        True if point is found in the hull (within tolerance).
    """
    if not generators:
        return False
    
    n = len(point)
    tol = 1e-8
    
    # Check if point is a generator
    for g in generators:
        if np.max(np.abs(point - g)) < tol:
            return True
    
    # Iteratively build hull by tropical combinations
    hull_points = list(generators)
    for _ in range(max_depth):
        new_points = []
        for x in hull_points:
            for y in generators:
                for s in np.linspace(-3, 0, 10):
                    t = 0.0
                    z = tropical_combination(x, y, s, t)
                    if np.max(np.abs(z - point)) < tol:
                        return True
                    new_points.append(z)
                    
                    z = tropical_combination(x, y, 0.0, s)
                    if np.max(np.abs(z - point)) < tol:
                        return True
                    new_points.append(z)
        
        hull_points = new_points[:1000]  # Keep bounded
    
    return False


def fractional_helly_test(
    halfspaces: List[TropicalHalfspace],
    dimension: int,
    grid_resolution: int = 20
) -> Tuple[float, float, np.ndarray]:
    """Test the tropical fractional Helly conjecture.
    
    Computes:
    - α: fraction of (n+1)-subfamilies with nonempty intersection
    - β: maximum fraction of halfspaces containing any grid point
    
    The conjecture predicts β ≥ c·α for some universal constant c > 0.
    
    Returns:
        (alpha, beta, best_point)
    """
    m = len(halfspaces)
    n = dimension
    helly_number = n + 1
    
    # Compute α
    total = 0
    intersecting = 0
    for combo in combinations(range(m), min(helly_number, m)):
        total += 1
        subset = [halfspaces[i] for i in combo]
        if farkas_construction(subset) is not None:
            intersecting += 1
    
    alpha = intersecting / total if total > 0 else 0.0
    
    # Compute β via grid search + Farkas point
    best_count = 0
    best_point = np.zeros(n)
    
    # Try the Farkas construction point first
    farkas_point = farkas_construction(halfspaces)
    if farkas_point is not None:
        count = sum(1 for h in halfspaces if h.contains(farkas_point))
        if count > best_count:
            best_count = count
            best_point = farkas_point
    
    # Also try grid points
    grid = np.linspace(-5, 5, grid_resolution)
    if n <= 3:
        for coords in np.ndindex(*([grid_resolution] * n)):
            x = np.array([grid[c] for c in coords])
            count = sum(1 for h in halfspaces if h.contains(x))
            if count > best_count:
                best_count = count
                best_point = x.copy()
    
    beta = best_count / m if m > 0 else 0.0
    
    return alpha, beta, best_point


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    # Example 1: Farkas construction
    print("Example 1: Farkas Construction")
    print("-" * 40)
    halfspaces = [
        TropicalHalfspace([1, 0, 0], 2),
        TropicalHalfspace([0, 1, 0], 3),
        TropicalHalfspace([0, 0, 1], 1),
    ]
    
    point = farkas_construction(halfspaces)
    if point is not None:
        print(f"Feasible point: {point}")
        for h in halfspaces:
            print(f"  {h}: max(a+x) = {np.max(h.a + point):.2f} >= {h.b} ✓")
    else:
        print("Infeasible!")
    
    # Example 2: Helly checker
    print("\nExample 2: Tropical Helly Checker")
    print("-" * 40)
    n = 3
    m = 6
    halfspaces = [
        TropicalHalfspace(np.random.randn(n), np.random.randn())
        for _ in range(m)
    ]
    
    holds, witness, failing = tropical_helly_check(halfspaces, n)
    print(f"Helly condition (n+1={n+1}-wise intersection): {'holds' if holds else 'fails'}")
    if holds and witness is not None:
        print(f"Witness: {np.round(witness, 3)}")
    elif failing:
        print(f"Failing subfamilies: {failing[:3]}...")
    
    # Example 3: Fractional Helly test
    print("\nExample 3: Fractional Helly Test")
    print("-" * 40)
    halfspaces = [
        TropicalHalfspace(np.random.randn(3) * 2, np.random.randn())
        for _ in range(12)
    ]
    alpha, beta, best = fractional_helly_test(halfspaces, 3, grid_resolution=10)
    print(f"α (fraction of 4-tuples intersecting): {alpha:.3f}")
    print(f"β (max fraction of sets containing a point): {beta:.3f}")
    print(f"Best point: {np.round(best, 3)}")
    print(f"Fractional Helly supported: {'Yes' if beta >= 0.05 * alpha else 'Unclear'}")
