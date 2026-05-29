#!/usr/bin/env python3
"""
Visualization 2: Feasibility Certificates — Potentials vs Negative Cycles

Visualizes the duality between feasibility certificates (graph potentials)
and infeasibility certificates (negative cycles) for tropical band systems.

Left panel: A feasible system with its graph potential shown on the constraint graph.
Right panel: An infeasible system with the negative cycle highlighted.

This illustrates the bridge theorem: tropical feasibility ↔ graph potentials.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ════════════════════════════════════════════════════════════
# Panel 1: FEASIBLE system with graph potential
# ════════════════════════════════════════════════════════════
ax = axes[0]
ax.set_title("Feasibility Certificate:\nGraph Potential", fontsize=13, fontweight='bold',
             color='darkgreen')

# 4-node system
n = 4
labels = ['$v_0$', '$v_1$', '$v_2$', '$v_3$']
# Place nodes in a square
positions = np.array([[1, 3], [3, 3], [3, 1], [1, 1]], dtype=float)

# Slack constraints (edges with weights)
edges = [
    (0, 1, 3.0),  # v0 → v1, weight 3
    (1, 2, 2.0),  # v1 → v2, weight 2
    (2, 3, 4.0),  # v2 → v3, weight 4
    (3, 0, 1.0),  # v3 → v0, weight 1  (cycle weight = 3+2+4+1 = 10 > 0, OK!)
    (0, 2, 5.0),  # v0 → v2, weight 5
]

# Feasible potential
potential = np.array([2.0, 4.0, 3.0, 1.0])

# Draw edges
for i, j, w in edges:
    pi, pj = positions[i], positions[j]
    mid = (pi + pj) / 2
    dx, dy = pj - pi
    length = np.sqrt(dx**2 + dy**2)
    # Offset for label
    perp = np.array([-dy, dx]) / length * 0.25

    ax.annotate('', xy=pj - 0.15 * np.array([dx, dy]) / length,
                xytext=pi + 0.15 * np.array([dx, dy]) / length,
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    ax.text(mid[0] + perp[0], mid[1] + perp[1], f'{w:.0f}',
            fontsize=10, ha='center', va='center', color='gray',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

# Draw nodes with potential values
for i in range(n):
    circle = plt.Circle(positions[i], 0.3, color='lightgreen',
                        ec='darkgreen', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(positions[i][0], positions[i][1], f'{potential[i]:.0f}',
            ha='center', va='center', fontsize=14, fontweight='bold',
            color='darkgreen', zorder=6)
    ax.text(positions[i][0], positions[i][1] + 0.5, labels[i],
            ha='center', va='center', fontsize=11, color='black')

# Verify and annotate
ax.text(2, -0.3, "✓ All edges: $p_i - p_j \\leq$ weight",
        ha='center', fontsize=11, color='darkgreen', fontweight='bold')
ax.text(2, -0.8, "Cycle: $2+4+3+1 = 10 > 0$ ✓",
        ha='center', fontsize=10, color='gray')

ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-1.5, 4.5)
ax.set_aspect('equal')
ax.axis('off')

# ════════════════════════════════════════════════════════════
# Panel 2: INFEASIBLE system with negative cycle
# ════════════════════════════════════════════════════════════
ax = axes[1]
ax.set_title("Infeasibility Certificate:\nNegative Cycle", fontsize=13, fontweight='bold',
             color='darkred')

# 3-node system with negative cycle
positions2 = np.array([[2, 3.5], [3.5, 0.5], [0.5, 0.5]], dtype=float)
labels2 = ['$v_0$', '$v_1$', '$v_2$']

edges2 = [
    (0, 1, 1.0),   # v0 → v1, weight 1
    (1, 2, 1.0),   # v1 → v2, weight 1
    (2, 0, -3.0),  # v2 → v0, weight -3
]

cycle_weight = sum(w for _, _, w in edges2)

# Draw edges (highlighting the negative cycle)
colors = ['red', 'red', 'red']  # All edges form the cycle
for idx, (i, j, w) in enumerate(edges2):
    pi, pj = positions2[i], positions2[j]
    dx, dy = pj - pi
    length = np.sqrt(dx**2 + dy**2)
    mid = (pi + pj) / 2
    perp = np.array([-dy, dx]) / length * 0.3

    ax.annotate('', xy=pj - 0.2 * np.array([dx, dy]) / length,
                xytext=pi + 0.2 * np.array([dx, dy]) / length,
                arrowprops=dict(arrowstyle='->', color=colors[idx], lw=3))

    weight_color = 'darkred' if w < 0 else 'black'
    ax.text(mid[0] + perp[0], mid[1] + perp[1],
            f'{w:+.0f}',
            fontsize=13, ha='center', va='center', color=weight_color,
            fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                      ec=weight_color, alpha=0.9))

# Draw nodes
for i in range(3):
    circle = plt.Circle(positions2[i], 0.3, color='lightyellow',
                        ec='darkred', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(positions2[i][0], positions2[i][1] + 0.5, labels2[i],
            ha='center', va='center', fontsize=11, color='black')
    ax.text(positions2[i][0], positions2[i][1], '?',
            ha='center', va='center', fontsize=14, fontweight='bold',
            color='darkred', zorder=6)

# Annotate
ax.text(2, -0.8, f"✗ Cycle weight: $1 + 1 + (-3) = {cycle_weight:.0f} < 0$",
        ha='center', fontsize=12, color='darkred', fontweight='bold')
ax.text(2, -1.4, "No assignment can satisfy all constraints",
        ha='center', fontsize=10, color='gray')
ax.text(2, -1.9, "Telescoping: $0 \\leq \\sum s_{ij} < 0$ — contradiction!",
        ha='center', fontsize=10, color='darkred', style='italic')

ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-2.5, 4.5)
ax.set_aspect('equal')
ax.axis('off')

plt.suptitle("Tropical Band Certificates: The Feasibility–Infeasibility Duality",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_certificates.png", dpi=150, bbox_inches='tight')
print("Saved: viz_certificates.png")
