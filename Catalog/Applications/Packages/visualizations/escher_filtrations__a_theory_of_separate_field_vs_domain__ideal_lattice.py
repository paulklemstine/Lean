#!/usr/bin/env python3
"""
Visualization: Field vs Domain — Ideal Lattice Comparison

Illustrates why fields have no Escher filtrations while integral domains do.

Left panel: The ideal lattice of a field (only ⊥ and ⊤) — no room for
infinite descent.

Right panel: The ideal lattice of ℤ showing the 2-adic Escher filtration
as a strictly descending chain with vanishing core.

This visualizes Theorems field_not_hasInfiniteEscherHeight and
int_twopow_isEscherFiltration.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

# ============================================================
# Left panel: Field (no Escher filtration possible)
# ============================================================
ax1.set_xlim(-1, 3)
ax1.set_ylim(-0.5, 3.5)
ax1.set_aspect('equal')
ax1.set_title("Ideal Lattice of a Field K\n(No Escher filtration possible)",
              fontsize=13, fontweight='bold', color='#e94560')

# Draw the two ideals
ax1.add_patch(plt.Circle((1, 0.5), 0.3, fill=True, facecolor='#1a1a2e',
                          edgecolor='white', linewidth=2))
ax1.text(1, 0.5, "⊥ = {0}", ha='center', va='center', fontsize=11,
         color='white', fontweight='bold')

ax1.add_patch(plt.Circle((1, 2.5), 0.3, fill=True, facecolor='#e94560',
                          edgecolor='white', linewidth=2))
ax1.text(1, 2.5, "⊤ = K", ha='center', va='center', fontsize=11,
         color='white', fontweight='bold')

# Connection line
ax1.plot([1, 1], [0.8, 2.2], 'w-', linewidth=2, alpha=0.5)

# Explanation text
ax1.text(1, -0.3, "Only two ideals: no room\nfor infinite descent",
         ha='center', va='top', fontsize=10, color='#888888', style='italic')

ax1.set_facecolor('#0a0a1a')
ax1.axis('off')

# ============================================================
# Right panel: ℤ with 2-adic Escher filtration
# ============================================================
ax2.set_xlim(-1, 5)
ax2.set_ylim(-1, 9)
ax2.set_aspect('equal')
ax2.set_title("2-adic Escher Filtration on ℤ\n(Infinite descent, vanishing core)",
              fontsize=13, fontweight='bold', color='#16c79a')

levels = [
    (2, 8, "ℤ = (2⁰)", "#e94560", 0.5),
    (2, 6.5, "(2)ℤ", "#c73e54", 0.45),
    (2, 5.2, "(4)ℤ", "#a83848", 0.40),
    (2, 4.1, "(8)ℤ", "#89323c", 0.35),
    (2, 3.2, "(16)ℤ", "#6a2c30", 0.30),
    (2, 2.5, "(32)ℤ", "#4b2624", 0.25),
    (2, 2.0, "⋮", "#333333", 0.15),
    (2, 1.2, "{0} = ⊥", "#1a1a2e", 0.25),
]

for x, y, label, color, radius in levels:
    if label == "⋮":
        ax2.text(x, y, "⋮", ha='center', va='center', fontsize=20,
                color='#888888', fontweight='bold')
    else:
        ax2.add_patch(plt.Circle((x, y), radius, fill=True, facecolor=color,
                                  edgecolor='white', linewidth=1.5, alpha=0.9))
        ax2.text(x, y, label, ha='center', va='center', fontsize=9,
                color='white', fontweight='bold')

# Draw descent arrows
arrow_pairs = [(8, 6.5), (6.5, 5.2), (5.2, 4.1), (4.1, 3.2), (3.2, 2.5)]
for y_top, y_bot in arrow_pairs:
    ax2.annotate("", xy=(2, y_bot + 0.35), xytext=(2, y_top - 0.35),
                arrowprops=dict(arrowstyle="->", color='#16c79a', lw=1.5))

# Strict descent markers
for y_top, y_bot in arrow_pairs:
    mid_y = (y_top + y_bot) / 2
    ax2.text(3.2, mid_y, "⊋", ha='center', va='center', fontsize=14,
            color='#16c79a', fontweight='bold')

# Label the vanishing core
ax2.annotate("Vanishing\nCore", xy=(2, 1.2), xytext=(3.8, 0.5),
            fontsize=10, color='#16c79a', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#16c79a', lw=1.5),
            ha='center')

ax2.text(2, -0.5, "Strict descent ∧ vanishing core\n= Escher filtration",
         ha='center', va='top', fontsize=10, color='#888888', style='italic')

ax2.set_facecolor('#0a0a1a')
ax2.axis('off')

fig.patch.set_facecolor('#0a0a1a')
plt.tight_layout()
plt.savefig("viz_field_vs_domain.png", dpi=150, bbox_inches='tight',
            facecolor='#0a0a1a')
plt.close()
print("Saved viz_field_vs_domain.png")
