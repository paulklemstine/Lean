#!/usr/bin/env python3
"""
Certified Rotation Algorithms

Implements the algorithms whose correctness is formally verified:
1. Quaternion ↔ Rotation Matrix conversion
2. Axis-Angle ↔ Quaternion conversion
3. Quaternion SLERP (spherical linear interpolation)
4. Euler angle extraction with singularity detection
5. Quaternion algebra norm-form classifier
"""

import numpy as np
from typing import Tuple, Optional


# ============================================================
# 1. Quaternion-Rotation Matrix Conversion
# ============================================================

def quat_to_rotation_matrix(q: np.ndarray) -> np.ndarray:
    """
    Convert a unit quaternion [w, x, y, z] to a 3×3 rotation matrix.

    Certified property (formally proved):
      - Output R is orthogonal: R^T R = I
      - det(R) = 1
      - R preserves vector norms

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        q: Unit quaternion [w, x, y, z] with w² + x² + y² + z² = 1

    Returns:
        3×3 rotation matrix R ∈ SO(3)
    """
    w, x, y, z = q
    return np.array([
        [1 - 2*(y**2 + z**2), 2*(x*y - z*w),       2*(x*z + y*w)],
        [2*(x*y + z*w),       1 - 2*(x**2 + z**2),  2*(y*z - x*w)],
        [2*(x*z - y*w),       2*(y*z + x*w),         1 - 2*(x**2 + y**2)]
    ])


def rotation_matrix_to_quat(R: np.ndarray) -> np.ndarray:
    """
    Convert a 3×3 rotation matrix to a unit quaternion.

    Uses Shepperd's method for numerical stability.

    Certified property: the output q satisfies quat_to_rotation_matrix(q) = R.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        R: 3×3 rotation matrix in SO(3)

    Returns:
        Unit quaternion [w, x, y, z]
    """
    trace = np.trace(R)

    if trace > 0:
        s = 2 * np.sqrt(trace + 1)
        w = 0.25 * s
        x = (R[2, 1] - R[1, 2]) / s
        y = (R[0, 2] - R[2, 0]) / s
        z = (R[1, 0] - R[0, 1]) / s
    elif R[0, 0] > R[1, 1] and R[0, 0] > R[2, 2]:
        s = 2 * np.sqrt(1 + R[0, 0] - R[1, 1] - R[2, 2])
        w = (R[2, 1] - R[1, 2]) / s
        x = 0.25 * s
        y = (R[0, 1] + R[1, 0]) / s
        z = (R[0, 2] + R[2, 0]) / s
    elif R[1, 1] > R[2, 2]:
        s = 2 * np.sqrt(1 + R[1, 1] - R[0, 0] - R[2, 2])
        w = (R[0, 2] - R[2, 0]) / s
        x = (R[0, 1] + R[1, 0]) / s
        y = 0.25 * s
        z = (R[1, 2] + R[2, 1]) / s
    else:
        s = 2 * np.sqrt(1 + R[2, 2] - R[0, 0] - R[1, 1])
        w = (R[1, 0] - R[0, 1]) / s
        x = (R[0, 2] + R[2, 0]) / s
        y = (R[1, 2] + R[2, 1]) / s
        z = 0.25 * s

    q = np.array([w, x, y, z])
    return q / np.linalg.norm(q)


# ============================================================
# 2. Axis-Angle ↔ Quaternion Conversion
# ============================================================

def axis_angle_to_quat(axis: np.ndarray, angle: float) -> np.ndarray:
    """
    Convert axis-angle to unit quaternion.

    Certified property (formally proved):
      - Output has unit norm when input axis has unit norm
      - axis_angle_to_quat(axis, 2π) = [-1, 0, 0, 0]
      - axis_angle_to_quat(axis, 4π) = [+1, 0, 0, 0]

    Time complexity: O(1)

    Args:
        axis: Unit 3D vector [ux, uy, uz]
        angle: Rotation angle in radians

    Returns:
        Unit quaternion [w, x, y, z]
    """
    axis = axis / np.linalg.norm(axis)
    half = angle / 2
    return np.array([
        np.cos(half),
        np.sin(half) * axis[0],
        np.sin(half) * axis[1],
        np.sin(half) * axis[2]
    ])


