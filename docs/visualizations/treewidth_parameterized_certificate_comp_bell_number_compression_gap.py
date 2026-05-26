"""
Visualization: Bell Number Gap Analysis

Compares the theoretical FPT bound 2^(k²+k) with the Bell number B(k+1),
showing the "compression gap" — the potential improvement from using
partition-based state compression instead of edge-based branching.

Output: Saves to viz_bell_gap.png via plt.savefig()
"""

import matplotlib.pyplot as plt
import numpy as np


def bell_number(n):
    """Compute the n-th Bell number using the Bell triangle."""
    if n == 0:
        return 1
    tri = [[0] * (n + 1) for _ in range(n + 1)]
    tri[0][0] = 1
    for i in range(1, n + 1):
        tri[i][0] = tri[i - 1][i - 1]
        for j in range(1, i + 1):
            tri[i][j] = tri[i][j - 1] + tri[i - 1][j - 1]
    return tri[n][0]


# Data
ks = list(range(1, 11))
bounds = [2 ** (k ** 2 + k) for k in ks]
bells = [bell_number(k + 1) for k in ks]
bell_sq = [bell_number(k + 1) ** 2 for k in ks]
active_edges = [k * (k + 1) // 2 for k in ks]
edge_bound = [2 ** ae for ae in active_edges]

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('The Bell Number Compression Gap', fontsize=16, fontweight='bold')

# Plot 1: Log-scale comparison
ax1 = axes[0]
ax1.semilogy(ks, bounds, 's-', color='red', label='2^(k²+k) [our bound]',
             markersize=8, linewidth=2)
ax1.semilogy(ks, bell_sq, 'D-', color='orange', label='Bell(k+1)² [conjectured]',
             markersize=8, linewidth=2)
ax1.semilogy(ks, bells, 'o-', color='blue', label='Bell(k+1) [state count]',
             markersize=8, linewidth=2)
ax1.semilogy(ks, edge_bound, '^-', color='green', label='2^(k(k+1)/2) [active edges]',
             markersize=8, linewidth=2)

ax1.set_xlabel('Treewidth k', fontsize=12)
ax1.set_ylabel('Branching Factor (log scale)', fontsize=12)
ax1.set_title('Branching Factor Comparison')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(ks)

# Plot 2: Compression ratio
ax2 = axes[1]
ratios_bell = [bounds[i] / bells[i] for i in range(len(ks))]
ratios_bell_sq = [bounds[i] / bell_sq[i] for i in range(len(ks))]

ax2.semilogy(ks, ratios_bell, 'o-', color='blue', label='2^(k²+k) / Bell(k+1)',
             markersize=8, linewidth=2)
ax2.semilogy(ks, ratios_bell_sq, 'D-', color='orange', label='2^(k²+k) / Bell(k+1)²',
             markersize=8, linewidth=2)

ax2.set_xlabel('Treewidth k', fontsize=12)
ax2.set_ylabel('Compression Ratio (log scale)', fontsize=12)
ax2.set_title('Potential Improvement via Bell Compression')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(ks)

# Plot 3: Table of values
ax3 = axes[2]
ax3.axis('off')

table_data = [['k', 'C(k+1,2)', '2^(k²+k)', 'B(k+1)', 'B(k+1)²', 'Gap']]
for k in range(1, 8):
    ae = k * (k + 1) // 2
    b = bounds[k - 1]
    bell = bells[k - 1]
    bsq = bell_sq[k - 1]
    gap = b // bell if bell > 0 else 0
    table_data.append([
        str(k), str(ae), f'{b:,}', str(bell), f'{bsq:,}', f'{gap:,}x'
    ])

table = ax3.table(cellText=table_data, cellLoc='center', loc='center',
                   colWidths=[0.08, 0.12, 0.2, 0.12, 0.2, 0.15])
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.0, 1.6)

# Color header row
for j in range(6):
    table[0, j].set_facecolor('#4472C4')
    table[0, j].set_text_props(color='white', fontweight='bold')

ax3.set_title('Numerical Values', fontsize=12, pad=20)

plt.tight_layout()
plt.savefig('viz_bell_gap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_bell_gap.png")
