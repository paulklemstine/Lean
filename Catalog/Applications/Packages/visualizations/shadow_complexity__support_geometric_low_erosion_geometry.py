#!/usr/bin/env python3
"""
Visualization 3: Polytope Erosion Geometry
Visualizes how the second shadow corresponds to discrete polytope erosion,
connecting arithmetic complexity to convex geometry.

Shows the Newton polytope of a support set and its erosion by the
degree-2 simplex, illustrating the cross-domain theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, Tuple
from itertools import product as cartesian_product

ExponentVector = Tuple[int, ...]

def subtract_pair_basis(alpha, i, j):
    lst = list(alpha)
    if lst[i] < 1: return None
    lst[i] -= 1
    if lst[j] < 1: return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S, n):
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def simplex_support(d, m):
    if d == 0: return {()} if m == 0 else set()
    if d == 1: return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result

# ─── Create figure ────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Different support shapes to demonstrate erosion
examples = [
    ("Simplex(2,7)", simplex_support(2, 7), 2,
     "Triangle → Smaller Triangle"),
    ("Square {0..4}²",
     set(cartesian_product(range(5), repeat=2)), 2,
     "Square → Smaller Square"),
    ("L-shape",
     {(a, b) for a in range(6) for b in range(6) if a <= 3 or b <= 2}, 2,
     "L-shape → Eroded L"),
]

for col, (name, S, n, description) in enumerate(examples):
    sh = second_shadow(S, n)
    
    max_c = max(max(v) for v in S) + 1
    
    # Top: Original support (Newton polytope lattice points)
    ax_top = axes[0, col]
    
    # Draw grid
    for x in range(max_c + 1):
        for y in range(max_c + 1):
            ax_top.plot(x, y, '.', color='#ddd', markersize=3)
    
    # Draw support
    sx = [p[0] for p in S]
    sy = [p[1] for p in S]
    ax_top.scatter(sx, sy, c='#2c3e50', s=40, zorder=5, label='Support S')
    
    # Draw convex hull outline
    from matplotlib.path import Path
    points = np.array(list(S))
    if len(points) >= 3:
        from scipy.spatial import ConvexHull
        try:
            hull = ConvexHull(points)
            hull_pts = points[hull.vertices]
            hull_pts = np.vstack([hull_pts, hull_pts[0]])
            ax_top.plot(hull_pts[:, 0], hull_pts[:, 1], 'k-', linewidth=1.5, alpha=0.5)
        except Exception:
            pass
    
    ax_top.set_xlim(-0.5, max_c + 0.5)
    ax_top.set_ylim(-0.5, max_c + 0.5)
    ax_top.set_aspect('equal')
    ax_top.set_title(f"{name}\n|S| = {len(S)}", fontsize=11, fontweight='bold')
    ax_top.set_xlabel("x₁")
    ax_top.set_ylabel("x₂")
    ax_top.grid(True, alpha=0.15)
    
    # Bottom: Erosion (= second shadow)
    ax_bot = axes[1, col]
    
    # Draw grid
    for x in range(max_c + 1):
        for y in range(max_c + 1):
            ax_bot.plot(x, y, '.', color='#ddd', markersize=3)
    
    # Draw original support faintly
    ax_bot.scatter(sx, sy, c='#bdc3c7', s=20, zorder=3, alpha=0.5, label='Original S')
    
    # Draw shadow
    if sh:
        shx = [p[0] for p in sh]
        shy = [p[1] for p in sh]
        ax_bot.scatter(shx, shy, c='#e74c3c', s=40, zorder=5, marker='s',
                      label=f'Sh₂(S) = Erosion')
        
        # Shadow convex hull
        sh_points = np.array(list(sh))
        if len(sh_points) >= 3:
            try:
                hull_sh = ConvexHull(sh_points)
                hull_sh_pts = sh_points[hull_sh.vertices]
                hull_sh_pts = np.vstack([hull_sh_pts, hull_sh_pts[0]])
                ax_bot.plot(hull_sh_pts[:, 0], hull_sh_pts[:, 1], 'r-',
                           linewidth=1.5, alpha=0.5)
            except Exception:
                pass
    
    ax_bot.set_xlim(-0.5, max_c + 0.5)
    ax_bot.set_ylim(-0.5, max_c + 0.5)
    ax_bot.set_aspect('equal')
    ax_bot.set_title(f"Erosion by Δ₂\n|Sh₂| = {len(sh)}, {description}", fontsize=10)
    ax_bot.set_xlabel("x₁")
    ax_bot.set_ylabel("x₂")
    ax_bot.legend(fontsize=8, loc='upper right')
    ax_bot.grid(True, alpha=0.15)

fig.suptitle("Newton Polytope Erosion = Second Shadow\n"
             "The shadow operation 'shrinks' the Newton polytope by the degree-2 simplex",
             fontsize=14, fontweight='bold', y=1.03)

plt.tight_layout()
plt.savefig("erosion_geometry.png", dpi=150, bbox_inches='tight')
print("Saved erosion_geometry.png")
