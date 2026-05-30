"""
Visualization: Torsion Sensitivity Heatmap

Displays a heatmap of the sensitivity index (number of distinct p-adic
valuations) across different group orders and prime sets. Highlights
the boundary between universal and non-universal torsion behavior.

The x-axis represents group orders (integers from 2 to N), and each row
represents a different prime used for the p-adic valuation. The color
intensity shows the valuation value, making it visually apparent where
different primes "see" the same vs. different structure in a number.
"""

import numpy as np
import matplotlib.pyplot as plt


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def sensitivity_index(n: int, primes: list) -> int:
    """Number of distinct p-adic valuations across primes."""
    return len(set(padic_val(p, n) for p in primes))


# Parameters
N = 120
primes = [2, 3, 5, 7, 11]
orders = list(range(2, N + 1))

# Build valuation matrix
val_matrix = np.zeros((len(primes), len(orders)))
for i, p in enumerate(primes):
    for j, n in enumerate(orders):
        val_matrix[i, j] = padic_val(p, n)

# Compute sensitivity indices
si_values = [sensitivity_index(n, primes) for n in orders]

# Create figure
fig, axes = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [3, 1]})

# Heatmap of valuations
im = axes[0].imshow(val_matrix, aspect='auto', cmap='YlOrRd',
                     extent=[2, N, len(primes) - 0.5, -0.5])
axes[0].set_yticks(range(len(primes)))
axes[0].set_yticklabels([f'v_{p}' for p in primes])
axes[0].set_xlabel('Group Order n')
axes[0].set_title('p-adic Valuation Profiles: The Arithmetic Fingerprint of Torsion',
                   fontsize=13, fontweight='bold')
plt.colorbar(im, ax=axes[0], label='Valuation v_p(n)')

# Highlight prime powers with markers
for n in orders:
    # Check if prime power
    is_pp = False
    for p in range(2, n + 1):
        if p > int(n**0.5) + 1 and n > 1:
            # n itself is prime
            is_pp = True
            break
        k = 0
        m = n
        while m % p == 0:
            m //= p
            k += 1
        if m == 1 and k >= 1:
            is_pp = True
            break
    if is_pp and n <= 50:
        axes[0].axvline(x=n, color='cyan', alpha=0.15, linewidth=1)

# Sensitivity index bar chart
colors = ['#2ecc71' if s == 1 else '#e74c3c' if s >= 3 else '#f39c12'
          for s in si_values]
axes[1].bar(orders, si_values, color=colors, width=1.0, edgecolor='none')
axes[1].set_xlabel('Group Order n')
axes[1].set_ylabel('Sensitivity\nIndex')
axes[1].set_title('Torsion Sensitivity Index (1 = universal, >1 = prime-dependent)',
                   fontsize=11)
axes[1].set_xlim(2, N)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', label='SI = 1 (Universal)'),
    Patch(facecolor='#f39c12', label='SI = 2'),
    Patch(facecolor='#e74c3c', label='SI ≥ 3 (Highly sensitive)'),
]
axes[1].legend(handles=legend_elements, loc='upper right', fontsize=8)

plt.tight_layout()
plt.savefig('viz_sensitivity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_sensitivity_heatmap.png")
