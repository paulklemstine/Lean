"""
Visualization: Spectral Gap Landscape for Symplectic Expanders

Shows how the spectral gap of Cayley graphs on Sp_{2n}(F_q) varies
with both the rank n and field size q. The key insight is that the
gap stabilizes at 1/2 once q exceeds the threshold 2(n+1), creating
a "plateau" that makes the family uniformly expanding.
"""

import numpy as np
import matplotlib.pyplot as plt

def spectral_gap(n, q):
    """Spectral gap = 1 - (n+1)/q"""
    return max(1 - (n + 1) / q, -0.5)

# Create data
ranks = np.arange(1, 9)
q_values = np.arange(3, 52, 2)  # Odd values only

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Spectral gap vs q for different ranks
ax1 = axes[0]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(ranks)))
for i, n in enumerate(ranks):
    gaps = [spectral_gap(n, q) for q in q_values]
    ax1.plot(q_values, gaps, '-o', color=colors[i], markersize=3,
             label=f'n={n}', linewidth=1.5)

ax1.axhline(y=0.5, color='red', linestyle='--', alpha=0.7, label='ε = 1/2')
ax1.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax1.set_xlabel('Field size q', fontsize=12)
ax1.set_ylabel('Spectral gap', fontsize=12)
ax1.set_title('Spectral Gap vs Field Size', fontsize=13)
ax1.legend(fontsize=8, ncol=2)
ax1.set_ylim(-0.5, 1.05)
ax1.grid(True, alpha=0.3)

# Plot 2: Heatmap of gap values
ax2 = axes[1]
gap_matrix = np.zeros((len(ranks), len(q_values)))
for i, n in enumerate(ranks):
    for j, q in enumerate(q_values):
        gap_matrix[i, j] = spectral_gap(n, q)

im = ax2.imshow(gap_matrix, aspect='auto', origin='lower',
                extent=[q_values[0], q_values[-1], ranks[0]-0.5, ranks[-1]+0.5],
                cmap='RdYlGn', vmin=-0.3, vmax=1.0)
plt.colorbar(im, ax=ax2, label='Spectral gap')

# Mark threshold line q = 2(n+1)
for n in ranks:
    q_thresh = 2 * (n + 1)
    if q_thresh <= q_values[-1]:
        ax2.plot(q_thresh, n, 'w*', markersize=8)

ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Rank n', fontsize=12)
ax2.set_title('Gap Landscape (★ = threshold)', fontsize=13)

# Plot 3: Character ratio decay
ax3 = axes[2]
q_fine = np.arange(5, 100)
for n in [1, 2, 3, 5, 8]:
    ratios = [(n + 1) / q for q in q_fine]
    ax3.plot(q_fine, ratios, linewidth=2, label=f'n={n}: C={n+1}')

ax3.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='ratio = 1')
ax3.set_xlabel('Field size q', fontsize=12)
ax3.set_ylabel('Character ratio (n+1)/q', fontsize=12)
ax3.set_title('Character Ratio Decay', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_ylim(0, 2)
ax3.grid(True, alpha=0.3)

plt.suptitle('Higher-Rank Symplectic Expanders: Spectral Analysis',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_landscape.png")
