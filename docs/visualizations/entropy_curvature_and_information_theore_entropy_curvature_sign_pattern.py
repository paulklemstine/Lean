#!/usr/bin/env python3
"""
Visualization: Entropy Curvature Sign Patterns and Depth Comparison

Visualizes the sign pattern of (-1)^k * Δ^k(log a)(n) across distribution families,
showing how the alternating sign structure emerges and how different families
have different curvature depth.

This is self-contained — all functions are inlined.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def iter_forward_diff(f, k):
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature(a, k):
    log_a = [math.log(x) if x > 0 else -100 for x in a]
    return iter_forward_diff(log_a, k)


# Distribution families
families = {
    'Geometric\n(r=0.5)': [(1-0.5)*0.5**m for m in range(20)],
    'Binomial\n(N=15, p=0.4)': [math.comb(15, i)*0.4**i*0.6**(15-i) for i in range(16)],
    'Poisson\n(λ=5)': [math.exp(-5)*5**m/math.factorial(m) for m in range(20)],
    'Ultra-LC\n(N=8)': [math.comb(8, i)**2/math.comb(16, 8) for i in range(9)],
    'Gibbs\n(E=0.5n)': [math.exp(-0.5*m) for m in range(20)],
}

max_order = 7
max_n = 14

fig, axes = plt.subplots(len(families), 1, figsize=(12, 2.5 * len(families)))
fig.suptitle('Entropy Curvature Sign Patterns: sign of (-1)ᵏ · Δᵏ(log a)(n)',
             fontsize=14, fontweight='bold', y=1.02)

# Color scheme: green = positive (sign law holds), red = negative (violation), gray = zero
pos_color = '#27ae60'
neg_color = '#e74c3c'
zero_color = '#bdc3c7'

for ax, (name, seq) in zip(axes, families.items()):
    # Build sign matrix
    sign_mat = np.full((max_order, max_n), np.nan)
    
    for k in range(1, max_order + 1):
        curv = entropy_curvature(seq, k)
        alt_sign = (-1) ** k
        for n in range(min(len(curv), max_n)):
            val = alt_sign * curv[n]
            if abs(val) < 1e-10:
                sign_mat[k-1, n] = 0
            elif val > 0:
                sign_mat[k-1, n] = 1
            else:
                sign_mat[k-1, n] = -1
    
    # Custom colormap
    cmap = plt.cm.colors.ListedColormap([neg_color, zero_color, pos_color])
    bounds = [-1.5, -0.5, 0.5, 1.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)
    
    im = ax.imshow(sign_mat, aspect='auto', cmap=cmap, norm=norm,
                   interpolation='nearest')
    ax.set_ylabel(name, fontsize=10, fontweight='bold', rotation=0, labelpad=80, va='center')
    ax.set_yticks(range(max_order))
    ax.set_yticklabels(range(1, max_order + 1), fontsize=8)
    
    if ax == axes[-1]:
        ax.set_xlabel('Position n', fontsize=11)
    
    # Add grid
    ax.set_xticks(np.arange(-0.5, max_n, 1), minor=True)
    ax.set_yticks(np.arange(-0.5, max_order, 1), minor=True)
    ax.grid(which='minor', color='white', linewidth=0.5)

# Legend
legend_patches = [
    mpatches.Patch(color=pos_color, label='(-1)ᵏ · Δᵏ > 0 (sign law holds)'),
    mpatches.Patch(color=zero_color, label='≈ 0 (flat curvature)'),
    mpatches.Patch(color=neg_color, label='(-1)ᵏ · Δᵏ < 0 (sign violation)'),
]
fig.legend(handles=legend_patches, loc='lower center', ncol=3, fontsize=10,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout()
plt.savefig('viz_depth_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_depth_comparison.png")
