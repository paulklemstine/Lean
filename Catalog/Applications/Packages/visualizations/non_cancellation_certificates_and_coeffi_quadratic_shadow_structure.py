#!/usr/bin/env python3
"""
Visualization 1: Quadratic Shadow Structure

Visualizes the quadratic shadow of a polynomial support set in 2D.
Shows the original support (blue), the shadow (red), and arrows
connecting ancestors to their shadow images.

This illustrates the core concept: each support element generates
shadow elements by subtracting pairs of unit basis vectors.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_quadratic_shadow_2d(support):
    """Compute quadratic shadow for 2-variable polynomials."""
    shadow = set()
    ancestors = {}  # shadow_point -> list of (ancestor, i, j)
    for alpha in support:
        a0, a1 = alpha
        for i in range(2):
            ai = [a0, a1]
            if ai[i] < 1:
                continue
            ai[i] -= 1
            for j in range(2):
                if ai[j] < 1:
                    continue
                beta = list(ai)
                beta[j] -= 1
                beta_t = tuple(beta)
                shadow.add(beta_t)
                if beta_t not in ancestors:
                    ancestors[beta_t] = []
                ancestors[beta_t].append((alpha, i, j))
    return shadow, ancestors


# Example: support of a degree-4 polynomial in 2 variables
support = {(4, 0), (3, 1), (2, 2), (1, 3), (0, 4), (2, 0), (1, 1), (0, 2)}

shadow, ancestors = compute_quadratic_shadow_2d(support)

# Separate shadow-only points from overlap
shadow_only = shadow - support
overlap = shadow & support
support_only = support - shadow

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Support and shadow with connections
ax = axes[0]
ax.set_title("Support & Quadratic Shadow", fontsize=14, fontweight='bold')

# Draw arrows from support to shadow
for beta, anc_list in ancestors.items():
    for alpha, i, j in anc_list:
        ax.annotate("", xy=beta, xytext=alpha,
                    arrowprops=dict(arrowstyle="->", color='gray',
                                   alpha=0.3, lw=0.8))

# Plot support-only points
if support_only:
    sx, sy = zip(*support_only)
    ax.scatter(sx, sy, c='royalblue', s=120, zorder=5, edgecolors='navy',
              linewidths=1.5, label='Support only')

# Plot overlap points
if overlap:
    ox, oy = zip(*overlap)
    ax.scatter(ox, oy, c='mediumpurple', s=120, zorder=5, edgecolors='indigo',
              linewidths=1.5, marker='D', label='Support ∩ Shadow')

# Plot shadow-only points
if shadow_only:
    shx, shy = zip(*shadow_only)
    ax.scatter(shx, shy, c='tomato', s=100, zorder=5, edgecolors='darkred',
              linewidths=1.5, marker='s', label='Shadow only')

ax.set_xlabel("Exponent of x", fontsize=12)
ax.set_ylabel("Exponent of y", fontsize=12)
ax.legend(fontsize=10, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Set integer ticks
all_points = support | shadow
max_coord = max(max(p) for p in all_points) + 1
ax.set_xticks(range(max_coord + 1))
ax.set_yticks(range(max_coord + 1))

# Right panel: Per-variable-pair leaf sets
ax2 = axes[1]
ax2.set_title("Per-(i,j) Quadratic Leaf Sets", fontsize=14, fontweight='bold')

colors = {'(0,0)': '#e74c3c', '(0,1)': '#2ecc71',
          '(1,0)': '#3498db', '(1,1)': '#f39c12'}
markers = {'(0,0)': 'o', '(0,1)': 's', '(1,0)': '^', '(1,1)': 'D'}

for i in range(2):
    for j in range(2):
        leaf_set = set()
        for alpha in support:
            a = list(alpha)
            if a[i] < 1:
                continue
            a[i] -= 1
            if a[j] < 1:
                continue
            a[j] -= 1
            leaf_set.add(tuple(a))

        label = f"∂_{i}∂_{j}"
        key = f"({i},{j})"
        if leaf_set:
            lx, ly = zip(*leaf_set)
            offset = (i * 0.08 - 0.04, j * 0.08 - 0.04)
            ax2.scatter([x + offset[0] for x in lx],
                       [y + offset[1] for y in ly],
                       c=colors[key], s=80, zorder=5,
                       marker=markers[key], label=label,
                       edgecolors='black', linewidths=0.5, alpha=0.8)

# Also show support for reference
sx_all, sy_all = zip(*support)
ax2.scatter(sx_all, sy_all, c='lightgray', s=200, zorder=1,
           marker='h', alpha=0.4, label='Support')

ax2.set_xlabel("Exponent of x", fontsize=12)
ax2.set_ylabel("Exponent of y", fontsize=12)
ax2.legend(fontsize=9, loc='upper right', ncol=2)
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(max_coord + 1))
ax2.set_yticks(range(max_coord + 1))

plt.suptitle("Quadratic Shadow: Support → Hessian Exponent Prediction",
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("visualize_shadow.png", dpi=150, bbox_inches='tight')
print("Saved visualize_shadow.png")
