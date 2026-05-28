#!/usr/bin/env python3
"""
Visualization: Shadow Decay Profiles for Multiple Polynomial Families

This script visualizes how shadow profiles decay for different polynomial
support families, comparing elementary symmetric, permanent, and random
supports against the simplex upper bound. The key insight is that
circuit-computable polynomials have constrained shadow decay, while
explicit hard polynomials may decay more slowly.
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

def random_sparse_support(n, d, count, seed=42):
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


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Elementary symmetric shadow profiles
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 4))
for idx, (n_val, r) in enumerate([(5,2), (6,3), (7,3), (8,4)]):
    S = elem_symm_support(n_val, r)
    ks = list(range(r + 1))
    profile = [len(kth_shadow(S, k, n_val)) for k in ks]
    expected = [comb(n_val, r - k) for k in ks]
    ax.plot(ks, profile, 'o-', color=colors[idx], linewidth=2, markersize=8,
            label=f'$e_{r}$, n={n_val}')
    ax.plot(ks, expected, 'x', color=colors[idx], markersize=10, markeredgewidth=2)

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow$_k$(S)|', fontsize=12)
ax.set_title('Elementary Symmetric Supports\n(circles = computed, × = C(n, r−k))', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Permanent vs simplex bound
ax = axes[1]
for m in [2, 3, 4]:
    n_val = m * m
    d = m
    S = permanent_support(m)
    ks = list(range(d + 1))
    profile = [len(kth_shadow(S, k, n_val)) for k in ks]
    simplex = [comb(n_val + d - k, n_val) for k in ks]
    ax.plot(ks, profile, 'o-', linewidth=2, markersize=8, label=f'perm {m}×{m}')
    ax.plot(ks, simplex, '--', alpha=0.5, linewidth=1.5, label=f'simplex {m}×{m}')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow$_k$(S)|', fontsize=12)
ax.set_title('Permanent Supports vs Simplex Bounds', fontsize=13)
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 3: Normalized decay comparison
ax = axes[2]
n_val = 6
d = 3
families = {
    '$e_3$ (n=6)': elem_symm_support(6, 3),
    'perm 2×2 (→6 vars)': permanent_support(2),
    'random sparse': random_sparse_support(6, 3, 15, seed=42),
}
# For perm 2x2, n=4 but we embed in 6 vars
for name, S in families.items():
    n_eff = 4 if 'perm' in name else 6
    d_eff = 2 if 'perm' in name else 3
    ks = list(range(d_eff + 1))
    profile = [len(kth_shadow(S, k, n_eff)) for k in ks]
    normalized = [p / comb(n_eff + d_eff - k, n_eff) if comb(n_eff + d_eff - k, n_eff) > 0 else 0
                  for k, p in zip(ks, profile)]
    ax.plot(ks, normalized, 's-', linewidth=2, markersize=8, label=name)

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('δ(k) = |Sh$_k$| / C(n+d−k, n)', fontsize=12)
ax.set_title('Normalized Shadow Decay', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.1)

plt.suptitle('Shadow Decay Profiles: A New Invariant for Circuit Complexity',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
