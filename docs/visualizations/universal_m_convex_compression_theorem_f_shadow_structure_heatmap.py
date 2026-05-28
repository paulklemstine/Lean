"""
Visualization: Shadow Structure Heatmap

Visualizes the fiber sizes across the degree-(r-2) shadow of an M-convex support.
Shows how the dominating fiber varies across different shadow elements,
illustrating the compression theorem's key structure.

For a degree-3 polynomial in 3 variables with full simplex support,
the shadow consists of degree-1 vectors. The heatmap shows how many
support elements dominate each shadow element.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import combinations, product


def total_degree(alpha):
    return sum(alpha)

def dominates(alpha, beta):
    return all(a <= b for a, b in zip(alpha, beta))

def degree_shadow(S, k):
    shadow = set()
    for beta in S:
        _gen(beta, k, 0, [], shadow)
    return shadow

def _gen(beta, target, idx, current, result):
    n = len(beta)
    remaining = target - sum(current)
    if idx == n:
        if remaining == 0:
            result.add(tuple(current))
        return
    max_val = min(beta[idx], remaining)
    for val in range(max_val + 1):
        new_rem = remaining - val
        if new_rem >= 0 and new_rem <= sum(beta[idx+1:]):
            current.append(val)
            _gen(beta, target, idx + 1, current, result)
            current.pop()

def quadratic_leaf_fiber(S, alpha):
    target = total_degree(alpha) + 2
    return {beta for beta in S if dominates(alpha, beta) and total_degree(beta) == target}

def full_degree_simplex(n, r):
    if n == 1:
        return {(r,)}
    result = set()
    for v in range(r + 1):
        for rest in full_degree_simplex(n - 1, r - v):
            result.add((v,) + rest)
    return result

def matroid_basis_support(bases, n):
    support = set()
    for basis in bases:
        vec = tuple(1 if i in basis else 0 for i in range(n))
        support.add(vec)
    return support


# Create figure with multiple panels
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ─── Panel 1: Uniform Matroid U_{3,5} ───
n, r = 5, 3
bases = [set(c) for c in combinations(range(n), r)]
S1 = matroid_basis_support(bases, n)
shadow1 = sorted(degree_shadow(S1, r - 2))

fiber_sizes_1 = [len(quadratic_leaf_fiber(S1, a)) for a in shadow1]
labels_1 = [str(a) for a in shadow1]

ax = axes[0]
colors = plt.cm.YlOrRd(np.array(fiber_sizes_1) / max(fiber_sizes_1))
bars = ax.bar(range(len(shadow1)), fiber_sizes_1, color=colors, edgecolor='black', linewidth=0.5)
ax.set_xticks(range(len(shadow1)))
ax.set_xticklabels(labels_1, rotation=45, ha='right', fontsize=7)
ax.set_ylabel('Fiber Size', fontsize=10)
ax.set_title(f'Uniform Matroid U(3,5)\n|Shadow|={len(shadow1)}', fontsize=11, fontweight='bold')
ax.set_ylim(0, max(fiber_sizes_1) + 1)

for bar, sz in zip(bars, fiber_sizes_1):
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
            str(sz), ha='center', va='bottom', fontsize=8)

# ─── Panel 2: Non-matroidal M-convex (degree-3 simplex, 3 vars) ───
S2 = full_degree_simplex(3, 3)
shadow2 = sorted(degree_shadow(S2, 1))

fiber_sizes_2 = [len(quadratic_leaf_fiber(S2, a)) for a in shadow2]
labels_2 = [str(a) for a in shadow2]

ax = axes[1]
colors2 = plt.cm.YlOrRd(np.array(fiber_sizes_2) / max(fiber_sizes_2))
bars2 = ax.bar(range(len(shadow2)), fiber_sizes_2, color=colors2, edgecolor='black', linewidth=0.5)
ax.set_xticks(range(len(shadow2)))
ax.set_xticklabels(labels_2, rotation=45, ha='right', fontsize=8)
ax.set_ylabel('Fiber Size', fontsize=10)
ax.set_title(f'Degree-3 Simplex (3 vars)\n|Shadow|={len(shadow2)}', fontsize=11, fontweight='bold')
ax.set_ylim(0, max(fiber_sizes_2) + 1)

for bar, sz in zip(bars2, fiber_sizes_2):
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
            str(sz), ha='center', va='bottom', fontsize=8)

# ─── Panel 3: Partial M-convex subset ───
S3 = {(2,2,0), (2,1,1), (2,0,2), (1,2,1), (1,1,2), (0,2,2)}
shadow3 = sorted(degree_shadow(S3, 2))

fiber_sizes_3 = [len(quadratic_leaf_fiber(S3, a)) for a in shadow3]
labels_3 = [str(a) for a in shadow3]

ax = axes[2]
colors3 = plt.cm.YlOrRd(np.array(fiber_sizes_3) / max(fiber_sizes_3))
bars3 = ax.bar(range(len(shadow3)), fiber_sizes_3, color=colors3, edgecolor='black', linewidth=0.5)
ax.set_xticks(range(len(shadow3)))
ax.set_xticklabels(labels_3, rotation=45, ha='right', fontsize=8)
ax.set_ylabel('Fiber Size', fontsize=10)
ax.set_title(f'Partial M-convex (deg 4)\n|Shadow|={len(shadow3)}', fontsize=11, fontweight='bold')
ax.set_ylim(0, max(fiber_sizes_3) + 1)

for bar, sz in zip(bars3, fiber_sizes_3):
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
            str(sz), ha='center', va='bottom', fontsize=8)

fig.suptitle('M-Convex Shadow Compression: Fiber Size Distribution',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")
