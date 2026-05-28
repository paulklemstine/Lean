"""
Visualization 2: Shadow Erosion in 2D

Visualizes the progressive erosion of a 2D lattice support under iterated
shadow operations. Shows how the support shrinks step by step, like a
sandcastle dissolving under mathematical tides.
"""

import itertools
import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.size'] = 11

# ============================================================
# Self-contained core functions
# ============================================================

def total_mass(v):
    return sum(v)

def _gen_multiindex(remaining, bound, idx, n, current, results):
    if idx == n - 1:
        if remaining <= bound[idx]:
            results.append(tuple(current + [remaining]))
        return
    for v in range(min(remaining, bound[idx]) + 1):
        current.append(v)
        _gen_multiindex(remaining - v, bound, idx + 1, n, current, results)
        current.pop()

def kth_shadow(S, k, n):
    if not S:
        return set()
    shadow = set()
    for alpha in S:
        results = []
        _gen_multiindex(k, alpha, 0, n, [], results)
        for tau in results:
            beta = tuple(alpha[i] - tau[i] for i in range(n))
            shadow.add(beta)
    return shadow

def simplex_support(n, d):
    result = set()
    def gen(remaining, idx, current):
        if idx == n:
            result.add(tuple(current))
            return
        for v in range(remaining + 1):
            current.append(v)
            gen(remaining - v, idx + 1, current)
            current.pop()
    gen(d, 0, [])
    return result

def box_support(bounds):
    ranges = [range(b + 1) for b in bounds]
    return set(itertools.product(*ranges))

# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(2, 4, figsize=(16, 8))
fig.suptitle('Shadow Erosion: Lattice Points Vanishing Under Differentiation', 
             fontsize=14, fontweight='bold')

# Case 1: Simplex in 2D with d=5
S = simplex_support(2, 5)
n = 2
D = 5

cmap = plt.cm.viridis
for k in range(min(D + 1, 4)):
    ax = axes[0, k]
    shadow = kth_shadow(S, k, n)
    
    # Plot all original points in light gray
    for v in S:
        ax.plot(v[0], v[1], 'o', color='lightgray', markersize=8, zorder=1)
    
    # Plot shadow points in color
    if shadow:
        xs = [v[0] for v in shadow]
        ys = [v[1] for v in shadow]
        color = cmap(k / max(D, 1))
        ax.scatter(xs, ys, c=[color]*len(xs), s=80, zorder=2, edgecolors='black', linewidths=0.5)
    
    ax.set_xlim(-0.5, 6)
    ax.set_ylim(-0.5, 6)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.set_title(f'Sh_{k}(Σ₅) : {len(shadow)} pts', fontsize=11)
    if k == 0:
        ax.set_ylabel('Simplex(2,5)', fontsize=12, fontweight='bold')

# Case 2: Box in 2D with bounds (3,4)
S = box_support((3, 4))
n = 2
D = 7

for k_idx, k in enumerate([0, 2, 4, 6]):
    ax = axes[1, k_idx]
    shadow = kth_shadow(S, k, n)
    
    # Plot all original points in light gray
    for v in S:
        ax.plot(v[0], v[1], 'o', color='lightgray', markersize=8, zorder=1)
    
    # Plot shadow points in color
    if shadow:
        xs = [v[0] for v in shadow]
        ys = [v[1] for v in shadow]
        color = plt.cm.magma(k / max(D, 1))
        ax.scatter(xs, ys, c=[color]*len(xs), s=80, zorder=2, edgecolors='black', linewidths=0.5)
    
    ax.set_xlim(-0.5, 5)
    ax.set_ylim(-0.5, 5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.set_title(f'Sh_{k}(Box) : {len(shadow)} pts', fontsize=11)
    if k_idx == 0:
        ax.set_ylabel('Box(3,4)', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig('shadow_erosion.png', dpi=150, bbox_inches='tight')
print("Saved shadow_erosion.png")
