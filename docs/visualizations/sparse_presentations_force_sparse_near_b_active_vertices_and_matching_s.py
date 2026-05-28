#!/usr/bin/env python3
"""
Visualization: Active Vertices and Matching Structure

Shows the relationship between active vertices, matching structure, and
the compression of near-basis geometry. Illustrates the key theorem that
independent sets concentrate on the active vertex set.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random
import itertools
from math import comb


def find_max_matching(adj, n_right):
    match_l, match_r = {}, {}
    def augment(u, visited):
        for v in adj[u]:
            if v in visited: continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v; match_r[v] = u; return True
        return False
    for u in range(len(adj)):
        augment(u, set())
    return match_l


def is_independent(subset, adj, n_right):
    if not subset: return True
    sub_adj = [adj[v] for v in subset]
    return len(find_max_matching(sub_adj, n_right)) == len(subset)


def find_active(adj, n_right, rank):
    n_left = len(adj)
    active = set()
    for v in range(n_left):
        for r in adj[v]:
            remaining = [([w for w in adj[u] if w != r]) for u in range(n_left) if u != v]
            if len(find_max_matching(remaining, n_right)) + 1 == rank:
                active.add(v)
                break
    return active


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: Active vs total vertices for varying n
ns = list(range(4, 13))
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's'),
                               (4, '#3498db', '^')]:
    active_counts = []
    for n in ns:
        random.seed(42 + n * 10 + delta)
        adj = []
        for _ in range(n):
            deg = random.randint(1, min(delta, n))
            adj.append(sorted(random.sample(range(n), deg)))
        rank = len(find_max_matching(adj, n))
        active = find_active(adj, n, rank)
        active_counts.append(len(active))

    axes[0, 0].plot(ns, active_counts, f'{marker}-', color=color,
                    label=f'Active (Δ={delta})', linewidth=2, markersize=8)

axes[0, 0].plot(ns, ns, 'k--', alpha=0.3, label='n (total)')
axes[0, 0].set_xlabel('n', fontsize=12)
axes[0, 0].set_ylabel('Active vertex count', fontsize=12)
axes[0, 0].set_title('Active Vertices vs Total Vertices', fontsize=13)
axes[0, 0].legend(fontsize=9)
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Improvement from active bound
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's')]:
    improvements = []
    for n in ns:
        random.seed(42 + n * 10 + delta)
        adj = []
        for _ in range(n):
            deg = random.randint(1, min(delta, n))
            adj.append(sorted(random.sample(range(n), deg)))
        rank = len(find_max_matching(adj, n))
        active = find_active(adj, n, rank)
        target = max(0, rank - 2)
        bound_ambient = comb(n, target)
        bound_active = comb(len(active), target)
        if bound_ambient > 0:
            improvements.append(1 - bound_active / bound_ambient)
        else:
            improvements.append(0)

    axes[0, 1].plot(ns, improvements, f'{marker}-', color=color,
                    label=f'Δ={delta}', linewidth=2, markersize=8)

axes[0, 1].set_xlabel('n', fontsize=12)
axes[0, 1].set_ylabel('Improvement fraction', fontsize=12)
axes[0, 1].set_title('Bound Improvement: 1 - C(active,r-2)/C(n,r-2)', fontsize=13)
axes[0, 1].legend(fontsize=10)
axes[0, 1].grid(True, alpha=0.3)
axes[0, 1].set_ylim(-0.05, 1.05)

# Panel 3: Bipartite graph visualization for a specific example
n = 8
delta = 3
random.seed(42 + n * 10 + delta)
adj = []
for _ in range(n):
    deg = random.randint(1, min(delta, n))
    adj.append(sorted(random.sample(range(n), deg)))

rank = len(find_max_matching(adj, n))
active = find_active(adj, n, rank)
matching = find_max_matching(adj, n)

ax = axes[1, 0]
# Draw left vertices
for i in range(n):
    color = '#e74c3c' if i in active else '#95a5a6'
    size = 300 if i in active else 150
    ax.scatter(0, n - 1 - i, s=size, c=color, zorder=5, edgecolors='black')
    ax.text(-0.15, n - 1 - i, f'L{i}', ha='right', va='center', fontsize=9)

# Draw right vertices
for j in range(n):
    matched = j in {matching[k] for k in matching}
    color = '#3498db' if matched else '#bdc3c7'
    size = 300 if matched else 150
    ax.scatter(2, n - 1 - j, s=size, c=color, zorder=5, edgecolors='black')
    ax.text(2.15, n - 1 - j, f'R{j}', ha='left', va='center', fontsize=9)

# Draw edges
for i in range(n):
    for j in adj[i]:
        is_matched = i in matching and matching[i] == j
        color = '#2ecc71' if is_matched else '#bdc3c7'
        width = 2.5 if is_matched else 0.5
        alpha = 1.0 if is_matched else 0.3
        ax.plot([0, 2], [n - 1 - i, n - 1 - j], color=color,
                linewidth=width, alpha=alpha, zorder=1 if not is_matched else 3)

ax.set_xlim(-0.5, 2.5)
ax.set_ylim(-0.5, n - 0.5)
ax.set_title(f'Bipartite Graph (n={n}, Δ={delta}, rank={rank})', fontsize=13)
ax.set_aspect('equal')
ax.axis('off')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Active left'),
    mpatches.Patch(facecolor='#95a5a6', edgecolor='black', label='Inactive left'),
    mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Matched right'),
    mpatches.Patch(facecolor='#2ecc71', label='Matching edge'),
]
ax.legend(handles=legend_elements, loc='lower center', fontsize=8, ncol=2)

# Panel 4: Three bounds comparison
ax = axes[1, 1]
ns_small = [5, 6, 7, 8, 9, 10]
delta = 3
qlcs = []
ambient_bounds = []
active_bounds = []

for n in ns_small:
    random.seed(42 + n * 10 + delta)
    adj_local = []
    for _ in range(n):
        deg = random.randint(1, min(delta, n))
        adj_local.append(sorted(random.sample(range(n), deg)))
    rank = len(find_max_matching(adj_local, n))
    qlc = 0
    target = rank - 2
    if target >= 0:
        qlc = sum(1 for s in itertools.combinations(range(n), target)
                  if is_independent(s, adj_local, n))
    active_v = find_active(adj_local, n, rank)

    qlcs.append(qlc)
    ambient_bounds.append(comb(n, max(0, target)))
    active_bounds.append(comb(len(active_v), max(0, target)))

x = np.arange(len(ns_small))
width = 0.25

ax.bar(x - width, ambient_bounds, width, label='C(n, r-2)', color='#3498db', alpha=0.7)
ax.bar(x, active_bounds, width, label='C(active, r-2)', color='#f39c12', alpha=0.7)
ax.bar(x + width, qlcs, width, label='QLC (actual)', color='#e74c3c', alpha=0.7)

ax.set_xticks(x)
ax.set_xticklabels(ns_small)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Three Bounds Comparison (Δ={delta})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('active_vertices.png', dpi=150, bbox_inches='tight')
print("Saved active_vertices.png")
