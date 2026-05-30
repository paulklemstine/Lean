#!/usr/bin/env python3
"""
applications.py — Real-world applications of Erdős–Szekeres theory.

Applications include:
1. Computational geometry: convex hull quality metrics
2. Pattern recognition: detecting convex structures in data
3. Network routing: monotone path analysis
4. Finance: detecting trend patterns in time series
"""

from typing import List, Tuple
import math
import random

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Orientation predicate."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def longest_increasing_subsequence_length(seq: List[float]) -> int:
    """Length of longest increasing subsequence (O(n log n))."""
    import bisect
    tails = []
    for x in seq:
        pos = bisect.bisect_left(tails, x)
        if pos == len(tails):
            tails.append(x)
        else:
            tails[pos] = x
    return len(tails)


def longest_decreasing_subsequence_length(seq: List[float]) -> int:
    """Length of longest decreasing subsequence."""
    return longest_increasing_subsequence_length([-x for x in seq])


# ============================================================================
# APPLICATION 1: Trend Detection in Financial Time Series
# ============================================================================
def detect_trends(prices: List[float]) -> dict:
    """Analyze a price sequence for trending structure.

    Uses the Erdős-Szekeres theorem to guarantee the existence of trends:
    in any sequence of n prices, there must be an increasing trend of length
    ≥ √n or a decreasing trend of length ≥ √n.

    Returns:
        Dictionary with trend analysis results.
    """
    n = len(prices)
    inc_len = longest_increasing_subsequence_length(prices)
    dec_len = longest_decreasing_subsequence_length(prices)
    guaranteed = math.isqrt(n) + 1

    return {
        "num_prices": n,
        "longest_uptrend": inc_len,
        "longest_downtrend": dec_len,
        "es_guarantee": guaranteed,
        "trend_type": "bullish" if inc_len >= dec_len else "bearish",
        "trend_strength": max(inc_len, dec_len) / n,
    }


# ============================================================================
# APPLICATION 2: Convex Hull Quality Metric
# ============================================================================
def convex_hull_quality(points: List[Point]) -> dict:
    """Measure the "convex quality" of a point set.

    The convex depth (largest convex subset) normalized by total points
    gives a measure of how convex-like the point distribution is.
    """
    n = len(points)
    if n <= 3:
        return {"quality": 1.0, "convex_subset_size": n, "total_points": n}

    # Find largest convex subset (brute force, limited to small n)
    import itertools
    best_size = 3  # At least 3 points in GP form a triangle

    for size in range(min(n, 10), 3, -1):
        found = False
        for combo in itertools.combinations(range(n), size):
            subset = sorted([points[i] for i in combo], key=lambda p: p[0])
            # Check if all x-coords are distinct
            xs = [p[0] for p in subset]
            if len(set(xs)) < len(xs):
                continue
            # Check convexity
            all_pos = True
            all_neg = True
            for i in range(len(subset)):
                for j in range(i + 1, len(subset)):
                    for k in range(j + 1, len(subset)):
                        o = orient(subset[i], subset[j], subset[k])
                        if o <= 0:
                            all_pos = False
                        if o >= 0:
                            all_neg = False
            if all_pos or all_neg:
                best_size = size
                found = True
                break
        if found:
            break

    return {
        "quality": best_size / n,
        "convex_subset_size": best_size,
        "total_points": n,
    }


# ============================================================================
# APPLICATION 3: Network Monotone Path Analysis
# ============================================================================
def monotone_path_analysis(
    node_values: List[float],
    edges: List[Tuple[int, int]],
) -> dict:
    """Analyze a directed graph for monotone paths.

    In a network where each node has a value, a monotone path is one where
    values strictly increase (or decrease) along the path. The ES theorem
    guarantees that long enough paths must contain monotone subpaths.
    """
    n = len(node_values)

    # Build adjacency list
    adj = [[] for _ in range(n)]
    for u, v in edges:
        if u < n and v < n:
            adj[u].append(v)

    # Find longest increasing path using DFS with memoization
    memo = {}

    def longest_inc_path(node: int, visited: frozenset) -> int:
        key = (node, visited)
        if key in memo:
            return memo[key]
        best = 1
        for nbr in adj[node]:
            if nbr not in visited and node_values[nbr] > node_values[node]:
                best = max(best, 1 + longest_inc_path(nbr, visited | {nbr}))
        memo[key] = best
        return best

    max_inc = max(
        (longest_inc_path(i, frozenset({i})) for i in range(n)),
        default=0,
    )

    return {
        "num_nodes": n,
        "num_edges": len(edges),
        "longest_increasing_path": max_inc,
        "es_path_guarantee": math.isqrt(n) + 1,
    }


