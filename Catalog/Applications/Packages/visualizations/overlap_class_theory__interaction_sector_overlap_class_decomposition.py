"""
Overlap Class Visualization — Support Interaction Graph

Visualizes the core mathematical concept: how overlapping supports
decompose into independent interaction sectors (overlap classes).
Shows a family of supports, their overlap graph, and the resulting
class decomposition with color-coding.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict, deque
from itertools import combinations
from typing import List, Set, Dict, FrozenSet


# ============================================================
# Self-contained implementations
# ============================================================

class SupportFamily:
    def __init__(self, supports):
        self.supports = list(supports)
        self.n = len(supports)


def compute_overlap_classes(family):
    adj = defaultdict(set)
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(family.n):
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            component.append(v)
            for w in adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        classes.append(sorted(component))
    return classes


def overlap_degree(family):
    count = 0
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            count += 1
    return count


# ============================================================
# Visualization
# ============================================================

def visualize_overlap_classes():
    """Create a comprehensive visualization of overlap class theory."""

    # Define a rich support family
    family = SupportFamily([
        frozenset({0, 1, 2, 3}),       # S₀
        frozenset({2, 3, 4, 5}),       # S₁ (overlaps S₀)
        frozenset({4, 5, 6}),          # S₂ (overlaps S₁)
        frozenset({10, 11, 12}),       # S₃ (isolated cluster)
        frozenset({12, 13, 14}),       # S₄ (overlaps S₃)
        frozenset({20, 21}),           # S₅ (singleton class)
    ])

    classes = compute_overlap_classes(family)

    # Color scheme for classes
    class_colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']
    idx_to_class = {}
    for ci, cls in enumerate(classes):
        for idx in cls:
            idx_to_class[idx] = ci

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Overlap Class Decomposition of Support Families',
                 fontsize=16, fontweight='bold', y=0.98)

    # ---- Panel 1: Support Sets as Intervals ----
    ax1 = axes[0]
    ax1.set_title('Support Family', fontsize=13, fontweight='bold')

    all_elements = set()
    for s in family.supports:
        all_elements |= s
    elem_list = sorted(all_elements)
    elem_to_x = {e: i for i, e in enumerate(elem_list)}

    for i in range(family.n):
        color = class_colors[idx_to_class[i] % len(class_colors)]
        y = family.n - 1 - i
        elements = sorted(family.supports[i])
        xs = [elem_to_x[e] for e in elements]
        ax1.scatter(xs, [y] * len(xs), color=color, s=80, zorder=5,
                   edgecolors='black', linewidths=0.5)
        # Connect elements with a line
        if len(xs) > 1:
            ax1.plot([min(xs) - 0.2, max(xs) + 0.2], [y, y],
                    color=color, linewidth=3, alpha=0.3)
        ax1.text(-1.5, y, f'S{i}', fontsize=11, ha='right', va='center',
                fontweight='bold', color=color)

    ax1.set_xlim(-2.5, len(elem_list))
    ax1.set_ylim(-0.5, family.n - 0.5)
    ax1.set_xlabel('Ground Set Elements', fontsize=10)
    ax1.set_xticks(range(len(elem_list)))
    ax1.set_xticklabels(elem_list, fontsize=8)
    ax1.set_yticks([])
    ax1.spines['top'].set_visible(False)
    ax1.spines['right'].set_visible(False)
    ax1.spines['left'].set_visible(False)

    # ---- Panel 2: Overlap Graph ----
    ax2 = axes[1]
    ax2.set_title('Support Overlap Graph', fontsize=13, fontweight='bold')

    # Position nodes in a circle
    n = family.n
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) - np.pi/2
    radius = 1.5
    positions = [(radius * np.cos(a), radius * np.sin(a)) for a in angles]

    # Draw edges
    for i, j in combinations(range(n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            isect_size = len(family.supports[i] & family.supports[j])
            x1, y1 = positions[i]
            x2, y2 = positions[j]
            ax2.plot([x1, x2], [y1, y2], 'k-', linewidth=1 + isect_size,
                    alpha=0.3, zorder=1)
            # Label edge with intersection size
            mx, my = (x1+x2)/2, (y1+y2)/2
            ax2.text(mx, my + 0.15, f'{isect_size}', fontsize=8,
                    ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                            edgecolor='gray', alpha=0.8))

    # Draw nodes
    for i in range(n):
        color = class_colors[idx_to_class[i] % len(class_colors)]
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.25, color=color, ec='black',
                           linewidth=1.5, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x, y, f'S{i}', fontsize=10, ha='center', va='center',
                fontweight='bold', color='white', zorder=6)

    ax2.set_xlim(-2.5, 2.5)
    ax2.set_ylim(-2.5, 2.5)
    ax2.set_aspect('equal')
    ax2.axis('off')

    # ---- Panel 3: Class Decomposition ----
    ax3 = axes[2]
    ax3.set_title('Overlap Classes', fontsize=13, fontweight='bold')

    for ci, cls in enumerate(classes):
        color = class_colors[ci % len(class_colors)]
        y_base = len(classes) - 1 - ci

        # Draw class box
        rect = mpatches.FancyBboxPatch(
            (0.1, y_base - 0.35), 3.8, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=color, alpha=0.15, edgecolor=color, linewidth=2
        )
        ax3.add_patch(rect)

        # Class label
        ax3.text(0.3, y_base + 0.15, f'Class {ci+1}',
                fontsize=11, fontweight='bold', color=color)

        # Members
        members = ', '.join(f'S{j}' for j in cls)
        ax3.text(0.3, y_base - 0.15, members,
                fontsize=10, color='black')

        # Union of supports
        union = set()
        for idx in cls:
            union |= family.supports[idx]
        ax3.text(2.5, y_base, f'∪ = {sorted(union)}',
                fontsize=8, color='gray', va='center')

    ax3.set_xlim(0, 4)
    ax3.set_ylim(-0.5, len(classes) - 0.5)
    ax3.axis('off')

    # Add summary text
    od = overlap_degree(family)
    fig.text(0.5, 0.02,
            f'Family size: {n} supports | Overlap degree: {od} | '
            f'Overlap classes: {len(classes)} | '
            f'Key theorem: supports across classes are disjoint',
            ha='center', fontsize=10, style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow',
                     edgecolor='orange', alpha=0.8))

    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig('overlap_classes_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: overlap_classes_visualization.png")


if __name__ == "__main__":
    visualize_overlap_classes()
