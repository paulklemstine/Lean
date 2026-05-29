#!/usr/bin/env python3
"""
Visualization: Modular Sieve Effectiveness

Shows how the mod-(b-1) congruence sieve eliminates candidate factor pairs
for vampire numbers. Plots the admissible residue classes and sieve
effectiveness across different bases.
"""

import matplotlib.pyplot as plt
import numpy as np


def mod_sieve_effectiveness(b):
    """Fraction of residue pairs (rx, ry) mod (b-1) that pass the sieve."""
    m = b - 1
    if m == 0:
        return 1.0
    admissible = 0
    total = m * m
    for rx in range(m):
        for ry in range(m):
            if (rx * ry) % m == (rx + ry) % m:
                admissible += 1
    return admissible / total


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Modular Sieve for Vampire Number Candidates",
             fontsize=14, fontweight='bold')

# Plot 1: Sieve effectiveness vs base
bases = list(range(3, 51))
survival = [mod_sieve_effectiveness(b) for b in bases]
elimination = [1 - s for s in survival]

ax1 = axes[0]
ax1.bar(bases, elimination, color='steelblue', alpha=0.7, width=0.8)
ax1.set_xlabel("Base b")
ax1.set_ylabel("Fraction eliminated")
ax1.set_title("Sieve Elimination Rate by Base")
ax1.set_ylim(0, 1)
ax1.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='50%')
ax1.legend()

# Plot 2: Admissible residue grid for base 10
ax2 = axes[1]
m = 9  # base 10, mod 9
grid = np.zeros((m, m))
for rx in range(m):
    for ry in range(m):
        if (rx * ry) % m == (rx + ry) % m:
            grid[rx, ry] = 1
ax2.imshow(grid, cmap='RdYlGn', origin='lower', aspect='equal',
           extent=[-0.5, m-0.5, -0.5, m-0.5])
ax2.set_xlabel("y mod 9")
ax2.set_ylabel("x mod 9")
ax2.set_title("Admissible Residues (Base 10)\nGreen = passes sieve")
ax2.set_xticks(range(m))
ax2.set_yticks(range(m))

# Plot 3: Admissible residue grid for base 16
ax3 = axes[2]
m = 15  # base 16, mod 15
grid = np.zeros((m, m))
for rx in range(m):
    for ry in range(m):
        if (rx * ry) % m == (rx + ry) % m:
            grid[rx, ry] = 1
ax3.imshow(grid, cmap='RdYlGn', origin='lower', aspect='equal',
           extent=[-0.5, m-0.5, -0.5, m-0.5])
ax3.set_xlabel("y mod 15")
ax3.set_ylabel("x mod 15")
ax3.set_title("Admissible Residues (Base 16)\nGreen = passes sieve")
ax3.set_xticks(range(0, m, 3))
ax3.set_yticks(range(0, m, 3))

plt.tight_layout()
plt.savefig("viz_sieve.png", dpi=150, bbox_inches='tight')
print("Saved viz_sieve.png")
