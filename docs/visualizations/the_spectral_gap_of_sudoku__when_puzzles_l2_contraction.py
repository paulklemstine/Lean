"""
L2 Contraction Visualization: Exponential Convergence from Spectral Gap

Visualizes the proven theorem that the L2 distance to stationarity decays
exponentially as (1-γ)^t, where γ is the spectral gap. Shows how different
gap values lead to dramatically different convergence rates — the mathematical
essence of why puzzle difficulty varies with constraint density.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Contraction curves for different gaps
gaps = [0.05, 0.1, 0.2, 0.4, 0.6, 0.8]
steps = np.arange(0, 30)

for gap in gaps:
    contraction = (1 - gap) ** steps
    ax1.plot(steps, contraction, linewidth=2.5, label=f'γ = {gap}')

ax1.set_xlabel('Number of Steps (t)', fontsize=13)
ax1.set_ylabel('Contraction Factor (1-γ)^t', fontsize=13)
ax1.set_title('Exponential L2 Contraction\n(Proved: contraction_decreasing)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper right')
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0.25, color='gray', linestyle=':', alpha=0.7, label='ε = 0.25')

# Add annotation
ax1.annotate('Mixing time threshold\n(ε = 0.25)', xy=(15, 0.25),
            fontsize=10, ha='center', va='bottom',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

# Right: Mixing time vs spectral gap
gap_values = np.linspace(0.01, 1.0, 200)
n_states = 100
epsilon = 0.25

mixing_times = (1.0 / gap_values) * (np.log(n_states) + np.log(1.0 / epsilon))

ax2.plot(gap_values, mixing_times, linewidth=3, color='#e74c3c')
ax2.fill_between(gap_values, mixing_times, alpha=0.1, color='#e74c3c')
ax2.set_xlabel('Spectral Gap (γ)', fontsize=13)
ax2.set_ylabel('Mixing Time Bound', fontsize=13)
ax2.set_title(f'Mixing Time vs Spectral Gap\n(n={n_states}, ε={epsilon})', fontsize=14, fontweight='bold')
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Mark critical density region
ax2.axvspan(0.0, 0.1, alpha=0.15, color='red', label='Critical region\n(slow mixing)')
ax2.axvspan(0.3, 1.0, alpha=0.15, color='green', label='Fast mixing\nregion')
ax2.legend(fontsize=11, loc='upper right')

# Add the divergence annotation
ax2.annotate('T_mix → ∞ as γ → 0\n(Proved: mixing_time_diverges_at_zero_gap)',
            xy=(0.03, mixing_times[5]),
            fontsize=9, ha='left',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

plt.suptitle('Spectral Gap Controls Mixing: From Theory to Phase Transitions',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('contraction.png', dpi=150, bbox_inches='tight')
print("Saved contraction.png")
