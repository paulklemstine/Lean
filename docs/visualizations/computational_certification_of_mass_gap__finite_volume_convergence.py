#!/usr/bin/env python3
"""
Visualization: Finite Volume Gap Convergence

Shows how the finite-volume mass gap converges to the infinite-volume
value as the lattice size L increases. Illustrates the theorem
finite_volume_gap_positive: there exists L₀ beyond which the gap is positive.
"""

import numpy as np
import matplotlib.pyplot as plt

m_inf = 1.5  # Infinite-volume gap
C = 10.0     # Correction constant

L_values = np.arange(1, 25)
corrections = C / L_values.astype(float)**2
gap_lower = m_inf - corrections
gap_upper = m_inf + corrections

# Find L0 where gap_lower first becomes positive
L0 = next(L for L in L_values if m_inf - C/L**2 > 0)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Gap bounds vs L
ax1.fill_between(L_values, gap_lower, gap_upper, alpha=0.25, color='blue',
                 label='Certified interval')
ax1.plot(L_values, gap_lower, 'b-', linewidth=1.5)
ax1.plot(L_values, gap_upper, 'b-', linewidth=1.5)
ax1.axhline(y=m_inf, color='red', linestyle='--', linewidth=2,
            label=f'm∞ = {m_inf}')
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.axvline(x=L0, color='green', linestyle=':', linewidth=2,
            label=f'L₀ = {L0} (positivity threshold)')
ax1.set_xlabel('Lattice size L', fontsize=12)
ax1.set_ylabel('Mass gap', fontsize=12)
ax1.set_title('Finite Volume Convergence', fontsize=14)
ax1.legend(fontsize=10, loc='lower right')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1, 24)

# Panel 2: Correction magnitude (log scale)
ax2.semilogy(L_values, corrections, 'b-o', markersize=4, linewidth=2,
             label='C/L²')
ax2.axhline(y=m_inf, color='red', linestyle='--', alpha=0.5,
            label=f'm∞ = {m_inf}')
ax2.set_xlabel('Lattice size L', fontsize=12)
ax2.set_ylabel('Finite-volume correction C/L²', fontsize=12)
ax2.set_title('Correction Decay Rate', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_finite_volume.png', dpi=150, bbox_inches='tight')
print("Saved viz_finite_volume.png")
