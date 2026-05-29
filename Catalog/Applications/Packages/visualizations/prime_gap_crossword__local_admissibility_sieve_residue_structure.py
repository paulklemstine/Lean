#!/usr/bin/env python3
"""
Visualization: Sieve Residue Structure

Visualizes the modular "chessboard" of admissible residues mod M for
different sieve sets. Shows how the coprime residues (valid starting
positions for prime candidates) form a structured pattern on the
discrete torus Z/MZ.

The visualization reveals the geometric structure underlying the
prime gap crossword: admissible positions form a sparse, periodic
lattice in modular arithmetic.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import prod, gcd
from typing import Set

# ── Build residue grid visualization ────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

configs = [
    ({2, 3}, "S = {2,3}, M = 6", axes[0, 0]),
    ({2, 3, 5}, "S = {2,3,5}, M = 30", axes[0, 1]),
    ({2, 3, 5, 7}, "S = {2,3,5,7}, M = 210", axes[1, 0]),
]

for S, title, ax in configs:
    M = prod(S)

    # Determine which residues are coprime to M
    coprime = np.array([1 if all(r % q != 0 for q in S) else 0 for r in range(M)])

    # Reshape into a 2D grid for visualization
    cols = max(6, int(np.sqrt(M)))
    while M % cols != 0 and cols > 1:
        cols -= 1
    rows = M // cols

    grid = coprime.reshape(rows, cols)

    # Color: coprime residues = green, sieved = gray
    cmap = plt.cm.colors.ListedColormap(['#e8e8e8', '#48c774'])
    ax.imshow(grid, cmap=cmap, aspect='equal', origin='lower')

    ax.set_title(f"{title}\n{sum(coprime)} coprime residues out of {M}",
                 fontsize=11)
    ax.set_xlabel(f'Residue mod {cols}')
    ax.set_ylabel(f'Block ({cols} per row)')

    # Density annotation
    density = sum(coprime) / M
    euler_product = prod((1 - 1/q) for q in S)
    ax.text(0.02, 0.98, f'Density: {density:.3f}\nEuler: {euler_product:.3f}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# Fourth panel: Gap transition diagram for S = {2, 3}
ax4 = axes[1, 1]
S = {2, 3}
M = 6
coprime_residues = [r for r in range(M) if all(r % q != 0 for q in S)]

# Draw circular layout of coprime residues mod 6
n_res = len(coprime_residues)
theta = np.linspace(0, 2 * np.pi, M, endpoint=False)
radius = 1.5

# Draw all residues as small dots
for r in range(M):
    x, y = radius * np.cos(theta[r]), radius * np.sin(theta[r])
    is_cop = r in coprime_residues
    color = '#48c774' if is_cop else '#cccccc'
    size = 800 if is_cop else 200
    ax4.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidth=1)
    ax4.annotate(str(r), (x, y), fontsize=12 if is_cop else 8,
                ha='center', va='center', fontweight='bold' if is_cop else 'normal')

# Draw admissible gap transitions
gap_colors = {2: '#e74c3c', 4: '#3498db', 6: '#f39c12'}
for a in coprime_residues:
    for g in [2, 4, 6]:
        b = (a + g) % M
        if b in coprime_residues:
            # Check if interior is covered
            all_interior_hit = True
            for u in range(1, g):
                if not any((a + u) % q == 0 for q in S):
                    all_interior_hit = False
                    break
            if all_interior_hit:
                xa, ya = radius * np.cos(theta[a]), radius * np.sin(theta[a])
                xb, yb = radius * np.cos(theta[b]), radius * np.sin(theta[b])
                ax4.annotate('', xy=(xb, yb), xytext=(xa, ya),
                            arrowprops=dict(arrowstyle='->', color=gap_colors.get(g, 'gray'),
                                          lw=2, connectionstyle='arc3,rad=0.3'))

ax4.set_xlim(-2.5, 2.5)
ax4.set_ylim(-2.5, 2.5)
ax4.set_aspect('equal')
ax4.set_title('Gap Transition Graph (S = {2,3}, mod 6)\nGreen = coprime residues',
              fontsize=11)
ax4.axis('off')

# Add gap color legend
from matplotlib.lines import Line2D
legend_lines = [Line2D([0], [0], color=c, lw=2, label=f'gap {g}')
                for g, c in sorted(gap_colors.items())]
ax4.legend(handles=legend_lines, loc='lower right', fontsize=9)

fig.suptitle('Prime Gap Crossword: Modular Sieve Structure',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('sieve_residues.png', dpi=150, bbox_inches='tight')
print("Saved sieve_residues.png")
