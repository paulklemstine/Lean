#!/usr/bin/env python3
"""
Visualization: Universality Curves

Shows the convergence of P_full/P_coord → 1 as m → ∞ for different k values,
providing visual evidence for the universality theorem. Also plots the
statistical mechanics interpretation: partition function decomposition.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


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


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Universality in Wreath Product Generation Thresholds',
             fontsize=16, fontweight='bold')

m_values = np.arange(2, 51)

# Panel 1: Convergence curves for different k
ax1 = axes[0, 0]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
for idx, k in enumerate([3, 4, 5, 7, 10]):
    p_sk = compute_symm_pressure(k)
    ratios = []
    for m in m_values:
        pc = m * p_sk
        pnc = noncoord_estimate(k, m)
        ratios.append((pc + pnc) / pc if pc > 0 else 1.0)
    ax1.plot(m_values, ratios, '-', linewidth=2, color=colors[idx], label=f'k={k}')

ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5, linewidth=1)
ax1.set_xlabel('m', fontsize=12)
ax1.set_ylabel('P(W_{k,m}) / P_coord(W_{k,m})', fontsize=12)
ax1.set_title('Universality: Ratio → 1', fontsize=13)
ax1.legend(fontsize=10, loc='upper right')
ax1.grid(True, alpha=0.3)

# Panel 2: Log-scale gap
ax2 = axes[0, 1]
for idx, k in enumerate([3, 5, 7, 10]):
    gaps = []
    for m in m_values:
        pnc = noncoord_estimate(k, m)
        gaps.append(max(pnc, 1e-15))
    ax2.semilogy(m_values, gaps, '-o', linewidth=2, markersize=3,
                 color=colors[idx], label=f'k={k}')

# Reference: log(m)
log_ref = [math.log(m + 1) for m in m_values]
ax2.semilogy(m_values, log_ref, 'k--', linewidth=1, alpha=0.5, label='log(m+1)')

ax2.set_xlabel('m', fontsize=12)
ax2.set_ylabel('P_noncoord (log scale)', fontsize=12)
ax2.set_title('Non-coordinate Pressure Growth', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Stacked area chart (partition function decomposition)
ax3 = axes[1, 0]
k = 5
p_sk = compute_symm_pressure(k)
coord_vals = [m * p_sk for m in m_values]
noncoord_vals = [noncoord_estimate(k, m) for m in m_values]

ax3.fill_between(m_values, 0, coord_vals, alpha=0.7, color='steelblue',
                 label='Z_coord (coordinate defects)')
ax3.fill_between(m_values, coord_vals,
                 [c + n for c, n in zip(coord_vals, noncoord_vals)],
                 alpha=0.7, color='coral', label='Z_noncoord (other types)')
ax3.set_xlabel('m', fontsize=12)
ax3.set_ylabel('Partition Function Z(W_{5,m})', fontsize=12)
ax3.set_title('Statistical Mechanics:\nPartition Function Decomposition', fontsize=13)
ax3.legend(fontsize=10, loc='upper left')
ax3.grid(True, alpha=0.3)

# Panel 4: Threshold comparison
ax4 = axes[1, 1]
for idx, k in enumerate([5, 7, 10]):
    p_sk = compute_symm_pressure(k)
    thresholds_coord = [1.0 / (m * p_sk) for m in m_values]
    thresholds_full = [1.0 / (m * p_sk + noncoord_estimate(k, m)) for m in m_values]
    ax4.plot(m_values, thresholds_coord, '--', linewidth=2, color=colors[idx],
             alpha=0.5)
    ax4.plot(m_values, thresholds_full, '-', linewidth=2, color=colors[idx],
             label=f'k={k}')

ax4.set_xlabel('m', fontsize=12)
ax4.set_ylabel('Generation Threshold', fontsize=12)
ax4.set_title('Phase Transition Threshold\n(solid=full, dashed=coord only)', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('universality_curves.png', dpi=150, bbox_inches='tight')
print("Saved: universality_curves.png")
