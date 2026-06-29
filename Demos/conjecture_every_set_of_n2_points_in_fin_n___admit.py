"""
Applications of Tropical Radon Partitions

Demonstrates connections to shortest-path geometry, scheduling,
and optimization via min-plus algebra.
"""

from typing import List, Tuple, Optional
from algorithms import (tropical_combination, find_radon_partition,
                         tropical_segment_sample)


def shortest_path_intersection():
    """
    Application: Shortest-path redundancy detection.

    In a network with n nodes and m source-sink pairs, the shortest-path
    distances from each source form a point in ℚ^n (min-plus space).
    A tropical Radon partition reveals that some sources can be grouped
    into two families whose "reachability profiles" overlap — meaning
    the network has redundant coverage.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Redundancy Detection")
    print("=" * 60)

    # 4 sources, distances to 2 destinations
    # Source i has distances [d(i,0), d(i,1)] to destinations 0, 1
    distances = [
        [2, 7],   # Source 0: close to dest 0, far from dest 1
        [8, 3],   # Source 1: far from dest 0, close to dest 1
        [4, 5],   # Source 2: moderate to both
        [6, 4],   # Source 3: moderate-far to dest 0, moderate-close to dest 1
    ]

    print("\nNetwork: 4 sources, 2 destinations")
    print("Distance matrix (source → destination):")
    for i, d in enumerate(distances):
        print(f"  Source {i}: {d}")

    result = find_radon_partition(distances)
    if result:
        A, B = result['A'], result['B']
        z = result['z']
        print(f"\nRadon partition found!")
        print(f"  Group A (sources {A}): their tropical hull")
        print(f"  Group B (sources {B}): their tropical hull")
        print(f"  Shared reachability profile: z = {z}")
        print(f"\n  Interpretation: Both groups can achieve the same")
        print(f"  best-case distance profile {z} to all destinations.")
        print(f"  This means Group A is a redundant backup for Group B.")


def scheduling_overlap():
    """
    Application: Schedule feasibility overlap.

    In min-plus scheduling, each job i has a profile p_i ∈ ℚ^n giving
    the earliest completion time at each stage. A tropical Radon partition
    shows that two disjoint job subsets have overlapping feasibility regions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Schedule Feasibility Overlap")
    print("=" * 60)

    # 4 jobs, 2 processing stages
    # Job i: [earliest_finish_stage_0, earliest_finish_stage_1]
    jobs = [
        [1, 6],   # Job 0: fast at stage 0, slow at stage 1
        [5, 2],   # Job 1: slow at stage 0, fast at stage 1
        [3, 4],   # Job 2: balanced
        [4, 3],   # Job 3: slightly slow at stage 0
    ]

    print("\nScheduling: 4 jobs across 2 stages")
    print("Earliest completion times:")
    for i, j in enumerate(jobs):
        print(f"  Job {i}: Stage 0 = {j[0]}, Stage 1 = {j[1]}")

    result = find_radon_partition(jobs)
    if result:
        A, B = result['A'], result['B']
        z = result['z']
        print(f"\nRadon partition:")
        print(f"  Subset A = jobs {A}")
        print(f"  Subset B = jobs {B}")
        print(f"  Shared schedule point: {z}")
        print(f"\n  Both subsets can achieve completion profile {z}")
        print(f"  via appropriate job delays (tropical weights).")


def tropical_halfspace_certificate():
    """
    Application: Infeasibility certificate for tropical linear systems.

    A tropical Radon partition provides a certificate that a system
    of tropical linear inequalities has redundant constraints.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Linear System Redundancy")
    print("=" * 60)

    # Each row defines a tropical halfspace constraint
    constraints = [
        [0, 0],   # Constraint: min(x₀, x₁) ≤ 0
        [2, -1],  # Constraint: min(x₀+2, x₁-1) ≤ 0
        [-1, 3],  # Constraint: min(x₀-1, x₁+3) ≤ 0
        [1, 1],   # Constraint: min(x₀+1, x₁+1) ≤ 0
    ]

    print("\nTropical linear system: 4 constraints in ℚ²")
    for i, c in enumerate(constraints):
        print(f"  Constraint {i}: min(x₀{c[0]:+}, x₁{c[1]:+}) ≤ 0")

    result = find_radon_partition(constraints)
    if result:
        A, B = result['A'], result['B']
        print(f"\nRadon partition: A={A}, B={B}")
        print(f"  The constraints in A and B have overlapping")
        print(f"  tropical regions — constraint set is redundant.")
        print(f"  One of the two groups can be removed without")
        print(f"  changing the feasible region.")


def dynamic_programming_example():
    """
    Application: Dynamic programming state compression.

    In DP over a min-plus semiring, states correspond to points in ℚ^n.
    A Radon partition identifies states that can be compressed because
    their value functions overlap tropically.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: DP State Compression via Tropical Radon")
    print("=" * 60)

    # 4 DP states, each with a 2-dimensional value function
    states = [
        [10, 3],   # State 0: high cost path 0, low cost path 1
        [4, 9],    # State 1: low cost path 0, high cost path 1
        [6, 6],    # State 2: balanced
        [7, 5],    # State 3: slightly imbalanced
    ]

    print("\nDynamic programming: 4 states, 2 successor paths")
    print("Cost vectors (min-plus values):")
    for i, s in enumerate(states):
        print(f"  State {i}: {s}")

    result = find_radon_partition(states)
    if result:
        A, B = result['A'], result['B']
        z = result['z']
        print(f"\nRadon partition: A={A}, B={B}")
        print(f"  Shared optimal profile: z = {z}")
        print(f"\n  States in A and states in B can reach the same")
        print(f"  optimal cost profile. In a DP table, one group")
        print(f"  can be pruned without losing optimality.")


