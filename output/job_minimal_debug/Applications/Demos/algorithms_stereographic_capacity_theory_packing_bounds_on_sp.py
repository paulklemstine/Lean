#!/usr/bin/env python3
"""
Stereographic Capacity Theory: Core Algorithms

Implements the mathematical algorithms underlying the stereographic packing
bound theory, with full documentation and type hints.

Algorithm 1: Stereographic Conformal Factor Computation
Algorithm 2: Weighted Exclusion Radius
Algorithm 3: Packing Bound Computation (any dimension framework)
Algorithm 4: Distortion-Optimal Radius Selection
"""

import math
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Stereographic Conformal Factor
# ============================================================

def stereo_factor(x_norm: float) -> float:
    """
    Compute the stereographic conformal factor λ(x) = 2/(1 + ‖x‖²).

    This is the pointwise scale factor of stereographic projection from the
    north pole of S^n to ℝ^n. It satisfies:
      - λ(x) > 0 for all x
      - λ(x) ≤ 2, with equality iff x = 0
      - λ(x) → 0 as ‖x‖ → ∞

    Parameters
    ----------
    x_norm : float
        The Euclidean norm ‖x‖ of the projected point.

    Returns
    -------
    float
        The conformal factor λ(x).

    Complexity
    ----------
    Time: O(1), Space: O(1)

    Examples
    --------
    >>> stereo_factor(0.0)
    2.0
    >>> stereo_factor(1.0)
    1.0
    >>> abs(stereo_factor(math.sqrt(3)) - 0.5) < 1e-10
    True
    """
    return 2.0 / (1.0 + x_norm ** 2)


def stereo_factor_inverse(x_norm: float) -> float:
    """
    Compute 1/λ(x) = (1 + ‖x‖²)/2, the inverse conformal factor.

    This gives the local magnification of distances under stereographic
    projection: distances at x are magnified by this factor relative to
    spherical distances.

    Parameters
    ----------
    x_norm : float
        The Euclidean norm ‖x‖.

    Returns
    -------
    float
        The inverse conformal factor, always ≥ 1/2.
    """
    return (1.0 + x_norm ** 2) / 2.0


# ============================================================
# Algorithm 2: Weighted Exclusion Radius
# ============================================================

def stereo_exclusion_radius(r: float, x_norm: float) -> float:
    """
    Compute the stereographic exclusion radius ρ(r, x) = tan(r) / λ(x).

    Under stereographic projection, a spherical cap of geodesic radius r
    centered at a point projecting to x has its image contained in a
    Euclidean ball of approximately this radius.

    Parameters
    ----------
    r : float
        Geodesic cap radius on the sphere, 0 < r < π/2.
    x_norm : float
        Euclidean norm of the projected center point.

    Returns
    -------
    float
        The weighted exclusion radius.

    Complexity
    ----------
    Time: O(1), Space: O(1)
    """
    lam = stereo_factor(x_norm)
    return math.tan(r) / lam


def check_stereo_separation(
    r: float,
    points: List[Tuple[float, ...]],
) -> bool:
    """
    Check if a set of projected points satisfies stereographic separation.

    For each pair (x, y), verifies:
        ρ(r, x) + ρ(r, y) ≤ ‖x - y‖

    Parameters
    ----------
    r : float
        Geodesic cap radius.
    points : list of tuples
        List of points in ℝ^n.

    Returns
    -------
    bool
        True if all pairs satisfy the weighted exclusion condition.

    Complexity
    ----------
    Time: O(k² · n) where k = len(points), n = dimension.
    Space: O(1) beyond input.
    """
    n = len(points)
    for i in range(n):
        for j in range(i + 1, n):
            xi, xj = points[i], points[j]
            norm_i = math.sqrt(sum(c ** 2 for c in xi))
            norm_j = math.sqrt(sum(c ** 2 for c in xj))
            rho_i = stereo_exclusion_radius(r, norm_i)
            rho_j = stereo_exclusion_radius(r, norm_j)
            dist = math.sqrt(sum((a - b) ** 2 for a, b in zip(xi, xj)))
            if rho_i + rho_j > dist + 1e-12:
                return False
    return True


