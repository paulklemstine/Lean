#!/usr/bin/env python3
"""
Visualization: Chain Game Values and the Path to ω

Shows how finite chain games witness every finite ordinal,
with ω as their supremum.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Chain games as trees
ax = axes[0]

max_n = 6
y_offset = 0

for n in range(max_n + 1):
    y = y_offset + n * 1.5
    # Draw chain: n+1 nodes
    for k in range(n + 1):
        x = k * 1.2 + 0.5
        # Color by game value
        color = plt.cm.viridis(k / max(max_n, 1))
        circle = plt.Circle((x, y), 0.3, color=color, ec='black', linewidth=1.5)
        ax.add_patch(circle)
        ax.text(x, y, str(k), ha='center', va='center', fontsize=10, fontweight='bold', color='white')
        
        # Draw arrow from k to k-1 (move)
        if k > 0:
            ax.annotate('', xy=(x - 1.2 + 0.35, y), xytext=(x - 0.35, y),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Label
    ax.text(-0.5, y, f'n={n}:', ha='right', va='center', fontsize=10, fontweight='bold')
    ax.text((n + 1) * 1.2 + 0.3, y, f'value = {n}', ha='left', va='center',
            fontsize=10, color='darkblue', fontstyle='italic')

ax.set_xlim(-1.5, max_n * 1.2 + 3)
ax.set_ylim(-1, max_n * 1.5 + 1.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Chain Games: Position k Has Value k\n(arrows show moves)', fontsize=13)

# Panel 2: Game values approaching ω
ax2 = axes[1]

n_values = list(range(1, 16))
game_values = n_values  # Chain game n has max value n

# Plot finite values
bars = ax2.bar(n_values, game_values, color=[plt.cm.viridis(v/15) for v in game_values],
               edgecolor='black', alpha=0.8, label='Chain game value')

# Add ω line
ax2.axhline(y=16, color='red', linestyle='--', linewidth=2, alpha=0.7, label='ω (supremum)')
ax2.text(15.5, 16.3, 'ω', fontsize=16, color='red', fontweight='bold')

# Add "..." indicator
ax2.text(15.7, 15.2, '...', fontsize=20, color='gray', fontweight='bold')

# Annotations
ax2.annotate('Every finite value\nis achieved', xy=(8, 8), xytext=(10, 4),
             fontsize=10, ha='center',
             arrowprops=dict(arrowstyle='->', color='blue'),
             bbox=dict(boxstyle='round,pad=0.3', fc='lightyellow', ec='blue'))

ax2.annotate('ω = sup{n : n ∈ ℕ}\nFirst infinite ordinal', xy=(13, 16), xytext=(8, 18),
             fontsize=10, ha='center',
             arrowprops=dict(arrowstyle='->', color='red'),
             bbox=dict(boxstyle='round,pad=0.3', fc='mistyrose', ec='red'))

ax2.set_xlabel('Chain Game Length (n)', fontsize=12)
ax2.set_ylabel('Game Value at Top Position', fontsize=12)
ax2.set_title('Finite Game Values Approaching ω\n(transfinite_chess_conjecture_true)', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 20)

plt.tight_layout()
plt.savefig('viz_game_values.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_game_values.png")
