#!/usr/bin/env python3
"""
Visualization: Fixed-Point Variety Dimensions for All 256 ECAs
"""

import itertools
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eca_truth_table(rule_num):
    return [(rule_num >> i) & 1 for i in range(8)]


def anf_coefficients(rule_num):
    g = lambda a, b, c: eca_truth_table(rule_num)[a*4 + b*2 + c]
    c = [0]*8
    c[0] = g(0,0,0)
    c[1] = (g(0,0,0)+g(1,0,0))%2
    c[2] = (g(0,0,0)+g(0,1,0))%2
    c[3] = (g(0,0,0)+g(0,0,1))%2
    c[4] = (g(0,0,0)+g(1,0,0)+g(0,1,0)+g(1,1,0))%2
    c[5] = (g(0,0,0)+g(1,0,0)+g(0,0,1)+g(1,0,1))%2
    c[6] = (g(0,0,0)+g(0,1,0)+g(0,0,1)+g(0,1,1))%2
    c[7] = sum(g(a,b,c) for a,b,c in itertools.product([0,1],repeat=3))%2
    return c


def anf_degree(rule_num):
    c = anf_coefficients(rule_num)
    if c[7]: return 3
    if any(c[i] for i in [4,5,6]): return 2
    if any(c[i] for i in [1,2,3]): return 1
    if c[0]: return 0
    return -1


def count_fixed_points(rule_num, n):
    tt = eca_truth_table(rule_num)
    count = 0
    for bits in itertools.product([0,1], repeat=n):
        ok = True
        for i in range(n):
            idx = bits[(i-1)%n]*4 + bits[i]*2 + bits[(i+1)%n]
            if tt[idx] != bits[i]:
                ok = False
                break
        if ok:
            count += 1
    return count


def complement_conjugate(rule_num):
    tt = eca_truth_table(rule_num)
    new = 0
    for a,b,c in itertools.product([0,1], repeat=3):
        idx = a*4 + b*2 + c
        val = (1 + tt[(1-a)*4 + (1-b)*2 + (1-c)]) % 2
        new |= (val << idx)
    return new


# === Figure 1: Fixed-point count heatmap ===
n = 8
fp_counts = [count_fixed_points(r, n) for r in range(256)]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Heatmap
grid = np.array(fp_counts).reshape(16, 16)
im = axes[0].imshow(grid, cmap='viridis', aspect='auto')
axes[0].set_title(f'Fixed-Point Count |V(f)| for n={n} cells', fontsize=12)
axes[0].set_xlabel('Rule number (low nibble)')
axes[0].set_ylabel('Rule number (high nibble)')
plt.colorbar(im, ax=axes[0], label='Number of fixed points')

# Degree vs fixed points
degrees = [anf_degree(r) for r in range(256)]
for deg in [-1, 0, 1, 2, 3]:
    idx = [r for r in range(256) if degrees[r] == deg]
    fps = [fp_counts[r] for r in idx]
    label = f'deg={deg}' if deg >= 0 else 'zero'
    axes[1].scatter([deg + np.random.uniform(-0.2, 0.2) for _ in idx], 
                    [math.log2(fp + 0.5) for fp in fps],
                    alpha=0.5, s=15, label=label)
axes[1].set_xlabel('ANF Polynomial Degree')
axes[1].set_ylabel('log₂(|Fix| + 0.5)')
axes[1].set_title('ANF Degree vs Fixed-Point Count', fontsize=12)
axes[1].legend()

# Complement conjugation verification
fp_orig = []
fp_conj = []
for r in range(256):
    rc = complement_conjugate(r)
    fp_orig.append(fp_counts[r])
    fp_conj.append(fp_counts[rc])
axes[2].scatter(fp_orig, fp_conj, alpha=0.4, s=10, c='crimson')
axes[2].plot([0, max(fp_counts)], [0, max(fp_counts)], 'k--', alpha=0.5, label='y=x')
axes[2].set_xlabel('|Fix(g)|')
axes[2].set_ylabel('|Fix(g̃)|')
axes[2].set_title('Complement Bijection: |Fix(g)| = |Fix(g̃)|', fontsize=12)
axes[2].legend()

plt.tight_layout()
plt.savefig('eca_algebraic_geometry.png', dpi=150)
print("Saved eca_algebraic_geometry.png")
