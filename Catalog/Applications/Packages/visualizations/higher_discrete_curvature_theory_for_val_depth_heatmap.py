#!/usr/bin/env python3
"""
Visualization 1: Depth Heatmap

Visualizes the directional depth of functions across a 2D parameter space.
Shows how depth varies as we interpolate between different coefficient vectors,
revealing the "depth landscape" and identifying phase transitions between
depth classes.

The x-axis and y-axis represent two parameters controlling the shape of a
1D function, and the color represents the computed directional depth.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as iter_product
from math import exp


def unit_vec(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def add_tuples(*tuples):
    return tuple(sum(x) for x in zip(*tuples))

def multiindices(n, max_deg):
    return list(iter_product(range(max_deg + 1), repeat=n))

def compute_depth_1d(coeffs, max_depth=5, max_deg=8):
    """Compute directional depth of a 1D function given by coefficients."""
    def f(m):
        idx = m[0]
        if 0 <= idx < len(coeffs):
            return coeffs[idx]
        return 0.0

    def is_dlc(g):
        for m in multiindices(1, max_deg):
            e = (1,)
            fm = g(m)
            fm1 = g(add_tuples(m, e))
            fm2 = g(add_tuples(m, e, e))
            if fm1**2 < fm * fm2 - 1e-12:
                return False
        return True

    def ratio_transform(g, i=0):
        e = (1,)
        def Rg(m):
            v = g(m)
            return g(add_tuples(m, e)) / v if abs(v) > 1e-15 else 0
        return Rg

    depth = 0
    fns = [f]
    for k in range(max_depth):
        if not all(is_dlc(fn) for fn in fns):
            break
        depth = k + 1
        fns = [ratio_transform(fn) for fn in fns]
    return depth


# Create the heatmap
# Family: f(0)=1, f(1)=a, f(2)=b, f(3)=c where c = max(0, 2b-a) (maintaining some structure)
# We fix f(0)=1 and scan over a=f(1) and b=f(2)

a_range = np.linspace(0.5, 6.0, 40)
b_range = np.linspace(0.1, 5.0, 40)

depth_map = np.zeros((len(b_range), len(a_range)))

for i, b in enumerate(b_range):
    for j, a in enumerate(a_range):
        # Ensure log-concavity-friendly shape
        c = max(0, b**2 / max(a, 0.01))  # Choose c to be at the boundary
        c = min(c, 10.0)
        coeffs = [1.0, a, b, c * 0.5]  # Slightly below boundary
        depth_map[i, j] = compute_depth_1d(coeffs, max_depth=5, max_deg=6)

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

im = ax.imshow(depth_map, extent=[a_range[0], a_range[-1], b_range[0], b_range[-1]],
               origin='lower', aspect='auto', cmap='viridis',
               vmin=0, vmax=5, interpolation='nearest')

ax.set_xlabel('f(1) = a', fontsize=14)
ax.set_ylabel('f(2) = b', fontsize=14)
ax.set_title('Directional Depth Landscape\n'
             r'$f = [1, a, b, b^2/(2a)]$', fontsize=16)

cbar = plt.colorbar(im, ax=ax, label='Directional Depth')
cbar.set_ticks([0, 1, 2, 3, 4, 5])
cbar.set_ticklabels(['0', '1', '2', '3', '4', '≥5'])

# Add contour lines
cs = ax.contour(a_range, b_range, depth_map, levels=[0.5, 1.5, 2.5],
                colors='white', linewidths=1.5, linestyles='--')
ax.clabel(cs, fmt={0.5: 'depth=0↔1', 1.5: 'depth=1↔2', 2.5: 'depth=2↔3'},
          fontsize=10)

# Mark the log-concavity boundary: a^2 >= 1*b, i.e., b <= a^2
a_boundary = np.linspace(0.5, 6.0, 100)
b_boundary = a_boundary**2
valid = b_boundary <= b_range[-1]
ax.plot(a_boundary[valid], b_boundary[valid], 'r-', linewidth=2,
        label=r'$b = a^2$ (LC boundary)')
ax.legend(loc='upper left', fontsize=11)

plt.tight_layout()
plt.savefig('depth_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved depth_heatmap.png")