# ============================================================
# Algorithm 3: Packing Bound Computation
# ============================================================

def packing_bound_s2(r: float) -> Tuple[float, int]:
    """
    Compute the stereographic packing bound for S².

    Uses the closed-form formula:
        B(r) = 8 / (cos²(r) · (1 - cos(r)))

    This is equivalent to (2/cos r)² · (4π / (2π(1-cos r))).

    Parameters
    ----------
    r : float
        Geodesic cap radius, 0 < r < π/2.

    Returns
    -------
    tuple of (float, int)
        (exact_bound, ceiling_bound)

    Complexity
    ----------
    Time: O(1), Space: O(1)

    Examples
    --------
    >>> exact, ceil_val = packing_bound_s2(math.pi / 3)
    >>> ceil_val
    64
    >>> exact, ceil_val = packing_bound_s2(math.pi / 6)
    >>> ceil_val >= 12
    True
    """
    if r <= 0 or r >= math.pi / 2:
        raise ValueError(f"r must be in (0, π/2), got r={r}")
    c = math.cos(r)
    bound = 8.0 / (c ** 2 * (1.0 - c))
    return bound, math.ceil(bound)


def packing_bound_general(n: int, r: float) -> Tuple[float, int]:
    """
    Compute a generalized stereographic packing bound for S^n.

    For general dimension n, the bound is:
        B(n, r) = D(n, r) · vol(S^n) / capVol(n, r)

    where D(n, r) = (2/cos r)^n is the worst-case n-dimensional
    distortion factor.

    For n=2 this reduces to the closed form above. For n>2 we use
    the ratio of sphere volume to cap volume with numerical integration
    for the cap volume.

    Parameters
    ----------
    n : int
        Dimension of the sphere (S^n embedded in ℝ^{n+1}).
    r : float
        Geodesic cap radius, 0 < r < π/2.

    Returns
    -------
    tuple of (float, int)
        (exact_bound, ceiling_bound)

    Complexity
    ----------
    Time: O(n) for dimension-dependent volume computation.
    Space: O(1)
    """
    if n < 1:
        raise ValueError(f"n must be ≥ 1, got {n}")
    if r <= 0 or r >= math.pi / 2:
        raise ValueError(f"r must be in (0, π/2), got r={r}")

    c = math.cos(r)
    distortion = (2.0 / c) ** n

    # Volume of S^n: 2π^((n+1)/2) / Γ((n+1)/2)
    sphere_vol = 2.0 * math.pi ** ((n + 1) / 2.0) / math.gamma((n + 1) / 2.0)

    # Cap volume approximation using numerical integration
    # Cap of geodesic radius r on S^n has volume:
    # ω_{n-1} ∫_0^r sin^{n-1}(θ) dθ
    # where ω_{n-1} is the volume of S^{n-1}
    omega_n_minus_1 = 2.0 * math.pi ** (n / 2.0) / math.gamma(n / 2.0)

    # Numerical integration of sin^{n-1}(θ) from 0 to r
    num_steps = 10000
    dt = r / num_steps
    integral = 0.0
    for i in range(num_steps):
        theta = (i + 0.5) * dt
        integral += math.sin(theta) ** (n - 1) * dt

    cap_vol = omega_n_minus_1 * integral

    bound = distortion * sphere_vol / cap_vol
    return bound, math.ceil(bound)


# ============================================================
# Algorithm 4: Distortion-Optimal Radius Analysis
# ============================================================

def distortion_overhead(r: float, n: int = 2) -> float:
    """
    Compute the distortion overhead factor (2/cos r)^n.

    This measures how much the stereographic bound exceeds the simple
    volume bound due to conformal distortion. The overhead is:
      - 1 at r = 0 (no distortion)
      - increasing as r → π/2
      - exponential in dimension n

    Parameters
    ----------
    r : float
        Geodesic cap radius.
    n : int
        Dimension (default 2).

    Returns
    -------
    float
        The distortion overhead factor.
    """
    c = math.cos(r)
    return (2.0 / c) ** n


