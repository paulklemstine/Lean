"""
Visualization: Gauge-Code Correspondence

Shows the relationship between spectral gap and code distance
for different gauge groups, demonstrating the gauge-code dictionary.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Gauge-Code Correspondence: Gap × Distance Product', 
             fontsize=15, fontweight='bold')

L_values = np.arange(2, 25)

# Panel 1: Protection product Δ·d vs L for different groups
ax1 = axes[0]
groups = [
    ('ℤ₂', 1.0, 1.0, 'blue'),
    ('ℤ₃', 1.0, 1.0, 'green'),
    ('ℤ₅', 1.0, 1.0, 'red'),
]
for name, gap, growth, color in groups:
    d_vals = growth * L_values
    product = gap * d_vals
    ax1.plot(L_values, product, '-o', color=color, markersize=3, 
             linewidth=2, label=f'{name}: Δ·d = {gap}·{growth}·L')

ax1.set_xlabel('System Size L', fontsize=12)
ax1.set_ylabel('Protection Product Δ·d', fontsize=12)
ax1.set_title('Linear Growth of Protection', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Perturbation analysis
ax2 = axes[1]
epsilons = np.linspace(0, 0.5, 50)
for L in [4, 8, 16]:
    gap = 1.0
    residual = np.maximum(gap - 2 * epsilons, 0)
    barrier = residual * L
    ax2.plot(epsilons, barrier, linewidth=2, label=f'L={L}')

ax2.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax2.axvline(x=0.5, color='k', linestyle='--', alpha=0.3, label='Critical ε=Δ/2')
ax2.set_xlabel('Perturbation ε', fontsize=12)
ax2.set_ylabel('Energy Barrier (Δ-2ε)·d', fontsize=12)
ax2.set_title('Perturbation Stability', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Correlation length vs system size
ax3 = axes[2]
gaps = [0.5, 1.0, 2.0]
colors_gap = ['orange', 'blue', 'purple']
for gap, color in zip(gaps, colors_gap):
    xi = 1.0 / gap
    L_range = np.arange(2, 25)
    # Topological order when xi < L
    topo_order = L_range > xi
    ax3.plot(L_range, [xi] * len(L_range), '--', color=color, alpha=0.5)
    ax3.fill_between(L_range, xi, 0, where=topo_order, 
                     alpha=0.15, color=color)
    ax3.plot(L_range, L_range, 'k-', alpha=0.3)
    ax3.annotate(f'Δ={gap}, ξ={xi:.1f}', xy=(20, xi + 0.3), 
                fontsize=9, color=color)

ax3.set_xlabel('System Size L', fontsize=12)
ax3.set_ylabel('Length Scale', fontsize=12)
ax3.set_title('Topological Order: ξ < L', fontsize=13)
ax3.set_ylim(0, 10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gauge_code_correspondence.png', dpi=150, bbox_inches='tight')
plt.close()
