#!/usr/bin/env python3
"""
Visualization: Tropical Convex Hull Structure

Shows the structure of tropical convex hulls in 2D, comparing them with
classical convex hulls. Illustrates the piecewise-linear nature of
tropical geometry and the role of max-plus combinations.

Uses matplotlib. Output: tropical_hull.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import ConvexHull


def trop_comb(t, x, y):
    return np.maximum(x, t + y)


def sample_trop_hull(generators, num=10000):
    n = len(generators)
    pts = []
    for _ in range(num):
        w = np.random.uniform(-8, 0, size=n)
        z = np.max(w[:, None] + generators, axis=0)
        pts.append(z)
    return np.array(pts)


def sample_trop_segment(x, y, num=300):
    diff = np.max(np.abs(x - y))
    t_range = max(diff * 2, 5.0)
    pts = []
    for t in np.linspace(-t_range, 0, num):
        pts.append(trop_comb(t, x, y))
        pts.append(trop_comb(t, y, x))
    return np.array(pts)


fig, axes = plt.subplots(2, 2, figsize=(14, 13))

# --- Panel 1: 2 generators ---
ax = axes[0, 0]
gens = np.array([[0.0, 3.0], [4.0, 0.0]])
seg = sample_trop_segment(gens[0], gens[1], num=500)

# Sort for clean plotting
order = np.argsort(seg[:, 0])
seg_sorted = seg[order]
# Remove duplicates approximately
unique_mask = np.concatenate([[True], np.any(np.abs(np.diff(seg_sorted, axis=0)) > 0.01, axis=1)])
seg_unique = seg_sorted[unique_mask]

ax.fill_between(seg_unique[:, 0], seg_unique[:, 1] - 0.05, seg_unique[:, 1] + 0.05,
                alpha=0.3, color='blue', label='Tropical segment')
ax.plot(seg_unique[:, 0], seg_unique[:, 1], 'b-', linewidth=2)

# Classical segment
ts = np.linspace(0, 1, 100)
classical = np.array([t * gens[0] + (1 - t) * gens[1] for t in ts])
ax.plot(classical[:, 0], classical[:, 1], 'r--', linewidth=2, label='Classical segment')

for i, g in enumerate(gens):
    ax.plot(*g, 'ko', markersize=12, zorder=5)
    
ax.set_title('2 Points: Tropical vs Classical', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

# --- Panel 2: 3 generators ---
ax = axes[0, 1]
gens3 = np.array([[0.0, 0.0], [5.0, 1.0], [2.0, 6.0]])
hull_pts = sample_trop_hull(gens3, num=15000)

ax.scatter(hull_pts[:, 0], hull_pts[:, 1], c='lightblue', s=0.5, alpha=0.3, label='Tropical hull')

# Tropical segments between generators
for i in range(3):
    for j in range(i+1, 3):
        seg = sample_trop_segment(gens3[i], gens3[j], num=300)
        ax.plot(seg[:, 0], seg[:, 1], 'b-', linewidth=1.5, alpha=0.7)

# Classical hull
try:
    ch = ConvexHull(gens3)
    for simplex in ch.simplices:
        ax.plot(gens3[simplex, 0], gens3[simplex, 1], 'r--', linewidth=2)
except:
    pass

for i, g in enumerate(gens3):
    ax.plot(*g, 'ro', markersize=10, zorder=5)
    ax.annotate(f'p{i}', g, fontsize=12, fontweight='bold', 
                xytext=(8, 5), textcoords='offset points')

ax.set_title('3 Points: Tropical Convex Hull', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

# --- Panel 3: 4 generators ---
ax = axes[1, 0]
gens4 = np.array([[0.0, 0.0], [6.0, 1.0], [4.0, 7.0], [1.0, 5.0]])
hull_pts4 = sample_trop_hull(gens4, num=20000)

ax.scatter(hull_pts4[:, 0], hull_pts4[:, 1], c='lightgreen', s=0.5, alpha=0.3)

for i in range(4):
    for j in range(i+1, 4):
        seg = sample_trop_segment(gens4[i], gens4[j], num=200)
        ax.plot(seg[:, 0], seg[:, 1], 'g-', linewidth=1, alpha=0.5)

for i, g in enumerate(gens4):
    ax.plot(*g, 'ko', markersize=10, zorder=5)
    ax.annotate(f'p{i}', g, fontsize=11, fontweight='bold',
                xytext=(8, 5), textcoords='offset points')

ax.set_title('4 Points: Larger Hull', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

# --- Panel 4: Weight space exploration ---
ax = axes[1, 1]
gens_demo = np.array([[0.0, 0.0], [4.0, 1.0], [1.0, 5.0]])

# Color by which generator dominates
hull_colors = []
hull_x, hull_y = [], []
for _ in range(15000):
    w = np.random.uniform(-6, 0, size=3)
    shifted = w[:, None] + gens_demo
    z = np.max(shifted, axis=0)
    # For each coordinate, which generator achieves the max?
    dominant = np.argmax(shifted, axis=0)
    # Color encoding: mix based on dominance
    colors = np.array([[1, 0, 0], [0, 0.7, 0], [0, 0, 1]])
    color = np.mean([colors[dominant[0]], colors[dominant[1]]], axis=0)
    hull_colors.append(color)
    hull_x.append(z[0])
    hull_y.append(z[1])

hull_colors = np.array(hull_colors)
ax.scatter(hull_x, hull_y, c=hull_colors, s=1, alpha=0.4)

for i, g in enumerate(gens_demo):
    colors = ['red', 'green', 'blue']
    ax.plot(*g, 'o', color=colors[i], markersize=12, zorder=5,
            markeredgecolor='black', markeredgewidth=1.5)
    ax.annotate(f'p{i}', g, fontsize=12, fontweight='bold',
                xytext=(8, 5), textcoords='offset points')

ax.set_title('Hull Colored by Dominant Generator', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

plt.suptitle('Tropical Convex Geometry (Max-Plus Convention)', 
             fontsize=16, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('tropical_hull.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_hull.png")
