"""
Visualization: Möbius Contributions by Subgroup Size in S_n

This script creates a bar chart showing how different subgroup sizes contribute
to the generating pair count via the Möbius inversion formula. Each bar represents
the total μ(H, S_n) · |H|² contribution from all subgroups of a given size.

The key visual insight is that the formula involves both positive and negative
contributions that cancel to produce the exact generating pair count.
"""

import matplotlib.pyplot as plt
import numpy as np
import itertools
from collections import defaultdict

# ── Self-contained permutation utilities ──

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i in range(len(p)):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generated_subgroup(gens, n):
    e = identity(n)
    subgroup = {e}
    for g in gens:
        subgroup.add(g)
    queue = list(subgroup - {e})
    while queue:
        g = queue.pop(0)
        for h in list(subgroup):
            for new in [compose(g, h), compose(h, g), inverse(g)]:
                if new not in subgroup:
                    subgroup.add(new)
                    queue.append(new)
    return frozenset(subgroup)

def compute_subgroup_lattice(n):
    perms = list(itertools.permutations(range(n)))
    subgroups = {frozenset([identity(n)]), frozenset(perms)}
    for p in perms:
        subgroups.add(generated_subgroup([p], n))
    for p in perms:
        for q in perms:
            subgroups.add(generated_subgroup([p, q], n))
    return subgroups

def compute_moebius(subgroups, n):
    full = frozenset(itertools.permutations(range(n)))
    sorted_sgs = sorted(subgroups, key=lambda s: -len(s))
    mu = {full: 1}
    for sg in sorted_sgs:
        if sg == full:
            continue
        mu[sg] = -sum(mu.get(lg, 0) for lg in subgroups if sg < lg)
    return mu

# ── Compute for S_3 and S_4 ──

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, n in enumerate([3, 4]):
    subgroups = compute_subgroup_lattice(n)
    mu = compute_moebius(subgroups, n)

    # Group by subgroup size
    size_contrib = defaultdict(float)
    for sg in subgroups:
        sz = len(sg)
        size_contrib[sz] += mu.get(sg, 0) * sz ** 2

    sizes = sorted(size_contrib.keys())
    contributions = [size_contrib[s] for s in sizes]
    colors = ['#2ecc71' if c >= 0 else '#e74c3c' for c in contributions]

    ax = axes[idx]
    bars = ax.bar([str(s) for s in sizes], contributions, color=colors, edgecolor='black', linewidth=0.5)

    # Add value labels
    for bar, val in zip(bars, contributions):
        y = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, y + (5 if y >= 0 else -15),
                f'{int(val)}', ha='center', va='bottom' if y >= 0 else 'top',
                fontsize=9, fontweight='bold')

    total = sum(contributions)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Subgroup Size |H|', fontsize=12)
    ax.set_ylabel('μ(H, S_n) · |H|²', fontsize=12)
    ax.set_title(f'S_{n}: Möbius Contributions (Total = {int(total)})', fontsize=14)
    ax.grid(axis='y', alpha=0.3)

    # Add annotation
    n_fact = [1, 1, 2, 6, 24][n]
    ax.annotate(f'P_{n} = {int(total)}/{n_fact**2} = {total/n_fact**2:.4f}',
                xy=(0.95, 0.95), xycoords='axes fraction',
                ha='right', va='top', fontsize=11,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='gray'))

plt.suptitle('Möbius Inversion Formula: Subgroup Contributions to Generating Pair Count',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_moebius_contributions.png', dpi=150, bbox_inches='tight')
print("Saved viz_moebius_contributions.png")
