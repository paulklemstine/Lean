"""
Visualize the Support Nerve as a Heatmap

Shows the pairwise intersection structure of cycle supports as a
symmetric heatmap. Each cell (i,j) shows the size of the intersection
between support i and support j. The diagonal shows support sizes.

This reveals the "interaction matrix" that governs how tropical
kernel generators entangle across overlapping cycle supports.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque
from itertools import combinations


# ──────── Inline implementations (self-contained) ────────

class Graph:
    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                self.adj[u].add(v)
                self.adj[v].add(u)


def find_cycle_supports(G, S):
    vertices = sorted(S)
    adj_in_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_in_S[u].add(v)
    parent, visited, tree_edges, non_tree = {}, set(), set(), []
    for root in vertices:
        if root in visited:
            continue
        visited.add(root)
        parent[root] = -1
        queue = deque([root])
        while queue:
            u = queue.popleft()
            for v in adj_in_S[u]:
                if v not in visited:
                    visited.add(v)
                    parent[v] = u
                    tree_edges.add((min(u,v), max(u,v)))
                    queue.append(v)
                elif (min(u,v), max(u,v)) not in tree_edges:
                    non_tree.append((u, v))
    supports = []
    for u, v in non_tree:
        pu, x = [], u
        while x != -1: pu.append(x); x = parent[x]
        pv, x = [], v
        while x != -1: pv.append(x); x = parent[x]
        su = set(pu)
        lca = next((x for x in pv if x in su), None)
        if lca is None: continue
        cycle = set()
        for x in pu:
            cycle.add(x)
            if x == lca: break
        for x in pv:
            cycle.add(x)
            if x == lca: break
        supports.append(frozenset(cycle))
    return supports


def overlap_classes(supports):
    n = len(supports)
    if n == 0: return []
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j); adj[j].add(i)
    visited, comps = set(), []
    for s in range(n):
        if s in visited: continue
        comp = []
        queue = deque([s]); visited.add(s)
        while queue:
            u = queue.popleft(); comp.append(u)
            for v in adj[u]:
                if v not in visited:
                    visited.add(v); queue.append(v)
        comps.append(sorted(comp))
    return comps


# ──────── Create examples ────────

examples = [
    {
        'name': 'Prism Graph (3-prism)',
        'graph': Graph(6, [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),
                           (0,3),(1,4),(2,5)]),
        'S': {0, 1, 2, 3, 4, 5},
    },
    {
        'name': 'Complete K₅ (minus vertex 0)',
        'graph': Graph(5, list(combinations(range(5), 2))),
        'S': {1, 2, 3, 4},
    },
    {
        'name': 'Petersen-like (wheel W₅)',
        'graph': Graph(6, [(0,1),(0,2),(0,3),(0,4),(0,5),
                           (1,2),(2,3),(3,4),(4,5),(5,1)]),
        'S': {1, 2, 3, 4, 5},
    },
]


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Support Nerve Heatmaps: Pairwise Intersection Structure',
             fontsize=15, fontweight='bold', y=1.02)

for idx, ex in enumerate(examples):
    ax = axes[idx]
    G = ex['graph']
    S = ex['S']
    supports = find_cycle_supports(G, S)
    n = len(supports)

    if n == 0:
        ax.text(0.5, 0.5, 'No cycles found', ha='center', va='center',
                transform=ax.transAxes, fontsize=14)
        ax.set_title(ex['name'])
        continue

    # Build intersection matrix
    matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        matrix[i, i] = len(supports[i])
        for j in range(i + 1, n):
            inter = len(supports[i] & supports[j])
            matrix[i, j] = inter
            matrix[j, i] = inter

    # Get overlap classes for ordering
    classes = overlap_classes(supports)

    # Reorder by class
    order = []
    for cls in classes:
        order.extend(cls)
    reordered = matrix[np.ix_(order, order)]

    # Plot heatmap
    im = ax.imshow(reordered, cmap='YlOrRd', interpolation='nearest',
                   aspect='equal')

    # Annotate cells
    for i in range(n):
        for j in range(n):
            val = reordered[i, j]
            color = 'white' if val > matrix.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=10, fontweight='bold', color=color)

    # Draw class boundaries
    pos = 0
    for cls in classes:
        if pos > 0:
            ax.axhline(y=pos - 0.5, color='blue', linewidth=2)
            ax.axvline(x=pos - 0.5, color='blue', linewidth=2)
        pos += len(cls)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'S{order[i]}' for i in range(n)], fontsize=9)
    ax.set_yticklabels([f'S{order[i]}' for i in range(n)], fontsize=9)

    cls_str = ', '.join([str(c) for c in classes])
    ax.set_title(f'{ex["name"]}\n{n} supports, classes: {cls_str}',
                 fontsize=11, fontweight='bold')

    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label='|Sᵢ ∩ Sⱼ|')

plt.tight_layout()
plt.savefig("overlap_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved: overlap_heatmap.png")
