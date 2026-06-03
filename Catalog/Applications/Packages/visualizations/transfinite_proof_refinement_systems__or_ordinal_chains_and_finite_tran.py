#!/usr/bin/env python3
"""
Visualization: Ordinal Refinement Chains and the Finite-Transfinite Gap

Shows chain length bounds and the gap between finite and transfinite ordinals.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# Figure 1: Chain length vs initial complexity for the linear system
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Ordinal Refinement Chain Analysis', fontsize=14, fontweight='bold')

ns = list(range(1, 21))
chain_lengths = ns  # Linear system achieves exact bound
complexities = ns  # Initial complexity = n

ax1.plot(complexities, chain_lengths, 'o-', color='#e74c3c', linewidth=2, markersize=8,
         label='Achieved (linear system)')
ax1.plot(complexities, complexities, '--', color='gray', alpha=0.5, label='Bound: length ≤ complexity')
ax1.fill_between(complexities, chain_lengths, complexities, alpha=0.1, color='#3498db',
                  label='Unreachable region')
ax1.set_xlabel('Initial Complexity', fontsize=12)
ax1.set_ylabel('Maximum Chain Length', fontsize=12)
ax1.set_title('Chain Length Bound (Finite Ordinals)', fontsize=12)
ax1.legend()
ax1.grid(True, alpha=0.3)

# Figure 2: Ordinal complexity levels (schematic)
levels = ['0', '1', '2', '...', 'n', '...', 'ω', 'ω+1', '...', 'ω·2', '...', 'ω²']
y_positions = [0, 1, 2, 3.5, 5, 6.5, 8, 9, 10, 11.5, 13, 15]
colors = ['#2ecc71'] * 6 + ['#e74c3c'] * 6
sizes = [200] * 6 + [300] * 6

for y, label, color, size in zip(y_positions, levels, colors, sizes):
    ax2.scatter([0], [y], s=size, c=color, zorder=5, edgecolors='black', linewidth=1)
    ax2.annotate(label, (0.3, y), fontsize=11, va='center')

# Add bracket for finite ordinals
ax2.annotate('', xy=(-0.5, 0), xytext=(-0.5, 6.5),
             arrowprops=dict(arrowstyle='<->', color='#2ecc71', lw=2))
ax2.text(-1.2, 3, 'Finite\nordinals\n(ℕ-chains\npossible)', fontsize=9,
         color='#2ecc71', ha='center', va='center')

# Add bracket for transfinite ordinals
ax2.annotate('', xy=(-0.5, 8), xytext=(-0.5, 15),
             arrowprops=dict(arrowstyle='<->', color='#e74c3c', lw=2))
ax2.text(-1.2, 11.5, 'Transfinite\nordinals\n(no ℕ-chain\nof this length)', fontsize=9,
         color='#e74c3c', ha='center', va='center')

# Gap line
ax2.axhline(y=7.2, color='orange', linewidth=2, linestyle='--')
ax2.text(0.8, 7.2, '← FINITE-TRANSFINITE GAP', fontsize=10, color='orange',
         va='center', fontweight='bold')

ax2.set_xlim(-2, 3)
ax2.set_ylim(-1, 16)
ax2.set_title('The Ordinal Hierarchy\nand the Finite-Transfinite Gap', fontsize=12)
ax2.axis('off')

plt.tight_layout()
plt.savefig('ordinal_chains.png', dpi=150, bbox_inches='tight')
print("Saved: ordinal_chains.png")
