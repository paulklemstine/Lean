#!/usr/bin/env python3
"""
Visualization 1: Spectral gaps for symplectic expanders across ranks and field sizes.

This plot shows how the spectral gap 1 - K_n/q varies with field size q
for different ranks n = 1, 2, 3, 4, 5. The key observation is that for
each fixed rank, the gap is uniformly bounded below (by 1 - K_n/q₀) and
improves monotonically toward 1 as q grows.

This visualizes Theorem 1 (rank-aware transference) and Theorem 4
(torus-type stability) from the formalization.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
ranks = [1, 2, 3, 4, 5]
q_values = np.array([3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
                      53, 59, 61, 67, 71, 73, 79, 83, 89, 97])

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Spectral gaps vs q
ax1 = axes[0]
colors = plt.cm.viridis(np.linspace(0.15, 0.85, len(ranks)))
for i, n in enumerate(ranks):
    K_n = n + 1
    gaps = np.maximum(0, 1 - K_n / q_values.astype(float))
    valid = gaps > 0
    ax1.plot(q_values[valid], gaps[valid], 'o-', color=colors[i],
             label=f'Sp$_{{{2*n}}}$  (K={K_n})', markersize=5, linewidth=1.5)
    # Plot the uniform lower bound
    q0 = K_n + 1  # smallest q where gap > 0
    min_gap = 1 - K_n / q0
    ax1.axhline(y=min_gap, color=colors[i], linestyle=':', alpha=0.4, linewidth=1)

ax1.set_xlabel('Field size q', fontsize=12)
ax1.set_ylabel('Spectral gap  (1 − K/q)', fontsize=12)
ax1.set_title('Uniform Spectral Gaps for Sp₂ₙ(𝔽q)', fontsize=13)
ax1.legend(loc='lower right', fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(2, 100)

# Right panel: Mixing time vs q
ax2 = axes[1]
for i, n in enumerate(ranks):
    K_n = n + 1
    gaps = np.maximum(1e-10, 1 - K_n / q_values.astype(float))
    mix_times = np.ceil(np.log(100) / np.log(1 / (K_n / q_values.astype(float))))
    valid = (gaps > 0.01) & (mix_times > 0) & (mix_times < 1e6)
    ax2.semilogy(q_values[valid], mix_times[valid], 's-', color=colors[i],
                 label=f'Sp$_{{{2*n}}}$', markersize=4, linewidth=1.5)

ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Mixing time (ε=0.01)', fontsize=12)
ax2.set_title('Random Walk Mixing Times', fontsize=13)
ax2.legend(loc='upper right', fontsize=10)
ax2.grid(True, alpha=0.3, which='both')
ax2.set_xlim(2, 100)

plt.tight_layout()
plt.savefig('spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gaps.png")
