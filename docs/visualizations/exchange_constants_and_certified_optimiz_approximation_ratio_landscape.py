"""
Visualization: Approximation Ratio vs Exchange Constant

Shows how the exchange constant K determines the quality guarantee for
local search algorithms. Plots the certified approximation ratio
ρ = 1 + K·r/w_min as a function of K for various ranks r.
"""

import matplotlib.pyplot as plt
import numpy as np


# Parameters
ranks = [2, 3, 5, 8, 10]
w_min_values = [1.0, 5.0, 10.0]
K_range = np.linspace(0, 2.0, 200)

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# === Panel 1: Ratio vs K for different ranks ===
ax1 = axes[0]
ax1.set_title('Certified Approximation Ratio\nρ = 1 + K·r/w_min  (w_min = 1)',
              fontsize=13, fontweight='bold')

colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(ranks)))
for i, r in enumerate(ranks):
    ratio = 1 + K_range * r / 1.0
    ax1.plot(K_range, ratio, linewidth=2.5, color=colors[i], label=f'rank r = {r}')

ax1.axhline(y=1, color='green', linestyle='--', linewidth=1, alpha=0.7, label='ρ = 1 (exact)')
ax1.axvline(x=0, color='gray', linestyle='-', linewidth=0.5)

# Highlight the K=0 region
ax1.fill_betweenx([0.9, 1 + max(ranks) * 2.1], 0, 0.05, alpha=0.15, color='green')
ax1.annotate('K = 0:\nGreedy is\noptimal', xy=(0.025, 1.5), fontsize=9,
             ha='center', color='darkgreen', fontweight='bold')

ax1.set_xlabel('Exchange Constant K', fontsize=12)
ax1.set_ylabel('Approximation Ratio ρ', fontsize=12)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-0.05, 2.05)
ax1.set_ylim(0.9, 1 + max(ranks) * 2.1)

# === Panel 2: Ratio vs rank for different K values ===
ax2 = axes[1]
ax2.set_title('How Rank Affects the Guarantee\n(w_min = 5)',
              fontsize=13, fontweight='bold')

K_values = [0.0, 0.1, 0.5, 1.0, 2.0]
r_range = np.arange(1, 21)
colors2 = plt.cm.plasma(np.linspace(0.1, 0.9, len(K_values)))

for i, K in enumerate(K_values):
    ratio = 1 + K * r_range / 5.0
    style = '--' if K == 0 else '-'
    ax2.plot(r_range, ratio, linewidth=2.5, color=colors2[i],
             linestyle=style, label=f'K = {K}', marker='o' if K == 0 else None, markersize=3)

ax2.set_xlabel('Rank r (number of elements in basis)', fontsize=12)
ax2.set_ylabel('Approximation Ratio ρ', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 20.5)

# Add annotation
ax2.annotate('Small K + Small rank\n= Strong guarantee',
             xy=(3, 1.1), xytext=(8, 2),
             arrowprops=dict(arrowstyle='->', color='darkblue', lw=1.5),
             fontsize=10, color='darkblue', fontweight='bold')

plt.tight_layout()
plt.savefig('approx_ratio_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: approx_ratio_visualization.png")
plt.close()
