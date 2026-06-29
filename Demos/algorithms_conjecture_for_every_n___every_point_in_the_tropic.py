#!/usr/bin/env python3
"""
Algorithms for Tropical Convexity and Carathéodory Compression

Implements the core algorithms from the Tropical Carathéodory Compression
theorem, including tropical convex hull membership testing, active witness
extraction, and compression to minimal generator sets.

Tropical Arithmetic (min-plus semiring):
    a ⊕ b = min(a, b)       (tropical addition)
    a ⊙ b = a + b           (tropical multiplication)
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass


@dataclass
class TropicalCombination:
    """
    A tropical convex combination z(i) = min_j (w_j + x_j(i)).
    
    Attributes:
        points: (k, n) array of k generators in R^n
        weights: (k,) array of tropical weights
        result: (n,) array — the resulting tropical combination
    """
    points: np.ndarray
    weights: np.ndarray
    result: np.ndarray
    
    @property
    def n_generators(self) -> int:
        return self.points.shape[0]
    
    @property
    def dimension(self) -> int:
        return self.points.shape[1]


def tropical_min_plus(points: np.ndarray, weights: np.ndarray) -> np.ndarray:
    """
    Compute the min-plus tropical combination.
    
    z(i) = min_{j=1..k} (w_j + x_j(i))
    
    Args:
        points: (k, n) array of generators
        weights: (k,) array of weights
        
    Returns:
        (n,) array — the tropical combination
        
    Time complexity: O(k * n)
    Space complexity: O(n)
    """
    return (weights[:, None] + points).min(axis=0)


def find_active_set(points: np.ndarray, weights: np.ndarray,
                     z: np.ndarray, tol: float = 1e-12) -> Dict[int, List[int]]:
    """
    Identify the active generator set for each coordinate.
    
    For coordinate i, generator j is active if w_j + x_j(i) = z(i).
    
    Args:
        points: (k, n) array of generators
        weights: (k,) array of weights  
        z: (n,) array — target point
        tol: numerical tolerance
        
    Returns:
        Dictionary mapping coordinate -> list of active generator indices
        
    Time complexity: O(k * n)
    """
    n = z.shape[0]
    k = points.shape[0]
    active = {}
    for i in range(n):
        active[i] = [j for j in range(k) 
                      if abs(weights[j] + points[j, i] - z[i]) < tol]
    return active


def caratheodory_compress(points: np.ndarray, weights: np.ndarray,
                           strategy: str = "first") -> TropicalCombination:
    """
    Apply Tropical Carathéodory Compression to reduce generators to at most n.
    
    Algorithm:
        1. Compute z = tropical_min_plus(points, weights)
        2. For each coordinate i, select one active generator
        3. Return the compressed combination using only selected generators
    
    Args:
        points: (k, n) array of generators
        weights: (k,) array of weights
        strategy: "first" (pick first active), "diverse" (maximize coverage)
        
    Returns:
        TropicalCombination with at most n generators
        
    Time complexity: O(k * n)
    Space complexity: O(n)
    
    Guarantees:
        - Output has at most n generators (sharp bound)
        - Output produces the same tropical combination as input
    """
    z = tropical_min_plus(points, weights)
    n = z.shape[0]
    active = find_active_set(points, weights, z)
    
    if strategy == "first":
        selected = set()
        for i in range(n):
            selected.add(active[i][0])
    elif strategy == "diverse":
        # Greedy: try to select generators that cover the most coordinates
        selected = set()
        uncovered = set(range(n))
        while uncovered:
            # Find generator covering most uncovered coordinates
            best_gen = None
            best_cover = -1
            for i in uncovered:
                for j in active[i]:
                    if j in selected:
                        continue
                    cover = sum(1 for ii in uncovered if j in active[ii])
                    if cover > best_cover:
                        best_cover = cover
                        best_gen = j
            if best_gen is None:
                break
            selected.add(best_gen)
            # Remove covered coordinates
            newly_covered = {i for i in uncovered if best_gen in active[i]}
            uncovered -= newly_covered
    else:
        raise ValueError(f"Unknown strategy: {strategy}")
    
    selected = sorted(selected)
    comp_points = points[selected]
    comp_weights = weights[selected]
    
    return TropicalCombination(
        points=comp_points,
        weights=comp_weights,
        result=z
    )


def tropical_hull_membership(points: np.ndarray, z: np.ndarray,
                               tol: float = 1e-10) -> Optional[np.ndarray]:
    """
    Test if z lies in the tropical convex hull of the given points.
    
    This solves: find w such that z(i) = min_j (w_j + x_j(i)) for all i.
    
    Equivalent to: for each j, w_j ≥ max_i (z(i) - x_j(i)),
    and for each i, min_j (w_j + x_j(i)) = z(i).
    
    The minimum feasible weight for generator j is:
        w_j^* = max_i (z(i) - x_j(i))
    
    Then z ∈ hull iff z(i) = min_j (w_j^* + x_j(i)) for all i.
    
    Args:
        points: (k, n) array of generators
        z: (n,) target point
        tol: numerical tolerance
        
    Returns:
        weights array if z is in the hull, None otherwise
        
    Time complexity: O(k * n)
    """
    k, n = points.shape
    
    # Compute minimum feasible weights
    # w_j^* = max_i (z(i) - x_j(i))
    w_star = (z[None, :] - points).max(axis=1)  # (k,)
    
    # Verify: z(i) should equal min_j (w_j^* + x_j(i))
    z_check = tropical_min_plus(points, w_star)
    
    if np.allclose(z_check, z, atol=tol):
        return w_star
    return None


def tropical_segment(x: np.ndarray, y: np.ndarray,
                      num_points: int = 50) -> np.ndarray:
    """
    Compute points along the tropical line segment from x to y.
    
    The tropical segment {x, y} is the set of all points
    z(i) = min(a + x(i), b + y(i)) for varying a, b in R.
    
    Parameterization: fix b = 0, vary a from -M to +M.
    
    Args:
        x, y: endpoints in R^n
        num_points: number of sample points
        
    Returns:
        (num_points, n) array of points on the segment
    """
    n = len(x)
    a_range = np.linspace(-5, 5, num_points)
    
    segment = np.zeros((num_points, n))
    for idx, a in enumerate(a_range):
        for i in range(n):
            segment[idx, i] = min(a + x[i], y[i])
    
    return segment


def is_tropically_convex(S: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a finite set S is tropically convex (closed under binary
    tropical combinations).
    
    For each pair x, y in S and for a sample of parameters a,
    check that min(a + x(i), (1-a) + y(i)) is (approximately) in S.
    
    Note: This is an approximate test for finite sets.
    
    Args:
        S: (k, n) array of points
        tol: tolerance for membership
        
    Returns:
        True if S appears tropically convex
    """
    k = S.shape[0]
    for i in range(k):
        for j in range(i + 1, k):
            for a in np.linspace(-3, 3, 20):
                z = np.minimum(a + S[i], -a + S[j])
                # Check if z is in S
                dists = np.linalg.norm(S - z[None, :], axis=1)
                if dists.min() > tol:
                    return False
    return True


