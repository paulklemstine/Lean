"""
Visualization: Irreducible Polynomial Rate Heatmap

This heatmap shows the theoretical irreducible rate N(q,n)/q^n for monic
degree-n polynomials over GF(q), across different dimensions n and field
sizes q. The rates encode a "spectral fingerprint" that uniquely identifies
the ambient field — the mathematical foundation for black-box group recognition.

Brighter cells indicate higher irreducible rates. Note how the rate
decreases with n (≈1/n asymptotically) and increases with q, creating
a distinctive pattern that separates different parameter pairs.
"""

import matplotlib.pyplot as plt
import numpy as np


def mobius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            temp //= d
            if temp % d == 0:
                return 0
            factors += 1
        d += 1
    if temp > 1:
        factors += 1
    return (-1) ** factors


def divisors(n):
    divs = []
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def num_irreducible_monic(q, n):
    if n <= 0 or q <= 0:
        return 0
    total = sum(mobius(n // d) * q**d for d in divisors(n))
    return total // n


def irreducible_rate(q, n):
    if q <= 0 or n <= 0:
        return 0.0
    return num_irreducible_monic(q, n) / q**n


# Parameters
ns = list(range(1, 11))
qs = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31]

# Compute rates
data = np.zeros((len(ns), len(qs)))
for i, n in enumerate(ns):
    for j, q in enumerate(qs):
        data[i, j] = irreducible_rate(q, n)

# Plot
fig, ax = plt.subplots(figsize=(14, 7))
im = ax.imshow(data, aspect='auto', cmap='viridis', interpolation='nearest')

ax.set_xticks(range(len(qs)))
ax.set_xticklabels([str(q) for q in qs], fontsize=9)
ax.set_yticks(range(len(ns)))
ax.set_yticklabels([str(n) for n in ns], fontsize=10)
ax.set_xlabel('Field size q', fontsize=13)
ax.set_ylabel('Polynomial degree n', fontsize=13)
ax.set_title('Irreducible Polynomial Rate: The Spectral Fingerprint of Finite Fields',
             fontsize=14, fontweight='bold')

# Add text annotations
for i in range(len(ns)):
    for j in range(len(qs)):
        val = data[i, j]
        color = 'white' if val < 0.3 else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                fontsize=7, color=color)

cbar = plt.colorbar(im, ax=ax, label='Irreducible rate N(q,n)/q^n')

# Add 1/n reference line annotation
for i, n in enumerate(ns):
    ref = 1.0 / n
    ax.annotate(f'1/{n}={ref:.2f}', xy=(len(qs)-0.3, i),
                fontsize=7, color='red', ha='left', va='center')

plt.tight_layout()
plt.savefig('viz_rate_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_rate_heatmap.png")
