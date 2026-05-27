"""
Visualize the Support Interaction Graph (Overlap Graph)

This script illustrates the core concept of the overlap class theory:
given a graph G and a subset S of its vertices, the cycle supports in
G[S] form a support family. The overlap graph connects supports that
share at least one vertex. Connected components of this overlap graph
are the "overlap classes" — independent interaction sectors.

The visualization shows:
1. The original graph G with highlighted subset S
2. The cycle supports found in G[S]
3. The support interaction graph (overlap graph)
4. Overlap classes color-coded
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
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

    def edges(self):
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result

    def degree(self, v):
        return len(self.adj[v])


def find_cycle_supports(G, S):
    vertices = sorted(S)
    adj_in_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_in_S[u].add(v)

    parent = {}
    visited = set()
    tree_edges = set()
    non_tree_edges = []

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
                    tree_edges.add((min(u, v), max(u, v)))
                    queue.append(v)
                elif (min(u, v), max(u, v)) not in tree_edges:
                    non_tree_edges.append((u, v))

    supports = []
    for u, v in non_tree_edges:
        path_u, x = [], u
        while x != -1:
            path_u.append(x)
            x = parent[x]
        path_v, x = [], v
        while x != -1:
            path_v.append(x)
            x = parent[x]
        set_u = set(path_u)
        lca = next((x for x in path_v if x in set_u), None)
        if lca is None:
            continue
        cycle = set()
        for x in path_u:
            cycle.add(x)
            if x == lca:
                break
        for x in path_v:
            cycle.add(x)
            if x == lca:
                break
        supports.append(frozenset(cycle))
    return supports


def overlap_classes(supports):
    n = len(supports)
    if n == 0:
        return []
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    components = []
    for start in range(n):
        if start in visited:
            continue
        comp = []
        queue = deque([start])
        visited.add(start)
        while queue:
            u = queue.popleft()
            comp.append(u)
            for v in adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        components.append(sorted(comp))
    return components


def overlap_degree(supports):
    mx = 0
    for i, j in combinations(range(len(supports)), 2):
        mx = max(mx, len(supports[i] & supports[j]))
    return mx


# ──────── Layout helpers ────────

def circular_layout(n, center=(0, 0), radius=1.0):
    positions = {}
    for i in range(n):
        angle = 2 * np.pi * i / n - np.pi / 2
        positions[i] = (center[0] + radius * np.cos(angle),
                        center[1] + radius * np.sin(angle))
    return positions


def draw_graph(ax, G, pos, S=None, title="", supports=None, classes=None):
    """Draw graph with optional highlighting."""
    # Colors for overlap classes
    class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12',
                    '#9b59b6', '#1abc9c', '#e67e22', '#34495e']

    # Draw edges
    for u, v in G.edges():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        ax.plot(x, y, 'k-', linewidth=1, alpha=0.4, zorder=1)

    # Draw vertices
    for v in range(G.n):
        color = '#cccccc'
        size = 300
        if S and v in S:
            color = '#3498db'
            size = 400
        ax.scatter(pos[v][0], pos[v][1], s=size, c=color,
                   edgecolors='black', linewidth=1.5, zorder=3)
        ax.annotate(str(v), pos[v], ha='center', va='center',
                    fontsize=10, fontweight='bold', zorder=4)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


def draw_overlap_graph(ax, supports, classes, title="Overlap Graph"):
    """Draw the support interaction graph with overlap classes colored."""
    n = len(supports)
    if n == 0:
        ax.text(0.5, 0.5, "No supports", ha='center', va='center',
                transform=ax.transAxes, fontsize=14)
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.axis('off')
        return

    class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12',
                    '#9b59b6', '#1abc9c', '#e67e22', '#34495e']

    # Assign colors
    node_color = {}
    for ci, cls in enumerate(classes):
        for idx in cls:
            node_color[idx] = class_colors[ci % len(class_colors)]

    pos = circular_layout(n, radius=1.0)

    # Draw edges (overlapping pairs)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            x = [pos[i][0], pos[j][0]]
            y = [pos[i][1], pos[j][1]]
            inter_size = len(supports[i] & supports[j])
            ax.plot(x, y, '-', color='#e74c3c', linewidth=1 + inter_size,
                    alpha=0.5, zorder=1)
            mx, my = (x[0] + x[1]) / 2, (y[0] + y[1]) / 2
            ax.annotate(str(inter_size), (mx, my), ha='center', va='center',
                        fontsize=8, color='red', fontweight='bold',
                        bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                                  edgecolor='red', alpha=0.8), zorder=5)

    # Draw nodes
    for i in range(n):
        ax.scatter(pos[i][0], pos[i][1], s=500,
                   c=node_color.get(i, '#cccccc'),
                   edgecolors='black', linewidth=2, zorder=3)
        ax.annotate(f"S{i}", pos[i], ha='center', va='center',
                    fontsize=9, fontweight='bold', color='white', zorder=4)

    # Legend
    handles = []
    for ci, cls in enumerate(classes):
        color = class_colors[ci % len(class_colors)]
        handles.append(mpatches.Patch(color=color,
                                       label=f'Class {ci}: {cls}'))
    if handles:
        ax.legend(handles=handles, loc='upper right', fontsize=8)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


# ──────── Main visualization ────────

# Example 1: Two triangles sharing a vertex (overlap degree 1)
G1 = Graph(5, [(0, 1), (1, 2), (0, 2), (2, 3), (3, 4), (2, 4)])
S1 = {0, 1, 2, 3, 4}
supports1 = find_cycle_supports(G1, S1)
classes1 = overlap_classes(supports1)

# Example 2: Complete graph K4 (high overlap)
G2 = Graph(4, list(combinations(range(4), 2)))
S2 = {0, 1, 2, 3}
supports2 = find_cycle_supports(G2, S2)
classes2 = overlap_classes(supports2)

# Example 3: Two disjoint triangles
G3 = Graph(6, [(0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)])
S3 = {0, 1, 2, 3, 4, 5}
supports3 = find_cycle_supports(G3, S3)
classes3 = overlap_classes(supports3)

fig, axes = plt.subplots(3, 2, figsize=(14, 18))
fig.suptitle("Support Interaction Graphs and Overlap Classes",
             fontsize=16, fontweight='bold', y=0.98)

# Row 1: Two triangles sharing vertex
pos1 = {0: (-1, 0.5), 1: (0, 1.5), 2: (1, 0.5), 3: (2, 1.5), 4: (3, 0.5)}
draw_graph(axes[0, 0], G1, pos1, S1,
           title=f"Two triangles sharing vertex 2\n"
                 f"Supports: {[sorted(s) for s in supports1]}")
draw_overlap_graph(axes[0, 1], supports1, classes1,
                   title=f"Overlap Graph (degree={overlap_degree(supports1)})")

# Row 2: Complete K4
pos2 = circular_layout(4, radius=1.0)
draw_graph(axes[1, 0], G2, pos2, S2,
           title=f"Complete graph K₄\n"
                 f"Supports: {[sorted(s) for s in supports2]}")
draw_overlap_graph(axes[1, 1], supports2, classes2,
                   title=f"Overlap Graph (degree={overlap_degree(supports2)})")

# Row 3: Two disjoint triangles
pos3 = {0: (-1.5, 0), 1: (-0.5, 1), 2: (-0.5, -1),
        3: (1.5, 0), 4: (0.5, 1), 5: (0.5, -1)}
draw_graph(axes[2, 0], G3, pos3, S3,
           title=f"Two disjoint triangles\n"
                 f"Supports: {[sorted(s) for s in supports3]}")
draw_overlap_graph(axes[2, 1], supports3, classes3,
                   title=f"Overlap Graph (degree={overlap_degree(supports3)})")

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig("overlap_graph_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: overlap_graph_visualization.png")
