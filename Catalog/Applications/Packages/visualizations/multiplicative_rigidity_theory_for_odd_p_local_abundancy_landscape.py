#!/usr/bin/env python3
"""
Visualization: Local Abundancy Landscape
=========================================

This heatmap shows the local abundancy factor I(p, a) = σ(p^a)/p^a
for various primes p and exponents a. The color intensity reveals
how each factor approaches its geometric limit p/(p-1) as the
exponent grows.

Key observations visible in this plot:
- Small primes (3, 5, 7) contribute much more than large primes
- All factors are strictly between 1 and p/(p-1)
- The factors converge rapidly for large p
- Perfect numbers require these factors to multiply to exactly 2
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from fractions import Fraction


def sigma_prime_pow(p, a):
    if a == 0:
        return 1
    return (p ** (a + 1) - 1) // (p - 1)


def local_abundancy(p, a):
    return Fraction(sigma_prime_pow(p, a), p ** a)


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


primes = [p for p in range(3, 50, 2) if is_prime(p)][:12]
max_exp = 12

# Compute the abundancy matrix
Z = np.zeros((len(primes), max_exp))
for i, p in enumerate(primes):
    for a in range(1, max_exp + 1):
        Z[i, a-1] = float(local_abundancy(p, a))

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Heatmap of I(p, a)
ax = axes[0]
im = ax.imshow(Z, aspect='auto', cmap='YlOrRd', vmin=1.0,
               interpolation='nearest')
ax.set_xticks(range(max_exp))
ax.set_xticklabels(range(1, max_exp + 1))
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([str(p) for p in primes])
ax.set_xlabel('Exponent a', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('Local Abundancy I(p, a)', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='I(p, a)')

# Annotate a few values
for i in range(min(5, len(primes))):
    for a in range(min(4, max_exp)):
        val = Z[i, a]
        ax.text(a, i, f'{val:.3f}', ha='center', va='center', fontsize=6,
                color='white' if val > 1.3 else 'black')

# Line plot: convergence to limit
ax2 = axes[1]
for i, p in enumerate(primes[:6]):
    exponents = list(range(0, max_exp + 1))
    values = [float(local_abundancy(p, a)) for a in exponents]
    limit = float(Fraction(p, p - 1))
    ax2.plot(exponents, values, 'o-', label=f'p={p}', markersize=4, linewidth=1.5)
    ax2.axhline(y=limit, color=ax2.get_lines()[-1].get_color(),
                linestyle=':', alpha=0.3, linewidth=1)

ax2.set_xlabel('Exponent a', fontsize=12)
ax2.set_ylabel('I(p, a)', fontsize=12)
ax2.set_title('Convergence to Geometric Limit\np/(p-1)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='lower right')
ax2.set_ylim(0.95, 1.6)

# Gap from limit: p/(p-1) - I(p,a)
ax3 = axes[2]
for i, p in enumerate(primes[:6]):
    exponents = list(range(1, max_exp + 1))
    limit = Fraction(p, p - 1)
    gaps = [float(limit - local_abundancy(p, a)) for a in exponents]
    ax3.semilogy(exponents, gaps, 'o-', label=f'p={p}', markersize=4, linewidth=1.5)

ax3.set_xlabel('Exponent a', fontsize=12)
ax3.set_ylabel('Gap: p/(p-1) - I(p, a)', fontsize=12)
ax3.set_title('Exponential Convergence Rate\n(log scale)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_abundancy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_abundancy_landscape.png")
