"""
Visualization 2: Degree Sequence Separation

Visualizes how degree sequences (sorted preimage size vectors) separate
non-conjugate quadratic maps. Shows the conjugacy invariance theorem
in action: conjugate maps have identical degree sequences, while
non-conjugate maps are separated at most primes.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def degree_sequence(coeffs, p):
    """Compute sorted degree sequence for polynomial mod p."""
    n = p + 1
    counts = [0] * n
    for x in range(n):
        counts[mod_p_poly(coeffs, p, x)] += 1
    return tuple(sorted(counts))


def sieve_primes(n):
    """Simple sieve of Eratosthenes."""
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Parameters
c_values = list(range(-5, 11))
primes = sieve_primes(60)

# Compute separation matrix
n_maps = len(c_values)
separation_matrix = np.zeros((n_maps, n_maps))

for i in range(n_maps):
    for j in range(i + 1, n_maps):
        separating_primes = 0
        for p in primes:
            ds_i = degree_sequence([c_values[i], 0, 1], p)
            ds_j = degree_sequence([c_values[j], 0, 1], p)
            if ds_i != ds_j:
                separating_primes += 1
        frac = separating_primes / len(primes)
        separation_matrix[i, j] = frac
        separation_matrix[j, i] = frac

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Separation heatmap
ax1 = axes[0]
im = ax1.imshow(separation_matrix, cmap='RdYlGn', vmin=0, vmax=1)
ax1.set_xticks(range(n_maps))
ax1.set_xticklabels([str(c) for c in c_values], fontsize=8, rotation=45)
ax1.set_yticks(range(n_maps))
ax1.set_yticklabels([str(c) for c in c_values], fontsize=8)
ax1.set_xlabel('Parameter c₂', fontsize=12)
ax1.set_ylabel('Parameter c₁', fontsize=12)
ax1.set_title('Fraction of Primes Separating x²+c₁ from x²+c₂', fontsize=13)
plt.colorbar(im, ax=ax1, label='Separation fraction')

# Degree sequence diversity across primes
ax2 = axes[1]
for c in [-2, 0, 1, 3, 7]:
    diversity = []
    for p in primes:
        ds = degree_sequence([c, 0, 1], p)
        # Count distinct preimage sizes
        diversity.append(len(set(ds)))
    ax2.plot(primes, diversity, 'o-', markersize=4, label=f'c={c}', alpha=0.8)

ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('# Distinct Preimage Sizes', fontsize=12)
ax2.set_title('Degree Sequence Complexity', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_degree_sequences.png', dpi=150, bbox_inches='tight')
print("Saved viz_degree_sequences.png")
