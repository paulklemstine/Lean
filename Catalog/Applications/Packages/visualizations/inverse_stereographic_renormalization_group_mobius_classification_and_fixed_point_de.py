#!/usr/bin/env python3
"""
Algorithms for Inverse Stereographic Renormalization Group

Implements certified algorithms for:
1. Detecting RG fixed points from pole data
2. Computing the geometric beta observable
3. Classifying Möbius dynamics (elliptic/parabolic/hyperbolic)
4. Computing orbit periods and rotation numbers
"""

import numpy as np
from typing import Tuple, Optional, List

# ─────────────────────────────────────────────
# Algorithm 1: Möbius classification
# ─────────────────────────────────────────────

def moebius_classify(a: float, b: float) -> str:
    """
    Classify the two-pole Möbius map F_{a,b}.

    The discriminant is Δ = -4(a-b)².
    - Δ < 0 (a ≠ b): elliptic (rotation, no real fixed points)
    - Δ = 0 (a = b): identity (parabolic degenerate)

    Parameters
    ----------
    a : float
        First pole
    b : float
        Second pole

    Returns
    -------
    str
        Classification: "elliptic", "identity"

    Complexity: O(1) time, O(1) space
    """
    disc = -4 * (a - b) ** 2
    if abs(a - b) < 1e-15:
        return "identity"
    return "elliptic"


def moebius_f(a: float, b: float, t: float) -> float:
    """
    Compute F_{a,b}(t) = ((ab+1)t + (b-a)) / ((a-b)t + (ab+1)).

    Parameters
    ----------
    a, b : float
        Pole parameters
    t : float
        Input coupling

    Returns
    -------
    float
        F_{a,b}(t)

    Complexity: O(1)
    """
    numer = (a * b + 1) * t + (b - a)
    denom = (a - b) * t + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return numer / denom


def moebius_deriv(a: float, b: float, g: float) -> float:
    """
    Compute F'_{a,b}(g) = (1+a²)(1+b²) / ((a-b)g + (ab+1))².

    This is the geometric beta coefficient — the conformal response
    of the RG update at coupling g.

    Parameters
    ----------
    a, b : float
        Pole parameters
    g : float
        Coupling at which to evaluate derivative

    Returns
    -------
    float
        The derivative F'_{a,b}(g)

    Complexity: O(1)
    """
    denom = (a - b) * g + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return (1 + a**2) * (1 + b**2) / denom**2


# ─────────────────────────────────────────────
# Algorithm 2: Fixed point detection
# ─────────────────────────────────────────────

def detect_fixed_points(a: float, b: float) -> List[complex]:
    """
    Find all fixed points of F_{a,b} (including complex ones).

    The fixed-point equation is (a-b)(g² + 1) = 0.
    - If a = b: every point is fixed.
    - If a ≠ b: g² + 1 = 0, so g = ±i (complex only).

    Parameters
    ----------
    a, b : float
        Pole parameters

    Returns
    -------
    list of complex
        Fixed points. Empty list if a = b (all points fixed).
        [+i, -i] if a ≠ b.

    Complexity: O(1)
    """
    if abs(a - b) < 1e-15:
        return []  # All points are fixed
    return [1j, -1j]


def detect_real_fixed_points(a: float, b: float) -> List[float]:
    """
    Find real fixed points of F_{a,b}.

    Theorem (rgUpdate_no_real_fixed_point): For a ≠ b, there are none.

    Parameters
    ----------
    a, b : float
        Pole parameters

    Returns
    -------
    list of float
        Real fixed points (empty if a ≠ b).

    Complexity: O(1)
    """
    if abs(a - b) < 1e-15:
        return [0.0]  # Representative; actually all points
    return []


# ─────────────────────────────────────────────
# Algorithm 3: Orbit computation
# ─────────────────────────────────────────────

def compute_orbit(a: float, b: float, g0: float,
                  n_steps: int = 100) -> np.ndarray:
    """
    Compute the orbit of g0 under iterated F_{a,b}.

    Parameters
    ----------
    a, b : float
        Pole parameters
    g0 : float
        Initial coupling
    n_steps : int
        Number of iterations

    Returns
    -------
    ndarray of shape (n_steps+1,)
        The orbit [g0, F(g0), F²(g0), ...]

    Complexity: O(n_steps)
    """
    orbit = np.zeros(n_steps + 1)
    orbit[0] = g0
    for i in range(n_steps):
        orbit[i + 1] = moebius_f(a, b, orbit[i])
    return orbit


