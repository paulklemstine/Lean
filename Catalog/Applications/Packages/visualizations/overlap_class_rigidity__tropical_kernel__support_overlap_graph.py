"""
Visualization: Support Overlap Graph and Overlap Classes

This script visualizes the support overlap graph for a family of finite sets.
It shows how supports are connected via shared elements and colors the
connected components (overlap classes) distinctly.

What it visualizes:
- Each node represents a support set in the family
- Edges connect supports with nonempty intersection
- Colors indicate overlap classes (connected components)
- Node labels show the support elements
- Edge labels show shared elements
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict


def compute_overlap_classes(supports):
    """Compute overlap classes using union-find."""
    n = len(supports)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    edges = []
    for i, j in combinations(range(n), 2):
        shared = supports[i] & supports[j]
        if shared:
            union(i, j)
            edges.append((i, j, shared))

    components = defaultdict(list)
    for i in range(n):
        components[find(i)].append(i)

    return list(components.values()), edges


def layout_circular(n, radius=2.0):
    """Compute circular layout positions."""
    positions = {}
    for i in range(n):
        angle = 2 * np.pi * i / n - np.pi / 2
        positions[i] = (radius * np.cos(angle), radius * np.sin(angle))
    return positions


def draw_overlap_graph(supports, title="Support Overlap Graph", ax=None):
    """Draw the support overlap graph with colored overlap classes."""
    if ax is None:
        fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    else:
        fig = ax.figure

    n = len(supports)
    classes, edges = compute_overlap_classes(supports)
    positions = layout_circular(n)

    # Color palette for classes
    colors = plt.cm.Set2(np.linspace(0, 1, max(len(classes), 1)))

    # Map index to class color
    idx_to_color = {}
    for ci, cls in enumerate(classes):
        for idx in cls:
            idx_to_color[idx] = colors[ci]

    # Draw edges
    for i, j, shared in edges:
        x = [positions[i][0], positions[j][0]]
        y = [positions[i][1], positions[j][1]]
        ax.plot(x, y, 'k-', alpha=0.4, linewidth=2)
        # Label edge with shared elements
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.annotate(f"∩={set(shared)}", (mx, my),
                   fontsize=7, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.8))

    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.4, color=idx_to_color[i],
                           ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, f"S{i}\n{set(supports[i])}", ha='center', va='center',
               fontsize=8, fontweight='bold', zorder=6)

    # Legend
    legend_patches = []
    for ci, cls in enumerate(classes):
        patch = mpatches.Patch(color=colors[ci],
                              label=f"Class {ci}: indices {cls}")
        legend_patches.append(patch)
    ax.legend(handles=legend_patches, loc='upper left', fontsize=9)

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.axis('off')

    return fig, ax


# Create the visualization
fig, axes = plt.subplots(2, 2, figsize=(16, 14))
fig.suptitle("Support Overlap Graphs and Overlap Classes", fontsize=16, fontweight='bold')

# Example 1: Fully disjoint
supports1 = [
    frozenset({0, 1}),
    frozenset({2, 3}),
    frozenset({4, 5}),
    frozenset({6, 7}),
]
draw_overlap_graph(supports1, "Pairwise Disjoint\n(4 classes, 0 edges)", axes[0, 0])

# Example 2: Single overlap
supports2 = [
    frozenset({0, 1, 2}),
    frozenset({2, 3, 4}),
    frozenset({5, 6}),
    frozenset({7, 8}),
]
draw_overlap_graph(supports2, "Single Overlap\n(3 classes, 1 edge)", axes[0, 1])

# Example 3: Chain overlap
supports3 = [
    frozenset({0, 1}),
    frozenset({1, 2}),
    frozenset({2, 3}),
    frozenset({5, 6}),
]
draw_overlap_graph(supports3, "Chain Overlap\n(2 classes, 2 edges)", axes[1, 0])

# Example 4: Dense overlap
supports4 = [
    frozenset({0, 1, 2}),
    frozenset({1, 2, 3}),
    frozenset({2, 3, 4}),
    frozenset({0, 4}),
]
draw_overlap_graph(supports4, "Dense Overlap\n(1 class, 5 edges)", axes[1, 1])

plt.tight_layout()
plt.savefig('overlap_graph_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overlap_graph_visualization.png")
