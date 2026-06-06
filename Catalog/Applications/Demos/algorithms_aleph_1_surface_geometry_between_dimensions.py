#!/usr/bin/env python3
"""
Algorithms for Transfinite-Dimensional Geometry

Type-hinted implementations of the key algorithms and computations
from the Aleph-1 Surface theory.
"""

from typing import List, Tuple, Optional, Callable
import math


def arctan_embedding(x: float) -> float:
    """
    The arctan embedding: ℝ → [0, 1].
    
    Maps x ↦ arctan(x)/π + 1/2.
    
    This is the coordinate-wise function used to embed ℝ^I into [0,1]^I
    (the generalized Hilbert cube). It is:
    - Injective (since arctan is strictly monotone)
    - Continuous
    - Maps ℝ onto (0, 1) ⊂ [0, 1]
    
    Complexity: O(1)
    """
    return math.atan(x) / math.pi + 0.5


def arctan_embedding_inverse(y: float) -> float:
    """
    Inverse of the arctan embedding: (0, 1) → ℝ.
    
    Maps y ↦ tan(π(y - 1/2)).
    
    Only defined for y ∈ (0, 1).
    
    Complexity: O(1)
    """
    if y <= 0 or y >= 1:
        raise ValueError(f"y = {y} must be in (0, 1)")
    return math.tan(math.pi * (y - 0.5))


def coordinate_wise_embed(point: List[float]) -> List[float]:
    """
    Apply the arctan embedding coordinate-wise.
    
    This is the finite-dimensional analog of the embedding
    ℝ^I → [0,1]^I from Theorem 5.1.
    
    Args:
        point: A point in ℝⁿ (list of n real coordinates)
    
    Returns:
        The embedded point in [0,1]ⁿ
    
    Complexity: O(n) where n = len(point)
    """
    return [arctan_embedding(x) for x in point]


def projection(point: List[float], target_dim: int) -> List[float]:
    """
    Project a high-dimensional point to its first target_dim coordinates.
    
    This is the finite analog of the projection ℝ^{ℵ₁} → ℝⁿ.
    By Theorem 4.1, such projections cannot be injective when
    the source dimension is ℵ₁ (under CH).
    
    Args:
        point: A point in ℝⁿ
        target_dim: Number of coordinates to keep
    
    Returns:
        The projected point (first target_dim coordinates)
    
    Complexity: O(target_dim)
    """
    return point[:target_dim]


def collision_count(
    points: List[List[float]], 
    target_dim: int
) -> Tuple[int, int]:
    """
    Count how many points collide after projection.
    
    Returns (original_distinct, projected_distinct).
    The difference measures information loss.
    
    Complexity: O(n * d) where n = #points, d = target_dim
    """
    original = set(tuple(p) for p in points)
    projected = set(tuple(p[:target_dim]) for p in points)
    return len(original), len(projected)


def cardinal_hierarchy(n_levels: int = 7) -> List[dict]:
    """
    Generate the cardinal hierarchy for display.
    
    Returns a list of dictionaries describing each aleph number,
    its relationship to the continuum hypothesis, and its role
    in the dimension theory.
    
    Args:
        n_levels: Number of aleph numbers to generate
    
    Returns:
        List of cardinal level descriptions
    """
    levels = []
    for i in range(n_levels):
        level: dict = {
            "symbol": f"ℵ_{i}",
            "ordinal_index": i,
            "description": "",
            "ch_value": "",
            "embeddable_in_Rn": None,
        }
        
        if i == 0:
            level["description"] = "Countably infinite"
            level["ch_value"] = "ℵ₀"
            level["embeddable_in_Rn"] = True
        elif i == 1:
            level["description"] = "First uncountable"
            level["ch_value"] = "𝔠 = 2^ℵ₀ (under CH)"
            level["embeddable_in_Rn"] = False
        else:
            level["description"] = f"ℵ_{i}"
            level["ch_value"] = f"2^ℵ_{i-1} (under GCH)"
            level["embeddable_in_Rn"] = False
        
        levels.append(level)
    
    return levels


def dimension_gap_check(candidates: List[int]) -> List[bool]:
    """
    Check if candidate values fall in the "dimension gap."
    
    In the finite analog: check if values are strictly between
    two consecutive Fibonacci-like growth levels.
    
    The mathematical theorem (Cantor Dimension Gap) says:
    No cardinal κ exists with ℵ₀ < κ < ℵ₁.
    
    Args:
        candidates: List of candidate cardinal sizes
    
    Returns:
        List of booleans: True if the candidate is in a "gap"
    """
    # In finite analog: gaps are between consecutive powers of 2
    # (mimicking 2^ℵ₀, 2^ℵ₁, etc.)
    powers = [2**i for i in range(20)]
    gaps = []
    for c in candidates:
        in_gap = any(powers[i] < c < powers[i+1] and c not in powers 
                     for i in range(len(powers)-1))
        gaps.append(in_gap)
    return gaps


def triangulation_vertex_lower_bound(
    space_cardinality: int,
    simplex_dim: int
) -> int:
    """
    Compute the minimum number of vertices needed to triangulate
    a space of given cardinality.
    
    By the triangulation vertex bound theorem:
    #vertices ≥ #space (since the cover must be surjective)
    
    For finite spaces, this gives a concrete computable bound.
    For transfinite spaces (ℵ₁-surface), the bound is:
    #vertices > ℵ₁ (under CH)
    
    Args:
        space_cardinality: Number of points in the space
        simplex_dim: Maximum dimension of simplices used
    
    Returns:
        Minimum number of vertices required
    """
    # The surjectivity bound: at least as many vertices as points
    return space_cardinality


def verify_embedding_injectivity(
    embed: Callable[[float], float],
    test_points: List[float]
) -> bool:
    """
    Numerically verify that an embedding function is injective
    on a set of test points.
    
    Args:
        embed: The embedding function ℝ → [0,1]
        test_points: Points to test
    
    Returns:
        True if all test points map to distinct values
    """
    images = [embed(x) for x in test_points]
    return len(set(images)) == len(images)


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("ALGORITHMS FOR TRANSFINITE-DIMENSIONAL GEOMETRY")
    print("=" * 50)
    
    # Test arctan embedding
    print("\n1. Arctan Embedding")
    test_vals = [-100, -10, -1, 0, 1, 10, 100]
    for x in test_vals:
        y = arctan_embedding(x)
        x_back = arctan_embedding_inverse(y)
        print(f"  x={x:>6}, embed={y:.6f}, inverse={x_back:.4f}")
    
    # Test injectivity
    print(f"\n  Injectivity verified: {verify_embedding_injectivity(arctan_embedding, test_vals)}")
    
    # Test projection collision
    print("\n2. Projection Collision Rates")
    import random
    random.seed(42)
    points = [[random.uniform(-10, 10) for _ in range(20)] for _ in range(500)]
    for d in [1, 2, 5, 10, 15]:
        orig, proj = collision_count(points, d)
        print(f"  R^20 → R^{d}: {orig} distinct → {proj} distinct ({100*(1-proj/orig):.1f}% collision)")
    
    # Cardinal hierarchy
    print("\n3. Cardinal Hierarchy")
    for level in cardinal_hierarchy(5):
        embeddable = "✓" if level["embeddable_in_Rn"] else "✗"
        print(f"  {level['symbol']}: {level['description']} [{embeddable} embeddable in Rⁿ]")
