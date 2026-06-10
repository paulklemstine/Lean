"""
algorithms.py — Newton Polytope Erosion and Quadratic Shadow Algorithms

Implements the core computational methods for:
1. Computing the quadratic shadow of a finite support set
2. Computing Newton polytope convex hull
3. Computing Minkowski erosion lattice points
4. Comparing shadow and erosion
"""

from itertools import combinations_with_replacement
from typing import Set, FrozenSet, Tuple, List, Optional
import numpy as np


def quadratic_increments(n: int) -> List[tuple]:
    """
    Generate all β ∈ ℕⁿ with ∑βᵢ = 2.
    These are: 2eᵢ for each i, and eᵢ + eⱼ for each i ≤ j.

    Args:
        n: dimension

    Returns:
        List of n-tuples representing all degree-2 increments.

    >>> sorted(quadratic_increments(2))
    [(0, 2), (1, 1), (2, 0)]
    """
    result = []
    for i in range(n):
        beta = [0] * n
        beta[i] = 2
        result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n
            beta[i] = 1
            beta[j] = 1
            result.append(tuple(beta))
    return result


def discrete_quad_shadow(S: Set[tuple], n: int) -> Set[tuple]:
    """
    Compute the discrete (existential) quadratic shadow of S.
    Sh₂(S) = {u | ∃ β with ∑βᵢ = 2 and u + β ∈ S}

    Args:
        S: finite support set as set of n-tuples
        n: dimension

    Returns:
        The quadratic shadow as a set of tuples.

    >>> S = {(0,), (1,), (2,), (3,)}
    >>> sorted(discrete_quad_shadow(S, 1))
    [(0,), (1,)]
    """
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u):
                shadow.add(u)
    return shadow


def universal_quad_shadow(S: Set[tuple], n: int) -> Set[tuple]:
    """
    Compute the universal quadratic shadow of S.
    USh₂(S) = {u | ∀ β with ∑βᵢ = 2, u + β ∈ S}

    Args:
        S: finite support set as set of n-tuples
        n: dimension

    Returns:
        The universal quadratic shadow as a set of tuples.

    >>> S = {(2,), (3,), (4,)}
    >>> sorted(universal_quad_shadow(S, 1))
    [(2,)]
    """
    increments = quadratic_increments(n)
    # Candidates: points that could possibly be in the shadow
    # u + β ∈ S for all β, so u ∈ S - β for each β
    candidates = None
    for beta in increments:
        shifted = set()
        for alpha in S:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u):
                shifted.add(u)
        if candidates is None:
            candidates = shifted
        else:
            candidates &= shifted
    return candidates if candidates is not None else set()


def convex_hull_points(points: np.ndarray) -> np.ndarray:
    """
    Compute the convex hull vertices of a set of points.

    Args:
        points: (m, n) array of points

    Returns:
        Vertices of the convex hull.
    """
    from scipy.spatial import ConvexHull
    if len(points) <= 1:
        return points
    try:
        hull = ConvexHull(points)
        return points[hull.vertices]
    except Exception:
        return points


def newton_polytope_vertices(S: Set[tuple]) -> np.ndarray:
    """
    Compute the Newton polytope vertices (convex hull of support points).

    Args:
        S: finite support set

    Returns:
        Array of vertices of the Newton polytope.
    """
    points = np.array(list(S), dtype=float)
    return convex_hull_points(points)


def point_in_convex_hull(point: np.ndarray, hull_points: np.ndarray) -> bool:
    """
    Check if a point lies in the convex hull of given points.
    Uses linear programming.

    Args:
        point: test point
        hull_points: vertices of the convex hull

    Returns:
        True if point is in the convex hull.
    """
    from scipy.optimize import linprog
    m = hull_points.shape[0]
    n = hull_points.shape[1]

    # We need: ∑ λᵢ pᵢ = point, ∑ λᵢ = 1, λᵢ ≥ 0
    # This is a feasibility LP
    A_eq = np.vstack([hull_points.T, np.ones(m)])
    b_eq = np.append(point, 1.0)
    c = np.zeros(m)
    bounds = [(0, None)] * m

    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')
    return result.success


