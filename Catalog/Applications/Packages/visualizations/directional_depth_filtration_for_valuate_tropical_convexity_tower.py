"""
Visualization: Tropical Convexity Tower

Shows how successive ratio transforms produce a tower of tropical convex
potentials. Each panel shows -log(R^k f) at a different level k,
illustrating how the supermodularity (convexity) persists or degrades
through the depth hierarchy.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math
from typing import Dict, Tuple, List

Multiset = Tuple[int, ...]
WeightFn = Dict[Multiset, float]

def degree_slice(n, d):
    if n == 0: return [()] if d == 0 else []
    if n == 1: return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result

def unit_vector(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def add_multisets(m, e):
    return tuple(a + b for a, b in zip(m, e))

def lookup(wf, m):
    return wf.get(m, 0.0)

def make_weight_fn(f, n, max_deg):
    wf = {}
    for d in range(max_deg + 1):
        for m in degree_slice(n, d):
            wf[m] = f(m)
    return wf

def ratio_transform_fn(wf, n, i):
    result = {}
    ei = unit_vector(n, i)
    for m, fm in wf.items():
        if abs(fm) > 1e-15:
            result[m] = lookup(wf, add_multisets(m, ei)) / fm
    return result

# ── Create the visualization ─────────────────────────────────────────

n = 2
max_deg = 10

# Gaussian weight
def gaussian(m):
    return math.exp(-0.5 * sum(x**2 for x in m))

wf = make_weight_fn(gaussian, n, max_deg)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for level in range(6):
    ax = axes[level // 3][level % 3]
    
    # Extract 2D grid of -log values
    grid_size = max_deg - level
    if grid_size <= 0:
        ax.set_visible(False)
        continue
    
    grid = np.full((grid_size, grid_size), np.nan)
    for m, fm in wf.items():
        if len(m) == 2 and m[0] < grid_size and m[1] < grid_size:
            if fm > 1e-15:
                grid[m[1], m[0]] = -math.log(fm)
    
    im = ax.imshow(grid, origin='lower', cmap='RdYlBu_r', aspect='auto',
                    extent=[-0.5, grid_size-0.5, -0.5, grid_size-0.5])
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    # Check supermodularity
    is_sm = True
    sm_violations = 0
    for m in wf:
        if len(m) != 2: continue
        for i in range(n):
            for j in range(i+1, n):
                ei, ej = unit_vector(n, i), unit_vector(n, j)
                mi = add_multisets(m, ei)
                mj = add_multisets(m, ej)
                mij = add_multisets(mi, ej)
                vals = [lookup(wf, x) for x in [m, mi, mj, mij]]
                if all(v > 1e-15 for v in vals):
                    logs = [-math.log(v) for v in vals]
                    if logs[1] + logs[2] > logs[0] + logs[3] + 1e-10:
                        is_sm = False
                        sm_violations += 1
    
    sm_str = "✓ Supermodular" if is_sm else f"✗ {sm_violations} violations"
    prefix = "f" if level == 0 else f"R₀^{level} f"
    ax.set_title(f'Level {level}: -log({prefix})\n{sm_str}', fontsize=11)
    ax.set_xlabel('m₁', fontsize=10)
    ax.set_ylabel('m₂', fontsize=10)
    
    # Apply ratio transform for next level
    wf = ratio_transform_fn(wf, n, 0)

plt.suptitle('Tropical Convexity Tower: -log of Iterated Ratio Transforms\n'
             'Gaussian f(m) = exp(-½||m||²)', fontsize=14)
plt.tight_layout()
plt.savefig('viz_tropical_tower.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_tower.png")
