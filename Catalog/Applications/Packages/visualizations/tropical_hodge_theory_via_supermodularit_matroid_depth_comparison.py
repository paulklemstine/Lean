#!/usr/bin/env python3
"""
Visualization 3: Matroid Rank-Defect Depth Comparison

Bar chart comparing the tropical Hodge depth of rank-defect functions
for different matroids on a ground set of size 3. Illustrates how
depth detects matroid structure.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def powerset(n):
    elems = list(range(n))
    result = []
    for i in range(1 << n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return result


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


# Ground set size
n = 3
max_k = 4

# Define various matroid-like functions
matroids = []

# Uniform matroids U(r,3)
for r in range(4):
    name = f"U({r},{n})"
    rank_fn = lambda s, r=r: float(min(len(s), r))
    defect_fn = lambda s, rf=rank_fn: float(len(s)) - rf(s)
    depth = compute_depth(defect_fn, n, max_k=max_k)
    matroids.append((name, depth, f"|S|-min(|S|,{r})"))

# Cardinality (free matroid rank defect = 0)
card_fn = lambda s: float(len(s))
depth = compute_depth(card_fn, n, max_k=max_k)
matroids.append(("|S| (card)", depth, "modular"))

# Quadratic
sq_fn = lambda s: float(len(s)**2)
depth = compute_depth(sq_fn, n, max_k=max_k)
matroids.append(("|S|²", depth, "convex"))

# Modular with weights
mod_fn = lambda s: float(sum(i + 1 for i in s))
depth = compute_depth(mod_fn, n, max_k=max_k)
matroids.append(("Σ(i+1)", depth, "modular"))

# Constant
const_fn = lambda s: 5.0
depth = compute_depth(const_fn, n, max_k=max_k)
matroids.append(("const 5", depth, "constant"))

# Create the bar chart
fig, ax = plt.subplots(figsize=(12, 7))

names = [m[0] for m in matroids]
depths = [m[1] for m in matroids]
descs = [m[2] for m in matroids]

# Color by depth
colors = []
for d in depths:
    if d >= max_k:
        colors.append('#1565C0')  # Deep blue for infinite depth
    elif d == 0:
        colors.append('#E53935')  # Red for depth 0
    else:
        colors.append('#FFA726')  # Orange for intermediate

bars = ax.bar(range(len(names)), depths, color=colors, edgecolor='black',
              linewidth=0.5, alpha=0.85)

# Add value labels
for i, (bar, d, desc) in enumerate(zip(bars, depths, descs)):
    label = f"≥{max_k}" if d >= max_k else str(d)
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
            label, ha='center', va='bottom', fontweight='bold', fontsize=11)
    ax.text(bar.get_x() + bar.get_width()/2., -0.35,
            desc, ha='center', va='top', fontsize=8, color='gray',
            fontstyle='italic')

ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, rotation=30, ha='right', fontsize=10)
ax.set_ylabel("Tropical Hodge Depth", fontsize=12)
ax.set_title(
    "Tropical Hodge Depth of Set Functions\n"
    f"Ground set size n={n}",
    fontsize=14, fontweight='bold'
)
ax.set_ylim(-0.5, max_k + 1)
ax.axhline(y=0, color='gray', linewidth=0.5)

# Add a legend for colors
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#E53935', edgecolor='black', label='Depth 0 (barely supermodular)'),
    Patch(facecolor='#FFA726', edgecolor='black', label='Intermediate depth'),
    Patch(facecolor='#1565C0', edgecolor='black', label=f'Depth ≥{max_k} (all orders)'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# Add annotation
ax.annotate(
    'Free/modular functions achieve\nmaximum depth (all orders)',
    xy=(4, max_k), xytext=(2, max_k - 0.8),
    fontsize=9, color='#1565C0',
    arrowprops=dict(arrowstyle='->', color='#1565C0', lw=1.5),
    bbox=dict(boxstyle='round,pad=0.3', facecolor='#E3F2FD', edgecolor='#1565C0')
)

ax.annotate(
    'Constrained matroids have\ndepth 0 — structure detected!',
    xy=(1, 0), xytext=(3.5, 1.5),
    fontsize=9, color='#E53935',
    arrowprops=dict(arrowstyle='->', color='#E53935', lw=1.5),
    bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFEBEE', edgecolor='#E53935')
)

plt.tight_layout()
plt.savefig("viz_matroid_depths.png", dpi=150, bbox_inches='tight')
print("Saved viz_matroid_depths.png")
