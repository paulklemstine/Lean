#!/usr/bin/env python3
"""
Visualization: Confluence Diamond Tiling

Visualizes the Strip Lemma proof strategy: how the diamond property
tiles the region between two diverging paths to produce a common reduct.
This illustrates the core inductive argument of diamond_implies_confluence.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# === Panel 1: Single Diamond ===
ax = axes[0]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Diamond Property', fontsize=14, fontweight='bold')

# Diamond shape
diamond_x = [0, -1, 0, 1, 0]
diamond_y = [1, 0, -1, 0, 1]
ax.plot(diamond_x, diamond_y, 'b-', linewidth=2)

# Arrows
ax.annotate('', xy=(-0.85, 0.15), xytext=(0, 1),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax.annotate('', xy=(0.85, 0.15), xytext=(0, 1),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.annotate('', xy=(0, -0.85), xytext=(-0.85, 0.05),
            arrowprops=dict(arrowstyle='->', color='green', lw=2, ls='--'))
ax.annotate('', xy=(0, -0.85), xytext=(0.85, 0.05),
            arrowprops=dict(arrowstyle='->', color='red', lw=2, ls='--'))

# Labels
ax.text(0, 1.2, 'a', fontsize=14, ha='center', fontweight='bold')
ax.text(-1.2, 0, 'b', fontsize=14, ha='center', fontweight='bold')
ax.text(1.2, 0, 'c', fontsize=14, ha='center', fontweight='bold')
ax.text(0, -1.2, 'd', fontsize=14, ha='center', fontweight='bold')
ax.text(-0.7, 0.7, 'r', fontsize=12, ha='center', color='red')
ax.text(0.7, 0.7, 'r', fontsize=12, ha='center', color='green')
ax.text(-0.7, -0.7, 'r', fontsize=12, ha='center', color='green', style='italic')
ax.text(0.7, -0.7, 'r', fontsize=12, ha='center', color='red', style='italic')

ax.text(0, -1.8, '∀ b,c: r(a,b) ∧ r(a,c)\n⟹ ∃d: r(b,d) ∧ r(c,d)',
        fontsize=10, ha='center', style='italic')
ax.axis('off')

# === Panel 2: Strip Lemma ===
ax = axes[1]
ax.set_xlim(-1.5, 5.5)
ax.set_ylim(-2, 2)
ax.set_aspect('equal')
ax.set_title('Strip Lemma (Inductive Tiling)', fontsize=14, fontweight='bold')

# Top path: a → a₁ → a₂ → a₃ = b
top_y = 1.5
for i in range(4):
    ax.plot(i, top_y, 'ko', markersize=8)
    if i < 3:
        ax.annotate('', xy=(i+0.85, top_y), xytext=(i+0.15, top_y),
                    arrowprops=dict(arrowstyle='->', color='blue', lw=2))

# Bottom row: c → d₁ → d₂ → d₃
bot_y = -0.5
for i in range(4):
    ax.plot(i, bot_y, 'ko', markersize=8)
    if i < 3:
        ax.annotate('', xy=(i+0.85, bot_y), xytext=(i+0.15, bot_y),
                    arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))

# Vertical arrows
for i in range(4):
    ax.annotate('', xy=(i, bot_y+0.15), xytext=(i, top_y-0.15),
                arrowprops=dict(arrowstyle='->', color='orange', lw=1.5,
                               ls='-' if i == 0 else '--'))

# Labels
labels_top = ['a', 'a₁', 'a₂', 'b']
labels_bot = ['c', 'd₁', 'd₂', 'd₃']
for i, (lt, lb) in enumerate(zip(labels_top, labels_bot)):
    ax.text(i, top_y + 0.3, lt, fontsize=12, ha='center', fontweight='bold')
    ax.text(i, bot_y - 0.35, lb, fontsize=12, ha='center', fontweight='bold')

# Diamond overlays
for i in range(3):
    diamond = patches.FancyBboxPatch((i-0.1, bot_y-0.1), 1.2, top_y-bot_y+0.2,
                                      boxstyle="round,pad=0.1",
                                      facecolor='lightyellow', edgecolor='gray',
                                      alpha=0.3, linewidth=1)
    ax.add_patch(diamond)

ax.text(2, -1.5, 'Each small diamond uses\nthe diamond property once',
        fontsize=10, ha='center', style='italic')
ax.axis('off')

# === Panel 3: Full Confluence ===
ax = axes[2]
ax.set_xlim(-2, 2)
ax.set_ylim(-3, 1.5)
ax.set_aspect('equal')
ax.set_title('Confluence (Diamond ⟹ CR)', fontsize=14, fontweight='bold')

# Source
ax.plot(0, 1, 'ko', markersize=10)
ax.text(0, 1.3, 'a', fontsize=14, ha='center', fontweight='bold')

# Left path: a →* b
left_pts = [(0, 1), (-0.5, 0.3), (-1, -0.4), (-1.2, -1.2)]
for i in range(len(left_pts)-1):
    ax.annotate('', xy=left_pts[i+1], xytext=left_pts[i],
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.plot(*left_pts[i+1], 'ro', markersize=6)
ax.text(-1.5, -1.2, 'b', fontsize=14, ha='center', fontweight='bold', color='red')

# Right path: a →* c
right_pts = [(0, 1), (0.5, 0.3), (1, -0.4), (1.2, -1.2)]
for i in range(len(right_pts)-1):
    ax.annotate('', xy=right_pts[i+1], xytext=right_pts[i],
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.plot(*right_pts[i+1], 'go', markersize=6)
ax.text(1.5, -1.2, 'c', fontsize=14, ha='center', fontweight='bold', color='green')

# Joining paths
join_pt = (0, -2.5)
ax.annotate('', xy=join_pt, xytext=left_pts[-1],
            arrowprops=dict(arrowstyle='->', color='green', lw=2, ls='--'))
ax.annotate('', xy=join_pt, xytext=right_pts[-1],
            arrowprops=dict(arrowstyle='->', color='red', lw=2, ls='--'))
ax.plot(*join_pt, 'ko', markersize=10)
ax.text(0, -2.8, 'd', fontsize=14, ha='center', fontweight='bold')

# Fill region
from matplotlib.patches import Polygon
region = Polygon([left_pts[-1], (0, 1), right_pts[-1], join_pt],
                  alpha=0.1, color='blue')
ax.add_patch(region)

ax.text(0, -3.3, '∀ b,c: a →* b ∧ a →* c\n⟹ ∃d: b →* d ∧ c →* d',
        fontsize=10, ha='center', style='italic')
ax.axis('off')

plt.suptitle('From Diamond Property to Confluence', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('confluence_diagram.png', dpi=150, bbox_inches='tight')
print("Saved confluence_diagram.png")
