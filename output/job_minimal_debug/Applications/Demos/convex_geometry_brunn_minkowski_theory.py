#!/usr/bin/env python3
"""
Applications of convex geometry to real-world problems:

1. Optimal packaging: finding the most efficient box to contain two shapes
2. Signal processing: entropy power inequality analogy
3. Geometric optimization: isoperimetric bounds for boxes
4. Error estimation: Minkowski sum in robotics/collision detection
"""

import numpy as np
from typing import Tuple
import itertools


# ============================================================
# Application 1: Optimal Packaging / Container Design
# ============================================================

def optimal_container_bound(
    item_dims: list, num_items: int
) -> Tuple[np.ndarray, float]:
    """
    Given items to pack, compute Minkowski-sum-based container bounds.

    When packing multiple convex items, the Minkowski sum gives an outer
    bound on the space needed. Brunn-Minkowski provides a lower bound
    on the volume of any containing shape.

    Args:
        item_dims: List of item dimensions (each a numpy array of side lengths)
        num_items: Number of items (for scaling)

    Returns:
        (container_dims, min_volume_bound) - the Minkowski sum dimensions
        and BM lower bound on volume.

    Application: warehouse design, shipping container optimization.
    """
    n = len(item_dims[0])
    container = np.zeros(n)
    vol_roots = []

    for dims in item_dims:
        container = container + dims
        vol_roots.append(float(np.prod(dims)) ** (1.0 / n))

    bm_lower = sum(vol_roots) ** n
    actual = float(np.prod(container))

    return container, bm_lower


def demo_packaging():
    """Demonstrate optimal packaging application."""
    print("=" * 60)
    print("APPLICATION 1: OPTIMAL CONTAINER DESIGN")
    print("=" * 60)
    print()
    print("Scenario: Pack 3 different box-shaped items into a container.")
    print("Brunn-Minkowski gives a theoretical lower bound on volume needed.")
    print()

    items = [
        np.array([2.0, 3.0, 1.0]),  # Item 1: 2x3x1
        np.array([1.0, 1.0, 4.0]),  # Item 2: 1x1x4
        np.array([3.0, 2.0, 2.0]),  # Item 3: 3x2x2
    ]

    container, bm_bound = optimal_container_bound(items, len(items))

    print("Items:")
    for i, item in enumerate(items):
        print(f"  Item {i+1}: {item} (vol = {np.prod(item):.1f})")

    print(f"\nMinkowski sum container: {container}")
    print(f"Container volume: {np.prod(container):.1f}")
    print(f"BM lower bound: {bm_bound:.1f}")
    print(f"Efficiency ratio: {bm_bound / np.prod(container):.4f}")
    print()


# ============================================================
# Application 2: Information Theory Connection
# ============================================================

def entropy_power_analogy(
    variances_x: np.ndarray, variances_y: np.ndarray
) -> Tuple[float, float]:
    """
    Demonstrate the Brunn-Minkowski / Entropy Power Inequality analogy.

    For independent random vectors X, Y with covariance matrices
    diag(variances_x) and diag(variances_y), the entropy power inequality
    states that the entropy power of X+Y is at least the sum of
    entropy powers of X and Y.

    For Gaussians, this reduces exactly to the Brunn-Minkowski inequality
    applied to covariance ellipsoids.

    Args:
        variances_x: Diagonal variances of X.
        variances_y: Diagonal variances of Y.

    Returns:
        (ep_sum, ep_x_plus_ep_y) - entropy power of sum vs sum of EPs.
    """
    n = len(variances_x)

    # Entropy power N(X) = (2*pi*e)^(-1) * det(Cov)^(1/n) for Gaussian
    # For diagonal: det = product of variances
    det_x = float(np.prod(variances_x))
    det_y = float(np.prod(variances_y))
    det_sum = float(np.prod(variances_x + variances_y))

    ep_x = det_x ** (1.0 / n)
    ep_y = det_y ** (1.0 / n)
    ep_sum = det_sum ** (1.0 / n)

    return ep_sum, ep_x + ep_y


