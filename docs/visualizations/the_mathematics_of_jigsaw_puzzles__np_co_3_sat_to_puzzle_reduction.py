#!/usr/bin/env python3
"""
Visualization: 3-SAT to Jigsaw Puzzle Reduction
================================================

Visualizes the reduction from 3-SAT to jigsaw puzzles:
- Shows a concrete 3-SAT formula
- Displays the variable pieces (TRUE/FALSE with complementary edges)
- Shows the clause piece structure
- Demonstrates how satisfying assignments correspond to valid puzzle assemblies

This is the core computational complexity result: solving jigsaw puzzles
is as hard as any NP problem.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# ─── Panel 1: Variable piece encoding ───

ax1 = axes[0, 0]
ax1.set_xlim(-1, 6)
ax1.set_ylim(-1, 4)
ax1.set_aspect('equal')
ax1.set_title('Variable Piece Encoding\n(TRUE=Tab, FALSE=Blank)', fontsize=13, fontweight='bold')

def draw_piece(ax, x, y, label, edges, color='lightyellow'):
    """Draw a jigsaw piece at (x,y) with given edge labels."""
    # Main square
    rect = FancyBboxPatch((x - 0.4, y - 0.4), 0.8, 0.8,
                          boxstyle="round,pad=0.05",
                          facecolor=color, edgecolor='black', linewidth=2)
    ax.add_patch(rect)
    ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')

    # Edge labels
    edge_labels = {'T': ('↑Tab', 'green'), 'B': ('↓Blank', 'red'),
                   'F': ('Flat', 'gray')}
    positions = [(x, y + 0.55, edges[0]),   # top
                 (x + 0.6, y, edges[1]),     # right
                 (x, y - 0.55, edges[2]),    # bottom
                 (x - 0.6, y, edges[3])]     # left

    for px, py, edge in positions:
        color_e = 'green' if edge == 'T' else ('red' if edge == 'B' else 'gray')
        symbol = '▲' if edge == 'T' else ('▼' if edge == 'B' else '─')
        ax.text(px, py, symbol, ha='center', va='center',
                fontsize=10, color=color_e, fontweight='bold')

# Draw TRUE piece for x₁
draw_piece(ax1, 1, 3, 'x₁\nTRUE', ['F', 'T', 'F', 'F'], 'lightgreen')
draw_piece(ax1, 3.5, 3, 'x₁\nFALSE', ['F', 'B', 'F', 'F'], 'lightcoral')

# Arrow showing complementary
ax1.annotate('', xy=(3.0, 3), xytext=(1.6, 3),
            arrowprops=dict(arrowstyle='<->', color='purple', lw=2))
ax1.text(2.3, 3.3, 'Complementary\nright edges', ha='center', fontsize=8, color='purple')

# Draw TRUE piece for x₂
draw_piece(ax1, 1, 1.2, 'x₂\nTRUE', ['F', 'T', 'F', 'F'], 'lightgreen')
draw_piece(ax1, 3.5, 1.2, 'x₂\nFALSE', ['F', 'B', 'F', 'F'], 'lightcoral')

ax1.annotate('', xy=(3.0, 1.2), xytext=(1.6, 1.2),
            arrowprops=dict(arrowstyle='<->', color='purple', lw=2))

ax1.text(5, 2.1, 'Mutual\nExclusion:\nOnly ONE\ncan fit!', ha='center',
         fontsize=10, fontweight='bold', color='darkred',
         bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='darkred'))

ax1.axis('off')

# ─── Panel 2: Clause satisfaction ───

ax2 = axes[0, 1]
ax2.set_xlim(-0.5, 7)
ax2.set_ylim(-1, 5)
ax2.set_aspect('equal')
ax2.set_title('Clause Piece: (x₁ ∨ x₂ ∨ ¬x₃)\nFits if ≥1 literal is TRUE', fontsize=13, fontweight='bold')

# Clause piece
rect = FancyBboxPatch((2, 1.5), 3, 2,
                      boxstyle="round,pad=0.1",
                      facecolor='lightyellow', edgecolor='black', linewidth=2)
ax2.add_patch(rect)
ax2.text(3.5, 2.5, 'Clause C₁\nx₁ ∨ x₂ ∨ ¬x₃', ha='center', va='center',
         fontsize=11, fontweight='bold')

# Input edges from literals
inputs = [('x₁', 1.5, 3.2, 'green'), ('x₂', 1.5, 2.5, 'green'),
          ('¬x₃', 1.5, 1.8, 'red')]
for label, x, y, color in inputs:
    ax2.annotate('', xy=(2, y), xytext=(x, y),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    ax2.text(x - 0.3, y, label, ha='center', va='center', fontsize=10,
             fontweight='bold', color=color)

# Output edge
ax2.annotate('', xy=(6, 2.5), xytext=(5, 2.5),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax2.text(6.3, 2.5, 'SAT', ha='center', va='center', fontsize=10,
         fontweight='bold', color='blue')

# Truth table
ax2.text(3.5, 0.5, 'At least one input must match\nfor piece to fit → clause satisfied!',
         ha='center', va='center', fontsize=9, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='gray'))

ax2.axis('off')

# ─── Panel 3: Complete reduction example ───

ax3 = axes[1, 0]
ax3.set_xlim(-0.5, 8)
ax3.set_ylim(-1, 4)
ax3.set_title('3-SAT → Puzzle Reduction\n(x₁∨x₂∨¬x₃) ∧ (¬x₁∨x₃∨x₂)',
              fontsize=13, fontweight='bold')

# Formula info
formula_text = (
    "Formula: (x₁∨x₂∨¬x₃) ∧ (¬x₁∨x₃∨x₂)\n"
    "Variables: 3\n"
    "Clauses: 2\n"
    "Puzzle pieces: 2×3 + 2 + 2 = 10"
)
ax3.text(0.5, 3, formula_text, fontsize=10, family='monospace',
         verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='black'))

# Show satisfying assignment
sat_text = (
    "Satisfying: x₁=T, x₂=T, x₃=F\n"
    "→ C₁: T∨T∨T = TRUE ✓\n"
    "→ C₂: F∨F∨T = TRUE ✓\n"
    "→ Valid puzzle assembly exists!"
)
ax3.text(4.5, 3, sat_text, fontsize=10, family='monospace',
         verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightgreen', edgecolor='darkgreen'))

# Draw the puzzle strip
pieces_labels = ['TL', 'x₁T', 'x₂T', 'x₃F', 'C₁', 'C₂', 'BR']
piece_colors = ['gray', 'lightgreen', 'lightgreen', 'lightcoral',
                'lightyellow', 'lightyellow', 'gray']

for i, (label, color) in enumerate(zip(pieces_labels, piece_colors)):
    rect = FancyBboxPatch((i + 0.1, 0.1), 0.8, 0.8,
                          boxstyle="round,pad=0.05",
                          facecolor=color, edgecolor='black', linewidth=1.5)
    ax3.add_patch(rect)
    ax3.text(i + 0.5, 0.5, label, ha='center', va='center', fontsize=8,
             fontweight='bold')

ax3.text(3.5, -0.3, 'Assembly corresponds to satisfying assignment',
         ha='center', fontsize=9, style='italic')
ax3.axis('off')

# ─── Panel 4: Piece count scaling ───

ax4 = axes[1, 1]

# Reduction size: N = 2n + m + 2
n_vars = np.arange(1, 51)
for m_clauses_factor in [1, 2, 5, 10]:
    m_clauses = m_clauses_factor * n_vars
    sizes = 2 * n_vars + m_clauses + 2
    ax4.plot(n_vars, sizes, '-', linewidth=2,
             label=f'm = {m_clauses_factor}n clauses')

ax4.set_xlabel('Number of variables (n)', fontsize=12)
ax4.set_ylabel('Number of puzzle pieces', fontsize=12)
ax4.set_title('Reduction Size: N = 2n + m + 2\n(Linear in input size!)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

# Annotate key property
ax4.text(30, 100, 'Polynomial\nreduction!', fontsize=14, fontweight='bold',
         color='darkgreen', ha='center',
         bbox=dict(boxstyle='round', facecolor='lightgreen', edgecolor='darkgreen', alpha=0.7))

plt.tight_layout()
plt.savefig('reduction_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved reduction_visualization.png")
