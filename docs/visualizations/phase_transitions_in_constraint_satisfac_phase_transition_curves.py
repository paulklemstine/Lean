#!/usr/bin/env python3
"""
Visualization 1: Phase Transition Curves for Latin Square CSPs

Shows how the satisfiability probability drops sharply at the critical density
d_c(n) = (n²-1)/n² for different grid sizes. The sharpness of the transition
increases with n, demonstrating the universality of the phase transition.

Uses simulated data based on the theoretical sigmoid model.
"""

import numpy as np
import matplotlib.pyplot as plt


def critical_density(n):
    """Critical density d_c(n) = (n²-1)/n²."""
    return (n**2 - 1) / n**2


def sat_probability_model(d, n, sharpness=None):
    """
    Model for satisfiability probability as a function of density.
    Uses a sigmoid centered at d_c with sharpness proportional to n².
    """
    dc = critical_density(n)
    if sharpness is None:
        sharpness = n**2 * 2  # Sharpness scales with n²
    return 1 / (1 + np.exp(sharpness * (d - dc)))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Phase transition curves for different n
ax1 = axes[0]
densities = np.linspace(0, 1, 500)
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']
ns = [2, 3, 4, 5, 6]

for n, color in zip(ns, colors):
    dc = critical_density(n)
    probs = sat_probability_model(densities, n)
    ax1.plot(densities, probs, color=color, linewidth=2.5,
             label=f'n={n} (d_c={dc:.3f})')
    ax1.axvline(dc, color=color, linestyle='--', alpha=0.3, linewidth=1)

ax1.set_xlabel('Density of Pre-filled Cells (d)', fontsize=13)
ax1.set_ylabel('P(Satisfiable)', fontsize=13)
ax1.set_title('Phase Transition in Latin Square Completion', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='center left')
ax1.set_xlim(0, 1)
ax1.set_ylim(-0.05, 1.05)
ax1.axhline(0.5, color='gray', linestyle=':', alpha=0.5)
ax1.grid(True, alpha=0.3)

# Shade the SAT and UNSAT regions for n=3
dc3 = critical_density(3)
ax1.fill_between([0, dc3 - 1/9], [1.05, 1.05], alpha=0.05, color='green')
ax1.fill_between([dc3 + 1/9, 1], [1.05, 1.05], alpha=0.05, color='red')
ax1.text(0.2, 0.95, 'SAT', fontsize=14, color='green', alpha=0.7,
         ha='center', fontweight='bold')
ax1.text(0.97, 0.95, 'UNSAT', fontsize=14, color='red', alpha=0.7,
         ha='center', fontweight='bold')

# Right panel: Critical density convergence
ax2 = axes[1]
ns_range = np.arange(2, 21)
dc_values = [(n**2 - 1) / n**2 for n in ns_range]
gaps = [1 / n**2 for n in ns_range]

ax2.plot(ns_range, dc_values, 'o-', color='#2196F3', linewidth=2,
         markersize=8, label=r'$d_c(n) = (n^2-1)/n^2$')
ax2.axhline(1.0, color='gray', linestyle='--', alpha=0.5, label='Limit = 1')

ax2_twin = ax2.twinx()
ax2_twin.bar(ns_range, gaps, alpha=0.3, color='#FF9800', width=0.6,
             label=r'Window width $1/n^2$')
ax2_twin.set_ylabel('Phase Transition Window Width', fontsize=12, color='#FF9800')
ax2_twin.tick_params(axis='y', labelcolor='#FF9800')

ax2.set_xlabel('Grid Order n', fontsize=13)
ax2.set_ylabel('Critical Density d_c(n)', fontsize=13)
ax2.set_title('Critical Density Convergence', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11, loc='lower right')
ax2.set_ylim(0.6, 1.02)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition_curves.png', dpi=150, bbox_inches='tight')
print("Saved: phase_transition_curves.png")
