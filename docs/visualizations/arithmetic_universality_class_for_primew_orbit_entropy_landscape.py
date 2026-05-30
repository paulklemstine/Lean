"""
Visualization 1: Orbit Entropy Landscape

Visualizes the orbit entropy of quadratic maps x² + c mod p across
a grid of (c, p) values. Shows how entropy varies with the map parameter
and prime, revealing the structure of the "entropy landscape" on moduli space.

The proven theorem (orbit_entropy_nonneg) guarantees all values are ≥ 0.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def preimage_sizes_fast(coeffs, p):
    """Compute preimage sizes for polynomial mod p."""
    n = p + 1
    counts = [0] * n
    for x in range(n):
        counts[mod_p_poly(coeffs, p, x)] += 1
    return counts


def orbit_entropy(coeffs, p):
    """Compute orbit entropy for polynomial mod p."""
    n = p + 1
    sizes = preimage_sizes_fast(coeffs, p)
    if n == 0:
        return 0.0
    return math.log(n) - sum(math.log(s + 1) for s in sizes) / n


# Parameters
c_values = list(range(-20, 21))
primes = [p for p in range(3, 100) if all(p % i != 0 for i in range(2, int(p**0.5) + 1))]

# Compute entropy grid
entropy_grid = np.zeros((len(c_values), len(primes)))
for i, c in enumerate(c_values):
    for j, p in enumerate(primes):
        entropy_grid[i, j] = orbit_entropy([c, 0, 1], p)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(entropy_grid, aspect='auto', cmap='viridis',
                extent=[primes[0], primes[-1], c_values[-1], c_values[0]],
                interpolation='nearest')
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Parameter c', fontsize=12)
ax1.set_title('Orbit Entropy H(x² + c, p)', fontsize=14)
plt.colorbar(im, ax=ax1, label='Entropy')

# Entropy vs prime for selected c values
ax2 = axes[1]
for c in [-2, -1, 0, 1, 2, 5]:
    entropies = [orbit_entropy([c, 0, 1], p) for p in primes]
    ax2.plot(primes, entropies, 'o-', markersize=3, label=f'c={c}', alpha=0.7)

ax2.axhline(y=math.log(2), color='red', linestyle='--', alpha=0.5, label='log(2)')
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('Orbit Entropy', fontsize=12)
ax2.set_title('Entropy Convergence (proven ≥ 0)', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_landscape.png")
