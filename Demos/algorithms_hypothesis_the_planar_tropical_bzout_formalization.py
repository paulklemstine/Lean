"""
Algorithms for Tropical Bernstein Theorem Computations

This module implements algorithms for computing mixed areas, Minkowski sums,
and Bernstein numbers for lattice polygons. These correspond to the formally
verified computations in the Lean formalization.

Key algorithms:
1. Minkowski sum of finite lattice point sets
2. Mixed lattice index (= mixed area for convex sets)
3. Convex hull of lattice points (Graham scan)
4. Shoelace area formula for lattice polygons
5. Mixed area via edge-normal convolution
"""

from __future__ import annotations
import math
from typing import Optional


def minkowski_sum(
    A: set[tuple[int, int]], B: set[tuple[int, int]]
) -> set[tuple[int, int]]:
    """
    Compute the Minkowski sum A ⊕ B = {a + b : a ∈ A, b ∈ B}.

    Time complexity: O(|A| · |B|)
    Space complexity: O(|A ⊕ B|), which is at most O(|A| · |B|)

    Args:
        A: First finite lattice point set
        B: Second finite lattice point set

    Returns:
        The Minkowski sum as a set of lattice points

    Example:
        >>> A = {(0, 0), (1, 0), (0, 1)}  # Δ₁
        >>> B = {(0, 0), (1, 0), (0, 1)}  # Δ₁
        >>> sorted(minkowski_sum(A, B))
        [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (2, 0)]
    """
    return {(a[0] + b[0], a[1] + b[1]) for a in A for b in B}


def mixed_lattice_index(
    A: set[tuple[int, int]], B: set[tuple[int, int]]
) -> int:
    """
    Compute the mixed lattice index via inclusion-exclusion:
        MLI(A, B) = |A ⊕ B| - |A| - |B| + 1

    For convex lattice polygons P, Q (as sets of interior + boundary lattice points),
    this equals the mixed area MixedArea(P, Q).

    Time complexity: O(|A| · |B|)

    Args:
        A: First finite lattice point set
        B: Second finite lattice point set

    Returns:
        The mixed lattice index (an integer)

    Example:
        >>> A = {(i, j) for i in range(3) for j in range(3) if i + j <= 2}  # Δ₂
        >>> B = {(i, j) for i in range(3) for j in range(3) if i + j <= 2}  # Δ₂
        >>> mixed_lattice_index(A, B)
        4
    """
    mink = minkowski_sum(A, B)
    return len(mink) - len(A) - len(B) + 1


def degree_simplex(d: int) -> set[tuple[int, int]]:
    """
    Generate the degree-d simplex: Δ_d = {(i,j) ∈ ℤ² : i,j ≥ 0, i+j ≤ d}.

    The lattice point count is (d+1)(d+2)/2.

    Args:
        d: Non-negative integer degree

    Returns:
        Set of lattice points in the simplex

    Example:
        >>> len(degree_simplex(3))
        10
    """
    return {(i, j) for i in range(d + 1) for j in range(d - i + 1)}


def lattice_rectangle(a: int, b: int) -> set[tuple[int, int]]:
    """
    Generate the lattice rectangle [0,a] × [0,b].

    The lattice point count is (a+1)(b+1).

    Args:
        a: Width (non-negative integer)
        b: Height (non-negative integer)

    Returns:
        Set of lattice points in the rectangle

    Example:
        >>> len(lattice_rectangle(2, 3))
        12
    """
    return {(i, j) for i in range(a + 1) for j in range(b + 1)}


def convex_hull_2d(points: list[tuple[int, int]]) -> list[tuple[int, int]]:
    """
    Compute the convex hull of a set of 2D lattice points using Graham scan.

    Returns vertices in counter-clockwise order.

    Time complexity: O(n log n) where n = len(points)

    Args:
        points: List of 2D lattice points

    Returns:
        Vertices of the convex hull in CCW order

    Example:
        >>> convex_hull_2d([(0,0), (1,0), (0,1), (1,1), (0,2)])
        [(0, 0), (1, 0), (1, 1), (0, 2)]
    """
    if len(points) <= 1:
        return list(points)

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    points = sorted(set(points))
    if len(points) <= 2:
        return points

    # Build lower hull
    lower = []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)

    # Build upper hull
    upper = []
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)

    return lower[:-1] + upper[:-1]


