#!/usr/bin/env python3
"""
Visualization 1: Heatmap of Local Densities δ_k(p)

Shows the local density δ_k(p) = #Sol(p)/p² for each integer k (rows)
and prime p (columns). Highlights the mod 9 obstruction (k ≡ 4,5 mod 9
have zero density at p=3) and the variation in density across residue classes.

This visualization makes tangible the "landscape" of local factors that
feed into the singular series Euler product.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def three_cube_residue_count(k, n):
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def local_density(k, n):
    return three_cube_residue_count(k, n) / n**2


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


primes = sieve_primes(19)
k_values = list(range(20))

# Compute density matrix
data = np.zeros((len(k_values), len(primes)))
for i, k in enumerate(k_values):
    for j, p in enumerate(primes):
        data[i, j] = local_density(k, p)

fig, ax = plt.subplots(figsize=(10, 8))
im = ax.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes])
ax.set_yticks(range(len(k_values)))
ax.set_yticklabels([str(k) for k in k_values])

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Target integer k', fontsize=12)
ax.set_title('Local Density δ_k(p) = #Sol(p) / p²\n'
             'Heatmap of Circle Method Local Factors', fontsize=14)

# Mark obstructed residues
for i, k in enumerate(k_values):
    if k % 9 in (4, 5):
        ax.text(-0.7, i, '✗', fontsize=10, color='red', fontweight='bold',
                ha='center', va='center')

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Local density δ_k(p)', fontsize=11)

# Annotate cells with values
for i in range(len(k_values)):
    for j in range(len(primes)):
        val = data[i, j]
        color = 'white' if val > 1.5 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=7, color=color)

plt.tight_layout()
plt.savefig('viz_local_density_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_local_density_heatmap.png")
