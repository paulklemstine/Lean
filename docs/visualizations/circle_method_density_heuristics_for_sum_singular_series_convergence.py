#!/usr/bin/env python3
"""
Visualization 2: Convergence of the Truncated Singular Series

Plots the truncated singular series S^sf_{≤P}(k) = ∏_{p≤P} δ_k(p)
as a function of the prime cutoff P for several admissible values of k.

This shows how the Euler product proxy stabilizes, providing computational
evidence for the conjecture that the full singular series converges
to a positive constant for each admissible k.
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


primes = sieve_primes(23)
admissible_k = [0, 1, 2, 3, 6, 7, 8, 9]
colors = plt.cm.tab10(np.linspace(0, 1, len(admissible_k)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: absolute values
for idx, k in enumerate(admissible_k):
    series_values = []
    product = 1.0
    for p in primes:
        product *= local_density(k, p)
        series_values.append(product)
    ax1.plot(range(1, len(primes) + 1), series_values, 'o-',
             color=colors[idx], label=f'k = {k}', markersize=4, linewidth=1.5)

ax1.set_xlabel('Number of prime factors included', fontsize=12)
ax1.set_ylabel('S^sf_{≤P}(k)', fontsize=12)
ax1.set_title('Truncated Singular Series\n(Absolute Values)', fontsize=13)
ax1.legend(loc='best', fontsize=9)
ax1.set_xticks(range(1, len(primes) + 1))
ax1.set_xticklabels([str(p) for p in primes], fontsize=8)
ax1.grid(True, alpha=0.3)

# Right panel: ratio to k=0 baseline (relative comparison)
baseline = []
product = 1.0
for p in primes:
    product *= local_density(0, p)
    baseline.append(product)

for idx, k in enumerate(admissible_k):
    if k == 0:
        continue
    series_values = []
    product = 1.0
    for i, p in enumerate(primes):
        product *= local_density(k, p)
        series_values.append(product / baseline[i] if baseline[i] > 0 else 0)
    ax2.plot(range(1, len(primes) + 1), series_values, 'o-',
             color=colors[idx], label=f'k = {k}', markersize=4, linewidth=1.5)

ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='k=0 baseline')
ax2.set_xlabel('Number of prime factors included', fontsize=12)
ax2.set_ylabel('S^sf(k) / S^sf(0)', fontsize=12)
ax2.set_title('Relative Singular Series\n(Normalized to k=0)', fontsize=13)
ax2.legend(loc='best', fontsize=9)
ax2.set_xticks(range(1, len(primes) + 1))
ax2.set_xticklabels([str(p) for p in primes], fontsize=8)
ax2.grid(True, alpha=0.3)

plt.suptitle('Convergence of the Euler Product Proxy for x³ + y³ + z³ = k',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_singular_series_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_singular_series_convergence.png")
