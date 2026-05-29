#!/usr/bin/env python3
"""
Visualization: Loop-Filtered Divergence Complex Structure

Visualizes the 1-skeleton of the divergence complex for φ⁴ in 4D,
showing vertices (graph types) and edges (insertion relations) colored
by filtration level (loop order). Illustrates how the Euler defect
formula computes the persistent bar count.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# ═══ Panel 1: φ⁴₄D complex at loop order 3 ═══════════════════════

ax = axes[0]
ax.set_title("φ⁴₄D Divergence Complex (L≤3)", fontsize=11, fontweight='bold')

# Vertices: (residue_arity, loop_order)
vertices = {
    (2, 1): (1, 2), (4, 1): (3, 2),
    (2, 2): (1, 4), (4, 2): (3, 4),
    (2, 3): (1, 6), (4, 3): (3, 6),
}

colors_by_loop = {1: '#2196F3', 2: '#4CAF50', 3: '#FF9800'}

# Draw edges
edges = [
    ((2,1), (4,1)), ((2,2), (4,2)), ((2,3), (4,3)),  # horizontal
    ((2,1), (2,2)), ((2,2), (2,3)),  # vertical 2-pt
    ((4,1), (4,2)), ((4,2), (4,3)),  # vertical 4-pt
]

for (a1, l1), (a2, l2) in edges:
    x1, y1 = vertices[(a1, l1)]
    x2, y2 = vertices[(a2, l2)]
    ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.5)

# Draw vertices
for (arity, loop), (x, y) in vertices.items():
    color = colors_by_loop[loop]
    ax.plot(x, y, 'o', color=color, markersize=20, zorder=5)
    ax.text(x, y, f"{arity}pt", ha='center', va='center',
            fontsize=8, fontweight='bold', color='white')

# Labels
ax.set_xlim(-0.5, 4.5)
ax.set_ylim(0.5, 7.5)
ax.set_ylabel("Filtration level (loop order)")
for loop in [1, 2, 3]:
    ax.text(-0.3, loop * 2, f"L={loop}", fontsize=9, ha='right', va='center')
ax.set_xticks([])

# Euler defect annotation
V, E, comp = 6, 7, 1
beta = E + comp - V
ax.text(2, 0.8, f"V={V}, E={E}, β₀={comp}\nβ̄ = E+β₀−V = {beta}",
        ha='center', fontsize=9,
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# ═══ Panel 2: Super-renormalizable φ³₆D ═══════════════════════════

ax = axes[1]
ax.set_title("φ³₆D Complex (L≤3)", fontsize=11, fontweight='bold')

vertices2 = {
    (2, 1): (2, 2),
    (2, 2): (2, 4),
    (2, 3): (2, 6),
}

edges2 = [((2,1), (2,2)), ((2,2), (2,3))]

for (a1, l1), (a2, l2) in edges2:
    x1, y1 = vertices2[(a1, l1)]
    x2, y2 = vertices2[(a2, l2)]
    ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.5)

for (arity, loop), (x, y) in vertices2.items():
    color = colors_by_loop[loop]
    ax.plot(x, y, 'o', color=color, markersize=20, zorder=5)
    ax.text(x, y, f"{arity}pt", ha='center', va='center',
            fontsize=8, fontweight='bold', color='white')

ax.set_xlim(0, 4)
ax.set_ylim(0.5, 7.5)
ax.set_ylabel("Filtration level")
for loop in [1, 2, 3]:
    ax.text(-0.1, loop * 2, f"L={loop}", fontsize=9, ha='right', va='center')
ax.set_xticks([])

V2, E2, comp2 = 3, 2, 1
beta2 = E2 + comp2 - V2
ax.text(2, 0.8, f"V={V2}, E={E2}, β₀={comp2}\nβ̄ = {E2}+{comp2}−{V2} = {beta2}",
        ha='center', fontsize=9,
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# ═══ Panel 3: Non-renormalizable (growing) ════════════════════════

ax = axes[2]
ax.set_title("Non-renorm Complex (L≤3)", fontsize=11, fontweight='bold')

vertices3 = {
    (2, 1): (1, 2), (4, 1): (3, 2),
    (2, 2): (0.5, 4), (4, 2): (2, 4), (6, 2): (3.5, 4),
    (2, 3): (0.5, 6), (4, 3): (1.5, 6), (6, 3): (2.5, 6), (8, 3): (3.5, 6),
}

edges3 = [
    ((2,1), (4,1)),
    ((2,2), (4,2)), ((4,2), (6,2)), ((2,2), (6,2)),
    ((2,3), (4,3)), ((4,3), (6,3)), ((6,3), (8,3)),
    ((2,3), (6,3)), ((2,3), (8,3)), ((4,3), (8,3)),
    ((2,1), (2,2)), ((4,1), (4,2)),
    ((2,2), (2,3)), ((4,2), (4,3)), ((6,2), (6,3)),
]

for (a1, l1), (a2, l2) in edges3:
    if (a1, l1) in vertices3 and (a2, l2) in vertices3:
        x1, y1 = vertices3[(a1, l1)]
        x2, y2 = vertices3[(a2, l2)]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1, alpha=0.4)

for (arity, loop), (x, y) in vertices3.items():
    color = colors_by_loop[loop]
    ax.plot(x, y, 'o', color=color, markersize=16, zorder=5)
    ax.text(x, y, f"{arity}", ha='center', va='center',
            fontsize=7, fontweight='bold', color='white')

ax.set_xlim(-0.5, 4.5)
ax.set_ylim(0.5, 7.5)
ax.set_ylabel("Filtration level")
for loop in [1, 2, 3]:
    ax.text(-0.3, loop * 2, f"L={loop}", fontsize=9, ha='right', va='center')
ax.set_xticks([])

ax.text(2, 0.8, "New types at each L\n→ β̄ grows without bound",
        ha='center', fontsize=9, color='red',
        bbox=dict(boxstyle='round', facecolor='mistyrose', alpha=0.9))

# ─── Legend ───────────────────────────────────────────────────────

patches = [mpatches.Patch(color=c, label=f"Loop order {l}")
           for l, c in colors_by_loop.items()]
fig.legend(handles=patches, loc='lower center', ncol=3, fontsize=10)

plt.tight_layout(rect=[0, 0.08, 1, 0.95])
fig.suptitle("Loop-Filtered Divergence Complexes and Euler Defect",
             fontsize=14, fontweight='bold')
plt.savefig("complex_structure.png", dpi=150, bbox_inches='tight')
print("Saved complex_structure.png")
