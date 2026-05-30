"""
Visualization: Product Set Growth Sequences

Visualizes the growth dichotomy theorem: for generating sets in finite groups,
|A^k| increases strictly at every step until A^k = G. Different initial sets
show different growth rates but the same qualitative behavior.
"""

import matplotlib.pyplot as plt
import numpy as np


def product_set_cyclic(A, B, n):
    """Product set in Z/nZ."""
    return set((a + b) % n for a in A for b in B)


def growth_sequence(A, n, max_k=None):
    """Compute |A^k| for k = 0, 1, 2, ..."""
    if max_k is None:
        max_k = n
    sizes = [1]
    current = {0}
    for k in range(1, max_k + 1):
        current = product_set_cyclic(current, A, n)
        sizes.append(len(current))
        if len(current) == n:
            break
    return sizes


# Parameters
n = 60  # Z/60Z

configs = [
    ({0, 1, 59}, "A = {0, 1, -1}", "#2196F3"),
    ({0, 7, 53}, "A = {0, 7, -7}", "#FF5722"),
    ({0, 1, 7, 53, 59}, "A = {0, ±1, ±7}", "#4CAF50"),
    ({0, 12, 48}, "A = {0, 12, -12}", "#9C27B0"),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Growth sequences
ax = axes[0]
for A, label, color in configs:
    sizes = growth_sequence(A, n)
    steps = list(range(len(sizes)))
    ax.plot(steps, sizes, 'o-', label=label, color=color, markersize=4, linewidth=2)

ax.axhline(y=n, color='gray', linestyle='--', alpha=0.5, label=f'|G| = {n}')
ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^k|', fontsize=12)
ax.set_title(f'Growth Dichotomy in Z/{n}Z', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Growth ratios
ax = axes[1]
for A, label, color in configs:
    sizes = growth_sequence(A, n)
    ratios = [sizes[k+1]/sizes[k] if sizes[k] > 0 else 0 
              for k in range(len(sizes)-1)]
    steps = list(range(1, len(ratios)+1))
    ax.plot(steps, ratios, 's-', label=label, color=color, markersize=4, linewidth=2)

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='No growth (ratio=1)')
ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^{k+1}|/|A^k|', fontsize=12)
ax.set_title('Growth Ratios (must be > 1 until saturation)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.8, 4)

plt.tight_layout()
plt.savefig('growth_sequences.png', dpi=150, bbox_inches='tight')
print("Saved growth_sequences.png")
