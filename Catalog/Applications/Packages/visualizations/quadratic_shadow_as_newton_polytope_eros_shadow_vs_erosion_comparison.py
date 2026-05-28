"""
Visualization: Shadow vs. Erosion in 2D

Visualizes the core theorem: for lattice-saturated supports, the universal
quadratic shadow equals the lattice points of the Minkowski erosion of the
Newton polytope by the degree-2 simplex. Shows both equality (saturated case)
and strict containment (sparse case) side by side.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
from itertools import combinations_with_replacement, product


# ──────────── Self-contained algorithms ────────────

def quadratic_increments(n):
    result = []
    for i in range(n):
        beta = [0] * n; beta[i] = 2; result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n; beta[i] = 1; beta[j] = 1; result.append(tuple(beta))
    return result

def universal_quad_shadow(S, n):
    increments = quadratic_increments(n)
    candidates = None
    for beta in increments:
        shifted = set()
        for alpha in S:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shifted.add(u)
        candidates = shifted if candidates is None else candidates & shifted
    return candidates if candidates is not None else set()

def discrete_quad_shadow(S, n):
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shadow.add(u)
    return shadow

def point_in_convex_hull_2d(point, hull_points):
    from scipy.optimize import linprog
    m = hull_points.shape[0]
    A_eq = np.vstack([hull_points.T, np.ones(m)])
    b_eq = np.append(point, 1.0)
    c = np.zeros(m)
    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=[(0, None)] * m, method='highs')
    return result.success

def eroded_newton_lattice_points(S, n):
    if not S: return set()
    points = np.array(list(S), dtype=float)
    increments = quadratic_increments(n)
    min_c = np.min(points, axis=0).astype(int)
    max_c = np.max(points, axis=0).astype(int)
    result = set()
    for u_tuple in product(*[range(max(0, int(min_c[i])), int(max_c[i]) + 1) for i in range(n)]):
        u = np.array(u_tuple, dtype=float)
        if all(point_in_convex_hull_2d(u + np.array(b, dtype=float), points) for b in increments):
            result.add(u_tuple)
    return result


# ──────────── Visualization ────────────

fig, axes = plt.subplots(2, 3, figsize=(18, 12))

# Case 1: Lattice-saturated (full triangle degree 5)
S_sat = set()
for i in range(6):
    for j in range(6 - i):
        S_sat.add((i, j))

shadow_sat = universal_quad_shadow(S_sat, 2)
erosion_sat = eroded_newton_lattice_points(S_sat, 2)
exist_sat = discrete_quad_shadow(S_sat, 2)

# Case 2: Sparse (vertices only of degree 5 triangle)
S_sparse = {(0, 0), (5, 0), (0, 5)}
shadow_sparse = universal_quad_shadow(S_sparse, 2)
erosion_sparse = eroded_newton_lattice_points(S_sparse, 2)
exist_sparse = discrete_quad_shadow(S_sparse, 2)

def plot_set(ax, S, color, marker, size, label, zorder=3, alpha=1.0):
    if S:
        arr = np.array(list(S))
        ax.scatter(arr[:, 0], arr[:, 1], c=color, s=size, marker=marker,
                   zorder=zorder, label=label, alpha=alpha, edgecolors='black', linewidths=0.5)

def draw_newton_polygon(ax, S, color='blue', alpha=0.1):
    from scipy.spatial import ConvexHull
    pts = np.array(list(S), dtype=float)
    if len(pts) >= 3:
        hull = ConvexHull(pts)
        vertices = pts[hull.vertices]
        polygon = Polygon(vertices, closed=True, facecolor=color, alpha=alpha, edgecolor=color, linewidth=2)
        ax.add_patch(polygon)

# Row 1: Saturated case
ax = axes[0, 0]
draw_newton_polygon(ax, S_sat, 'royalblue', 0.15)
plot_set(ax, S_sat, 'royalblue', 'o', 50, f'Support ({len(S_sat)} pts)')
ax.set_title('Saturated Support S\n(full triangle, deg 5)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[0, 1]
plot_set(ax, exist_sat, 'lightgreen', 's', 80, f'Existential Sh₂ ({len(exist_sat)})', alpha=0.4)
plot_set(ax, shadow_sat, 'darkgreen', 'o', 40, f'Universal Sh₂ ({len(shadow_sat)})')
ax.set_title('Quadratic Shadows\n(existential ⊇ universal)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[0, 2]
plot_set(ax, erosion_sat, 'orange', 'D', 100, f'Erosion lattice ({len(erosion_sat)})', alpha=0.5)
plot_set(ax, shadow_sat, 'red', 'o', 30, f'Universal shadow ({len(shadow_sat)})')
equal_sat = shadow_sat == erosion_sat
ax.set_title(f'Shadow vs Erosion\n(EQUAL = {equal_sat}) ✓', fontsize=11,
             fontweight='bold', color='green' if equal_sat else 'red')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

# Row 2: Sparse case
ax = axes[1, 0]
draw_newton_polygon(ax, S_sparse, 'royalblue', 0.15)
plot_set(ax, S_sparse, 'royalblue', 'o', 80, f'Support ({len(S_sparse)} pts)')
# Show missing lattice points
all_interior = set()
for i in range(6):
    for j in range(6 - i):
        if (i, j) not in S_sparse:
            all_interior.add((i, j))
plot_set(ax, all_interior, 'lightcoral', 'x', 30, f'Missing ({len(all_interior)} pts)', alpha=0.5, zorder=2)
ax.set_title('Sparse Support S\n(vertices only, deg 5)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[1, 1]
plot_set(ax, exist_sparse, 'lightgreen', 's', 80, f'Existential Sh₂ ({len(exist_sparse)})', alpha=0.4)
plot_set(ax, shadow_sparse, 'darkgreen', 'o', 40, f'Universal Sh₂ ({len(shadow_sparse)})')
ax.set_title('Quadratic Shadows\n(sparse: universal much smaller)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[1, 2]
plot_set(ax, erosion_sparse, 'orange', 'D', 100, f'Erosion lattice ({len(erosion_sparse)})', alpha=0.5)
plot_set(ax, shadow_sparse, 'red', 'o', 30, f'Universal shadow ({len(shadow_sparse)})')
gap = erosion_sparse - shadow_sparse
if gap:
    plot_set(ax, gap, 'purple', 'X', 150, f'GAP ({len(gap)} pts)', zorder=6)
equal_sp = shadow_sparse == erosion_sparse
ax.set_title(f'Shadow vs Erosion\n(EQUAL = {equal_sp}) — gap exists!', fontsize=11,
             fontweight='bold', color='green' if equal_sp else 'red')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

fig.suptitle('Newton Polytope Erosion Theory: Shadow = Erosion iff Lattice-Saturated',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('shadow_erosion_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: shadow_erosion_comparison.png")