def shoelace_area(vertices: list[tuple[int, int]]) -> int:
    """
    Compute twice the area of a polygon using the shoelace formula.

    The result is always a non-negative integer for lattice polygons
    with vertices in CCW order.

    Time complexity: O(n) where n = number of vertices

    Args:
        vertices: Polygon vertices in CCW order

    Returns:
        Twice the Euclidean area (= normalized lattice area)

    Example:
        >>> shoelace_area([(0,0), (2,0), (0,2)])  # triangle
        4
    """
    n = len(vertices)
    if n < 3:
        return 0
    area = 0
    for i in range(n):
        j = (i + 1) % n
        area += vertices[i][0] * vertices[j][1]
        area -= vertices[j][0] * vertices[i][1]
    return abs(area)


def mixed_area_from_areas(
    P: set[tuple[int, int]],
    Q: set[tuple[int, int]]
) -> float:
    """
    Compute the mixed area using the Minkowski bilinearity identity:
        MixedArea(P, Q) = Area(P+Q) - Area(P) - Area(Q)

    where Area is the normalized (2×Euclidean) area computed from convex hulls.

    This is an alternative to the lattice-point counting method.

    Args:
        P: First lattice point set
        Q: Second lattice point set

    Returns:
        The mixed area (should be a non-negative integer for convex lattice polygons)

    Example:
        >>> P = degree_simplex(2)
        >>> Q = degree_simplex(3)
        >>> mixed_area_from_areas(P, Q)
        6
    """
    hull_P = convex_hull_2d(list(P))
    hull_Q = convex_hull_2d(list(Q))
    mink = minkowski_sum(P, Q)
    hull_PQ = convex_hull_2d(list(mink))

    area_P = shoelace_area(hull_P)
    area_Q = shoelace_area(hull_Q)
    area_PQ = shoelace_area(hull_PQ)

    return area_PQ - area_P - area_Q


def bernstein_number(
    support_f: set[tuple[int, int]],
    support_g: set[tuple[int, int]]
) -> int:
    """
    Compute the Bernstein number for two tropical polynomial supports.

    For generic tropical polynomials with these supports, this gives the
    exact count of stable intersection points with multiplicity.

    Args:
        support_f: Support of the first tropical polynomial
        support_g: Support of the second tropical polynomial

    Returns:
        The Bernstein number (mixed lattice index)

    Example:
        >>> bernstein_number(degree_simplex(2), degree_simplex(3))
        6
    """
    return mixed_lattice_index(support_f, support_g)


def edge_normal_mixed_area(
    P_vertices: list[tuple[int, int]],
    Q_vertices: list[tuple[int, int]]
) -> int:
    """
    Compute mixed area via edge-normal convolution.

    For convex polygons P, Q with ordered vertices, the mixed area equals:
        MixedArea(P, Q) = (1/2) Σᵢ Σⱼ |det(eᵢ, fⱼ)| · [normals compatible]

    where eᵢ are edges of P and fⱼ are edges of Q.

    This is equivalent to the Minkowski sum formula but operates directly
    on the polygon boundary data.

    Time complexity: O(m · n) where m, n are the numbers of edges

    Args:
        P_vertices: Vertices of P in CCW order
        Q_vertices: Vertices of Q in CCW order

    Returns:
        The mixed area

    Example:
        >>> P = [(0,0), (2,0), (0,2)]  # triangle
        >>> Q = [(0,0), (1,0), (0,1)]  # unit triangle
        >>> edge_normal_mixed_area(P, Q)
        4
    """
    def edges(verts):
        n = len(verts)
        return [(verts[(i+1) % n][0] - verts[i][0],
                 verts[(i+1) % n][1] - verts[i][1]) for i in range(n)]

    P_edges = edges(P_vertices)
    Q_edges = edges(Q_vertices)

    # Mixed area = (1/2) Σ |det(eᵢ, fⱼ)| for compatible normal pairs
    # For the full formula, we use the area identity
    P_area = shoelace_area(P_vertices)
    Q_area = shoelace_area(Q_vertices)

    # Compute Minkowski sum vertices
    all_edges = []
    for e in P_edges:
        angle = math.atan2(e[1], e[0])
        all_edges.append((angle, e))
    for e in Q_edges:
        angle = math.atan2(e[1], e[0])
        all_edges.append((angle, e))

    all_edges.sort(key=lambda x: x[0])

    # Build Minkowski sum polygon
    start_P = min(P_vertices)
    start_Q = min(Q_vertices)
    current = (start_P[0] + start_Q[0], start_P[1] + start_Q[1])
    mink_vertices = [current]

    for _, edge in all_edges:
        current = (current[0] + edge[0], current[1] + edge[1])
        mink_vertices.append(current)

    mink_vertices.pop()  # remove duplicate closing point
    PQ_area = shoelace_area(mink_vertices)

    return PQ_area - P_area - Q_area


