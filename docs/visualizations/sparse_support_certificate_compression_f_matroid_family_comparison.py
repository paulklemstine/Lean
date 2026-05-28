"""
Visualization: Matroid Family Comparison

Bar chart comparing quadratic leaf counts across different matroid families
for fixed parameters, showing how support structure controls complexity.
Includes ambient bound, active-variable bound, and actual leaf count.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb
from collections import defaultdict
import random

random.seed(42)

def count_leaves(bases, n, r):
    k = r - 2
    if k < 0:
        return 0
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            count += 1
    return count

def active_count(bases):
    s = set()
    for b in bases:
        s |= b
    return len(s)

def is_forest(edges, indices):
    adj = defaultdict(set)
    verts = set()
    for idx in indices:
        u, v = edges[idx]
        adj[u].add(v)
        adj[v].add(u)
        verts.add(u)
        verts.add(v)
    visited = set()
    for start in verts:
        if start in visited:
            continue
        stack = [(start, -1)]
        lv = set()
        while stack:
            node, parent = stack.pop()
            if node in lv:
                return False
            lv.add(node)
            visited.add(node)
            for nb in adj[node]:
                if nb != parent:
                    stack.append((nb, node))
    return True

def spans(edges, indices, nv):
    if not indices:
        return nv <= 1
    adj = defaultdict(set)
    for idx in indices:
        u, v = edges[idx]
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    queue = [0]
    while queue:
        node = queue.pop()
        if node in visited:
            continue
        visited.add(node)
        for nb in adj[node]:
            if nb not in visited:
                queue.append(nb)
    return len(visited) == nv

# Fixed parameters
n = 10
r = 4
k = r - 2

families = []

# 1. Uniform matroid
bases_unif = {frozenset(c) for c in combinations(range(n), r)}
leaves_unif = count_leaves(bases_unif, n, r)
omega_unif = active_count(bases_unif)
families.append(("Uniform\nU(4,10)", leaves_unif, comb(omega_unif, k),
                 comb(n, k), len(bases_unif)))

# 2. Single basis
bases_single = {frozenset({0, 1, 2, 3})}
leaves_single = count_leaves(bases_single, n, r)
omega_single = active_count(bases_single)
families.append(("Single\nBasis", leaves_single, comb(omega_single, k),
                 comb(n, k), 1))

# 3. Two disjoint bases
bases_two = {frozenset({0,1,2,3}), frozenset({4,5,6,7})}
leaves_two = count_leaves(bases_two, n, r)
omega_two = active_count(bases_two)
families.append(("2 Disjoint\nBases", leaves_two, comb(omega_two, k),
                 comb(n, k), 2))

# 4. Three overlapping bases
bases_three = {frozenset({0,1,2,3}), frozenset({2,3,4,5}), frozenset({4,5,6,7})}
leaves_three = count_leaves(bases_three, n, r)
omega_three = active_count(bases_three)
families.append(("3 Overlap\nBases", leaves_three, comb(omega_three, k),
                 comb(n, k), 3))

# 5. Random 10 bases
all_combs = list(combinations(range(n), r))
chosen = random.sample(all_combs, 10)
bases_rand = {frozenset(c) for c in chosen}
leaves_rand = count_leaves(bases_rand, n, r)
omega_rand = active_count(bases_rand)
families.append(("Random\n10 Bases", leaves_rand, comb(omega_rand, k),
                 comb(n, k), 10))

# 6. Random 50 bases
chosen50 = random.sample(all_combs, 50)
bases_r50 = {frozenset(c) for c in chosen50}
leaves_r50 = count_leaves(bases_r50, n, r)
omega_r50 = active_count(bases_r50)
families.append(("Random\n50 Bases", leaves_r50, comb(omega_r50, k),
                 comb(n, k), 50))

# Extract data
names = [f[0] for f in families]
actual = [f[1] for f in families]
active_bd = [f[2] for f in families]
ambient = [f[3] for f in families]
num_bases = [f[4] for f in families]

x = np.arange(len(names))
width = 0.25

fig, ax = plt.subplots(figsize=(12, 7))

bars1 = ax.bar(x - width, ambient, width, label='Ambient C(n, r−2)',
               color='#e74c3c', alpha=0.8, edgecolor='black', linewidth=0.5)
bars2 = ax.bar(x, active_bd, width, label='Active C(ω, r−2)',
               color='#f39c12', alpha=0.8, edgecolor='black', linewidth=0.5)
bars3 = ax.bar(x + width, actual, width, label='Actual Leaves',
               color='#2ecc71', alpha=0.8, edgecolor='black', linewidth=0.5)

# Add value labels
for bar_group in [bars1, bars2, bars3]:
    for bar in bar_group:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.5,
                f'{int(height)}', ha='center', va='bottom', fontsize=9,
                fontweight='bold')

# Add basis count annotations
for i, nb in enumerate(num_bases):
    ax.text(i, -3, f'{nb} bases', ha='center', fontsize=9,
            style='italic', color='gray')

ax.set_xlabel('Matroid Family', fontsize=13)
ax.set_ylabel('Leaf Count', fontsize=13)
ax.set_title(f'Certificate Compression by Support Geometry\n'
             f'n = {n}, r = {r}, ambient bound C({n}, {k}) = {comb(n, k)}',
             fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(names, fontsize=11)
ax.legend(fontsize=11, loc='upper right')
ax.grid(True, alpha=0.2, axis='y')
ax.set_ylim(bottom=-5)

plt.tight_layout()
plt.savefig('matroid_comparison.png', dpi=150, bbox_inches='tight')
print("Saved matroid_comparison.png")
