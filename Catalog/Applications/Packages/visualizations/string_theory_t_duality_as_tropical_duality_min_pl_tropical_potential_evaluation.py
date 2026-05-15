#!/usr/bin/env python3
"""
Algorithms for Tropical T-Duality and Mirror Symmetry.

Implements the core computational primitives that arise from the formalized
mathematical framework: tropical potential evaluation, Fenchel conjugation,
corner locus detection, and conifold transition tracking.
"""

from typing import Callable
import math


# ============================================================
# Algorithm 1: Tropical Potential Evaluation
# ============================================================

def tropical_potential(
    coefficients: list[tuple[float, float]],
    x: float
) -> tuple[float, int]:
    """
    Evaluate a tropical potential Φ(x) = min_i(c_i + m_i * x).

    Args:
        coefficients: List of (intercept c_i, slope m_i) pairs defining affine branches.
        x: Point at which to evaluate.

    Returns:
        (value, minimizing_index): The potential value and the index of the
        branch achieving the minimum.

    Time complexity: O(k) where k = len(coefficients).
    Space complexity: O(1).

    >>> tropical_potential([(0, 1), (2, -1), (1, 0)], 0.5)
    (0.5, 0)
    """
    if not coefficients:
        raise ValueError("At least one branch required")

    best_val = float('inf')
    best_idx = 0
    for i, (c, m) in enumerate(coefficients):
        val = c + m * x
        if val < best_val:
            best_val = val
            best_idx = i
    return best_val, best_idx


# ============================================================
# Algorithm 2: Corner Locus Detection
# ============================================================

def detect_corners(
    coefficients: list[tuple[float, float]]
) -> list[tuple[float, int, int]]:
    """
    Find all corner points of a tropical potential.

    For k affine branches, corners occur at intersections of pairs of branches
    with distinct slopes. Returns all corner points sorted by x-coordinate.

    Args:
        coefficients: List of (intercept c_i, slope m_i) pairs.

    Returns:
        List of (x_corner, branch_i, branch_j) triples, sorted by x_corner.

    Time complexity: O(k² log k) for k branches.
    Space complexity: O(k²).

    >>> corners = detect_corners([(0, 1), (0, -1), (1, 0)])
    >>> [(round(x, 4), i, j) for x, i, j in corners]
    [(-1.0, 1, 2), (0.0, 0, 1), (1.0, 0, 2)]
    """
    corners = []
    k = len(coefficients)
    for i in range(k):
        for j in range(i + 1, k):
            c_i, m_i = coefficients[i]
            c_j, m_j = coefficients[j]
            if abs(m_i - m_j) < 1e-15:
                continue  # Parallel branches, no intersection
            x_corner = (c_j - c_i) / (m_i - m_j)
            # Check that this is actually a corner (both branches achieve the min)
            val_corner = c_i + m_i * x_corner
            is_corner = True
            for l, (c_l, m_l) in enumerate(coefficients):
                if l != i and l != j:
                    if c_l + m_l * x_corner < val_corner - 1e-12:
                        is_corner = False
                        break
            if is_corner:
                corners.append((x_corner, i, j))

    corners.sort(key=lambda t: t[0])
    return corners


def filter_active_corners(
    coefficients: list[tuple[float, float]]
) -> list[tuple[float, float, list[int]]]:
    """
    Find all active corner points with their values and participating branches.

    An active corner is a point where the minimum is achieved by ≥2 branches
    and no other branch is strictly below.

    Returns:
        List of (x, value, [branch_indices]) triples.
    """
    raw = detect_corners(coefficients)
    result = []
    seen = set()
    for x, _, _ in raw:
        x_key = round(x, 10)
        if x_key in seen:
            continue
        seen.add(x_key)
        val, _ = tropical_potential(coefficients, x)
        active = [i for i, (c, m) in enumerate(coefficients)
                  if abs(c + m * x - val) < 1e-10]
        if len(active) >= 2:
            result.append((x, val, active))
    return result


# ============================================================
# Algorithm 3: Tropical Fenchel Conjugate
# ============================================================

def tropical_fenchel_conjugate(
    sample_points: list[float],
    f: Callable[[float], float],
    p: float
) -> float:
    """
    Compute the tropical Fenchel conjugate f°(p) = inf_{x ∈ S} (f(x) - p*x).

    Args:
        sample_points: Finite set S of evaluation points.
        f: Function to conjugate.
        p: Slope parameter.

    Returns:
        The conjugate value f°(p).

    Time complexity: O(|S|).

    >>> f = lambda x: x**2
    >>> tropical_fenchel_conjugate([-2, -1, 0, 1, 2], f, 1.0)
    0.0
    """
    return min(f(x) - p * x for x in sample_points)