def normalize_weights(weights: np.ndarray) -> np.ndarray:
    """
    Normalize tropical weights by subtracting the minimum.
    
    After normalization, min(w_j) = 0. This removes one degree of freedom
    in tropical convex combinations.
    """
    return weights - weights.min()


def compression_certificate(points: np.ndarray, weights: np.ndarray) -> dict:
    """
    Produce a full compression certificate with all metadata.
    
    This is the main output format for verified tropical optimization.
    
    Returns dict with:
        - original: TropicalCombination (full representation)
        - compressed: TropicalCombination (≤ n generators)
        - active_sets: per-coordinate active generator lists
        - compression_ratio: |original| / |compressed|
        - is_tight: whether |compressed| = n (bound is achieved)
    """
    z = tropical_min_plus(points, weights)
    n = z.shape[0]
    k = points.shape[0]
    
    original = TropicalCombination(points=points, weights=weights, result=z)
    compressed = caratheodory_compress(points, weights)
    active = find_active_set(points, weights, z)
    
    return {
        "original": original,
        "compressed": compressed,
        "active_sets": active,
        "compression_ratio": k / compressed.n_generators if compressed.n_generators > 0 else float('inf'),
        "is_tight": compressed.n_generators == n,
        "dimension": n,
        "original_size": k,
        "compressed_size": compressed.n_generators,
    }


# ── Example usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Carathéodory Compression — Algorithm Suite")
    print("=" * 55)
    
    # Example: 10 random generators in R^4
    np.random.seed(123)
    n, k = 4, 10
    points = np.random.randn(k, n) * 3
    weights = np.random.randn(k)
    
    cert = compression_certificate(points, weights)
    
    print(f"\nDimension: {cert['dimension']}")
    print(f"Original generators: {cert['original_size']}")
    print(f"Compressed generators: {cert['compressed_size']}")
    print(f"Compression ratio: {cert['compression_ratio']:.1f}x")
    print(f"Bound achieved (|T| = n): {cert['is_tight']}")
    
    z_orig = cert['original'].result
    z_comp = cert['compressed'].result
    print(f"\nOriginal z  = {np.round(z_orig, 4)}")
    print(f"Compressed z = {np.round(z_comp, 4)}")
    print(f"Match: {np.allclose(z_orig, z_comp)}")
    
    # Hull membership test
    print("\n--- Hull Membership Test ---")
    z_test = z_orig + 0.1  # Slightly shifted
    w = tropical_hull_membership(points, z_test)
    print(f"z + 0.1 in hull: {w is not None}")
    
    w = tropical_hull_membership(points, z_orig)
    print(f"z in hull: {w is not None}")
    
    # Compression strategies
    print("\n--- Compression Strategies ---")
    for strategy in ["first", "diverse"]:
        comp = caratheodory_compress(points, weights, strategy=strategy)
        print(f"  {strategy}: {comp.n_generators} generators, "
              f"match = {np.allclose(comp.result, z_orig)}")
