#!/usr/bin/env python3
"""
Visualization: Knot Lattice Forbidden Regions
===============================================
Shows lattice paths for different knots with their forbidden regions
highlighted, demonstrating how knot topology constrains path combinatorics.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import combinations
from math import comb


def all_lattice_paths(m, n):
    paths = []
    for east_pos in combinations(range(m + n), m):
        p = [False] * (m + n)
        for pos in east_pos:
            p[pos] = True
        paths.append(p)
    return paths


def path_visits(path, point):
    x, y = 0, 0
    if (x, y) == point:
        return True
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        if (x, y) == point:
            return True
    return False


def compute_path_area(path):
    area, h = 0, 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def path_coordinates(path):
    coords = [(0, 0)]
    x, y = 0, 0
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        coords.append((x, y))
    return coords


def draw_knot_lattice(ax, n, forbidden, title, writhe):
    """Draw a knot lattice with forbidden region and valid paths."""
    # Draw grid
    for i in range(n + 1):
        ax.plot([i, i], [0, n], 'lightgray', linewidth=0.5)
        ax.plot([0, n], [i, i], 'lightgray', linewidth=0.5)
    
    # Draw forbidden region
    for fx, fy in forbidden:
        rect = patches.Rectangle((fx - 0.4, fy - 0.4), 0.8, 0.8,
                                  facecolor='#F44336', alpha=0.4,
                                  edgecolor='#F44336', linewidth=2)
        ax.add_patch(rect)
        ax.plot(fx, fy, 'x', color='#B71C1C', markersize=12, 
                markeredgewidth=3, zorder=10)
    
    # Get all paths and classify
    all_paths = all_lattice_paths(n, n)
    valid_paths = [p for p in all_paths 
                   if all(not path_visits(p, f) for f in forbidden)]
    
    # Draw a sample of valid paths (up to 8)
    cmap = plt.cm.Blues
    sample = valid_paths[:min(8, len(valid_paths))]
    for idx, path in enumerate(sample):
        coords = path_coordinates(path)
        xs, ys = zip(*coords)
        alpha = 0.3 + 0.5 * (idx / max(len(sample) - 1, 1))
        color = cmap(0.3 + 0.5 * idx / max(len(sample) - 1, 1))
        ax.plot(xs, ys, color=color, linewidth=1.5, alpha=0.6)
    
    # Draw start and end
    ax.plot(0, 0, 'go', markersize=10, zorder=15, label='Start')
    ax.plot(n, n, 's', color='purple', markersize=10, zorder=15, label='End')
    
    # Area distribution
    gf = {}
    for p in valid_paths:
        a = compute_path_area(p)
        gf[a] = gf.get(a, 0) + 1
    
    # Check palindromic
    max_a = n * n
    is_pal = all(gf.get(a, 0) == gf.get(max_a - a, 0) for a in range(max_a + 1))
    
    total = comb(2*n, n)
    ax.set_title(f'{title}\nWrithe={writhe}, Valid: {len(valid_paths)}/{total}, '
                 f'Palindromic: {"✓" if is_pal else "✗"}',
                 fontsize=11, fontweight='bold')
    ax.set_xlim(-0.5, n + 0.5)
    ax.set_ylim(-0.5, n + 0.5)
    ax.set_aspect('equal')
    ax.set_xlabel('East →')
    ax.set_ylabel('North →')


knots = [
    (2, set(), "Unknot (0₁)", 0),
    (3, {(1, 1)}, "Trefoil (3₁)", 3),
    (4, {(1, 1), (2, 2)}, "Figure-Eight (4₁)", 0),
    (5, {(1, 1), (2, 2)}, "Cinquefoil (5₁)", 5),
    (5, {(1, 1), (3, 3)}, "Solomon's Seal (5₂)", 3),
    (6, {(1, 1), (2, 3), (3, 2)}, "Knot 6₁", 0),
]

fig, axes = plt.subplots(2, 3, figsize=(16, 11))
fig.suptitle('Knot Lattices: Forbidden Regions and Valid Paths',
             fontsize=16, fontweight='bold')

for idx, (n, forbidden, title, writhe) in enumerate(knots):
    ax = axes[idx // 3, idx % 3]
    draw_knot_lattice(ax, n, forbidden, title, writhe)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_knot_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_knot_lattice.png")
