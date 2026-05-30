"""
Visualization: Pythagorean Descent Game Analysis

Visualizes the game-theoretic structure of the Pythagorean descent game:
game values, winning/losing classification, and descent tree structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math

# ---- Inline Pythagorean game functions (self-contained) ----

def pythagorean_moves(n):
    """Find all valid Pythagorean descent moves from n."""
    moves = []
    n_sq = n * n
    for m in range(1, n):
        k_sq = n_sq - m * m
        if k_sq > 0:
            k = int(math.isqrt(k_sq))
            if k * k == k_sq:
                moves.append(m)
    return moves

def compute_game_values(max_n):
    """Compute game values for all positions up to max_n."""
    values = {}
    winning = {}
    
    for n in range(0, max_n + 1):
        moves = pythagorean_moves(n)
        if not moves:
            values[n] = 0
            winning[n] = False
        else:
            values[n] = max(values.get(m, 0) + 1 for m in moves)
            winning[n] = any(not winning.get(m, False) for m in moves)
    
    return values, winning

# ---- Compute data ----
max_n = 100
values, winning = compute_game_values(max_n)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Pythagorean Descent Game: Structure and Strategy', 
             fontsize=16, fontweight='bold')

# Plot 1: Game values as bar chart
ax1 = axes[0, 0]
hypotenuses = [n for n in range(2, max_n + 1) if pythagorean_moves(n)]
game_vals = [values[n] for n in hypotenuses]
colors = ['#2ecc71' if winning[n] else '#e74c3c' for n in hypotenuses]

ax1.bar(hypotenuses, game_vals, color=colors, width=0.8, edgecolor='none')
ax1.set_xlabel('Position n (Pythagorean hypotenuses)', fontsize=11)
ax1.set_ylabel('Game Value (Rank)', fontsize=11)
ax1.set_title('Game Values of Pythagorean Positions', fontsize=12)

win_patch = mpatches.Patch(color='#2ecc71', label='Winning')
lose_patch = mpatches.Patch(color='#e74c3c', label='Losing')
ax1.legend(handles=[win_patch, lose_patch], fontsize=10)
ax1.grid(True, alpha=0.3, axis='y')

# Plot 2: Game value distribution
ax2 = axes[0, 1]
val_counts = {}
for n in hypotenuses:
    v = values[n]
    val_counts[v] = val_counts.get(v, 0) + 1

sorted_vals = sorted(val_counts.keys())
counts = [val_counts[v] for v in sorted_vals]

ax2.bar(sorted_vals, counts, color='#3498db', edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Game Value', fontsize=11)
ax2.set_ylabel('Number of Positions', fontsize=11)
ax2.set_title('Distribution of Game Values (n ≤ 100)', fontsize=12)
ax2.grid(True, alpha=0.3, axis='y')

# Plot 3: Descent tree from 65
ax3 = axes[1, 0]

def draw_tree(ax, n, x, y, dx, depth=0, max_depth=4):
    """Draw the descent tree from position n."""
    if depth > max_depth:
        return
    
    moves = pythagorean_moves(n)
    is_win = winning.get(n, False)
    
    color = '#2ecc71' if is_win else '#e74c3c'
    ax.scatter(x, y, s=200, c=color, zorder=5, edgecolor='black', linewidth=1)
    ax.text(x, y, str(n), ha='center', va='center', fontsize=7, fontweight='bold')
    
    if not moves or depth >= max_depth:
        return
    
    n_moves = len(moves)
    if n_moves == 1:
        offsets = [0]
    else:
        offsets = np.linspace(-dx, dx, n_moves)
    
    for i, m in enumerate(moves):
        child_x = x + offsets[i]
        child_y = y - 1
        ax.plot([x, child_x], [y, child_y], 'k-', linewidth=1, alpha=0.5)
        draw_tree(ax, m, child_x, child_y, dx * 0.4, depth + 1, max_depth)

draw_tree(ax3, 65, 0, 0, 4, max_depth=3)
ax3.set_title('Descent Tree from n=65', fontsize=12)
ax3.set_xlim(-6, 6)
ax3.set_ylim(-4.5, 0.8)
ax3.axis('off')

# Plot 4: Winning vs losing positions heatmap
ax4 = axes[1, 1]

# Create a grid showing which positions are winning/losing/non-game
grid_size = 10
grid = np.zeros((grid_size, grid_size))
labels_grid = np.empty((grid_size, grid_size), dtype=object)

for i in range(grid_size):
    for j in range(grid_size):
        n = i * grid_size + j + 1
        if n > max_n:
            grid[i, j] = 0.5  # neutral
            labels_grid[i, j] = ''
        elif not pythagorean_moves(n):
            grid[i, j] = 0  # not a hypotenuse
            labels_grid[i, j] = str(n)
        elif winning.get(n, False):
            grid[i, j] = 1  # winning
            labels_grid[i, j] = str(n)
        else:
            grid[i, j] = -1  # losing
            labels_grid[i, j] = str(n)

cmap = plt.cm.RdYlGn
im = ax4.imshow(grid, cmap=cmap, vmin=-1, vmax=1, aspect='equal')

for i in range(grid_size):
    for j in range(grid_size):
        n = i * grid_size + j + 1
        if n <= max_n:
            fontsize = 6 if n >= 10 else 7
            ax4.text(j, i, labels_grid[i, j], ha='center', va='center', 
                    fontsize=fontsize)

ax4.set_title('Positions 1-100: Win/Lose/Non-game', fontsize=12)
ax4.set_xticks([])
ax4.set_yticks([])

non_patch = mpatches.Patch(color=cmap(0.5), label='Non-hypotenuse')
win2_patch = mpatches.Patch(color=cmap(1.0), label='Winning')
lose2_patch = mpatches.Patch(color=cmap(0.0), label='Losing')
ax4.legend(handles=[win2_patch, lose2_patch, non_patch], 
           fontsize=8, loc='upper right')

plt.tight_layout()
plt.savefig('viz_pythagorean_game.png', dpi=150, bbox_inches='tight')
print("Saved visualization to viz_pythagorean_game.png")
