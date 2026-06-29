#!/usr/bin/env python3
"""
Tropical Shadow Duality — Algorithms
=====================================

Implements the core algorithms from the research paper:

1. QuadraticLeafShadow — O(|S| · n²) computation of the shadow
2. ShadowPolytopeGenerators — Certified generator extraction
3. ShadowSupportFunction — O(|shadow| · n) support function evaluation
4. ConvexHull — Graham scan for 2D polytope vertices

These algorithms enable certified extraction of Hessian Newton geometry
without coefficient-level Hessian expansion.
"""

from typing import Set, Tuple, Dict, List, Optional
import numpy as np


# Type aliases
ExponentVector = Tuple[int, ...]
Polynomial = Dict[ExponentVector, float]


def quad_leaf_shadow(
    support: Set[ExponentVector],
    i: int,
    j: int,
    n_vars: int
) -> Set[ExponentVector]:
    """
    Compute the quadratic leaf shadow for variable pair (i, j).

    The shadow is {β : β + eᵢ + eⱼ ∈ S}, where S is the support set.
    This predicts exactly which monomials appear in ∂ᵢ∂ⱼp.

    Parameters
    ----------
    support : set of tuples
        The support S = {exponent vectors with nonzero coefficient}
    i : int
        First differentiation variable index
    j : int
        Second differentiation variable index
    n_vars : int
        Total number of variables

    Returns
    -------
    set of tuples
        The quadratic leaf shadow Sh(S, i, j)

    Complexity
    ----------
    Time: O(|S|) — single pass over support
    Space: O(|shadow|)

    Examples
    --------
    >>> S = {(2, 1), (1, 2), (3, 0), (0, 3)}
    >>> quad_leaf_shadow(S, 0, 1, 2)
    {(1, 0), (0, 1)}
    """
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def compute_shadow_polytope_generators(
    support: Set[ExponentVector],
    i: int,
    j: int,
    n_vars: int
) -> Set[ExponentVector]:
    """
    Compute the shadow polytope generators.

    This is the algorithmic heart: certified extraction of Hessian Newton
    geometry from support data alone, without computing any coefficients.

    Parameters
    ----------
    support : set of tuples
        Support of the polynomial
    i, j : int
        Variable indices
    n_vars : int
        Number of variables

    Returns
    -------
    set of tuples
        Generators of the shadow polytope (= quadratic leaf shadow)

    Correctness
    -----------
    By Theorem 1 (Shadow Duality Principle), these generators produce
    exactly the Newton polytope of ∂ᵢ∂ⱼp when p has generic coefficients.
    """
    return quad_leaf_shadow(support, i, j, n_vars)


def shadow_support_function(
    support: Set[ExponentVector],
    i: int,
    j: int,
    w: np.ndarray
) -> float:
    """
    Evaluate the shadow support function: max ⟨w, α⟩ over shadow generators.

    By Theorem 3 (Tropical-Algebraic Bridge), this equals the support function
    of the Newton polytope of ∂ᵢ∂ⱼp.

    Parameters
    ----------
    support : set of tuples
        Support of the polynomial
    i, j : int
        Variable indices
    w : np.ndarray
        Weight vector of shape (n_vars,)

    Returns
    -------
    float
        max_{α ∈ shadow} ⟨w, α⟩

    Complexity
    ----------
    Time: O(|shadow| · n)
    """
    n_vars = len(w)
    shadow = quad_leaf_shadow(support, i, j, n_vars)
    if not shadow:
        return float('-inf')
    return max(np.dot(w, np.array(alpha)) for alpha in shadow)


def full_shadow_analysis(
    support: Set[ExponentVector],
    n_vars: int
) -> Dict[Tuple[int, int], Set[ExponentVector]]:
    """
    Compute the full shadow analysis for all variable pairs.

    Parameters
    ----------
    support : set of tuples
        Support of the polynomial
    n_vars : int
        Number of variables

    Returns
    -------
    dict
        Maps (i, j) to the quadratic leaf shadow

    Complexity
    ----------
    Time: O(n² · |S|)
    """
    result = {}
    for i in range(n_vars):
        for j in range(n_vars):
            result[(i, j)] = quad_leaf_shadow(support, i, j, n_vars)
    return result


def convex_hull_2d(points: List[Tuple[float, ...]]) -> List[Tuple[float, ...]]:
    """
    Compute 2D convex hull using Graham scan.

    Parameters
    ----------
    points : list of 2-tuples
        Points in ℝ²

    Returns
    -------
    list of 2-tuples
        Vertices of the convex hull in counterclockwise order

    Complexity
    ----------
    Time: O(n log n)
    """
    if len(points) <= 2:
        return list(set(points))

    points = sorted(set(points))

    def cross(O, A, B):
        return (A[0] - O[0]) * (B[1] - O[1]) - (A[1] - O[1]) * (B[0] - O[0])

    lower = []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    upper = []
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


def hessian_shadow_complexity(
    support: Set[ExponentVector],
    n_vars: int
) -> int:
    """
    Compute the Hessian shadow complexity: total number of distinct
    shadow exponents across all variable pairs.

    This provides a combinatorial lower bound on the total number of
    nonzero Hessian entries.

    Parameters
    ----------
    support : set of tuples
    n_vars : int

    Returns
    -------
    int
        |⋃_{i,j} Sh(S, i, j)|
    """
    all_shadows = set()
    for i in range(n_vars):
        for j in range(n_vars):
            all_shadows |= quad_leaf_shadow(support, i, j, n_vars)
    return len(all_shadows)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example: p = x³ + 3x²y + 2xy² + y³ in 2 variables
    support = {(3, 0), (2, 1), (1, 2), (0, 3)}
    n_vars = 2

    print("Support:", sorted(support))
    print()

    shadows = full_shadow_analysis(support, n_vars)
    for (i, j), shadow in sorted(shadows.items()):
        print(f"  Shadow(i={i}, j={j}): {sorted(shadow)}")

    print()
    print(f"  Hessian shadow complexity: {hessian_shadow_complexity(support, n_vars)}")

    # Support function evaluation
    w = np.array([1.0, 0.5])
    for (i, j) in [(0, 0), (0, 1), (1, 1)]:
        sf = shadow_support_function(support, i, j, w)
        print(f"  h_shadow(w, i={i}, j={j}) = {sf}")
