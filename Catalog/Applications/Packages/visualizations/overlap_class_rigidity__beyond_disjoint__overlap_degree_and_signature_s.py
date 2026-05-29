"""
Visualization: Overlap Degree and Signature Distribution

Visualizes how overlap degree and class count vary across families of
different connectivity patterns. Shows the transition from the pairwise
disjoint regime (overlap degree 0) to the fully entangled regime.

This script is fully self-contained — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, FrozenSet, Dict, Set
import itertools
import math


# ---- Inline algorithms ----

def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    return len(A & B) > 0

def overlap_degree(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1,n) if supports_overlap(family[i], family[j]))

def overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    n = len(family)
    if n == 0: return []
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i+1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j); adj[j].add(i)
    visited = [False]*n; comps = []
    for s in range(n):
        if visited[s]: continue
        comp = []; q = [s]; visited[s] = True
        while q:
            nd = q.pop(0); comp.append(nd)
            for nb in sorted(adj[nd]):
                if not visited[nb]: visited[nb] = True; q.append(nb)
        comps.append(sorted(comp))
    return comps

def overlap_signature(family: List[FrozenSet[int]]) -> List[int]:
    n = len(family)
    return sorted(len(family[i]&family[j]) for i in range(n) for j in range(i+1,n)
                  if supports_overlap(family[i], family[j]))

def graph_cycle_supports(adj, subset):
    if len(subset) < 3: return []
    sub = set(subset)
    ind_adj = {v: set() for v in subset}
    for v in subset:
        for u in adj.get(v, set()):
            if u in sub: ind_adj[v].add(u)
    parent = {}; visited = set(); non_tree = []
    for start in subset:
        if start in visited: continue
        visited.add(start); parent[start] = None; queue = [start]
        while queue:
            node = queue.pop(0)
            for nb in sorted(ind_adj[node]):
                if nb not in visited:
                    visited.add(nb); parent[nb] = node; queue.append(nb)
                elif parent.get(node) != nb:
                    e = (min(node,nb),max(node,nb))
                    if e not in non_tree: non_tree.append(e)
    cycles = []
    for u, v in non_tree:
        pu, pv = [], []
        nd = u
        while nd is not None: pu.append(nd); nd = parent.get(nd)
        nd = v
        while nd is not None: pv.append(nd); nd = parent.get(nd)
        sv = set(pv); cv = set()
        for x in pu:
            cv.add(x)
            if x in sv:
                for y in pv:
                    cv.add(y)
                    if y == x: break
                break
        if len(cv) >= 3: cycles.append(frozenset(cv))
    return cycles


# ---- Data collection ----

def collect_graph_data(max_n=6):
    """Collect overlap statistics from connected graphs."""
    data = []
    vertices = list(range(max_n))

    for n in range(3, max_n + 1):
        verts = list(range(n))
        possible_edges = list(itertools.combinations(verts, 2))
        count = 0
        for r in range(n-1, min(len(possible_edges)+1, n*(n-1)//2 + 1)):
            for edge_subset in itertools.combinations(possible_edges, r):
                adj = {v: set() for v in verts}
                for u, v in edge_subset:
                    adj[u].add(v); adj[v].add(u)
                visited = {0}; queue = [0]
                while queue:
                    nd = queue.pop(0)
                    for nb in adj[nd]:
                        if nb not in visited: visited.add(nb); queue.append(nb)
                if len(visited) != n: continue
                count += 1

                cycles = graph_cycle_supports(adj, verts)
                if cycles:
                    od = overlap_degree(cycles)
                    nc = len(overlap_classes(cycles))
                    sig = overlap_signature(cycles)
                    data.append({
                        'n': n, 'edges': r, 'num_cycles': len(cycles),
                        'overlap_degree': od, 'class_count': nc,
                        'signature': sig, 'max_overlap': max(sig) if sig else 0
                    })
    return data


# ---- Plotting ----

data = collect_graph_data(6)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Overlap Class Theory: Statistical Landscape', fontsize=16, fontweight='bold')

# Panel 1: Overlap degree vs number of edges
ax1 = axes[0, 0]
for n in range(3, 7):
    subset = [d for d in data if d['n'] == n]
    if subset:
        edges = [d['edges'] for d in subset]
        degrees = [d['overlap_degree'] for d in subset]
        ax1.scatter(edges, degrees, alpha=0.5, s=30, label=f'n={n}')
ax1.set_xlabel('Number of edges in graph', fontsize=11)
ax1.set_ylabel('Overlap degree of cycle supports', fontsize=11)
ax1.set_title('Overlap Degree vs Graph Density', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Class count distribution
ax2 = axes[0, 1]
class_counts = [d['class_count'] for d in data]
if class_counts:
    max_cc = max(class_counts)
    bins = range(1, max_cc + 2)
    for n in range(3, 7):
        subset = [d['class_count'] for d in data if d['n'] == n]
        if subset:
            ax2.hist(subset, bins=bins, alpha=0.5, label=f'n={n}', align='left')
ax2.set_xlabel('Number of overlap classes', fontsize=11)
ax2.set_ylabel('Frequency', fontsize=11)
ax2.set_title('Distribution of Overlap Class Counts', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Overlap degree vs class count
ax3 = axes[1, 0]
if data:
    degrees = [d['overlap_degree'] for d in data]
    classes = [d['class_count'] for d in data]
    num_cycles = [d['num_cycles'] for d in data]
    sc = ax3.scatter(degrees, classes, c=num_cycles, cmap='viridis',
                     alpha=0.6, s=40, edgecolors='gray', linewidth=0.5)
    plt.colorbar(sc, ax=ax3, label='Number of cycles')
ax3.set_xlabel('Overlap degree', fontsize=11)
ax3.set_ylabel('Overlap class count', fontsize=11)
ax3.set_title('Overlap Degree vs Class Count', fontsize=12, fontweight='bold')
ax3.grid(True, alpha=0.3)

# Panel 4: Max intersection size distribution
ax4 = axes[1, 1]
max_overlaps = [d['max_overlap'] for d in data if d['max_overlap'] > 0]
if max_overlaps:
    bins = range(1, max(max_overlaps) + 2)
    ax4.hist(max_overlaps, bins=bins, color='#e74c3c', alpha=0.7,
             align='left', edgecolor='black')
ax4.set_xlabel('Maximum pairwise intersection size', fontsize=11)
ax4.set_ylabel('Frequency', fontsize=11)
ax4.set_title('Distribution of Max Overlap Intensity', fontsize=12, fontweight='bold')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('overlap_signature_analysis.png', dpi=150, bbox_inches='tight', facecolor='white')
print("Saved overlap_signature_analysis.png")
