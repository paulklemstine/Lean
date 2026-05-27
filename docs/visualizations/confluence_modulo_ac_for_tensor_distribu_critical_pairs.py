#!/usr/bin/env python3
"""
Visualization: Critical Pair Diagram

Shows the 4 critical pairs of the tensor rewrite system and how they join,
demonstrating local confluence modulo AC.

Uses matplotlib to create a diagram saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib
matplotlib.use('Agg')

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle("Critical Pair Analysis: All 4 Pairs Are Joinable Modulo AC",
             fontsize=14, fontweight='bold')

def draw_diamond(ax, top, left, right, bottom, join_type, title, color_left='#2196F3', color_right='#FF9800'):
    """Draw a diamond-shaped confluence diagram."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)

    # Positions
    pos = {'top': (0, 1.2), 'left': (-1.1, 0), 'right': (1.1, 0), 'bottom': (0, -1.2)}

    # Draw arrows
    arrow_props = dict(arrowstyle='->', color='black', lw=1.5)
    ax.annotate('', xy=pos['left'], xytext=pos['top'], arrowprops=arrow_props)
    ax.annotate('', xy=pos['right'], xytext=pos['top'], arrowprops=arrow_props)

    # Dashed arrows to join
    dash_props = dict(arrowstyle='->', color='green', lw=1.5, linestyle='dashed')
    ax.annotate('', xy=pos['bottom'], xytext=pos['left'], arrowprops=dash_props)
    ax.annotate('', xy=pos['bottom'], xytext=pos['right'], arrowprops=dash_props)

    # Text boxes
    bbox_top = dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='black')
    bbox_left = dict(boxstyle='round,pad=0.3', facecolor=color_left, edgecolor='black', alpha=0.3)
    bbox_right = dict(boxstyle='round,pad=0.3', facecolor=color_right, edgecolor='black', alpha=0.3)
    bbox_bottom = dict(boxstyle='round,pad=0.3', facecolor='lightgreen', edgecolor='black')

    ax.text(*pos['top'], top, ha='center', va='center', fontsize=7, bbox=bbox_top)
    ax.text(*pos['left'], left, ha='center', va='center', fontsize=6, bbox=bbox_left)
    ax.text(*pos['right'], right, ha='center', va='center', fontsize=6, bbox=bbox_right)
    ax.text(*pos['bottom'], bottom, ha='center', va='center', fontsize=6, bbox=bbox_bottom)

    # Join type label
    ax.text(0, -0.5, join_type, ha='center', va='center', fontsize=8,
            color='darkgreen', fontweight='bold')

    # Rule labels on arrows
    ax.text(-0.7, 0.75, 'Rule', fontsize=7, color='blue', ha='center', rotation=45)
    ax.text(0.7, 0.75, 'Rule', fontsize=7, color='red', ha='center', rotation=-45)

# CP1
draw_diamond(axes[0][0],
    top="(A⊞B)·(v⊕w)",
    left="(A⊞B)·v ⊕ (A⊞B)·w",
    right="A·(v⊕w) ⊕ B·(v⊕w)",
    bottom="{Av, Aw, Bv, Bw}",
    join_type="≡_AC (vecAdd)",
    title="CP1: Rules 1 & 2")

# CP2
draw_diamond(axes[0][1],
    top="(a⊙A)·(v⊕w)",
    left="(a⊙A)·v ⊕ (a⊙A)·w",
    right="a•(A·(v⊕w))",
    bottom="a•(A·v) ⊕ a•(A·w)",
    join_type="= (exact)",
    title="CP2: Rules 1 & 3")

# CP3
draw_diamond(axes[1][0],
    top="⟨v⊕w, x⊕y⟩",
    left="⟨v,x⊕y⟩ + ⟨w,x⊕y⟩",
    right="⟨v⊕w,x⟩ + ⟨v⊕w,y⟩",
    bottom="{⟨v,x⟩,⟨v,y⟩,⟨w,x⟩,⟨w,y⟩}",
    join_type="≡_AC (scalAdd)",
    title="CP3: Rules 6 & 7")

# CP4
draw_diamond(axes[1][1],
    top="⟨a•v, x⊕y⟩",
    left="⟨a•v,x⟩ + ⟨a•v,y⟩",
    right="a·⟨v, x⊕y⟩",
    bottom="a·⟨v,x⟩ + a·⟨v,y⟩",
    join_type="= (uses Rule 9)",
    title="CP4: Rules 7 & 8")

plt.tight_layout()
plt.savefig("viz_critical_pairs.png", dpi=150, bbox_inches='tight')
print("Saved viz_critical_pairs.png")
