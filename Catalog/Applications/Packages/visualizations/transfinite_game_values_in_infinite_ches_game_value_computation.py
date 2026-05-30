"""
Visualization: Game Value Computation

Shows how game values are computed bottom-up in well-founded games.
Demonstrates the chain game and ordinal game constructions.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# === Left panel: Chain Game Values ===
ax1 = axes[0]
n = 8

# Draw the chain: positions 0 through n
x_positions = np.arange(n + 1)
y_position = 2

# Draw arrows
for i in range(1, n + 1):
    ax1.annotate('', xy=(i - 1, y_position), xytext=(i, y_position),
                arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))

# Draw position circles and labels
for i in range(n + 1):
    circle = plt.Circle((i, y_position), 0.3, fill=True, 
                        color='#E3F2FD' if i > 0 else '#FFCDD2',
                        edgecolor='#1565C0' if i > 0 else '#C62828', 
                        linewidth=2, zorder=5)
    ax1.add_patch(circle)
    ax1.text(i, y_position, str(i), ha='center', va='center', 
             fontsize=11, fontweight='bold', zorder=6)
    # Game value label
    ax1.text(i, y_position - 0.7, f'v={i}', ha='center', va='center',
             fontsize=9, color='#555')

ax1.text(0, y_position + 0.7, '✓', ha='center', va='center',
         fontsize=14, color='red', fontweight='bold')

ax1.set_xlim(-0.8, n + 0.8)
ax1.set_ylim(0.5, 3.5)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title(f'Chain Game (n={n}): Value k at Position k', 
              fontsize=13, fontweight='bold')

# Add legend text
ax1.text(n/2, 0.8, 'Terminal (checkmate) at position 0\n'
         'Each position k has game value k',
         ha='center', va='center', fontsize=10, style='italic',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

# === Right panel: Ordinal Game (α=5) ===
ax2 = axes[1]

alpha = 5
positions = list(range(alpha))

# Draw a grid showing moves (lower triangular matrix)
cell_size = 0.8
grid_x_start = 0.5
grid_y_start = 0.5

# Draw move matrix
for p in range(alpha):
    for q in range(alpha):
        x = grid_x_start + q * cell_size
        y = grid_y_start + (alpha - 1 - p) * cell_size
        
        if q < p:  # q < p means q ∈ moves(p)
            rect = patches.FancyBboxPatch((x, y), cell_size * 0.9, cell_size * 0.9,
                                          boxstyle="round,pad=0.05",
                                          facecolor='#4CAF50', alpha=0.6, 
                                          edgecolor='#2E7D32')
            ax2.add_patch(rect)
            ax2.text(x + cell_size * 0.45, y + cell_size * 0.45, '→',
                    ha='center', va='center', fontsize=10, color='white',
                    fontweight='bold')
        else:
            rect = patches.FancyBboxPatch((x, y), cell_size * 0.9, cell_size * 0.9,
                                          boxstyle="round,pad=0.05",
                                          facecolor='#EEEEEE', alpha=0.4,
                                          edgecolor='#BDBDBD')
            ax2.add_patch(rect)

# Labels
for i in range(alpha):
    # Column labels (target positions)
    ax2.text(grid_x_start + i * cell_size + cell_size * 0.45, 
             grid_y_start + alpha * cell_size + 0.2,
             f'q={i}', ha='center', va='bottom', fontsize=9, fontweight='bold')
    # Row labels (source positions)
    ax2.text(grid_x_start - 0.3, 
             grid_y_start + (alpha - 1 - i) * cell_size + cell_size * 0.45,
             f'p={i}', ha='right', va='center', fontsize=9, fontweight='bold')
    # Game values
    ax2.text(grid_x_start + alpha * cell_size + 0.5,
             grid_y_start + (alpha - 1 - i) * cell_size + cell_size * 0.45,
             f'v(p)={i}', ha='left', va='center', fontsize=9, color='#1565C0',
             fontweight='bold')

ax2.set_xlim(-0.3, grid_x_start + alpha * cell_size + 2)
ax2.set_ylim(-0.3, grid_y_start + alpha * cell_size + 1)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title(f'Ordinal Game (α={alpha}): Move Matrix', 
              fontsize=13, fontweight='bold')

# Legend
ax2.text(grid_x_start + alpha * cell_size / 2, -0.1,
         'Green = valid move (q < p)\n'
         'Game value at position p = p',
         ha='center', va='top', fontsize=9, style='italic',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('game_values.png', dpi=150, bbox_inches='tight')
print("Saved game_values.png")
