#!/usr/bin/env python3
"""
Visualization: Spectral Gaps and Cheeger Constants vs Field Size

Plots the certified spectral gap and Cheeger constant as functions of q
for G₂(𝔽_q)-type certificates with constant C = 2. Shows how the
expansion guarantees improve with growing field size.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Parameters
C = 2.0
q_values = np.arange(3, 51)
spectral_gaps = 1 - C / q_values
cheeger_bounds = spectral_gaps / 2
spectral_radii = C / q_values

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Spectral gap vs q
ax1 = axes[0]
ax1.plot(q_values, spectral_gaps, 'b-o', markersize=3, linewidth=1.5, label='γ = 1 - C/q')
ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='γ = 1 (limit)')
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='γ = 0 (threshold)')
ax1.fill_between(q_values, 0, spectral_gaps, alpha=0.1, color='blue')
ax1.set_xlabel('Field size q', fontsize=12)
ax1.set_ylabel('Certified spectral gap γ', fontsize=12)
ax1.set_title('Spectral Gap vs Field Size\n(C = 2)', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_ylim(-0.1, 1.1)
ax1.grid(True, alpha=0.3)

# Plot 2: Cheeger constant vs q
ax2 = axes[1]
ax2.plot(q_values, cheeger_bounds, 'g-s', markersize=3, linewidth=1.5, label='h ≥ γ/2')
ax2.axhline(y=0.25, color='orange', linestyle='--', alpha=0.7, label='h = 1/4')
ax2.fill_between(q_values, 0, cheeger_bounds, alpha=0.1, color='green')
ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Certified Cheeger bound h', fontsize=12)
ax2.set_title('Cheeger Constant vs Field Size\n(C = 2)', fontsize=13)
ax2.legend(fontsize=9)
ax2.set_ylim(-0.05, 0.55)
ax2.grid(True, alpha=0.3)

# Plot 3: Scaled ratio M(q) = q · α
ax3 = axes[2]
M_values = q_values * (C / q_values)  # = C for all q (in the exact-bound case)
ax3.plot(q_values, M_values, 'r-^', markersize=3, linewidth=1.5, label='M(q) = q · α')
ax3.axhline(y=C, color='darkred', linestyle='--', alpha=0.7, label=f'C = {C}')
ax3.set_xlabel('Field size q', fontsize=12)
ax3.set_ylabel('Scaled character ratio M(q)', fontsize=12)
ax3.set_title('Scaled Ratio M(q) = q·α\n(Tests Uniform Bound Conjecture)', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_ylim(0, C + 1)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gaps_plot.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved spectral_gaps_plot.png")