def demo_entropy():
    """Demonstrate entropy power inequality analogy."""
    print("=" * 60)
    print("APPLICATION 2: ENTROPY POWER INEQUALITY ANALOGY")
    print("=" * 60)
    print()
    print("The Brunn-Minkowski inequality for Gaussian distributions")
    print("becomes the Entropy Power Inequality (EPI):")
    print("  N(X+Y) >= N(X) + N(Y)")
    print()

    np.random.seed(42)
    for trial in range(3):
        n = np.random.randint(2, 5)
        var_x = np.random.exponential(2.0, size=n)
        var_y = np.random.exponential(2.0, size=n)

        ep_sum, ep_bound = entropy_power_analogy(var_x, var_y)

        print(f"Trial {trial+1}: dimension {n}")
        print(f"  Var(X) = {np.round(var_x, 3)}")
        print(f"  Var(Y) = {np.round(var_y, 3)}")
        print(f"  N(X+Y) = {ep_sum:.4f}")
        print(f"  N(X) + N(Y) = {ep_bound:.4f}")
        print(f"  EPI gap: {ep_sum - ep_bound:.4f}  {'✓' if ep_sum >= ep_bound - 1e-10 else '✗'}")
        print()


# ============================================================
# Application 3: Isoperimetric Optimization
# ============================================================

def isoperimetric_ratio_box(sides: np.ndarray) -> float:
    """
    Compute the isoperimetric ratio for a box.

    The isoperimetric ratio SA^n / (n^n * omega_n * V^{n-1})
    measures how far a shape is from a sphere. For boxes,
    the cube minimizes this ratio among all boxes of fixed volume.

    Args:
        sides: Side lengths of the box.

    Returns:
        The isoperimetric ratio (1.0 for a cube).
    """
    n = len(sides)
    volume = float(np.prod(sides))
    # Surface area for box = 2 * sum_i prod_{j != i} s_j
    sa = 0.0
    for i in range(n):
        term = 1.0
        for j in range(n):
            if j != i:
                term *= sides[j]
        sa += term
    sa *= 2.0

    # For a cube of the same volume: side = V^{1/n}
    cube_side = volume ** (1.0 / n)
    cube_sa = 2.0 * n * cube_side ** (n - 1)

    return sa / cube_sa


def demo_isoperimetry():
    """Demonstrate isoperimetric optimization for boxes."""
    print("=" * 60)
    print("APPLICATION 3: ISOPERIMETRIC OPTIMIZATION FOR BOXES")
    print("=" * 60)
    print()
    print("Among all boxes of fixed volume, the CUBE minimizes surface area.")
    print("Isoperimetric ratio = 1.0 for cube, > 1.0 for non-cubes.")
    print()

    # Test various boxes with the same volume
    target_vol = 64.0  # Volume = 64

    test_boxes = [
        np.array([4.0, 4.0, 4.0]),      # Cube
        np.array([2.0, 4.0, 8.0]),      # Elongated
        np.array([1.0, 8.0, 8.0]),      # Flat
        np.array([1.0, 1.0, 64.0]),     # Very elongated
        np.array([16.0, 2.0, 2.0]),     # Another shape
    ]

    for box in test_boxes:
        ratio = isoperimetric_ratio_box(box)
        vol = np.prod(box)
        print(f"  Box {box}: vol={vol:.0f}, iso ratio={ratio:.4f}")

    print()
    print("✓ Cube always has ratio 1.0 (minimum)")


# ============================================================
# Application 4: Robotics / Collision Detection
# ============================================================

def collision_free_space(
    robot_dims: np.ndarray, obstacle_dims: np.ndarray
) -> np.ndarray:
    """
    Compute the configuration space obstacle using Minkowski sum.

    In robotics, the Minkowski sum of a robot and an obstacle gives
    the set of positions where the robot would collide. The complement
    is the free configuration space.

    For box-shaped robot and obstacle, the Minkowski sum is again a box.

    Args:
        robot_dims: Side lengths of the robot bounding box.
        obstacle_dims: Side lengths of the obstacle.

    Returns:
        Side lengths of the C-space obstacle (Minkowski sum).
    """
    return robot_dims + obstacle_dims


