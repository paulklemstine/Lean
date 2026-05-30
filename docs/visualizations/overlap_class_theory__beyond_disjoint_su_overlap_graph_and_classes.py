#!/usr/bin/env python3
"""
Visualization 1: Overlap Graph and Classes
===========================================
Visualizes the overlap graph of a support family, coloring
vertices by their overlap class. Shows how supports that share
elements form connected components in the overlap graph.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict, deque
from typing import List, Set, Dict


def compute_overlap_classes(supports: List[Set[int]]) -> List[Set[int]]:
    n = len(supports)
    if n == 0:
        return []
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(n):
        adj[i]
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(n):
        if start in visited:
            continue
        component: Set[int] = set()
        queue = deque([start])
        while queue:
            node = queue.popleft()
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj.get(node, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        classes.append(component)
    return classes


def overlap_graph_edges(supports: List[Set[int]]) -> List[tuple]:
    edges = []
    for i, j in combinations(range(len(supports)), 2):
        if supports[i] & supports[j]:
            edges.append((i, j, len(supports[i] & supports[j])))
    return edges


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Color palette
colors = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12', '#9B59B6', '#1ABC9C']

examples = [
    ("Fully Disjoint (3 classes)",
     [{1, 2, 3}, {4, 5, 6}, {7, 8, 9}]),
    ("Chain Overlap (2 classes)",
     [{1, 2, 3}, {3, 4, 5}, {5, 6, 7}, {10, 11}]),
    ("Fully Connected (1 class)",
     [{1, 2, 3, 4}, {3, 4, 5, 6}, {5, 6, 7, 1}]),
]

for ax_idx, (title, supports) in enumerate(examples):
    ax = axes[ax_idx]
    n = len(supports)
    classes = compute_overlap_classes(supports)
    edges = overlap_graph_edges(supports)

    # Layout: circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    angles = angles - np.pi / 2  # start from top
    radius = 1.5
    positions = [(radius * np.cos(a), radius * np.sin(a)) for a in angles]

    # Assign colors by class
    vertex_colors = ['gray'] * n
    for cls_idx, cls in enumerate(classes):
        for v in cls:
            vertex_colors[v] = colors[cls_idx % len(colors)]

    # Draw edges
    for i, j, weight in edges:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        lw = 1 + weight * 0.8
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=lw, alpha=0.4, zorder=1)
        # Label with intersection size
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx, my, str(weight), fontsize=8, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8),
                zorder=3)

    # Draw vertices
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.35, color=vertex_colors[i],
                           ec='black', linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, f'F{i}', fontsize=11, ha='center', va='center',
                fontweight='bold', color='white', zorder=4)
        # Show support below
        support_str = str(sorted(supports[i]))
        ax.text(x, y - 0.55, support_str, fontsize=7, ha='center', va='top',
                color='gray')

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.axis('off')

    # Legend
    legend_patches = []
    for cls_idx, cls in enumerate(classes):
        patch = mpatches.Patch(color=colors[cls_idx % len(colors)],
                              label=f'Class {cls_idx + 1}: {sorted(cls)}')
        legend_patches.append(patch)
    ax.legend(handles=legend_patches, loc='lower center', fontsize=8,
             framealpha=0.9, ncol=1)

fig.suptitle('Overlap Graphs and Equivalence Classes',
            fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_overlap_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")
