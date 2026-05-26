#!/usr/bin/env python3
"""
Visualization: Support-Tutte Invariant Heatmap

Displays the support-Tutte invariant T(S; x, y) as a heatmap over the (x, y) plane
for several M-convex support sets, showing how the invariant landscape varies
across different support geometries.
"""

import matplotlib.pyplot as plt
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


def support_tutte(S, n, x=2, y=2, memo=None):
    if memo is None:
        memo = {}
    key = frozenset(S)
    if key in memo:
        return memo[key]
    if not S:
        return 1
    coord = None
    for i in range(n):
        vals = set(m[i] for m in S)
        if len(vals) > 1 or (len(vals) == 1 and 0 not in vals):
            coord = i
            break
    if coord is None:
        memo[key] = 1
        return 1
    i = coord
    is_loop = all(m[i] > 0 for m in S)
    is_coloop = len(set(m[i] for m in S)) == 1
    S_del = support_delete(S, i)
    S_con = support_contract(S, i)
    if is_loop:
        result = y * support_tutte(S_con, n, x, y, memo)
    elif is_coloop:
        result = x * support_tutte(S_con, n, x, y, memo)
    else:
        result = support_tutte(S_del, n, x, y, memo) + support_tutte(S_con, n, x, y, memo)
    memo[key] = result
    return result


# Create support sets
def uniform_matroid_support(n, k):
    bases = list(combinations(range(n), k))
    return [indicator_vector(n, B) for B in bases], n


def degree_simplex(n, d):
    S = []
    def gen(rv, rd, cur):
        if rv == 1:
            S.append(tuple(cur + [rd]))
            return
        for v in range(rd + 1):
            gen(rv - 1, rd - v, cur + [v])
    gen(n, d, [])
    return S, n


# Build heatmaps
fig, axes = plt.subplots(2, 3, figsize=(18, 11))
fig.suptitle('Support-Tutte Invariant T(S; x, y) — Heatmaps', fontsize=16, fontweight='bold')

supports = [
    ("U(2,4)", *uniform_matroid_support(4, 2)),
    ("U(2,5)", *uniform_matroid_support(5, 2)),
    ("U(3,5)", *uniform_matroid_support(5, 3)),
    ("Δ(3,2)", *degree_simplex(3, 2)),
    ("Δ(3,3)", *degree_simplex(3, 3)),
    ("Δ(4,2)", *degree_simplex(4, 2)),
]

x_range = np.linspace(0.5, 4.0, 40)
y_range = np.linspace(0.5, 4.0, 40)

for idx, (name, S, n) in enumerate(supports):
    ax = axes[idx // 3][idx % 3]
    
    Z = np.zeros((len(y_range), len(x_range)))
    for ix, xv in enumerate(x_range):
        for iy, yv in enumerate(y_range):
            memo = {}
            Z[iy, ix] = support_tutte(S, n, xv, yv, memo)
    
    # Use log scale for better visualization
    Z_log = np.log1p(np.abs(Z)) * np.sign(Z)
    
    im = ax.imshow(Z_log, extent=[x_range[0], x_range[-1], y_range[0], y_range[-1]],
                   origin='lower', aspect='auto', cmap='viridis')
    ax.set_xlabel('x', fontsize=10)
    ax.set_ylabel('y', fontsize=10)
    ax.set_title(f'{name}  (|S|={len(S)})', fontsize=12)
    
    # Mark special points
    memo = {}
    t11 = support_tutte(S, n, 1, 1, memo)
    memo = {}
    t22 = support_tutte(S, n, 2, 2, memo)
    ax.plot(1, 1, 'w*', markersize=10, zorder=5)
    ax.plot(2, 2, 'wo', markersize=8, zorder=5)
    ax.text(1.1, 1.1, f'T(1,1)={t11}', color='white', fontsize=7,
            fontweight='bold', bbox=dict(boxstyle='round,pad=0.2', facecolor='black', alpha=0.5))
    ax.text(2.1, 2.1, f'T(2,2)={t22}', color='white', fontsize=7,
            fontweight='bold', bbox=dict(boxstyle='round,pad=0.2', facecolor='black', alpha=0.5))
    
    plt.colorbar(im, ax=ax, label='log(1+|T|)·sign(T)', shrink=0.8)

plt.tight_layout()
plt.savefig('viz_tutte_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_tutte_heatmap.png")
