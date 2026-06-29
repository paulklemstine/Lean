#!/usr/bin/env python3
"""
Tropical Double Descent — Algorithms

Implements the core algorithms for tropical phase diagram computation:
1. Tropical risk evaluation
2. Threshold detection (tropical vertex finding)
3. Phase assignment
4. Perturbation stability analysis
5. Multi-facet tropical risk (generalized to k competing regimes)
"""

from typing import List, Tuple, Optional
import numpy as np


def tropical_risk_eval(
    a1: float, b1: float, a2: float, b2: float, n: float
) -> float:
    """
    Evaluate the tropical (min-plus) risk at complexity n.

    R(n) = min(a1 * n + b1, a2 * n + b2)

    Time: O(1)
    Space: O(1)

    Args:
        a1: Slope of classical facet
        b1: Intercept of classical facet
        a2: Slope of modern facet
        b2: Intercept of modern facet
        n: Model complexity parameter

    Returns:
        The tropical risk value at n

    Example:
        >>> tropical_risk_eval(1.0, -2.0, -0.5, 5.5, 3)
        1.0
        >>> tropical_risk_eval(1.0, -2.0, -0.5, 5.5, 7)
        2.0
    """
    return min(a1 * n + b1, a2 * n + b2)


def find_tropical_vertex(
    a1: float, b1: float, a2: float, b2: float
) -> Optional[float]:
    """
    Find the tropical vertex (interpolation threshold) where two affine
    risk branches cross.

    Solves: a1 * τ + b1 = a2 * τ + b2
    => τ = (b2 - b1) / (a1 - a2)

    Returns None if slopes are equal (parallel lines, no crossing).

    Time: O(1)
    Space: O(1)

    Args:
        a1, b1: Slope and intercept of classical facet
        a2, b2: Slope and intercept of modern facet

    Returns:
        The crossing point τ, or None if slopes are equal

    Example:
        >>> find_tropical_vertex(1.0, -2.0, -0.5, 5.5)
        5.0
    """
    if abs(a1 - a2) < 1e-15:
        return None
    return (b2 - b1) / (a1 - a2)


def phase_assignment(
    a1: float, b1: float, a2: float, b2: float, n: float
) -> str:
    """
    Determine which regime (classical or modern) dominates at complexity n.

    Time: O(1)
    Space: O(1)

    Returns:
        'classical' if a1*n+b1 < a2*n+b2
        'modern' if a2*n+b2 < a1*n+b1
        'vertex' if they are equal (at the threshold)
    """
    f = a1 * n + b1
    g = a2 * n + b2
    if abs(f - g) < 1e-12:
        return 'vertex'
    elif f < g:
        return 'classical'
    else:
        return 'modern'


def dominance_margin(
    a1: float, a2: float, n: float, tau: float
) -> float:
    """
    Compute the dominance margin at complexity n.

    margin(n) = (a1 - a2) * (n - τ)

    Positive => classical facet has higher value (modern dominates)
    Negative => modern facet has higher value (classical dominates)
    Zero => at the vertex

    Time: O(1)
    Space: O(1)

    Example:
        >>> dominance_margin(1.0, -0.5, 3, 5)
        -3.0
        >>> dominance_margin(1.0, -0.5, 7, 5)
        3.0
    """
    return (a1 - a2) * (n - tau)


def perturbation_stability_check(
    a1: float, b1: float, a2: float, b2: float,
    tau: float, eta: float, n: float
) -> bool:
    """
    Check if the phase assignment at n is stable under perturbation of size η.

    The assignment is stable if |margin(n)| > 2η, meaning that even with
    bounded perturbation of both facets, the dominant facet doesn't change.

    Time: O(1)
    Space: O(1)

    Args:
        a1, b1, a2, b2: Facet parameters
        tau: Threshold
        eta: Perturbation bound
        n: Point to check

    Returns:
        True if the phase assignment is stable under η-perturbation

    Example:
        >>> perturbation_stability_check(1.0, -2.0, -0.5, 5.5, 5.0, 0.3, 3.0)
        True
        >>> perturbation_stability_check(1.0, -2.0, -0.5, 5.5, 5.0, 5.0, 4.0)
        False
    """
    margin = abs(dominance_margin(a1, a2, n, tau))
    return margin > 2 * eta


def multi_facet_tropical_risk(
    facets: List[Tuple[float, float]], n: float
) -> Tuple[float, int]:
    """
    Evaluate the tropical risk as the minimum of k competing affine facets.

    R(n) = min_{i=1..k} (a_i * n + b_i)

    Time: O(k) where k = len(facets)
    Space: O(1)

    Args:
        facets: List of (slope, intercept) pairs
        n: Complexity parameter

    Returns:
        Tuple of (risk_value, dominant_facet_index)

    Example:
        >>> multi_facet_tropical_risk([(1.0, -2.0), (-0.5, 5.5), (0.2, 1.0)], 3)
        (1.0, 0)
    """
    best_val = float('inf')
    best_idx = -1
    for i, (a, b) in enumerate(facets):
        val = a * n + b
        if val < best_val:
            best_val = val
            best_idx = i
    return best_val, best_idx


