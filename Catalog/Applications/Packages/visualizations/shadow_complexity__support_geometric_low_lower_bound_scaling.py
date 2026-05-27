#!/usr/bin/env python3
"""
Visualization 2: Lower Bound Scaling
Shows how the shadow complexity lower bound |Sh₂(S)|/n² scales across
different polynomial families and dimensions.

Demonstrates that the bound grows meaningfully with problem size,
establishing the practical relevance of the shadow-geometric approach.
"""

import matplotlib.pyplot as plt
import numpy as np
import math
from typing import Set, Tuple

ExponentVector = Tuple[int, ...]

def subtract_pair_basis(alpha, i, j):
    lst = list(alpha)
    if lst[i] < 1: return None
    lst[i] -= 1
    if lst[j] < 1: return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S, n):
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def simplex_support(d, m):
    if d == 0: return {()} if m == 0 else set()
    if d == 1: return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result

def greedy_circuit(S, n):
    available = set()
    gates = 0
    for i in range(n):
        for j in range(n):
            needed = set()
            for alpha in S:
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    needed.add(beta)
            new = needed - available
            gates += len(new)
            available.update(new)
    return gates

# ─── Compute data ────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Shadow size vs support size for simplex families
ax1 = axes[0]
for d in [2, 3, 4, 5]:
    ms = list(range(2, 16))
    support_sizes = []
    shadow_sizes = []
    for m in ms:
        ss = math.comb(m + d - 1, d - 1)
        sh = math.comb(m + d - 3, d - 1)
        if ss > 50000:
            break
        support_sizes.append(ss)
        shadow_sizes.append(sh)
    ax1.plot(support_sizes, shadow_sizes, 'o-', label=f'd={d}', markersize=5)

ax1.set_xlabel('Support size |S|', fontsize=12)
ax1.set_ylabel('Shadow size |Sh₂(S)|', fontsize=12)
ax1.set_title('Shadow Growth for Simplex Families', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xscale('log')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Lower bound vs degree for fixed dimensions
ax2 = axes[1]
for d in [2, 3, 4]:
    ms = list(range(2, 20))
    lbs = []
    degs = []
    for m in ms:
        sh_size = math.comb(m + d - 3, d - 1)
        lb = sh_size / (d ** 2)
        if math.comb(m + d - 1, d - 1) > 100000:
            break
        degs.append(m)
        lbs.append(lb)
    ax2.plot(degs, lbs, 's-', label=f'd={d}', markersize=5)

ax2.set_xlabel('Degree m', fontsize=12)
ax2.set_ylabel('Lower bound |Sh₂|/d²', fontsize=12)
ax2.set_title('Circuit Lower Bound vs Degree', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Greedy circuit vs lower bound (computed)
ax3 = axes[2]
dims = [2, 3]
for d in dims:
    ms = list(range(3, 12))
    lbs_actual = []
    greedys = []
    for m in ms:
        S = simplex_support(d, m)
        if len(S) > 5000:
            break
        sh = second_shadow(S, d)
        lb = len(sh) / (d ** 2)
        gc = greedy_circuit(S, d)
        lbs_actual.append(lb)
        greedys.append(gc)
    if lbs_actual:
        ax3.plot(lbs_actual, greedys, 'D-', label=f'd={d}', markersize=5)

# Plot y=x reference line
max_val = max(max(lbs_actual), max(greedys)) if lbs_actual else 10
ax3.plot([0, max_val * 1.1], [0, max_val * 1.1], 'k--', alpha=0.5, label='y = x')
ax3.set_xlabel('Lower bound |Sh₂|/d²', fontsize=12)
ax3.set_ylabel('Greedy circuit size', fontsize=12)
ax3.set_title('Greedy vs Lower Bound', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

fig.suptitle("Shadow Complexity Lower Bounds for Arithmetic Circuits",
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig("lower_bound_scaling.png", dpi=150, bbox_inches='tight')
print("Saved lower_bound_scaling.png")
