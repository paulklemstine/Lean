#!/usr/bin/env python3
"""
Visualization: Elementary Symmetric Support Shadow Geometry

This script illustrates the exact shadow theorem for elementary symmetric
polynomials: Shadow_k(supp(e_r)) = supp(e_{r-k}), with |Shadow_k| = C(n, r-k).

The visualization shows how the support of e_r contracts level by level
through the shadow operation, connecting to the classical Kruskal-Katona
shadow phenomenon in extremal set theory.
"""

import itertools
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def elem_symm_support(n, r):
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

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


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: Shadow sizes for e_r with n=8
ax = axes[0, 0]
n_val = 8
for r in range(1, n_val):
    ks = list(range(r + 1))
    sizes = [comb(n_val, r - k) for k in ks]
    ax.plot(ks, sizes, 'o-', linewidth=2, markersize=6, label=f'r={r}')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow$_k$| = C(8, r−k)', fontsize=12)
ax.set_title(f'Shadow Profiles of $e_r(x_1,...,x_8)$', fontsize=13)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Top right: Ratio |Sh_k| / |Sh_0| (normalized by initial size)
ax = axes[0, 1]
for r in [2, 3, 4, 5]:
    ks = list(range(r + 1))
    ratios = [comb(n_val, r - k) / comb(n_val, r) for k in ks]
    ax.plot(ks, ratios, 's-', linewidth=2, markersize=7, label=f'r={r}')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Sh$_k$| / |Sh$_0$|', fontsize=12)
ax.set_title('Relative Shadow Decay (n=8)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom left: Verification table
ax = axes[1, 0]
ax.axis('off')
table_data = []
n_val = 7
for r in range(1, n_val + 1):
    row = [f'e_{r}']
    for k in range(min(r + 1, 5)):
        S = elem_symm_support(n_val, r)
        computed = len(kth_shadow(S, k, n_val))
        formula = comb(n_val, r - k)
        match = '✓' if computed == formula else '✗'
        row.append(f'{computed} {match}')
    while len(row) < 6:
        row.append('')
    table_data.append(row)

col_labels = ['Family'] + [f'Sh_{k}' for k in range(5)]
table = ax.table(cellText=table_data, colLabels=col_labels,
                 cellLoc='center', loc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.0, 1.5)
ax.set_title(f'Verification: |Sh_k(e_r)| = C({n_val}, r−k)', fontsize=13, pad=20)

# Bottom right: Shadow vs simplex bound comparison
ax = axes[1, 1]
n_val = 6
for r in [2, 3, 4]:
    ks = list(range(r + 1))
    shadow_sizes = [comb(n_val, r - k) for k in ks]
    simplex_sizes = [comb(n_val + r - k, n_val) for k in ks]
    ax.fill_between(ks, shadow_sizes, simplex_sizes, alpha=0.15)
    ax.plot(ks, shadow_sizes, 'o-', linewidth=2, markersize=7,
            label=f'|Sh_k(e_{r})| = C({n_val},r−k)')
    ax.plot(ks, simplex_sizes, '--', linewidth=1.5, alpha=0.6,
            label=f'C({n_val}+{r}−k,{n_val})')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Cardinality', fontsize=12)
ax.set_title(f'Shadow Size vs Simplex Bound (n={n_val})', fontsize=13)
ax.legend(fontsize=8, ncol=2)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

plt.suptitle('Elementary Symmetric Supports: Exact Shadow Geometry\n'
             'Shadow_k(supp(e_r)) = supp(e_{r−k}), connecting to Kruskal–Katona theory',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('elem_symm_shadows.png', dpi=150, bbox_inches='tight')
print("Saved elem_symm_shadows.png")
