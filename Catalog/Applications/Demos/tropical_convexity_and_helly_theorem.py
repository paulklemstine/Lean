#!/usr/bin/env python3
"""
Tropical Convexity and Helly's Theorem — Numerical Demonstrations

Demonstrates:
1. Tropical segment computation
2. Helly's theorem for intervals
3. Difference constraint solvability (cycle condition)
4. Tropical convex hull of finite points
"""

import numpy as np
from itertools import combinations


def tropical_linear_combination(x: np.ndarray, y: np.ndarray,
                                 a: float, b: float) -> np.ndarray:
    """Compute the tropical linear combination max(a + x, b + y) coordinatewise."""
    return np.maximum(a + x, b + y)


def tropical_segment_sample(x: np.ndarray, y: np.ndarray,
                             num_points: int = 50) -> np.ndarray:
    """Sample points from the tropical segment between x and y."""
    points = []
    for t in np.linspace(-5, 5, num_points):
        z = tropical_linear_combination(x, y, t, 0.0)
        points.append(z)
        z = tropical_linear_combination(x, y, 0.0, t)
        points.append(z)
    return np.array(points)


def helly_intervals_check(intervals: list[tuple[float, float]]) -> tuple[bool, float | None]:
    """
    Check Helly's condition for a family of intervals [a_i, b_i].
    Returns (is_feasible, common_point).
    
    By Helly's theorem: the family has non-empty intersection iff
    every pair intersects, i.e., a_i <= b_j for all i, j.
    The common point is max_i(a_i).
    """
    n = len(intervals)
    # Check pairwise condition
    for i in range(n):
        for j in range(n):
            if intervals[i][0] > intervals[j][1]:
                return False, None
    
    # Common point: max of all left endpoints
    x = max(a for a, _ in intervals)
    return True, x


def diff_constraint_cycle_check(weights: list[float]) -> tuple[bool, list[float] | None]:
    """
    Check solvability of a cyclic system of difference constraints:
    x_{i} - x_{i+1} <= c_i (indices mod n), with x_n = x_0.
    
    Solvable iff sum of weights >= 0 (non-negative cycle condition).
    If solvable, returns the shortest-path solution.
    """
    total = sum(weights)
    if total < -1e-12:
        return False, None
    
    # Shortest-path solution: x_0 = 0, x_k = -sum(c_0, ..., c_{k-1})
    n = len(weights)
    solution = [0.0]
    cumsum = 0.0
    for k in range(n - 1):
        cumsum += weights[k]
        solution.append(-cumsum)
    
    return True, solution


def tropical_convex_hull_2d(points: np.ndarray,
                             num_samples: int = 1000) -> np.ndarray:
    """
    Approximate the tropical convex hull of a set of 2D points
    by sampling tropical linear combinations.
    """
    n = len(points)
    hull_points = list(points)
    
    for _ in range(num_samples):
        # Random tropical combination of two random points
        i, j = np.random.choice(n, size=2, replace=True)
        a = np.random.uniform(-3, 3)
        b = np.random.uniform(-3, 3)
        z = tropical_linear_combination(points[i], points[j], a, b)
        hull_points.append(z)
    
    return np.array(hull_points)


def verify_tropical_convexity(points: np.ndarray, test_set: np.ndarray,
                                tol: float = 1e-6) -> bool:
    """
    Verify that a set (given by test_set) contains the tropical segment
    between every pair of its points (approximate check).
    """
    n = len(test_set)
    for i in range(min(n, 50)):
        for j in range(i + 1, min(n, 50)):
            for a in np.linspace(-2, 2, 10):
                z = tropical_linear_combination(test_set[i], test_set[j], a, 0.0)
                # Check if z is close to any point in test_set
                dists = np.min(np.linalg.norm(test_set - z, axis=1))
                if dists > tol:
                    return False
    return True


