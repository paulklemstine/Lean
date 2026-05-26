"""
Visualization: Deletion/Contraction Recurrence Tree

Visualizes the recursive certificate compilation process for a small
graphic matroid, showing how the partition function decomposes through
the deletion/contraction recurrence Z_M(w) = Z_{M\\e}(w) + w(e)·Z_{M/e}(w).
"""

import itertools
import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# --- Inline matroid ---
def graphic_matroid_triangle():
    """K₃ graphic matroid: 3 edges, 3 spanning trees."""
    edges = [(0,1),(0,2),(1,2)]
    bases = [sorted(c) for c in itertools.combinations(range(3), 2)]
    return edges, bases

edges, bases = graphic_matroid_triangle()
w = {0: 2.0, 1: 3.0, 2: 5.0}

# Compute partition functions for deletion/contraction tree
def Z(basis_list, weights):
    return sum(math.prod(weights.get(e, 1.0) for e in B) for B in basis_list)

# Level 0: Full matroid
Z_full = Z(bases, w)

# Branch on e=0
# Deletion: bases not containing 0 → {1,2}
del_0 = [B for B in bases if 0 not in B]  # [{1,2}]
Z_del_0 = Z(del_0, w)

# Contraction: bases containing 0, remove 0 → {1}, {2}  
con_0 = [[e for e in B if e != 0] for B in bases if 0 in B]  # [{1}, {2}]
Z_con_0 = Z(con_0, w)

# Verify: Z = Z_del + w(0) * Z_con
Z_check = Z_del_0 + w[0] * Z_con_0

fig, ax = plt.subplots(1, 1, figsize=(14, 8))
ax.set_xlim(-1, 11)
ax.set_ylim(-1, 9)
ax.set_aspect('equal')
ax.axis('off')

def draw_box(ax, x, y, width, height, text, color='lightyellow', fontsize=9):
    rect = mpatches.FancyBboxPatch((x, y), width, height,
                                    boxstyle="round,pad=0.1",
                                    facecolor=color, edgecolor='black', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=fontsize, family='monospace')

def draw_arrow(ax, x1, y1, x2, y2, label="", color='black'):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx, my + 0.25, label, ha='center', va='bottom',
                fontsize=9, color=color, fontweight='bold')

# Root node
draw_box(ax, 2.5, 7, 5, 1.2,
         f"M = graphic(K₃)\n"
         f"Bases: {{01, 02, 12}}\n"
         f"Z = {Z_full:.1f}",
         color='#E8F4FD', fontsize=10)

# Deletion branch
draw_arrow(ax, 3.5, 7, 1.5, 5.7, "M \\ e₀", color='#2196F3')
draw_box(ax, 0, 4.5, 3.5, 1.2,
         f"M \\ e₀\n"
         f"Bases: {{12}}\n"
         f"Z_del = {Z_del_0:.1f}",
         color='#C8E6C9')

# Contraction branch  
draw_arrow(ax, 6.5, 7, 8.5, 5.7, f"w(e₀)={w[0]:.0f} × M / e₀", color='#F44336')
draw_box(ax, 6.5, 4.5, 3.5, 1.2,
         f"M / e₀\n"
         f"Bases: {{1}}, {{2}}\n"
         f"Z_con = {Z_con_0:.1f}",
         color='#FFECB3')

# Further decomposition of contraction
draw_arrow(ax, 7.5, 4.5, 6, 3.2, "M/e₀ \\ e₁", color='#2196F3')
draw_box(ax, 4.5, 2, 3, 1,
         f"Basis: {{2}}\n"
         f"w = {w[2]:.1f}",
         color='#C8E6C9')

draw_arrow(ax, 9, 4.5, 9.5, 3.2, f"w(e₁)={w[1]:.0f} × M/e₀/e₁", color='#F44336')
draw_box(ax, 8, 2, 3, 1,
         f"Basis: {{∅}}\n"
         f"w = 1.0",
         color='#C8E6C9')

# Verification equation
eq_text = (f"Z_M = Z_del + w(e₀) · Z_con\n"
           f"   {Z_full:.1f} = {Z_del_0:.1f} + {w[0]:.0f} × {Z_con_0:.1f} = {Z_check:.1f} ✓")
ax.text(5, 0.5, eq_text, ha='center', va='center',
        fontsize=12, fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF9C4', edgecolor='black'))

# Title
ax.text(5, 8.8, "Deletion/Contraction Recurrence Tree",
        ha='center', va='center', fontsize=16, fontweight='bold')
ax.text(5, 8.3, "Recursive certificate compilation for K₃ graphic matroid",
        ha='center', va='center', fontsize=11, style='italic', color='gray')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#C8E6C9', edgecolor='black', label='Leaf (basis found)'),
    mpatches.Patch(facecolor='#E8F4FD', edgecolor='black', label='Internal node'),
    mpatches.Patch(facecolor='#FFECB3', edgecolor='black', label='Contraction result'),
]
ax.legend(handles=legend_elements, loc='lower left', fontsize=9)

plt.tight_layout()
plt.savefig("viz_recurrence_tree.png", dpi=150, bbox_inches='tight')
print("Saved viz_recurrence_tree.png")
