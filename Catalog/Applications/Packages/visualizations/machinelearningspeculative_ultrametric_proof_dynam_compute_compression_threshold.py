#!/usr/bin/env python3
"""
Algorithms for Ultrametric Proof Dynamics

Implements the core algorithms derived from the theorems in
UltrametricProofLearning.lean.
"""

import numpy as np
from typing import Callable, Tuple, Optional


def compute_compression_threshold(
    q: float, d0: float, epsilon: float
) -> int:
    """
    Compute the minimal iteration count N such that q^N · d0 ≤ ε.

    Based on compression_threshold_exists theorem.

    Algorithm:
        N = ⌈log(ε / d0) / log(q)⌉

    Complexity: O(1) time and space.

    Args:
        q: Contraction ratio, 0 ≤ q < 1
        d0: Initial compression radius d(F(x), x)
        epsilon: Target accuracy ε > 0

    Returns:
        Minimal N such that q^N · d0 ≤ ε

    Examples:
        >>> compute_compression_threshold(0.5, 100.0, 0.01)
        14
        >>> compute_compression_threshold(0.9, 1.0, 0.001)
        66
    """
    if d0 <= 0:
        return 0
    if q <= 0:
        return 1 if d0 > epsilon else 0
    if epsilon >= d0:
        return 0
    return int(np.ceil(np.log(epsilon / d0) / np.log(q)))


def iterate_with_certification(
    F: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    q: float,
    epsilon: float,
    max_iter: int = 10000,
    dist: Optional[Callable[[np.ndarray, np.ndarray], float]] = None,
) -> Tuple[np.ndarray, int, float]:
    """
    Iterate F from x0 until the compression threshold ε is reached.

    Based on certified_orbit_radius and compression_threshold_exists theorems.
    Uses the diagonal stability guarantee: step distances are monotone decreasing,
    so we can safely stop as soon as one step is below ε.

    Algorithm:
        1. Compute x_{n+1} = F(x_n)
        2. Check d(x_n, x_{n+1}) ≤ ε
        3. Return x_N when threshold is met

    Complexity: O(N · cost(F)) where N = O(log(1/ε) / log(1/q)).

    Args:
        F: Contractive map
        x0: Initial point
        q: Contraction ratio (for certification, not used in iteration)
        epsilon: Target accuracy
        max_iter: Safety limit on iterations
        dist: Distance function (default: L-infinity)

    Returns:
        (final_point, num_iterations, final_step_distance)

    Certificate: By iterate_step_bound_geometric, the returned point satisfies
        d(x_N, F(x_N)) ≤ ε, and by certified_orbit_radius, all subsequent
        iterates remain within d(F(x0), x0) of x0.
    """
    if dist is None:
        dist = lambda a, b: float(np.max(np.abs(a - b)))

    current = x0.copy()
    for n in range(max_iter):
        next_val = F(current)
        step_dist = dist(current, next_val)
        if step_dist <= epsilon:
            return next_val, n + 1, step_dist
        current = next_val

    return current, max_iter, dist(current, F(current))


def certified_pruning_depth(
    q: float, initial_radius: float, epsilon: float
) -> int:
    """
    Compute the depth beyond which network layers can be pruned.

    Based on entropy_capacity_ultrametric_barrier: after N layers,
    the compression radius is at most q^N · initial_radius.

    Complexity: O(1).

    Args:
        q: Per-layer contraction ratio
        initial_radius: Compression radius of first layer
        epsilon: Maximum tolerable compression radius

    Returns:
        Minimum depth N such that q^N · initial_radius ≤ ε
    """
    return compute_compression_threshold(q, initial_radius, epsilon)


def orbit_separation_bound(
    q: float, d_xy: float, n: int
) -> float:
    """
    Compute the guaranteed separation bound between two orbits at step n.

    Based on iterate_pair_bound_geometric: d(F^n(x), F^n(y)) ≤ q^n · d(x,y).

    Args:
        q: Contraction ratio
        d_xy: Initial distance d(x, y)
        n: Iteration step

    Returns:
        Upper bound q^n · d(x,y) on the distance between orbits at step n.
    """
    return q**n * d_xy


def orbit_diameter_bound(
    q: float, d_Fx_x: float, m: int, n: int
) -> float:
    """
    Compute the orbit diameter collapse bound.

    Based on ultrametric_orbit_diameter_collapse:
        d(F^m(x), F^n(x)) ≤ max(q^m, q^n) · d(F(x), x)

    Args:
        q: Contraction ratio
        d_Fx_x: Initial step distance d(F(x), x)
        m, n: Iteration steps

    Returns:
        Upper bound max(q^m, q^n) · d(F(x), x).
    """
    return max(q**m, q**n) * d_Fx_x


def verify_ultrametric(
    points: list, dist: Callable
) -> bool:
    """
    Verify that a set of points with a given distance function satisfies
    the ultrametric inequality.

    Checks: ∀ x y z, d(x,z) ≤ max(d(x,y), d(y,z))

    Complexity: O(n³) where n = len(points).

    Args:
        points: List of points
        dist: Distance function

    Returns:
        True if ultrametric inequality holds for all triples.
    """
    n = len(points)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                dxz = dist(points[i], points[k])
                dxy = dist(points[i], points[j])
                dyz = dist(points[j], points[k])
                if dxz > max(dxy, dyz) + 1e-12:
                    return False
    return True


if __name__ == "__main__":
    # Example usage
    print("Compression threshold for q=0.5, d0=100, ε=0.01:")
    N = compute_compression_threshold(0.5, 100.0, 0.01)
    print(f"  N = {N} iterations")
    print(f"  Verification: 0.5^{N} * 100 = {0.5**N * 100:.6e}")

    print()
    print("Certified iteration:")
    F = lambda x: 0.5 * x + np.array([1.0, -0.5])
    result, iters, final_dist = iterate_with_certification(
        F, np.array([100.0, 50.0]), q=0.5, epsilon=0.01
    )
    print(f"  Converged in {iters} iterations")
    print(f"  Final point: {result}")
    print(f"  Final step distance: {final_dist:.6e}")

    print()
    print("Pruning depth for q=0.9, radius=10.0, ε=0.001:")
    depth = certified_pruning_depth(0.9, 10.0, 0.001)
    print(f"  Prune after depth {depth}")


#!/usr/bin/env python3
"""
Applications of Ultrametric Proof Dynamics

Real-world applications in ML, cryptography, and physics.
"""

import numpy as np