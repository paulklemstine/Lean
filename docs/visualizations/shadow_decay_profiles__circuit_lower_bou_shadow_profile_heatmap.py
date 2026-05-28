#!/usr/bin/env python3
"""
Visualization: Shadow Profile Heatmap Across Families

This script creates a heatmap showing how shadow profiles vary across
different polynomial families and shadow depths, making visible the
qualitative differences in shadow decay behavior that distinguish
circuit-computable from hard polynomials.
"""

import itertools
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def kth_shadow(S, k, n):
    shadow = set()
    for alpha in S:
        _add(alpha, k, n, 0, [], shadow)
    return shadow

def _add(alpha, rem, n, idx, diff, result):
    if idx == n:
        if rem == 0:
            result.add(tuple(alpha[i] - diff[i] for i in range(n)))
        return
    for d in range(min(rem, alpha[idx]) + 1):
        diff.append(d)
        _add(alpha, rem - d, n, idx + 1, diff, result)
        diff.pop()

def elem_symm_support(n, r):
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def permanent_support(m):
    n = m * m
    support = set()
    for perm in itertools.permutations(range(m)):
        vec = [0] * n
        for i in range(m):
            vec[i * m + perm[i]] = 1
        support.add(tuple(vec))
    return support

def random_support(n, d, count, seed=42):
    import random
    rng = random.Random(seed)
    support = set()
    for _ in range(count * 100):
        if len(support) >= count:
            break
        vec = [0] * n
        for _ in range(d):
            vec[rng.randint(0, n - 1)] += 1
        support.add(tuple(vec))
    return support


# Build family data
families = []
max_k = 4

# Elementary symmetric
for r in [2, 3, 4]:
    n = 8
    if r <= n:
        S = elem_symm_support(n, r)
        d = r
        profile = []
        for k in range(max_k + 1):
            if k <= d:
                sh = len(kth_shadow(S, k, n))
                bound = comb(n + d - k, n)
                profile.append(sh / bound if bound > 0 else 0)
            else:
                profile.append(0)
        families.append((f'e_{r}(8 vars)', profile))

# Permanents
for m in [2, 3]:
    n = m * m
    d = m
    S = permanent_support(m)
    profile = []
    for k in range(max_k + 1):
        if k <= d:
            sh = len(kth_shadow(S, k, n))
            bound = comb(n + d - k, n)
            profile.append(sh / bound if bound > 0 else 0)
        else:
            profile.append(0)
    families.append((f'perm {m}×{m}', profile))

# Random
for label, (n, d, count) in [('sparse(6,3,10)', (6, 3, 10)),
                               ('dense(5,3,35)', (5, 3, 35))]:
    S = random_support(n, d, count)
    profile = []
    for k in range(max_k + 1):
        if k <= d:
            sh = len(kth_shadow(S, k, n))
            bound = comb(n + d - k, n)
            profile.append(sh / bound if bound > 0 else 0)
        else:
            profile.append(0)
    families.append((label, profile))

# Create heatmap
names = [f[0] for f in families]
data = np.array([f[1] for f in families])

fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(data, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1)

ax.set_xticks(range(max_k + 1))
ax.set_xticklabels([f'k={k}' for k in range(max_k + 1)], fontsize=12)
ax.set_yticks(range(len(names)))
ax.set_yticklabels(names, fontsize=11)

# Add text annotations
for i in range(len(names)):
    for j in range(max_k + 1):
        val = data[i, j]
        color = 'white' if val > 0.5 else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                fontsize=10, color=color, fontweight='bold')

ax.set_xlabel('Shadow Depth k', fontsize=13)
ax.set_title('Normalized Shadow Decay δ(k) = |Sh_k(S)| / C(n+d−k, n)\n'
             'Higher values (red) indicate slower decay — potential circuit hardness',
             fontsize=13)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Normalized shadow occupation δ(k)', fontsize=11)

plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
