"""
Visualization: Newton Polytope Truncation in 2D

Shows how support contraction transforms the Newton polygon of a polynomial.
The original support (blue) is filtered to points with positive i-coordinate,
then translated by -e_i to produce the contracted support (red).

This visualizes Theorem 1: tropicalTruncate(i, T).supp = supportContract(i, T.supp)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from scipy.spatial import ConvexHull

def exponent_contract(i, m):
    if m[i] == 0:
        return None
    return (m[0] - (1 if i == 0 else 0), m[1] - (1 if i == 1 else 0))

def support_contract(i, S):
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def convex_hull_points(pts):
    if len(pts) < 3:
        return list(pts)
    arr = np.array(list(pts))
    try:
        hull = ConvexHull(arr)
        return [tuple(arr[v]) for v in hull.vertices]
    except:
        return list(pts)

# Setup
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Newton Polytope Truncation: Support Contraction in 2D',
             fontsize=16, fontweight='bold')

# Example supports
examples = [
    ("Cubic: x³ + x²y + xy² + y³ + xy",
     {(3, 0), (2, 1), (1, 2), (0, 3), (1, 1)}),
    ("Degree 4: x⁴ + x³y + x²y² + xy³ + y⁴",
     {(4, 0), (3, 1), (2, 2), (1, 3), (0, 4)}),
]

for row, (title, supp) in enumerate(examples):
    # Original
    ax = axes[row, 0]
    pts = np.array(list(supp))
    ax.scatter(pts[:, 0], pts[:, 1], c='royalblue', s=120, zorder=5,
              edgecolors='navy', linewidth=1.5)
    hull_pts = convex_hull_points(supp)
    if len(hull_pts) >= 3:
        hull_arr = np.array(hull_pts + [hull_pts[0]])
        ax.fill(hull_arr[:, 0], hull_arr[:, 1], alpha=0.15, color='royalblue')
        ax.plot(hull_arr[:, 0], hull_arr[:, 1], 'b-', alpha=0.5, linewidth=1.5)
    for p in supp:
        ax.annotate(f'({p[0]},{p[1]})', p, textcoords="offset points",
                   xytext=(5, 8), fontsize=8)
    ax.set_title(f'{title}\nOriginal Support', fontsize=10)
    ax.set_xlabel('x-exponent')
    ax.set_ylabel('y-exponent')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.set_xlim(-0.5, max(p[0] for p in supp) + 0.5)
    ax.set_ylim(-0.5, max(p[1] for p in supp) + 0.5)

    for col, direction in enumerate([0, 1]):
        ax = axes[row, col + 1]
        contracted = support_contract(direction, supp)
        filtered = {m for m in supp if m[direction] > 0}

        # Plot filtered (faded blue)
        filt_pts = np.array(list(filtered))
        ax.scatter(filt_pts[:, 0], filt_pts[:, 1], c='lightblue', s=80,
                  zorder=3, edgecolors='blue', linewidth=1, alpha=0.5,
                  label='Filtered (m[i]>0)')

        # Draw arrows from filtered to contracted
        for m in filtered:
            mc = exponent_contract(direction, m)
            if mc:
                ax.annotate('', xy=mc, xytext=m,
                           arrowprops=dict(arrowstyle='->', color='gray',
                                          lw=1.5, alpha=0.6))

        # Plot contracted (red)
        c_pts = np.array(list(contracted))
        ax.scatter(c_pts[:, 0], c_pts[:, 1], c='crimson', s=120, zorder=5,
                  edgecolors='darkred', linewidth=1.5, label='Contracted')

        # Convex hull of contracted
        if len(contracted) >= 3:
            hull_c = convex_hull_points(contracted)
            hull_arr = np.array(hull_c + [hull_c[0]])
            ax.fill(hull_arr[:, 0], hull_arr[:, 1], alpha=0.15, color='crimson')
            ax.plot(hull_arr[:, 0], hull_arr[:, 1], 'r-', alpha=0.5, linewidth=1.5)

        for p in contracted:
            ax.annotate(f'({p[0]},{p[1]})', p, textcoords="offset points",
                       xytext=(5, 8), fontsize=8, color='darkred')

        dir_name = 'x' if direction == 0 else 'y'
        ax.set_title(f'Contract direction {dir_name}\n'
                    f'|original| = {len(supp)} → |contracted| = {len(contracted)}',
                    fontsize=10)
        ax.set_xlabel('x-exponent')
        ax.set_ylabel('y-exponent')
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8, loc='upper right')
        ax.set_aspect('equal')
        all_pts = list(supp) + list(contracted)
        ax.set_xlim(-0.5, max(p[0] for p in all_pts) + 0.5)
        ax.set_ylim(-0.5, max(p[1] for p in all_pts) + 0.5)

plt.tight_layout()
plt.savefig('newton_truncation.png', dpi=150, bbox_inches='tight')
print("Saved newton_truncation.png")
