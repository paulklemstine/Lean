#!/usr/bin/env python3
"""
Visualization 2: Nested Cones of the Tropical Hodge Hierarchy

Shows the nested cone structure of the supermodularity hierarchy
in a 2D projection. For a ground set of size 2 (so the function
is determined by g(∅), g({0}), g({1}), g({0,1})), we fix g(∅)=0
and g({0,1})=c (parameterized), then visualize the feasible region
for g({0}), g({1}) at each depth level.

This creates a diagram showing how higher depths restrict the
function space to smaller and smaller sub-cones.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def check_supermod_order_2d(k, vals):
    """
    Check SupermodularOrder k for g on ground set {0,1}.
    vals = (g_empty, g_0, g_1, g_01) = (g(∅), g({0}), g({1}), g({0,1}))
    """
    g_e, g_0, g_1, g_01 = vals

    # All subsets: ∅, {0}, {1}, {0,1}
    # Defects to check for order 0:
    # (∅,∅): 0  (∅,{0}): 0  (∅,{1}): 0  (∅,{0,1}): 0
    # ({0},{0}): 0  ({0},{1}): g_01 + g_e - g_0 - g_1
    # ({0},{0,1}): 0  ({1},{0,1}): 0
    # ({1},{1}): 0  ({0,1},{0,1}): 0

    defect_01 = g_01 + g_e - g_0 - g_1  # The only non-trivial defect

    if k == 0:
        return defect_01 >= -1e-12

    if k >= 1:
        if defect_01 < -1e-12:
            return False
        # elemDiff with 0: Δ₀g(s) = g(s∪{0}) - g(s)
        # Δ₀g(∅) = g_0 - g_e, Δ₀g({0}) = 0, Δ₀g({1}) = g_01 - g_1, Δ₀g({0,1}) = 0
        d0_e = g_0 - g_e
        d0_1 = g_01 - g_1
        # defect of Δ₀g at ({1}, ∅): actually for order 0 of Δ₀g, all pairs
        # The only non-trivial: sets {1} and ∅ (or {1} and {0}, etc.)
        # Δ₀g on subsets of {0,1}: value at ∅=d0_e, {0}=0, {1}=d0_1, {0,1}=0
        # defect({0},{1}) = 0 + d0_e - 0 - d0_1 = d0_e - d0_1 = (g_0-g_e)-(g_01-g_1)
        defect_d0 = (g_0 - g_e) - (g_01 - g_1)  # = g_0 + g_1 - g_e - g_01 = -defect_01
        # Also defect(∅, {0,1}) of Δ₀g = 0 + 0 - d0_e - 0 = -d0_e ... wait
        # More carefully: subsets are ∅,{0},{1},{0,1}
        # Δ₀g: ∅→d0_e, {0}→0, {1}→d0_1, {0,1}→0
        # defect(s,t) for Δ₀g:
        # ({0},{1}): Δ₀g({0,1}) + Δ₀g(∅) - Δ₀g({0}) - Δ₀g({1}) = 0+d0_e-0-d0_1
        # This is (g_0-g_e)-(g_01-g_1) = -(g_01+g_e-g_0-g_1) = -defect_01
        # For this to be ≥ 0, need defect_01 ≤ 0.
        # Combined with defect_01 ≥ 0, need defect_01 = 0.

        # elemDiff with 1: symmetric
        # defect of Δ₁g at ({0},{∅}) is also -defect_01

        if k >= 1:
            return abs(defect_01) < 1e-12  # need defect = 0 for order 1

    return abs(defect_01) < 1e-12


fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Fix g(∅) = 0
g_e = 0.0

# We'll plot g({0}) on x-axis, g({1}) on y-axis
# and color points by the maximum depth they achieve

x_range = np.linspace(-3, 3, 300)
y_range = np.linspace(-3, 3, 300)
X, Y = np.meshgrid(x_range, y_range)

# For various values of g({0,1})
g_01 = 2.0  # Fix g({0,1}) = 2

depth_map = np.full(X.shape, -1.0)

for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        g_0 = X[i, j]
        g_1 = Y[i, j]
        vals = (g_e, g_0, g_1, g_01)

        # Check orders
        if check_supermod_order_2d(0, vals):
            depth_map[i, j] = 0
            if check_supermod_order_2d(1, vals):
                depth_map[i, j] = 1
        # Depth ≥ 1 means modular (defect = 0)

# Create a custom colormap
colors = ['#f0f0f0', '#4CAF50', '#1565C0']
bounds = [-0.5, -0.01, 0.5, 1.5]
cmap = plt.cm.colors.ListedColormap(colors)
norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

im = ax.pcolormesh(X, Y, depth_map, cmap=cmap, norm=norm, shading='auto')

# Draw the boundary: defect = 0 line
# defect = g_01 + g_e - g_0 - g_1 = 2 - x - y ≥ 0
# i.e., x + y ≤ 2
ax.plot(x_range, 2 - x_range, 'k-', linewidth=2, label='Depth 0 boundary: x+y=2')

# The modular line is where defect = 0: x + y = 2
# Depth ≥ 1 region is the LINE x + y = 2

ax.set_xlabel("g({0})", fontsize=12)
ax.set_ylabel("g({1})", fontsize=12)
ax.set_title(
    "Nested Cones of the Tropical Hodge Hierarchy\n"
    f"Ground set {{0,1}}, g(∅)={g_e}, g({{0,1}})={g_01}",
    fontsize=13, fontweight='bold'
)

# Legend
legend_patches = [
    mpatches.Patch(color=colors[0], label='Not supermodular (depth < 0)'),
    mpatches.Patch(color=colors[1], label='Depth 0 (supermodular)'),
    mpatches.Patch(color=colors[2], label='Depth ≥ 1 (modular, on line x+y=2)'),
]
ax.legend(handles=legend_patches, loc='upper right', fontsize=10)

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Annotate the modular line
ax.annotate('Modular line\n(infinite depth)',
            xy=(0, 2), xytext=(-2.5, 0.5),
            fontsize=10, color='#1565C0',
            arrowprops=dict(arrowstyle='->', color='#1565C0'))

# Annotate the supermodular cone
ax.annotate('Supermodular cone\n(depth ≥ 0)',
            xy=(-1, 1), xytext=(-2.5, -1.5),
            fontsize=10, color='#4CAF50',
            arrowprops=dict(arrowstyle='->', color='#4CAF50'))

plt.tight_layout()
plt.savefig("viz_hierarchy_cones.png", dpi=150, bbox_inches='tight')
print("Saved viz_hierarchy_cones.png")