# ============================================================================
# Example usage
# ============================================================================
if __name__ == "__main__":
    print("APPLICATION 1: Financial Trend Detection")
    print("-" * 50)
    random.seed(42)
    # Simulate a stock price series
    prices = [100.0]
    for _ in range(99):
        prices.append(prices[-1] * (1 + random.gauss(0.001, 0.02)))
    result = detect_trends(prices)
    print(f"  Prices: {len(result['num_prices'])} data points")
    print(f"  Longest uptrend: {result['longest_uptrend']} periods")
    print(f"  Longest downtrend: {result['longest_downtrend']} periods")
    print(f"  ES guarantee: ≥ {result['es_guarantee']} period trend exists")
    print(f"  Market tendency: {result['trend_type']}")
    print(f"  Trend strength: {result['trend_strength']:.2%}")

    print()
    print("APPLICATION 2: Convex Hull Quality")
    print("-" * 50)
    # Points on a circle (high quality)
    circle_pts = [
        (math.cos(2 * math.pi * i / 8), math.sin(2 * math.pi * i / 8))
        for i in range(8)
    ]
    result = convex_hull_quality(circle_pts)
    print(f"  Circle points: quality = {result['quality']:.2f}")
    print(f"  Convex subset: {result['convex_subset_size']}/{result['total_points']}")

    # Random clustered points (lower quality)
    cluster_pts = [(random.gauss(0, 1), random.gauss(0, 1)) for _ in range(8)]
    result = convex_hull_quality(cluster_pts)
    print(f"  Random cluster: quality = {result['quality']:.2f}")
    print(f"  Convex subset: {result['convex_subset_size']}/{result['total_points']}")

    print()
    print("APPLICATION 3: Network Monotone Paths")
    print("-" * 50)
    node_vals = [3, 1, 4, 1, 5, 9, 2, 6]
    edges = [(i, j) for i in range(8) for j in range(i + 1, 8)]
    result = monotone_path_analysis(node_vals, edges)
    print(f"  Nodes: {result['num_nodes']}, Edges: {result['num_edges']}")
    print(f"  Longest increasing path: {result['longest_increasing_path']}")
    print(f"  ES guarantee: ≥ {result['es_path_guarantee']}")


#!/usr/bin/env python3
"""
demo.py — Demonstrations of the Happy End Problem and Erdős–Szekeres theory.

Concrete numerical examples showing:
1. The monotone subsequence theorem in action
2. Cups and caps in point configurations
3. Convex depth computation
4. The orientation predicate
"""

import random
import itertools
from typing import List, Tuple

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Signed area × 2 of triangle (a, b, c).
    Positive = counterclockwise, negative = clockwise, zero = collinear."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def is_convex_position(points: List[Point]) -> bool:
    """Check if points (sorted by x) are in convex position."""
    n = len(points)
    if n <= 2:
        return True
    pts = sorted(points, key=lambda p: p[0])
    signs = set()
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                o = orient(pts[i], pts[j], pts[k])
                if o > 0:
                    signs.add(1)
                elif o < 0:
                    signs.add(-1)
                else:
                    return False  # Collinear = not in general position
    return len(signs) <= 1


def longest_increasing_subsequence(seq: List[float]) -> List[int]:
    """Find indices of a longest increasing subsequence."""
    n = len(seq)
    if n == 0:
        return []
    dp = [1] * n
    parent = [-1] * n
    for i in range(1, n):
        for j in range(i):
            if seq[j] < seq[i] and dp[j] + 1 > dp[i]:
                dp[i] = dp[j] + 1
                parent[i] = j
    idx = max(range(n), key=lambda i: dp[i])
    result = []
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


def longest_decreasing_subsequence(seq: List[float]) -> List[int]:
    """Find indices of a longest decreasing subsequence."""
    n = len(seq)
    if n == 0:
        return []
    dp = [1] * n
    parent = [-1] * n
    for i in range(1, n):
        for j in range(i):
            if seq[j] > seq[i] and dp[j] + 1 > dp[i]:
                dp[i] = dp[j] + 1
                parent[i] = j
    idx = max(range(n), key=lambda i: dp[i])
    result = []
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