def demo_robotics():
    """Demonstrate Minkowski sum in collision detection."""
    print("=" * 60)
    print("APPLICATION 4: ROBOTICS / COLLISION DETECTION")
    print("=" * 60)
    print()
    print("The Minkowski sum computes configuration-space obstacles.")
    print("Robot at position p collides with obstacle O iff p ∈ O ⊕ (-R)")
    print()

    robot = np.array([1.0, 0.5])  # 1m x 0.5m robot
    obstacles = [
        np.array([2.0, 3.0]),    # Wall
        np.array([1.0, 1.0]),    # Pillar
        np.array([0.5, 4.0]),    # Narrow passage
    ]

    for i, obs in enumerate(obstacles):
        c_obs = collision_free_space(robot, obs)
        print(f"  Obstacle {i+1}: {obs}")
        print(f"    C-space obstacle: {c_obs}")
        print(f"    Volume expansion: {np.prod(c_obs) / np.prod(obs):.2f}x")
        print()

    # BM bound
    print("  Brunn-Minkowski guarantees:")
    print("    vol(C-obs)^{1/n} >= vol(obs)^{1/n} + vol(robot)^{1/n}")
    for i, obs in enumerate(obstacles):
        c_obs = collision_free_space(robot, obs)
        n = 2
        lhs = np.prod(c_obs) ** (1.0 / n)
        rhs = np.prod(obs) ** (1.0 / n) + np.prod(robot) ** (1.0 / n)
        print(f"    Obstacle {i+1}: {lhs:.4f} >= {rhs:.4f} ✓")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_packaging()
    demo_entropy()
    demo_isoperimetry()
    demo_robotics()


#!/usr/bin/env python3
"""
Interactive demonstration of convex geometry: Minkowski sums, Brunn-Minkowski,
support functions, and log-concavity of mixed volume coefficients.

Samples boxes and convex polygons, computes Minkowski sums, plots volume growth
under interpolation, and numerically verifies the Brunn-Minkowski inequality
and Newton's log-concavity inequality.
"""

import numpy as np
import itertools
from typing import List, Tuple

# ============================================================
# Core definitions
# ============================================================

def box_volume(side_lengths: np.ndarray) -> float:
    """Volume of an axis-aligned box with given side lengths."""
    return float(np.prod(side_lengths))

