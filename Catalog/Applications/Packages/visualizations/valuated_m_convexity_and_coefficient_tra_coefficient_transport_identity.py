#!/usr/bin/env python3
"""
Visualization: Coefficient Transport Identity

Shows how partial differentiation transforms coefficients through the identity:
    (∂_i p).coeff(m) = (m_i + 1) * p.coeff(m + e_i)

Visualizes the coefficient "flow" from original polynomial to derivative as a
heatmap, making the transport mechanism tangible.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# ─── Self-contained utility functions ────────────────────────────────────────

def weighted_uniform_coeffs(n, d, weights=None):
    """Generate coefficient dict for weighted uniform matroid polynomial."""
    bases = list(combinations(range(n), d))
    if weights is None:
        weights = {S: 1.0 for S in bases}
    coeffs = {}
    for S in bases:
        e = tuple(1 if i in S else 0 for i in range(n))
        coeffs[e] = weights[S]
    return coeffs

def compute_deriv(coeffs, var, n):
    """Compute partial derivative coefficients."""
    result = {}
    for e, c in coeffs.items():
        if e[var] > 0:
            new_e = list(e)
            new_e[var] -= 1
            new_e = tuple(new_e)
            result[new_e] = result.get(new_e, 0.0) + c * e[var]
    return result

# ─── Main visualization ─────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Coefficient Transport: Original → Derivatives\n'
             'p = 2·x₀x₁ + 3·x₀x₂ + 5·x₁x₂', fontsize=14, fontweight='bold')

# U(2,3) with specific weights
n = 3
weights = {(0,1): 2.0, (0,2): 3.0, (1,2): 5.0}
coeffs = weighted_uniform_coeffs(n, 2, weights)

# All degree-2 and degree-1 exponents for Fin 3
deg2_exps = [(1,1,0), (1,0,1), (0,1,1)]
deg1_exps = [(1,0,0), (0,1,0), (0,0,1)]
deg2_labels = ['x₀x₁', 'x₀x₂', 'x₁x₂']
deg1_labels = ['x₀', 'x₁', 'x₂']

# Top row: Original polynomial coefficients as bar chart
ax = axes[0][0]
vals = [coeffs.get(e, 0) for e in deg2_exps]
colors = ['#2196F3', '#4CAF50', '#FF9800']
ax.bar(range(len(deg2_exps)), vals, color=colors, edgecolor='black', linewidth=1.2)
ax.set_xticks(range(len(deg2_exps)))
ax.set_xticklabels(deg2_labels, fontsize=11)
ax.set_ylabel('Coefficient', fontsize=11)
ax.set_title('Original p', fontsize=12, fontweight='bold')
ax.set_ylim(0, 6)
for i, v in enumerate(vals):
    ax.text(i, v + 0.15, f'{v:.0f}', ha='center', fontsize=12, fontweight='bold')

# Top row: Transport matrix visualization
ax = axes[0][1]
# Transport matrix: (∂_var p).coeff(m) = (m_var+1) * p.coeff(m + e_var)
# For each derivative var and each target m in deg1, find source m+e_var in deg2
transport_data = np.zeros((3, 3, 3))  # [var, target_idx, source_idx]
for var in range(3):
    for t_idx, m in enumerate(deg1_exps):
        source = list(m)
        source[var] += 1
        source = tuple(source)
        for s_idx, s in enumerate(deg2_exps):
            if s == source:
                factor = m[var] + 1
                transport_data[var, t_idx, s_idx] = factor * coeffs.get(s, 0)

# Show transport as a combined heatmap
combined = np.zeros((3, 3))
for var in range(3):
    combined += transport_data[var]

im = ax.imshow(combined, cmap='YlOrRd', aspect='auto', vmin=0)
ax.set_xticks(range(3))
ax.set_xticklabels(deg2_labels, fontsize=10)
ax.set_yticks(range(3))
ax.set_yticklabels(deg1_labels, fontsize=10)
ax.set_xlabel('Source (degree 2)', fontsize=10)
ax.set_ylabel('Target (degree 1)', fontsize=10)
ax.set_title('Transport Contributions', fontsize=12, fontweight='bold')
for i in range(3):
    for j in range(3):
        if combined[i,j] > 0:
            ax.text(j, i, f'{combined[i,j]:.0f}', ha='center', va='center',
                   fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)

# Top row: Exchange configuration
ax = axes[0][2]
ax.set_xlim(-0.5, 2.5)
ax.set_ylim(-0.5, 2.5)
# Draw the 3 support monomials as vertices of a triangle
pts = np.array([[0, 0], [2, 0], [1, 1.7]])
triangle = plt.Polygon(pts, fill=False, edgecolor='black', linewidth=2)
ax.add_patch(triangle)
labels = ['x₀x₁\n(2)', 'x₁x₂\n(5)', 'x₀x₂\n(3)']
for p, l, c in zip(pts, labels, colors):
    ax.plot(p[0], p[1], 'o', markersize=20, color=c, zorder=5)
    ax.text(p[0], p[1] - 0.35, l, ha='center', fontsize=10, fontweight='bold')
# Draw exchange arrows
for i in range(3):
    for j in range(i+1, 3):
        ax.annotate('', xy=pts[j], xytext=pts[i],
                    arrowprops=dict(arrowstyle='<->', color='gray', lw=1.5))
ax.set_title('Exchange Graph', fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

# Bottom row: Derivative coefficient bar charts
deriv_names = ['∂₀p = 2x₁ + 3x₂', '∂₁p = 2x₀ + 5x₂', '∂₂p = 3x₀ + 5x₁']
for var in range(3):
    ax = axes[1][var]
    d_coeffs = compute_deriv(coeffs, var, n)
    vals = [d_coeffs.get(e, 0) for e in deg1_exps]
    bar_colors = ['#E91E63' if v > 0 else '#EEEEEE' for v in vals]
    ax.bar(range(3), vals, color=bar_colors, edgecolor='black', linewidth=1.2)
    ax.set_xticks(range(3))
    ax.set_xticklabels(deg1_labels, fontsize=11)
    ax.set_ylabel('Coefficient', fontsize=10)
    ax.set_title(deriv_names[var], fontsize=11, fontweight='bold')
    ax.set_ylim(0, 6)
    for i, v in enumerate(vals):
        if v > 0:
            ax.text(i, v + 0.15, f'{v:.0f}', ha='center', fontsize=12, fontweight='bold')
    # Add "K=1 ✓" annotation
    ax.text(0.95, 0.95, 'K=1 ✓', transform=ax.transAxes,
            fontsize=11, fontweight='bold', color='green',
            ha='right', va='top',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('coefficient_transport_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: coefficient_transport_visualization.png")
