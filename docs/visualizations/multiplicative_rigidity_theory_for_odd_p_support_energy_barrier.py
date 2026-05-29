#!/usr/bin/env python3
"""
Visualization: Support Energy Barrier for Odd Perfect Numbers
=============================================================

This plot shows how the support energy ∏ p/(p-1) grows as we add
consecutive odd primes. The horizontal line at y=2 is the critical
threshold: only supports with energy ≥ 2 can potentially support
an odd perfect number.

The key insight is that the energy grows slowly—it takes at least 3
consecutive odd primes to cross the barrier, and larger primes
contribute progressively less energy.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from fractions import Fraction


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def odd_primes_up_to(n):
    return [p for p in range(3, n + 1, 2) if is_prime(p)]


primes = odd_primes_up_to(100)
energies = []
energy = Fraction(1)
for p in primes:
    energy *= Fraction(p, p - 1)
    energies.append(float(energy))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: cumulative energy
x = list(range(1, len(energies) + 1))
colors = ['#e74c3c' if e < 2 else '#2ecc71' for e in energies]
ax1.bar(x, energies, color=colors, alpha=0.7, edgecolor='white', linewidth=0.5)
ax1.axhline(y=2, color='#3498db', linewidth=2, linestyle='--', label='Critical threshold (y=2)')
ax1.set_xlabel('Number of consecutive odd primes', fontsize=12)
ax1.set_ylabel('Support energy ∏ p/(p-1)', fontsize=12)
ax1.set_title('Support Energy Barrier\nfor Odd Perfect Numbers', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)

# Annotate key points
ax1.annotate(f'1 prime: {energies[0]:.3f}', xy=(1, energies[0]),
            xytext=(3, energies[0] - 0.2), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='gray'))
ax1.annotate(f'2 primes: {energies[1]:.3f}', xy=(2, energies[1]),
            xytext=(4, energies[1] - 0.15), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='gray'))

# Find crossing point
crossing = next(i for i, e in enumerate(energies) if e >= 2)
ax1.annotate(f'{crossing+1} primes: crosses 2!', xy=(crossing+1, energies[crossing]),
            xytext=(crossing+3, 1.5), fontsize=9, color='#e74c3c',
            arrowprops=dict(arrowstyle='->', color='#e74c3c'))

ax1.set_xlim(0.5, min(15, len(energies)) + 0.5)
ax1.set_ylim(0, max(energies[:15]) * 1.1)

# Right: individual contributions p/(p-1)
contributions = [Fraction(p, p-1) for p in primes[:20]]
contrib_float = [float(c) for c in contributions]
ax2.bar(range(1, 21), contrib_float, color='#9b59b6', alpha=0.7, edgecolor='white')
ax2.set_xlabel('Prime index (1=3, 2=5, 3=7, ...)', fontsize=12)
ax2.set_ylabel('Individual factor p/(p-1)', fontsize=12)
ax2.set_title('Individual Prime Contributions\n(decreasing toward 1)', fontsize=14, fontweight='bold')

# Annotate with prime values
for i in range(min(8, len(primes))):
    ax2.annotate(f'p={primes[i]}', xy=(i+1, contrib_float[i]),
                xytext=(i+1, contrib_float[i] + 0.02), fontsize=7,
                ha='center', rotation=45)

ax2.axhline(y=1, color='gray', linewidth=1, linestyle=':', alpha=0.5, label='Limit as p→∞')
ax2.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_energy_barrier.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_barrier.png")
