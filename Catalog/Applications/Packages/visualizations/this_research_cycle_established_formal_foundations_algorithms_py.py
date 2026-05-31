"""
Cup-Cap Number and Erdős–Szekeres Algorithms

Type-hinted implementations of:
1. CupCapNumber computation via binomial coefficients
2. Cup/cap finding in point sets via dynamic programming
3. Convex layer decomposition (onion peeling)
4. Orientation and general position testing
"""

from math import comb
from typing import Optional


def cup_cap_number(j: int, k: int) -> int:
    """Compute CC(j,k) = C(j+k-4, j-2) + 1 for j,k >= 2.

    The Cup-Cap number is the threshold for the Erdős–Szekeres cup-cap theorem:
    any CC(j,k) x-sorted points in general position contain a j-cup or k-cap.

    Args:
        j: Cup size parameter (>= 2)
        k: Cap size parameter (>= 2)

    Returns:
        The cup-cap number CC(j,k), or 0 if j < 2 or k < 2.
    """
    if j < 2 or k < 2:
        return 0
    return comb(j + k - 4, j - 2) + 1


def es_upper_bound(n: int) -> int:
    """Compute the classical Erdős–Szekeres upper bound for ES(n).

    ES(n) <= CC(n,n) = C(2n-4, n-2) + 1.

    Args:
        n: Number of points in convex position to guarantee (>= 2)

    Returns:
        The upper bound C(2n-4, n-2) + 1.
    """
    if n < 2:
        return 0
    return comb(2 * n - 4, n - 2) + 1


def orient(a: tuple[float, float], b: tuple[float, float],
           c: tuple[float, float]) -> float:
    """Compute the orientation (signed area × 2) of three points.

    Positive = counterclockwise, negative = clockwise, zero = collinear.

    Args:
        a, b, c: Points as (x, y) tuples.

    Returns:
        The orientation value.
    """
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def is_general_position(points: list[tuple[float, float]],
                        eps: float = 1e-10) -> bool:
    """Check if points are in general position (no three collinear).

    Args:
        points: List of (x, y) points.
        eps: Tolerance for collinearity detection.

    Returns:
        True if no three points are collinear.
    """
    n = len(points)
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                if abs(orient(points[i], points[j], points[k])) < eps:
                    return False
    return True


def find_longest_cup(points: list[tuple[float, float]]) -> list[int]:
    """Find the longest cup (concave-up chain) in x-sorted points.

    Uses dynamic programming: for each point, track the longest cup ending there.

    Args:
        points: List of (x, y) points, assumed to be x-sorted.

    Returns:
        List of indices forming the longest cup.
    """
    n = len(points)
    if n <= 2:
        return list(range(n))

    # dp[i] = (length, prev_index) of longest cup ending at point i
    dp: list[tuple[int, int]] = [(1, -1) for _ in range(n)]

    # For pairs: any 2 points form a cup of length 2
    for i in range(n):
        for j in range(i + 1, n):
            dp[j] = max(dp[j], (2, i))

    # For triples and beyond
    for j in range(2, n):
        for i in range(1, j):
            if dp[i][0] >= 2:
                # Check if we can extend the cup ending at i with j
                # We need the last triple to have positive orientation
                # Find the predecessor of i
                pred_i = dp[i][1]
                if pred_i >= 0:
                    o = orient(points[pred_i], points[i], points[j])
                    if o > 0:
                        new_len = dp[i][0] + 1
                        if new_len > dp[j][0]:
                            dp[j] = (new_len, i)

    # Find the best ending point
    best_end = max(range(n), key=lambda i: dp[i][0])
    best_len = dp[best_end][0]

    # Reconstruct the path
    path: list[int] = []
    idx = best_end
    while idx >= 0:
        path.append(idx)
        idx = dp[idx][1]
    path.reverse()

    return path


def find_longest_cap(points: list[tuple[float, float]]) -> list[int]:
    """Find the longest cap (concave-down chain) in x-sorted points.

    Uses dynamic programming, symmetric to find_longest_cup.

    Args:
        points: List of (x, y) points, assumed to be x-sorted.

    Returns:
        List of indices forming the longest cap.
    """
    # Reflect y-coordinates and find longest cup
    reflected = [(x, -y) for (x, y) in points]
    return find_longest_cup(reflected)


def convex_layer_decomposition(
    points: list[tuple[float, float]]
) -> list[list[int]]:
    """Compute the convex layer decomposition (onion peeling) of a point set.

    Iteratively computes the convex hull of the remaining points and removes
    hull vertices, creating nested layers.

    Args:
        points: List of (x, y) points.

    Returns:
        List of layers, each a list of point indices. Layer 0 is outermost.
    """
    n = len(points)
    remaining = set(range(n))
    layers: list[list[int]] = []

    while remaining:
        if len(remaining) <= 2:
            layers.append(sorted(remaining))
            break

        # Compute convex hull of remaining points (Graham scan)
        hull_indices = _convex_hull([points[i] for i in sorted(remaining)],
                                    sorted(remaining))
        if not hull_indices:
            layers.append(sorted(remaining))
            break

        layers.append(hull_indices)
        remaining -= set(hull_indices)

    return layers


def _convex_hull(pts: list[tuple[float, float]],
                 original_indices: list[int]) -> list[int]:
    """Compute convex hull using Andrew's monotone chain algorithm.

    Args:
        pts: Points (already sorted by x).
        original_indices: Mapping from local to original indices.

    Returns:
        List of original indices on the convex hull.
    """
    n = len(pts)
    if n <= 1:
        return list(original_indices)

    # Build lower hull
    lower: list[int] = []
    for i in range(n):
        while len(lower) >= 2:
            o = orient(pts[lower[-2]], pts[lower[-1]], pts[i])
            if o <= 0:
                lower.pop()
            else:
                break
        lower.append(i)

    # Build upper hull
    upper: list[int] = []
    for i in range(n - 1, -1, -1):
        while len(upper) >= 2:
            o = orient(pts[upper[-2]], pts[upper[-1]], pts[i])
            if o <= 0:
                upper.pop()
            else:
                break
        upper.append(i)

    # Remove last point of each half (it's the first of the other)
    hull_local = list(set(lower[:-1] + upper[:-1]))
    return [original_indices[i] for i in hull_local]


def cup_cap_table(max_j: int, max_k: int) -> list[list[int]]:
    """Generate the CC(j,k) table for 2 <= j <= max_j, 2 <= k <= max_k.

    Args:
        max_j: Maximum j value.
        max_k: Maximum k value.

    Returns:
        2D list where result[j-2][k-2] = CC(j, k).
    """
    return [
        [cup_cap_number(j, k) for k in range(2, max_k + 1)]
        for j in range(2, max_j + 1)
    ]


def verify_recurrence(j: int, k: int) -> bool:
    """Verify the Pascal recurrence CC(j,k) = CC(j-1,k) + CC(j,k-1) - 1.

    Args:
        j, k: Parameters (both >= 3 for the recurrence).

    Returns:
        True if the recurrence holds.
    """
    if j < 3 or k < 3:
        return False
    lhs = cup_cap_number(j, k)
    rhs = cup_cap_number(j - 1, k) + cup_cap_number(j, k - 1) - 1
    return lhs == rhs


def verify_symmetry(j: int, k: int) -> bool:
    """Verify CC(j,k) = CC(k,j).

    Args:
        j, k: Parameters.

    Returns:
        True if symmetry holds.
    """
    return cup_cap_number(j, k) == cup_cap_number(k, j)
