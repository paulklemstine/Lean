"""
Visualization 3: Quadratic Residue Pattern — Why No Prime ≤ 40 Divides n² + n + 41
====================================================================================
Shows the residues of n² + n + 41 mod p for each prime p ≤ 40.
The key theorem: zero never appears, which is why the polynomial generates primes.
"""

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


primes = [p for p in range(2, 41) if is_prime(p)]

fig, ax = plt.subplots(figsize=(14, 8))

# For each prime p, compute the set of residues of n² + n + 41 mod p
data = []
for idx, p in enumerate(primes):
    residues = set()
    for n in range(p):
        r = (n * n + n + 41) % p
        residues.add(r)
    # Plot each residue as a dot
    for r in range(p):
        if r in residues:
            color = '#2196F3'  # blue = achieved residue
            marker = 'o'
            size = 40
        else:
            color = '#FFCDD2'  # light red = missing residue
            marker = 's'
            size = 20
        ax.scatter(r, idx, c=color, s=size, marker=marker, edgecolors='none', zorder=3)

    # Highlight zero specifically
    if 0 in residues:
        ax.scatter(0, idx, c='#F44336', s=120, marker='X', zorder=5)
    else:
        ax.scatter(0, idx, c='#4CAF50', s=80, marker='D', edgecolors='#2E7D32',
                  linewidth=1.5, zorder=5)

    data.append((p, residues))

ax.set_yticks(range(len(primes)))
ax.set_yticklabels([f'p = {p}' for p in primes], fontsize=11)
ax.set_xlabel('Residue mod p', fontsize=13)
ax.set_title('Residues of n² + n + 41 (mod p) for Each Prime p ≤ 40\n'
             'Green diamond at 0 = zero is NEVER achieved (our theorem!)',
             fontsize=14, fontweight='bold')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3', markersize=8, label='Achieved residue'),
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#FFCDD2', markersize=6, label='Missing residue'),
    Line2D([0], [0], marker='D', color='w', markerfacecolor='#4CAF50', markeredgecolor='#2E7D32',
           markersize=8, label='Zero NOT achieved ✓'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

ax.set_xlim(-0.5, 40)
ax.grid(True, alpha=0.15, axis='x')
ax.invert_yaxis()

plt.tight_layout()
plt.savefig('viz_residue_pattern.png', dpi=150, bbox_inches='tight')
print("Saved viz_residue_pattern.png")
