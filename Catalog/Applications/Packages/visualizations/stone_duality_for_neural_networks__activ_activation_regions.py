"""
Visualization: Activation Regions of a ReLU Network
=====================================================
Shows how hyperplanes partition R^2 into activation regions,
each colored by its activation pattern. The hyperplane boundaries
are drawn as lines, and each region is shaded.

This visualizes the core concept of the activation Boolean algebra:
the atoms are the colored regions, and the Boolean algebra consists
of all possible unions of these regions.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import matplotlib.patches as mpatches


def hyperplane_eval(w, b, x):
    return w[0] * x[0] + w[1] * x[1] + b


def activation_pattern(Ws, bs, x):
    return tuple(hyperplane_eval(w, b, x) > 0 for w, b in zip(Ws, bs))


# Create hyperplane arrangement: 5 neurons in R^2
np.random.seed(42)
m = 5
Ws = [np.array([2.0, -1.0]),
      np.array([-1.0, 2.0]),
      np.array([1.5, 1.0]),
      np.array([-0.5, -1.5]),
      np.array([1.0, 0.3])]
bs = [0.2, -0.3, -0.8, 0.5, -0.1]

# Create grid
resolution = 500
x_range = np.linspace(-3, 3, resolution)
y_range = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x_range, y_range)

# Compute activation pattern for each grid point
patterns = {}
pattern_grid = np.zeros((resolution, resolution), dtype=int)

for i in range(resolution):
    for j in range(resolution):
        point = np.array([X[i, j], Y[i, j]])
        p = activation_pattern(Ws, bs, point)
        if p not in patterns:
            patterns[p] = len(patterns)
        pattern_grid[i, j] = patterns[p]

n_regions = len(patterns)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Activation regions
ax1 = axes[0]
cmap = plt.cm.get_cmap('tab20', n_regions)
im = ax1.pcolormesh(X, Y, pattern_grid, cmap=cmap, shading='auto')

# Draw hyperplane boundaries
for k in range(m):
    w, b = Ws[k], bs[k]
    if abs(w[1]) > 1e-10:
        x_line = np.linspace(-3, 3, 100)
        y_line = -(w[0] * x_line + b) / w[1]
        mask = (y_line >= -3) & (y_line <= 3)
        ax1.plot(x_line[mask], y_line[mask], 'k-', linewidth=1.5, alpha=0.7)
    else:
        x_val = -b / w[0]
        if -3 <= x_val <= 3:
            ax1.axvline(x=x_val, color='k', linewidth=1.5, alpha=0.7)

from math import comb
zas = sum(comb(m, k) for k in range(3))  # n=2

ax1.set_xlim(-3, 3)
ax1.set_ylim(-3, 3)
ax1.set_xlabel('x₁', fontsize=14)
ax1.set_ylabel('x₂', fontsize=14)
ax1.set_title(f'Activation Regions ({n_regions} regions, Zaslavsky bound = {zas})',
              fontsize=13)
ax1.set_aspect('equal')

# Right: Boolean algebra structure
ax2 = axes[1]
# Show the lattice of the Boolean algebra
# For visualization, show a sample of elements

# The atoms are the realized patterns
atom_labels = [f'R{i}' for i in range(min(n_regions, 8))]
n_show = min(n_regions, 6)

# Draw Hasse diagram of a small Boolean algebra
positions = {}
level_counts = {}

for k in range(n_show + 1):
    level_counts[k] = 0

# Place nodes
y_spacing = 1.0
for size in range(n_show + 1):
    subsets = []
    if size == 0:
        subsets = [frozenset()]
    elif size == n_show:
        subsets = [frozenset(range(n_show))]
    elif size == 1:
        subsets = [frozenset([i]) for i in range(n_show)]
    elif size == n_show - 1:
        subsets = [frozenset(range(n_show)) - frozenset([i]) for i in range(n_show)]
    else:
        # Only show a few
        from itertools import combinations
        subsets = [frozenset(c) for c in combinations(range(n_show), size)]
        if len(subsets) > 6:
            subsets = subsets[:6]

    for idx, s in enumerate(subsets):
        x_pos = (idx - len(subsets) / 2 + 0.5) * 1.5
        y_pos = size * y_spacing
        positions[s] = (x_pos, y_pos)

# Draw edges for a subset of the lattice
for s1, (x1, y1) in positions.items():
    for s2, (x2, y2) in positions.items():
        if s1 < s2 and len(s2) == len(s1) + 1:
            ax2.plot([x1, x2], [y1, y2], 'gray', linewidth=0.5, alpha=0.5)

# Draw nodes
for s, (x, y) in positions.items():
    color = cmap(list(s)[0]) if len(s) == 1 else ('white' if len(s) == 0 else 'lightblue')
    ax2.plot(x, y, 'o', markersize=12, color=color,
             markeredgecolor='black', markeredgewidth=1)
    if len(s) <= 1:
        label = '∅' if len(s) == 0 else f'R{list(s)[0]}'
        ax2.annotate(label, (x, y), textcoords="offset points",
                     xytext=(0, -18), ha='center', fontsize=8)

ax2.set_xlim(-5, 5)
ax2.set_ylim(-0.5, n_show + 0.5)
ax2.set_title(f'Activation Boolean Algebra\n(2^{n_regions} = {2**n_regions} elements)',
              fontsize=13)
ax2.axis('off')

plt.suptitle('Stone Duality for Neural Networks:\nActivation Patterns as Boolean Algebra Atoms',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('activation_regions.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Saved activation_regions.png ({n_regions} regions found)")
