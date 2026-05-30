#!/usr/bin/env python3
"""
Visualization 2: Computational Hardness Landscape

Shows the 'hardness peak' at the phase transition: instances near the critical
density d_c are exponentially harder to solve than those far from it.
This is the computational signature of criticality in CSPs.
"""

import numpy as np
import matplotlib.pyplot as plt


def critical_density(n):
    """Critical density d_c(n) = (n²-1)/n²."""
    return (n**2 - 1) / n**2


def hardness_model(d, n):
    """
    Model computational hardness (backtracks) as a function of density.
    Hardness peaks sharply at d_c with height ~ exp(n).
    """
    dc = critical_density(n)
    width = 1 / n**2
    peak_height = np.exp(n)
    return peak_height * np.exp(-((d - dc) / width)**2)


def entropy_model(d, n):
    """
    Model constraint entropy H(d) as a function of density.
    Entropy decreases from ~1 (unconstrained) to ~0 (fully determined).
    """
    dc = critical_density(n)
    return 1 / (1 + np.exp(n**2 * (d - dc)))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
densities = np.linspace(0, 1, 500)

# Left: Hardness landscape
ax1 = axes[0]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
ns = [2, 3, 4, 5]

for n, color in zip(ns, colors):
    dc = critical_density(n)
    hardness = hardness_model(densities, n)
    # Normalize for display
    hardness_norm = hardness / hardness.max()
    ax1.plot(densities, hardness_norm, color=color, linewidth=2.5,
             label=f'n={n}')
    ax1.axvline(dc, color=color, linestyle='--', alpha=0.3)

ax1.set_xlabel('Density (d)', fontsize=13)
ax1.set_ylabel('Relative Computational Hardness', fontsize=13)
ax1.set_title('Hardness Peak at Phase Transition', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_xlim(0, 1)
ax1.grid(True, alpha=0.3)

# Annotate the easy-hard-easy pattern
ax1.annotate('EASY\n(few constraints)',
             xy=(0.15, 0.05), fontsize=11, color='green',
             ha='center', fontweight='bold')
ax1.annotate('HARD\n(critical)',
             xy=(critical_density(3), 0.85), fontsize=11, color='red',
             ha='center', fontweight='bold',
             arrowprops=dict(arrowstyle='->', color='red'),
             xytext=(critical_density(3) - 0.15, 0.95))
ax1.annotate('EASY\n(over-constrained)',
             xy=(0.97, 0.05), fontsize=11, color='green',
             ha='center', fontweight='bold')

# Right: Entropy vs density
ax2 = axes[1]

for n, color in zip(ns, colors):
    dc = critical_density(n)
    entropy = entropy_model(densities, n)
    ax2.plot(densities, entropy, color=color, linewidth=2.5,
             label=f'n={n}')
    ax2.axvline(dc, color=color, linestyle='--', alpha=0.3)

ax2.axhline(1/np.e, color='gray', linestyle=':', alpha=0.5,
            label=r'$H = 1/e$ threshold')
ax2.set_xlabel('Density (d)', fontsize=13)
ax2.set_ylabel('Constraint Entropy H(d)', fontsize=13)
ax2.set_title('Entropy Collapse at Phase Transition', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11, loc='upper right')
ax2.set_xlim(0, 1)
ax2.set_ylim(-0.05, 1.05)
ax2.grid(True, alpha=0.3)

# Shade regions
ax2.fill_between(densities, 1/np.e, 1.05,
                 where=densities < critical_density(3),
                 alpha=0.05, color='green')
ax2.fill_between(densities, -0.05, 1/np.e,
                 where=densities > critical_density(3),
                 alpha=0.05, color='red')

plt.tight_layout()
plt.savefig('hardness_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: hardness_landscape.png")
