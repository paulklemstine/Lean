#!/usr/bin/env python3
"""
Visualization: Support Function Polar Plot
=============================================

Visualizes the support function of the shadow polytope as a polar plot.
The support function h(w) = max⟨w, α⟩ over shadow generators encodes
the shape of the Newton polytope. By Theorem 3 (Tropical-Algebraic Bridge),
this equals the support function of the Hessian Newton polytope.

The polar plot shows h(w) for w = (cos θ, sin θ), revealing the
directional complexity of the Hessian entry.

Uses matplotlib. Saves output as support_function_polar.png.
"""

import numpy as np
import matplotlib.pyplot as plt


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


def support_function_eval(generators, w):
    """Evaluate support function max⟨w, α⟩."""
    if not generators:
        return 0.0
    return max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in generators)


# Polynomial: p = x⁴ + y⁴ + 3x²y² + 2x³y + xy³ + x²y + xy²
poly_support = {(4, 0), (0, 4), (2, 2), (3, 1), (1, 3), (2, 1), (1, 2)}
n_vars = 2

fig, axes = plt.subplots(2, 2, figsize=(12, 12),
                          subplot_kw={'projection': 'polar'})
fig.suptitle('Support Function Polar Plots — Shadow Polytopes',
             fontsize=14, fontweight='bold', y=0.98)

pairs = [(0, 0), (0, 1), (1, 0), (1, 1)]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

angles = np.linspace(0, 2 * np.pi, 360, endpoint=False)

for idx, (i, j) in enumerate(pairs):
    ax = axes[idx // 2][idx % 2]
    shadow = quad_leaf_shadow(poly_support, i, j, n_vars)

    if shadow:
        # Compute support function
        values = []
        for theta in angles:
            w = [np.cos(theta), np.sin(theta)]
            values.append(support_function_eval(shadow, w))
        values = np.array(values)

        # Normalize for visibility
        values_shifted = values - values.min() + 0.5

        ax.fill(angles, values_shifted, alpha=0.2, color=colors[idx])
        ax.plot(angles, values_shifted, color=colors[idx], linewidth=2)

        # Mark vertices of shadow
        for pt in shadow:
            r = np.sqrt(pt[0]**2 + pt[1]**2) + 0.5
            theta_pt = np.arctan2(pt[1], pt[0])
            ax.plot(theta_pt, r, 'o', color=colors[idx], markersize=8,
                    markeredgecolor='black', markeredgewidth=1)

    ax.set_title(f'∂_{i}∂_{j}p — Shadow: {sorted(shadow) if shadow else "∅"}',
                 fontsize=11, fontweight='bold', pad=15)
    ax.set_rticks([])

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('support_function_polar.png', dpi=150, bbox_inches='tight')
print("Saved support_function_polar.png")
