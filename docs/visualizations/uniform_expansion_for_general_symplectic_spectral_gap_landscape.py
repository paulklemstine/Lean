#!/usr/bin/env python3
"""
Visualization: Spectral Gap Landscape for Symplectic Groups

Visualizes how the spectral gap bound 1 - C_n/q varies across
rank n and field size q, showing the "expansion landscape" of
the symplectic group family. The key insight: for fixed rank,
gaps improve with field size; for fixed field, gaps degrade
linearly with rank. The uniform gap (worst over q) depends
only on the threshold field size.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

# Parameters
ranks = np.arange(1, 11)
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]

# Compute gap table
gap_matrix = np.zeros((len(ranks), len(primes)))
for i, n in enumerate(ranks):
    C_n = n + 1
    for j, q in enumerate(primes):
        gap_matrix[i, j] = max(0.0, 1.0 - C_n / q)

# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Heatmap of spectral gaps
ax1 = axes[0]
im = ax1.imshow(gap_matrix, aspect='auto', cmap='RdYlGn', origin='lower',
                vmin=0, vmax=1, interpolation='nearest')
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels(primes, rotation=45, fontsize=7)
ax1.set_yticks(range(len(ranks)))
ax1.set_yticklabels(ranks)
ax1.set_xlabel('Field size q (prime)', fontsize=11)
ax1.set_ylabel('Rank n', fontsize=11)
ax1.set_title('Spectral Gap: 1 - (n+1)/q', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax1, shrink=0.8, label='Gap bound')

# Add contour lines for gap = 0.5
for i, n in enumerate(ranks):
    for j, q in enumerate(primes):
        if gap_matrix[i, j] > 0.01:
            ax1.text(j, i, f'{gap_matrix[i,j]:.2f}', ha='center', va='center',
                    fontsize=5, color='black' if gap_matrix[i,j] > 0.3 else 'white')

# Plot 2: Gap vs q for fixed ranks
ax2 = axes[1]
q_range = np.linspace(3, 80, 200)
colors = cm.viridis(np.linspace(0, 1, 6))
for idx, n in enumerate([1, 2, 3, 5, 7, 10]):
    C_n = n + 1
    gaps = np.maximum(0, 1 - C_n / q_range)
    ax2.plot(q_range, gaps, '-', color=colors[idx], linewidth=2,
             label=f'n={n} (C={C_n})')
    # Mark threshold where gap = 0
    threshold = C_n
    ax2.axvline(x=threshold, color=colors[idx], linestyle=':', alpha=0.3)

ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='Gap = 1/2')
ax2.set_xlabel('Field size q', fontsize=11)
ax2.set_ylabel('Spectral gap bound', fontsize=11)
ax2.set_title('Gap vs Field Size (Fixed Rank)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='lower right')
ax2.set_xlim(3, 80)
ax2.set_ylim(-0.05, 1.05)
ax2.grid(True, alpha=0.3)

# Plot 3: Mixing time vs rank
ax3 = axes[2]
import math
for q in [7, 11, 23, 47, 71]:
    mixing_times = []
    valid_ranks = []
    for n in range(1, 20):
        C_n = n + 1
        gap = 1 - C_n / q
        if gap > 0.01:
            contraction = 1 - gap
            mt = math.ceil(math.log(100) / math.log(1.0 / contraction))
            mixing_times.append(mt)
            valid_ranks.append(n)
    if valid_ranks:
        ax3.semilogy(valid_ranks, mixing_times, 'o-', markersize=4,
                     label=f'q={q}')

ax3.set_xlabel('Rank n', fontsize=11)
ax3.set_ylabel('Mixing time (to ε=0.01)', fontsize=11)
ax3.set_title('Mixing Time vs Rank', fontsize=13, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

plt.suptitle('Uniform Symplectic Expansion: Sp₂ₙ(𝔽_q) Spectral Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
print("Saved spectral_landscape.png")
