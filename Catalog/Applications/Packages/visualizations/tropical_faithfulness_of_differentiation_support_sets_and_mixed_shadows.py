#!/usr/bin/env python3
"""
Visualization: Support Sets and Mixed Shadows

Visualizes the core theorem: the support of ∂ᵢ∂ⱼp equals the mixed shadow
of supp(p). Shows the original support, the shadow, and the derivative
support as overlaid lattice point plots.

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random


def partial_derivative(poly, var_idx, n_vars):
    result = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var_idx] >= 1:
            new_coeff = coeff * e[var_idx]
            e[var_idx] -= 1
            new_exp = tuple(e)
            result[new_exp] = result.get(new_exp, 0) + new_coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial(poly, i, j, n_vars):
    return partial_derivative(partial_derivative(poly, j, n_vars), i, n_vars)


def mixed_shadow(supp, i, j, n_vars):
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def convex_hull_2d(points):
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


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Example 1: Faithful individual partial
poly1 = {(3, 1): 2, (2, 2): -1, (1, 3): 3, (2, 1): 1, (1, 2): -2}
supp1 = set(poly1.keys())
shadow1 = mixed_shadow(supp1, 0, 1, 2)
mp1 = mixed_partial(poly1, 0, 1, 2)
deriv_supp1 = set(mp1.keys())

ax = axes[0]
ax.set_title('Theorem 1: Individual ∂₀∂₁ (Always Faithful)', fontsize=12, fontweight='bold')

# Plot grid
for x in range(5):
    for y in range(5):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=4)

# Original support
for pt in supp1:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=18, alpha=0.6, zorder=2)

# Shadow (predicted)
for pt in shadow1:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=14, alpha=0.7, zorder=3)

# Actual derivative support
for pt in deriv_supp1:
    ax.plot(pt[0], pt[1], 'o', color='#4CAF50', markersize=10, zorder=4)

# Draw arrows from shadow to ancestors
for pt in shadow1:
    ancestor = (pt[0] + 1, pt[1] + 1)
    if ancestor in supp1:
        ax.annotate('', xy=ancestor, xytext=pt,
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.5))

ax.set_xlabel('x exponent')
ax.set_ylabel('y exponent')
ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-0.5, 4.5)
ax.set_aspect('equal')
legend_elements = [
    mpatches.Patch(color='#2196F3', alpha=0.6),
    mpatches.Patch(color='#FF9800', alpha=0.7),
    mpatches.Patch(color='#4CAF50'),
]
ax.legend(legend_elements, ['supp(p)', 'Shadow (predicted)', 'supp(∂₀∂₁p) = Shadow ✓'],
          loc='upper right', fontsize=9)

# Example 2: Newton polytope comparison
poly2 = {(4, 0): 1, (3, 1): 2, (2, 2): -1, (1, 3): 1, (0, 4): 3, (2, 1): 1, (1, 2): -1}
supp2 = set(poly2.keys())
shadow2 = mixed_shadow(supp2, 0, 1, 2)

ax = axes[1]
ax.set_title('Newton Polytope: p vs ∂₀∂₁p', fontsize=12, fontweight='bold')

for x in range(5):
    for y in range(5):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=4)

# Hull of original
hull_pts = convex_hull_2d(list(supp2))
if hull_pts:
    hull_closed = hull_pts + [hull_pts[0]]
    ax.fill([p[0] for p in hull_closed], [p[1] for p in hull_closed],
            alpha=0.15, color='#2196F3')
    ax.plot([p[0] for p in hull_closed], [p[1] for p in hull_closed],
            '-', color='#2196F3', linewidth=2, alpha=0.8)

# Hull of shadow
hull_shadow = convex_hull_2d(list(shadow2))
if hull_shadow:
    hull_s_closed = hull_shadow + [hull_shadow[0]]
    ax.fill([p[0] for p in hull_s_closed], [p[1] for p in hull_s_closed],
            alpha=0.15, color='#FF9800')
    ax.plot([p[0] for p in hull_s_closed], [p[1] for p in hull_s_closed],
            '--', color='#FF9800', linewidth=2, alpha=0.8)

for pt in supp2:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=12, zorder=5)
for pt in shadow2:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=10, zorder=5)

ax.set_xlabel('x exponent')
ax.set_ylabel('y exponent')
ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-0.5, 4.5)
ax.set_aspect('equal')
legend_elements2 = [
    mpatches.Patch(color='#2196F3', alpha=0.3),
    mpatches.Patch(color='#FF9800', alpha=0.3),
]
ax.legend(legend_elements2, ['Newt(p)', 'Newt(∂₀∂₁p) = Shadow Polytope'],
          loc='upper right', fontsize=9)

# Example 3: Aggregate with cancellation
poly3 = {(2, 1): 1, (1, 2): 1}
supp3 = set(poly3.keys())

# Antisymmetric: ∂₀∂₁ - ∂₁∂₀ = 0
shadow_01 = mixed_shadow(supp3, 0, 1, 2)
shadow_10 = mixed_shadow(supp3, 1, 0, 2)
agg_shadow = shadow_01 | shadow_10

ax = axes[2]
ax.set_title('Theorem 4: Aggregate Cancellation\n(∂₀∂₁ − ∂₁∂₀ = 0)', fontsize=12, fontweight='bold')

for x in range(4):
    for y in range(4):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=4)

for pt in supp3:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=18, alpha=0.6, zorder=2)

for pt in agg_shadow:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=14, alpha=0.7, zorder=3)
    # Red X to show absence
    ax.plot(pt[0], pt[1], 'x', color='#F44336', markersize=20, markeredgewidth=3, zorder=5)

ax.set_xlabel('x exponent')
ax.set_ylabel('y exponent')
ax.set_xlim(-0.5, 3.5)
ax.set_ylim(-0.5, 3.5)
ax.set_aspect('equal')
legend_elements3 = [
    mpatches.Patch(color='#2196F3', alpha=0.6),
    mpatches.Patch(color='#FF9800', alpha=0.7),
    plt.Line2D([0], [0], marker='x', color='#F44336', linestyle='None',
               markersize=10, markeredgewidth=3),
]
ax.legend(legend_elements3, ['supp(p)', 'Shadow (predicted)', 'Cancelled! (not in supp)'],
          loc='upper right', fontsize=9)

plt.tight_layout()
plt.savefig('viz_support_shadow.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_shadow.png")
