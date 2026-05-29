#!/usr/bin/env python3
"""
Visualization 3: Genus-2 Semistable Reduction Types

Visualizes the dual graphs of standard genus-2 semistable reduction types
alongside their computed component group structures. This demonstrates
the conjecture that SNF invariant factors match Néron component groups.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

def draw_graph(ax, vertices, edges, title, subtitle, color='#2196F3'):
    """Draw a simple graph with labeled vertices."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Draw edges
    for (u, v, w) in edges:
        x1, y1 = vertices[u]
        x2, y2 = vertices[v]
        if w == 1:
            ax.plot([x1, x2], [y1, y2], 'k-', linewidth=2)
        else:
            # Draw multiple edges (curved)
            for k in range(w):
                offset = (k - (w-1)/2) * 0.15
                mid_x = (x1 + x2) / 2 + offset * (y2 - y1) / max(0.01, np.sqrt((x2-x1)**2 + (y2-y1)**2))
                mid_y = (y1 + y2) / 2 - offset * (x2 - x1) / max(0.01, np.sqrt((x2-x1)**2 + (y2-y1)**2))
                ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                          arrowprops=dict(arrowstyle='-', color='black', linewidth=1.5,
                                        connectionstyle=f'arc3,rad={offset*0.8}'))
    
    # Draw vertices
    for i, (x, y) in enumerate(vertices):
        circle = plt.Circle((x, y), 0.15, color=color, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(i), ha='center', va='center', fontsize=10,
                color='white', fontweight='bold', zorder=6)
    
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    ax.text(0, -1.3, subtitle, ha='center', va='top', fontsize=9,
            style='italic', color='#555')


fig, axes = plt.subplots(2, 4, figsize=(18, 10))
fig.suptitle('Genus-2 Semistable Reduction Types: Dual Graphs → Component Groups',
             fontsize=15, fontweight='bold', y=0.98)

# Type 1: Single vertex (good reduction)
ax = axes[0, 0]
draw_graph(ax, [(0, 0)], [], 
           'Type I: Good Reduction', 'Φ_J = 0, |Φ_J| = 1')

# Type 2: Two vertices, 1 edge
ax = axes[0, 1]
draw_graph(ax, [(-0.7, 0), (0.7, 0)], [(0, 1, 1)],
           'Type II: One Bridge', 'Φ_J = 0, |Φ_J| = 1')

# Type 3: Banana(2)
ax = axes[0, 2]
draw_graph(ax, [(-0.7, 0), (0.7, 0)], [(0, 1, 2)],
           'Type III: Banana(2)', 'Φ_J ≅ ℤ/2ℤ, |Φ_J| = 2')

# Type 4: Theta graph (banana(3))
ax = axes[0, 3]
draw_graph(ax, [(-0.7, 0), (0.7, 0)], [(0, 1, 3)],
           'Type IV: Theta Graph', 'Φ_J ≅ ℤ/3ℤ, |Φ_J| = 3')

# Type 5: Triangle K₃
ax = axes[1, 0]
verts = [(0, 0.8), (-0.7, -0.5), (0.7, -0.5)]
draw_graph(ax, verts, [(0,1,1), (1,2,1), (0,2,1)],
           'Type V: Triangle K₃', 'Φ_J ≅ ℤ/3ℤ, |Φ_J| = 3', color='#E91E63')

# Type 6: Chain of 3
ax = axes[1, 1]
draw_graph(ax, [(-1, 0), (0, 0), (1, 0)], [(0,1,1), (1,2,1)],
           'Type VI: Chain (tree)', 'Φ_J = 0, |Φ_J| = 1', color='#4CAF50')

# Type 7: Weighted chain
ax = axes[1, 2]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')
verts_wt = [(-1, 0), (0, 0), (1, 0)]
# Draw weight-2 edge with annotation
ax.annotate('', xy=(0, 0), xytext=(-1, 0),
           arrowprops=dict(arrowstyle='-', color='black', linewidth=1.5,
                         connectionstyle='arc3,rad=0.15'))
ax.annotate('', xy=(0, 0), xytext=(-1, 0),
           arrowprops=dict(arrowstyle='-', color='black', linewidth=1.5,
                         connectionstyle='arc3,rad=-0.15'))
ax.plot([0, 1], [0, 0], 'k-', linewidth=2)
ax.text(-0.5, 0.25, 'w=2', ha='center', fontsize=9, color='red')
for i, (x, y) in enumerate(verts_wt):
    circle = plt.Circle((x, y), 0.15, color='#FF9800', zorder=5)
    ax.add_patch(circle)
    ax.text(x, y, str(i), ha='center', va='center', fontsize=10,
            color='white', fontweight='bold', zorder=6)
ax.set_title('Type VII: Weighted Chain', fontsize=11, fontweight='bold', pad=10)
ax.text(0, -1.3, 'Φ_J ≅ ℤ/2ℤ, |Φ_J| = 2', ha='center', va='top', fontsize=9,
        style='italic', color='#555')

# Summary panel
ax = axes[1, 3]
ax.axis('off')
summary = (
    "SUMMARY\n"
    "━━━━━━━━━━━━━━━━━━━━━\n\n"
    "For each dual graph Γ:\n\n"
    "  Φ_J ≅ coker(L_red)\n\n"
    "  |Φ_J| = det(L_red)\n"
    "       = # spanning trees\n\n"
    "SNF of L_red gives the\n"
    "invariant factors of Φ_J.\n\n"
    "This connects:\n"
    "  • Arithmetic geometry\n"
    "  • Tropical geometry\n"
    "  • Spectral graph theory\n"
    "  • Integer linear algebra"
)
ax.text(0.5, 0.5, summary, transform=ax.transAxes,
        fontsize=10, verticalalignment='center', horizontalalignment='center',
        fontfamily='monospace',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('visualize_genus2.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_genus2.png")
