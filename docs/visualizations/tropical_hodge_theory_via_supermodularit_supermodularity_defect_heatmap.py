#!/usr/bin/env python3
"""
Visualization 1: Tropical Hodge Depth Heatmap

Visualizes the supermodularity defect landscape for different set functions
on a ground set of size 3. Shows how the defect pattern changes across
function families, with depth indicated by color intensity.

The heatmap shows defect values Δ(g; S, T) for all pairs (S, T) of subsets,
revealing the structure that determines tropical Hodge depth.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import math


def powerset(n):
    """Generate all subsets of {0,...,n-1} as frozensets, sorted by size."""
    result = []
    for i in range(1 << n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return sorted(result, key=lambda s: (len(s), sorted(s)))


def supermod_defect(g, s, t):
    return g(s | t) + g(s & t) - g(s) - g(t)


def elem_diff(g, a):
    singleton = frozenset([a])
    return lambda s: g(s | singleton) - g(s)


def check_order(k, g, subsets, ground):
    if k == 0:
        return all(supermod_defect(g, s, t) >= -1e-12
                   for s in subsets for t in subsets)
    if not check_order(k - 1, g, subsets, ground):
        return False
    return all(check_order(k - 1, elem_diff(g, a), subsets, ground)
               for a in ground)


def compute_depth(g, n, max_k=4):
    ground = set(range(n))
    subsets = powerset(n)
    depth = -1
    for k in range(max_k + 1):
        if check_order(k, g, subsets, ground):
            depth = k
        else:
            break
    return depth


def set_label(s):
    if not s:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(s)) + "}"


n = 3
subsets = powerset(n)
labels = [set_label(s) for s in subsets]

functions = {
    "|S| (cardinality)": lambda s: float(len(s)),
    "|S|² (quadratic)": lambda s: float(len(s)**2),
    "2^|S| (exponential)": lambda s: float(2**len(s)),
    "Σwᵢ (modular)": lambda s: float(sum(i + 1 for i in s)),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Supermodularity Defect Heatmaps\n"
             "Δ(g; S, T) = g(S∪T) + g(S∩T) − g(S) − g(T)",
             fontsize=14, fontweight='bold')

for idx, (name, g) in enumerate(functions.items()):
    ax = axes[idx // 2][idx % 2]

    matrix = np.zeros((len(subsets), len(subsets)))
    for i, s in enumerate(subsets):
        for j, t in enumerate(subsets):
            matrix[i, j] = supermod_defect(g, s, t)

    depth = compute_depth(g, n, max_k=4)
    depth_str = f"≥4" if depth >= 4 else str(depth)

    vmax = max(abs(matrix.max()), abs(matrix.min()), 0.1)
    cmap = plt.cm.RdYlGn
    norm = mcolors.TwoSlopeNorm(vmin=-vmax, vcenter=0, vmax=vmax)

    im = ax.imshow(matrix, cmap=cmap, norm=norm, aspect='equal')
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=8)
    ax.set_title(f"{name}\nDepth = {depth_str}", fontsize=11)
    ax.set_xlabel("T")
    ax.set_ylabel("S")

    plt.colorbar(im, ax=ax, shrink=0.8, label="Defect Δ(g; S, T)")

    for i in range(len(subsets)):
        for j in range(len(subsets)):
            val = matrix[i, j]
            color = 'black' if abs(val) < vmax * 0.6 else 'white'
            if abs(val) > 0.01:
                ax.text(j, i, f"{val:.1f}", ha='center', va='center',
                        fontsize=6, color=color)

plt.tight_layout()
plt.savefig("viz_depth_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_depth_heatmap.png")
