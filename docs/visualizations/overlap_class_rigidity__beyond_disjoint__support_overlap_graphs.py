"""
Visualization: Support Overlap Graph and Overlap Classes

Visualizes a family of finite sets and their overlap graph. Each support is
shown as a node colored by its overlap class. Edges indicate nonempty
intersection, with edge width proportional to intersection size.

This visualizes the core mathematical objects defined in
OverlapClassRigidity.lean: SupportOverlapGraph and overlapClassCount.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
from typing import List, FrozenSet, Dict, Set, Tuple


def supports_overlap(a: FrozenSet[int], b: FrozenSet[int]) -> bool:
    return len(a & b) > 0

def find_overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    n = len(family)
    if n == 0: return []
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                union(i, j)
    classes: Dict[int, List[int]] = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())

def spring_layout(adj: Dict[int, Set[int]], n: int, iterations: int = 50) -> Dict[int, Tuple[float, float]]:
    """Simple spring layout."""
    np.random.seed(42)
    pos = {i: np.random.randn(2) for i in range(n)}
    for _ in range(iterations):
        forces = {i: np.zeros(2) for i in range(n)}
        for i in range(n):
            for j in range(n):
                if i == j: continue
                d = pos[j] - pos[i]
                dist = max(np.linalg.norm(d), 0.01)
                forces[i] -= d / (dist ** 2) * 0.5  # repulsion
                if j in adj.get(i, set()):
                    forces[i] += d * 0.1  # attraction
        for i in range(n):
            pos[i] += forces[i] * 0.1
    return pos


# ====== Example families ======
families = {
    "Pairwise Disjoint\n(3 classes)": [
        frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})
    ],
    "Chain Overlap\n(1 class)": [
        frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4}), frozenset({4, 5})
    ],
    "Two Clusters\n(2 classes)": [
        frozenset({1, 2}), frozenset({2, 3}), frozenset({5, 6}), frozenset({6, 7})
    ],
    "Star Overlap\n(1 class)": [
        frozenset({0, 1}), frozenset({0, 2}), frozenset({0, 3}), frozenset({0, 4})
    ],
}

colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Support Overlap Graphs and Overlap Classes', fontsize=16, fontweight='bold')

for idx, (name, family) in enumerate(families.items()):
    ax = axes[idx // 2][idx % 2]
    n = len(family)

    # Build overlap graph
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)

    # Find classes
    classes = find_overlap_classes(family)
    class_map = {}
    for ci, cls in enumerate(classes):
        for idx_in_cls in cls:
            class_map[idx_in_cls] = ci

    # Layout
    pos = spring_layout(adj, n)

    # Normalize positions
    all_x = [p[0] for p in pos.values()]
    all_y = [p[1] for p in pos.values()]
    cx, cy = np.mean(all_x), np.mean(all_y)
    scale = max(max(abs(x - cx) for x in all_x), max(abs(y - cy) for y in all_y), 0.1)
    pos = {k: ((v[0] - cx) / scale * 0.35 + 0.5, (v[1] - cy) / scale * 0.35 + 0.5) for k, v in pos.items()}

    # Draw edges
    for i in range(n):
        for j in adj[i]:
            if i < j:
                xi, yi = pos[i]
                xj, yj = pos[j]
                isect_size = len(family[i] & family[j])
                ax.plot([xi, xj], [yi, yj], '-', color='gray',
                        linewidth=1 + isect_size, alpha=0.5)
                mid_x, mid_y = (xi + xj) / 2, (yi + yj) / 2
                ax.text(mid_x, mid_y + 0.03, f"|∩|={isect_size}",
                        ha='center', va='center', fontsize=7, color='gray')

    # Draw nodes
    for i in range(n):
        x, y = pos[i]
        color = colors[class_map[i] % len(colors)]
        ax.scatter(x, y, s=800, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        label = '{' + ','.join(map(str, sorted(family[i]))) + '}'
        ax.text(x, y, label, ha='center', va='center', fontsize=7, fontweight='bold')

    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.1, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    unique_classes = sorted(set(class_map.values()))
    patches = [mpatches.Patch(color=colors[c % len(colors)],
               label=f'Class {c}') for c in unique_classes]
    ax.legend(handles=patches, loc='lower right', fontsize=8)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_overlap_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")
