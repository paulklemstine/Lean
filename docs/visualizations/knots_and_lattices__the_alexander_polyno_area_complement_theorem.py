#!/usr/bin/env python3
"""
Visualization: Area Complement Theorem
========================================
Visualizes the Area Complement Theorem for lattice paths.
Shows a lattice path and its complement side by side, with shaded areas
demonstrating that area(path) + area(complement) = m * n.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import combinations


def path_from_east_positions(m, n, east_pos):
    """Create a lattice path from East step positions."""
    path = [False] * (m + n)
    for pos in east_pos:
        path[pos] = True
    return path


def compute_path_area(path):
    area, h = 0, 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def path_coordinates(path):
    """Get the (x, y) coordinates of a lattice path."""
    coords = [(0, 0)]
    x, y = 0, 0
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        coords.append((x, y))
    return coords


def draw_lattice_path(ax, path, m, n, title, color='#2196F3', fill_color='#BBDEFB'):
    """Draw a lattice path with shaded area."""
    coords = path_coordinates(path)
    xs, ys = zip(*coords)
    
    # Draw grid
    for i in range(m + 1):
        ax.plot([i, i], [0, n], 'lightgray', linewidth=0.5)
    for j in range(n + 1):
        ax.plot([0, m], [j, j], 'lightgray', linewidth=0.5)
    
    # Shade area under the path
    # For each East step at height h, shade the rectangle below
    x_pos, y_pos = 0, 0
    for step in path:
        if step:  # East step
            if y_pos > 0:
                rect = patches.Rectangle((x_pos, 0), 1, y_pos,
                                         facecolor=fill_color, edgecolor='none', alpha=0.7)
                ax.add_patch(rect)
            x_pos += 1
        else:
            y_pos += 1
    
    # Draw the path
    ax.plot(xs, ys, color=color, linewidth=3, marker='o', markersize=6, zorder=5)
    
    # Draw diagonal reference
    ax.plot([0, min(m, n)], [0, min(m, n)], '--', color='gray', alpha=0.4, linewidth=1)
    
    area = compute_path_area(path)
    ax.set_title(f'{title}\nArea = {area}', fontsize=13, fontweight='bold')
    ax.set_xlim(-0.3, m + 0.3)
    ax.set_ylim(-0.3, n + 0.3)
    ax.set_aspect('equal')
    ax.set_xlabel('East →', fontsize=10)
    ax.set_ylabel('North →', fontsize=10)


# Generate example paths for m=3, n=3
m, n = 3, 3
example_paths = [
    ([True, False, True, False, True, False], "ENENENE"),
    ([True, True, True, False, False, False], "EEENNN"),
    ([False, True, False, True, False, True], "NENENE"),
    ([True, False, False, True, True, False], "ENNEEN"),
]

fig, axes = plt.subplots(len(example_paths), 2, figsize=(12, 4 * len(example_paths)))
fig.suptitle('Area Complement Theorem: area(p) + area(complement) = m × n = 9',
             fontsize=16, fontweight='bold', y=0.98)

for idx, (path, name) in enumerate(example_paths):
    comp = [not s for s in path]
    area_p = compute_path_area(path)
    area_c = compute_path_area(comp)
    
    draw_lattice_path(axes[idx, 0], path, m, n, 
                      f'Path: {name}', '#2196F3', '#BBDEFB')
    
    comp_name = ''.join('N' if s else 'E' for s in path)
    draw_lattice_path(axes[idx, 1], comp, n, m,
                      f'Complement: {comp_name}', '#F44336', '#FFCDD2')
    
    # Add verification text
    axes[idx, 1].text(m + 0.1, n/2, f'{area_p} + {area_c} = {area_p + area_c}',
                      fontsize=12, color='green', fontweight='bold',
                      transform=axes[idx, 1].transData,
                      verticalalignment='center')

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_area_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_area_complement.png")
