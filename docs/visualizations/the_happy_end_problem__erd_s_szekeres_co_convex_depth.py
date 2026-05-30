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