def eroded_newton_lattice_points(S: Set[tuple], n: int) -> Set[tuple]:
    """
    Compute lattice points of Newt(S) ⊖ Δ₂.
    A point u is in the erosion iff for all β ∈ quadSimplexReal(n),
    u + β ∈ Newt(S).

    Since quadSimplexReal is the convex hull of the discrete quadratic
    simplex vertices, it suffices to check u + β for all discrete β.

    Args:
        S: finite support set
        n: dimension

    Returns:
        Set of lattice points in the eroded Newton polytope.
    """
    if not S:
        return set()

    points = np.array(list(S), dtype=float)
    increments = quadratic_increments(n)

    # Get bounding box for candidates
    min_coords = np.min(points, axis=0).astype(int)
    max_coords = np.max(points, axis=0).astype(int)

    # u must satisfy u + β ∈ Newt(S) for all β in quadSimplexReal
    # Since quadSimplexReal = conv(embed(quadSimplex)), by convexity
    # it suffices to check u + embed(β) ∈ Newt(S) for all discrete β
    result = set()
    from itertools import product
    ranges = [range(max(0, int(min_coords[i])), int(max_coords[i]) + 1) for i in range(n)]
    for u_tuple in product(*ranges):
        u = np.array(u_tuple, dtype=float)
        all_in = True
        for beta in increments:
            shifted = u + np.array(beta, dtype=float)
            if not point_in_convex_hull(shifted, points):
                all_in = False
                break
        if all_in:
            result.add(u_tuple)

    return result


def compare_shadow_and_erosion(S: Set[tuple], n: int) -> dict:
    """
    Compare the universal quadratic shadow with eroded Newton lattice points.

    Args:
        S: finite support set
        n: dimension

    Returns:
        Dictionary with comparison results.
    """
    shadow = universal_quad_shadow(S, n)
    erosion = eroded_newton_lattice_points(S, n)

    return {
        'shadow': shadow,
        'erosion': erosion,
        'shadow_size': len(shadow),
        'erosion_size': len(erosion),
        'equal': shadow == erosion,
        'shadow_minus_erosion': shadow - erosion,
        'erosion_minus_shadow': erosion - shadow,
    }


def is_lattice_saturated(S: Set[tuple], n: int) -> bool:
    """
    Check if S is lattice-saturated (contains all integer points of its Newton polytope).

    Args:
        S: finite support set
        n: dimension

    Returns:
        True if S is lattice-saturated.
    """
    if not S:
        return True

    points = np.array(list(S), dtype=float)
    min_coords = np.min(points, axis=0).astype(int)
    max_coords = np.max(points, axis=0).astype(int)

    from itertools import product
    ranges = [range(int(min_coords[i]), int(max_coords[i]) + 1) for i in range(n)]
    for u_tuple in product(*ranges):
        if u_tuple not in S:
            u = np.array(u_tuple, dtype=float)
            if point_in_convex_hull(u, points):
                return False
    return True


if __name__ == '__main__':
    # Example: 2D support
    print("=== 2D Example ===")
    S = {(0, 0), (2, 0), (0, 2), (1, 1)}
    n = 2
    print(f"Support S = {sorted(S)}")
    print(f"Is lattice-saturated: {is_lattice_saturated(S, n)}")

    result = compare_shadow_and_erosion(S, n)
    print(f"Universal shadow = {sorted(result['shadow'])}")
    print(f"Erosion lattice  = {sorted(result['erosion'])}")
    print(f"Equal: {result['equal']}")

    print("\n=== Sparse 2D Example (not saturated) ===")
    S_sparse = {(0, 0), (2, 0), (0, 2)}  # missing (1,1)
    print(f"Support S = {sorted(S_sparse)}")
    print(f"Is lattice-saturated: {is_lattice_saturated(S_sparse, n)}")
    result2 = compare_shadow_and_erosion(S_sparse, n)
    print(f"Universal shadow = {sorted(result2['shadow'])}")
    print(f"Erosion lattice  = {sorted(result2['erosion'])}")
    print(f"Equal: {result2['equal']}")
    if result2['erosion_minus_shadow']:
        print(f"Gap (erosion \\ shadow) = {result2['erosion_minus_shadow']}")
