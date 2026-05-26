#!/usr/bin/env python3
"""
Visualization: Minor Lattice of an M-Convex Support

Shows the lattice of all minors (up to depth 3) of the uniform matroid U(2,3),
illustrating how deletion and contraction generate a rich family of sub-supports,
all of which preserve the exchange property.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def indicator_vector(n, subset):
    v = [0] * n
    for i in subset:
        v[i] = 1
    return tuple(v)


def support_delete(S, i):
    return [m for m in S if m[i] == 0]


def support_contract(S, i):
    if not S:
        return []
    min_val = min(m[i] for m in S)
    return [tuple(m[j] - (min_val if j == i else 0) for j in range(len(m)))
            for m in S if m[i] == min_val]


def check_exchange(S, n):
    S_set = set(S)
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x)
                            x_new[a] -= 1
                            x_new[b] += 1
                            y_new = list(y)
                            y_new[a] += 1
                            y_new[b] -= 1
                            if tuple(x_new) in S_set and tuple(y_new) in S_set:
                                found = True
                                break
                    if not found:
                        return False
    return True


# Build minor lattice for U(2,3)
n = 3
bases = list(combinations(range(n), 2))
S0 = [indicator_vector(n, B) for B in bases]

# BFS to find all minors
nodes = {}  # frozenset -> (label, depth, support)
edges = []  # (from_key, to_key, operation)

queue = [(frozenset(map(tuple, S0)), "U(2,3)", 0, S0)]
nodes[frozenset(map(tuple, S0))] = ("U(2,3)", 0, S0)

max_depth = 3

while queue:
    next_queue = []
    for key, label, depth, S in queue:
        if depth >= max_depth:
            continue
        for i in range(n):
            # Deletion
            S_del = support_delete(S, i)
            del_key = frozenset(S_del)
            if del_key not in nodes:
                del_label = f"D{i}({label})" if depth == 0 else f"|S|={len(S_del)}"
                nodes[del_key] = (del_label, depth + 1, S_del)
                next_queue.append((del_key, del_label, depth + 1, S_del))
            edges.append((key, del_key, f"D{i}"))
            
            # Contraction
            S_con = support_contract(S, i)
            con_key = frozenset(S_con)
            if con_key not in nodes:
                con_label = f"C{i}({label})" if depth == 0 else f"|S|={len(S_con)}"
                nodes[con_key] = (con_label, depth + 1, S_con)
                next_queue.append((con_key, con_label, depth + 1, S_con))
            edges.append((key, con_key, f"C{i}"))
    
    queue = next_queue

# Deduplicate edges
edges = list(set(edges))

# Layout: arrange by depth
depth_groups = {}
for key, (label, depth, S) in nodes.items():
    if depth not in depth_groups:
        depth_groups[depth] = []
    depth_groups[depth].append(key)

positions = {}
for depth, keys in depth_groups.items():
    n_keys = len(keys)
    for idx, key in enumerate(keys):
        x = (idx - (n_keys - 1) / 2) * 2.5
        y = -depth * 2.0
        positions[key] = (x, y)

# Draw
fig, ax = plt.subplots(1, 1, figsize=(16, 10))
fig.suptitle('Minor Lattice of U(2,3) Support', fontsize=16, fontweight='bold')

# Draw edges
drawn_edges = set()
for from_key, to_key, op in edges:
    if from_key == to_key:
        continue
    edge_id = (from_key, to_key)
    if edge_id in drawn_edges:
        continue
    drawn_edges.add(edge_id)
    
    x1, y1 = positions[from_key]
    x2, y2 = positions[to_key]
    
    color = '#cc4444' if op.startswith('D') else '#44aa44'
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, alpha=0.4, lw=1.2))

# Draw nodes
for key, (label, depth, S) in nodes.items():
    x, y = positions[key]
    has_exchange = check_exchange(S, n) if S else True
    
    color = '#4488cc' if has_exchange else '#cc4444'
    size = max(300, 600 - depth * 100)
    
    ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidth=1.5)
    
    # Label
    display = f"|S|={len(S)}"
    if depth == 0:
        display = label
    ax.text(x, y - 0.15, display, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Show exchange status
    status = "✓" if has_exchange else "✗"
    ax.text(x, y + 0.15, status, ha='center', va='center', fontsize=10,
            color='white', fontweight='bold')
    
    # Show support elements on hover (as annotation)
    if len(S) <= 4:
        support_str = '\n'.join(str(s) for s in sorted(S))
        ax.text(x + 0.8, y, support_str, fontsize=5, alpha=0.6,
                verticalalignment='center', fontfamily='monospace',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.5))

# Legend
del_patch = mpatches.Patch(color='#cc4444', alpha=0.5, label='Deletion')
con_patch = mpatches.Patch(color='#44aa44', alpha=0.5, label='Contraction')
exch_patch = mpatches.Patch(color='#4488cc', label='Exchange holds')
ax.legend(handles=[del_patch, con_patch, exch_patch], loc='upper right', fontsize=10)

ax.set_xlim(-8, 8)
ax.set_ylim(-7, 1)
ax.set_aspect('equal')
ax.axis('off')

# Depth labels
for depth in range(max_depth + 1):
    ax.text(-7.5, -depth * 2.0, f'Depth {depth}', fontsize=10, fontweight='bold',
            color='gray', verticalalignment='center')

plt.tight_layout()
plt.savefig('viz_minor_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_minor_lattice.png")
