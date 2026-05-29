"""
Visualization: Overlap Graph and Class Decomposition

Visualizes a support family as an overlap graph, with connected components
(overlap classes) colored differently. Shows the transition from the
pairwise disjoint regime to the overlapping regime.

This script is fully self-contained — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, FrozenSet, Dict, Set, Tuple
import math


# ---- Inline overlap algorithms ----

def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    return len(A & B) > 0

def overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    n = len(family)
    if n == 0: return []
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i+1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j); adj[j].add(i)
    visited = [False]*n; comps = []
    for s in range(n):
        if visited[s]: continue
        comp = []; q = [s]; visited[s] = True
        while q:
            nd = q.pop(0); comp.append(nd)
            for nb in sorted(adj[nd]):
                if not visited[nb]: visited[nb] = True; q.append(nb)
        comps.append(sorted(comp))
    return comps

def overlap_degree(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1,n) if supports_overlap(family[i], family[j]))


# ---- Visualization ----

def plot_overlap_analysis(families, titles, filename="overlap_analysis.png"):
    """Create a multi-panel visualization of overlap class decomposition."""

    n_panels = len(families)
    fig, axes = plt.subplots(1, n_panels, figsize=(6*n_panels, 6))
    if n_panels == 1:
        axes = [axes]

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6',
              '#1abc9c', '#e67e22', '#34495e']

    for panel_idx, (family, title) in enumerate(zip(families, titles)):
        ax = axes[panel_idx]
        n = len(family)
        classes = overlap_classes(family)
        class_map = {}
        for cls_idx, cls in enumerate(classes):
            for i in cls:
                class_map[i] = cls_idx

        # Layout: circular arrangement
        angles = [2 * math.pi * i / n for i in range(n)]
        radius = 2.0
        positions = [(radius * math.cos(a), radius * math.sin(a)) for a in angles]

        # Draw edges (overlapping pairs)
        for i in range(n):
            for j in range(i+1, n):
                if supports_overlap(family[i], family[j]):
                    xi, yi = positions[i]
                    xj, yj = positions[j]
                    inter_size = len(family[i] & family[j])
                    lw = 1 + inter_size * 0.5
                    ax.plot([xi, xj], [yi, yj], color='#bdc3c7', linewidth=lw,
                            zorder=1, alpha=0.6)
                    # Label intersection size
                    mx, my = (xi+xj)/2, (yi+yj)/2
                    ax.text(mx, my, str(inter_size), fontsize=8,
                            ha='center', va='center',
                            bbox=dict(boxstyle='round,pad=0.2',
                                      facecolor='white', alpha=0.8),
                            zorder=3)

        # Draw nodes
        for i in range(n):
            x, y = positions[i]
            cls_idx = class_map[i]
            color = colors[cls_idx % len(colors)]
            circle = plt.Circle((x, y), 0.35, facecolor=color,
                                edgecolor='black', linewidth=2, zorder=4)
            ax.add_patch(circle)
            ax.text(x, y, f"S{i}", fontsize=10, fontweight='bold',
                    ha='center', va='center', color='white', zorder=5)

            # Show support contents
            support_str = '{' + ','.join(str(v) for v in sorted(family[i])) + '}'
            ax.text(x, y - 0.55, support_str, fontsize=7,
                    ha='center', va='top', color=color, zorder=5)

        # Legend for classes
        legend_patches = []
        for cls_idx, cls in enumerate(classes):
            color = colors[cls_idx % len(colors)]
            label = f"Class {cls_idx}: indices {cls}"
            legend_patches.append(mpatches.Patch(color=color, label=label))

        ax.legend(handles=legend_patches, loc='upper right', fontsize=8,
                  framealpha=0.9)

        # Title and stats
        od = overlap_degree(family)
        nc = len(classes)
        ax.set_title(f"{title}\nOverlap deg={od}, Classes={nc}", fontsize=12,
                     fontweight='bold')

        ax.set_xlim(-3.5, 3.5)
        ax.set_ylim(-3.5, 3.5)
        ax.set_aspect('equal')
        ax.axis('off')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
    print(f"Saved visualization to {filename}")


# ---- Main ----

# Panel 1: Pairwise disjoint family (3 classes)
family1 = [
    frozenset({1, 2}),
    frozenset({3, 4}),
    frozenset({5, 6}),
]

# Panel 2: Partial overlap (2 classes)
family2 = [
    frozenset({1, 2, 3}),
    frozenset({3, 4, 5}),
    frozenset({7, 8}),
    frozenset({8, 9}),
]

# Panel 3: Dense overlap (1 class)
family3 = [
    frozenset({1, 2, 3}),
    frozenset({2, 3, 4}),
    frozenset({4, 5, 1}),
    frozenset({3, 5, 6}),
]

plot_overlap_analysis(
    [family1, family2, family3],
    ["Pairwise Disjoint\n(Classical Regime)",
     "Partial Overlap\n(Two Sectors)",
     "Dense Overlap\n(Single Cluster)"],
    "overlap_analysis.png"
)