def find_convex_subset(points: List[Point], target_size: int) -> List[int]:
    """Find a convex subset of given size (brute-force)."""
    n = len(points)
    for combo in itertools.combinations(range(n), target_size):
        subset = [points[i] for i in combo]
        if is_convex_position(subset):
            return list(combo)
    return []


def convex_depth(points: List[Point]) -> int:
    """Compute the convex depth of a point configuration."""
    n = len(points)
    for k in range(n, 0, -1):
        if find_convex_subset(points, k):
            return k
    return 0


# ============================================================================
# DEMO 1: Erdős-Szekeres Monotone Subsequence Theorem
# ============================================================================
print("=" * 70)
print("DEMO 1: Erdős-Szekeres Monotone Subsequence Theorem")
print("=" * 70)
print()
print("Theorem: Any sequence of > (r-1)(s-1) distinct numbers contains")
print("an increasing subsequence of length r or decreasing of length s.")
print()

# Example: r = s = 4, so (r-1)(s-1) = 9. With 10 elements:
r, s = 4, 4
seq = [3, 1, 8, 2, 7, 4, 6, 5, 10, 9]
print(f"Sequence of length {len(seq)}: {seq}")
print(f"Bound: ({r}-1)×({s}-1) = {(r-1)*(s-1)}, need > {(r-1)*(s-1)} elements")
print(f"We have {len(seq)} > {(r-1)*(s-1)}, so theorem applies.")
print()

inc = longest_increasing_subsequence(seq)
dec = longest_decreasing_subsequence(seq)
print(f"Longest increasing subsequence: {[seq[i] for i in inc]} (length {len(inc)})")
print(f"Longest decreasing subsequence: {[seq[i] for i in dec]} (length {len(dec)})")

assert len(inc) >= r or len(dec) >= s, "Theorem violated!"
print(f"✓ Verified: max(inc_len, dec_len) = {max(len(inc), len(dec))} ≥ {min(r, s)}")

# ============================================================================
# DEMO 2: Orientation Predicate
# ============================================================================
print()
print("=" * 70)
print("DEMO 2: Orientation Predicate")
print("=" * 70)
print()

A = (0, 0)
B = (4, 0)
C = (2, 3)
D = (2, -3)

print(f"Points: A={A}, B={B}, C={C}, D={D}")
print(f"orient(A,B,C) = {orient(A,B,C):+.1f}  (counterclockwise)")
print(f"orient(A,B,D) = {orient(A,B,D):+.1f}  (clockwise)")
print(f"orient(A,C,B) = {orient(A,C,B):+.1f}  (reversed = negated)")
print(f"orient(B,C,A) = {orient(B,C,A):+.1f}  (cyclic = same)")
print()
print("Properties verified:")
print(f"  Antisymmetry: orient(A,B,C) = {orient(A,B,C)}, orient(B,A,C) = {orient(B,A,C)}")
print(f"  Cyclic: orient(A,B,C) = {orient(A,B,C)}, orient(B,C,A) = {orient(B,C,A)}")

# ============================================================================
# DEMO 3: Convex Position and Depth
# ============================================================================
print()
print("=" * 70)
print("DEMO 3: Convex Position and Depth")
print("=" * 70)
print()

# 5 points in convex position (a regular pentagon-ish)
import math
pentagon = [(math.cos(2 * math.pi * i / 5), math.sin(2 * math.pi * i / 5)) for i in range(5)]
pentagon_sorted = sorted(pentagon, key=lambda p: p[0])
print("Pentagon (sorted by x):")
for i, p in enumerate(pentagon_sorted):
    print(f"  P{i} = ({p[0]:.3f}, {p[1]:.3f})")
print(f"In convex position: {is_convex_position(pentagon_sorted)}")
print(f"Convex depth: {convex_depth(pentagon_sorted)}")

# 5 points with one interior point
with_interior = [(0, 0), (4, 0), (4, 4), (0, 4), (2, 2)]
print(f"\nSquare + center point:")
for i, p in enumerate(with_interior):
    print(f"  P{i} = {p}")
print(f"In convex position (all 5): {is_convex_position(with_interior)}")
print(f"Convex depth: {convex_depth(with_interior)}")

# ============================================================================
# DEMO 4: ES(4) = 5 Illustration
# ============================================================================
print()
print("=" * 70)
print("DEMO 4: ES(4) = 5 — Five Points Always Contain a Convex Quadrilateral")
print("=" * 70)
print()

