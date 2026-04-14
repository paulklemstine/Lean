#!/usr/bin/env python3
"""
Thomas Precession via 3D SPB

Demonstrates that non-commutative velocity addition in 3D
leads to the Thomas-Wigner rotation (Thomas precession).

The 3D SPB formula is:
  spb₃(u, v) = (u + v + u × v) / (1 - u · v)

This is non-commutative: spb₃(u,v) ≠ spb₃(v,u) in general.
The difference is a rotation — the Thomas precession.
"""

import math
import numpy as np

def cross(u, v):
    return np.array([
        u[1]*v[2] - u[2]*v[1],
        u[2]*v[0] - u[0]*v[2],
        u[0]*v[1] - u[1]*v[0]
    ])

def dot(u, v):
    return np.sum(u * v)

def spb3(u, v):
    """3D SPB: (u + v + u×v) / (1 - u·v)"""
    denom = 1 - dot(u, v)
    if abs(denom) < 1e-15:
        return None
    return (u + v + cross(u, v)) / denom

def spbH3(u, v):
    """3D hyperbolic SPB (relativistic velocity addition)
    Exact Einstein formula for non-collinear velocities"""
    gamma_u = 1 / math.sqrt(1 - dot(u, u))
    u_dot_v = dot(u, v)

    numerator = (u + v / gamma_u +
                 (gamma_u / (1 + gamma_u)) * u_dot_v * u)
    denom = 1 + u_dot_v

    return numerator / denom

def rotation_angle(u, v):
    """Compute the Thomas rotation angle between spb3(u,v) and spb3(v,u)"""
    w1 = spb3(u, v)
    w2 = spb3(v, u)

    if w1 is None or w2 is None:
        return None

    # The angle between w1 and w2
    cos_theta = dot(w1, w2) / (np.linalg.norm(w1) * np.linalg.norm(w2))
    cos_theta = max(-1, min(1, cos_theta))  # numerical clamp
    return math.acos(cos_theta)

def thomas_angle_formula(u, v):
    """Theoretical Thomas-Wigner rotation angle (small velocity approximation)"""
    cross_uv = cross(u, v)
    cross_mag = np.linalg.norm(cross_uv)
    u_dot_v = dot(u, v)

    if cross_mag < 1e-15:
        return 0.0  # collinear, no precession

    # Exact formula for the 3D SPB case
    angle = 2 * math.atan2(cross_mag, 1 + u_dot_v)
    return angle

