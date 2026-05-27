"""
Visualization 1: Depth-Exponent Relationship

Plots the theoretical descent bound d^(d-k) as a function of depth k for
several dimensions d. Shows how deeper certificates exponentially reduce
the complexity exponent, collapsing to O(D) at k=d.

This is the central visual insight of the theory: certificate depth
interpolates smoothly between generic polynomial bounds and optimal
linear convergence.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ── Left panel: Complexity exponent d^(d-k) vs k ──
ax1 = axes[0]
dimensions = [4, 6, 8, 10, 12]
colors = plt.cm.viridis(np.linspace(0.15, 0.85, len(dimensions)))

for d, color in zip(dimensions, colors):
    k_vals = np.arange(0, d + 1)
    exponents = [d ** (d - k) for k in k_vals]
    ax1.semilogy(k_vals, exponents, 'o-', color=color, label=f'd={d}',
                 markersize=6, linewidth=2)
    # Highlight k=d point
    ax1.plot(d, 1, '*', color=color, markersize=15, zorder=5)

ax1.set_xlabel('Certificate Depth k', fontsize=13)
ax1.set_ylabel('Complexity Factor d^(d-k)', fontsize=13)
ax1.set_title('Depth Controls Descent Complexity', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.annotate('All converge to 1\nat maximal depth',
             xy=(8, 1.5), fontsize=10, ha='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

# ── Right panel: Speed improvement factor per depth increment ──
ax2 = axes[1]
for d, color in zip(dimensions, colors):
    k_vals = np.arange(1, d + 1)
    # Ratio of bound at k-1 to bound at k
    ratios = [d ** (d - k + 1) / d ** (d - k) for k in k_vals]
    ax2.plot(k_vals, ratios, 's-', color=color, label=f'd={d}',
             markersize=6, linewidth=2)

ax2.set_xlabel('Certificate Depth k', fontsize=13)
ax2.set_ylabel('Speed Improvement per Depth', fontsize=13)
ax2.set_title('Each Depth Level Multiplies Speed by d', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, max(dimensions) + 2)

plt.tight_layout()
plt.savefig('viz_depth_exponent.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_exponent.png")
