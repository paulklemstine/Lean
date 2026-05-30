#!/usr/bin/env python3
"""
Visualization 3: Tropical Geodesics on the Pentagon Graph

Visualizes the pentagon graph (modeling the [[5,1,3]] HaPPY code bulk)
and its tropical shortest-path distances. Shows how the min-plus
(tropical) semiring computes geodesics in the holographic bulk.
"""

import matplotlib.pyplot as plt
import numpy as np

# Pentagon graph
n = 5
angles = [np.pi/2 + 2*np.pi*i/n for i in range(n)]
x = [np.cos(a) for a in angles]
y = [np.sin(a) for a in angles]

# Compute tropical shortest paths
INF = float('inf')
weight = [[INF]*n for _ in range(n)]
for i in range(n):
    weight[i][i] = 0
    weight[i][(i+1)%n] = 1
    weight[(i+1)%n][i] = 1

dist = [row[:] for row in weight]
for k in range(n):
    for i in range(n):
        for j in range(n):
            dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# Plot 1: Pentagon graph with distances from v0
ax1 = axes[0]

# Draw edges
for i in range(n):
    j = (i + 1) % n
    ax1.plot([x[i], x[j]], [y[i], y[j]], 'k-', linewidth=2, alpha=0.6)

# Draw vertices
for i in range(n):
    d_from_0 = dist[0][i]
    color = ['#e74c3c', '#f39c12', '#2ecc71'][min(int(d_from_0), 2)]
    ax1.scatter(x[i], y[i], s=500, c=color, zorder=5, edgecolors='black', linewidth=2)
    ax1.text(x[i], y[i], f'v{i}\nd={int(d_from_0)}', ha='center', va='center',
             fontsize=10, fontweight='bold')

# Labels outside
label_x = [1.35*xi for xi in x]
label_y = [1.35*yi for yi in y]
for i in range(n):
    ax1.text(label_x[i], label_y[i], f'qubit {i}', ha='center', va='center',
             fontsize=9, style='italic', color='gray')

ax1.set_xlim(-1.8, 1.8)
ax1.set_ylim(-1.6, 1.8)
ax1.set_aspect('equal')
ax1.set_title('Pentagon Graph: Distances from v₀', fontsize=13)
ax1.axis('off')

# Color legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#e74c3c', edgecolor='black', label='d = 0 (source)'),
    Patch(facecolor='#f39c12', edgecolor='black', label='d = 1 (adjacent)'),
    Patch(facecolor='#2ecc71', edgecolor='black', label='d = 2 (far)'),
]
ax1.legend(handles=legend_elements, loc='lower center', fontsize=9)

# Plot 2: Distance matrix heatmap
ax2 = axes[1]
dist_arr = np.array(dist)
im = ax2.imshow(dist_arr, cmap='YlOrRd_r', vmin=0, vmax=2)
ax2.set_xticks(range(n))
ax2.set_yticks(range(n))
ax2.set_xticklabels([f'v{i}' for i in range(n)])
ax2.set_yticklabels([f'v{i}' for i in range(n)])
ax2.set_title('Tropical Geodesic Distance Matrix', fontsize=13)

# Annotate cells
for i in range(n):
    for j in range(n):
        ax2.text(j, i, f'{int(dist_arr[i,j])}', ha='center', va='center',
                 fontsize=14, fontweight='bold',
                 color='white' if dist_arr[i,j] < 1 else 'black')

plt.colorbar(im, ax=ax2, shrink=0.8)

# Plot 3: Tropical semiring operations
ax3 = axes[2]

# Show tropical addition (min) and multiplication (+)
a_vals = np.linspace(0, 3, 50)
b_val = 1.5

trop_add = np.minimum(a_vals, b_val)
trop_mul = a_vals + b_val

ax3.plot(a_vals, trop_add, 'b-', linewidth=2.5, label=f'a ⊕ {b_val} = min(a, {b_val})')
ax3.plot(a_vals, trop_mul, 'r-', linewidth=2.5, label=f'a ⊗ {b_val} = a + {b_val}')
ax3.plot(a_vals, a_vals, 'k--', linewidth=1, alpha=0.5, label='y = a')
ax3.axhline(y=b_val, color='green', linestyle=':', alpha=0.5, label=f'y = {b_val}')

ax3.set_xlabel('a', fontsize=13)
ax3.set_ylabel('Result', fontsize=13)
ax3.set_title('Tropical Semiring Operations', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_geodesics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved tropical_geodesics.png")