if __name__ == "__main__":
    print("=" * 65)
    print("THOMAS PRECESSION VIA 3D SPB")
    print("spb₃(u,v) = (u + v + u×v) / (1 - u·v)")
    print("=" * 65)

    # Test 1: Non-commutativity
    print("\n--- Non-Commutativity of 3D SPB ---")
    u = np.array([0.3, 0.0, 0.0])
    v = np.array([0.0, 0.4, 0.0])

    w_uv = spb3(u, v)
    w_vu = spb3(v, u)

    print(f"  u = {u}")
    print(f"  v = {v}")
    print(f"  spb₃(u,v) = [{w_uv[0]:.6f}, {w_uv[1]:.6f}, {w_uv[2]:.6f}]")
    print(f"  spb₃(v,u) = [{w_vu[0]:.6f}, {w_vu[1]:.6f}, {w_vu[2]:.6f}]")
    print(f"  Equal? {np.allclose(w_uv, w_vu)} (should be False)")
    print(f"  Difference (Thomas precession): {w_uv - w_vu}")

    # Test 2: Thomas rotation angles for various velocity pairs
    print("\n--- Thomas Rotation Angles ---")
    print(f"  {'|u|':>6s} {'|v|':>6s} {'angle°':>8s} {'formula°':>9s} {'u×v':>8s}")

    for u_mag, v_mag in [(0.1, 0.1), (0.2, 0.3), (0.3, 0.4), (0.5, 0.5),
                          (0.1, 0.5), (0.4, 0.4)]:
        u = np.array([u_mag, 0, 0])
        v = np.array([0, v_mag, 0])

        angle = rotation_angle(u, v)
        formula = thomas_angle_formula(u, v)
        cross_mag = np.linalg.norm(cross(u, v))

        if angle is not None:
            print(f"  {u_mag:6.2f} {v_mag:6.2f} {math.degrees(angle):8.4f} "
                  f"{math.degrees(formula):9.4f} {cross_mag:8.4f}")

    # Test 3: Collinear velocities — no precession
    print("\n--- Collinear Velocities (No Precession) ---")
    u = np.array([0.3, 0.0, 0.0])
    v = np.array([0.4, 0.0, 0.0])
    w_uv = spb3(u, v)
    w_vu = spb3(v, u)
    print(f"  u = {u}, v = {v}")
    print(f"  spb₃(u,v) = {w_uv}")
    print(f"  spb₃(v,u) = {w_vu}")
    print(f"  Equal? {np.allclose(w_uv, w_vu)} (should be True for collinear)")

    # Test 4: Connection to quaternions
    print("\n--- Connection to Quaternions ---")
    print("  The 3D SPB formula (u + v + u×v)/(1 - u·v)")
    print("  matches the quaternion product formula for pure quaternions:")
    print("  If q₁ = u₁i + u₂j + u₃k and q₂ = v₁i + v₂j + v₃k,")
    print("  then q₁·q₂ = -(u·v) + (u×v)₁i + (u×v)₂j + (u×v)₃k")
    print("  The SPB formula is exactly the stereographic projection")
    print("  of this quaternion product back to ℝ³.")

    # Verify: quaternion product
    def quat_mult(q1, q2):
        """Multiply quaternions (w, x, y, z)"""
        w1, x1, y1, z1 = q1
        w2, x2, y2, z2 = q2
        return (
            w1*w2 - x1*x2 - y1*y2 - z1*z2,
            w1*x2 + x1*w2 + y1*z2 - z1*y2,
            w1*y2 - x1*z2 + y1*w2 + z1*x2,
            w1*z2 + x1*y2 - y1*x2 + z1*w2,
        )

    # Map ℝ³ to quaternion via stereographic projection
    def r3_to_quat(v):
        """Map v ∈ ℝ³ to unit quaternion via stereographic projection"""
        norm_sq = dot(v, v)
        w = (1 - norm_sq) / (1 + norm_sq)
        scale = 2 / (1 + norm_sq)
        return (w, scale * v[0], scale * v[1], scale * v[2])

    def quat_to_r3(q):
        """Map unit quaternion back to ℝ³ via inverse stereographic"""
        w, x, y, z = q
        if abs(1 + w) < 1e-15:
            return None
        return np.array([x, y, z]) / (1 + w)

    u = np.array([0.3, 0.2, 0.1])
    v = np.array([0.1, 0.4, 0.2])

    qu = r3_to_quat(u)
    qv = r3_to_quat(v)
    q_prod = quat_mult(qu, qv)
    w_quat = quat_to_r3(q_prod)
    w_spb = spb3(u, v)

    print(f"\n  u = {u}")
    print(f"  v = {v}")
    print(f"  Quaternion product → ℝ³: {w_quat}")
    print(f"  SPB₃(u, v):              {w_spb}")
    print(f"  Match: {np.allclose(w_quat, w_spb)}")

    # Test 5: Division algebra connection
    print("\n--- Division Algebra Connection ---")
    print("  SPB dimensionality matches Hurwitz's theorem:")
    print("  dim 1: SPB(x,y) = (x+y)/(1-xy) → ℝ (reals)")
    print("  dim 3: SPB₃(u,v) = (u+v+u×v)/(1-u·v) → ℍ (quaternions)")
    print("  dim 7: SPB₇ would use octonion multiplication → 𝕆 (octonions)")
    print("  These are the ONLY dimensions where SPB forms a group!")
    print("  (By Hurwitz's theorem: division algebras exist only in dim 1,2,4,8)")
    print("  (SPB dimensions = division algebra dimensions minus 1)")

    print("\n" + "=" * 65)
    print("THOMAS PRECESSION ANALYSIS COMPLETE")
    print("=" * 65)
