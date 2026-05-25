#!/usr/bin/env python3
"""
Visualization: Phase Transition Heatmap for S_k^m

Visualizes the subgroup pair pressure as a function of (k, m),
showing the phase transition boundary where pressure ≈ 1.
The heatmap reveals the entropy-energy competition: as m grows
(more blocks), pressure increases; as k grows (larger blocks),
individual subgroup indices grow and suppress pressure.

This is the central visual evidence for the phase transition
conjecture in wreath product random generation.
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


def block_pressure(k, m):
    return m * pressure_Sk(k)


k_vals = np.arange(2, 16)
m_vals = np.arange(1, 21)

Z = np.zeros((len(m_vals), len(k_vals)))
for i, m in enumerate(m_vals):
    for j, k in enumerate(k_vals):
        Z[i, j] = np.log10(block_pressure(int(k), int(m)) + 1e-15)

fig, ax = plt.subplots(figsize=(10, 7))

# Use diverging colormap centered at log10(1) = 0
vmin, vmax = Z.min(), Z.max()
im = ax.pcolormesh(k_vals - 0.5, m_vals - 0.5, Z,
                   cmap='RdYlBu_r', shading='auto')

# Add contour at pressure = 1 (log10 = 0)
CS = ax.contour(k_vals, m_vals, Z, levels=[0],
                colors='black', linewidths=2, linestyles='--')
ax.clabel(CS, fmt='pressure=1', fontsize=10)

cbar = fig.colorbar(im, ax=ax, label='log₁₀(pressure)')
ax.set_xlabel('Block size k (symmetric group S_k)', fontsize=12)
ax.set_ylabel('Number of blocks m', fontsize=12)
ax.set_title('Phase Transition in Subgroup Pair Pressure for S_k^m\n'
             'Red = high pressure (nongeneration likely) | Blue = low pressure (generation likely)',
             fontsize=13)

# Add ratio lines
for ratio in [0.5, 1.0, 2.0]:
    k_line = np.linspace(2, 15, 100)
    m_line = k_line / ratio
    mask = (m_line >= 1) & (m_line <= 20)
    ax.plot(k_line[mask], m_line[mask], 'g-', alpha=0.5, linewidth=1)
    if ratio == 1.0:
        ax.text(14, 14/ratio, f'k/m={ratio}', color='green', fontsize=9)

ax.set_xlim(1.5, 15.5)
ax.set_ylim(0.5, 20.5)

plt.tight_layout()
plt.savefig('phase_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved phase_heatmap.png")
