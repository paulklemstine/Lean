"""
Visualization: Kruskal Failure Rate vs Graph Density

This script shows how frequently Kruskal's ordering fails to find the
minimum cycle weight as a function of graph density and size. It
demonstrates that denser graphs have higher failure rates.

The key insight: Kruskal optimizes local edge weight, not global cycle
weight. As graphs get denser, the mismatch between these objectives grows.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from collections import defaultdict

# ===== Inline all needed functions =====

class WeightedGraph:
    def __init__(self):
        self.vertices = set()
        self.edges = {}
        self.adj = defaultdict(set)
    def add_edge(self, u, v, weight):
        a, b = min(u, v), max(u, v)
        self.vertices.add(a); self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b); self.adj[b].add(a)

def enumerate_simple_cycles(G):
    vertices = sorted(G.vertices)
    cycles, seen = [], set()
    def dfs(start, current, path, visited):
        for nb in sorted(G.adj[current]):
            if nb == start and len(path) >= 3:
                ce = []
                for i in range(len(path)):
                    u, v = path[i], path[(i+1) % len(path)]
                    ce.append((min(u,v), max(u,v)))
                key = tuple(sorted(ce))
                if key not in seen: seen.add(key); cycles.append(ce)
            elif nb > start and nb not in visited:
                visited.add(nb); path.append(nb)
                dfs(start, nb, path, visited)
                path.pop(); visited.remove(nb)
    for v in vertices: dfs(v, v, [v], {v})
    return cycles

def cycle_weight(G, c): return sum(G.edges[e] for e in c)

class UnionFind:
    def __init__(self, verts):
        self.parent = {v: v for v in verts}
        self.rank = {v: 0 for v in verts}
    def find(self, x):
        if self.parent[x] != x: self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return True
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return False
    def connected(self, x, y): return self.find(x) == self.find(y)

def find_cycle_in_forest(G, forest, new_edge):
    u, v = new_edge
    adj = defaultdict(list)
    for a, b in forest: adj[a].append(b); adj[b].append(a)
    queue = [(u, [u])]; visited = {u}
    while queue:
        cur, path = queue.pop(0)
        for nb in adj[cur]:
            if nb == v:
                fp = path + [v]; ce = []
                for i in range(len(fp)-1):
                    ce.append((min(fp[i],fp[i+1]), max(fp[i],fp[i+1])))
                ce.append(new_edge); return ce
            if nb not in visited:
                visited.add(nb); queue.append((nb, path+[nb]))
    return [new_edge]

def kruskal_first_birth(G):
    uf = UnionFind(G.vertices); forest = []
    for e in sorted(G.edges.keys(), key=lambda e: (G.edges[e], e)):
        u, v = e
        if uf.connected(u, v):
            ce = find_cycle_in_forest(G, forest, e)
            return sum(G.edges[x] for x in ce)
        else: uf.union(u, v); forest.append(e)
    return None

# ===== Run experiments =====

random.seed(2025)
densities = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7]
vertex_counts = [5, 6, 7, 8]
trials_per = 40

results = {}  # (n, p) -> failure_rate

for n in vertex_counts:
    for p in densities:
        total = 0
        failures = 0
        for trial in range(trials_per):
            G = WeightedGraph()
            for v in range(n): G.vertices.add(v)
            random.seed(n*10000 + int(p*1000) + trial)
            for i in range(n):
                for j in range(i+1, n):
                    if random.random() < p:
                        G.add_edge(i, j, random.randint(1, 10))
            if len(G.edges) < 3: continue
            cycles = enumerate_simple_cycles(G)
            if not cycles: continue
            total += 1
            min_w = min(cycle_weight(G, c) for c in cycles)
            kb = kruskal_first_birth(G)
            if kb and abs(kb - min_w) > 1e-10:
                failures += 1
        results[(n, p)] = failures / max(1, total) * 100

# ===== Plot =====

fig, ax = plt.subplots(figsize=(10, 7))

for n in vertex_counts:
    rates = [results.get((n, p), 0) for p in densities]
    ax.plot(densities, rates, 'o-', linewidth=2, markersize=8, label=f'n = {n}')

ax.set_xlabel('Edge Probability (Graph Density)', fontsize=13)
ax.set_ylabel('Kruskal Failure Rate (%)', fontsize=13)
ax.set_title('When Does Kruskal Fail to Find the Weighted Systole?\n'
             'Failure rate vs graph density for random weighted graphs',
             fontsize=14, fontweight='bold')
ax.legend(title='Vertices', fontsize=11, title_fontsize=12)
ax.set_ylim(-2, 55)
ax.grid(True, alpha=0.3)

ax.annotate('Denser graphs → more\nalternative paths →\nhigher failure rate',
           xy=(0.6, results.get((8, 0.6), 30)),
           xytext=(0.45, 45), fontsize=11,
           arrowprops=dict(arrowstyle='->', color='#e74c3c'),
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_kruskal_failure_rate.png', dpi=150, bbox_inches='tight')
print("Saved: viz_kruskal_failure_rate.png")
