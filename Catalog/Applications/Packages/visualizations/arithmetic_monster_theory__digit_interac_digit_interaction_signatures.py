"""
Visualization: Digit Interaction Signatures Across Multiplications

This script visualizes how digit representations transform under multiplication,
showing the "preserved / created / destroyed" decomposition for products of
two-digit numbers. The heatmap reveals that vampire numbers (where all digits
are preserved) are rare islands of perfect conservation in a sea of digit chaos.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def digits_base10(n):
    """Return digits of n in base 10 (least significant first)."""
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_signature(v, x, y, base=10):
    """Compute preserved/created/destroyed counts."""
    bag_v = Counter(digits_base10(v))
    bag_xy = Counter(digits_base10(x)) + Counter(digits_base10(y))
    preserved = sum(min(bag_v.get(d, 0), bag_xy.get(d, 0)) for d in range(base))
    created = sum(max(0, bag_v.get(d, 0) - bag_xy.get(d, 0)) for d in range(base))
    destroyed = sum(max(0, bag_xy.get(d, 0) - bag_v.get(d, 0)) for d in range(base))
    return preserved, created, destroyed


# Compute digit interaction signatures for all 2-digit × 2-digit products
x_range = range(10, 100)
y_range = range(10, 100)

preserved_grid = np.zeros((90, 90))
created_grid = np.zeros((90, 90))
destroyed_grid = np.zeros((90, 90))
vampire_mask = np.zeros((90, 90), dtype=bool)

for i, x in enumerate(x_range):
    for j, y in enumerate(y_range):
        if y >= x:
            v = x * y
            p, c, d = digit_signature(v, x, y)
            preserved_grid[i, j] = p
            created_grid[i, j] = c
            destroyed_grid[i, j] = d
            if c == 0 and d == 0:
                vampire_mask[i, j] = True

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Preserved digits
im1 = axes[0].imshow(preserved_grid, cmap='YlGn', aspect='auto',
                      extent=[10, 99, 99, 10], interpolation='nearest')
axes[0].set_title('Preserved Digits', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Factor y')
axes[0].set_ylabel('Factor x')
plt.colorbar(im1, ax=axes[0], label='Count')

# Plot 2: Created digits (in product but not factors)
im2 = axes[1].imshow(created_grid, cmap='OrRd', aspect='auto',
                      extent=[10, 99, 99, 10], interpolation='nearest')
axes[1].set_title('Created Digits', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Factor y')
axes[1].set_ylabel('Factor x')
plt.colorbar(im2, ax=axes[1], label='Count')

# Plot 3: Destroyed digits (in factors but not product)
im3 = axes[2].imshow(destroyed_grid, cmap='PuBu', aspect='auto',
                      extent=[10, 99, 99, 10], interpolation='nearest')
axes[2].set_title('Destroyed Digits', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Factor y')
axes[2].set_ylabel('Factor x')
plt.colorbar(im3, ax=axes[2], label='Count')

# Mark vampire pairs on all plots
for ax in axes:
    vamp_x, vamp_y = np.where(vampire_mask)
    ax.scatter(vamp_y + 10, vamp_x + 10, c='red', s=50, marker='*',
              zorder=5, label='Vampire pairs')
    ax.legend(loc='upper right', fontsize=9)

plt.suptitle('Digit Interaction Signatures: How Multiplication Reshapes Digits',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_digit_signatures.png', dpi=150, bbox_inches='tight')
print("Saved viz_digit_signatures.png")
