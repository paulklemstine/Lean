"""
Visualization: The Ordinal Hierarchy ω^0, ω^1, ..., ω^n, ..., ω^ω

Shows the exponential tower of ordinals that arise as game values
in infinite chess. Each ω^n represents a fundamentally different
level of strategic complexity.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# === Left panel: Log-scale visualization of ω^n hierarchy ===
ax1 = axes[0]
n_values = np.arange(0, 8)

# Use log representation: log(ω^n) = n·log(ω)
# We'll represent ω as e (Euler's number) for visualization
log_values = n_values  # log_ω(ω^n) = n

colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(n_values)))
bars = ax1.bar(n_values, [2**n for n in n_values], color=colors, 
               edgecolor='black', linewidth=0.5, alpha=0.8)

ax1.set_yscale('log', base=2)
ax1.set_xlabel('Exponent n', fontsize=12)
ax1.set_ylabel('Relative magnitude (log scale)', fontsize=12)
ax1.set_title('Ordinal Hierarchy: ω^n', fontsize=14, fontweight='bold')

labels = ['1', 'ω', 'ω²', 'ω³', 'ω⁴', 'ω⁵', 'ω⁶', 'ω⁷']
ax1.set_xticks(n_values)
ax1.set_xticklabels(labels, fontsize=10)

# Add ω^ω indicator
ax1.axhline(y=2**8, color='red', linestyle='--', linewidth=2, alpha=0.7)
ax1.text(3.5, 2**8.3, 'ω^ω (limit)', fontsize=11, color='red', 
         ha='center', fontweight='bold')

# === Right panel: Game tree structure for different ordinals ===
ax2 = axes[1]
ax2.set_xlim(-1, 10)
ax2.set_ylim(-0.5, 5.5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('Game Tree Structure by Ordinal Value', fontsize=14, fontweight='bold')

def draw_tree(ax, x, y, depth, width, label, color):
    """Draw a schematic game tree."""
    if depth == 0:
        ax.plot(x, y, 'o', color=color, markersize=6, zorder=5)
        return
    
    ax.plot(x, y, 'o', color=color, markersize=8, zorder=5)
    
    n_children = min(3, depth + 1)
    child_positions = np.linspace(x - width/2, x + width/2, n_children)
    
    for cx in child_positions:
        ax.plot([x, cx], [y, y - 0.8], '-', color=color, linewidth=1.5, alpha=0.6)
        draw_tree(ax, cx, y - 0.8, depth - 1, width / (n_children + 0.5), label, color)

# Draw example trees
tree_configs = [
    (1, 4.5, 1, 0.5, "Value 1\n(1 move)", '#2196F3'),
    (3.5, 4.5, 2, 1.2, "Value 3\n(finite)", '#4CAF50'),
    (6.5, 4.5, 3, 2.0, "Value ω\n(infinite)", '#FF9800'),
    (9, 4.5, 4, 2.5, "Value ω²\n(∞ of ∞)", '#F44336'),
]

for x, y, depth, width, label, color in tree_configs:
    draw_tree(ax2, x, y, min(depth, 3), width, label, color)
    ax2.text(x, y + 0.5, label, ha='center', va='bottom', fontsize=9,
             color=color, fontweight='bold')

# Add dots to indicate infinite branching
for x_pos, y_pos in [(6.5, 1.7), (9, 1.7)]:
    ax2.text(x_pos, y_pos, '⋮', fontsize=14, ha='center', va='center', color='gray')

plt.tight_layout()
plt.savefig('ordinal_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved ordinal_hierarchy.png")
