"""
Visualization: Pythagorean Digit Sum Obstruction

This script visualizes the mod-9 constraints on Pythagorean triples arising
from digit sum analysis. For every triple (a, b, c) with a² + b² = c²,
we plot digitSum(a)² + digitSum(b)² mod 9 vs digitSum(c)² mod 9,
showing they always agree — a beautiful cross-domain connection between
number theory and digit structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def digit_sum(n, base=10):
    """Sum of digits of n in given base."""
    s = 0
    while n > 0:
        s += n % base
        n //= base
    return s


# Find Pythagorean triples up to c = 500
triples = []
for a in range(1, 400):
    for b in range(a, 400):
        c_sq = a*a + b*b
        c = int(c_sq**0.5)
        if c*c == c_sq and c <= 500:
            triples.append((a, b, c))

# Compute digit sum residues
lhs_vals = []  # (digitSum(a)^2 + digitSum(b)^2) mod 9
rhs_vals = []  # digitSum(c)^2 mod 9
ds_a_list = []
ds_b_list = []

for a, b, c in triples:
    ds_a = digit_sum(a) % 9
    ds_b = digit_sum(b) % 9
    ds_c = digit_sum(c) % 9
    lhs = (ds_a**2 + ds_b**2) % 9
    rhs = (ds_c**2) % 9
    lhs_vals.append(lhs)
    rhs_vals.append(rhs)
    ds_a_list.append(ds_a)
    ds_b_list.append(ds_b)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Scatter of LHS vs RHS (should all lie on y=x)
ax1 = axes[0]
jitter = np.random.uniform(-0.15, 0.15, len(lhs_vals))
ax1.scatter(np.array(lhs_vals) + jitter, np.array(rhs_vals) + jitter,
            alpha=0.3, s=15, c='steelblue')
ax1.plot([0, 8], [0, 8], 'r-', linewidth=2, label='y = x (theorem)')
ax1.set_xlabel('(digitSum(a)² + digitSum(b)²) mod 9', fontsize=12)
ax1.set_ylabel('digitSum(c)² mod 9', fontsize=12)
ax1.set_title('Pythagorean Digit Sum Obstruction\n(all points on diagonal)',
              fontsize=13, fontweight='bold')
ax1.set_xticks(range(9))
ax1.set_yticks(range(9))
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Heatmap of (digitSum(a) mod 9, digitSum(b) mod 9) distribution
ax2 = axes[1]
grid = np.zeros((9, 9))
for da, db in zip(ds_a_list, ds_b_list):
    grid[da, db] += 1

im = ax2.imshow(grid, cmap='viridis', interpolation='nearest')
ax2.set_xlabel('digitSum(b) mod 9', fontsize=12)
ax2.set_ylabel('digitSum(a) mod 9', fontsize=12)
ax2.set_title('Distribution of Digit Sum Residues\nin Pythagorean Triples',
              fontsize=13, fontweight='bold')
ax2.set_xticks(range(9))
ax2.set_yticks(range(9))
plt.colorbar(im, ax=ax2, label='Count')

plt.suptitle(f'Pythagorean Triples (n = {len(triples)}, c ≤ 500)',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_pythagorean_digits.png', dpi=150, bbox_inches='tight')
print(f"Saved viz_pythagorean_digits.png ({len(triples)} triples)")
