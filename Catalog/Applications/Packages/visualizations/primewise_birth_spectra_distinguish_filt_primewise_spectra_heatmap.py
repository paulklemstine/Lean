#!/usr/bin/env python3
"""
Visualization 1: Primewise Birth Spectra Heatmap

Visualizes the primewise birth spectrum of two filtration profiles as heatmaps,
showing how the global birth sets are identical but the primewise decomposition
differs. Each row is a prime, each column is a filtration level, and cells
are colored by whether p-torsion is born at that level.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, Set


def prime_factors(n: int) -> Set[int]:
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


class BirthProfile:
    def __init__(self, max_level: int, orders_at: Dict[int, Set[int]]):
        self.max_level = max_level
        self.orders_at = {i: set(orders_at.get(i, set())) for i in range(max_level + 1)}

    def p_birth_set(self, p: int) -> set:
        return {i for i in range(self.max_level + 1)
                if any(m > 1 and m % p == 0 for m in self.orders_at[i])}

    def global_birth_set(self) -> set:
        return {i for i in range(self.max_level + 1)
                if any(m > 1 for m in self.orders_at[i])}

    def active_primes(self) -> set:
        all_orders = set().union(*self.orders_at.values())
        return set().union(*(prime_factors(m) for m in all_orders if m > 1))


# Create the witness profiles
F = BirthProfile(3, {1: {2}, 3: {6}})
G = BirthProfile(3, {1: {3}, 3: {6}})

primes = sorted(F.active_primes() | G.active_primes())
levels = list(range(4))

# Build heatmap matrices
def make_matrix(prof, primes, levels):
    mat = np.zeros((len(primes), len(levels)))
    for pi, p in enumerate(primes):
        birth = prof.p_birth_set(p)
        for li, l in enumerate(levels):
            if l in birth:
                mat[pi, li] = 1.0
    return mat

F_mat = make_matrix(F, primes, levels)
G_mat = make_matrix(G, primes, levels)
diff_mat = F_mat - G_mat  # +1 = F has it, -1 = G has it, 0 = same

fig, axes = plt.subplots(1, 3, figsize=(14, 4))

# Profile F
im1 = axes[0].imshow(F_mat, cmap='Blues', aspect='auto', vmin=0, vmax=1)
axes[0].set_title('Profile F\n(ℤ/2ℤ at level 1, ℤ/6ℤ at level 3)', fontsize=10)
axes[0].set_xlabel('Filtration Level')
axes[0].set_ylabel('Prime')
axes[0].set_xticks(range(len(levels)))
axes[0].set_xticklabels(levels)
axes[0].set_yticks(range(len(primes)))
axes[0].set_yticklabels([f'p = {p}' for p in primes])
for i in range(len(primes)):
    for j in range(len(levels)):
        axes[0].text(j, i, '●' if F_mat[i,j] else '○',
                    ha='center', va='center', fontsize=16,
                    color='white' if F_mat[i,j] else 'lightgray')

# Profile G
im2 = axes[1].imshow(G_mat, cmap='Oranges', aspect='auto', vmin=0, vmax=1)
axes[1].set_title('Profile G\n(ℤ/3ℤ at level 1, ℤ/6ℤ at level 3)', fontsize=10)
axes[1].set_xlabel('Filtration Level')
axes[1].set_xticks(range(len(levels)))
axes[1].set_xticklabels(levels)
axes[1].set_yticks(range(len(primes)))
axes[1].set_yticklabels([f'p = {p}' for p in primes])
for i in range(len(primes)):
    for j in range(len(levels)):
        axes[1].text(j, i, '●' if G_mat[i,j] else '○',
                    ha='center', va='center', fontsize=16,
                    color='white' if G_mat[i,j] else 'lightgray')

# Difference
im3 = axes[2].imshow(diff_mat, cmap='RdBu', aspect='auto', vmin=-1, vmax=1)
axes[2].set_title('Difference (F − G)\nRed = only in F, Blue = only in G', fontsize=10)
axes[2].set_xlabel('Filtration Level')
axes[2].set_xticks(range(len(levels)))
axes[2].set_xticklabels(levels)
axes[2].set_yticks(range(len(primes)))
axes[2].set_yticklabels([f'p = {p}' for p in primes])
for i in range(len(primes)):
    for j in range(len(levels)):
        val = diff_mat[i,j]
        if val > 0:
            axes[2].text(j, i, 'F', ha='center', va='center', fontsize=12, fontweight='bold', color='darkred')
        elif val < 0:
            axes[2].text(j, i, 'G', ha='center', va='center', fontsize=12, fontweight='bold', color='darkblue')
        else:
            axes[2].text(j, i, '=', ha='center', va='center', fontsize=12, color='gray')

plt.suptitle('Primewise Birth Spectra: Same Global Birth Set, Different Prime Resolution',
             fontsize=13, fontweight='bold', y=1.02)

# Add global birth annotation
fig.text(0.5, -0.05,
         f'Global birth sets: F = {sorted(F.global_birth_set())}, G = {sorted(G.global_birth_set())} — IDENTICAL\n'
         f'But 2-torsion births differ: F₂ = {sorted(F.p_birth_set(2))}, G₂ = {sorted(G.p_birth_set(2))} — DIFFERENT',
         ha='center', fontsize=10, style='italic')

plt.tight_layout()
plt.savefig('primewise_spectra_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: primewise_spectra_heatmap.png")
