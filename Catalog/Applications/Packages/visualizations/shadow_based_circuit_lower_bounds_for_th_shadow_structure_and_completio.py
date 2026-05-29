#!/usr/bin/env python3
"""
Visualization: Completion Multiplicity and Shadow Structure

Visualizes the uniform completion multiplicity property: every partial
permutation support of size n-2 extends to exactly 2 full permutation
supports. Also shows the structure of the k-shadow hierarchy.

This is a self-contained script — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import factorial, comb
from itertools import permutations, combinations
from collections import Counter


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

def completion_count(s, family):
    s_set = set(s)
    return sum(1 for t in family if s_set <= set(t))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Completion counts are all exactly 2
ax1 = axes[0]
for n in range(3, 7):
    family = perm_support_family(n)
    sh2 = k_shadow(family, 2)
    counts = [completion_count(s, family) for s in sh2]
    counter = Counter(counts)
    bars = ax1.bar([n + (c - 2) * 0.15 for c in counter.keys()],
                   counter.values(), width=0.12, label=f'n={n}', alpha=0.8)

ax1.set_xlabel('Completion count', fontsize=12)
ax1.set_ylabel('Number of shadow elements', fontsize=12)
ax1.set_title('Completion Multiplicity\n(always exactly 2)', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_xticks(range(3, 7))
ax1.set_xticklabels([f'n={n}' for n in range(3, 7)])

# Plot 2: k-shadow hierarchy
ax2 = axes[1]
for n in range(3, 8):
    ks = list(range(n + 1))
    shadow_sizes = [comb(n, k)**2 * factorial(n - k) for k in ks]
    ax2.semilogy(ks, shadow_sizes, 'o-', linewidth=2, markersize=6, label=f'n={n}')

ax2.set_xlabel('Shadow depth k', fontsize=12)
ax2.set_ylabel('|Sh_k| (log scale)', fontsize=12)
ax2.set_title('k-Shadow Hierarchy\n|Sh_k| = C(n,k)² · (n-k)!', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Ratio of shadow to parent
ax3 = axes[2]
for n in range(4, 9):
    ks = list(range(1, n + 1))
    ratios = []
    for k in ks:
        parent = comb(n, k-1)**2 * factorial(n - k + 1) if k > 0 else factorial(n)
        child = comb(n, k)**2 * factorial(n - k)
        ratios.append(child / parent if parent > 0 else 0)
    ax3.plot(ks, ratios, 'o-', linewidth=2, markersize=6, label=f'n={n}')

ax3.set_xlabel('Shadow depth k', fontsize=12)
ax3.set_ylabel('|Sh_k| / |Sh_{k-1}|', fontsize=12)
ax3.set_title('Shadow Compression Ratio\nacross depths', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('Permanent Support Shadow Structure', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('shadow_structure.png', dpi=150, bbox_inches='tight')
print("Saved shadow_structure.png")