def quat_to_axis_angle(q: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    Convert unit quaternion to axis-angle representation.

    Time complexity: O(1)

    Args:
        q: Unit quaternion [w, x, y, z]

    Returns:
        (axis, angle) where axis is a unit 3D vector and angle ∈ [0, 2π)
    """
    q = q / np.linalg.norm(q)
    # Ensure w ≥ 0 for canonical form
    if q[0] < 0:
        q = -q

    angle = 2 * np.arccos(np.clip(q[0], -1, 1))
    sin_half = np.sin(angle / 2)

    if abs(sin_half) < 1e-10:
        return np.array([1, 0, 0]), 0.0  # identity rotation

    axis = q[1:4] / sin_half
    return axis, angle


# ============================================================
# 3. Quaternion SLERP
# ============================================================

def slerp(q0: np.ndarray, q1: np.ndarray, t: float) -> np.ndarray:
    """
    Spherical linear interpolation between unit quaternions.

    The geodesic on S³ — the natural shortest-path interpolation.
    This path avoids gimbal lock singularities by construction.

    Time complexity: O(1)

    Args:
        q0: Start unit quaternion
        q1: End unit quaternion
        t: Interpolation parameter in [0, 1]

    Returns:
        Interpolated unit quaternion at parameter t
    """
    q0 = q0 / np.linalg.norm(q0)
    q1 = q1 / np.linalg.norm(q1)

    # Ensure shortest path (avoid going the long way around S³)
    dot = np.dot(q0, q1)
    if dot < 0:
        q1 = -q1
        dot = -dot

    # If very close, use linear interpolation to avoid division by zero
    if dot > 0.9995:
        result = q0 + t * (q1 - q0)
        return result / np.linalg.norm(result)

    theta = np.arccos(dot)
    sin_theta = np.sin(theta)

    result = (np.sin((1 - t) * theta) / sin_theta) * q0 + \
             (np.sin(t * theta) / sin_theta) * q1
    return result / np.linalg.norm(result)


# ============================================================
# 4. Euler Angle Extraction with Singularity Detection
# ============================================================

def rotation_to_euler(R: np.ndarray) -> Tuple[float, float, float, bool]:
    """
    Extract Euler angles (roll, pitch, yaw) from rotation matrix
    with gimbal lock detection.

    Returns:
        (roll, pitch, yaw, is_singular)
        where is_singular = True when |cos(pitch)| < threshold
    """
    GIMBAL_THRESHOLD = 1e-6

    # pitch = arcsin(R[2,0])
    sin_pitch = np.clip(R[2, 0], -1, 1)
    pitch = np.arcsin(sin_pitch)
    cos_pitch = np.cos(pitch)

    is_singular = abs(cos_pitch) < GIMBAL_THRESHOLD

    if is_singular:
        # Gimbal lock: roll and yaw are degenerate
        roll = 0.0
        yaw = np.arctan2(R[0, 1], R[0, 2])
    else:
        roll = np.arctan2(-R[2, 1] / cos_pitch, R[2, 2] / cos_pitch)
        yaw = np.arctan2(-R[1, 0] / cos_pitch, R[0, 0] / cos_pitch)

    return roll, pitch, yaw, is_singular


def euler_singularity_detector(q: np.ndarray) -> dict:
    """
    Analyze a quaternion orientation for proximity to Euler singularities.

    Returns a report with:
    - is_singular: whether the orientation is at gimbal lock
    - cos_pitch: the value of cos(pitch), which → 0 at singularity
    - condition_number: estimate of Euler parametrization conditioning
    """
    R = quat_to_rotation_matrix(q)
    sin_pitch = np.clip(R[2, 0], -1, 1)
    cos_pitch = np.cos(np.arcsin(sin_pitch))

    return {
        "is_singular": abs(cos_pitch) < 1e-6,
        "cos_pitch": cos_pitch,
        "condition_number": 1.0 / max(abs(cos_pitch), 1e-15),
        "quaternion_condition": 1.0 / np.linalg.norm(q)  # Always 1 for unit q
    }


# ============================================================
# 5. Quaternion Algebra Norm-Form Classifier
# ============================================================

def reduced_norm(a: float, b: float, p: np.ndarray) -> float:
    """
    Compute the reduced norm of an element p = (x₀, x₁, x₂, x₃)
    in the quaternion algebra (a,b)_ℝ.

    N(p) = x₀² - a·x₁² - b·x₂² + ab·x₃²

    Certified property (formally proved): N(pq) = N(p)·N(q)
    """
    return p[0]**2 - a*p[1]**2 - b*p[2]**2 + a*b*p[3]**2


def classify_real_qa(a: float, b: float) -> str:
    """
    Classify the real quaternion algebra (a,b)_ℝ.

    Certified theorem: (a,b)_ℝ is a division algebra ⟺ a < 0 ∧ b < 0.
    Otherwise it splits as M₂(ℝ).

    Time complexity: O(1)

    Args:
        a, b: Nonzero real parameters

    Returns:
        "division" or "split"
    """
    if a == 0 or b == 0:
        raise ValueError("Parameters must be nonzero")
    return "division" if a < 0 and b < 0 else "split"


def find_norm_zero(a: float, b: float) -> Optional[np.ndarray]:
    """
    If (a,b)_ℝ splits, find a nontrivial element with norm zero.

    Certified: when a > 0, use (√a, 1, 0, 0); when b > 0, use (√b, 0, 1, 0).
    """
    if a > 0:
        return np.array([np.sqrt(a), 1, 0, 0])
    elif b > 0:
        return np.array([np.sqrt(b), 0, 1, 0])
    else:
        return None  # Division algebra — no such element exists


# ============================================================
# Usage examples
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")

    # Test roundtrip: quaternion → matrix → quaternion
    q = np.array([0.5, 0.5, 0.5, 0.5])
    R = quat_to_rotation_matrix(q)
    q_back = rotation_matrix_to_quat(R)
    print(f"Original q:    {q}")
    print(f"Recovered q:   {q_back}")
    print(f"Match: {np.allclose(np.abs(np.dot(q, q_back)), 1.0)}")

    # Test SLERP
    print(f"\nSLERP test:")
    q0 = np.array([1, 0, 0, 0])
    q1 = axis_angle_to_quat(np.array([0, 0, 1]), np.pi/2)
    for t in [0, 0.25, 0.5, 0.75, 1.0]:
        qt = slerp(q0, q1, t)
        print(f"  t={t:.2f}: {qt}, norm={np.linalg.norm(qt):.6f}")

    # Test classifier
    print(f"\nQA Classification:")
    for a, b in [(-1,-1), (-2,-3), (1,-1), (1,1)]:
        cls = classify_real_qa(a, b)
        zero = find_norm_zero(a, b)
        print(f"  ({a},{b}): {cls}", end="")
        if zero is not None:
            print(f", zero element: {zero}, norm={reduced_norm(a,b,zero):.6f}")
        else:
            print()
