"""
Visualize Overlap Degree Distribution Across Graph Families

This script shows how overlap degree varies across all connected graphs
of different sizes, illustrating the transition from the disjoint regime
(degree 0) to increasingly entangled cycle supports.

The visualization produces a heatmap/histogram showing:
- x-axis: overlap degree (0, 1, 2, ...)
- y-axis: number of vertices n
- color/height: number of (G, q) pairs achieving that overlap degree
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

    def edges(self):
        return [(u, v) for u in range(self.n) for v in self.adj[u] if u < v]

    def is_connected(self):
        if self.n == 0:
            return True
        visited = {0}
        queue = deque([0])
        while queue:
            u = queue.popleft()
            for v in self.adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        return len(visited) == self.n


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


def overlap_degree(supports):
    mx = 0
    for i, j in combinations(range(len(supports)), 2):
        mx = max(mx, len(supports[i] & supports[j]))
    return mx


def overlap_class_count(supports):
    n = len(supports)
    if n == 0: return 0
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j); adj[j].add(i)
    visited, count = set(), 0
    for s in range(n):
        if s in visited: continue
        count += 1
        queue = deque([s]); visited.add(s)
        while queue:
            u = queue.popleft()
            for v in adj[u]:
                if v not in visited:
                    visited.add(v); queue.append(v)
    return count


def generate_connected_graphs(n):
    if n <= 1: return [Graph(n)] if n == 1 else []
    all_edges = list(combinations(range(n), 2))
    m = len(all_edges)
    graphs = []
    for mask in range(1, 1 << m):
        edges = [all_edges[i] for i in range(m) if mask & (1 << i)]
        g = Graph(n, edges)
        if g.is_connected():
            graphs.append(g)
    return graphs


# ──────── Data collection ────────

max_n = 6
degree_data = defaultdict(lambda: defaultdict(int))
class_data = defaultdict(lambda: defaultdict(int))

for n in range(3, max_n + 1):
    print(f"Processing n = {n}...")
    graphs = generate_connected_graphs(n)
    for G in graphs:
        for q in range(n):
            S = set(range(n)) - {q}
            supports = find_cycle_supports(G, S)
            if supports:
                od = overlap_degree(supports)
                oc = overlap_class_count(supports)
                degree_data[n][od] += 1
                class_data[n][oc] += 1

# ──────── Visualization ────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Plot 1: Overlap degree distribution
colors = ['#2ecc71', '#3498db', '#e74c3c', '#f39c12', '#9b59b6',
          '#1abc9c', '#e67e22', '#34495e', '#c0392b']

max_deg = max(max(d.keys()) for d in degree_data.values() if d)
x_labels = list(range(max_deg + 1))

bar_width = 0.15
for idx, n in enumerate(sorted(degree_data.keys())):
    offsets = [x + idx * bar_width for x in x_labels]
    heights = [degree_data[n].get(d, 0) for d in x_labels]
    ax1.bar(offsets, heights, bar_width, label=f'n={n}',
            color=colors[idx % len(colors)], alpha=0.8,
            edgecolor='white', linewidth=0.5)

ax1.set_xlabel('Overlap Degree', fontsize=13)
ax1.set_ylabel('Number of (G, q) pairs', fontsize=13)
ax1.set_title('Distribution of Overlap Degree\n'
              'by Graph Size', fontsize=14, fontweight='bold')
ax1.set_xticks([x + bar_width * len(degree_data) / 2 for x in x_labels])
ax1.set_xticklabels(x_labels)
ax1.legend(fontsize=11)
ax1.grid(axis='y', alpha=0.3)

# Annotate key finding
total_zero = sum(degree_data[n].get(0, 0) for n in degree_data)
total_all = sum(sum(d.values()) for d in degree_data.values())
pct_disjoint = 100 * total_zero / max(total_all, 1)
ax1.annotate(f'{pct_disjoint:.1f}% have\noverlap degree 0\n(disjoint regime)',
             xy=(0, max(degree_data[max_n].get(0, 0),
                        degree_data[max_n - 1].get(0, 0))),
             xytext=(2, max(max(d.values()) for d in degree_data.values()) * 0.7),
             fontsize=10, ha='center',
             arrowprops=dict(arrowstyle='->', color='#e74c3c'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#fff3cd',
                       edgecolor='#e74c3c'))

# Plot 2: Overlap class count distribution
max_cls = max(max(d.keys()) for d in class_data.values() if d)
x_labels2 = list(range(1, max_cls + 1))

for idx, n in enumerate(sorted(class_data.keys())):
    offsets = [x + idx * bar_width for x in x_labels2]
    heights = [class_data[n].get(c, 0) for c in x_labels2]
    ax2.bar(offsets, heights, bar_width, label=f'n={n}',
            color=colors[idx % len(colors)], alpha=0.8,
            edgecolor='white', linewidth=0.5)

ax2.set_xlabel('Number of Overlap Classes', fontsize=13)
ax2.set_ylabel('Number of (G, q) pairs', fontsize=13)
ax2.set_title('Distribution of Overlap Class Count\n'
              'by Graph Size', fontsize=14, fontweight='bold')
ax2.set_xticks([x + bar_width * len(class_data) / 2 for x in x_labels2])
ax2.set_xticklabels(x_labels2)
ax2.legend(fontsize=11)
ax2.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig("overlap_degree_distribution.png", dpi=150, bbox_inches='tight')
print("Saved: overlap_degree_distribution.png")
