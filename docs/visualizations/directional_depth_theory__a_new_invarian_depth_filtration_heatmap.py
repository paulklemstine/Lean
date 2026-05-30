"""
Visualization: Directional Depth Filtration Heatmap
====================================================

Visualizes how the depth filtration varies across a family of sequences
parameterized by a perturbation parameter. Shows the nested structure of
the filtration as a heatmap.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def ratio_transform(seq):
    return [seq[i + 1] / seq[i] for i in range(len(seq) - 1) if seq[i] > 0]


def is_log_concave(seq, rel_tol=1e-9):
    for i in range(len(seq) - 2):
        if seq[i + 1] ** 2 < seq[i] * seq[i + 2] * (1 - rel_tol):
            return False
    return True


def compute_depth(seq, max_depth=15):
    current = list(seq)
    if not all(x > 0 for x in current):
        return -1
    if not is_log_concave(current):
        return -1
    depth = 0
    for _ in range(max_depth):
        if len(current) < 3:
            return depth
        try:
            current = ratio_transform(current)
        except (ZeroDivisionError, OverflowError):
            return depth
        if not current or not all(x > 0 for x in current):
            return depth
        if not is_log_concave(current):
            return depth
        depth += 1
    return depth


# Generate family: a_alpha(n) = (alpha + 1)^n * C(N, n) for varying alpha
N = 12
alphas = np.linspace(0.01, 3.0, 60)
seq_len = N + 1

depths = []
for alpha in alphas:
    seq = [(alpha + 1) ** k * math.comb(N, k) for k in range(seq_len)]
    d = compute_depth(seq)
    depths.append(d)

# Create main figure
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Depth vs parameter
ax1 = axes[0]
ax1.plot(alphas, depths, 'b-', linewidth=2)
ax1.fill_between(alphas, depths, alpha=0.3)
ax1.set_xlabel('Parameter α', fontsize=12)
ax1.set_ylabel('Directional Depth', fontsize=12)
ax1.set_title('Depth of (α+1)ⁿ · C(N,n)', fontsize=14)
ax1.grid(True, alpha=0.3)

# Right: Filtration heatmap
# Show which filtration levels each sequence belongs to
max_d = max(depths) + 1
heatmap = np.zeros((max_d, len(alphas)))
for j, d in enumerate(depths):
    for k in range(max(0, d + 1)):
        heatmap[k, j] = 1

ax2 = axes[1]
im = ax2.imshow(heatmap, aspect='auto', cmap='YlOrRd',
                extent=[alphas[0], alphas[-1], max_d - 0.5, -0.5])
ax2.set_xlabel('Parameter α', fontsize=12)
ax2.set_ylabel('Filtration Level k', fontsize=12)
ax2.set_title('Depth Filtration (colored = depth ≥ k)', fontsize=14)
plt.colorbar(im, ax=ax2, label='In filtration')

plt.tight_layout()
plt.savefig('depth_filtration_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved depth_filtration_heatmap.png")