def estimate_rotation_number(a: float, b: float, g0: float,
                              n_steps: int = 10000) -> float:
    """
    Estimate the rotation number of F_{a,b} on the projective line.

    For an elliptic Möbius transformation, the dynamics on the projective
    line is conjugate to a rotation. The rotation number θ/(2π) can be
    estimated from the angular velocity on the unit circle.

    Parameters
    ----------
    a, b : float
        Pole parameters
    g0 : float
        Starting point

    Returns
    -------
    float
        Estimated rotation number in [0, 1)

    Complexity: O(n_steps)
    """
    if abs(a - b) < 1e-15:
        return 0.0

    # Map to unit circle via inverse stereographic
    def to_angle(t):
        return 2 * np.arctan(t)

    theta0 = to_angle(g0)
    g = g0
    total_angle = 0.0

    for _ in range(n_steps):
        g_new = moebius_f(a, b, g)
        theta_old = to_angle(g)
        theta_new = to_angle(g_new)
        dtheta = theta_new - theta_old
        # Unwrap
        while dtheta > np.pi:
            dtheta -= 2 * np.pi
        while dtheta < -np.pi:
            dtheta += 2 * np.pi
        total_angle += dtheta
        g = g_new

    return (total_angle / (2 * np.pi * n_steps)) % 1.0


# ─────────────────────────────────────────────
# Algorithm 4: Stability classification
# ─────────────────────────────────────────────

def classify_stability(a: float, b: float, g: float) -> str:
    """
    Classify local stability at coupling g under F_{a,b}.

    Since F'(g) > 0 always, and F has no real fixed points for a≠b,
    the classification is based on the derivative magnitude:
    - |F'(g)| < 1: locally contracting
    - |F'(g)| = 1: neutral
    - |F'(g)| > 1: locally expanding

    Parameters
    ----------
    a, b : float
        Pole parameters
    g : float
        Coupling value

    Returns
    -------
    str
        "contracting", "neutral", or "expanding"
    """
    d = moebius_deriv(a, b, g)
    if d == float('inf'):
        return "singular"
    if abs(d) < 1 - 1e-10:
        return "contracting"
    elif abs(d) > 1 + 1e-10:
        return "expanding"
    return "neutral"


# ─────────────────────────────────────────────
# Algorithm 5: Determinant and group structure
# ─────────────────────────────────────────────

def moebius_det(a: float, b: float) -> float:
    """
    Compute the determinant of F_{a,b}: (1+a²)(1+b²).

    This equals the product of Gaussian norms N(1+ai)·N(1+bi).

    Complexity: O(1)
    """
    return (1 + a**2) * (1 + b**2)


def compose_poles(a: float, b: float, c: float) -> Tuple[float, float]:
    """
    The composition law: F_{b,c} ∘ F_{a,b} = F_{a,c}.

    Given three poles a, b, c, the composition of two successive
    RG updates with pole pairs (a,b) and (b,c) equals a single
    update with poles (a,c). The intermediate pole cancels.

    Parameters
    ----------
    a, b, c : float
        Three poles

    Returns
    -------
    tuple (a, c)
        The effective pole pair after composition

    Complexity: O(1)
    """
    return (a, c)


# ─────────────────────────────────────────────
# Main: demonstrate algorithms
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print("Inverse Stereographic RG — Algorithm Demonstrations")
    print("=" * 55)

    # Classification
    print("\n1. Möbius classification:")
    for a, b in [(0, 1), (1, 1), (2, -3), (0.5, 0.5)]:
        print(f"   F_{{{a},{b}}}: {moebius_classify(a, b)}")

    # Fixed points
    print("\n2. Fixed point detection:")
    for a, b in [(0, 1), (1, 1)]:
        real_fp = detect_real_fixed_points(a, b)
        complex_fp = detect_fixed_points(a, b)
        print(f"   F_{{{a},{b}}}: real={real_fp}, complex={complex_fp}")

    # Rotation numbers
    print("\n3. Rotation numbers:")
    for a, b in [(0, 1), (0, 0.5), (1, 2), (0, 0.1)]:
        rn = estimate_rotation_number(a, b, 0.0)
        print(f"   F_{{{a},{b}}}: ρ ≈ {rn:.6f}")

    # Stability
    print("\n4. Stability at g=0:")
    for a, b in [(0, 1), (0, 0.1), (1, 10)]:
        s = classify_stability(a, b, 0)
        d = moebius_deriv(a, b, 0)
        print(f"   F_{{{a},{b}}}: {s} (F'(0) = {d:.4f})")

    # Composition
    print("\n5. Composition law F_{b,c} ∘ F_{a,b} = F_{a,c}:")
    a, b, c = 1, 2, 3
    g = 0.5
    lhs = moebius_f(b, c, moebius_f(a, b, g))
    rhs = moebius_f(a, c, g)
    print(f"   F_{{{b},{c}}}(F_{{{a},{b}}}({g})) = {lhs:.6f}")
    print(f"   F_{{{a},{c}}}({g}) = {rhs:.6f}")
    print(f"   Match: {abs(lhs - rhs) < 1e-10}")
