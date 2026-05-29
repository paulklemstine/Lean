#!/usr/bin/env python3
"""
Visualization: Exchange Graph of M-Convex Supports

Shows the exchange graph structure of M-convex families, where nodes are
exponent vectors and edges represent single-step exchanges (α → α - eᵢ + eⱼ).
Highlights the connectivity pattern that underlies support compression.

The graph structure reveals why M-convex exchange controls shadow geometry:
exchange paths connect all elements, ensuring dominated vectors can be
"reached" through systematic coordinate redistribution.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import Set, Tuple, Dict, List
from collections import defaultdict


Exponent = Tuple[int, ...]


def schur_support(partition, n):
    lam = list(partition)
    support = set()
    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)
    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return support


def exchange_graph(s: Set[Exponent]) -> Dict[Exponent, List[Exponent]]:
    n = len(next(iter(s)))
    graph = defaultdict(list)
    for alpha in s:
        for i in range(n):
            if alpha[i] > 0:
                for j in range(n):
                    if i != j:
                        ex = list(alpha)
                        ex[i] -= 1
                        ex[j] += 1
                        t = tuple(ex)
                        if t in s:
                            graph[alpha].append(t)
    return dict(graph)


def _gen_dom(m, remaining, n, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(min(m[idx], remaining) + 1):
        current.append(v)
        _gen_dom(m, remaining - v, n, idx + 1, current, results)
        current.pop()


def degree_shadow(s: Set[Exponent], k: int) -> Set[Exponent]:
    n = len(next(iter(s)))
    shadow = set()
    for m in s:
        results = []
        _gen_dom(m, k, n, 0, [], results)
        shadow.update(results)
    return shadow


# ─── Create visualization ───────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Exchange graph of Schur s_(2,1) on 3 variables
s = schur_support((2, 1), 3)
graph = exchange_graph(s)
nodes = sorted(s)
n_nodes = len(nodes)
node_idx = {v: i for i, v in enumerate(nodes)}

# Position nodes using barycentric coordinates (since 3 variables)
# Map (a, b, c) to 2D using a+b+c=3
positions = {}
for v in nodes:
    # Barycentric to Cartesian
    x = v[1] + 0.5 * v[2]
    y = v[2] * np.sqrt(3) / 2
    positions[v] = (x, y)

ax1 = axes[0]
ax1.set_title("Exchange Graph: Schur s₍₂,₁₎(x₁,x₂,x₃)\nDegree 3, 7 elements",
              fontsize=11, fontweight='bold')

# Draw edges
drawn_edges = set()
for alpha, neighbors in graph.items():
    for beta in neighbors:
        edge = frozenset([alpha, beta])
        if edge not in drawn_edges:
            drawn_edges.add(edge)
            x1, y1 = positions[alpha]
            x2, y2 = positions[beta]
            ax1.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

# Draw nodes
multiaffine_nodes = [v for v in nodes if all(c <= 1 for c in v)]
non_multiaffine_nodes = [v for v in nodes if any(c > 1 for c in v)]

for v in non_multiaffine_nodes:
    x, y = positions[v]
    ax1.scatter(x, y, s=200, c='coral', edgecolors='darkred',
               linewidth=1.5, zorder=5)
    ax1.annotate(str(v), (x, y), ha='center', va='bottom',
                fontsize=8, fontweight='bold', xytext=(0, 12),
                textcoords='offset points')

for v in multiaffine_nodes:
    x, y = positions[v]
    ax1.scatter(x, y, s=200, c='steelblue', edgecolors='darkblue',
               linewidth=1.5, zorder=5)
    ax1.annotate(str(v), (x, y), ha='center', va='bottom',
                fontsize=8, fontweight='bold', xytext=(0, 12),
                textcoords='offset points')

# Legend
blue_patch = mpatches.Patch(color='steelblue', label='Multiaffine (0/1)')
red_patch = mpatches.Patch(color='coral', label='Non-multiaffine')
ax1.legend(handles=[blue_patch, red_patch], loc='upper right', fontsize=9)
ax1.set_aspect('equal')
ax1.axis('off')

# Panel 2: Shadow decomposition showing domination
ax2 = axes[1]
ax2.set_title("Shadow Decomposition: Degree-1 Shadow\n"
              "Each leaf ← its dominating support elements",
              fontsize=11, fontweight='bold')

shadow_1 = degree_shadow(s, 1)
shadow_nodes = sorted(shadow_1)

# Layout: support elements on top, shadow on bottom
y_top = 2.0
y_bot = 0.0
support_x = np.linspace(0, 6, len(nodes))
shadow_x = np.linspace(1, 5, len(shadow_nodes))

support_pos = {v: (support_x[i], y_top) for i, v in enumerate(nodes)}
shadow_pos = {v: (shadow_x[i], y_bot) for i, v in enumerate(shadow_nodes)}

# Draw domination edges
for u in shadow_nodes:
    for m in nodes:
        if all(u[i] <= m[i] for i in range(3)):
            x1, y1 = support_pos[m]
            x2, y2 = shadow_pos[u]
            ax2.plot([x1, x2], [y1, y2], '-', color='gray', alpha=0.4, linewidth=0.8)

# Draw support nodes
for v in nodes:
    x, y = support_pos[v]
    color = 'steelblue' if all(c <= 1 for c in v) else 'coral'
    ax2.scatter(x, y, s=150, c=color, edgecolors='black', linewidth=1, zorder=5)
    ax2.annotate(str(v), (x, y), ha='center', va='bottom',
                fontsize=7, xytext=(0, 8), textcoords='offset points')

# Draw shadow nodes
for v in shadow_nodes:
    x, y = shadow_pos[v]
    ax2.scatter(x, y, s=150, c='gold', edgecolors='darkgoldenrod',
               linewidth=1.5, zorder=5)
    ax2.annotate(str(v), (x, y), ha='center', va='top',
                fontsize=8, fontweight='bold', xytext=(0, -12),
                textcoords='offset points')

# Labels
ax2.text(3, y_top + 0.4, f"Support S (degree 3, |S|={len(nodes)})",
         ha='center', fontsize=10, fontstyle='italic')
ax2.text(3, y_bot - 0.5, f"Shadow₁(S) (degree 1, |shadow|={len(shadow_nodes)}, "
         f"bound C(3,1)={3})",
         ha='center', fontsize=10, fontstyle='italic')

gold_patch = mpatches.Patch(color='gold', label='Shadow elements')
ax2.legend(handles=[blue_patch, red_patch, gold_patch],
          loc='center right', fontsize=8)
ax2.set_xlim(-0.5, 7)
ax2.set_ylim(-1, 3)
ax2.axis('off')

plt.tight_layout()
plt.savefig("exchange_graph_and_shadow.png", dpi=150, bbox_inches='tight')
print("Saved exchange_graph_and_shadow.png")
