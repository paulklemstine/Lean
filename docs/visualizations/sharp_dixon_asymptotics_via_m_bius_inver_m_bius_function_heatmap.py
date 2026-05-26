"""
Visualization: Möbius Function Heatmap on Subgroup Lattice

This script creates a heatmap showing the Möbius function values μ(H, S_n)
for all subgroups of S_n, organized by subgroup order. This visualizes
the "anatomy of failure" — which subgroups contribute positively or negatively
to the generating pair count via the Möbius inversion formula.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import permutations
from math import factorial
from fractions import Fraction
from collections import defaultdict


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def closure(generators, n):
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def enumerate_subgroups(n):
    all_perms = list(permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity(n)]))
    for g in all_perms:
        subgroups.add(closure([g], n))
    for i, g in enumerate(all_perms):
        for h in all_perms[i:]:
            subgroups.add(closure([g, h], n))
    return subgroups

def compute_moebius(subgroups, n):
    sn = frozenset(permutations(range(n)))
    sorted_subs = sorted(subgroups, key=lambda s: -len(s))
    mu = {}
    for H in sorted_subs:
        if H == sn:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs if H < K and H.issubset(K))
    return mu


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Möbius Function μ(H, $S_n$) on Subgroup Lattice', fontsize=16, fontweight='bold')

for idx, n in enumerate([2, 3, 4, 5]):
    ax = axes[idx // 2][idx % 2]

    subgroups = enumerate_subgroups(n)
    mu = compute_moebius(subgroups, n)

    # Group by order
    by_order = defaultdict(list)
    for H in subgroups:
        by_order[len(H)].append(mu[H])

    orders = sorted(by_order.keys())
    max_count = max(len(v) for v in by_order.values())

    # Create grid data
    grid = np.full((len(orders), max_count), np.nan)
    for i, order in enumerate(orders):
        vals = sorted(by_order[order], reverse=True)
        for j, v in enumerate(vals):
            grid[i, j] = v

    # Plot
    im = ax.imshow(grid.T, aspect='auto', cmap='RdBu_r',
                   vmin=-max(abs(v) for v in mu.values()),
                   vmax=max(abs(v) for v in mu.values()),
                   interpolation='nearest')

    ax.set_xticks(range(len(orders)))
    ax.set_xticklabels([str(o) for o in orders], fontsize=8)
    ax.set_xlabel('Subgroup Order |H|', fontsize=11)
    ax.set_ylabel('Subgroup Index', fontsize=11)
    ax.set_title(f'$S_{n}$ ({len(subgroups)} subgroups)', fontsize=13)

    # Annotate cells
    for i in range(len(orders)):
        vals = sorted(by_order[orders[i]], reverse=True)
        for j, v in enumerate(vals):
            if not np.isnan(grid[i, j]):
                color = 'white' if abs(v) > max(abs(vv) for vv in mu.values()) * 0.6 else 'black'
                ax.text(i, j, str(int(v)), ha='center', va='center',
                       fontsize=7, color=color, fontweight='bold')

    plt.colorbar(im, ax=ax, shrink=0.8, label='μ(H, $S_n$)')

    # Add contribution info
    total_pairs = factorial(n) ** 2
    gen_count = sum(mu[H] * len(H)**2 for H in subgroups)
    prob = gen_count / total_pairs
    ax.text(0.02, 0.98, f'P = {prob:.4f}',
           transform=ax.transAxes, fontsize=10,
           verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('moebius_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: moebius_heatmap.png")
