#!/usr/bin/env python3
"""
Visualization: The Berggren Tree of Pythagorean Triples

This script visualizes the first several levels of the Berggren ternary tree,
showing how primitive Pythagorean triples are organized by their parent-child
relationships. Points are plotted on the unit circle at angle θ = atan2(b/c, a/c),
with color indicating tree depth (hyperbolic distance from origin).

The exponential growth of the tree mirrors the exponential divergence of
geodesics in hyperbolic space — a visual manifestation of negative curvature.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import atan2, pi, sqrt


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def build_tree(max_depth=5):
    """Build tree with depth tracking."""
    nodes = []  # (a, b, c, depth, parent_idx)
    nodes.append((3, 4, 5, 0, -1))
    queue = [(3, 4, 5, 0, 0)]
    
    while queue:
        a, b, c, depth, parent_idx = queue.pop(0)
        if depth >= max_depth:
            continue
        
        for child_fn in [berggren_A, berggren_B, berggren_C]:
            child = child_fn(a, b, c)
            child_idx = len(nodes)
            nodes.append((*child, depth + 1, parent_idx))
            queue.append((*child, depth + 1, child_idx))
    
    return nodes


# Build tree
max_depth = 4
nodes = build_tree(max_depth)

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# ---- LEFT PLOT: Points on the unit disk ----
# Map each triple (a,b,c) to the point (a/c, b/c) on the unit disk
cmap = plt.cm.plasma
norm = plt.Normalize(0, max_depth)

# Draw unit circle
theta = np.linspace(0, pi/2, 100)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1, alpha=0.3)

# Draw edges (parent to child)
for i, (a, b, c, depth, parent_idx) in enumerate(nodes):
    if parent_idx >= 0:
        pa, pb, pc = nodes[parent_idx][0], nodes[parent_idx][1], nodes[parent_idx][2]
        ax1.plot([pa/pc, a/c], [pb/pc, b/c], 
                color=cmap(norm(depth)), alpha=0.3, linewidth=0.5)

# Draw nodes
for a, b, c, depth, _ in nodes:
    x, y = a/c, b/c
    size = max(8, 40 - depth * 8)
    ax1.scatter(x, y, c=[depth], cmap='plasma', vmin=0, vmax=max_depth, 
               s=size, zorder=5, edgecolors='black', linewidth=0.3)

# Label root and first-level nodes
for a, b, c, depth, _ in nodes[:4]:
    ax1.annotate(f'({a},{b},{c})', (a/c, b/c), 
                textcoords="offset points", xytext=(5, 5),
                fontsize=7, alpha=0.8)

ax1.set_xlim(-0.05, 1.05)
ax1.set_ylim(-0.05, 1.05)
ax1.set_aspect('equal')
ax1.set_xlabel('a/c (cosine component)', fontsize=11)
ax1.set_ylabel('b/c (sine component)', fontsize=11)
ax1.set_title('Pythagorean Triples on the Unit Circle\n(Berggren Tree, depth ≤ 4)', fontsize=13)

# ---- RIGHT PLOT: Hypotenuse growth by depth ----
depths = {}
for a, b, c, depth, _ in nodes:
    if depth not in depths:
        depths[depth] = []
    depths[depth].append(c)

depth_labels = sorted(depths.keys())
for d in depth_labels:
    hyps = sorted(depths[d])
    jitter = np.random.normal(0, 0.1, len(hyps))
    ax2.scatter([d + j for j in jitter], hyps, 
               c=[d]*len(hyps), cmap='plasma', vmin=0, vmax=max_depth,
               s=15, alpha=0.7, edgecolors='none')

# Plot min and max hypotenuse per depth
min_hyps = [min(depths[d]) for d in depth_labels]
max_hyps = [max(depths[d]) for d in depth_labels]
mean_hyps = [sum(depths[d])/len(depths[d]) for d in depth_labels]
ax2.plot(depth_labels, min_hyps, 'b-o', markersize=5, label='Min hypotenuse', linewidth=2)
ax2.plot(depth_labels, max_hyps, 'r-s', markersize=5, label='Max hypotenuse', linewidth=2)
ax2.plot(depth_labels, mean_hyps, 'g-^', markersize=5, label='Mean hypotenuse', linewidth=2)

ax2.set_yscale('log')
ax2.set_xlabel('Berggren Tree Depth', fontsize=11)
ax2.set_ylabel('Hypotenuse (log scale)', fontsize=11)
ax2.set_title('Exponential Growth of Hypotenuse\n(Hyperbolic Divergence)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('berggren_tree_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: berggren_tree_visualization.png")