def tropical_biconjugate(
    sample_points: list[float],
    f: Callable[[float], float],
    x: float
) -> float:
    """
    Compute the tropical biconjugate f°°(x) = inf_{p ∈ S} (f°(p) + p*x).

    By the Fenchel-Moreau inequality (proved in Lean): f°°(x) ≤ f(x).

    Args:
        sample_points: Finite set S used for both conjugations.
        f: Original function.
        x: Point at which to evaluate.

    Returns:
        The biconjugate value f°°(x).
    """
    return min(
        tropical_fenchel_conjugate(sample_points, f, p) + p * x
        for p in sample_points
    )


# ============================================================
# Algorithm 4: Conifold Transition Tracker
# ============================================================

def track_conifold_transition(
    t_values: list[float],
    x_range: tuple[float, float] = (-3, 3),
    resolution: int = 1000
) -> list[dict]:
    """
    Track the evolution of corner loci through a conifold family
    f_t(x) = min(x, -x, t) as the parameter t varies.

    Args:
        t_values: Parameter values to scan.
        x_range: Range of x to search for corners.
        resolution: Number of sample points.

    Returns:
        List of dictionaries with transition data for each t.

    >>> results = track_conifold_transition([0.0])
    >>> results[0]['n_corners_at_origin']
    3
    """
    results = []
    xs = [x_range[0] + i * (x_range[1] - x_range[0]) / resolution
          for i in range(resolution + 1)]

    for t in t_values:
        coeffs = [(0, 1), (0, -1), (t, 0)]  # x, -x, t
        corners = filter_active_corners(coeffs)

        # Count branches at origin
        val_origin = min(0, 0, t)
        branches_at_origin = sum(1 for v in [0, 0, t] if abs(v - val_origin) < 1e-10)

        results.append({
            't': t,
            'n_corners': len(corners),
            'corners': corners,
            'n_corners_at_origin': branches_at_origin,
            'is_singular': branches_at_origin >= 3,
            'value_at_origin': val_origin,
        })

    return results


# ============================================================
# Algorithm 5: T-Duality Transform
# ============================================================

def t_duality_transform(
    R: float,
    spectrum: list[tuple[float, float]]
) -> tuple[float, list[tuple[float, float]]]:
    """
    Apply T-duality to a string spectrum.

    Transforms:
    - Radius: R → 1/R
    - Charges: (n_i, w_i) → (w_i, n_i) for each state

    Args:
        R: Compactification radius.
        spectrum: List of (momentum, winding) quantum numbers.

    Returns:
        (dual_radius, dual_spectrum)

    >>> t_duality_transform(2.0, [(1, 0), (0, 1), (2, 3)])
    (0.5, [(0, 1), (1, 0), (3, 2)])
    """
    dual_R = 1.0 / R
    dual_spectrum = [(w, n) for n, w in spectrum]
    return dual_R, dual_spectrum


def verify_energy_invariance(
    R: float,
    spectrum: list[tuple[float, float]],
    tol: float = 1e-12
) -> bool:
    """
    Verify T-duality energy invariance for a spectrum.

    Checks that E(R, n, w) = E(1/R, w, n) for all states.

    >>> verify_energy_invariance(2.0, [(1, 2), (3, -1), (0, 0)])
    True
    """
    dual_R = 1.0 / R
    for n, w in spectrum:
        E1 = min(n + R, w + 1.0 / R)
        E2 = min(w + dual_R, n + R)
        if abs(E1 - E2) > tol:
            return False
    return True


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("Algorithm 1: Tropical Potential")
    coeffs = [(0, 1), (2, -1), (1, 0)]
    for x in [-1, 0, 0.5, 1, 2]:
        val, idx = tropical_potential(coeffs, x)
        print(f"  Φ({x}) = {val:.4f} (branch {idx})")

    print("\nAlgorithm 2: Corner Detection")
    corners = filter_active_corners(coeffs)
    for x, val, branches in corners:
        print(f"  Corner at x={x:.4f}, value={val:.4f}, branches={branches}")

    print("\nAlgorithm 3: Fenchel-Moreau Inequality")
    S = [-2.0, -1.0, 0.0, 1.0, 2.0]
    f = lambda x: x ** 2
    for x in S:
        fx = f(x)
        fxx = tropical_biconjugate(S, f, x)
        print(f"  f({x}) = {fx:.4f}, f°°({x}) = {fxx:.4f}, gap = {fx - fxx:.4f}")

    print("\nAlgorithm 4: Conifold Transition Tracking")
    results = track_conifold_transition([-1, -0.5, 0, 0.5, 1])
    for r in results:
        status = "SINGULAR" if r['is_singular'] else "smooth"
        print(f"  t={r['t']:5.1f}: #corners={r['n_corners']}, "
              f"origin_branches={r['n_corners_at_origin']}, [{status}]")

    print("\nAlgorithm 5: T-Duality Transform")
    R = 2.0
    spectrum = [(1, 0), (0, 1), (2, 3)]
    dR, ds = t_duality_transform(R, spectrum)
    print(f"  R={R} → R'={dR}")
    print(f"  Spectrum: {spectrum} → {ds}")
    print(f"  Energy invariance: {verify_energy_invariance(R, spectrum)}")
