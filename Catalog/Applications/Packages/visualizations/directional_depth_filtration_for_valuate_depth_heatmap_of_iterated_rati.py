#!/usr/bin/env python3
"""
Visualization: Depth Heatmap of Ratio Transforms

Visualizes how the ratio transform R_i f changes as we iterate,
showing the "depth layers" of a function. Each heatmap shows the
values of the k-th iterated ratio transform, revealing where
log-concavity persists or breaks down.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from itertools import product as iter_product
from typing import Dict, Tuple, List

# Inlined helpers
def make_grid(n, d):
    return [m for m in iter_product(range(d + 1), repeat=n) if sum(m) <= d]

def shift(m, i):
    return tuple(m[j] + (1 if j == i else 0) for j in range(len(m)))

def ratio_xform(f, i, grid):
    r = {}
    for m in grid:
        mu = shift(m, i)
        fm = f.get(m, 0.0)
        fmu = f.get(mu, 0.0)
        if abs(fm) < 1e-15:
            continue
        r[m] = fmu / fm
    return r

def check_dir_lc(f, grid, n, tol=1e-10):
    for i in range(n):
        for m in grid:
            m1 = shift(m, i)
            m2 = shift(m1, i)
            fm, fm1, fm2 = f.get(m, 0.0), f.get(m1, 0.0), f.get(m2, 0.0)
            if fm * fm2 > fm1 * fm1 + tol:
                return False
    return True


# Create test functions
def gaussian_2d(max_deg, sigma=1.5):
    return {m: math.exp(-sum(x**2 for x in m)/(2*sigma**2))
            for m in make_grid(2, max_deg)}

def witness_2d(max_deg):
    """The depth-1 witness extended to 2 variables."""
    f = {}
    vals = {0: 1.0, 1: 3.0, 2: 2.0, 3: 1.0}
    for m in make_grid(2, max_deg):
        f[m] = vals.get(m[0], 0.0) * vals.get(m[1], 0.5)
    return f


# Main visualization
fig, axes = plt.subplots(2, 4, figsize=(16, 8))
fig.suptitle('Directional Depth: Iterated Ratio Transforms', fontsize=14, fontweight='bold')

max_deg = 6
grid = make_grid(2, max_deg)

# Row 1: Gaussian (high depth)
f = gaussian_2d(max_deg)
for k in range(4):
    ax = axes[0, k]
    # Create heatmap data
    data = {}
    for m in grid:
        if len(m) == 2 and m in f:
            data[m] = f[m]

    # Plot as scatter with color
    xs = [m[0] for m in data]
    ys = [m[1] for m in data]
    vs = [max(data[m], 1e-20) for m in data]
    log_vs = [math.log10(v) if v > 0 else -10 for v in vs]

    sc = ax.scatter(xs, ys, c=log_vs, cmap='viridis', s=80, edgecolors='gray', linewidth=0.5)
    is_lc = check_dir_lc(f, grid, 2)
    ax.set_title(f'R⁰·R₀^{k} (Gaussian)\nLC: {"✓" if is_lc else "✗"}', fontsize=10)
    ax.set_xlabel('m₁')
    ax.set_ylabel('m₂')
    ax.set_xlim(-0.5, max_deg + 0.5)
    ax.set_ylim(-0.5, max_deg + 0.5)

    # Apply ratio transform for next iteration
    f_new = ratio_xform(f, 0, grid)
    f = {m: v for m, v in f_new.items() if math.isfinite(v) and v > 1e-20}

# Row 2: Depth-1 witness (breaks at level 2)
f = witness_2d(max_deg)
for k in range(4):
    ax = axes[1, k]
    data = {m: f[m] for m in grid if m in f and f[m] > 1e-20}

    if data:
        xs = [m[0] for m in data]
        ys = [m[1] for m in data]
        vs = [data[m] for m in data]
        log_vs = [math.log10(v) if v > 0 else -10 for v in vs]

        sc = ax.scatter(xs, ys, c=log_vs, cmap='magma', s=80, edgecolors='gray', linewidth=0.5)
        is_lc = check_dir_lc(f, grid, 2)
        ax.set_title(f'R₀^{k} (Witness)\nLC: {"✓" if is_lc else "✗"}', fontsize=10)
    else:
        ax.set_title(f'R₀^{k} (Witness)\nEmpty support', fontsize=10)

    ax.set_xlabel('m₁')
    ax.set_ylabel('m₂')
    ax.set_xlim(-0.5, max_deg + 0.5)
    ax.set_ylim(-0.5, max_deg + 0.5)

    f_new = ratio_xform(f, 0, grid)
    f = {m: v for m, v in f_new.items() if math.isfinite(v) and v > 1e-20}

plt.tight_layout()
plt.savefig('/workspace/request-project/viz_depth_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_heatmap.png")
