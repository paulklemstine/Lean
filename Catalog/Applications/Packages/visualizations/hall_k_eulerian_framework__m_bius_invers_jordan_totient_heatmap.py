"""
Visualization 1: Jordan's Totient Heatmap J_k(n)

Displays a heatmap of J_k(n) / n^k (= generation probability P_k(Z/nZ))
for n = 2..40 and k = 1..10. Shows how generation probability increases
with k and varies with the prime factorization of n.

Key insight: Numbers with many small prime factors (like 30 = 2·3·5)
have lower generation probability, but converge to 1 as k increases.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import gcd


def jordan_totient(k, n):
    """Compute J_k(n) via Euler product."""
    result = n ** k
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            result = result * (d ** k - 1) // (d ** k)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        result = result * (temp ** k - 1) // (temp ** k)
    return result


# Parameters
n_range = range(2, 41)
k_range = range(1, 11)

# Compute P_k(Z/nZ) matrix
data = np.zeros((len(k_range), len(n_range)))
for i, k in enumerate(k_range):
    for j, n in enumerate(n_range):
        data[i, j] = jordan_totient(k, n) / n ** k

# Plot
fig, ax = plt.subplots(figsize=(14, 6))
im = ax.imshow(data, aspect='auto', cmap='RdYlGn', vmin=0, vmax=1,
               interpolation='nearest')

ax.set_xticks(range(0, len(n_range), 2))
ax.set_xticklabels([str(n) for n in n_range][::2], fontsize=8)
ax.set_yticks(range(len(k_range)))
ax.set_yticklabels([str(k) for k in k_range])

ax.set_xlabel('n (group order)', fontsize=12)
ax.set_ylabel('k (tuple size)', fontsize=12)
ax.set_title('Generation Probability P_k(Z/nZ) = J_k(n)/n^k\n'
             'Green = high probability, Red = low probability', fontsize=13)

cbar = plt.colorbar(im, ax=ax, label='P_k(Z/nZ)')

# Annotate key values
for i, k in enumerate(k_range):
    for j, n in enumerate(n_range):
        if data[i, j] < 0.5:
            ax.text(j, i, f'{data[i, j]:.2f}', ha='center', va='center',
                    fontsize=5, color='white')
        elif k <= 3 and n <= 15:
            ax.text(j, i, f'{data[i, j]:.2f}', ha='center', va='center',
                    fontsize=5, color='black')

plt.tight_layout()
plt.savefig('jordan_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved jordan_heatmap.png")
