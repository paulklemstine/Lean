"""
Visualization: Shadow Heatmap for 2D Polynomial Supports

Shows the k-th shadow structure as a heatmap over the lattice Z^2,
illustrating how the shadow contracts the support set as k increases.

This script is fully self-contained — all needed functions are inlined.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# --- Self-contained core functions ---

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow


# --- Generate a sample 2D support ---
# Homogeneous polynomial of degree 5 in 2 variables
d = 6
S = {(i, d - i) for i in range(d + 1)}
# Add some extra monomials for visual interest
S.update({(2, 2), (3, 1), (1, 3), (4, 0), (0, 4)})

max_k = max(sum(a) for a in S)

# --- Create heatmap ---
fig, axes = plt.subplots(2, 4, figsize=(16, 8))
axes = axes.flatten()

for idx, k in enumerate(range(min(8, max_k + 2))):
    ax = axes[idx]
    shadow = kth_shadow(S, k)

    # Create grid
    if shadow:
        max_coord = max(max(p) for p in shadow) + 1
    else:
        max_coord = max(max(p) for p in S) + 1

    grid = np.zeros((max_coord + 1, max_coord + 1))
    for pt in shadow:
        if pt[0] <= max_coord and pt[1] <= max_coord:
            grid[pt[1], pt[0]] = 1  # note: y, x for imshow

    # Also mark original support
    for pt in S:
        if pt[0] <= max_coord and pt[1] <= max_coord:
            if grid[pt[1], pt[0]] == 0:
                grid[pt[1], pt[0]] = 0.3  # faded original

    im = ax.imshow(grid, cmap='YlOrRd', origin='lower', vmin=0, vmax=1,
                   aspect='equal', interpolation='nearest')
    ax.set_title(f'Shadow$_{{ {k} }}$ ({len(shadow)} pts)', fontsize=11)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')

    # Add grid lines
    ax.set_xticks(np.arange(-0.5, max_coord + 1, 1), minor=True)
    ax.set_yticks(np.arange(-0.5, max_coord + 1, 1), minor=True)
    ax.grid(which='minor', color='gray', linewidth=0.5, alpha=0.3)
    ax.tick_params(which='minor', size=0)

plt.suptitle('Shadow Contraction: Support Shrinks as Derivative Order Increases',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
