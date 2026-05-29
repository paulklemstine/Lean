#!/usr/bin/env python3
"""
Visualization: Tropical Segments and Convex Hulls in 2D

Visualizes the max-plus tropical segment between two points and the
tropical convex hull of three generators. Shows how tropical geometry
creates piecewise-linear "geodesics" unlike classical straight lines.

Uses matplotlib. Output: tropical_segments.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def trop_comb(t, x, y):
    """Max-plus tropical combination: z_i = max(x_i, t + y_i)."""
    return np.maximum(x, t + y)


def compute_segment(x, y, num=500):
    """Compute tropical segment between x and y."""
    diff = np.max(np.abs(x - y))
    t_range = max(diff * 2, 5.0)
    pts = []
    for t in np.linspace(-t_range, 0, num):
        pts.append(trop_comb(t, x, y))
        pts.append(trop_comb(t, y, x))
    return np.array(pts)


def compute_hull(generators, num=2000):
    """Sample points from tropical convex hull."""
    n = len(generators)
    pts = []
    for _ in range(num):
        w = np.random.uniform(-6, 0, size=n)
        z = np.max(w[:, None] + generators, axis=0)
        pts.append(z)
    return np.array(pts)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Tropical segment vs Euclidean segment ---
ax = axes[0]
x = np.array([0.0, 3.0])
y = np.array([4.0, 0.0])

seg = compute_segment(x, y)
ax.plot(seg[:, 0], seg[:, 1], 'b.', markersize=1, alpha=0.5, label='Tropical segment')

# Euclidean segment
ts = np.linspace(0, 1, 100)
euclid = np.array([t * x + (1 - t) * y for t in ts])
ax.plot(euclid[:, 0], euclid[:, 1], 'r--', linewidth=2, label='Euclidean segment')

ax.plot(*x, 'ko', markersize=10, zorder=5)
ax.plot(*y, 'ko', markersize=10, zorder=5)
ax.annotate('x = (0, 3)', x, fontsize=11, xytext=(-1.5, 3.3))
ax.annotate('y = (4, 0)', y, fontsize=11, xytext=(3.5, 0.5))

ax.set_title('Tropical vs Euclidean Segment', fontsize=14, fontweight='bold')
ax.set_xlabel('Coordinate 1')
ax.set_ylabel('Coordinate 2')
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: Tropical convex hull of 3 points ---
ax = axes[1]
generators = np.array([
    [0.0, 0.0],
    [5.0, 1.0],
    [2.0, 6.0],
])

hull_pts = compute_hull(generators, num=5000)
ax.scatter(hull_pts[:, 0], hull_pts[:, 1], c='lightblue', s=1, alpha=0.3)

# Draw segments between generators
for i in range(3):
    for j in range(i + 1, 3):
        seg = compute_segment(generators[i], generators[j])
        ax.plot(seg[:, 0], seg[:, 1], 'b-', linewidth=1, alpha=0.6)

for i, g in enumerate(generators):
    ax.plot(*g, 'ro', markersize=10, zorder=5)
    ax.annotate(f'p{i}', g, fontsize=12, fontweight='bold', 
                xytext=(5, 5), textcoords='offset points')

ax.set_title('Tropical Convex Hull (3 generators)', fontsize=14, fontweight='bold')
ax.set_xlabel('Coordinate 1')
ax.set_ylabel('Coordinate 2')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 3: Helly theorem for boxes ---
ax = axes[2]

boxes = [
    (np.array([0, 0]), np.array([4, 3]), 'lightcoral', 'Box 1'),
    (np.array([1, 1]), np.array([5, 4]), 'lightgreen', 'Box 2'),
    (np.array([2, 0.5]), np.array([6, 3.5]), 'lightskyblue', 'Box 3'),
    (np.array([1.5, 0]), np.array([4.5, 2.5]), 'lightyellow', 'Box 4'),
]

for lo, hi, color, label in boxes:
    rect = plt.Rectangle(lo, hi[0] - lo[0], hi[1] - lo[1], 
                         alpha=0.3, facecolor=color, edgecolor='black', linewidth=1.5,
                         label=label)
    ax.add_patch(rect)

# Compute and show intersection
lo_max = np.max([lo for lo, _, _, _ in boxes], axis=0)
hi_min = np.min([hi for _, hi, _, _ in boxes], axis=0)

if np.all(lo_max <= hi_min):
    rect_int = plt.Rectangle(lo_max, hi_min[0] - lo_max[0], hi_min[1] - lo_max[1],
                             alpha=0.6, facecolor='gold', edgecolor='darkred', linewidth=2,
                             label='Intersection')
    ax.add_patch(rect_int)
    center = (lo_max + hi_min) / 2
    ax.plot(*center, 'r*', markersize=15, zorder=5, label='Witness point')

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 5)
ax.set_title('Helly Theorem: Pairwise → Global', fontsize=14, fontweight='bold')
ax.set_xlabel('Coordinate 1')
ax.set_ylabel('Coordinate 2')
ax.legend(fontsize=9, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_segments.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_segments.png")