if __name__ == "__main__":
    shortest_path_intersection()
    scheduling_overlap()
    tropical_halfspace_certificate()
    dynamic_programming_example()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Tropical Radon Theorem — Interactive Demonstrations

This module demonstrates the tropical Radon partition theorem with
concrete numerical examples in low dimensions, visualizing how
min-plus convex hulls of disjoint point families can intersect.
"""

from itertools import combinations
from typing import List, Tuple, Optional
import math


def trop_conv_hull_pair(p1: List[float], p2: List[float],
                        w1: float, w2: float) -> List[float]:
    """Compute a tropical convex combination of two points with given weights.

    Returns z where z[k] = min(w1 + p1[k], w2 + p2[k]).
    """
    return [min(w1 + p1[k], w2 + p2[k]) for k in range(len(p1))]


def is_constant_shift(p1: List[float], p2: List[float], tol: float = 1e-12) -> bool:
    """Check if p1 - p2 is a constant vector (tropical equivalence)."""
    if len(p1) != len(p2) or len(p1) == 0:
        return True
    diff = p1[0] - p2[0]
    return all(abs((p1[k] - p2[k]) - diff) < tol for k in range(len(p1)))


def find_radon_partition_2d(points: List[List[float]]) -> Optional[dict]:
    """Find a tropical Radon partition for points in ℚ^2.

    Uses the median-slope construction:
    1. Compute slopes α_i = p_i[1] - p_i[0]
    2. Find median index i_med with α_lo ≤ α_med ≤ α_hi
    3. Return A = {i_med}, B = {i_lo, i_hi}

    Args:
        points: List of points in ℚ^2 (each a list of 2 rationals).

    Returns:
        Dictionary with keys 'A', 'B', 'z', 'weights_A', 'weights_B',
        or None if fewer than 3 points are provided.
    """
    if len(points) < 3:
        return None

    n = len(points[0])
    assert n == 2, "This function is for 2D points only"

    # Compute slopes
    slopes = [(points[i][1] - points[i][0], i) for i in range(len(points))]
    slopes.sort(key=lambda x: x[0])

    # Pick median (second element in sorted order)
    i_lo = slopes[0][1]
    i_med = slopes[1][1]
    i_hi = slopes[2][1]

    alpha_lo = points[i_lo][1] - points[i_lo][0]
    alpha_med = points[i_med][1] - points[i_med][0]
    alpha_hi = points[i_hi][1] - points[i_hi][0]

    assert alpha_lo <= alpha_med <= alpha_hi

    # Weights for the B-side tropical combination
    w_hi = points[i_med][0] - points[i_hi][0]  # tight at coord 0
    w_lo = points[i_med][1] - points[i_lo][1]  # tight at coord 1

    # Witness point
    z = points[i_med][:]

    # Verify
    z_check = trop_conv_hull_pair(points[i_hi], points[i_lo], w_hi, w_lo)
    assert all(abs(z[k] - z_check[k]) < 1e-10 for k in range(n)), \
        f"Verification failed: z={z}, z_check={z_check}"

    return {
        'A': [i_med],
        'B': [i_hi, i_lo],
        'z': z,
        'weights_A': [0.0],  # z = 0 + p[i_med]
        'weights_B': [w_hi, w_lo],
        'alpha_lo': alpha_lo,
        'alpha_med': alpha_med,
        'alpha_hi': alpha_hi,
    }


def verify_hull_membership(z, points, weights):
    """Verify that z is in the tropical convex hull of points with given weights."""
    n = len(z)
    m = len(points)
    for k in range(n):
        val = min(weights[i] + points[i][k] for i in range(m))
        if abs(val - z[k]) > 1e-10:
            return False
    return True


# ─── DEMO 1: Basic tropical convex hull ───

def demo_basic_hull():
    print("=" * 60)
    print("DEMO 1: Tropical Convex Hull Basics")
    print("=" * 60)

    p1 = [0, 0]
    p2 = [3, 1]

    print(f"\nTwo points in ℚ²: p₁ = {p1}, p₂ = {p2}")
    print("\nTropical convex hull = {z : z[k] = min(w₁+p₁[k], w₂+p₂[k])}")
    print("\nSample tropical combinations (varying w₁, w₂):")

    for w1, w2 in [(0, 0), (0, -1), (-2, 0), (1, -1), (-1, 1)]:
        z = trop_conv_hull_pair(p1, p2, w1, w2)
        print(f"  w₁={w1:+}, w₂={w2:+}  →  z = {z}")


# ─── DEMO 2: Tropical Radon partition in ℚ² ───

def demo_radon_2d():
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Radon Partition in ℚ²")
    print("=" * 60)

    points = [[0, 0], [3, 1], [1, 4], [2, 2]]
    print(f"\n4 points in ℚ²:")
    for i, p in enumerate(points):
        print(f"  p[{i}] = {p}   (slope α = {p[1]-p[0]:+.1f})")

    result = find_radon_partition_2d(points)
    if result:
        A, B = result['A'], result['B']
        z = result['z']
        print(f"\nRadon partition found!")
        print(f"  A = {{{', '.join(str(i) for i in A)}}}  (singleton)")
        print(f"  B = {{{', '.join(str(i) for i in B)}}}")
        print(f"  Witness z = {z}")
        print(f"\n  A-side: z = p[{A[0]}] + 0 ✓")
        wB = result['weights_B']
        print(f"  B-side: z[k] = min({wB[0]:.1f}+p[{B[0]}][k], {wB[1]:.1f}+p[{B[1]}][k])")

        # Verify
        ok_A = verify_hull_membership(z, [points[i] for i in A], result['weights_A'])
        ok_B = verify_hull_membership(z, [points[i] for i in B], result['weights_B'])
        print(f"\n  Verification: A-hull ✓={ok_A}, B-hull ✓={ok_B}")


# ─── DEMO 3: Multiple configurations ───

def demo_many_configs():
    print("\n" + "=" * 60)
    print("DEMO 3: Radon Partitions for Various Configurations")
    print("=" * 60)

    configs = [
        ("Standard basis-like", [[0,0], [1,0], [0,1], [1,1]]),
        ("Collinear (x=0)",     [[0,0], [0,1], [0,2], [0,3]]),
        ("Random-looking",      [[1,5], [3,2], [7,4], [2,8]]),
        ("Large spread",        [[0,0], [100,0], [0,100], [50,50]]),
        ("Negative coords",     [[-3,2], [1,-4], [5,3], [-2,-1]]),
    ]

    for name, pts in configs:
        result = find_radon_partition_2d(pts)
        if result:
            A, B, z = result['A'], result['B'], result['z']
            ok_A = verify_hull_membership(z, [pts[i] for i in A], result['weights_A'])
            ok_B = verify_hull_membership(z, [pts[i] for i in B], result['weights_B'])
            status = "✓" if (ok_A and ok_B) else "✗"
            print(f"\n  {name}:")
            print(f"    Points: {pts}")
            print(f"    A={A}, B={B}, z={z}  [{status}]")


# ─── DEMO 4: Tropical equivalence detection ───

def demo_tropical_equivalence():
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Equivalence Detection")
    print("=" * 60)

    pairs = [
        ([0, 0], [3, 3]),    # equivalent (diff = [-3,-3])
        ([1, 2], [4, 5]),    # equivalent (diff = [-3,-3])
        ([0, 0], [1, 2]),    # NOT equivalent (diff = [-1,-2])
        ([1, 3, 5], [2, 4, 6]),  # equivalent in ℚ³
        ([1, 3, 5], [2, 4, 7]),  # NOT equivalent in ℚ³
    ]

    for p1, p2 in pairs:
        eq = is_constant_shift(p1, p2)
        diff = [p1[k] - p2[k] for k in range(len(p1))]
        print(f"\n  p₁={p1}, p₂={p2}")
        print(f"  Difference: {diff}")
        print(f"  Tropically equivalent: {eq}")


if __name__ == "__main__":
    demo_basic_hull()
    demo_radon_2d()
    demo_many_configs()
    demo_tropical_equivalence()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
