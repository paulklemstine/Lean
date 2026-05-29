#!/usr/bin/env python3
"""
Visualization: Tropical Helly's Theorem in Action

Shows the Helly condition for tropical halfspaces:
- Left panel: A family where ALL 4-subfamilies (n+1=4 for n=3) intersect
  → Full intersection guaranteed (Helly)
- Right panel: A family where SOME 4-subfamilies fail to intersect
  → No guarantee

Projected to 2D for visualization clarity.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def in_halfspace(X, Y, a, b):
    """Check if points are in tropical halfspace H(a, b) in ℝ²."""
    return np.maximum(a[0] + X, a[1] + Y) >= b


def farkas_2d(A, b):
    """Farkas construction in 2D."""
    n = 2
    x = np.array([np.max(b - A[:, i]) for i in range(n)])
    for j in range(len(b)):
        if np.max(A[j] + x) < b[j] - 1e-10:
            return None
    return x


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

grid_res = 400
xx = np.linspace(-5, 8, grid_res)
yy = np.linspace(-5, 8, grid_res)
X, Y = np.meshgrid(xx, yy)

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']

# --- Panel 1: Helly condition satisfied ---
ax = axes[0]
np.random.seed(42)

# 5 halfspaces in ℝ² (Helly number = 3)
halfspaces_good = [
    (np.array([1.0, 0.0]), 1.0),
    (np.array([0.0, 1.0]), 0.5),
    (np.array([0.5, 0.5]), 1.0),
    (np.array([-0.3, 0.8]), 0.0),
    (np.array([0.7, -0.2]), 0.3),
]

mask_all = np.ones_like(X, dtype=bool)
for i, (a, b) in enumerate(halfspaces_good):
    mask_i = in_halfspace(X, Y, a, b)
    ax.contour(X, Y, mask_i.astype(float), levels=[0.5], 
               colors=[colors[i]], linewidths=1.5, linestyles='--', alpha=0.7)
    mask_all &= mask_i

ax.contourf(X, Y, mask_all.astype(float), levels=[0.5, 1.5], 
            colors=['#b2df8a'], alpha=0.8)
ax.contour(X, Y, mask_all.astype(float), levels=[0.5], 
           colors=['#33a02c'], linewidths=2.5)

# Check all 3-subfamilies
all_good = True
A_good = np.array([h[0] for h in halfspaces_good])
b_good = np.array([h[1] for h in halfspaces_good])

for combo in combinations(range(5), 3):
    idx = list(combo)
    pt = farkas_2d(A_good[idx], b_good[idx])
    if pt is not None:
        ax.plot(pt[0], pt[1], 's', color='gray', markersize=4, alpha=0.5, zorder=3)
    else:
        all_good = False

# Farkas witness for full intersection
witness = farkas_2d(A_good, b_good)
if witness is not None:
    ax.plot(witness[0], witness[1], 'r*', markersize=18, zorder=5, 
            label=f'Full intersection\nwitness ({witness[0]:.1f}, {witness[1]:.1f})')

# Legend for halfspaces
for i in range(5):
    ax.plot([], [], '-', color=colors[i], label=f'$H_{i+1}$', linewidth=2)

ax.set_title('Helly Condition SATISFIED\n(All 3-subfamilies intersect → full intersection exists)', 
             fontsize=11, fontweight='bold', color='#33a02c')
ax.set_xlabel('$x_1$', fontsize=11)
ax.set_ylabel('$x_2$', fontsize=11)
ax.set_xlim(-3, 7)
ax.set_ylim(-3, 7)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(loc='upper left', fontsize=8, ncol=2)

# --- Panel 2: Helly condition fails ---
ax = axes[1]

# 4 halfspaces where some 3-subfamilies fail
halfspaces_bad = [
    (np.array([2.0, -2.0]), 3.0),
    (np.array([-2.0, 2.0]), 3.0),
    (np.array([1.0, 1.0]), 5.0),
    (np.array([-1.0, -1.0]), -2.0),
]

mask_all = np.ones_like(X, dtype=bool)
for i, (a, b) in enumerate(halfspaces_bad):
    mask_i = in_halfspace(X, Y, a, b)
    ax.contour(X, Y, mask_i.astype(float), levels=[0.5], 
               colors=[colors[i]], linewidths=1.5, linestyles='--', alpha=0.7)
    mask_all &= mask_i

# Check 3-subfamilies
A_bad = np.array([h[0] for h in halfspaces_bad])
b_bad = np.array([h[1] for h in halfspaces_bad])

n_intersecting = 0
n_total = 0
for combo in combinations(range(4), 3):
    idx = list(combo)
    n_total += 1
    pt = farkas_2d(A_bad[idx], b_bad[idx])
    if pt is not None:
        n_intersecting += 1
        ax.plot(pt[0], pt[1], 's', color='green', markersize=6, alpha=0.7, zorder=3)
    else:
        # Mark failing subfamily
        center_a = np.mean(A_bad[idx], axis=0)
        ax.annotate(f'✗ {{{",".join(str(i+1) for i in idx)}}}', 
                    xy=(3, -2 - n_total * 0.4), fontsize=8, color='red', fontweight='bold')

# Check if full intersection is nonempty
has_full = mask_all.any()
if has_full:
    ax.contourf(X, Y, mask_all.astype(float), levels=[0.5, 1.5], 
                colors=['#b2df8a'], alpha=0.8)
else:
    ax.text(2, 2, 'Full intersection\nmay be empty', fontsize=12, 
            ha='center', va='center', color='red', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#fff0f0', edgecolor='red'))

for i in range(4):
    ax.plot([], [], '-', color=colors[i], label=f'$H_{i+1}$', linewidth=2)

ax.set_title(f'Helly Condition FAILS\n({n_intersecting}/{n_total} of 3-subfamilies intersect)', 
             fontsize=11, fontweight='bold', color='#e41a1c')
ax.set_xlabel('$x_1$', fontsize=11)
ax.set_ylabel('$x_2$', fontsize=11)
ax.set_xlim(-3, 7)
ax.set_ylim(-3, 7)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(loc='upper left', fontsize=8)

plt.tight_layout()
plt.savefig('helly_theorem.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: helly_theorem.png")
