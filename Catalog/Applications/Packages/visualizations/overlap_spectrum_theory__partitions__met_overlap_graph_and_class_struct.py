#!/usr/bin/env python3
"""
Visualization: Overlap Graph and Class Structure

Visualizes the overlap graph of a support family, with nodes colored
by overlap class. Shows how the connected components of the overlap
graph decompose the family into independent interaction sectors.

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
import math


def compute_overlap_classes_inline(family):
    """Union-find overlap class computation (self-contained)."""
    n = len(family)
    parent = list(range(n))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


def compute_edges(family):
    """Find all overlapping pairs."""
    edges = []
    for i in range(len(family)):
        for j in range(i + 1, len(family)):
            if len(family[i] & family[j]) > 0:
                edges.append((i, j))
    return edges


# Define the support family
family = [
    {1, 2, 3},      # F₀
    {3, 4, 5},      # F₁
    {5, 6},          # F₂
    {7, 8},          # F₃
    {8, 9, 10},      # F₄
    {11, 12},        # F₅
]

n = len(family)
classes = compute_overlap_classes_inline(family)
edges = compute_edges(family)
spectrum = sorted([len(c) for c in classes], reverse=True)

# Assign colors to classes
colors_palette = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']
node_colors = ['grey'] * n
for cls_idx, cls in enumerate(classes):
    for i in cls:
        node_colors[i] = colors_palette[cls_idx % len(colors_palette)]

# Layout: place nodes in a circle
angles = [2 * math.pi * i / n for i in range(n)]
positions = [(math.cos(a), math.sin(a)) for a in angles]

# Create the figure
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: The overlap graph
ax1 = axes[0]
ax1.set_title("Overlap Graph", fontsize=14, fontweight='bold')
ax1.set_aspect('equal')
ax1.set_xlim(-1.6, 1.6)
ax1.set_ylim(-1.6, 1.6)

# Draw edges
for i, j in edges:
    x = [positions[i][0], positions[j][0]]
    y = [positions[i][1], positions[j][1]]
    ax1.plot(x, y, 'k-', linewidth=1.5, alpha=0.5)

# Draw nodes
for i in range(n):
    circle = plt.Circle(positions[i], 0.15, color=node_colors[i], 
                        ec='black', linewidth=2, zorder=5)
    ax1.add_patch(circle)
    ax1.text(positions[i][0], positions[i][1], f'F{i}', 
             ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)

# Legend
legend_patches = []
for cls_idx, cls in enumerate(classes):
    label = f"Class {cls_idx+1}: " + ", ".join(f"F{i}" for i in cls)
    legend_patches.append(mpatches.Patch(
        color=colors_palette[cls_idx % len(colors_palette)], label=label))
ax1.legend(handles=legend_patches, loc='lower center', fontsize=8)
ax1.axis('off')

# Panel 2: Support Venn-style diagram
ax2 = axes[1]
ax2.set_title("Support Sets (Element View)", fontsize=14, fontweight='bold')
ax2.set_aspect('equal')

# Draw supports as colored rectangles with element labels
all_elements = sorted(set().union(*family))
elem_y = {elem: i for i, elem in enumerate(all_elements)}
max_y = len(all_elements)

for i in range(n):
    x_start = i * 1.2
    for elem in sorted(family[i]):
        y_pos = elem_y[elem]
        rect = plt.Rectangle((x_start, y_pos - 0.3), 0.8, 0.6,
                             facecolor=node_colors[i], alpha=0.6, 
                             edgecolor='black', linewidth=1)
        ax2.add_patch(rect)
        ax2.text(x_start + 0.4, y_pos, str(elem), 
                ha='center', va='center', fontsize=8)
    ax2.text(x_start + 0.4, -1, f'F{i}', ha='center', va='center',
            fontsize=10, fontweight='bold', color=node_colors[i])

ax2.set_xlim(-0.5, n * 1.2 + 0.5)
ax2.set_ylim(-2, max_y + 1)
ax2.set_ylabel("Element value", fontsize=10)
ax2.axis('off')

# Panel 3: Overlap spectrum (partition diagram)
ax3 = axes[2]
ax3.set_title(f"Overlap Spectrum: {spectrum}", fontsize=14, fontweight='bold')

# Draw Young diagram
max_part = max(spectrum) if spectrum else 0
for row_idx, part_size in enumerate(spectrum):
    for col in range(part_size):
        rect = plt.Rectangle((col, len(spectrum) - 1 - row_idx), 0.9, 0.9,
                             facecolor=colors_palette[row_idx % len(colors_palette)],
                             alpha=0.7, edgecolor='black', linewidth=2)
        ax3.add_patch(rect)
        ax3.text(col + 0.45, len(spectrum) - 0.55 - row_idx, 
                str(col + 1), ha='center', va='center', fontsize=10)

ax3.set_xlim(-0.5, max_part + 0.5)
ax3.set_ylim(-0.5, len(spectrum) + 0.5)
ax3.set_xlabel("Class size", fontsize=10)
ax3.set_ylabel("Class index", fontsize=10)
ax3.text(max_part / 2, -0.3, f"Sum = {sum(spectrum)} = n = {n}", 
         ha='center', fontsize=11, style='italic')
ax3.axis('off')

plt.suptitle("Overlap Spectrum Theory: Graph → Classes → Partition", 
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_overlap_graph.png", dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")
