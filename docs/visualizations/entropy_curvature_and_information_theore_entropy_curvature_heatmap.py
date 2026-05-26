#!/usr/bin/env python3
"""
Visualization: Entropy Curvature Heatmap

Visualizes the entropy curvature profile Δ^k(log a)(n) as a heatmap
for several distribution families. Each row is a different order k,
each column is a position n. Color encodes the sign and magnitude
of the curvature, revealing how curvature structure varies across
distribution families.

This is self-contained — all functions are inlined.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


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


def make_curvature_matrix(a, max_order, max_n):
    """Build a matrix where entry (k, n) = Δ^k(log a)(n), padded with NaN."""
    mat = np.full((max_order, max_n), np.nan)
    for k in range(1, max_order + 1):
        curv = entropy_curvature(a, k)
        for n in range(min(len(curv), max_n)):
            mat[k - 1, n] = curv[n]
    return mat


# Distribution families
N_terms = 18
max_order = 8

distributions = {
    'Geometric (r=0.5)': [(1 - 0.5) * 0.5**m for m in range(N_terms)],
    'Binomial (N=15, p=0.4)': [math.comb(15, i) * 0.4**i * 0.6**(15-i)
                                for i in range(min(16, N_terms))],
    'Poisson (λ=5)': [math.exp(-5) * 5**m / math.factorial(m)
                       for m in range(N_terms)],
    'Gibbs (E=0.3n+1)': [math.exp(-(0.3 * m + 1)) for m in range(N_terms)],
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Entropy Curvature Heatmaps: Δᵏ(log a)(n)', fontsize=16, fontweight='bold')

# Diverging colormap centered at 0
cmap = plt.cm.RdBu_r

for ax, (name, seq) in zip(axes.flat, distributions.items()):
    mat = make_curvature_matrix(seq, max_order, N_terms)
    
    # Symmetric color scale
    vmax = np.nanmax(np.abs(mat))
    if vmax < 1e-10:
        vmax = 1.0
    
    im = ax.imshow(mat, aspect='auto', cmap=cmap, vmin=-vmax, vmax=vmax,
                   interpolation='nearest')
    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlabel('Position n')
    ax.set_ylabel('Order k')
    ax.set_yticks(range(max_order))
    ax.set_yticklabels(range(1, max_order + 1))
    plt.colorbar(im, ax=ax, shrink=0.8, label='Curvature value')

plt.tight_layout()
plt.savefig('viz_curvature_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_curvature_heatmap.png")