def main():
    print("=" * 60)
    print("TROPICAL CONVEXITY AND HELLY'S THEOREM — DEMONSTRATIONS")
    print("=" * 60)
    
    # Demo 1: Tropical Segments
    print("\n--- Demo 1: Tropical Segments ---")
    x = np.array([0.0, 1.0, 2.0])
    y = np.array([2.0, 0.0, 1.0])
    print(f"Point x = {x}")
    print(f"Point y = {y}")
    
    for a, b in [(0, 0), (1, 0), (0, 1), (-1, 0), (0, -1)]:
        z = tropical_linear_combination(x, y, a, b)
        print(f"  max({a}+x, {b}+y) = {z}")
    
    # Demo 2: Helly's Theorem for Intervals
    print("\n--- Demo 2: Helly's Theorem for Intervals ---")
    
    # Case 1: Pairwise intersecting intervals
    intervals1 = [(1, 5), (2, 6), (3, 7), (0, 4)]
    feasible, point = helly_intervals_check(intervals1)
    print(f"Intervals: {intervals1}")
    print(f"  Feasible: {feasible}, Common point: {point}")
    
    # Verify
    if feasible and point is not None:
        for a, b in intervals1:
            assert a <= point <= b, f"Point {point} not in [{a}, {b}]"
        print(f"  Verified: {point} lies in all intervals ✓")
    
    # Case 2: Non-intersecting intervals
    intervals2 = [(1, 3), (4, 6), (2, 5)]
    feasible, point = helly_intervals_check(intervals2)
    print(f"\nIntervals: {intervals2}")
    print(f"  Feasible: {feasible}")
    if not feasible:
        # Find the failing pair
        for i, j in combinations(range(len(intervals2)), 2):
            if intervals2[i][0] > intervals2[j][1]:
                print(f"  Failing pair: [{intervals2[i][0]},{intervals2[i][1]}] "
                      f"and [{intervals2[j][0]},{intervals2[j][1]}]")
    
    # Demo 3: Difference Constraints
    print("\n--- Demo 3: Difference Constraint Solvability ---")
    
    # Case 1: Feasible cycle
    weights1 = [2.0, 3.0, -4.0]
    feasible, sol = diff_constraint_cycle_check(weights1)
    print(f"Cycle weights: {weights1}, sum = {sum(weights1)}")
    print(f"  Feasible: {feasible}")
    if sol:
        print(f"  Solution: x = {sol}")
        # Verify
        n = len(weights1)
        for k in range(n):
            lhs = sol[k] - sol[(k + 1) % n]
            print(f"  x_{k} - x_{(k+1)%n} = {lhs:.2f} <= {weights1[k]} ✓"
                  if lhs <= weights1[k] + 1e-10 else
                  f"  x_{k} - x_{(k+1)%n} = {lhs:.2f} > {weights1[k]} ✗")
    
    # Case 2: Infeasible cycle (negative total weight)
    weights2 = [1.0, -3.0, 1.0]
    feasible, sol = diff_constraint_cycle_check(weights2)
    print(f"\nCycle weights: {weights2}, sum = {sum(weights2)}")
    print(f"  Feasible: {feasible} (negative cycle!)")
    
    # Demo 4: Three-variable cycle (matching our formal theorem)
    print("\n--- Demo 4: Three-Variable Cycle (Formal Theorem) ---")
    for c12, c23, c31 in [(1, 2, -2), (1, -1, -1), (3, -1, -1)]:
        total = c12 + c23 + c31
        feasible = total >= 0
        print(f"  c₁₂={c12}, c₂₃={c23}, c₃₁={c31}: "
              f"sum={total}, feasible={feasible}")
        if feasible:
            x1, x2, x3 = 0, -c12, -(c12 + c23)
            print(f"    Shortest-path solution: ({x1}, {x2}, {x3})")
            print(f"    x₁-x₂ = {x1-x2} ≤ {c12}, "
                  f"x₂-x₃ = {x2-x3} ≤ {c23}, "
                  f"x₃-x₁ = {x3-x1} ≤ {c31}")
    
    # Demo 5: Tropical Convex Hull
    print("\n--- Demo 5: Tropical Convex Hull ---")
    generators = np.array([[0, 0], [3, 1], [1, 3]])
    hull = tropical_convex_hull_2d(generators, num_samples=500)
    print(f"Generators: {generators.tolist()}")
    print(f"Hull has {len(hull)} sampled points")
    print(f"Hull bounding box: x∈[{hull[:,0].min():.1f}, {hull[:,0].max():.1f}], "
          f"y∈[{hull[:,1].min():.1f}, {hull[:,1].max():.1f}]")
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization of difference constraint solvability and cycle condition."""
import matplotlib.pyplot as plt
import numpy as np

def draw_constraint_graph(weights, ax, title):
    """Draw a 3-variable cycle constraint graph."""
    n = len(weights)
    total = sum(weights)
    feasible = total >= -1e-12
    
    angles = [np.pi/2 + 2*np.pi*k/n for k in range(n)]
    positions = [(np.cos(a), np.sin(a)) for a in angles]
    
    for i, (x, y) in enumerate(positions):
        color = 'lightgreen' if feasible else 'lightcoral'
        ax.plot(x, y, 'o', markersize=30, color=color, zorder=5,
                markeredgecolor='black', markeredgewidth=2)
        ax.text(x, y, f'x_{i+1}', ha='center', va='center', fontsize=12,
                fontweight='bold', zorder=6)
    
    for i in range(n):
        j = (i + 1) % n
        xi, yi = positions[i]
        xj, yj = positions[j]
        dx, dy = xj - xi, yj - yi
        length = np.sqrt(dx**2 + dy**2)
        dx, dy = dx/length, dy/length
        offset = 0.15
        
        ax.annotate('', xy=(xj - dx*0.2, yj - dy*0.2),
                    xytext=(xi + dx*0.2, yi + dy*0.2),
                    arrowprops=dict(arrowstyle='->', lw=2,
                                   color='darkblue' if feasible else 'darkred'))
        
        mx = (xi + xj) / 2 - dy * 0.15
        my = (yi + yj) / 2 + dx * 0.15
        ax.text(mx, my, f'c={weights[i]}', ha='center', va='center',
                fontsize=10, color='darkblue' if feasible else 'darkred',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))
    
    status = "✓ Feasible" if feasible else "✗ Infeasible"
    color = 'green' if feasible else 'red'
    ax.set_title(f"{title}\nΣ = {total:.1f} {'≥' if feasible else '<'} 0 → {status}",
                 color=color, fontsize=11)
    
    if feasible:
        sol = [0, -weights[0], -(weights[0] + weights[1])]
        sol_text = f"Solution: ({sol[0]:.0f}, {sol[1]:.0f}, {sol[2]:.0f})"
        ax.text(0, -1.5, sol_text, ha='center', fontsize=10,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

cases = [
    ([2, 3, -4], "Case 1: Positive cycle"),
    ([1, -1, 0], "Case 2: Zero cycle"),
    ([1, -3, 1], "Case 3: Negative cycle"),
]

for ax, (weights, title) in zip(axes, cases):
    draw_constraint_graph(weights, ax, title)

plt.suptitle("Three-Variable Cycle Condition for Difference Constraints", fontsize=14)
plt.tight_layout()
plt.savefig("diff_constraints.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved diff_constraints.png")


#!/usr/bin/env python3
"""Visualization of Helly's theorem for intervals."""
import matplotlib.pyplot as plt
import numpy as np

