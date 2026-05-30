#!/usr/bin/env python3
"""
Visualization 3: Rook's Graph and the CSP-Graph Coloring Connection

Shows the constraint graph (Rook's graph) for Latin squares, illustrating
the cross-domain connection between constraint satisfaction and graph theory.
A valid Latin square is exactly a proper n-coloring of the Rook's graph.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def draw_rook_graph(ax, n, show_coloring=True):
    """Draw the Rook's graph for an n×n board with optional Latin square coloring."""
    # Colors for the Latin square (Cayley table)
    cmap = plt.cm.Set3
    colors_list = [cmap(i / n) for i in range(n)]

    cell_size = 1.0
    margin = 0.1

    # Draw cells
    for i in range(n):
        for j in range(n):
            x = j * cell_size
            y = (n - 1 - i) * cell_size

            if show_coloring:
                val = (i + j) % n
                color = colors_list[val]
            else:
                color = 'lightgray'

            rect = patches.FancyBboxPatch(
                (x + margin/2, y + margin/2),
                cell_size - margin, cell_size - margin,
                boxstyle="round,pad=0.05",
                facecolor=color, edgecolor='black', linewidth=1.5
            )
            ax.add_patch(rect)

            # Draw the value
            if show_coloring:
                val = (i + j) % n
                ax.text(x + cell_size/2, y + cell_size/2, str(val),
                       ha='center', va='center', fontsize=14, fontweight='bold')

    # Draw constraint edges (a subset for clarity)
    # Row constraints
    for i in range(n):
        y = (n - 1 - i) * cell_size + cell_size/2
        for j in range(n - 1):
            x1 = j * cell_size + cell_size - margin/2
            x2 = (j + 1) * cell_size + margin/2
            ax.plot([x1, x2], [y, y], 'r-', alpha=0.3, linewidth=1.5)

    # Column constraints
    for j in range(n):
        x = j * cell_size + cell_size/2
        for i in range(n - 1):
            y1 = (n - 1 - i) * cell_size + margin/2
            y2 = (n - 2 - i) * cell_size + cell_size - margin/2
            ax.plot([x, x], [y1, y2], 'b-', alpha=0.3, linewidth=1.5)

    ax.set_xlim(-0.2, n * cell_size + 0.2)
    ax.set_ylim(-0.2, n * cell_size + 0.2)
    ax.set_aspect('equal')
    ax.axis('off')


fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# Panel 1: Rook's graph structure (n=4, no coloring)
ax1 = axes[0]
draw_rook_graph(ax1, 4, show_coloring=False)
ax1.set_title("Rook's Graph K₄ □ K₄\n(Constraint Structure)", fontsize=13, fontweight='bold')

# Add legend for constraints
ax1.plot([], [], 'r-', linewidth=2, label='Row constraints')
ax1.plot([], [], 'b-', linewidth=2, label='Column constraints')
ax1.legend(loc='lower center', fontsize=10, ncol=2)

# Panel 2: Valid coloring = Latin square
ax2 = axes[1]
draw_rook_graph(ax2, 4, show_coloring=True)
ax2.set_title("Valid 4-Coloring\n= Latin Square", fontsize=13, fontweight='bold')

# Panel 3: Statistics comparison
ax3 = axes[2]
ns = list(range(2, 11))
degrees = [2*(n-1) for n in ns]
edges = [n**2 * (n-1) for n in ns]
chromatic = ns  # χ(Rook's graph) = n
dc_vals = [(n**2-1)/n**2 for n in ns]

ax3_twin = ax3.twinx()

bars = ax3.bar([n - 0.2 for n in ns], degrees, 0.35, color='#2196F3',
               alpha=0.7, label='Degree 2(n-1)')
ax3.bar([n + 0.2 for n in ns], chromatic, 0.35, color='#4CAF50',
        alpha=0.7, label='χ = n')

line = ax3_twin.plot(ns, dc_vals, 'ro-', linewidth=2, markersize=6,
                     label='d_c(n)')

ax3.set_xlabel('Grid Order n', fontsize=12)
ax3.set_ylabel('Graph Parameter', fontsize=12, color='#2196F3')
ax3_twin.set_ylabel('Critical Density', fontsize=12, color='red')
ax3.set_title('Rook Graph Properties\nvs Critical Density', fontsize=13, fontweight='bold')

# Combine legends
lines1, labels1 = ax3.get_legend_handles_labels()
lines2, labels2 = ax3_twin.get_legend_handles_labels()
ax3.legend(lines1 + lines2, labels1 + labels2, loc='upper left', fontsize=9)

ax3.set_xticks(ns)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('rook_graph_connection.png', dpi=150, bbox_inches='tight')
print("Saved: rook_graph_connection.png")
