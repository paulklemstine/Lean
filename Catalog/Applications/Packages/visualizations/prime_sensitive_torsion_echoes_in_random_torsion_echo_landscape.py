"""
Visualization: Torsion Echo Landscape

A 3D-style surface plot showing how the p-adic valuation landscape changes
across different primes and group orders. Each "ridge" in the landscape
corresponds to multiples of a prime power, creating a characteristic
pattern unique to each prime — the "echo" of that prime in the torsion
structure.

This visualization makes tangible the key insight: the landscape of
v_p(n) is qualitatively different for different primes p.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


# Parameters
N = 200
primes = [2, 3, 5, 7, 11, 13]
orders = np.arange(1, N + 1)

fig, axes = plt.subplots(3, 2, figsize=(14, 10))
fig.suptitle('Torsion Echo Landscapes: Each Prime Leaves a Unique Fingerprint',
             fontsize=14, fontweight='bold')

for idx, p in enumerate(primes):
    ax = axes[idx // 2, idx % 2]
    vals = [padic_val(p, int(n)) for n in orders]

    # Create colored bar plot
    colors_map = {0: '#e8e8e8', 1: '#3498db', 2: '#2ecc71',
                  3: '#e67e22', 4: '#e74c3c', 5: '#9b59b6'}
    colors = [colors_map.get(v, '#2c3e50') for v in vals]

    ax.bar(orders, vals, color=colors, width=1.0, edgecolor='none')
    ax.set_title(f'v_{p}(n): Echo of prime {p}', fontsize=11, fontweight='bold')
    ax.set_xlabel('n')
    ax.set_ylabel(f'v_{p}(n)')
    ax.set_xlim(0, N)

    # Annotate key features
    max_val = max(vals)
    if max_val > 0:
        max_idx = vals.index(max_val)
        ax.annotate(f'v_{p}({orders[max_idx]})={max_val}',
                    xy=(orders[max_idx], max_val),
                    xytext=(orders[max_idx] + 15, max_val),
                    fontsize=8, color='red',
                    arrowprops=dict(arrowstyle='->', color='red', lw=0.8))

    # Show periodicity: mark multiples of p
    for mult in range(p, N + 1, p):
        ax.axvline(x=mult, color='gray', alpha=0.05, linewidth=0.5)

plt.tight_layout()
plt.savefig('viz_echo_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_echo_landscape.png")
