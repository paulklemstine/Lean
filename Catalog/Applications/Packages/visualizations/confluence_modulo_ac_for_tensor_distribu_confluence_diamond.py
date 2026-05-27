#!/usr/bin/env python3
"""
Visualization: Confluence Diagram — Critical Pair Resolution

Shows how two different rewrite paths from the same term converge
to AC-equivalent normal forms, illustrating the diamond property
modulo AC.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ─── Left panel: Generic confluence diamond ───
ax = axes[0]
ax.set_xlim(-3, 3)
ax.set_ylim(-3.5, 1)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title("Confluence Modulo AC: The Diamond Property", fontsize=13, fontweight='bold')

# Nodes
nodes = {
    't': (0, 0),
    'u': (-2, -1.2),
    'v': (2, -1.2),
    'n1': (-2, -2.8),
    'n2': (2, -2.8),
}

# Draw edges
arrow_style = dict(arrowstyle='->', color='#333', lw=2, connectionstyle='arc3,rad=0.1')
ax.annotate('', xy=nodes['u'], xytext=nodes['t'],
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2.5))
ax.annotate('', xy=nodes['v'], xytext=nodes['t'],
            arrowprops=dict(arrowstyle='->', color='#FF5722', lw=2.5))
ax.annotate('', xy=nodes['n1'], xytext=nodes['u'],
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=1.5, linestyle='dashed'))
ax.annotate('', xy=nodes['n2'], xytext=nodes['v'],
            arrowprops=dict(arrowstyle='->', color='#FF5722', lw=1.5, linestyle='dashed'))

# AC-equivalence line
ax.annotate('', xy=nodes['n2'], xytext=nodes['n1'],
            arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2.5, linestyle='dotted'))

# Node labels
for name, (x, y) in nodes.items():
    labels = {'t': 't', 'u': 'u', 'v': 'v', 'n1': 'n₁', 'n2': 'n₂'}
    ax.plot(x, y, 'o', markersize=20, color='white', markeredgecolor='#333',
            markeredgewidth=2, zorder=5)
    ax.text(x, y, labels[name], ha='center', va='center', fontsize=12,
            fontweight='bold', zorder=6)

# Labels on edges
ax.text(-1.3, -0.3, 'rewrite', fontsize=9, color='#2196F3', rotation=-35)
ax.text(1.3, -0.3, 'rewrite', fontsize=9, color='#FF5722', rotation=35)
ax.text(-2.5, -2, '→*', fontsize=11, color='#2196F3')
ax.text(2.3, -2, '→*', fontsize=11, color='#FF5722')
ax.text(0, -3.1, 'ACEq', fontsize=11, color='#4CAF50', ha='center',
        fontweight='bold')

# Legend text
ax.text(0, -3.5, 'Normal forms n₁ ≡ n₂ modulo\nassociativity-commutativity of addition',
        ha='center', fontsize=9, style='italic', color='#666')

# ─── Right panel: Concrete critical pair ───
ax2 = axes[1]
ax2.set_xlim(-4, 4)
ax2.set_ylim(-5.5, 1)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title("Critical Pair: Rules R1 & R2", fontsize=13, fontweight='bold')

terms = {
    'top': (0, 0, '(A⊞B)·(v⊕w)', '#FFF9C4'),
    'left': (-2.5, -1.5, 'R1: (A⊞B)·v\n    ⊕ (A⊞B)·w', '#BBDEFB'),
    'right': (2.5, -1.5, 'R2: A·(v⊕w)\n    ⊕ B·(v⊕w)', '#FFCCBC'),
    'bl': (-2.5, -3.5, 'Av⊕Bv⊕Aw⊕Bw', '#C8E6C9'),
    'br': (2.5, -3.5, 'Av⊕Aw⊕Bv⊕Bw', '#C8E6C9'),
}

for key, (x, y, text, color) in terms.items():
    bbox = dict(boxstyle='round,pad=0.4', facecolor=color, edgecolor='#666', linewidth=1.5)
    ax2.text(x, y, text, ha='center', va='center', fontsize=9, bbox=bbox)

# Arrows
for src, dst, col in [('top', 'left', '#2196F3'), ('top', 'right', '#FF5722'),
                       ('left', 'bl', '#2196F3'), ('right', 'br', '#FF5722')]:
    sx, sy = terms[src][0], terms[src][1]
    dx, dy = terms[dst][0], terms[dst][1]
    ax2.annotate('', xy=(dx, dy+0.4), xytext=(sx, sy-0.4),
                arrowprops=dict(arrowstyle='->', color=col, lw=2))

# AC equivalence
ax2.annotate('', xy=(2.0, -3.5), xytext=(-2.0, -3.5),
            arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2.5, linestyle='dotted'))
ax2.text(0, -3.5, '≡_AC', fontsize=12, color='#4CAF50', ha='center', va='center',
         fontweight='bold', bbox=dict(facecolor='white', edgecolor='none', pad=2))

ax2.text(0, -4.5, 'Same 4 summands, different association order\n'
         'Av, Bv, Aw, Bw vs. Av, Aw, Bv, Bw',
         ha='center', fontsize=9, style='italic', color='#666')

# Rule labels
ax2.text(-1.5, -0.5, 'R1', fontsize=10, color='#2196F3', fontweight='bold')
ax2.text(1.5, -0.5, 'R2', fontsize=10, color='#FF5722', fontweight='bold')
ax2.text(-3.2, -2.5, 'R2×2', fontsize=9, color='#2196F3')
ax2.text(3.0, -2.5, 'R1×2', fontsize=9, color='#FF5722')

plt.tight_layout()
plt.savefig('viz_confluence.png', dpi=150, bbox_inches='tight')
print("Saved viz_confluence.png")
