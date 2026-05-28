#!/usr/bin/env python3
"""
Visualization: Primewise Birth Spectra Heatmap

Visualizes the key separation result: two filtrations F and G have identical
global birth sets but different primewise birth spectra. The heatmap shows
which primes are "active" at which filtration levels, revealing the hidden
chromatic structure that the global invariant discards.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ---------- Inline data ----------

def p_torsion_birth_set(p, orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}

def global_torsion_birth_set(orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 for m in orders)}

# Profile F: order 2 at level 1, order 6 at level 3
F_orders = {0: set(), 1: {2}, 2: set(), 3: {6}}
# Profile G: order 3 at level 1, order 6 at level 3
G_orders = {0: set(), 1: {3}, 2: set(), 3: {6}}

primes = [2, 3, 5, 7]
levels = [0, 1, 2, 3]

# Build heatmap matrices
def build_matrix(orders_at):
    mat = np.zeros((len(primes), len(levels)))
    for pi, p in enumerate(primes):
        bs = p_torsion_birth_set(p, orders_at)
        for li, l in enumerate(levels):
            if l in bs:
                mat[pi, li] = 1.0
    return mat

mat_F = build_matrix(F_orders)
mat_G = build_matrix(G_orders)
mat_diff = mat_F - mat_G  # +1 = only in F, -1 = only in G

# ---------- Plot ----------

fig, axes = plt.subplots(1, 3, figsize=(15, 4.5), gridspec_kw={'wspace': 0.35})

# Common settings
prime_labels = [f'p = {p}' for p in primes]
level_labels = [str(l) for l in levels]

# Profile F
im0 = axes[0].imshow(mat_F, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
axes[0].set_title('Profile F\n(orders: {1: {2}, 3: {6}})', fontsize=11, fontweight='bold')
axes[0].set_xlabel('Filtration Level')
axes[0].set_ylabel('Prime')
axes[0].set_xticks(range(len(levels)))
axes[0].set_xticklabels(level_labels)
axes[0].set_yticks(range(len(primes)))
axes[0].set_yticklabels(prime_labels)
for pi in range(len(primes)):
    for li in range(len(levels)):
        val = mat_F[pi, li]
        color = 'white' if val > 0.5 else 'black'
        axes[0].text(li, pi, '●' if val > 0 else '○',
                     ha='center', va='center', color=color, fontsize=14)

# Profile G
im1 = axes[1].imshow(mat_G, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
axes[1].set_title('Profile G\n(orders: {1: {3}, 3: {6}})', fontsize=11, fontweight='bold')
axes[1].set_xlabel('Filtration Level')
axes[1].set_xticks(range(len(levels)))
axes[1].set_xticklabels(level_labels)
axes[1].set_yticks(range(len(primes)))
axes[1].set_yticklabels(prime_labels)
for pi in range(len(primes)):
    for li in range(len(levels)):
        val = mat_G[pi, li]
        color = 'white' if val > 0.5 else 'black'
        axes[1].text(li, pi, '●' if val > 0 else '○',
                     ha='center', va='center', color=color, fontsize=14)

# Difference
cmap_diff = plt.cm.RdBu_r
im2 = axes[2].imshow(mat_diff, cmap=cmap_diff, aspect='auto', vmin=-1, vmax=1)
axes[2].set_title('Difference (F − G)\nSame global, different spectra', fontsize=11, fontweight='bold')
axes[2].set_xlabel('Filtration Level')
axes[2].set_xticks(range(len(levels)))
axes[2].set_xticklabels(level_labels)
axes[2].set_yticks(range(len(primes)))
axes[2].set_yticklabels(prime_labels)
for pi in range(len(primes)):
    for li in range(len(levels)):
        val = mat_diff[pi, li]
        if val > 0:
            axes[2].text(li, pi, '+F', ha='center', va='center',
                         color='white', fontsize=10, fontweight='bold')
        elif val < 0:
            axes[2].text(li, pi, '+G', ha='center', va='center',
                         color='white', fontsize=10, fontweight='bold')
        else:
            axes[2].text(li, pi, '=', ha='center', va='center',
                         color='gray', fontsize=10)

# Add global birth set annotation
gF = sorted(global_torsion_birth_set(F_orders))
gG = sorted(global_torsion_birth_set(G_orders))
fig.text(0.5, 0.01,
         f'Global birth sets:  F → {{{", ".join(map(str, gF))}}}  =  '
         f'G → {{{", ".join(map(str, gG))}}}   (identical!)',
         ha='center', fontsize=12, style='italic',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='orange'))

plt.suptitle('Primewise Birth Spectra: The Separation Theorem',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('primewise_spectra_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: primewise_spectra_heatmap.png")