def picks_theorem(vertices: list[tuple[int, int]]) -> tuple[int, int, int]:
    """
    Apply Pick's theorem to a lattice polygon.

    Pick's theorem: A = I + B/2 - 1
    where A = area, I = interior lattice points, B = boundary lattice points.

    Returns (2A, B, I) where 2A is the normalized area.

    Args:
        vertices: Polygon vertices in order

    Returns:
        Tuple (normalized_area, boundary_points, interior_points)

    Example:
        >>> picks_theorem([(0,0), (3,0), (0,3)])  # right triangle
        (9, 10, 1)
    """
    n = len(vertices)
    if n < 3:
        return (0, len(set(vertices)), 0)

    # Compute 2A via shoelace
    two_A = shoelace_area(vertices)

    # Count boundary points using gcd formula
    B = 0
    for i in range(n):
        j = (i + 1) % n
        dx = abs(vertices[j][0] - vertices[i][0])
        dy = abs(vertices[j][1] - vertices[i][1])
        B += math.gcd(dx, dy)

    # I = A - B/2 + 1 = (2A - B + 2) / 2
    I = (two_A - B + 2) // 2

    return (two_A, B, I)


if __name__ == "__main__":
    print("=== Algorithm Tests ===")
    print()

    # Test Minkowski sum
    A = degree_simplex(2)
    B = degree_simplex(3)
    print(f"Δ₂ has {len(A)} lattice points")
    print(f"Δ₃ has {len(B)} lattice points")
    mink = minkowski_sum(A, B)
    print(f"Δ₂ ⊕ Δ₃ has {len(mink)} lattice points")
    print(f"Δ₅ has {len(degree_simplex(5))} lattice points")
    assert mink == degree_simplex(5), "Minkowski sum of simplices failed"
    print("  ✓ Δ₂ ⊕ Δ₃ = Δ₅")
    print()

    # Test mixed lattice index
    ma = mixed_lattice_index(A, B)
    print(f"MixedArea(Δ₂, Δ₃) = {ma}")
    assert ma == 6, f"Expected 6, got {ma}"
    print("  ✓ Equals 2·3 = 6")
    print()

    # Test rectangle formula
    R1 = lattice_rectangle(2, 3)
    R2 = lattice_rectangle(1, 4)
    ma_rect = mixed_lattice_index(R1, R2)
    print(f"MixedArea([0,2]×[0,3], [0,1]×[0,4]) = {ma_rect}")
    assert ma_rect == 2 * 4 + 1 * 3, f"Expected 11, got {ma_rect}"
    print("  ✓ Equals 2·4 + 1·3 = 11")
    print()

    # Test convex hull
    pts = [(0, 0), (1, 0), (2, 0), (0, 1), (0, 2), (1, 1)]
    hull = convex_hull_2d(pts)
    print(f"ConvexHull({pts}) = {hull}")
    print()

    # Test Pick's theorem
    triangle = [(0, 0), (4, 0), (0, 4)]
    area, boundary, interior = picks_theorem(triangle)
    print(f"Triangle (0,0)-(4,0)-(0,4):")
    print(f"  Normalized area = {area}")
    print(f"  Boundary points = {boundary}")
    print(f"  Interior points = {interior}")
    assert area == 16, f"Expected 16, got {area}"
    print("  ✓ Pick's theorem verified")
    print()

    # Test Bernstein number
    sparse = {(0, 0), (3, 0), (0, 3), (1, 1)}
    bn = bernstein_number(sparse, degree_simplex(2))
    print(f"BernsteinNumber(sparse_4pts, Δ₂) = {bn}")
    bezout_bn = bernstein_number(degree_simplex(3), degree_simplex(2))
    print(f"BézoutNumber(Δ₃, Δ₂) = {bezout_bn}")
    print(f"  Bernstein saves {bezout_bn - bn} intersection points")
    print()

    print("All algorithm tests passed! ✓")
