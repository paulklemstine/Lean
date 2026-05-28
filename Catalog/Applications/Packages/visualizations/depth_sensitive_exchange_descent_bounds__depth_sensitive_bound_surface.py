"""
Visualization 1: Depth-Sensitive Descent Bound Surface

Visualizes how the theoretical descent bound T ≤ C · d^{d-k} · D varies
with dimension d and certificate depth k. The key insight is that deeper
certificates (larger k) dramatically reduce the bound, with the surface
collapsing to linear scaling when k = d.

This is the central visual of the theory: certificate depth as a regularity
parameter that interpolates between generic polynomial descent and near-linear
augmenting-path behavior.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm

fig = plt.figure(figsize=(14, 5))

# ─── Panel 1: 3D surface of bound vs (d, k) ───
ax1 = fig.add_subplot(131, projection='3d')

d_vals = np.arange(2, 13)
D = 10  # fixed diameter

X, Y = [], []
Z = []
for d in d_vals:
    for k in range(1, d + 1):
        X.append(d)
        Y.append(k)
        Z.append(np.log10(max(d ** max(d - k, 0) * D, 1)))

X, Y, Z = np.array(X), np.array(Y), np.array(Z)

scatter = ax1.scatter(X, Y, Z, c=Z, cmap='viridis', s=40, alpha=0.8)
ax1.set_xlabel('Dimension d', fontsize=9)
ax1.set_ylabel('Depth k', fontsize=9)
ax1.set_zlabel('log₁₀(Bound)', fontsize=9)
ax1.set_title('Descent Bound\nvs (d, k)', fontsize=11, fontweight='bold')
ax1.view_init(elev=25, azim=135)

# ─── Panel 2: Bound curves for fixed dimensions ───
ax2 = fig.add_subplot(132)

colors = plt.cm.plasma(np.linspace(0.1, 0.9, 6))
for idx, d in enumerate([4, 6, 8, 10, 12]):
    ks = range(1, d + 1)
    bounds = [d ** max(d - k, 0) * D for k in ks]
    ax2.semilogy(list(ks), bounds, 'o-', color=colors[idx],
                 label=f'd={d}', markersize=5, linewidth=1.5)

ax2.set_xlabel('Certificate Depth k', fontsize=11)
ax2.set_ylabel('Descent Bound (log scale)', fontsize=11)
ax2.set_title('Bound Collapse\nwith Depth', fontsize=11, fontweight='bold')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 13)

# Highlight k=d points
ax2.axhline(y=D, color='red', linestyle='--', alpha=0.5, linewidth=1)
ax2.text(11, D * 1.5, 'Linear: O(D)', color='red', fontsize=8, ha='center')

# ─── Panel 3: Effective exponent d-k ───
ax3 = fig.add_subplot(133)

for d in [4, 6, 8, 10]:
    ks = np.arange(1, d + 1)
    exponents = [d - k for k in ks]
    ax3.plot(ks, exponents, 's-', label=f'd={d}', markersize=6, linewidth=1.5)

ax3.set_xlabel('Certificate Depth k', fontsize=11)
ax3.set_ylabel('Effective Exponent (d − k)', fontsize=11)
ax3.set_title('Exponent Reduction\nwith Depth', fontsize=11, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=0, color='green', linestyle='--', alpha=0.7, linewidth=1.5)
ax3.text(8, 0.5, 'Linear regime', color='green', fontsize=9, ha='center')

plt.tight_layout()
plt.savefig('viz_depth_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_bound.png")
