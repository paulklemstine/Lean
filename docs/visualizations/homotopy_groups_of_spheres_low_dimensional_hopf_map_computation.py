#!/usr/bin/env python3
"""
Algorithms for computing Hopf fibration invariants.

This module implements:
1. The Hopf map in coordinates
2. Discrete linking number computation via Gauss integral
3. Fiber computation and projection
4. SU(2) to S³ correspondence

All algorithms are self-contained with type hints and docstrings.
"""

import numpy as np
from typing import Tuple, List, Optional


# ============================================================
# Algorithm 1: Hopf Map Computation
# ============================================================

def hopf_map(x: np.ndarray) -> np.ndarray:
    """
    Compute the Hopf map η: S³ → S².

    The Hopf map in coordinates sends (x₀, x₁, x₂, x₃) ∈ S³ to:
      y₀ = 2(x₀x₂ + x₁x₃)
      y₁ = 2(x₁x₂ - x₀x₃)
      y₂ = x₀² + x₁² - x₂² - x₃²

    Complexity: O(1) per point, O(n) for n points (vectorized).

    Args:
        x: Array of shape (..., 4) with points on S³

    Returns:
        Array of shape (..., 3) with points on S²

    Example:
        >>> x = np.array([1, 0, 0, 0], dtype=float)
        >>> hopf_map(x)
        array([0., 0., 1.])
    """
    x0, x1, x2, x3 = x[..., 0], x[..., 1], x[..., 2], x[..., 3]
    return np.stack([
        2 * (x0 * x2 + x1 * x3),
        2 * (x1 * x2 - x0 * x3),
        x0**2 + x1**2 - x2**2 - x3**2
    ], axis=-1)


# ============================================================
# Algorithm 2: S¹ Action on S³
# ============================================================

def s1_action(x: np.ndarray, theta: float) -> np.ndarray:
    """
    Apply the S¹ action to points on S³.

    This rotates (z₁, z₂) by e^{iθ}, which in real coordinates
    is simultaneous rotation by θ in the (x₀,x₁) and (x₂,x₃) planes.

    The Hopf map is invariant under this action:
      η(e^{iθ} · p) = η(p)  for all θ.

    Complexity: O(1) per point.

    Args:
        x: Array of shape (..., 4)
        theta: Rotation angle in radians

    Returns:
        Rotated array of shape (..., 4)
    """
    c, s = np.cos(theta), np.sin(theta)
    x0, x1, x2, x3 = x[..., 0], x[..., 1], x[..., 2], x[..., 3]
    return np.stack([
        c * x0 - s * x1,
        s * x0 + c * x1,
        c * x2 - s * x3,
        s * x2 + c * x3
    ], axis=-1)


# ============================================================
# Algorithm 3: Hopf Fiber Computation
# ============================================================

def compute_hopf_fiber(target: np.ndarray, n_points: int = 200) -> np.ndarray:
    """
    Compute the Hopf fiber (preimage) over a point on S².

    Given a target point y ∈ S², finds a base point p ∈ S³ with η(p) = y,
    then traces the S¹ orbit {e^{iθ}·p : θ ∈ [0, 2π)} which is the
    complete fiber η⁻¹(y).

    Complexity: O(n_points).

    Args:
        target: Point on S² as array of shape (3,)
        n_points: Number of sample points on the fiber circle

    Returns:
        Array of shape (n_points, 4) representing the fiber circle in S³
    """
    y0, y1, y2 = target

    # Find a base point solving the Hopf map equations
    if y2 > -0.99:
        # Standard case: y2 ≠ -1
        r_sq = (1 - y2) / 2  # x2² + x3² = (1-y2)/2
        r = np.sqrt(max(r_sq, 0))
        if r > 1e-10:
            # Set x3 = 0, x2 = r, then x0 = y0/(2r), x1 = y1/(2r)
            x2 = r
            x3 = 0.0
            x0 = y0 / (2 * x2)
            x1 = y1 / (2 * x2)
        else:
            # y2 ≈ 1: north pole case
            x0 = 1.0
            x1 = 0.0
            x2 = 0.0
            x3 = 0.0
    else:
        # y2 ≈ -1: south pole case
        x0 = 0.0
        x1 = 0.0
        x2 = 1.0
        x3 = 0.0

    base = np.array([x0, x1, x2, x3])
    base = base / np.linalg.norm(base)

    # Trace the S¹ orbit
    thetas = np.linspace(0, 2 * np.pi, n_points, endpoint=True)
    return np.array([s1_action(base, t) for t in thetas])


