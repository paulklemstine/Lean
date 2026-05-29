#!/usr/bin/env python3
"""
Visualization: Shadow Duality Principle
=========================================

Visualizes the core theorem: the Newton polytope of ∂ᵢ∂ⱼp (blue) equals
the convex hull of the quadratic leaf shadow (red dashed). Shows both the
original polynomial support, the shadow generators, and their convex hulls
overlaid to demonstrate exact equality.

Uses matplotlib. Saves output as shadow_duality.png.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch


def quad_leaf_shadow(support, i, j, n_vars):
    """Compute quadratic leaf shadow."""
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def compute_hessian_support(poly, i, j):
    """Compute support of ∂ᵢ∂ⱼp symbolically."""
    dpj = {}
    for exp, coeff in poly.items():
        if exp[j] >= 1:
            new_exp = list(exp)
            new_coeff = coeff * exp[j]
            new_exp[j] -= 1
            new_exp = tuple(new_exp)
            dpj[new_exp] = dpj.get(new_exp, 0) + new_coeff
    dpij = {}
    for exp, coeff in dpj.items():
        if exp[i] >= 1:
            new_exp = list(exp)
            new_coeff = coeff * exp[i]
            new_exp[i] -= 1
            new_exp = tuple(new_exp)
            dpij[new_exp] = dpij.get(new_exp, 0) + new_coeff
    return {k: v for k, v in dpij.items() if abs(v) > 1e-15}


def convex_hull_2d(points):
    """Graham scan convex hull."""
    if len(points) <= 1:
        return list(points)
    points = sorted(set(points))
    if len(points) <= 2:
        return points

    def cross(O, A, B):
        return (A[0] - O[0]) * (B[1] - O[1]) - (A[1] - O[1]) * (B[0] - O[0])

    lower = []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    upper = []
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Tropical Shadow Duality Principle',
             fontsize=16, fontweight='bold', y=0.98)

# ── Example 1: Original support ──
ax = axes[0, 0]
poly = {
    (3, 1): 2, (1, 3): 3, (2, 2): 1,
    (4, 0): 1, (0, 4): 1, (3, 2): 2, (2, 3): -1,
}
support = set(poly.keys())
support_pts = np.array(list(support))

ax.scatter(support_pts[:, 0], support_pts[:, 1], c='forestgreen', s=120,
           zorder=5, edgecolors='darkgreen', linewidths=1.5, label='supp(p)')

hull = convex_hull_2d(list(support))
hull_closed = hull + [hull[0]]
hull_x = [p[0] for p in hull_closed]
hull_y = [p[1] for p in hull_closed]
ax.fill(hull_x, hull_y, alpha=0.15, color='forestgreen')
ax.plot(hull_x, hull_y, 'g-', linewidth=2, alpha=0.7)

ax.set_title('Newton Polytope of p', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_0$ exponent', fontsize=11)
ax.set_ylabel('$x_1$ exponent', fontsize=11)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, 5)
ax.set_ylim(-0.5, 5)
ax.set_aspect('equal')

# ── Example 2: Shadow vs Hessian support ──
ax = axes[0, 1]
i_var, j_var = 0, 1

shadow = quad_leaf_shadow(support, i_var, j_var, 2)
hessian = compute_hessian_support(poly, i_var, j_var)
hessian_supp = set(hessian.keys())

if shadow:
    shadow_pts = np.array(list(shadow))
    ax.scatter(shadow_pts[:, 0], shadow_pts[:, 1], c='crimson', s=150,
               marker='D', zorder=6, edgecolors='darkred', linewidths=1.5,
               label='Shadow (predicted)')

if hessian_supp:
    hess_pts = np.array(list(hessian_supp))
    ax.scatter(hess_pts[:, 0], hess_pts[:, 1], c='royalblue', s=80,
               marker='o', zorder=5, edgecolors='navy', linewidths=1.5,
               alpha=0.7, label='Hessian support (actual)')

# Draw both convex hulls
if len(shadow) >= 3:
    hull_s = convex_hull_2d(list(shadow))
    hull_s_closed = hull_s + [hull_s[0]]
    sx = [p[0] for p in hull_s_closed]
    sy = [p[1] for p in hull_s_closed]
    ax.fill(sx, sy, alpha=0.1, color='crimson')
    ax.plot(sx, sy, 'r--', linewidth=2.5, alpha=0.8, label='Shadow polytope')

if len(hessian_supp) >= 3:
    hull_h = convex_hull_2d(list(hessian_supp))
    hull_h_closed = hull_h + [hull_h[0]]
    hx = [p[0] for p in hull_h_closed]
    hy = [p[1] for p in hull_h_closed]
    ax.plot(hx, hy, 'b-', linewidth=1.5, alpha=0.6, label='Hessian polytope')

ax.set_title(f'Shadow Duality: ∂₀∂₁p', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_0$ exponent', fontsize=11)
ax.set_ylabel('$x_1$ exponent', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# ── Example 3: All four Hessian entries ──
ax = axes[1, 0]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
markers = ['D', 'o', 's', '^']
labels_ij = [(0, 0), (0, 1), (1, 0), (1, 1)]

for idx, (ii, jj) in enumerate(labels_ij):
    sh = quad_leaf_shadow(support, ii, jj, 2)
    if sh:
        pts = np.array(list(sh))
        ax.scatter(pts[:, 0], pts[:, 1], c=colors[idx], s=80,
                   marker=markers[idx], zorder=5, alpha=0.8,
                   edgecolors='black', linewidths=0.8,
                   label=f'Shadow(∂_{ii}∂_{jj})')

ax.set_title('All Hessian Shadow Entries', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_0$ exponent', fontsize=11)
ax.set_ylabel('$x_1$ exponent', fontsize=11)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# ── Example 4: Support function comparison ──
ax = axes[1, 1]
n_angles = 100
angles = np.linspace(0, 2 * np.pi, n_angles)
sf_shadow_vals = []
sf_hessian_vals = []

for theta in angles:
    w = [np.cos(theta), np.sin(theta)]
    if shadow:
        sf_s = max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in shadow)
    else:
        sf_s = 0
    if hessian_supp:
        sf_h = max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in hessian_supp)
    else:
        sf_h = 0
    sf_shadow_vals.append(sf_s)
    sf_hessian_vals.append(sf_h)

ax.plot(np.degrees(angles), sf_shadow_vals, 'r-', linewidth=2.5,
        label='Shadow support fn', alpha=0.8)
ax.plot(np.degrees(angles), sf_hessian_vals, 'b--', linewidth=1.5,
        label='Hessian support fn', alpha=0.8)

ax.set_title('Support Function Comparison (Theorem 3)',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Weight angle (degrees)', fontsize=11)
ax.set_ylabel('Support function value', fontsize=11)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('shadow_duality.png', dpi=150, bbox_inches='tight')
print("Saved shadow_duality.png")
