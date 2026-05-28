"""
Visualization: Shadow Lattice Heatmap

Visualizes the k-th shadow of a 2D polynomial support as a heatmap,
showing how the "shadow" of the Newton support contracts as k increases.
This illustrates the core geometric insight: differentiation moves
the support inward through the Newton polytope.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


# ── Inline implementations ───────────────────────────────────────────

def enumerate_multi_indices_le(alpha, mass):
    n = len(alpha)
    results = []
    def generate(pos, remaining, current):
        if pos == n:
            if remaining == 0:
                results.append(tuple(current))
            return
        for v in range(min(alpha[pos], remaining) + 1):
            current.append(v)
            generate(pos + 1, remaining - v, current)
            current.pop()
    generate(0, mass, [])
    return results


def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        for tau in enumerate_multi_indices_le(alpha, k):
            beta = tuple(a - t for a, t in zip(alpha, tau))
            shadow.add(beta)
    return shadow


# ── Create visualization ─────────────────────────────────────────────

# Example: a non-trivial support in 2 variables
support = {(4, 0), (3, 1), (2, 2), (1, 3), (0, 4),
           (3, 0), (0, 3), (2, 0), (0, 2), (1, 1)}

max_coord = 5
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
axes = axes.flatten()

for k in range(6):
    ax = axes[k]
    shadow = kth_shadow(support, k)

    # Create grid
    grid = np.zeros((max_coord + 1, max_coord + 1))
    for (x, y) in shadow:
        if 0 <= x <= max_coord and 0 <= y <= max_coord:
            grid[y, x] = 1  # Note: y is row, x is column

    # Also mark original support
    orig_grid = np.zeros((max_coord + 1, max_coord + 1))
    for (x, y) in support:
        if 0 <= x <= max_coord and 0 <= y <= max_coord:
            orig_grid[y, x] = 1

    # Custom colormap: white=0, light blue=in shadow, dark blue=in original
    combined = np.zeros((max_coord + 1, max_coord + 1))
    for i in range(max_coord + 1):
        for j in range(max_coord + 1):
            if grid[i, j] == 1 and orig_grid[i, j] == 1:
                combined[i, j] = 2  # in both
            elif grid[i, j] == 1:
                combined[i, j] = 1  # in shadow only
            elif orig_grid[i, j] == 1:
                combined[i, j] = 0.5  # in original only (shouldn't happen for k=0)

    colors = ['#f0f0f0', '#ffe0b2', '#4fc3f7', '#1565c0']
    cmap = mcolors.ListedColormap(colors)
    bounds = [0, 0.25, 0.75, 1.5, 2.5]
    norm = mcolors.BoundaryNorm(bounds, cmap.N)

    ax.imshow(combined, cmap=cmap, norm=norm, origin='lower',
              extent=[-0.5, max_coord + 0.5, -0.5, max_coord + 0.5])

    # Add grid lines and labels
    for x in range(max_coord + 1):
        for y in range(max_coord + 1):
            if combined[y, x] > 0:
                ax.plot(x, y, 'o', color='black', markersize=4)

    ax.set_xlim(-0.5, max_coord + 0.5)
    ax.set_ylim(-0.5, max_coord + 0.5)
    ax.set_xticks(range(max_coord + 1))
    ax.set_yticks(range(max_coord + 1))
    ax.set_xlabel('x exponent', fontsize=9)
    ax.set_ylabel('y exponent', fontsize=9)
    ax.set_title(f'k = {k}  (|Sh_{k}| = {len(shadow)})',
                 fontsize=11, fontweight='bold')
    ax.grid(True, alpha=0.2)
    ax.set_aspect('equal')

plt.suptitle('Shadow Contraction: Sh_k(S) for Increasing k\n'
             '(Blue = shadow, Orange = shadow-only, Gray = empty)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
