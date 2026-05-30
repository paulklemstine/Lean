#!/usr/bin/env python3
"""
Visualization: The Symmetry-Entropy Bridge

Shows how symmetry constrains information content in rhythms.
Demonstrates the formally verified theorem: more symmetry (higher
symmetry group order) means fewer degrees of freedom and lower entropy.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: DOF vs symmetry order for various periods
ax1 = axes[0]
periods = [6, 8, 12, 16, 24]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(periods)))

for p, color in zip(periods, colors):
    divisors = sorted([d for d in range(1, p + 1) if p % d == 0])
    dofs = [p // d for d in divisors]
    ax1.plot(divisors, dofs, 'o-', color=color, linewidth=2, markersize=8,
             label=f'p={p}')

ax1.set_xlabel('Symmetry Group Order (d)', fontsize=13)
ax1.set_ylabel('Degrees of Freedom (p/d)', fontsize=13)
ax1.set_title('Symmetry Reduces Freedom\n(Verified: symmetry_reduces_freedom)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log', base=2)

# Panel 2: Number of possible rhythms vs symmetry order
ax2 = axes[1]
p = 12
divisors = sorted([d for d in range(1, p + 1) if p % d == 0])

possible = [2 ** (p // d) for d in divisors]
ax2.bar(range(len(divisors)), possible, color='#2196F3', edgecolor='white', linewidth=2)
ax2.set_xticks(range(len(divisors)))
ax2.set_xticklabels([str(d) for d in divisors], fontsize=12)
ax2.set_xlabel('Symmetry Order (d)', fontsize=13)
ax2.set_ylabel('Possible Rhythms (2^{p/d})', fontsize=13)
ax2.set_title(f'Rhythm Space Size (p={p})\n(Verified: rhythm_count_bound)', fontsize=14, fontweight='bold')
ax2.set_yscale('log', base=2)

# Add labels
for i, (d, count) in enumerate(zip(divisors, possible)):
    label = f'2^{p//d}'
    ax2.text(i, count * 1.2, label, ha='center', fontsize=10, fontweight='bold')

# Panel 3: Necklace counts vs period
ax3 = axes[2]
periods_neck = list(range(1, 21))
necklace_counts = []
total_counts = []

for p_val in periods_neck:
    nc = sum(2 ** gcd(k, p_val) for k in range(p_val)) // p_val
    necklace_counts.append(nc)
    total_counts.append(2 ** p_val)

ax3.semilogy(periods_neck, total_counts, 's-', color='#F44336', linewidth=2,
             markersize=6, label='Total strings (2^p)', alpha=0.7)
ax3.semilogy(periods_neck, necklace_counts, 'o-', color='#4CAF50', linewidth=2,
             markersize=6, label='Necklaces (Burnside)')

# Mark primes
primes = [2, 3, 5, 7, 11, 13, 17, 19]
for pp in primes:
    if pp <= 20:
        nc = necklace_counts[pp - 1]
        ax3.plot(pp, nc, 'D', color='gold', markersize=10, zorder=5,
                markeredgecolor='black')

ax3.set_xlabel('Period (p)', fontsize=13)
ax3.set_ylabel('Count', fontsize=13)
ax3.set_title('Necklace Counting\n(Burnside\'s Lemma)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)
ax3.text(0.05, 0.05, '◆ = prime period\n(simplified formula)',
         transform=ax3.transAxes, fontsize=10, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('symmetry_entropy.png', dpi=150, bbox_inches='tight')
print("Saved symmetry_entropy.png")
