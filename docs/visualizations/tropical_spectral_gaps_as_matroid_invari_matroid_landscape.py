#!/usr/bin/env python3
"""
Visualization: Exchange Defect Landscape for Different Graphs

Compares the exchange defect distributions across K₃, K₄, and K₅
graphical matroids with random valuations, showing how matroid
complexity grows with the graph. The landscape reveals that larger
matroids have richer exchange structure with wider defect distributions.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


def all_exchange_defects(bases, w_fn):
    bases_set = set(bases)
    defects = []
    for B1 in bases:
        for B2 in bases:
            d1, d2 = B1 - B2, B2 - B1
            if not d1 or not d2:
                continue
            for i in d1:
                for j in d2:
                    B1n = (B1 - {i}) | {j}
                    B2n = (B2 - {j}) | {i}
                    if B1n in bases_set and B2n in bases_set:
                        d = w_fn(B1) + w_fn(B2) - w_fn(B1n) - w_fn(B2n)
                        defects.append(d)
    return defects


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
colors = ['#2196F3', '#FF9800', '#4CAF50']
graph_names = ['K₃', 'K₄', 'K₅']

for idx, n in enumerate([3, 4, 5]):
    edges = list(combinations(range(n), 2))
    bases = graphical_matroid_bases(n, edges)

    rng = random.Random(42)
    weights = {B: rng.randint(-10, 10) for B in bases}
    w_fn = lambda B, weights=weights: weights.get(B, 0)

    defects = all_exchange_defects(bases, w_fn)

    ax = axes[idx]
    if defects:
        ax.hist(defects, bins=min(30, max(5, len(set(defects)))),
                color=colors[idx], edgecolor='black', alpha=0.8)
        ax.axvline(x=min(defects), color='red', linestyle='--',
                   linewidth=2, label=f'Min = {min(defects)}')
        ax.axvline(x=0, color='black', linestyle='-', linewidth=0.5)
    ax.set_title(f'{graph_names[idx]}\n{len(bases)} bases, {len(defects)} exchanges',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Exchange Defect', fontsize=10)
    ax.set_ylabel('Frequency', fontsize=10)
    ax.legend(fontsize=9)

plt.suptitle('Exchange Defect Landscapes Across Graph Families\n'
             '(Random Valuations, seed=42)', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('matroid_landscape.png', dpi=150, bbox_inches='tight')
print("Saved matroid_landscape.png")
