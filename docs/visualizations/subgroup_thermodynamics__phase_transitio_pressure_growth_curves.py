#!/usr/bin/env python3
"""
Visualization: Pressure Growth Curves

Shows how the subgroup pair pressure grows with m (number of blocks)
for different values of k (block size). The linear growth in m is
the content of the block-defect pressure theorem, while the dependence
on k shows the energy barrier effect.

The crossing of the pressure=1 line marks the approximate phase
transition boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def maximal_subgroup_indices_Sn(n):
    indices = []
    if n >= 2:
        indices.append(2)
    for k in range(1, n // 2 + 1):
        indices.append(math.comb(n, k))
    for k in range(2, n):
        if n % k == 0:
            m_val = n // k
            idx = math.factorial(n) // (math.factorial(k) ** m_val * math.factorial(m_val))
            if idx > 1:
                indices.append(idx)
    return sorted(set(indices))


def pressure_Sk(k):
    indices = maximal_subgroup_indices_Sn(k)
    return sum(1.0 / (idx ** 2) for idx in indices)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Pressure vs m for various k
ax1 = axes[0]
m_vals = np.arange(1, 31)
colors = plt.cm.viridis(np.linspace(0.1, 0.9, 8))

for i, k in enumerate(range(2, 10)):
    p_k = pressure_Sk(k)
    pressures = [m * p_k for m in m_vals]
    ax1.semilogy(m_vals, pressures, '-o', color=colors[i], 
                 markersize=3, label=f'k={k} (p₁={p_k:.4f})')

ax1.axhline(y=1.0, color='red', linestyle='--', linewidth=2, 
            label='Pressure = 1 (transition)')
ax1.set_xlabel('Number of blocks m', fontsize=12)
ax1.set_ylabel('Block-defect pressure (log scale)', fontsize=12)
ax1.set_title('Pressure Growth with Block Count', fontsize=13)
ax1.legend(fontsize=8, loc='lower right')
ax1.grid(True, alpha=0.3)

# Right: Free energy vs k/m ratio
ax2 = axes[1]
ratios = []
free_energies = []
labels = []

for k in range(2, 10):
    p_k = pressure_Sk(k)
    for m in range(1, 30):
        p_total = m * p_k
        if p_total > 0:
            ratio = k / m
            fe = -math.log(p_total)
            ratios.append(ratio)
            free_energies.append(fe)

ax2.scatter(ratios, free_energies, c='steelblue', alpha=0.5, s=15)
ax2.axhline(y=0, color='red', linestyle='--', linewidth=2,
            label='F = 0 (pressure = 1)')
ax2.set_xlabel('Ratio k/m', fontsize=12)
ax2.set_ylabel('Free energy F = -log(pressure)', fontsize=12)
ax2.set_title('Free Energy vs k/m Ratio', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 10)
ax2.set_ylim(-5, 10)

# Add annotations
ax2.annotate('Generation\nlikely', xy=(6, 5), fontsize=11, 
            color='green', ha='center', fontweight='bold')
ax2.annotate('Nongeneration\nlikely', xy=(1, -3), fontsize=11,
            color='red', ha='center', fontweight='bold')

plt.tight_layout()
plt.savefig('pressure_curves.png', dpi=150, bbox_inches='tight')
print("Saved pressure_curves.png")
