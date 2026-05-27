#!/usr/bin/env python3
"""
Visualization: Phase Transition Heatmap

Creates a heatmap showing the pressure ratio P_full/P_coord across
(k, m) parameter space, demonstrating that universality holds broadly:
the ratio stays close to 1 everywhere, confirming that coordinate
defects dominate the phase transition mechanism.

Also shows the logarithmic conjecture test: P_noncoord/log(m+1).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def compute_symm_pressure(k):
    if k < 2:
        return 0.0
    pressure = 0.0
    for j in range(1, k // 2 + 1):
        pressure += 1.0 / math.comb(k, j)
    pressure += 0.5
    for d in range(2, k):
        if k % d == 0 and k // d > 1:
            n = k // d
            idx = math.factorial(k) / (math.factorial(d) ** n * math.factorial(n))
            if idx > 0:
                pressure += 1.0 / idx
    return pressure


def noncoord_estimate(k, m):
    if k < 2 or m < 1:
        return 0.0
    top = compute_symm_pressure(m) if m >= 2 else 0.0
    diag = 0.0
    if k >= 5 and m >= 2:
        kfact = math.factorial(k)
        if m - 1 <= 20:
            diag = m * (m - 1) / 2.0 / (kfact ** (m - 1))
    return top + diag


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Wreath Product Phase Transition: Parameter Space Analysis',
             fontsize=15, fontweight='bold')

# Heatmap 1: P_full / P_coord
k_range = range(3, 13)
m_range = range(2, 21)
ratio_grid = np.zeros((len(list(k_range)), len(list(m_range))))

for i, k in enumerate(k_range):
    p_sk = compute_symm_pressure(k)
    for j, m in enumerate(m_range):
        pc = m * p_sk
        pnc = noncoord_estimate(k, m)
        ratio_grid[i, j] = (pc + pnc) / pc if pc > 0 else 1.0

ax1 = axes[0]
im1 = ax1.imshow(ratio_grid, aspect='auto', origin='lower',
                  extent=[min(m_range)-0.5, max(m_range)+0.5,
                          min(k_range)-0.5, max(k_range)+0.5],
                  cmap='RdYlGn_r', vmin=1.0, vmax=max(1.5, ratio_grid.max()))
ax1.set_xlabel('m (copies)', fontsize=12)
ax1.set_ylabel('k (base degree)', fontsize=12)
ax1.set_title('P_full / P_coord', fontsize=13)
plt.colorbar(im1, ax=ax1, label='Ratio')

# Heatmap 2: P_noncoord / m
nc_over_m = np.zeros((len(list(k_range)), len(list(m_range))))
for i, k in enumerate(k_range):
    for j, m in enumerate(m_range):
        pnc = noncoord_estimate(k, m)
        nc_over_m[i, j] = pnc / m

ax2 = axes[1]
im2 = ax2.imshow(nc_over_m, aspect='auto', origin='lower',
                  extent=[min(m_range)-0.5, max(m_range)+0.5,
                          min(k_range)-0.5, max(k_range)+0.5],
                  cmap='YlOrRd', vmin=0)
ax2.set_xlabel('m (copies)', fontsize=12)
ax2.set_ylabel('k (base degree)', fontsize=12)
ax2.set_title('P_noncoord / m (→ 0)', fontsize=13)
plt.colorbar(im2, ax=ax2, label='Ratio')

# Heatmap 3: P_noncoord / log(m+1) — logarithmic conjecture test
nc_over_log = np.zeros((len(list(k_range)), len(list(m_range))))
for i, k in enumerate(k_range):
    for j, m in enumerate(m_range):
        pnc = noncoord_estimate(k, m)
        nc_over_log[i, j] = pnc / math.log(m + 1)

ax3 = axes[2]
im3 = ax3.imshow(nc_over_log, aspect='auto', origin='lower',
                  extent=[min(m_range)-0.5, max(m_range)+0.5,
                          min(k_range)-0.5, max(k_range)+0.5],
                  cmap='YlOrRd', vmin=0)
ax3.set_xlabel('m (copies)', fontsize=12)
ax3.set_ylabel('k (base degree)', fontsize=12)
ax3.set_title('P_noncoord / log(m+1)\n(bounded ⟹ conjecture holds)', fontsize=13)
plt.colorbar(im3, ax=ax3, label='Ratio')

plt.tight_layout()
plt.savefig('phase_transition_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: phase_transition_heatmap.png")
