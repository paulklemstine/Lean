#!/usr/bin/env python3
"""
Algorithms for convex geometry computations:
- Minkowski sum computation for boxes and polygons
- Support function evaluation
- Mixed volume coefficient extraction
- Brunn-Minkowski verification
- Newton's inequality verification

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
import itertools


def minkowski_sum_boxes(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """
    Compute Minkowski sum of two axis-aligned boxes.

    Args:
        a: Side lengths of box A (n-dimensional).
        b: Side lengths of box B (n-dimensional).

    Returns:
        Side lengths of A ⊕ B.

    Time complexity: O(n)
    Space complexity: O(n)

    Example:
        >>> minkowski_sum_boxes(np.array([1, 2, 3]), np.array([4, 5, 6]))
        array([5, 7, 9])
    """
    assert len(a) == len(b), "Dimension mismatch"
    return a + b


def support_function_box(
    lo: np.ndarray, hi: np.ndarray, direction: np.ndarray
) -> float:
    """
    Evaluate the support function of a box [lo, hi] at a given direction.

    The support function h_K(u) = max_{x in K} <u, x>.
    For a box, this decomposes coordinatewise.

    Args:
        lo: Lower corner of the box.
        hi: Upper corner of the box.
        direction: Direction vector u.

    Returns:
        h_K(u) = sum_i max(u_i * lo_i, u_i * hi_i)

    Time complexity: O(n)
    Space complexity: O(1)

    Example:
        >>> support_function_box(np.array([0, 0]), np.array([1, 2]), np.array([1, -1]))
        1.0
    """
    return float(np.sum(np.maximum(direction * lo, direction * hi)))


def mixed_volume_coefficients(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """
    Compute the mixed volume coefficients of two boxes.

    For boxes with side lengths a and b, the volume of A + tB is
    vol(A + tB) = sum_{k=0}^{n} c_k * t^k
    where c_k = sum_{|S|=k} prod_{i in S} b_i * prod_{i not in S} a_i.

    Args:
        a: Side lengths of box A.
        b: Side lengths of box B.

    Returns:
        Array of coefficients [c_0, c_1, ..., c_n].

    Time complexity: O(2^n) — exponential in dimension
    Space complexity: O(n)

    For practical computation in high dimensions, use the polynomial
    multiplication approach (O(n^2)) instead.

    Example:
        >>> mixed_volume_coefficients(np.array([1, 2]), np.array([3, 4]))
        array([ 2., 10., 12.])
    """
    n = len(a)
    coeffs = np.zeros(n + 1)
    for k in range(n + 1):
        for subset in itertools.combinations(range(n), k):
            term = 1.0
            for i in range(n):
                term *= b[i] if i in subset else a[i]
            coeffs[k] += term
    return coeffs


def mixed_volume_coefficients_fast(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """
    Compute mixed volume coefficients via polynomial multiplication.

    Uses the factored form: prod_i (a_i + t * b_i).
    Multiplies polynomials sequentially.

    Args:
        a: Side lengths of box A.
        b: Side lengths of box B.

    Returns:
        Array of coefficients [c_0, c_1, ..., c_n].

    Time complexity: O(n^2)
    Space complexity: O(n)

    Example:
        >>> mixed_volume_coefficients_fast(np.array([1, 2]), np.array([3, 4]))
        array([ 2., 10., 12.])
    """
    n = len(a)
    # Start with the polynomial "1"
    poly = np.array([1.0])
    for i in range(n):
        # Multiply by (a_i + t * b_i)
        new_poly = np.zeros(len(poly) + 1)
        for j in range(len(poly)):
            new_poly[j] += a[i] * poly[j]
            new_poly[j + 1] += b[i] * poly[j]
        poly = new_poly
    return poly


def verify_brunn_minkowski(
    a: np.ndarray, b: np.ndarray
) -> Tuple[float, float, float]:
    """
    Verify Brunn-Minkowski inequality for boxes.

    Args:
        a: Side lengths of box A.
        b: Side lengths of box B.

    Returns:
        Tuple of (vol_sum_root, vol_a_root + vol_b_root, gap)
        where gap >= 0 iff BM holds.

    Time complexity: O(n)

    Example:
        >>> lhs, rhs, gap = verify_brunn_minkowski(np.array([1, 1]), np.array([2, 2]))
        >>> gap >= 0
        True
    """
    n = len(a)
    vol_sum = float(np.prod(a + b))
    vol_a = float(np.prod(a))
    vol_b = float(np.prod(b))
    lhs = vol_sum ** (1.0 / n)
    rhs = vol_a ** (1.0 / n) + vol_b ** (1.0 / n)
    return lhs, rhs, lhs - rhs


def verify_newton_inequality(coeffs: np.ndarray) -> List[Tuple[int, float]]:
    """
    Verify Newton's log-concavity inequality for a coefficient sequence.

    Checks c_k^2 - c_{k-1} * c_{k+1} >= 0 for each 0 < k < n.

    Args:
        coeffs: Coefficient sequence [c_0, ..., c_n].

    Returns:
        List of (k, gap) where gap = c_k^2 - c_{k-1} * c_{k+1}.
        All gaps should be >= 0 if Newton's inequality holds.

    Time complexity: O(n)

    Example:
        >>> gaps = verify_newton_inequality(np.array([2, 10, 12]))
        >>> all(gap >= -1e-12 for _, gap in gaps)
        True
    """
    results = []
    for k in range(1, len(coeffs) - 1):
        gap = coeffs[k] ** 2 - coeffs[k - 1] * coeffs[k + 1]
        results.append((k, gap))
    return results


def parallel_volume_box(sides: np.ndarray, t: float) -> float:
    """
    Compute the parallel volume vol(K + t * B_inf) for a box K.

    For a box with side lengths s_i, the parallel volume (expanding by t
    in each direction with the l^infinity ball) is prod_i (s_i + 2t).

    Args:
        sides: Side lengths of box K.
        t: Dilation parameter (t >= 0).

    Returns:
        vol(K + t * B_inf) = prod_i (s_i + 2t)

    Time complexity: O(n)
    """
    return float(np.prod(sides + 2 * t))


def perimeter_proxy_box(sides: np.ndarray) -> float:
    """
    Compute the perimeter proxy for a box.

    perimProxy(K) = 2 * sum_i prod_{j != i} s_j

    This is the derivative of parallel_volume at t=0, representing
    the surface area of the box.

    Args:
        sides: Side lengths of box K.

    Returns:
        The perimeter proxy value.

    Time complexity: O(n^2) naive, O(n) with prefix products.
    """
    n = len(sides)
    total = 0.0
    vol = float(np.prod(sides))
    for i in range(n):
        if sides[i] > 0:
            total += vol / sides[i]
        else:
            # Handle zero side length
            term = 1.0
            for j in range(n):
                if j != i:
                    term *= sides[j]
            total += term
    return 2.0 * total


def minkowski_sum_polygons(
    vertices_a: np.ndarray, vertices_b: np.ndarray
) -> np.ndarray:
    """
    Compute Minkowski sum of two convex polygons in R^2.

    Uses the standard edge-sorting algorithm: sort edges by angle,
    merge, and reconstruct vertices.

    Args:
        vertices_a: Vertices of polygon A, shape (m, 2), CCW order.
        vertices_b: Vertices of polygon B, shape (p, 2), CCW order.

    Returns:
        Vertices of A ⊕ B in CCW order, shape (m+p, 2).

    Time complexity: O(m + p) after sorting (O((m+p) log(m+p)) total)
    Space complexity: O(m + p)
    """
    def edges(verts):
        n = len(verts)
        return [(verts[(i + 1) % n] - verts[i]) for i in range(n)]

    def angle(v):
        return np.arctan2(v[1], v[0])

    # Compute edges
    ea = edges(vertices_a)
    eb = edges(vertices_b)

    # Start from bottom-most point of each
    start_a = np.argmin(vertices_a[:, 1])
    start_b = np.argmin(vertices_b[:, 1])

    # Reorder edges starting from bottom-most
    ea = ea[start_a:] + ea[:start_a]
    eb = eb[start_b:] + eb[:start_b]

    # Merge by angle
    result = [vertices_a[start_a] + vertices_b[start_b]]
    i, j = 0, 0
    while i < len(ea) or j < len(eb):
        if i >= len(ea):
            result.append(result[-1] + eb[j])
            j += 1
        elif j >= len(eb):
            result.append(result[-1] + ea[i])
            i += 1
        elif angle(ea[i]) < angle(eb[j]):
            result.append(result[-1] + ea[i])
            i += 1
        elif angle(ea[i]) > angle(eb[j]):
            result.append(result[-1] + eb[j])
            j += 1
        else:
            result.append(result[-1] + ea[i] + eb[j])
            i += 1
            j += 1

    return np.array(result[:-1])  # Remove duplicate last vertex


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Mixed Volume Coefficients (two methods) ===")
    a = np.array([1.0, 2.0, 3.0, 4.0])
    b = np.array([2.0, 1.0, 3.0, 2.0])
    c_slow = mixed_volume_coefficients(a, b)
    c_fast = mixed_volume_coefficients_fast(a, b)
    print(f"  Subset method: {c_slow}")
    print(f"  Polynomial method: {c_fast}")
    print(f"  Match: {np.allclose(c_slow, c_fast)}")
    print()

    print("=== Brunn-Minkowski Verification ===")
    lhs, rhs, gap = verify_brunn_minkowski(a, b)
    print(f"  vol(A+B)^(1/4) = {lhs:.6f}")
    print(f"  vol(A)^(1/4) + vol(B)^(1/4) = {rhs:.6f}")
    print(f"  Gap = {gap:.6f} >= 0: {'✓' if gap >= -1e-12 else '✗'}")
    print()

    print("=== Newton's Inequality ===")
    gaps = verify_newton_inequality(c_fast)
    for k, g in gaps:
        print(f"  k={k}: c_k^2 - c_{{k-1}}*c_{{k+1}} = {g:.4f} {'✓' if g >= -1e-12 else '✗'}")
    print()

    print("=== Perimeter Proxy ===")
    sides = np.array([2.0, 3.0, 5.0])
    proxy = perimeter_proxy_box(sides)
    print(f"  Box sides: {sides}")
    print(f"  Perimeter proxy: {proxy:.4f}")
    print(f"  Surface area: {2*(2*3 + 2*5 + 3*5):.4f}")
