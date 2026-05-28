"""
Visualization: Overlap Degree Statistics Across Small Graphs

This script generates statistics about overlap patterns across all
connected graphs on n vertices, showing how overlap degree distributes
and how the number of overlap classes varies with graph structure.

What it visualizes:
- Distribution of overlap degrees across small graphs
- Relationship between graph density and overlap degree
- Number of overlap classes vs number of cycle supports
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


def find_cycle_supports_local(n_vertices, edges, S):
    """Find cycle supports in the induced subgraph."""
    vertices = sorted(S)
    adj = {v: set() for v in vertices}
    for u, v in edges:
        if u in S and v in S:
            adj[u].add(v)
            adj[v].add(u)

    visited = set()
    parent = {}
    cycles = []

    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in adj[v]:
            if w == p:
                continue
            if w in visited:
                cycle = {w}
                u = v
                while u != w:
                    cycle.add(u)
                    u = parent[u]
                cycles.append(frozenset(cycle))
            elif w not in visited:
                dfs(w, v)

    for v in vertices:
        if v not in visited:
            dfs(v, None)
    return cycles


def overlap_degree_local(supports):
    """Count overlapping pairs."""
    return sum(1 for i, j in combinations(range(len(supports)), 2)
               if supports[i] & supports[j])


def overlap_classes_local(supports):
    """Count overlap classes."""
    n = len(supports)
    if n == 0:
        return 0
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
    return len(set(find(i) for i in range(n)))


def is_connected(n, edges):
    """Check if graph is connected."""
    if n <= 1:
        return True
    adj = {i: set() for i in range(n)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    stack = [0]
    while stack:
        v = stack.pop()
        if v in visited:
            continue
        visited.add(v)
        stack.extend(w for w in adj[v] if w not in visited)
    return len(visited) == n


# Collect statistics
print("Computing overlap statistics for small graphs...")

overlap_degrees = []
class_counts = []
support_counts = []
graph_densities = []

for n in range(3, 7):
    all_edges = list(combinations(range(n), 2))
    max_edges = len(all_edges)

    for mask in range(1, min(1 << max_edges, 2**13)):
        edges = [all_edges[i] for i in range(max_edges) if mask & (1 << i)]
        if not is_connected(n, edges):
            continue

        density = len(edges) / max_edges

        for q in range(n):
            S = set(range(n)) - {q}
            cs = find_cycle_supports_local(n, edges, S)
            if not cs:
                continue

            od = overlap_degree_local(cs)
            nc = overlap_classes_local(cs)

            overlap_degrees.append(od)
            class_counts.append(nc)
            support_counts.append(len(cs))
            graph_densities.append(density)

print(f"Collected {len(overlap_degrees)} data points")

# Create the visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Overlap Structure Statistics Across Small Graphs (n ≤ 6)",
             fontsize=14, fontweight='bold')

# Plot 1: Distribution of overlap degrees
ax = axes[0, 0]
max_od = max(overlap_degrees) if overlap_degrees else 0
bins = range(0, max_od + 2)
ax.hist(overlap_degrees, bins=bins, color='steelblue', edgecolor='black', alpha=0.8, align='left')
ax.set_xlabel('Overlap Degree', fontsize=11)
ax.set_ylabel('Frequency', fontsize=11)
ax.set_title('Distribution of Overlap Degrees', fontsize=12, fontweight='bold')
ax.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Disjoint regime')
ax.legend(fontsize=9)

# Plot 2: Overlap degree vs graph density
ax = axes[0, 1]
ax.scatter(graph_densities, overlap_degrees, alpha=0.15, s=10, c='steelblue')
ax.set_xlabel('Graph Density (|E|/max|E|)', fontsize=11)
ax.set_ylabel('Overlap Degree', fontsize=11)
ax.set_title('Overlap Degree vs Graph Density', fontsize=12, fontweight='bold')

# Add trend line
if graph_densities:
    z = np.polyfit(graph_densities, overlap_degrees, 2)
    p = np.poly1d(z)
    xs = np.linspace(min(graph_densities), max(graph_densities), 100)
    ax.plot(xs, p(xs), 'r-', linewidth=2, alpha=0.7, label='Quadratic fit')
    ax.legend(fontsize=9)

# Plot 3: Number of overlap classes vs number of supports
ax = axes[1, 0]
ax.scatter(support_counts, class_counts, alpha=0.2, s=15, c='green')
# Add y = x line
max_sc = max(support_counts) if support_counts else 1
ax.plot([0, max_sc], [0, max_sc], 'r--', alpha=0.5, label='Classes = Supports (all disjoint)')
ax.set_xlabel('Number of Cycle Supports', fontsize=11)
ax.set_ylabel('Number of Overlap Classes', fontsize=11)
ax.set_title('Overlap Classes vs Cycle Supports', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Plot 4: Fraction of overlapping cases by n
ax = axes[1, 1]
fracs = {}
for n in range(3, 7):
    all_edges = list(combinations(range(n), 2))
    max_edges = len(all_edges)
    total = 0
    overlapping = 0
    for mask in range(1, min(1 << max_edges, 2**13)):
        edges = [all_edges[i] for i in range(max_edges) if mask & (1 << i)]
        if not is_connected(n, edges):
            continue
        for q in range(n):
            S = set(range(n)) - {q}
            cs = find_cycle_supports_local(n, edges, S)
            if cs:
                total += 1
                if overlap_degree_local(cs) > 0:
                    overlapping += 1
    if total > 0:
        fracs[n] = overlapping / total

ns = sorted(fracs.keys())
vals = [fracs[n] for n in ns]
ax.bar(ns, vals, color='coral', edgecolor='black', alpha=0.8)
ax.set_xlabel('Number of Vertices (n)', fontsize=11)
ax.set_ylabel('Fraction with Overlap', fontsize=11)
ax.set_title('Fraction of Overlapping Instances by n', fontsize=12, fontweight='bold')
for i, (n, v) in enumerate(zip(ns, vals)):
    ax.text(n, v + 0.01, f'{v:.2%}', ha='center', fontsize=10)

plt.tight_layout()
plt.savefig('overlap_statistics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overlap_statistics.png")
