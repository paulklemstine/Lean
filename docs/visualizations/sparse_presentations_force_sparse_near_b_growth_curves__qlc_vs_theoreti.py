#!/usr/bin/env python3
"""
Visualization: Growth Curves of Quadratic Leaf Count vs Theoretical Bounds

Visualizes how the quadratic leaf count (QLC) grows with the number of left
vertices n, compared to the ambient bound C(n, r-2) and the active vertex
bound C(active, r-2). Shows that sparse presentations (small Δ) consistently
produce QLC well below the ambient bound.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import itertools
from typing import List, Dict, Set, Tuple, Optional
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


def compute_qlc(adj, n_right, rank):
    target = rank - 2
    if target <= 0: return 1 if target == 0 else 0
    return sum(1 for s in itertools.combinations(range(len(adj)), target)
               if is_independent(s, adj, n_right))


def generate_graph(n, delta, seed):
    random.seed(seed)
    adj = []
    for _ in range(n):
        deg = random.randint(1, min(delta, n))
        adj.append(sorted(random.sample(range(n), deg)))
    return adj


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: QLC vs n for different Δ
ns = [4, 5, 6, 7, 8, 9, 10]
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's'),
                               (4, '#3498db', '^')]:
    qlcs, bounds = [], []
    for n in ns:
        adj = generate_graph(n, delta, seed=42 + n * 10 + delta)
        rank = len(find_max_matching(adj, n))
        qlc = compute_qlc(adj, n, rank)
        bound = comb(n, max(0, rank - 2))
        qlcs.append(qlc)
        bounds.append(bound)

    axes[0].plot(ns, qlcs, f'{marker}-', color=color, label=f'QLC (Δ={delta})',
                 linewidth=2, markersize=8)
    axes[0].plot(ns, bounds, f'{marker}--', color=color, alpha=0.4,
                 label=f'C(n,r-2) (Δ={delta})')

axes[0].set_xlabel('Number of left vertices (n)', fontsize=12)
axes[0].set_ylabel('Count', fontsize=12)
axes[0].set_title('Quadratic Leaf Count vs Ambient Bound', fontsize=13)
axes[0].legend(fontsize=8, loc='upper left')
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Panel 2: Compression ratio QLC / C(n, r-2)
for delta, color, marker in [(2, '#e74c3c', 'o'), (3, '#2ecc71', 's'),
                               (4, '#3498db', '^')]:
    ratios = []
    for n in ns:
        adj = generate_graph(n, delta, seed=42 + n * 10 + delta)
        rank = len(find_max_matching(adj, n))
        qlc = compute_qlc(adj, n, rank)
        bound = comb(n, max(0, rank - 2))
        ratios.append(qlc / max(1, bound))

    axes[1].plot(ns, ratios, f'{marker}-', color=color, label=f'Δ={delta}',
                 linewidth=2, markersize=8)

axes[1].set_xlabel('Number of left vertices (n)', fontsize=12)
axes[1].set_ylabel('QLC / C(n, r-2)', fontsize=12)
axes[1].set_title('Compression Ratio (lower = sparser)', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].set_ylim(0, 1.05)
axes[1].grid(True, alpha=0.3)
axes[1].axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)

# Panel 3: QLC for complete vs sparse at fixed n=8
n = 8
deltas = [2, 3, 4, 5, 6, 7, 8]
qlcs_by_delta = []
bounds_by_delta = []

for delta in deltas:
    if delta == n:
        adj = [list(range(n)) for _ in range(n)]
    else:
        adj = generate_graph(n, delta, seed=100 + delta)
    rank = len(find_max_matching(adj, n))
    qlc = compute_qlc(adj, n, rank)
    bound = comb(n, max(0, rank - 2))
    qlcs_by_delta.append(qlc)
    bounds_by_delta.append(bound)

axes[2].bar([d - 0.15 for d in deltas], qlcs_by_delta, width=0.3,
            color='#e74c3c', label='QLC', alpha=0.8)
axes[2].bar([d + 0.15 for d in deltas], bounds_by_delta, width=0.3,
            color='#3498db', label='C(n,r-2)', alpha=0.5)
axes[2].set_xlabel('Maximum left degree (Δ)', fontsize=12)
axes[2].set_ylabel('Count', fontsize=12)
axes[2].set_title(f'QLC vs Bound (n={n})', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('growth_curves.png', dpi=150, bbox_inches='tight')
print("Saved growth_curves.png")
