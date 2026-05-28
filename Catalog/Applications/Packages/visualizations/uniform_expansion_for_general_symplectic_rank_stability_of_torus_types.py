#!/usr/bin/env python3
"""
Visualization 3: Rank stability of uniform torus types.

Shows how the uniform torus type condition propagates from rank 1 to
higher ranks, with the character-ratio constant C_n growing linearly.
Demonstrates that the spectral gap remains positive for all ranks when
q is sufficiently large.

This visualizes Theorem 4 (torus-type rank stability) and the full
induction chain from the Sp₂ = SL₂ base case.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: C_n growth with rank
ax1 = axes[0]
ranks = np.arange(1, 21)
C_n = ranks + 1  # C_n = n + 1

ax1.bar(ranks, C_n, color=plt.cm.viridis(ranks / 20), alpha=0.8, width=0.7)
ax1.plot(ranks, C_n, 'k--', linewidth=1, alpha=0.5)
ax1.set_xlabel('Rank n', fontsize=12)
ax1.set_ylabel('Bounding constant C_n', fontsize=12)
ax1.set_title('Character-Ratio Constants by Rank', fontsize=13)
ax1.text(10, 8, 'C_n = n + 1\n(linear growth)', fontsize=11,
         ha='center', style='italic',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
ax1.grid(True, alpha=0.3, axis='y')

# Panel 2: Minimum q for positive gap by rank
ax2 = axes[1]
min_q_for_gap = C_n + 1  # Need q > C_n for positive gap
min_q_for_half = 2 * C_n  # Need q ≥ 2C_n for gap ≥ 1/2

ax2.fill_between(ranks, 0, min_q_for_gap, alpha=0.3, color='red',
                 label='No expansion')
ax2.fill_between(ranks, min_q_for_gap, min_q_for_half, alpha=0.3,
                 color='orange', label='Gap ∈ (0, ½)')
ax2.fill_between(ranks, min_q_for_half, min_q_for_half * 2, alpha=0.3,
                 color='green', label='Gap ≥ ½')
ax2.plot(ranks, min_q_for_gap, 'r-', linewidth=2, label='q = C_n + 1')
ax2.plot(ranks, min_q_for_half, 'b-', linewidth=2, label='q = 2·C_n')

ax2.set_xlabel('Rank n', fontsize=12)
ax2.set_ylabel('Minimum field size q', fontsize=12)
ax2.set_title('Field Size Threshold by Rank', fontsize=13)
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)

# Panel 3: Spectral gap surface (rank × q)
ax3 = axes[2]
q_range = np.arange(3, 60)
n_range = np.arange(1, 16)
gap_matrix = np.zeros((len(n_range), len(q_range)))

for i, n in enumerate(n_range):
    for j, q in enumerate(q_range):
        K_n = n + 1
        gap_matrix[i, j] = max(0, 1 - K_n / q)

im = ax3.imshow(gap_matrix, aspect='auto', cmap='viridis',
                extent=[q_range[0], q_range[-1], n_range[-1]+0.5, n_range[0]-0.5],
                vmin=0, vmax=1)
ax3.set_xlabel('Field size q', fontsize=12)
ax3.set_ylabel('Rank n', fontsize=12)
ax3.set_title('Spectral Gap Landscape', fontsize=13)
plt.colorbar(im, ax=ax3, label='Spectral gap')

# Add boundary contour where gap = 0
ax3.contour(q_range, n_range, gap_matrix, levels=[0.01],
            colors='red', linewidths=2, linestyles='--')
ax3.contour(q_range, n_range, gap_matrix, levels=[0.5],
            colors='white', linewidths=1.5, linestyles='-')

plt.tight_layout()
plt.savefig('rank_stability.png', dpi=150, bbox_inches='tight')
print("Saved rank_stability.png")
