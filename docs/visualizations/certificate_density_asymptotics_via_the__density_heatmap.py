#!/usr/bin/env python3
"""
Visualization: Certificate Density Heatmap

Heatmap of I(q,n)/q^n across different (q, n) values,
showing how the density approaches 1/n uniformly.
The color represents the ratio δ_n(q) / (1/n) = n · I(q,n) / q^n,
which converges to 1.
"""

import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = []
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n):
    divs = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
        d += 1
    return sorted(divs)


def necklace_count(q, n):
    return sum(moebius(n // d) * q**d for d in divisors(n)) / n


# Compute the ratio n * I(q,n) / q^n for each (q, n)
q_values = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31, 37, 41, 43, 47]
n_values = list(range(2, 13))

data = np.zeros((len(n_values), len(q_values)))
for i, n in enumerate(n_values):
    for j, q in enumerate(q_values):
        data[i, j] = n * necklace_count(q, n) / q**n

fig, ax = plt.subplots(figsize=(12, 6))

im = ax.imshow(data, aspect='auto', cmap='RdYlGn',
               vmin=0.5, vmax=1.05,
               interpolation='nearest')

ax.set_xticks(range(len(q_values)))
ax.set_xticklabels(q_values, fontsize=8)
ax.set_yticks(range(len(n_values)))
ax.set_yticklabels(n_values, fontsize=10)

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Degree n', fontsize=12)
ax.set_title('Certificate Density Ratio: n · I(q,n) / q^n → 1', fontsize=13)

# Add text annotations
for i in range(len(n_values)):
    for j in range(len(q_values)):
        val = data[i, j]
        color = 'white' if val < 0.7 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=6, color=color)

plt.colorbar(im, ax=ax, label='n · I(q,n) / q^n', shrink=0.8)
plt.tight_layout()
plt.savefig('density_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved density_heatmap.png")