random.seed(42)
for trial in range(5):
    # Generate 5 random points in general position
    pts = [(random.uniform(0, 10), random.uniform(0, 10)) for _ in range(5)]
    quad = find_convex_subset(pts, 4)
    print(f"Trial {trial+1}: Points = {[(f'{p[0]:.2f}', f'{p[1]:.2f}') for p in pts]}")
    if quad:
        print(f"  Convex quadrilateral found at indices: {quad}")
        subset = [pts[i] for i in quad]
        print(f"  Points: {[(f'{p[0]:.2f}', f'{p[1]:.2f}') for p in subset]}")
    else:
        print("  No convex quadrilateral found (degenerate case)")
    print()

print("=" * 70)
print("All demos completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Convex Depth of Point Configurations

This script visualizes the concept of "convex depth" — the largest convex
polygon that can be found within a point configuration. It shows multiple
configurations side by side with their convex subsets highlighted.
"""
import matplotlib.pyplot as plt
import numpy as np
import itertools
import math


def orient(a, b, c):
    """Orientation predicate."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def is_convex_position(points, eps=1e-10):
    """Check if sorted points are in convex position."""
    n = len(points)
    if n <= 2:
        return True
    pos, neg = 0, 0
    for i in range(n):
        for j in range(i+1, n):
            for k in range(j+1, n):
                o = orient(points[i], points[j], points[k])
                if o > eps: pos += 1
                elif o < -eps: neg += 1
                else: return False
    return pos == 0 or neg == 0


def find_largest_convex_subset(points):
    """Find the largest convex subset."""
    n = len(points)
    pts_sorted = sorted(range(n), key=lambda i: points[i][0])

    for size in range(n, 2, -1):
        for combo in itertools.combinations(pts_sorted, size):
            subset = [points[i] for i in combo]
            if is_convex_position(subset):
                return list(combo)
    return pts_sorted[:min(2, n)]


# Generate point configurations
np.random.seed(42)

configs = []

# Config 1: Points on circle (all convex)
n1 = 7
angles = np.linspace(0, 2*np.pi, n1, endpoint=False)
pts1 = [(np.cos(a), np.sin(a)) for a in angles]
configs.append(("Regular 7-gon\n(depth = 7)", pts1))

# Config 2: Circle + interior points
n2_circle = 5
angles2 = np.linspace(0, 2*np.pi, n2_circle, endpoint=False)
pts2 = [(np.cos(a), np.sin(a)) for a in angles2]
pts2 += [(0.1, 0.1), (-0.2, 0.15), (0.0, -0.1)]
configs.append(("Pentagon + 3 interior\n(depth = 5)", pts2))

# Config 3: Grid-like arrangement
pts3 = [(i, j) for i in range(3) for j in range(3)]
configs.append(("3×3 Grid\n(depth = 4)", pts3))

# Config 4: Random points
pts4 = [(np.random.uniform(-1, 1), np.random.uniform(-1, 1)) for _ in range(9)]
configs.append(("9 Random Points", pts4))

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle('Convex Depth: Largest Convex Subset in Each Configuration',
             fontsize=14, fontweight='bold')

for ax, (title, pts) in zip(axes, configs):
    # Find largest convex subset
    convex_indices = find_largest_convex_subset(pts)
    convex_pts = [pts[i] for i in convex_indices]

    # Sort convex points by angle from centroid for polygon drawing
    if len(convex_pts) >= 3:
        cx = sum(p[0] for p in convex_pts) / len(convex_pts)
        cy = sum(p[1] for p in convex_pts) / len(convex_pts)
        convex_sorted = sorted(convex_pts,
                               key=lambda p: math.atan2(p[1]-cy, p[0]-cx))
        polygon = plt.Polygon(convex_sorted, fill=True, alpha=0.2,
                              color='steelblue', edgecolor='steelblue',
                              linewidth=2)
        ax.add_patch(polygon)

    # Plot all points
    all_x = [p[0] for p in pts]
    all_y = [p[1] for p in pts]
    ax.scatter(all_x, all_y, c='gray', s=50, zorder=3, alpha=0.5)

    # Highlight convex subset
    conv_x = [p[0] for p in convex_pts]
    conv_y = [p[1] for p in convex_pts]
    ax.scatter(conv_x, conv_y, c='steelblue', s=80, zorder=4,
               edgecolors='navy', linewidth=1.5)

    depth = len(convex_indices)
    if "depth" not in title:
        title = f"{title}\n(depth = {depth})"
    ax.set_title(title, fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    margin = 0.3
    ax.set_xlim(min(all_x) - margin, max(all_x) + margin)
    ax.set_ylim(min(all_y) - margin, max(all_y) + margin)

plt.tight_layout()
plt.savefig('convex_depth.png', dpi=150, bbox_inches='tight')
print("Saved convex_depth.png")


#!/usr/bin/env python3
"""
Visualization: Cups and Caps in Point Configurations

This script visualizes the cup-cap decomposition of planar point sets,
showing how cups (concave-up chains) and caps (concave-down chains)
partition the orientation structure.
"""
import matplotlib.pyplot as plt
import numpy as np
import math


def orient(a, b, c):
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def find_longest_cup(points):
    """Find longest cup (concave-up chain) in x-sorted points."""
    n = len(points)
    dp = [1] * n
    parent = [-1] * n
    prev = [-1] * n  # previous point in the cup (for orient check)

    for i in range(1, n):
        # Any pair forms a cup of size 2
        for j in range(i):
            if dp[j] == 1:
                if 2 > dp[i]:
                    dp[i] = 2
                    parent[i] = j
                    prev[i] = j
            elif prev[j] >= 0:
                if orient(points[prev[j]], points[j], points[i]) > 0:
                    if dp[j] + 1 > dp[i]:
                        dp[i] = dp[j] + 1
                        parent[i] = j
                        prev[i] = j

    best = max(range(n), key=lambda i: dp[i])
    result = []
    idx = best
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


def find_longest_cap(points):
    """Find longest cap (concave-down chain) in x-sorted points."""
    n = len(points)
    dp = [1] * n
    parent = [-1] * n
    prev = [-1] * n

    for i in range(1, n):
        for j in range(i):
            if dp[j] == 1:
                if 2 > dp[i]:
                    dp[i] = 2
                    parent[i] = j
                    prev[i] = j
            elif prev[j] >= 0:
                if orient(points[prev[j]], points[j], points[i]) < 0:
                    if dp[j] + 1 > dp[i]:
                        dp[i] = dp[j] + 1
                        parent[i] = j
                        prev[i] = j

    best = max(range(n), key=lambda i: dp[i])
    result = []
    idx = best
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


# Generate point configurations
np.random.seed(123)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Cups and Caps: Orientation Structure of Point Sets',
             fontsize=14, fontweight='bold')

# Configuration 1: Points on a parabola (pure cup)
t = np.linspace(-2, 2, 8)
pts1 = list(zip(t, t**2))
cup1 = find_longest_cup(pts1)
cap1 = find_longest_cap(pts1)

ax = axes[0, 0]
ax.scatter(*zip(*pts1), c='gray', s=60, zorder=3)
cup_pts = [pts1[i] for i in cup1]
ax.plot(*zip(*cup_pts), 'b-o', linewidth=2, markersize=8,
        label=f'Cup (size {len(cup1)})', zorder=4)
ax.set_title(f'Parabola: Pure Cup', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Configuration 2: Inverted parabola (pure cap)
pts2 = list(zip(t, -t**2 + 5))
cup2 = find_longest_cup(pts2)
cap2 = find_longest_cap(pts2)

ax = axes[0, 1]
ax.scatter(*zip(*pts2), c='gray', s=60, zorder=3)
cap_pts = [pts2[i] for i in cap2]
ax.plot(*zip(*cap_pts), 'r-s', linewidth=2, markersize=8,
        label=f'Cap (size {len(cap2)})', zorder=4)
ax.set_title(f'Inverted Parabola: Pure Cap', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Configuration 3: Sine wave (mixed)
t3 = np.linspace(0, 2*np.pi, 12)
pts3 = list(zip(t3, np.sin(t3)))
cup3 = find_longest_cup(pts3)
cap3 = find_longest_cap(pts3)

ax = axes[1, 0]
ax.scatter(*zip(*pts3), c='gray', s=60, zorder=3)
cup_pts3 = [pts3[i] for i in cup3]
cap_pts3 = [pts3[i] for i in cap3]
ax.plot(*zip(*cup_pts3), 'b-o', linewidth=2, markersize=8,
        label=f'Cup (size {len(cup3)})', zorder=4, alpha=0.8)
ax.plot(*zip(*cap_pts3), 'r-s', linewidth=2, markersize=8,
        label=f'Cap (size {len(cap3)})', zorder=4, alpha=0.8)
ax.set_title(f'Sine Wave: Mixed', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Configuration 4: Random points with cup and cap
pts4 = sorted([(np.random.uniform(0, 10), np.random.uniform(0, 5))
               for _ in range(10)], key=lambda p: p[0])
cup4 = find_longest_cup(pts4)
cap4 = find_longest_cap(pts4)

ax = axes[1, 1]
ax.scatter(*zip(*pts4), c='gray', s=60, zorder=3)
cup_pts4 = [pts4[i] for i in cup4]
cap_pts4 = [pts4[i] for i in cap4]
ax.plot(*zip(*cup_pts4), 'b-o', linewidth=2, markersize=8,
        label=f'Cup (size {len(cup4)})', zorder=4, alpha=0.8)
ax.plot(*zip(*cap_pts4), 'r-s', linewidth=2, markersize=8,
        label=f'Cap (size {len(cap4)})', zorder=4, alpha=0.8)
ax.set_title(f'Random: Cup-Cap Theorem', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('cups_caps.png', dpi=150, bbox_inches='tight')
print("Saved cups_caps.png")


#!/usr/bin/env python3
"""
Visualization: Erdős-Szekeres Bounds Comparison

This script plots the known values, conjectured values, and upper bounds
for the Erdős-Szekeres number ES(n), illustrating the gap between what
is known and what is conjectured.
"""
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2


def es_conjectured(n):
    """Conjectured value: 2^(n-2) + 1."""
    return 2**(n-2) + 1


def es_upper_bound(n):
    """Classical upper bound: C(2n-4, n-2) + 1."""
    if n <= 2:
        return n
    return comb(2*n-4, n-2) + 1


# Known exact values
known = {3: 3, 4: 5, 5: 9, 6: 17}

n_vals = list(range(3, 11))
conjectured = [es_conjectured(n) for n in n_vals]
upper = [es_upper_bound(n) for n in n_vals]
known_vals = [known.get(n, None) for n in n_vals]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Absolute values (log scale)
ax1.semilogy(n_vals, conjectured, 'b-o', label='Conjecture: $2^{n-2}+1$',
             markersize=8, linewidth=2)
ax1.semilogy(n_vals, upper, 'r--s', label=r'Upper bound: $\binom{2n-4}{n-2}+1$',
             markersize=8, linewidth=2)

# Plot known values
known_n = [n for n in n_vals if known.get(n) is not None]
known_v = [known[n] for n in known_n]
ax1.semilogy(known_n, known_v, 'g^', label='Known exact values',
             markersize=12, linewidth=2, markeredgecolor='darkgreen',
             markerfacecolor='lime', zorder=5)

# Suk bound approximation
suk = [2**(1.05*n) for n in n_vals]
ax1.semilogy(n_vals, suk, 'purple', label='Suk (2017): $2^{n+o(n)}$',
             linewidth=2, linestyle=':')

ax1.set_xlabel('n (polygon size)', fontsize=12)
ax1.set_ylabel('ES(n) — number of points needed', fontsize=12)
ax1.set_title('Erdős–Szekeres Number: Bounds Comparison', fontsize=13,
              fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xticks(n_vals)

# Plot 2: Ratio to conjecture
ratios_upper = [u / c for u, c in zip(upper, conjectured)]
ax2.plot(n_vals, ratios_upper, 'r-s', label='Upper bound / Conjecture',
         markersize=8, linewidth=2)
ax2.axhline(y=1.0, color='blue', linestyle='--', alpha=0.5,
            label='Conjecture (ratio = 1)')

# Known values ratio
known_ratios = [(known[n] / es_conjectured(n)) for n in known_n]
ax2.plot(known_n, known_ratios, 'g^', label='Known / Conjecture',
         markersize=12, markeredgecolor='darkgreen',
         markerfacecolor='lime', zorder=5)

ax2.set_xlabel('n (polygon size)', fontsize=12)
ax2.set_ylabel('Ratio to conjecture', fontsize=12)
ax2.set_title('Gap Between Bounds and Conjecture', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(n_vals)
ax2.set_yscale('log')

fig.tight_layout()
plt.savefig('es_bounds.png', dpi=150, bbox_inches='tight')
print("Saved es_bounds.png")