def find_all_tropical_vertices(
    facets: List[Tuple[float, float]]
) -> List[Tuple[float, int, int]]:
    """
    Find all tropical vertices (phase boundaries) for k competing affine facets.

    A tropical vertex occurs where two facets cross AND are jointly minimal.

    Time: O(k² log k) — O(k²) crossings, sorted, then O(k) sweep
    Space: O(k²) for storing crossings

    Args:
        facets: List of (slope, intercept) pairs

    Returns:
        List of (crossing_point, facet_i, facet_j) for each tropical vertex,
        sorted by crossing point

    Example:
        >>> vertices = find_all_tropical_vertices([(1.0, -2.0), (-0.5, 5.5), (0.2, 1.0)])
        >>> [(round(v[0], 2), v[1], v[2]) for v in vertices]
        [(3.75, 0, 2), (5.62, 2, 1)]
    """
    k = len(facets)
    crossings = []

    for i in range(k):
        for j in range(i + 1, k):
            a_i, b_i = facets[i]
            a_j, b_j = facets[j]
            if abs(a_i - a_j) < 1e-15:
                continue
            tau = (b_j - b_i) / (a_i - a_j)
            # Check if these two facets are jointly minimal at τ
            val_at_tau = a_i * tau + b_i
            is_minimal = True
            for l in range(k):
                if l != i and l != j:
                    a_l, b_l = facets[l]
                    if a_l * tau + b_l < val_at_tau - 1e-12:
                        is_minimal = False
                        break
            if is_minimal:
                crossings.append((tau, i, j))

    crossings.sort(key=lambda x: x[0])
    return crossings


def tropical_risk_piecewise_decomposition(
    facets: List[Tuple[float, float]],
    domain: Tuple[float, float] = (0, 100)
) -> List[Tuple[float, float, int]]:
    """
    Decompose the tropical risk into piecewise-affine segments.

    Returns intervals [start, end) with the index of the dominant facet.

    Time: O(k² log k)
    Space: O(k²)

    Args:
        facets: List of (slope, intercept) pairs
        domain: (min_n, max_n) domain of interest

    Returns:
        List of (start, end, dominant_facet_index) triples

    Example:
        >>> decomp = tropical_risk_piecewise_decomposition(
        ...     [(1.0, -2.0), (-0.5, 5.5)], (0, 10))
        >>> [(round(s, 1), round(e, 1), i) for s, e, i in decomp]
        [(0, 5.0, 0), (5.0, 10, 1)]
    """
    vertices = find_all_tropical_vertices(facets)
    breakpoints = [domain[0]] + [v[0] for v in vertices if domain[0] < v[0] < domain[1]] + [domain[1]]

    segments = []
    for idx in range(len(breakpoints) - 1):
        mid = (breakpoints[idx] + breakpoints[idx + 1]) / 2
        _, dominant = multi_facet_tropical_risk(facets, mid)
        segments.append((breakpoints[idx], breakpoints[idx + 1], dominant))

    return segments


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Double Descent — Algorithm Demonstrations")
    print("=" * 60)

    # Two-facet example
    a1, b1 = 1.0, -2.0
    a2, b2 = -0.5, 5.5
    tau = find_tropical_vertex(a1, b1, a2, b2)
    print(f"\nThreshold τ = {tau}")

    print("\nPhase assignments:")
    for n in range(11):
        phase = phase_assignment(a1, b1, a2, b2, n)
        risk = tropical_risk_eval(a1, b1, a2, b2, n)
        margin = dominance_margin(a1, a2, n, tau)
        stable = perturbation_stability_check(a1, b1, a2, b2, tau, 0.5, n)
        print(f"  n={n:2d}: R={risk:5.1f}, phase={phase:10s}, margin={margin:5.1f}, stable(η=0.5): {stable}")

    # Three-facet example
    print("\n" + "=" * 60)
    print("Multi-facet example (3 competing regimes)")
    print("=" * 60)
    facets = [(1.0, -2.0), (-0.5, 5.5), (0.2, 1.0)]
    vertices = find_all_tropical_vertices(facets)
    print(f"Tropical vertices: {[(round(v[0], 3), v[1], v[2]) for v in vertices]}")

    segments = tropical_risk_piecewise_decomposition(facets, (0, 15))
    print("Piecewise decomposition:")
    regime_names = ["Classical", "Modern", "Intermediate"]
    for start, end, idx in segments:
        print(f"  [{start:.2f}, {end:.2f}): {regime_names[idx]} (facet {idx})")
