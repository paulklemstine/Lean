"""
Visualization: Depth vs Width Tradeoff for ReLU Network Approximation

Shows how the piece count (expressivity) grows as w^L, demonstrating
the exponential advantage of depth over width. The heatmap reveals
that for a fixed parameter budget, deeper networks achieve far more
pieces than wider ones.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

# Compute piece count and parameter count
widths = np.arange(2, 21)
depths = np.arange(1, 16)

W, D = np.meshgrid(widths, depths)
pieces = W.astype(float) ** D.astype(float)
params = 2 * W * D + W + 1

# Cap for visualization
pieces_capped = np.minimum(pieces, 1e15)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Piece count heatmap
ax1 = axes[0]
im1 = ax1.pcolormesh(widths, depths, np.log10(pieces_capped), 
                       cmap='viridis', shading='auto')
ax1.set_xlabel('Width (w)', fontsize=12)
ax1.set_ylabel('Depth (L)', fontsize=12)
ax1.set_title('log₁₀(Piece Count) = L·log₁₀(w)', fontsize=13)
plt.colorbar(im1, ax=ax1, label='log₁₀(w^L)')

# Plot 2: Parameter efficiency (pieces per parameter)
ax2 = axes[1]
efficiency = np.log10(pieces_capped) / params
im2 = ax2.pcolormesh(widths, depths, efficiency,
                       cmap='plasma', shading='auto')
ax2.set_xlabel('Width (w)', fontsize=12)
ax2.set_ylabel('Depth (L)', fontsize=12)
ax2.set_title('Efficiency: log₁₀(pieces) / params', fontsize=13)
plt.colorbar(im2, ax=ax2, label='Bits per parameter')

# Plot 3: Fixed parameter budget comparison
ax3 = axes[2]
param_budgets = [20, 50, 100, 200, 500]
for budget in param_budgets:
    w_range = range(2, 51)
    max_pieces = []
    w_vals = []
    for w in w_range:
        # Max depth for this width within budget
        L_max = max(1, (budget - w - 1) // (2 * w))
        if L_max >= 1:
            p = w ** L_max
            max_pieces.append(min(p, 1e15))
            w_vals.append(w)
    ax3.semilogy(w_vals, max_pieces, '-o', markersize=3, label=f'{budget} params')

ax3.set_xlabel('Width (w)', fontsize=12)
ax3.set_ylabel('Max Pieces (w^L)', fontsize=12)
ax3.set_title('Max Pieces for Fixed Parameter Budget', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('ReLU Network Depth-Width Tradeoff: Depth Dominates', 
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_depth_width.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_width.png")
