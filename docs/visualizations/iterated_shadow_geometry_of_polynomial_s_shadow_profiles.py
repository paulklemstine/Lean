"""
Visualization: Shadow Profile Comparison

Visualizes how shadow profiles decay for different support families:
simplex, matroid basis, and product supports. The key insight is that
exchange-family supports produce log-concave profiles, while arbitrary
supports may not.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, product as iterproduct
from math import comb


# ── Inline implementations (self-contained) ──────────────────────────

def all_multi_indices_of_mass(n, k):
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    results = []
    for first in range(k + 1):
        for rest in all_multi_indices_of_mass(n - 1, k - first):
            results.append((first,) + rest)
    return results


def enumerate_multi_indices_le(alpha, mass):
    n = len(alpha)
    results = []
    def generate(pos, remaining, current):
        if pos == n:
            if remaining == 0:
                results.append(tuple(current))
            return
        for v in range(min(alpha[pos], remaining) + 1):
            current.append(v)
            generate(pos + 1, remaining - v, current)
            current.pop()
    generate(0, mass, [])
    return results


def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        for tau in enumerate_multi_indices_le(alpha, k):
            beta = tuple(a - t for a, t in zip(alpha, tau))
            shadow.add(beta)
    return shadow


def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]


def simplex_support(n, d):
    return set(all_multi_indices_of_mass(n, d))


def matroid_basis_support(n, r):
    support = set()
    for basis in combinations(range(n), r):
        alpha = tuple(1 if i in basis else 0 for i in range(n))
        support.add(alpha)
    return support


def product_support(dims):
    return set(iterproduct(*(range(d + 1) for d in dims)))


# ── Plotting ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Simplex supports
ax = axes[0]
ax.set_title("Simplex Supports Δ(n, d)", fontsize=13, fontweight='bold')
for n, d, color in [(2, 5, '#1f77b4'), (3, 4, '#ff7f0e'), (4, 3, '#2ca02c'), (3, 5, '#d62728')]:
    S = simplex_support(n, d)
    prof = shadow_profile(S)
    ks = list(range(len(prof)))
    ax.plot(ks, prof, 'o-', color=color, label=f'Δ({n},{d})', linewidth=2, markersize=6)
ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Sh_k(S)|', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Matroid basis supports
ax = axes[1]
ax.set_title("Matroid Basis Supports U_{r,n}", fontsize=13, fontweight='bold')
for n, r, color in [(5, 2, '#1f77b4'), (5, 3, '#ff7f0e'), (6, 3, '#2ca02c'),
                     (7, 3, '#d62728'), (6, 4, '#9467bd')]:
    S = matroid_basis_support(n, r)
    prof = shadow_profile(S)
    ks = list(range(len(prof)))
    ax.plot(ks, prof, 's-', color=color, label=f'U({r},{n})', linewidth=2, markersize=6)
ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Sh_k(S)|', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Product supports
ax = axes[2]
ax.set_title("Product Supports", fontsize=13, fontweight='bold')
for dims, color in [([2, 3], '#1f77b4'), ([1, 1, 1, 1], '#ff7f0e'),
                     ([2, 2, 2], '#2ca02c'), ([3, 3], '#d62728')]:
    S = product_support(dims)
    prof = shadow_profile(S)
    ks = list(range(len(prof)))
    label = '×'.join(f'[0,{d}]' for d in dims)
    ax.plot(ks, prof, '^-', color=color, label=label, linewidth=2, markersize=6)
ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Sh_k(S)|', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Shadow Profiles: Support Size Under Iterated Combinatorial Differentiation',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