# ============================================================
# Algorithm 4: Gauss Linking Number
# ============================================================

def gauss_linking_number(curve1: np.ndarray, curve2: np.ndarray) -> float:
    """
    Compute the Gauss linking number of two closed curves in ℝ³.

    Uses the Gauss linking integral:
      L = (1/4π) ∮∮ (r₁ - r₂) · (dr₁ × dr₂) / |r₁ - r₂|³

    This is a topological invariant: it counts how many times
    the curves are linked (with sign).

    Complexity: O(n₁ × n₂) where nᵢ = len(curveᵢ).

    Args:
        curve1: Array of shape (n1, 3), closed curve (first = last)
        curve2: Array of shape (n2, 3), closed curve (first = last)

    Returns:
        Approximate linking number (should be close to an integer)
    """
    n1 = len(curve1) - 1
    n2 = len(curve2) - 1

    total = 0.0
    for i in range(n1):
        dr1 = curve1[i + 1] - curve1[i]
        for j in range(n2):
            dr2 = curve2[j + 1] - curve2[j]
            r = curve1[i] - curve2[j]
            r_norm = np.linalg.norm(r)
            if r_norm > 1e-12:
                total += np.dot(r, np.cross(dr1, dr2)) / r_norm**3

    return total / (4 * np.pi)


# ============================================================
# Algorithm 5: Hopf Invariant via Linking
# ============================================================

def compute_hopf_invariant(n_fiber_points: int = 300) -> float:
    """
    Compute the Hopf invariant of the Hopf map via the linking number.

    The Hopf invariant H(η) equals the linking number of η⁻¹(a) and η⁻¹(b)
    for any two distinct regular values a, b ∈ S².

    For the standard Hopf map, H(η) = 1.

    Complexity: O(n²) where n = n_fiber_points.

    Returns:
        Approximate Hopf invariant (should be close to 1 for the standard Hopf map)
    """
    # Choose two distinct points on S²
    north = np.array([0.0, 0.0, 1.0])
    equator = np.array([1.0, 0.0, 0.0])

    # Compute fibers
    fiber1 = compute_hopf_fiber(north, n_fiber_points)
    fiber2 = compute_hopf_fiber(equator, n_fiber_points)

    # Stereographic projection S³ → ℝ³ (from the point (-1,0,0,0))
    def stereo(x):
        return x[..., 1:4] / (1 + x[..., 0:1] + 1e-15)

    proj1 = stereo(fiber1)
    proj2 = stereo(fiber2)

    # Compute linking number
    return gauss_linking_number(proj1, proj2)


# ============================================================
# Algorithm 6: SU(2) to S³ Correspondence
# ============================================================

def su2_to_s3(alpha: complex, beta: complex) -> np.ndarray:
    """
    Map an SU(2) element to S³.

    An SU(2) element is parametrized by (α, β) ∈ ℂ² with |α|² + |β|² = 1:
      U = [[α, -β̄], [β, ᾱ]]

    The map sends (α, β) to (Re α, Im α, Re β, Im β) ∈ S³ ⊂ ℝ⁴.

    Args:
        alpha, beta: Complex numbers with |α|² + |β|² = 1

    Returns:
        Point on S³ as array of shape (4,)
    """
    return np.array([alpha.real, alpha.imag, beta.real, beta.imag])


