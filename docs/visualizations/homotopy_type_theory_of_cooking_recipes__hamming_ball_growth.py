"""
Visualization 3: Hamming Ball Growth
=====================================
Shows how the size of Hamming balls grows with radius for different
recipe space parameters. Connects to sphere-packing bounds in coding theory.
The Hamming ball B(center, r) contains all recipes reachable by at most
r single-ingredient substitutions.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def hamming_ball_size_exact(n, m, r):
    """Exact size of Hamming ball B(center, r) in H(n,m)."""
    total = 0
    for k in range(min(r, n) + 1):
        total += comb(n, k) * (m - 1) ** k
    return total

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: Ball size vs radius for different (n, m)
ax = axes[0]
configs = [
    (5, 2, 'Binary (m=2), n=5', 'o-'),
    (5, 3, 'Ternary (m=3), n=5', 's-'),
    (5, 4, 'Quaternary (m=4), n=5', '^-'),
    (8, 2, 'Binary (m=2), n=8', 'D--'),
    (8, 3, 'Ternary (m=3), n=8', 'v--'),
]

for n, m, label, fmt in configs:
    radii = list(range(n + 1))
    sizes = [hamming_ball_size_exact(n, m, r) for r in radii]
    total = m ** n
    fractions = [s / total for s in sizes]
    ax.plot(radii, fractions, fmt, label=label, linewidth=2, markersize=6)

ax.set_xlabel('Hamming Ball Radius r', fontsize=12)
ax.set_ylabel('Fraction of Recipe Space Covered', fontsize=12)
ax.set_title('Hamming Ball Growth\n'
             '(fraction of all recipes within r substitutions)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Right plot: Ball size (absolute) for n=6, m=3
ax2 = axes[1]
n, m = 6, 3
radii = list(range(n + 1))
sizes = [hamming_ball_size_exact(n, m, r) for r in radii]

bars = ax2.bar(radii, sizes, color='coral', edgecolor='black', alpha=0.8)
ax2.axhline(y=m**n, color='red', linestyle='--', linewidth=2,
            label=f'Total space = {m}^{n} = {m**n}')

# Annotate bars
for i, (r_val, s) in enumerate(zip(radii, sizes)):
    ax2.text(r_val, s + m**n * 0.02, str(s), ha='center', fontsize=9, fontweight='bold')

ax2.set_xlabel('Hamming Ball Radius r', fontsize=12)
ax2.set_ylabel('Number of Recipes in Ball', fontsize=12)
ax2.set_title(f'Hamming Ball Sizes for H({n},{m})\n'
              f'n={n} slots, m={m} choices/slot, {m**n} total recipes', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle('Coding Theory Meets Cooking: Hamming Ball Structure',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hamming_balls.png', dpi=150, bbox_inches='tight')
print("Saved viz_hamming_balls.png")
