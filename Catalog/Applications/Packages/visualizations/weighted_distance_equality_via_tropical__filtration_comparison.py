"""
Visualization: Kruskal vs Girth-Adapted Filtration Comparison

This script visualizes how different edge orderings affect cycle detection
in weighted graphs. It shows:
- The weighted graph with edge weights
- The Kruskal ordering and the cycle it produces
- The girth-adapted ordering and the cycle it produces
- A bar chart comparing the two filtration birth values vs minimum

WHY THIS MATTERS: In quantum error-correcting codes, the minimum cycle
weight determines the code distance. Kruskal ordering can miss this
minimum, but girth-adapted filtration always finds it.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict

# ===== Inline all needed functions =====

class WeightedGraph:
    def __init__(self):
        self.vertices = set()
        self.edges = {}
        self.adj = defaultdict(set)

    def add_edge(self, u, v, weight):
        a, b = min(u, v), max(u, v)
        self.vertices.add(a)
        self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b)
        self.adj[b].add(a)

def enumerate_simple_cycles(G):
    vertices = sorted(G.vertices)
    cycles = []
    seen_cycles = set()
    def dfs(start, current, path, visited):
        for neighbor in sorted(G.adj[current]):
            if neighbor == start and len(path) >= 3:
                cycle_edges = []
                for i in range(len(path)):
                    u, v = path[i], path[(i + 1) % len(path)]
                    a, b = min(u, v), max(u, v)
                    cycle_edges.append((a, b))
                key = tuple(sorted(cycle_edges))
                if key not in seen_cycles:
                    seen_cycles.add(key)
                    cycles.append(cycle_edges)
            elif neighbor > start and neighbor not in visited:
                visited.add(neighbor)
                path.append(neighbor)
                dfs(start, neighbor, path, visited)
                path.pop()
                visited.remove(neighbor)
    for v in vertices:
        dfs(v, v, [v], {v})
    return cycles

def cycle_weight(G, cycle):
    return sum(G.edges[e] for e in cycle)

class UnionFind:
    def __init__(self, vertices):
        self.parent = {v: v for v in vertices}
        self.rank = {v: 0 for v in vertices}
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return True
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return False
    def connected(self, x, y):
        return self.find(x) == self.find(y)

def find_cycle_in_forest(G, forest_edges, new_edge):
    u, v = new_edge
    adj = defaultdict(list)
    for a, b in forest_edges:
        adj[a].append(b)
        adj[b].append(a)
    queue = [(u, [u])]
    visited = {u}
    while queue:
        current, path = queue.pop(0)
        for neighbor in adj[current]:
            if neighbor == v:
                full_path = path + [v]
                cycle_edges = []
                for i in range(len(full_path) - 1):
                    a, b = min(full_path[i], full_path[i+1]), max(full_path[i], full_path[i+1])
                    cycle_edges.append((a, b))
                cycle_edges.append(new_edge)
                return cycle_edges
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, path + [neighbor]))
    return [new_edge]

def first_cycle_birth_value(G, order):
    uf = UnionFind(G.vertices)
    forest_edges = []
    for edge in order:
        u, v = edge
        if uf.connected(u, v):
            cycle_edges = find_cycle_in_forest(G, forest_edges, edge)
            total_weight = sum(G.edges[e] for e in cycle_edges)
            return (total_weight, cycle_edges)
        else:
            uf.union(u, v)
            forest_edges.append(edge)
    return None

# ===== Build the example graph =====

G = WeightedGraph()
for i in range(7):
    G.add_edge(i, (i + 1) % 7, 1.0)
G.add_edge(0, 2, 3.0)

# Compute results
cycles = enumerate_simple_cycles(G)
min_w = min(cycle_weight(G, c) for c in cycles)

kruskal = sorted(G.edges.keys(), key=lambda e: (G.edges[e], e))
kruskal_result = first_cycle_birth_value(G, kruskal)

min_cycle = min(cycles, key=lambda c: cycle_weight(G, c))
min_cycle_set = set(min_cycle)
min_cycle_sorted = sorted(min_cycle, key=lambda e: (G.edges[e], e))
remaining = [e for e in sorted(G.edges.keys()) if e not in min_cycle_set]
girth_order = min_cycle_sorted + remaining
girth_result = first_cycle_birth_value(G, girth_order)

# ===== Create visualization =====

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Layout: vertices on a heptagon
angles = np.linspace(0, 2 * np.pi, 7, endpoint=False) - np.pi/2
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

def draw_graph(ax, G, pos, highlight_edges=None, highlight_color='red', title=''):
    ax.set_aspect('equal')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.axis('off')

    highlight_set = set(highlight_edges) if highlight_edges else set()

    for (u, v), w in G.edges.items():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        color = highlight_color if (u, v) in highlight_set else '#cccccc'
        lw = 3 if (u, v) in highlight_set else 1.5
        ax.plot(x, y, color=color, linewidth=lw, zorder=1)
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.text(mx, my + 0.08, f'{w:.0f}', ha='center', va='center',
                fontsize=9, color='#333', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    for v, (x, y) in pos.items():
        ax.plot(x, y, 'o', color='#2196F3', markersize=20, zorder=2)
        ax.text(x, y, str(v), ha='center', va='center',
                fontsize=11, color='white', fontweight='bold', zorder=3)

# Panel 1: Full graph
draw_graph(axes[0], G, pos, title='Weighted Graph\n(7-cycle + chord)')

# Panel 2: Kruskal cycle
kruskal_cycle_edges = kruskal_result[1] if kruskal_result else []
draw_graph(axes[1], G, pos, kruskal_cycle_edges, '#e74c3c',
           f'Kruskal First Cycle\nWeight = {kruskal_result[0]:.0f}')

# Panel 3: Girth-adapted cycle
girth_cycle_edges = girth_result[1] if girth_result else []
draw_graph(axes[2], G, pos, girth_cycle_edges, '#27ae60',
           f'Girth-Adapted First Cycle\nWeight = {girth_result[0]:.0f} = min')

fig.suptitle('Kruskal vs Girth-Adapted Filtration: Finding the Weighted Systole',
             fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout()
plt.savefig('viz_filtration_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_filtration_comparison.png")
