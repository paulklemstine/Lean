#!/usr/bin/env python3
"""
Visualization 2: Polynomial Degree vs Fixed-Point Dimension
============================================================
Scatter plot showing the relationship between the algebraic degree
of an ECA rule's polynomial representation over GF(2) and the
dimension of its fixed-point variety. This reveals whether
polynomial complexity predicts dynamical complexity.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from math import log2


def eca_local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def rule_to_anf(r):
    table = [(r >> i) & 1 for i in range(8)]
    anf = table.copy()
    for bit in range(3):
        step = 1 << bit
        for j in range(8):
            if j & step:
                anf[j] ^= anf[j ^ step]
    return anf


def anf_degree(anf):
    max_deg = 0
    for i in range(8):
        if anf[i]:
            max_deg = max(max_deg, bin(i).count('1'))
    return max_deg


def transfer_matrix(r):
    T = np.zeros((4, 4), dtype=int)
    for row in range(4):
        si = (row >> 1) & 1
        sj = row & 1
        for sk in range(2):
            col = 2 * sj + sk
            if eca_local_rule(r, si, sj, sk) == sj:
                T[row, col] = 1
    return T


def count_fixed_points_transfer(r, n):
    T = transfer_matrix(r)
    Tn = np.linalg.matrix_power(T, n)
    return int(round(np.trace(Tn)))


def cryptographic_nonlinearity(r):
    truth_table = [(r >> i) & 1 for i in range(8)]
    wht = [0] * 8
    for w in range(8):
        for x in range(8):
            wx = sum(((w >> b) & 1) * ((x >> b) & 1) for b in range(3)) % 2
            wht[w] += (-1) ** (truth_table[x] ^ wx)
    max_wht = max(abs(v) for v in wht)
    return (8 - max_wht) // 2


n = 10
degrees = []
dimensions = []
nonlinearities = []
rules = []

for r in range(256):
    anf = rule_to_anf(r)
    deg = anf_degree(anf)
    fp = count_fixed_points_transfer(r, n)
    dim = log2(fp) if fp > 0 else -0.5
    nl = cryptographic_nonlinearity(r)
    
    degrees.append(deg)
    dimensions.append(dim)
    nonlinearities.append(nl)
    rules.append(r)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Degree vs Dimension
ax1 = axes[0]
scatter1 = ax1.scatter(degrees, dimensions, c=nonlinearities, cmap='viridis',
                       alpha=0.6, s=30, edgecolors='gray', linewidths=0.3)
ax1.set_xlabel('Polynomial Degree over GF(2)', fontsize=12)
ax1.set_ylabel(f'Fixed-Point Variety Dimension (n={n})', fontsize=12)
ax1.set_title('Polynomial Degree vs Variety Dimension', fontsize=13, fontweight='bold')
cbar1 = plt.colorbar(scatter1, ax=ax1)
cbar1.set_label('Nonlinearity')

# Annotate special rules
special = {0: 'R0', 90: 'R90', 110: 'R110', 204: 'R204', 150: 'R150', 30: 'R30'}
for r, label in special.items():
    idx = rules.index(r)
    ax1.annotate(label, (degrees[idx], dimensions[idx]), 
                textcoords="offset points", xytext=(5, 5), fontsize=8,
                fontweight='bold', color='red')

# Add jitter to degrees for visibility
jittered_degrees = [d + np.random.uniform(-0.15, 0.15) for d in degrees]

# Plot 2: Degree histogram colored by dimension
ax2 = axes[1]
deg_counts = {}
for deg, dim in zip(degrees, dimensions):
    deg_counts.setdefault(deg, []).append(dim)

positions = sorted(deg_counts.keys())
bp_data = [deg_counts[d] for d in positions]
bp = ax2.boxplot(bp_data, positions=positions, widths=0.4, patch_artist=True)

colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']
for patch, color in zip(bp['boxes'], colors):
    patch.set_facecolor(color)
    patch.set_alpha(0.6)

ax2.set_xlabel('Polynomial Degree over GF(2)', fontsize=12)
ax2.set_ylabel(f'Fixed-Point Variety Dimension (n={n})', fontsize=12)
ax2.set_title('Dimension Distribution by Degree', fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_polynomial_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_polynomial_landscape.png")