def draw_interval_diagram(intervals, ax, title):
    """Draw intervals and their intersection."""
    n = len(intervals)
    colors = plt.cm.Set2(np.linspace(0, 1, n))
    
    max_lower = max(a for a, _ in intervals)
    min_upper = min(b for _, b in intervals)
    has_intersection = max_lower <= min_upper
    
    for i, ((a, b), color) in enumerate(zip(intervals, colors)):
        ax.barh(i, b - a, left=a, height=0.6, color=color, alpha=0.7,
                edgecolor='black', linewidth=1)
        ax.text(a - 0.3, i, f'[{a},{b}]', ha='right', va='center', fontsize=9)
    
    if has_intersection:
        ax.axvspan(max_lower, min_upper, alpha=0.3, color='green',
                   label=f'Intersection [{max_lower},{min_upper}]')
        ax.axvline(max_lower, color='green', linestyle='--', linewidth=2)
        ax.set_title(f"{title}\n✓ Common point: x = {max_lower}", color='green')
    else:
        ax.set_title(f"{title}\n✗ No common point", color='red')
    
    ax.set_yticks(range(n))
    ax.set_yticklabels([f'I_{i+1}' for i in range(n)])
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3, axis='x')

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

intervals_yes = [(1, 5), (2, 7), (3, 6), (0, 4)]
draw_interval_diagram(intervals_yes, ax1, "Pairwise Intersecting → Global Intersection")

intervals_no = [(1, 3), (5, 8), (2, 6)]
draw_interval_diagram(intervals_no, ax2, "Pair Fails → No Global Intersection")

plt.suptitle("Helly's Theorem for Intervals", fontsize=14)
plt.tight_layout()
plt.savefig("helly_intervals.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved helly_intervals.png")


#!/usr/bin/env python3
"""Visualization of tropical segments in 2D."""
import matplotlib.pyplot as plt
import numpy as np

def tropical_linear_combination(x, y, a, b):
    return np.maximum(a + x, b + y)

def plot_tropical_segment(x, y, ax, label_prefix=""):
    """Plot the tropical segment between x and y in 2D."""
    params = np.linspace(-5, 5, 500)
    points_a = np.array([tropical_linear_combination(x, y, a, 0) for a in params])
    points_b = np.array([tropical_linear_combination(x, y, 0, b) for b in params])
    all_points = np.vstack([points_a, points_b])
    ax.plot(all_points[:, 0], all_points[:, 1], '.', markersize=1, alpha=0.3)
    ax.plot(*x, 'ro', markersize=10, zorder=5)
    ax.plot(*y, 'bs', markersize=10, zorder=5)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

pairs = [
    (np.array([0.0, 0.0]), np.array([3.0, 1.0]), "Segment 1"),
    (np.array([0.0, 0.0]), np.array([1.0, 3.0]), "Segment 2"),
    (np.array([0.0, 2.0]), np.array([2.0, 0.0]), "Segment 3"),
]

for ax, (x, y, title) in zip(axes, pairs):
    plot_tropical_segment(x, y, ax)
    ax.set_title(title)
    ax.set_xlabel("x₁")
    ax.set_ylabel("x₂")
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

plt.suptitle("Tropical Segments in ℝ²", fontsize=14)
plt.tight_layout()
plt.savefig("tropical_segments.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved tropical_segments.png")
