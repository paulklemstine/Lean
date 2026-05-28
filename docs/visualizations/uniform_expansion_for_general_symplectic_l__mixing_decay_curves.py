#!/usr/bin/env python3
"""
Visualization 2: L² mixing decay curves for the symplectic averaging operator.

Shows the geometric decay of ‖T^k f‖₂ ≤ (1-gap)^k ‖f‖₂ for different
ranks and field sizes. The exponential decay rate is controlled by the
spectral gap, which is in turn controlled by the DL character-ratio bound.

This visualizes Theorem 2 (L² mixing from spectral gap) and demonstrates
the bridge to automorphic spectral theory (Hecke operator decay).
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Decay curves for fixed rank, varying q
ax1 = axes[0]
n = 3  # Sp₆
q_values = [5, 7, 11, 17, 31, 97]
colors1 = plt.cm.plasma(np.linspace(0.1, 0.9, len(q_values)))
steps = np.arange(0, 50)

for i, q in enumerate(q_values):
    K_n = n + 1
    gap = max(0, 1 - K_n / q)
    if gap > 0:
        decay = (1 - gap) ** steps
        ax1.semilogy(steps, decay, '-', color=colors1[i],
                     label=f'q={q} (gap={gap:.3f})', linewidth=1.5)

ax1.set_xlabel('Steps k', fontsize=11)
ax1.set_ylabel('‖T^k f‖₂ / ‖f‖₂', fontsize=11)
ax1.set_title(f'L² Decay for Sp₆(𝔽q)', fontsize=12)
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3, which='both')
ax1.set_ylim(1e-6, 1.1)
ax1.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='ε=0.01')

# Panel 2: Decay curves for fixed q, varying rank
ax2 = axes[1]
q = 11
ranks = [1, 2, 3, 4, 5]
colors2 = plt.cm.viridis(np.linspace(0.15, 0.85, len(ranks)))
steps2 = np.arange(0, 80)

for i, n in enumerate(ranks):
    K_n = n + 1
    gap = max(0, 1 - K_n / q)
    if gap > 0:
        decay = (1 - gap) ** steps2
        ax2.semilogy(steps2, decay, '-', color=colors2[i],
                     label=f'Sp$_{{{2*n}}}$ (K={K_n})', linewidth=1.5)

ax2.set_xlabel('Steps k', fontsize=11)
ax2.set_ylabel('‖T^k f‖₂ / ‖f‖₂', fontsize=11)
ax2.set_title(f'L² Decay across Ranks (q={q})', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, which='both')
ax2.set_ylim(1e-6, 1.1)

# Panel 3: Contraction factor heat map
ax3 = axes[2]
q_range = np.arange(3, 50, 2)
n_range = np.arange(1, 11)
contraction = np.zeros((len(n_range), len(q_range)))

for i, n in enumerate(n_range):
    for j, q in enumerate(q_range):
        K_n = n + 1
        gap = max(0, 1 - K_n / q)
        contraction[i, j] = 1 - gap if gap > 0 else 1.0

im = ax3.imshow(contraction, aspect='auto', cmap='RdYlGn_r',
                extent=[q_range[0], q_range[-1], n_range[-1]+0.5, n_range[0]-0.5],
                vmin=0, vmax=1)
ax3.set_xlabel('Field size q', fontsize=11)
ax3.set_ylabel('Rank n', fontsize=11)
ax3.set_title('Contraction Factor (1−gap)', fontsize=12)
plt.colorbar(im, ax=ax3, label='1 − gap')

# Add contour line where gap = 0 (boundary of expansion)
ax3.contour(q_range, n_range, contraction, levels=[0.99],
            colors='black', linewidths=2, linestyles='--')

plt.tight_layout()
plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
print("Saved mixing_decay.png")
