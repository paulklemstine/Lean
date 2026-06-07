#!/usr/bin/env python3
"""
Visualization: EML Separation Property

Shows how exp separates points and the multivariate separation structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("EML Separation Properties", fontsize=15, fontweight='bold')

# Plot 1: exp separates points
ax = axes[0]
x = np.linspace(-2, 2, 500)
ax.plot(x, np.exp(x), 'b-', linewidth=2)
pairs = [(-1, 0.5), (0, 1), (-0.5, 1.5)]
for x1, x2 in pairs:
    ax.plot([x1, x2], [np.exp(x1), np.exp(x2)], 'ro-', markersize=6)
    ax.annotate(f'gap={abs(np.exp(x1)-np.exp(x2)):.2f}',
                xy=((x1+x2)/2, (np.exp(x1)+np.exp(x2))/2),
                fontsize=8, ha='center')
ax.set_title("exp(x) Separates Points", fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('exp(x)')
ax.grid(True, alpha=0.3)

# Plot 2: Separation gap vs distance
ax = axes[1]
base_points = np.linspace(-2, 2, 20)
for delta in [0.01, 0.1, 0.5]:
    gaps = np.abs(np.exp(base_points + delta) - np.exp(base_points))
    ax.plot(base_points, gaps, '-o', markersize=3, label=f'δ={delta}')
ax.set_title("Separation Gap |exp(x+δ) - exp(x)|", fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('Gap')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Plot 3: Multivariate separation (2D)
ax = axes[2]
np.random.seed(42)
points = np.random.randn(10, 2) * 0.5
for i in range(len(points)):
    for j in range(i+1, len(points)):
        x1, x2 = points[i], points[j]
        # Find separating coordinate
        diffs = np.abs(x1 - x2)
        sep_coord = np.argmax(diffs)
        color = 'red' if sep_coord == 0 else 'blue'
        ax.plot([x1[0], x2[0]], [x1[1], x2[1]], '-', color=color, alpha=0.2)
ax.scatter(points[:, 0], points[:, 1], c='black', s=50, zorder=5)
ax.set_title("Multivariate: Separating Coordinates", fontsize=12)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.legend(['coord 0 sep.', 'coord 1 sep.'], fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_separation.png', dpi=150, bbox_inches='tight')
print("Saved viz_separation.png")
