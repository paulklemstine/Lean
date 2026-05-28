#!/usr/bin/env python3
"""
Visualization: Depth Profile Comparison

Compares the depth profiles of different function families:
Gaussian, power, multinomial, and the depth-1 witness.
Shows how depth varies with parameters and family type.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iter_product
from typing import Dict, Tuple, List

# Inlined core
def make_grid(n, d):
    return [m for m in iter_product(range(d + 1), repeat=n) if sum(m) <= d]

def make_slice(n, d):
    return [m for m in iter_product(range(d + 1), repeat=n) if sum(m) == d]

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

def compute_depth(f, n, d, maxk=5, tol=1e-10):
    grid = make_grid(n, d)
    return _drec(f, n, grid, maxk, tol)

def _drec(f, n, grid, rem, tol):
    if rem <= 0:
        return 0
    ok = check_dir_lc(f, grid, n, tol)
    if not ok:
        return 0
    msub = rem - 1
    for i in range(n):
        Rf = ratio_xform(f, i, grid)
        sg = [m for m in grid if m in Rf]
        sd = _drec(Rf, n, sg, rem - 1, tol)
        msub = min(msub, sd)
        if msub == 0:
            break
    return 1 + msub


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Depth Profiles Across Function Families', fontsize=14, fontweight='bold')

# Panel 1: Depth vs sigma for Gaussians
sigmas = [0.3, 0.5, 0.7, 1.0, 1.5, 2.0, 3.0, 5.0]
depths_gauss = []
for sigma in sigmas:
    f = {m: math.exp(-sum(x**2 for x in m)/(2*sigma**2)) for m in make_grid(2, 4)}
    depths_gauss.append(compute_depth(f, 2, 4, maxk=4))

ax = axes[0]
ax.bar(range(len(sigmas)), depths_gauss, color='steelblue', alpha=0.8)
ax.set_xticks(range(len(sigmas)))
ax.set_xticklabels([f'{s:.1f}' for s in sigmas], rotation=45)
ax.set_xlabel('σ (Gaussian width)')
ax.set_ylabel('Directional Depth')
ax.set_title('Gaussian: Depth vs Width')
ax.set_ylim(0, 5)
ax.axhline(y=4, color='green', linestyle='--', alpha=0.5, label='max tested')
ax.legend(fontsize=8)

# Panel 2: Depth of 1D sequences
sequences = {
    'Binomial\nC(6,k)': [math.comb(6, k) for k in range(7)],
    'Powers\n2^k': [2**k for k in range(7)],
    'Powers\n(1/2)^k': [0.5**k for k in range(7)],
    'Factorials\nk!': [math.factorial(k) for k in range(7)],
    'Witness\n1,3,2,1': [1, 3, 2, 1, 0.5, 0.25, 0.125],
}

names = list(sequences.keys())
depths_seq = []
for name, seq in sequences.items():
    f = {(k,): v for k, v in enumerate(seq)}
    depths_seq.append(compute_depth(f, 1, len(seq)-1, maxk=5))

ax = axes[1]
colors = ['steelblue', 'coral', 'seagreen', 'gold', 'crimson']
ax.bar(range(len(names)), depths_seq, color=colors, alpha=0.8)
ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, fontsize=8)
ax.set_ylabel('Directional Depth')
ax.set_title('1D Sequences: Depth Hierarchy')
ax.set_ylim(0, 6)

# Panel 3: Ratio transform values for depth-1 witness
f_wit = {(k,): v for k, v in enumerate([1.0, 3.0, 2.0, 1.0, 0.5, 0.25])}
grid_1d = make_grid(1, 5)

# Original function
vals_orig = [f_wit.get((k,), 0) for k in range(6)]
R0 = ratio_xform(f_wit, 0, grid_1d)
vals_r0 = [R0.get((k,), 0) for k in range(5)]
R0_clean = {m: v for m, v in R0.items() if v > 1e-15}
R1 = ratio_xform(R0_clean, 0, grid_1d)
vals_r1 = [R1.get((k,), 0) for k in range(4)]

ax = axes[2]
ax.plot(range(6), vals_orig, 'o-', color='steelblue', linewidth=2, markersize=8, label='f')
ax.plot(range(5), vals_r0, 's-', color='coral', linewidth=2, markersize=8, label='R₀f')
ax.plot(range(4), vals_r1, 'D-', color='seagreen', linewidth=2, markersize=8, label='R₀²f')
ax.set_xlabel('Index k')
ax.set_ylabel('Value')
ax.set_title('Ratio Transform Layers\n(Depth-1 Witness)')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/viz_depth_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_profile.png")