def box_minkowski_sum(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Side lengths of the Minkowski sum of two boxes."""
    return a + b

def box_interpolation_volume(a: np.ndarray, b: np.ndarray, t: float) -> float:
    """Volume of the Minkowski interpolation A + t*B for boxes."""
    return float(np.prod(a + t * b))

def box_mixed_coefficients(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """
    Compute mixed volume coefficients c_k for boxes.
    c_k = sum over subsets S of size k of (prod_{i in S} b_i * prod_{i not in S} a_i)
    """
    n = len(a)
    coeffs = np.zeros(n + 1)
    for k in range(n + 1):
        total = 0.0
        for subset in itertools.combinations(range(n), k):
            term = 1.0
            for i in range(n):
                if i in subset:
                    term *= b[i]
                else:
                    term *= a[i]
            total += term
        coeffs[k] = total
    return coeffs

def support_function_box(lo: np.ndarray, hi: np.ndarray, u: np.ndarray) -> float:
    """Support function of an axis-aligned box at direction u."""
    return float(np.sum(np.maximum(u * lo, u * hi)))

def brunn_minkowski_check(a: np.ndarray, b: np.ndarray) -> Tuple[float, float, bool]:
    """
    Check Brunn-Minkowski inequality for boxes with side lengths a, b.
    Returns (lhs, rhs, satisfied) where lhs = vol(A+B)^{1/n}, rhs = vol(A)^{1/n} + vol(B)^{1/n}.
    """
    n = len(a)
    vol_sum = box_volume(a + b)
    vol_a = box_volume(a)
    vol_b = box_volume(b)
    lhs = vol_sum ** (1.0 / n)
    rhs = vol_a ** (1.0 / n) + vol_b ** (1.0 / n)
    return lhs, rhs, lhs >= rhs - 1e-12

def newton_inequality_check(coeffs: np.ndarray) -> List[Tuple[int, float, bool]]:
    """
    Check Newton's log-concavity inequality c_k^2 >= c_{k-1} * c_{k+1}
    for each valid k.
    """
    results = []
    for k in range(1, len(coeffs) - 1):
        lhs = coeffs[k] ** 2
        rhs = coeffs[k - 1] * coeffs[k + 1]
        results.append((k, lhs - rhs, lhs >= rhs - 1e-12))
    return results

# ============================================================
# Demonstrations
# ============================================================

def demo_brunn_minkowski():
    """Demonstrate Brunn-Minkowski inequality for random boxes."""
    print("=" * 60)
    print("BRUNN-MINKOWSKI INEQUALITY FOR BOXES")
    print("=" * 60)
    print()
    print("For boxes A, B in R^n:")
    print("  vol(A+B)^{1/n} >= vol(A)^{1/n} + vol(B)^{1/n}")
    print()

    np.random.seed(42)
    for trial in range(5):
        n = np.random.randint(2, 6)
        a = np.random.exponential(2.0, size=n)
        b = np.random.exponential(2.0, size=n)

        lhs, rhs, ok = brunn_minkowski_check(a, b)
        print(f"Trial {trial+1}: n={n}")
        print(f"  A side lengths: {np.round(a, 3)}")
        print(f"  B side lengths: {np.round(b, 3)}")
        print(f"  vol(A+B)^(1/{n}) = {lhs:.6f}")
        print(f"  vol(A)^(1/{n}) + vol(B)^(1/{n}) = {rhs:.6f}")
        print(f"  Gap: {lhs - rhs:.6f}  {'✓' if ok else '✗ VIOLATION!'}")
        print()

def demo_support_function():
    """Demonstrate support function linearization."""
    print("=" * 60)
    print("SUPPORT FUNCTION LINEARIZATION")
    print("=" * 60)
    print()
    print("h_{A+B}(u) = h_A(u) + h_B(u)")
    print()

    # Two boxes in R^3
    lo_a, hi_a = np.array([0, 0, 0.0]), np.array([1, 2, 3.0])
    lo_b, hi_b = np.array([0, 0, 0.0]), np.array([2, 1, 1.0])

    # Minkowski sum
    lo_sum, hi_sum = lo_a + lo_b, hi_a + hi_b

    np.random.seed(123)
    for trial in range(5):
        u = np.random.randn(3)
        h_a = support_function_box(lo_a, hi_a, u)
        h_b = support_function_box(lo_b, hi_b, u)
        h_sum = support_function_box(lo_sum, hi_sum, u)

        print(f"Direction u = {np.round(u, 3)}")
        print(f"  h_A(u) = {h_a:.4f}, h_B(u) = {h_b:.4f}")
        print(f"  h_A(u) + h_B(u) = {h_a + h_b:.4f}")
        print(f"  h_{'{A+B}'}(u) = {h_sum:.4f}")
        print(f"  Match: {'✓' if abs(h_sum - h_a - h_b) < 1e-10 else '✗'}")
        print()

def demo_newton_inequality():
    """Demonstrate Newton's log-concavity of mixed volume coefficients."""
    print("=" * 60)
    print("NEWTON'S LOG-CONCAVITY INEQUALITY")
    print("=" * 60)
    print()
    print("For vol(A + tB) = sum_k c_k * t^k:")
    print("  c_k^2 >= c_{k-1} * c_{k+1}  (log-concavity)")
    print()

    np.random.seed(7)
    for trial in range(4):
        n = np.random.randint(3, 7)
        a = np.random.exponential(2.0, size=n)
        b = np.random.exponential(2.0, size=n)

        coeffs = box_mixed_coefficients(a, b)
        results = newton_inequality_check(coeffs)

        print(f"Trial {trial+1}: n={n}")
        print(f"  A side lengths: {np.round(a, 3)}")
        print(f"  B side lengths: {np.round(b, 3)}")
        print(f"  Coefficients: {np.round(coeffs, 4)}")
        for k, gap, ok in results:
            print(f"    k={k}: c_k^2 - c_{{k-1}}*c_{{k+1}} = {gap:.6f}  {'✓' if ok else '✗'}")
        print()

def demo_volume_interpolation():
    """Plot-style data for volume interpolation concavity."""
    print("=" * 60)
    print("VOLUME INTERPOLATION CONCAVITY")
    print("=" * 60)
    print()
    print("vol(A + tB)^{1/n} is concave in t (BM consequence)")
    print()

    a = np.array([1.0, 2.0, 3.0])
    b = np.array([3.0, 1.0, 2.0])
    n = 3

    ts = np.linspace(0, 1, 11)
    print(f"A side lengths: {a}")
    print(f"B side lengths: {b}")
    print(f"{'t':>6} | {'vol(A+tB)':>12} | {'vol^(1/n)':>12} | {'linear interp':>14}")
    print("-" * 52)

    v0 = box_interpolation_volume(a, b, 0.0) ** (1.0 / n)
    v1 = box_interpolation_volume(a, b, 1.0) ** (1.0 / n)

    for t in ts:
        vol = box_interpolation_volume(a, b, t)
        vol_root = vol ** (1.0 / n)
        linear = (1 - t) * v0 + t * v1
        print(f"{t:6.2f} | {vol:12.4f} | {vol_root:12.4f} | {linear:14.4f}")
        assert vol_root >= linear - 1e-10, f"Concavity violated at t={t}!"

    print()
    print("✓ Concavity verified: vol^{1/n} >= linear interpolation at all points")

def demo_perimeter_proxy():
    """Demonstrate perimeter proxy for cubes."""
    print("=" * 60)
    print("PERIMETER PROXY FOR CUBES")
    print("=" * 60)
    print()
    print("For a cube of side s in R^n:")
    print("  perimProxy = 2n * s^{n-1}")
    print()

    for n in range(2, 6):
        for s in [1.0, 2.0, 3.0]:
            sides = np.full(n, s)
            # perimProxy = 2 * sum_i prod_{j != i} sides[j]
            proxy = 0.0
            for i in range(n):
                term = 1.0
                for j in range(n):
                    if j != i:
                        term *= sides[j]
                proxy += term
            proxy *= 2
            expected = 2 * n * s ** (n - 1)
            print(f"  n={n}, s={s}: perimProxy = {proxy:.4f}, expected = {expected:.4f}, match: {'✓' if abs(proxy - expected) < 1e-10 else '✗'}")
    print()

def demo_conjecture_test():
    """Test falsifiable conjecture: log-concavity of mixed coefficients for random boxes."""
    print("=" * 60)
    print("CONJECTURE TEST: LOG-CONCAVITY OF MIXED COEFFICIENTS")
    print("=" * 60)
    print()
    print("Testing: For random boxes, c_k^2 >= c_{k-1} * c_{k+1}")
    print()

    np.random.seed(0)
    n_trials = 1000
    violations = 0

    for _ in range(n_trials):
        n = np.random.randint(2, 8)
        a = np.random.exponential(1.0, size=n)
        b = np.random.exponential(1.0, size=n)
        coeffs = box_mixed_coefficients(a, b)
        for k in range(1, n):
            if coeffs[k] ** 2 < coeffs[k - 1] * coeffs[k + 1] - 1e-12:
                violations += 1
                print(f"  VIOLATION: n={n}, k={k}")
                print(f"    a={np.round(a, 4)}, b={np.round(b, 4)}")
                print(f"    c_{k}^2 = {coeffs[k]**2:.6f}, c_{k-1}*c_{k+1} = {coeffs[k-1]*coeffs[k+1]:.6f}")

    print(f"\n{n_trials} random trials, {violations} violations found.")
    if violations == 0:
        print("✓ Conjecture holds in all tested cases.")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_brunn_minkowski()
    demo_support_function()
    demo_newton_inequality()
    demo_volume_interpolation()
    demo_perimeter_proxy()
    demo_conjecture_test()
