#!/usr/bin/env python3
"""
Visualization: Quadratic Shadow Multiplicity Heatmap

Visualizes the shadow multiplicity m_S(β) for degree-4 homogeneous polynomials
in 3 variables. Each point in the simplex of degree-2 exponents is colored by
its shadow multiplicity (number of ancestor paths). This reveals the geometric
structure of the shadow: high-multiplicity points have many "parents" in the
support, while boundary points have few.

Uses barycentric coordinates on the degree-2 simplex for 3 variables.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as tri
from collections import defaultdict


def compositions(d, n):
    """Generate all weak compositions of d into n parts."""
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in compositions(d - first, n - 1):
            yield (first,) + rest


def compute_shadow_with_multiplicity(support, n_vars):
    """Compute shadow with multiplicities."""
    result = defaultdict(int)
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            ai = list(alpha)
            ai[i] -= 1
            for j in range(n_vars):
                if ai[j] < 1:
                    continue
                beta = list(ai)
                beta[j] -= 1
                result[tuple(beta)] += 1
    return dict(result)


def barycentric_to_cartesian(a, b, c):
    """Convert barycentric coords (a,b,c) to 2D Cartesian for equilateral triangle."""
    total = a + b + c
    if total == 0:
        return 0, 0
    a, b, c = a/total, b/total, c/total
    x = 0.5 * (2*b + c)
    y = (np.sqrt(3)/2) * c
    return x, y


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Three polynomial families
families = [
    ("Pure Powers: x⁴+y⁴+z⁴", {(4,0,0), (0,4,0), (0,0,4)}),
    ("Symmetric: Σ x²y²", {(2,2,0), (2,0,2), (0,2,2)}),
    ("Full Degree 4", set(compositions(4, 3))),
]

for ax_idx, (name, support) in enumerate(families):
    ax = axes[ax_idx]
    n_vars = 3
    
    wsm = compute_shadow_with_multiplicity(support, n_vars)
    all_deg2 = list(compositions(2, 3))
    
    # Plot the shadow
    xs, ys, cs = [], [], []
    for beta in all_deg2:
        x, y = barycentric_to_cartesian(*beta)
        xs.append(x)
        ys.append(y)
        cs.append(wsm.get(beta, 0))
    
    xs, ys, cs = np.array(xs), np.array(ys), np.array(cs)
    
    # Draw triangle outline
    corners_x = [0, 1, 0.5, 0]
    corners_y = [0, 0, np.sqrt(3)/2, 0]
    ax.plot(corners_x, corners_y, 'k-', linewidth=1.5)
    
    # Color-code points by multiplicity
    scatter = ax.scatter(xs, ys, c=cs, s=300, cmap='YlOrRd', edgecolors='black',
                        linewidths=1, zorder=5, vmin=0,
                        vmax=max(max(cs), 1))
    
    # Label points
    for beta, x, y, c in zip(all_deg2, xs, ys, cs):
        label = f"{beta}\nm={int(c)}"
        ax.annotate(label, (x, y), textcoords="offset points",
                   xytext=(0, -25), ha='center', fontsize=7)
    
    # Label support points (degree 4, projected)
    ax.set_title(f"{name}\n|S|={len(support)}, |Sh₂|={len(wsm)}", fontsize=11)
    ax.set_xlim(-0.15, 1.15)
    ax.set_ylim(-0.25, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Add variable labels
    ax.text(-0.08, -0.05, 'x', fontsize=12, fontweight='bold', color='blue')
    ax.text(1.04, -0.05, 'y', fontsize=12, fontweight='bold', color='blue')
    ax.text(0.48, np.sqrt(3)/2 + 0.06, 'z', fontsize=12, fontweight='bold', color='blue')

# Add colorbar
fig.subplots_adjust(right=0.92)
cbar_ax = fig.add_axes([0.94, 0.15, 0.02, 0.7])
cbar = fig.colorbar(scatter, cax=cbar_ax)
cbar.set_label('Shadow Multiplicity m_S(β)', fontsize=11)

fig.suptitle('Quadratic Shadow Structure on the Degree-2 Simplex\n'
             '(3 variables, degree 4 → degree 2 shadow)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")
