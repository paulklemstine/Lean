"""
Visualization: Tropical Kernel Structure on Small Graphs
=========================================================

Visualizes the tropical kernel for small graphs by:
1. Showing the feasible region (potential differences) for a single edge
2. Plotting kernel elements for a triangle graph
3. Illustrating the network flow bridge

This brings the abstract mathematical structure to life.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Single edge feasibility region
ax1 = axes[0]
w01_vals = np.linspace(-3, 1, 20)
w10_vals = np.linspace(-3, 1, 20)
W01, W10 = np.meshgrid(w01_vals, w10_vals)
# Interval [w01, -w10] is nonempty when w01 + w10 ≤ 0
feasible = (W01 + W10 <= 0).astype(float)

ax1.contourf(W01, W10, feasible, levels=[-0.5, 0.5, 1.5],
             colors=['#FFCDD2', '#C8E6C9'], alpha=0.8)
ax1.contour(W01, W10, W01 + W10, levels=[0], colors='red', linewidths=2)

# Mark some example points
examples = [(-1, -1, '✓'), (-2, -0.5, '✓'), (0.5, 0.5, '✗'), (-1, 2, '✗')]
for w01, w10, label in examples:
    color = 'green' if w01 + w10 <= 0 else 'red'
    ax1.plot(w01, w10, 'o', color=color, markersize=10)
    ax1.annotate(f'({w01},{w10})', (w01, w10), textcoords="offset points",
                 xytext=(8, 8), fontsize=8)

ax1.set_xlabel('w₀₁ (weight 0→1)', fontsize=11)
ax1.set_ylabel('w₁₀ (weight 1→0)', fontsize=11)
ax1.set_title('Edge Kernel: Feasible iff w₀₁+w₁₀ ≤ 0', fontsize=12)
ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#C8E6C9', label='Feasible'),
                   Patch(facecolor='#FFCDD2', label='Infeasible')]
ax1.legend(handles=legend_elements, fontsize=9)

# Panel 2: Kernel elements for triangle with w = -1
ax2 = axes[1]
# Triangle K₃ with all weights = -1
# Balance: for each v, ∃ u ∈ N(v): -1 + x[u] ≤ x[v]
# i.e., ∃ u: x[v] - x[u] ≥ -1, i.e., x[v] ≥ x[u] - 1

# Sample kernel elements: all x with max(x)-min(x) ≤ 1
np.random.seed(42)
kernel_pts = []
non_kernel_pts = []
for _ in range(2000):
    x = np.random.uniform(-2, 2, 3)
    # Check kernel condition
    in_kernel = True
    for v in range(3):
        nbrs = [(v+1)%3, (v+2)%3]
        if not any(-1 + x[u] <= x[v] + 1e-10 for u in nbrs):
            in_kernel = False
            break
    if in_kernel:
        kernel_pts.append(x)
    else:
        non_kernel_pts.append(x)

# Plot in 2D: x₁-x₀ vs x₂-x₀ (mod out constant shift)
if kernel_pts:
    kp = np.array(kernel_pts)
    d1 = kp[:, 1] - kp[:, 0]
    d2 = kp[:, 2] - kp[:, 0]
    ax2.scatter(d1, d2, c='#2196F3', alpha=0.3, s=10, label='Kernel')

if non_kernel_pts:
    nkp = np.array(non_kernel_pts[:500])
    d1 = nkp[:, 1] - nkp[:, 0]
    d2 = nkp[:, 2] - nkp[:, 0]
    ax2.scatter(d1, d2, c='#FFCDD2', alpha=0.15, s=5, label='Not kernel')

ax2.set_xlabel('x₁ - x₀', fontsize=11)
ax2.set_ylabel('x₂ - x₀', fontsize=11)
ax2.set_title('Tropical Kernel of K₃ (w=-1)', fontsize=12)
ax2.legend(fontsize=9)
ax2.set_aspect('equal')
ax2.grid(alpha=0.2)

# Panel 3: Network flow bridge
ax3 = axes[2]
ax3.set_xlim(-0.5, 4.5)
ax3.set_ylim(-1, 3)
ax3.set_aspect('equal')

# Draw a small network
positions = {0: (0, 1.5), 1: (1.5, 2.5), 2: (1.5, 0.5), 3: (3, 1.5), 4: (4.5, 1.5)}
edges_draw = [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4)]
weights_draw = {(0,1): -1.0, (0,2): -1.5, (1,3): -0.8, (2,3): -1.0, (3,4): -0.5}

# Draw edges
for u, v in edges_draw:
    x_pos = [positions[u][0], positions[v][0]]
    y_pos = [positions[u][1], positions[v][1]]
    w = weights_draw[(u,v)]
    ax3.plot(x_pos, y_pos, 'k-', linewidth=1.5, alpha=0.5)
    mid_x = (x_pos[0] + x_pos[1]) / 2
    mid_y = (y_pos[0] + y_pos[1]) / 2
    ax3.annotate(f'{w}', (mid_x, mid_y), fontsize=8, ha='center',
                 bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow'))

# Draw vertices with potential values
x_vals = [0, 0, 0, 0, 0]  # zero potential (kernel element for nonpos weights)
for v, (px, py) in positions.items():
    gap = 0.0  # all gaps are 0 for zero potential with nonpos weights
    color = '#4CAF50' if abs(gap) < 0.01 else '#FF9800'
    circle = plt.Circle((px, py), 0.25, color=color, ec='black', linewidth=1.5)
    ax3.add_patch(circle)
    ax3.text(px, py, f'{v}', ha='center', va='center', fontsize=12, fontweight='bold')
    ax3.text(px, py - 0.45, f'gap=0', ha='center', va='top', fontsize=7, color='green')

ax3.set_title('Network Flow Bridge\n(gap=0 ⟹ tropical conservation)', fontsize=11)
ax3.axis('off')

plt.tight_layout()
plt.savefig('viz_kernel_structure.png', dpi=150, bbox_inches='tight')
print("Saved: viz_kernel_structure.png")
