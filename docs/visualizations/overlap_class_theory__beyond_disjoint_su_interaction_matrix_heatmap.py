#!/usr/bin/env python3
"""
Visualization 3: Support Interaction Matrix Heatmap
====================================================
Visualizes the support interaction matrix as a heatmap,
showing how the matrix structure reflects overlap classes.
Compares a fully connected family vs a block-diagonal one.
"""

import matplotlib.pyplot as plt
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


def interaction_matrix(supports: List[Set[int]]) -> np.ndarray:
    n = len(supports)
    M = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            M[i][j] = len(supports[i]) if i == j else len(supports[i] & supports[j])
    return M


# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

examples = [
    ("Block-Diagonal\n(3 overlap classes)",
     [{1, 2, 3, 4}, {3, 4, 5},
      {10, 11, 12}, {11, 12, 13},
      {20, 21}, {21, 22, 23}]),
    ("Single Block\n(1 overlap class)",
     [{1, 2, 3, 4}, {3, 4, 5, 6}, {5, 6, 7, 1},
      {2, 7, 8}, {8, 9, 1}, {6, 9, 10}]),
    ("Fully Disjoint\n(6 overlap classes)",
     [{1, 2}, {3, 4}, {5, 6}, {7, 8}, {9, 10}, {11, 12}]),
]

for ax_idx, (title, supports) in enumerate(examples):
    ax = axes[ax_idx]
    M = interaction_matrix(supports)
    classes = compute_overlap_classes(supports)

    # Reorder by overlap class for visual clarity
    order = []
    for cls in classes:
        order.extend(sorted(cls))
    M_reordered = M[np.ix_(order, order)]

    # Plot heatmap
    im = ax.imshow(M_reordered, cmap='YlOrRd', interpolation='nearest',
                   aspect='equal')

    # Add text annotations
    n = len(supports)
    for i in range(n):
        for j in range(n):
            val = M_reordered[i, j]
            text_color = 'white' if val > M.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                   fontsize=10, fontweight='bold', color=text_color)

    # Draw class boundaries
    pos = 0
    for cls in classes:
        size = len(cls)
        if pos > 0:
            ax.axhline(y=pos - 0.5, color='blue', linewidth=2, alpha=0.7)
            ax.axvline(x=pos - 0.5, color='blue', linewidth=2, alpha=0.7)
        pos += size

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'F{order[i]}' for i in range(n)], fontsize=8)
    ax.set_yticklabels([f'F{order[i]}' for i in range(n)], fontsize=8)
    ax.set_title(f'{title}\n{len(classes)} class{"es" if len(classes) > 1 else ""}',
                fontsize=12, fontweight='bold')

    # Add colorbar
    cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Intersection Size', fontsize=9)

fig.suptitle('Support Interaction Matrix — Block Structure Reflects Overlap Classes',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_interaction_matrix.png', dpi=150, bbox_inches='tight')
print("Saved viz_interaction_matrix.png")
