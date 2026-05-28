"""
Visualization: Support Overlap Graph and Overlap Classes

This self-contained script visualizes the overlap structure of a
support family, showing:
1. The original supports as colored sets
2. The overlap graph (vertices = supports, edges = nonempty intersection)
3. The overlap classes (connected components) with distinct colors

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, FrozenSet, List, Set, Tuple
from collections import defaultdict

# ============================================================
# Self-contained overlap computation
# ============================================================

Support = FrozenSet[int]
SupportFamily = List[Support]


def supports_overlap(a: Support, b: Support) -> bool:
    return bool(a & b)


def overlap_classes(family: SupportFamily) -> List[List[int]]:
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    visited = [False] * n
    components: List[List[int]] = []
    for start in range(n):
        if visited[start]:
            continue
        comp: List[int] = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            comp.append(node)
            for nb in adj[node]:
                if not visited[nb]:
                    visited[nb] = True
                    queue.append(nb)
        components.append(comp)
    return components


def cross_overlap_count(a: Support, b: Support) -> int:
    return len(a & b)


# ============================================================
# Visualization
# ============================================================

def visualize_overlap_structure(family: SupportFamily, title: str = "Support Overlap Structure"):
    """Create a comprehensive visualization of the overlap structure."""

    n = len(family)
    classes = overlap_classes(family)
    n_classes = len(classes)

    # Assign colors to overlap classes
    cmap = plt.cm.Set2
    class_colors = {}
    for idx, cls in enumerate(classes):
        color = cmap(idx / max(n_classes, 1))
        for i in cls:
            class_colors[i] = color

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle(title, fontsize=16, fontweight='bold')

    # --- Panel 1: Support elements ---
    ax1 = axes[0]
    ax1.set_title("Support Elements", fontsize=13)

    all_elements = sorted(set().union(*family))
    n_elem = len(all_elements)
    elem_positions = {e: i for i, e in enumerate(all_elements)}

    for i, support in enumerate(family):
        y = n - 1 - i
        for elem in support:
            x = elem_positions[elem]
            ax1.scatter(x, y, color=class_colors[i], s=200, zorder=3,
                       edgecolors='black', linewidth=1)
            ax1.text(x, y, str(elem), ha='center', va='center',
                    fontsize=8, fontweight='bold', zorder=4)

        # Draw a rectangle around the support
        if support:
            xs = [elem_positions[e] for e in support]
            ax1.plot([min(xs) - 0.3, max(xs) + 0.3, max(xs) + 0.3,
                     min(xs) - 0.3, min(xs) - 0.3],
                    [y - 0.3, y - 0.3, y + 0.3, y + 0.3, y - 0.3],
                    color=class_colors[i], linewidth=2, alpha=0.5)

    ax1.set_xlim(-0.5, n_elem - 0.5)
    ax1.set_ylim(-0.5, n - 0.5)
    ax1.set_yticks(range(n))
    ax1.set_yticklabels([f"S{n-1-i}" for i in range(n)])
    ax1.set_xticks(range(n_elem))
    ax1.set_xticklabels(all_elements)
    ax1.set_xlabel("Elements")
    ax1.set_ylabel("Supports")
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: Overlap Graph ---
    ax2 = axes[1]
    ax2.set_title("Overlap Graph", fontsize=13)

    # Position vertices in a circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

    # Draw edges
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                xi, yi = positions[i]
                xj, yj = positions[j]
                count = cross_overlap_count(family[i], family[j])
                ax2.plot([xi, xj], [yi, yj], 'k-', linewidth=1 + count,
                        alpha=0.4, zorder=1)
                mx, my = (xi + xj) / 2, (yi + yj) / 2
                ax2.text(mx, my, str(count), ha='center', va='center',
                        fontsize=8, color='red', fontweight='bold',
                        bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                                 edgecolor='red', alpha=0.8),
                        zorder=5)

    # Draw vertices
    for i in range(n):
        x, y = positions[i]
        ax2.scatter(x, y, color=class_colors[i], s=400, zorder=3,
                   edgecolors='black', linewidth=2)
        ax2.text(x, y, f"S{i}", ha='center', va='center',
                fontsize=10, fontweight='bold', zorder=4)

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.axis('off')

    # --- Panel 3: Overlap Classes ---
    ax3 = axes[2]
    ax3.set_title(f"Overlap Classes ({n_classes} classes)", fontsize=13)

    for cls_idx, cls in enumerate(classes):
        y_base = n_classes - 1 - cls_idx
        color = cmap(cls_idx / max(n_classes, 1))

        # Draw class box
        rect = mpatches.FancyBboxPatch(
            (-0.3, y_base - 0.35), 2.6, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=color, alpha=0.2, edgecolor=color, linewidth=2
        )
        ax3.add_patch(rect)

        # Draw supports in class
        for local_idx, support_idx in enumerate(sorted(cls)):
            x = local_idx * 0.5
            ax3.scatter(x, y_base, color=color, s=200, zorder=3,
                       edgecolors='black', linewidth=1)
            ax3.text(x, y_base, f"S{support_idx}", ha='center', va='center',
                    fontsize=8, fontweight='bold', zorder=4)

        # Class label
        union_set = set()
        for si in cls:
            union_set |= family[si]
        ax3.text(2.5, y_base, f"Class {cls_idx+1}\n|∪| = {len(union_set)}",
                ha='left', va='center', fontsize=9)

    ax3.set_xlim(-0.5, 4)
    ax3.set_ylim(-0.5, n_classes - 0.5)
    ax3.axis('off')

    plt.tight_layout()
    plt.savefig("overlap_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved: overlap_visualization.png")
    plt.close()


# ============================================================
# Main: Generate visualizations for several examples
# ============================================================

if __name__ == "__main__":
    # Example 1: Two overlap classes
    family1: SupportFamily = [
        frozenset({0, 1}),
        frozenset({1, 2}),
        frozenset({2, 3}),
        frozenset({5, 6}),
        frozenset({6, 7}),
    ]
    visualize_overlap_structure(family1,
        "Overlap Structure: Two Classes (Chain + Pair)")

    # Example 2: Fully connected
    family2: SupportFamily = [
        frozenset({0, 1, 2}),
        frozenset({1, 2, 3}),
        frozenset({2, 3, 4}),
        frozenset({3, 4, 0}),
    ]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Overlap Invariant Comparison", fontsize=16, fontweight='bold')

    # Panel 1: Overlap degree vs family size
    sizes = list(range(2, 8))
    degrees_chain = []
    degrees_complete = []
    for n in sizes:
        chain = [frozenset({i, i+1}) for i in range(n)]
        degrees_chain.append(n - 1)  # each pair overlaps
        complete = [frozenset(range(n)) for _ in range(n)]
        degrees_complete.append(n * (n-1) // 2)

    axes[0].plot(sizes, degrees_chain, 'bo-', label='Chain overlap', linewidth=2)
    axes[0].plot(sizes, degrees_complete, 'rs-', label='Complete overlap', linewidth=2)
    axes[0].plot(sizes, [0]*len(sizes), 'g^-', label='Disjoint', linewidth=2)
    axes[0].set_xlabel("Number of supports", fontsize=12)
    axes[0].set_ylabel("Overlap degree", fontsize=12)
    axes[0].set_title("Overlap Degree Growth", fontsize=13)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Panel 2: Class count vs overlap degree
    import random
    random.seed(42)
    deg_list = []
    class_list = []
    for _ in range(100):
        n_s = random.randint(3, 8)
        n_e = random.randint(4, 12)
        fam = [frozenset(random.sample(range(n_e), random.randint(1, 4)))
               for _ in range(n_s)]
        d = sum(1 for i in range(n_s) for j in range(i+1, n_s)
                if fam[i] & fam[j])
        c = len(overlap_classes(fam))
        deg_list.append(d)
        class_list.append(c)

    axes[1].scatter(deg_list, class_list, alpha=0.5, c='purple', s=30)
    axes[1].set_xlabel("Overlap degree", fontsize=12)
    axes[1].set_ylabel("Number of overlap classes", fontsize=12)
    axes[1].set_title("Classes vs Overlap Degree (random families)", fontsize=13)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("overlap_invariants.png", dpi=150, bbox_inches='tight')
    print("Saved: overlap_invariants.png")
    plt.close()
