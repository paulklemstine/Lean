"""
Visualization: Cross-Overlap Count Heatmap

This script creates a heatmap showing the pairwise intersection sizes
between supports in a family. The heatmap makes the overlap pattern
immediately visible: disjoint pairs appear as zeros (white), while
overlapping pairs show the intersection cardinality (colored).

What it visualizes:
- Pairwise intersection cardinalities between all supports
- Darker colors indicate larger intersections
- Block-diagonal structure reveals overlap classes
- Annotations show exact intersection sizes
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


def compute_cross_overlap_matrix(supports):
    """Compute the matrix of pairwise intersection sizes."""
    n = len(supports)
    matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            matrix[i, j] = len(supports[i] & supports[j])
    return matrix


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

    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            union(i, j)

    components = defaultdict(list)
    for i in range(n):
        components[find(i)].append(i)
    return list(components.values())


def reorder_by_classes(supports, classes):
    """Reorder indices so that overlap classes are contiguous."""
    order = []
    for cls in classes:
        order.extend(sorted(cls))
    return order


def draw_heatmap(supports, title, ax):
    """Draw the cross-overlap heatmap."""
    classes = compute_overlap_classes(supports)
    order = reorder_by_classes(supports, classes)
    n = len(supports)

    reordered = [supports[i] for i in order]
    matrix = compute_cross_overlap_matrix(reordered)

    # Zero out diagonal for cleaner visualization
    np.fill_diagonal(matrix, 0)

    im = ax.imshow(matrix, cmap='YlOrRd', aspect='equal', vmin=0)

    # Add text annotations
    for i in range(n):
        for j in range(n):
            val = matrix[i, j]
            color = 'white' if val > 2 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                   fontsize=10, fontweight='bold', color=color)

    # Labels
    labels = [f"S{order[i]}" for i in range(n)]
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=9)
    ax.set_yticklabels(labels, fontsize=9)

    # Draw class boundaries
    pos = 0
    for cls in classes:
        size = len(cls)
        if pos > 0:
            ax.axhline(y=pos - 0.5, color='blue', linewidth=2, linestyle='--')
            ax.axvline(x=pos - 0.5, color='blue', linewidth=2, linestyle='--')
        pos += size

    ax.set_title(title, fontsize=12, fontweight='bold')
    return im


# Create the visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Cross-Overlap Count Heatmaps\n(Blue dashed lines separate overlap classes)",
             fontsize=14, fontweight='bold')

# Example 1: Fully disjoint (6 supports)
supports1 = [
    frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5}),
    frozenset({6, 7}), frozenset({8, 9}), frozenset({10, 11}),
]
draw_heatmap(supports1, "Disjoint: 6 classes", axes[0, 0])

# Example 2: Two clusters
supports2 = [
    frozenset({0, 1, 2}), frozenset({1, 2, 3}), frozenset({2, 3, 4}),
    frozenset({10, 11}), frozenset({11, 12}), frozenset({20, 21}),
]
draw_heatmap(supports2, "Two clusters + isolated", axes[0, 1])

# Example 3: Chain
supports3 = [
    frozenset({0, 1}), frozenset({1, 2}), frozenset({2, 3}),
    frozenset({3, 4}), frozenset({4, 5}), frozenset({10, 11}),
]
draw_heatmap(supports3, "Chain + isolated", axes[1, 0])

# Example 4: Star
supports4 = [
    frozenset({0, 1, 2, 3}),
    frozenset({0, 4, 5}),
    frozenset({0, 6, 7}),
    frozenset({0, 8, 9}),
    frozenset({0, 10, 11}),
    frozenset({20, 21}),
]
draw_heatmap(supports4, "Star pattern + isolated", axes[1, 1])

plt.tight_layout()
plt.savefig('overlap_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overlap_heatmap.png")
