"""
Visualization: Torsion Persistence Spectrum Heatmap

Visualizes the TPS(p) values across different group orders m and primes p,
showing how torsion persistence varies with algebraic structure.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_factors(n):
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


def compute_tps(m, endos, p):
    """Compute TPS at prime p for ℤ/mℤ with given endomorphisms."""
    n = len(endos)
    max_persistence = 0
    for a in range(1, m):
        # Check p-torsion
        pk = p
        is_pt = False
        while pk <= m * m:
            if (pk * a) % m == 0:
                is_pt = True
                break
            pk *= p
        if not is_pt:
            continue
        # Track persistence
        x = a
        steps = 0
        for i in range(n):
            x = (endos[i] * x) % m
            if x == 0:
                break
            steps = i + 1
        max_persistence = max(max_persistence, steps)
    return max_persistence


# Compute TPS heatmap for multiplication-by-2 endomorphism
group_orders = list(range(2, 61))
all_primes = sieve_primes(60)

# Create heatmap data
heatmap = np.full((len(group_orders), len(all_primes)), np.nan)

for i, m in enumerate(group_orders):
    pf = prime_factors(m)
    endos = [2, 2]  # multiplication by 2, twice
    for j, p in enumerate(all_primes):
        if p in pf:
            heatmap[i, j] = compute_tps(m, endos, p)

fig, ax = plt.subplots(1, 1, figsize=(14, 10))

# Plot heatmap
im = ax.imshow(heatmap, aspect='auto', cmap='YlOrRd',
               interpolation='nearest', origin='lower')
ax.set_xlabel('Prime p', fontsize=14)
ax.set_ylabel('Group order m', fontsize=14)
ax.set_title('Torsion Persistence Spectrum: TPS(p) for ℤ/mℤ with ×2 endomorphism',
             fontsize=16)

# Set tick labels
ax.set_xticks(range(len(all_primes)))
ax.set_xticklabels([str(p) for p in all_primes], fontsize=9)
ytick_positions = list(range(0, len(group_orders), 5))
ax.set_yticks(ytick_positions)
ax.set_yticklabels([str(group_orders[i]) for i in ytick_positions], fontsize=10)

plt.colorbar(im, ax=ax, label='TPS(p)', shrink=0.8)

# Add annotation
ax.text(0.02, 0.98,
        'White = prime does not divide m\nDarker = longer torsion persistence',
        transform=ax.transAxes, fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('tps_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved tps_heatmap.png")
