#!/usr/bin/env python3
"""
Visualization: Partial Permutation Support Heatmap

Visualizes partial permutation supports (nonattacking rook placements)
on n×n boards. Shows examples of shadow elements — the partial
structures that underlie the permanent's circuit complexity.

This is a self-contained script — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, combinations


def perm_graph(sigma):
    return frozenset((i, sigma[i]) for i in range(len(sigma)))

def perm_support_family(n):
    return {perm_graph(sigma) for sigma in permutations(range(n))}

def k_shadow(family, k):
    shadow = set()
    for s in family:
        s_list = sorted(s)
        target_size = len(s_list) - k
        if target_size < 0:
            continue
        for subset in combinations(s_list, target_size):
            shadow.add(frozenset(subset))
    return shadow


n = 6
family = perm_support_family(n)

fig, axes = plt.subplots(2, 4, figsize=(16, 8))

# Top row: full permutation supports
axes[0, 0].set_title('Full Permutation\nSupport (n=6)', fontsize=11, fontweight='bold')
for idx, sigma in enumerate(list(permutations(range(n)))[:4]):
    ax = axes[0, idx]
    grid = np.zeros((n, n))
    for i in range(n):
        grid[i, sigma[i]] = 1
    ax.imshow(grid, cmap='Blues', vmin=0, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Column', fontsize=9)
    if idx == 0:
        ax.set_ylabel('Row', fontsize=9)
    ax.set_title(f'σ = {list(sigma)}', fontsize=9)
    ax.grid(True, alpha=0.3)
    # Mark the cells
    for i in range(n):
        ax.text(sigma[i], i, '♜', ha='center', va='center', fontsize=14, color='darkblue')

# Bottom row: shadow elements (partial perm supports of size n-2)
sh2 = k_shadow(family, 2)
shadow_list = sorted(sh2, key=lambda s: sorted(s))

axes[1, 0].set_title('2-Shadow Element\n(size n-2=4)', fontsize=11, fontweight='bold')
for idx in range(4):
    ax = axes[1, idx]
    s = shadow_list[idx * len(shadow_list) // 4]
    grid = np.zeros((n, n))
    for (i, j) in s:
        grid[i, j] = 1

    # Find defect rows/cols
    covered_rows = {p[0] for p in s}
    covered_cols = {p[1] for p in s}
    missing_rows = set(range(n)) - covered_rows
    missing_cols = set(range(n)) - covered_cols

    ax.imshow(grid, cmap='Greens', vmin=0, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Column', fontsize=9)
    if idx == 0:
        ax.set_ylabel('Row', fontsize=9)
    ax.grid(True, alpha=0.3)

    # Mark cells
    for (i, j) in s:
        ax.text(j, i, '♜', ha='center', va='center', fontsize=14, color='darkgreen')

    # Highlight missing rows/cols
    for r in missing_rows:
        ax.axhline(y=r, color='red', linewidth=2, alpha=0.3)
    for c in missing_cols:
        ax.axvline(x=c, color='red', linewidth=2, alpha=0.3)

    mr = sorted(missing_rows)
    mc = sorted(missing_cols)
    ax.set_title(f'Missing: rows {mr}\ncols {mc}', fontsize=9)

plt.suptitle('Permanent Support and Its 2-Shadow\n'
             'Top: Full permutations (n rooks)  |  '
             'Bottom: Shadow elements (n−2 rooks, red = gaps)',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('rook_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved rook_heatmap.png")
