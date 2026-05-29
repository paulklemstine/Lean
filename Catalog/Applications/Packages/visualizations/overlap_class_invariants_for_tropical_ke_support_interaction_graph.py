#!/usr/bin/env python3
"""
Visualization: Support Interaction Graph and Overlap Classes

Visualizes the support overlap graph for a family of sets.
Each node represents a support (labeled with its elements).
Edges connect overlapping supports. Colors indicate overlap classes.
This illustrates the core concept: overlap classes partition
supports into independent interaction sectors.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
import math


def overlap_classes_uf(family):
    """Find overlap classes using union-find."""
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

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)
                edges.append((i, j))

    groups = defaultdict(list)
    for i in range(n):
        groups[find(i)].append(i)
    return list(groups.values()), edges


def draw_overlap_graph(family, labels=None, title="Support Interaction Graph"):
    """Draw the support overlap graph with overlap class coloring."""
    n = len(family)
    classes, edges = overlap_classes_uf(family)

    # Assign colors to classes
    cmap = plt.cm.Set2
    class_colors = {}
    for ci, cls in enumerate(classes):
        color = cmap(ci / max(len(classes), 1))
        for idx in cls:
            class_colors[idx] = color

    # Layout: arrange in a circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    radius = 2.0
    positions = {i: (radius * np.cos(a), radius * np.sin(a))
                 for i, a in enumerate(angles)}

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw edges
    for i, j in edges:
        xi, yi = positions[i]
        xj, yj = positions[j]
        inter_size = len(family[i] & family[j])
        lw = 1 + inter_size * 0.8
        ax.plot([xi, xj], [yi, yj], 'k-', linewidth=lw, alpha=0.3, zorder=1)
        # Label intersection size
        mx, my = (xi + xj) / 2, (yi + yj) / 2
        ax.text(mx, my, str(inter_size), fontsize=8, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.7),
                zorder=3)

    # Draw nodes
    node_size = 800
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.35, color=class_colors[i],
                            ec='black', linewidth=2, zorder=2)
        ax.add_patch(circle)
        label = labels[i] if labels else str(set(family[i]))
        ax.text(x, y, f"F{i}\n{label}", fontsize=7, ha='center', va='center',
                fontweight='bold', zorder=4)

    # Legend for overlap classes
    legend_patches = []
    for ci, cls in enumerate(classes):
        color = cmap(ci / max(len(classes), 1))
        members = ', '.join(f'F{i}' for i in cls)
        legend_patches.append(
            mpatches.Patch(color=color, label=f'Class {ci+1}: {members}'))

    ax.legend(handles=legend_patches, loc='upper left', fontsize=9)

    # Annotations
    info_text = (f"Supports: {n}  |  "
                 f"Overlap classes: {len(classes)}  |  "
                 f"Overlap degree: {len(edges)}")
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.text(0.5, -0.05, info_text, transform=ax.transAxes,
            ha='center', fontsize=10, style='italic')

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    return fig


# ─────────────────────────────────────────────────────────────────────
# Main visualization
# ─────────────────────────────────────────────────────────────────────

# Example: family with 3 overlap classes
family = [
    frozenset({1, 2, 3}),      # Class 1
    frozenset({3, 4, 5}),      # Class 1 (overlaps with F0)
    frozenset({4, 5, 6}),      # Class 1 (overlaps with F1)
    frozenset({10, 11, 12}),   # Class 2
    frozenset({12, 13}),       # Class 2 (overlaps with F3)
    frozenset({20, 21, 22}),   # Class 3 (isolated)
]

fig = draw_overlap_graph(
    family,
    title="Support Interaction Graph — Three Overlap Classes"
)
plt.tight_layout()
plt.savefig("viz_overlap_graph.png", dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")
