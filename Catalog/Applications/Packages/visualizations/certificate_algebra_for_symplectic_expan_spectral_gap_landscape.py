"""
Visualization: Spectral Gap Landscape for Symplectic Groups
============================================================
Visualizes how the spectral gap of Sp_{2n}(F_q) varies with rank n
and field size q. The heatmap reveals the expansion/non-expansion
boundary and the rank-field tradeoff theorem: gap ≥ 1/2 when q ≥ 2(n+1).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Compute spectral gaps
ranks = np.arange(1, 16)
fields = np.arange(3, 101, 2)  # odd values only (primes live here)

gap_matrix = np.zeros((len(ranks), len(fields)))
for i, n in enumerate(ranks):
    for j, q in enumerate(fields):
        gap_matrix[i, j] = max(0, 1.0 - (n + 1) / q)

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap
ax = axes[0]
im = ax.imshow(gap_matrix, aspect='auto', origin='lower',
               extent=[fields[0], fields[-1], ranks[0], ranks[-1]],
               cmap='RdYlGn', vmin=0, vmax=1)
plt.colorbar(im, ax=ax, label='Spectral Gap ε')

# Add the q = 2(n+1) threshold line
threshold_q = 2 * (ranks + 1)
ax.plot(threshold_q, ranks, 'w--', linewidth=2, label='q = 2(n+1) [gap = 1/2]')

# Add the q = n+1 boundary (gap = 0)
boundary_q = ranks + 1
ax.plot(boundary_q, ranks, 'r--', linewidth=2, label='q = n+1 [gap = 0]')

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Rank n', fontsize=12)
ax.set_title('Spectral Gap Landscape: Sp₂ₙ(𝔽_q)', fontsize=14)
ax.legend(loc='upper left', fontsize=9, facecolor='white', framealpha=0.9)

# Gap curves for fixed ranks
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.9, 5))
for idx, n in enumerate([1, 2, 4, 8, 15]):
    q_vals = np.arange(n + 2, 100)
    gaps = [1.0 - (n + 1) / q for q in q_vals]
    ax2.plot(q_vals, gaps, color=colors[idx], linewidth=2, label=f'n = {n}')
    # Mark where gap = 1/2
    q_half = 2 * (n + 1)
    if q_half < 100:
        ax2.plot(q_half, 0.5, 'o', color=colors[idx], markersize=8)

ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='gap = 1/2')
ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Spectral gap ε', fontsize=12)
ax2.set_title('Gap Growth with Field Size', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_ylim(0, 1.05)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: spectral_gap_landscape.png")
