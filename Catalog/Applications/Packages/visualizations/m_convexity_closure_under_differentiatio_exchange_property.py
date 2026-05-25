#!/usr/bin/env python3
"""
Visualization: Exchange Property in Action

Shows the exchange axiom operating on a concrete M-convex support set.
For two chosen vectors α and β with α_i > β_i, highlights the exchange
witness j and the two replacement vectors.

Illustrates the symmetric exchange that is the heart of M-convexity.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def to_2d(v):
    """Project 3D simplex point to 2D."""
    x = v[1] + 0.5 * v[2]
    y = v[2] * np.sqrt(3) / 2
    return x, y


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# === Panel 1: The M-convex set ===
ax = axes[0]
ax.set_aspect('equal')
ax.set_title('M-convex Support Set\n(Degree-2 Simplex)', fontsize=12, fontweight='bold')

n, d = 3, 2
S = []
for a in range(d+1):
    for b in range(d+1-a):
        c = d - a - b
        S.append((a, b, c))

# Draw triangle
corners = [to_2d((d,0,0)), to_2d((0,d,0)), to_2d((0,0,d))]
triangle = plt.Polygon(corners, fill=True, facecolor='#E3F2FD',
                       edgecolor='#1565C0', linewidth=2)
ax.add_patch(triangle)

# Plot all points
for v in S:
    x, y = to_2d(v)
    ax.plot(x, y, 'o', color='#1976D2', markersize=12, zorder=5,
           markeredgecolor='black', markeredgewidth=0.5)
    ax.annotate(f'{v}', (x, y), textcoords="offset points",
               xytext=(0, 12), ha='center', fontsize=8)

ax.set_xlim(-0.5, d+0.5)
ax.set_ylim(-0.5, d*np.sqrt(3)/2+0.5)
ax.axis('off')
ax.text(0.5, -0.08, 'All 6 lattice points form\nan M-convex set',
       transform=ax.transAxes, ha='center', fontsize=10, style='italic')

# === Panel 2: Exchange in action ===
ax = axes[1]
ax.set_aspect('equal')
ax.set_title('Exchange Property\nα=(2,0,0), β=(0,2,0), i=0', fontsize=12, fontweight='bold')

triangle = plt.Polygon(corners, fill=True, facecolor='#FFF3E0',
                       edgecolor='#E65100', linewidth=2)
ax.add_patch(triangle)

# Highlight α and β
alpha = (2, 0, 0)
beta = (0, 2, 0)
xa, ya = to_2d(alpha)
xb, yb = to_2d(beta)

# Other points in gray
for v in S:
    if v not in [alpha, beta, (1, 1, 0)]:
        x, y = to_2d(v)
        ax.plot(x, y, 'o', color='lightgray', markersize=10, zorder=4,
               markeredgecolor='gray', markeredgewidth=0.5)

# α in red, β in blue
ax.plot(xa, ya, 's', color='#D32F2F', markersize=16, zorder=6,
       markeredgecolor='black', markeredgewidth=1.5, label='α=(2,0,0)')
ax.plot(xb, yb, 's', color='#1565C0', markersize=16, zorder=6,
       markeredgecolor='black', markeredgewidth=1.5, label='β=(0,2,0)')

# Exchange witnesses
swap1 = (1, 1, 0)  # α - e₀ + e₁
swap2 = (1, 1, 0)  # β + e₀ - e₁
xs, ys = to_2d(swap1)
ax.plot(xs, ys, 'D', color='#4CAF50', markersize=14, zorder=7,
       markeredgecolor='black', markeredgewidth=1.5, label='α-e₀+e₁ = β+e₀-e₁')

# Arrows
ax.annotate('', xy=(xs-0.05, ys+0.05), xytext=(xa-0.1, ya-0.05),
           arrowprops=dict(arrowstyle='->', color='#D32F2F', lw=2))
ax.annotate('', xy=(xs+0.05, ys+0.05), xytext=(xb+0.1, yb-0.05),
           arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2))

ax.legend(loc='upper right', fontsize=8, framealpha=0.9)
ax.set_xlim(-0.5, d+0.5)
ax.set_ylim(-0.5, d*np.sqrt(3)/2+0.5)
ax.axis('off')
ax.text(0.5, -0.08, 'j=1: both (1,1,0) ∈ S ✓',
       transform=ax.transAxes, ha='center', fontsize=10,
       color='#2E7D32', fontweight='bold')

# === Panel 3: After contraction ===
ax = axes[2]
ax.set_aspect('equal')
ax.set_title('After Contraction S/0\n(= Support of ∂p/∂x₀)', fontsize=12, fontweight='bold')

# Contracted set
S_contracted = [(0, 0, 1), (0, 1, 0), (1, 0, 0)]
d_new = 1
corners_new = [to_2d((d_new,0,0)), to_2d((0,d_new,0)), to_2d((0,0,d_new))]
triangle_new = plt.Polygon(corners_new, fill=True, facecolor='#E8F5E9',
                           edgecolor='#2E7D32', linewidth=2)
ax.add_patch(triangle_new)

for v in S_contracted:
    x, y = to_2d(v)
    ax.plot(x, y, 'o', color='#4CAF50', markersize=14, zorder=5,
           markeredgecolor='black', markeredgewidth=1)
    ax.annotate(f'{v}', (x, y), textcoords="offset points",
               xytext=(0, 14), ha='center', fontsize=9)

ax.set_xlim(-0.5, d+0.5)
ax.set_ylim(-0.5, d*np.sqrt(3)/2+0.5)
ax.axis('off')
ax.text(0.5, -0.08, 'Still M-convex! (Theorem) ✓',
       transform=ax.transAxes, ha='center', fontsize=10,
       color='#2E7D32', fontweight='bold')

plt.suptitle('The Exchange Property and Its Preservation Under Differentiation',
            fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('exchange_property.png', dpi=150, bbox_inches='tight')
print("Saved: exchange_property.png")
