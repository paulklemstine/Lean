#!/usr/bin/env python3
"""
Visualization: Minor Lattice of a Lorentzian Support

Visualizes the lattice of support minors obtained by iterated deletion
and contraction of the support of e_2(x1, x2, x3, x4). Each node
represents a distinct support, colored by whether it satisfies the
exchange property. Edges represent single-step minor operations.
"""

import itertools
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, FrozenSet, List, Set, Tuple

Monomial = Tuple[int, ...]
Support = FrozenSet[Monomial]

def support_delete(S: Support, i: int) -> Support:
    return frozenset(m for m in S if m[i] == 0)

def support_contract(S: Support, i: int) -> Support:
    if not S:
        return S
    min_val = min(m[i] for m in S)
    filtered = [m for m in S if m[i] == min_val]
    result = set()
    for m in filtered:
        new_m = list(m)
        new_m[i] -= min_val
        result.add(tuple(new_m))
    return frozenset(result)

def satisfies_exchange(S: Support) -> bool:
    if len(S) <= 1:
        return True
    S_set = set(S)
    for x in S:
        for y in S:
            n = len(x)
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x); x_new[a] -= 1; x_new[b] += 1
                            y_new = list(y); y_new[a] += 1; y_new[b] -= 1
                            if tuple(x_new) in S_set and tuple(y_new) in S_set:
                                found = True; break
                    if not found:
                        return False
    return True

def elementary_symmetric_support(n: int, k: int) -> Support:
    monomials = set()
    for combo in itertools.combinations(range(n), k):
        m = [0] * n
        for i in combo:
            m[i] = 1
        monomials.add(tuple(m))
    return frozenset(monomials)

# Generate minor lattice
S0 = elementary_symmetric_support(4, 2)
n_vars = 4

supports = {}  # support -> (depth, exchange)
edges = []     # (parent_id, child_id, label)

# BFS
support_list = [S0]
support_ids = {S0: 0}
supports[0] = (0, satisfies_exchange(S0), len(S0))

queue = [(S0, 0)]
max_depth = 4

for depth in range(1, max_depth + 1):
    next_queue = []
    for current, _ in queue:
        if not current:
            continue
        nn = len(next(iter(current)))
        for i in range(nn):
            for op_name, op in [("D", support_delete), ("C", support_contract)]:
                minor = op(current, i)
                if minor not in support_ids:
                    idx = len(support_list)
                    support_list.append(minor)
                    support_ids[minor] = idx
                    supports[idx] = (depth, satisfies_exchange(minor), len(minor))
                    next_queue.append((minor, depth))
                edges.append((support_ids[current], support_ids[minor],
                            f"{op_name}{i}"))
    queue = next_queue

# Layout: by depth (y) and spread (x)
depth_groups = {}
for idx, (d, exch, size) in supports.items():
    depth_groups.setdefault(d, []).append(idx)

positions = {}
for d, group in depth_groups.items():
    n_in_group = len(group)
    for j, idx in enumerate(sorted(group, key=lambda x: supports[x][2], reverse=True)):
        x = (j - (n_in_group - 1) / 2) * 2.0
        y = -d * 2.5
        positions[idx] = (x, y)

# Plot
fig, ax = plt.subplots(1, 1, figsize=(14, 10))

# Draw edges
for parent, child, label in edges:
    if parent in positions and child in positions:
        x1, y1 = positions[parent]
        x2, y2 = positions[child]
        color = '#2196F3' if 'D' in label else '#FF9800'
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color=color, alpha=0.3, lw=0.8))

# Draw nodes
for idx, (d, exch, size) in supports.items():
    if idx not in positions:
        continue
    x, y = positions[idx]
    color = '#4CAF50' if exch else '#F44336'
    node_size = max(200, size * 80)
    ax.scatter(x, y, s=node_size, c=color, zorder=5, edgecolors='black', linewidth=0.5)
    ax.annotate(f"|S|={size}", (x, y), ha='center', va='center', fontsize=7,
               fontweight='bold', zorder=6)

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#4CAF50', edgecolor='black', label='Exchange ✓'),
    mpatches.Patch(facecolor='#F44336', edgecolor='black', label='Exchange ✗'),
    plt.Line2D([0], [0], color='#2196F3', lw=2, label='Deletion'),
    plt.Line2D([0], [0], color='#FF9800', lw=2, label='Contraction'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# Labels
ax.set_title(r'Minor Lattice of $e_2(x_1, x_2, x_3, x_4)$', fontsize=16, fontweight='bold')
ax.set_ylabel('Minor Depth', fontsize=12)

# Depth labels
for d in depth_groups:
    ax.text(-max(6, len(depth_groups[d])) - 1, -d * 2.5, f'Depth {d}',
           ha='right', va='center', fontsize=10, color='gray')

ax.set_xlim(-10, 10)
ax.axis('off')
plt.tight_layout()
plt.savefig('minor_lattice.png', dpi=150, bbox_inches='tight')
print("Saved minor_lattice.png")