def find_crossover_radius(
    n: int = 2,
    threshold: float = 2.0,
    tol: float = 1e-10,
) -> float:
    """
    Find the radius r at which distortion overhead equals a threshold.

    Solves (2/cos r)^n = threshold for r ∈ (0, π/2).
    This is r = arccos(2 / threshold^{1/n}).

    Parameters
    ----------
    n : int
        Dimension.
    threshold : float
        Distortion overhead threshold.
    tol : float
        Numerical tolerance.

    Returns
    -------
    float
        The crossover radius in radians.
    """
    ratio = 2.0 / threshold ** (1.0 / n)
    if ratio > 1.0:
        return 0.0  # threshold too small, overhead always exceeds it
    if ratio < -1.0:
        return math.pi / 2  # never reaches threshold
    return math.acos(ratio)


def asymptotic_ratio(r: float, n: int = 2) -> float:
    """
    Compute the ratio Q_n(r) = bound(n,r) · capVol(n,r) / vol(S^n).

    As r → 0, if the bound is asymptotically sharp, Q_n(r) → 1.
    Deviations from 1 measure the looseness of the bound.

    Parameters
    ----------
    r : float
        Geodesic cap radius.
    n : int
        Dimension.

    Returns
    -------
    float
        The asymptotic ratio.
    """
    c = math.cos(r)
    # For S², Q_2(r) = (2/cos r)^2 = 4/cos²(r)
    return (2.0 / c) ** n


# ============================================================
# Demo and Testing
# ============================================================

def run_examples():
    """Run example computations demonstrating all algorithms."""
    print("=" * 60)
    print("Algorithm Examples: Stereographic Capacity Theory")
    print("=" * 60)

    # Algorithm 1: Conformal factor
    print("\n--- Algorithm 1: Stereographic Conformal Factor ---")
    for norm in [0.0, 0.5, 1.0, 2.0, 5.0, 10.0]:
        lam = stereo_factor(norm)
        inv_lam = stereo_factor_inverse(norm)
        print(f"  ‖x‖ = {norm:5.1f}  →  λ(x) = {lam:.6f},  1/λ(x) = {inv_lam:.6f}")

    # Algorithm 2: Exclusion radii
    print("\n--- Algorithm 2: Weighted Exclusion Radii ---")
    for r_name, r_val in [("π/6", math.pi/6), ("π/4", math.pi/4), ("π/3", math.pi/3)]:
        print(f"  r = {r_name}:")
        for norm in [0.0, 1.0, 2.0]:
            rho = stereo_exclusion_radius(r_val, norm)
            print(f"    ‖x‖ = {norm:.1f}  →  ρ = {rho:.6f}")

    # Algorithm 3: Packing bounds
    print("\n--- Algorithm 3: S² Packing Bounds ---")
    for r_name, r_val, known in [
        ("π/6", math.pi/6, 12),
        ("π/4", math.pi/4, 6),
        ("π/3", math.pi/3, 4),
    ]:
        exact, ceil_val = packing_bound_s2(r_val)
        print(f"  r = {r_name}:  bound = {exact:.2f},  ⌈bound⌉ = {ceil_val},  known N = {known}")

    # General dimension bounds
    print("\n--- Algorithm 3b: General Dimension Bounds ---")
    for n in [2, 3, 4]:
        exact, ceil_val = packing_bound_general(n, math.pi / 6)
        print(f"  S^{n}, r = π/6:  bound = {exact:.2f},  ⌈bound⌉ = {ceil_val}")

    # Algorithm 4: Distortion analysis
    print("\n--- Algorithm 4: Distortion Overhead ---")
    for r_name, r_val in [("π/12", math.pi/12), ("π/6", math.pi/6),
                           ("π/4", math.pi/4), ("π/3", math.pi/3)]:
        overhead = distortion_overhead(r_val, n=2)
        print(f"  r = {r_name}:  (2/cos r)² = {overhead:.4f}")

    crossover = find_crossover_radius(n=2, threshold=2.0)
    print(f"\n  Crossover radius (distortion = 2x): {crossover:.4f} rad ({math.degrees(crossover):.1f}°)")


if __name__ == "__main__":
    run_examples()
