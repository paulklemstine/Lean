"""
Visualization: Gram Matrix Bridge — Tropical Margin as Geometric Separation

Demonstrates the cross-domain theorem: for Gram matrices G = X·Xᵀ,
the tropical symmetric margin equals the minimum pairwise squared distance.
This bridges tropical optimization to metric geometry and kernel methods.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle


def pair_slack(W, i, j):
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def trop_sym_margin_with_witness(W):
    n = W.shape[0]
    best, bi, bj = float('inf'), 0, 1
    for i in range(n):
        for j in range(i+1, n):
            s = pair_slack(W, i, j)
            if s < best:
                best, bi, bj = s, i, j
    return best, bi, bj


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Points with closest pair highlighted
ax = axes[0]
rng = np.random.default_rng(42)
n_points = 8
points = rng.standard_normal((n_points, 2)) * 2
G = points @ points.T
margin, ci, cj = trop_sym_margin_with_witness(G)

# Draw all edges faintly
for i in range(n_points):
    for j in range(i+1, n_points):
        d = np.sqrt(np.sum((points[i] - points[j])**2))
        ax.plot([points[i, 0], points[j, 0]], [points[i, 1], points[j, 1]],
                'gray', alpha=0.15, linewidth=0.5)

# Highlight closest pair
ax.plot([points[ci, 0], points[cj, 0]], [points[ci, 1], points[cj, 1]],
        'r-', linewidth=2.5, label=f'Closest pair ({ci},{cj})')

# Draw points
ax.scatter(points[:, 0], points[:, 1], s=80, c='#2196F3', zorder=5, edgecolors='white')
for i in range(n_points):
    ax.annotate(str(i), (points[i, 0]+0.1, points[i, 1]+0.1), fontsize=9)

ax.set_title(f'Point Cloud (n={n_points})\nMargin = min ||xᵢ-xⱼ||² = {margin:.2f}',
             fontsize=12, fontweight='bold')
ax.set_xlabel('x₁')
ax.set_ylabel('x₂')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=9)

# Panel 2: Pair slack vs squared distance scatter
ax = axes[1]
pair_slacks = []
sq_dists = []
for i in range(n_points):
    for j in range(i+1, n_points):
        pair_slacks.append(pair_slack(G, i, j))
        sq_dists.append(np.sum((points[i] - points[j])**2))

ax.scatter(sq_dists, pair_slacks, s=40, c='#4CAF50', alpha=0.7, edgecolors='white')
lim = max(max(sq_dists), max(pair_slacks)) * 1.1
ax.plot([0, lim], [0, lim], 'r--', linewidth=1.5, label='y = x (exact match)')
ax.set_xlabel('||xᵢ - xⱼ||²', fontsize=11)
ax.set_ylabel('pairSlack(G, i, j)', fontsize=11)
ax.set_title('Pair Slack = Squared Distance\nfor Gram Matrices', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Margin vs dimension for random point clouds
ax = axes[2]
dims = range(2, 20)
n_pts = 10
num_trials = 200

mean_margins = []
std_margins = []
for d in dims:
    ms = []
    for _ in range(num_trials):
        pts = rng.standard_normal((n_pts, d))
        G = pts @ pts.T
        ms.append(trop_sym_margin(G))
    mean_margins.append(np.mean(ms))
    std_margins.append(np.std(ms))

mean_margins = np.array(mean_margins)
std_margins = np.array(std_margins)
dims_arr = np.array(list(dims))

ax.plot(dims_arr, mean_margins, 'o-', color='#2196F3', linewidth=1.5, label='Mean margin')
ax.fill_between(dims_arr, mean_margins - std_margins, mean_margins + std_margins,
                alpha=0.2, color='#2196F3')
ax.set_xlabel('Ambient dimension d', fontsize=11)
ax.set_ylabel('tropSymMargin(G)', fontsize=11)
ax.set_title(f'Margin Growth with Dimension\n(n={n_pts} random points)', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

fig.suptitle('Cross-Domain Bridge: Tropical Margin = Geometric Separation',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gram_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_gram_bridge.png")