def s3_to_su2(x: np.ndarray) -> Tuple[complex, complex]:
    """
    Map a point on S³ to an SU(2) element.

    Inverse of su2_to_s3.

    Args:
        x: Point on S³ as array of shape (4,)

    Returns:
        (alpha, beta) parametrizing the SU(2) element
    """
    return complex(x[0], x[1]), complex(x[2], x[3])


def hopf_via_su2(alpha: complex, beta: complex) -> np.ndarray:
    """
    Compute the Hopf map via the SU(2) quotient.

    The Hopf map SU(2) → SU(2)/U(1) ≅ S² sends (α, β) to:
      (2 Re(αβ̄), 2 Im(αβ̄), |α|² - |β|²)

    This equals the standard Hopf map composed with su2_to_s3.

    Args:
        alpha, beta: Complex numbers with |α|² + |β|² = 1

    Returns:
        Point on S² as array of shape (3,)
    """
    z = alpha * beta.conjugate()
    return np.array([2 * z.real, 2 * z.imag, abs(alpha)**2 - abs(beta)**2])


# ============================================================
# Algorithm 7: Exact Sequence Computation
# ============================================================

def exact_sequence_isomorphism_check(
    source_rank: int,
    left_trivial: bool,
    right_trivial: bool
) -> Optional[int]:
    """
    Determine the rank of the middle group in an exact sequence.

    Given an exact sequence A →[f] B →[g] C →[h] D where:
    - B has known rank (source_rank)
    - A is trivial iff left_trivial
    - D is trivial iff right_trivial

    If both A and D are trivial, g is an isomorphism and C has
    the same rank as B.

    This implements the algebraic engine behind the Hopf computation.

    Args:
        source_rank: Rank of B (source of the key map)
        left_trivial: Whether A = 0
        right_trivial: Whether D = 0

    Returns:
        Rank of C if determinable, None otherwise
    """
    if left_trivial and right_trivial:
        return source_rank
    elif left_trivial:
        # g is injective, rank(C) ≥ rank(B)
        return None  # Cannot determine without more info
    elif right_trivial:
        # g is surjective, rank(C) ≤ rank(B)
        return None
    else:
        return None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Hopf Fibration Algorithms - Examples")
    print("=" * 50)

    # Example 1: Hopf map
    print("\n1. Hopf map of north pole (1,0,0,0):")
    result = hopf_map(np.array([1.0, 0, 0, 0]))
    print(f"   η(1,0,0,0) = {result}")

    # Example 2: S¹ invariance
    print("\n2. S¹ invariance check:")
    p = np.array([1, 0, 0, 0], dtype=float)
    for theta in [0, np.pi/4, np.pi/2, np.pi]:
        q = s1_action(p, theta)
        print(f"   η(e^{{i·{theta:.2f}}}·p) = {hopf_map(q)}")

    # Example 3: Hopf invariant
    print("\n3. Hopf invariant (linking number):")
    H = compute_hopf_invariant(n_fiber_points=200)
    print(f"   H(η) ≈ {H:.4f} (expected: 1)")

    # Example 4: SU(2) correspondence
    print("\n4. SU(2) → S² via Hopf:")
    alpha, beta = complex(1/np.sqrt(2), 0), complex(1/np.sqrt(2), 0)
    print(f"   (α,β) = ({alpha}, {beta})")
    print(f"   Hopf image = {hopf_via_su2(alpha, beta)}")
    s3pt = su2_to_s3(alpha, beta)
    print(f"   Direct map = {hopf_map(s3pt)}")

    # Example 5: Exact sequence
    print("\n5. Exact sequence computation:")
    rank = exact_sequence_isomorphism_check(
        source_rank=1,  # π₃(S³) ≅ ℤ has rank 1
        left_trivial=True,  # π₃(S¹) = 0
        right_trivial=True  # π₂(S¹) = 0
    )
    print(f"   π₃(S²) has rank = {rank}")
    print(f"   Therefore π₃(S²) ≅ ℤ")
