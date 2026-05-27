#!/usr/bin/env python3
"""
Visualization 1: Shadow Heatmap
Visualizes the second shadow of a 2D polynomial support set as a heatmap,
showing which exponent vectors survive the shadow operation and how
different Hessian channels cover them.

This makes the core mathematical concept tangible: the "shape" of exponents
constrains what derivatives can produce.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, Tuple

ExponentVector = Tuple[int, ...]

def subtract_pair_basis(alpha, i, j):
    lst = list(alpha)
    if lst[i] < 1: return None
    lst[i] -= 1
    if lst[j] < 1: return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S, n):
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def hessian_channel_support(S, n, i, j):
    ch = set()
    for alpha in S:
        beta = subtract_pair_basis(alpha, i, j)
        if beta is not None:
            ch.add(beta)
    return ch

def simplex_support(d, m):
    if d == 0: return {()} if m == 0 else set()
    if d == 1: return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result

# ─── Create figure ────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Support families to visualize
families = [
    ("Simplex(2,6)", simplex_support(2, 6), 2),
    ("Simplex(2,8)", simplex_support(2, 8), 2),
    ("Cube(2,4)", set((a, b) for a in range(5) for b in range(5)), 2),
]

for col, (name, S, n) in enumerate(families):
    sh = second_shadow(S, n)
    
    # Top row: Support and Shadow overlay
    ax = axes[0, col]
    max_coord = max(max(v) for v in S) + 1
    
    # Plot shadow points (background)
    for beta in sh:
        ax.add_patch(plt.Rectangle((beta[0] - 0.4, beta[1] - 0.4), 0.8, 0.8,
                                    color='#3498db', alpha=0.3))
    
    # Plot support points (foreground)
    for alpha in S:
        ax.plot(alpha[0], alpha[1], 'ko', markersize=8, zorder=5)
    
    # Plot shadow-only points
    shadow_only = sh - S
    for beta in shadow_only:
        ax.plot(beta[0], beta[1], 's', color='#3498db', markersize=6, zorder=4)
    
    ax.set_xlim(-0.5, max_coord + 0.5)
    ax.set_ylim(-0.5, max_coord + 0.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title(f"{name}\n|S|={len(S)}, |Sh₂|={len(sh)}", fontsize=11)
    ax.set_xlabel("x₁ exponent")
    ax.set_ylabel("x₂ exponent")
    
    # Bottom row: Channel heatmap
    ax2 = axes[1, col]
    max_coord_sh = max(max(v) for v in sh) + 1 if sh else 1
    grid = np.zeros((max_coord_sh + 1, max_coord_sh + 1))
    
    for i in range(n):
        for j in range(n):
            ch = hessian_channel_support(S, n, i, j)
            for beta in ch:
                if beta[0] <= max_coord_sh and beta[1] <= max_coord_sh:
                    grid[beta[1], beta[0]] += 1  # count channels covering this point
    
    im = ax2.imshow(grid, origin='lower', cmap='YlOrRd', aspect='equal',
                     extent=(-0.5, max_coord_sh + 0.5, -0.5, max_coord_sh + 0.5))
    plt.colorbar(im, ax=ax2, label='# channels covering')
    ax2.set_title(f"Channel coverage density\nLB = |Sh₂|/n² = {len(sh)/n**2:.1f}", fontsize=11)
    ax2.set_xlabel("x₁ exponent")
    ax2.set_ylabel("x₂ exponent")

# Legend
support_patch = mpatches.Patch(color='black', label='Support S')
shadow_patch = mpatches.Patch(color='#3498db', alpha=0.5, label='Shadow Sh₂(S)')
fig.legend(handles=[support_patch, shadow_patch], loc='upper center',
           ncol=2, fontsize=12, bbox_to_anchor=(0.5, 1.02))

fig.suptitle("Second Shadow and Hessian Channel Coverage\n"
             "The shadow determines which exponents appear in second derivatives",
             fontsize=14, fontweight='bold', y=1.06)
plt.tight_layout()
plt.savefig("shadow_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
