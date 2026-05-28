"""
Visualization 3: Deficit Landscape — All Permutations

For a small matrix (n=4), plot the deficit of every permutation,
colored by cycle structure. Shows that under diagonal dominance,
transpositions (2-cycles) are always the closest competitors to
the identity, while longer cycles have larger deficits.

Self-contained — all functions inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def perm_weight(W, sigma):
    return sum(W[i, sigma[i]] for i in range(len(sigma)))


def id_weight(W):
    return float(np.trace(W))


def is_identity(sigma):
    return all(sigma[i] == i for i in range(len(sigma)))


def cycle_structure(sigma):
    n = len(sigma)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if visited[i] or sigma[i] == i:
            visited[i] = True
            continue
        cycle = []
        j = i
        while not visited[j]:
            visited[j] = True
            cycle.append(j)
            j = sigma[j]
        if len(cycle) > 1:
            cycles.append(cycle)
    return cycles


def classify_permutation(sigma):
    if is_identity(sigma):
        return "identity"
    cycles = cycle_structure(sigma)
    lengths = sorted([len(c) for c in cycles], reverse=True)
    return tuple(lengths)


# Generate a symmetric diagonally dominant matrix
np.random.seed(42)
n = 4
G = np.random.randn(n, n)
W = (G + G.T) / 2 + 5 * np.eye(n)

# Compute deficit for every non-identity permutation
perms_data = []
for perm in permutations(range(n)):
    perm = list(perm)
    if is_identity(perm):
        continue
    w = perm_weight(W, perm)
    deficit = id_weight(W) - w
    ctype = classify_permutation(perm)
    perms_data.append((perm, w, deficit, ctype))

# Sort by deficit
perms_data.sort(key=lambda x: x[2])

# Color mapping for cycle types
type_colors = {
    (2,): '#2196F3',      # Transpositions: blue
    (2, 2): '#4CAF50',    # Double transpositions: green
    (3,): '#FF9800',      # 3-cycles: orange
    (4,): '#F44336',      # 4-cycles: red
    (3, 1): '#FF9800',    # not possible for n=4 non-trivially
}
type_labels = {
    (2,): 'Transposition (2-cycle)',
    (2, 2): 'Double transposition',
    (3,): '3-cycle',
    (4,): '4-cycle',
}

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 9), height_ratios=[2, 1])

# Top: bar chart of deficits
x_pos = range(len(perms_data))
colors = [type_colors.get(d[3], '#9E9E9E') for d in perms_data]
bars = ax1.bar(x_pos, [d[2] for d in perms_data], color=colors, edgecolor='white',
               linewidth=0.5)

ax1.set_xlabel('Permutation (sorted by deficit)', fontsize=11)
ax1.set_ylabel('Deficit = idWeight − permWeight(σ)', fontsize=11)
ax1.set_title(f'Deficit Landscape: All {len(perms_data)} Non-Identity '
              f'Permutations of {{0,1,2,3}}',
              fontsize=13, fontweight='bold')
ax1.axhline(y=0, color='black', linewidth=0.5)

# Legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=type_colors[k], label=type_labels[k])
                   for k in sorted(type_labels.keys())]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=10)

# Add annotation: minimum deficit is a transposition
min_deficit = perms_data[0][2]
min_type = perms_data[0][3]
ax1.annotate(f'Min deficit = {min_deficit:.2f}\nType: {type_labels.get(min_type, str(min_type))}',
            xy=(0, min_deficit), xytext=(5, min_deficit * 1.5),
            fontsize=10, fontweight='bold', color='blue',
            arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))

# Bottom: symmetric deficit identity verification
# 2*(id - perm) = ∑ pairDeficit(i, σ(i))
ax2.set_title('Symmetric Deficit Identity: 2·deficit = Σᵢ d(i, σ(i))',
              fontsize=13, fontweight='bold')

pair_deficits_sum = []
two_times_deficit = []
for perm, w, deficit, ctype in perms_data:
    pd_sum = sum(W[i, i] + W[perm[i], perm[i]] - 2 * W[i, perm[i]] for i in range(n))
    pair_deficits_sum.append(pd_sum)
    two_times_deficit.append(2 * deficit)

ax2.scatter(two_times_deficit, pair_deficits_sum, c=colors, s=40,
            edgecolors='black', linewidths=0.5, zorder=5)

# Perfect agreement line
lims = [min(min(two_times_deficit), min(pair_deficits_sum)) - 0.5,
        max(max(two_times_deficit), max(pair_deficits_sum)) + 0.5]
ax2.plot(lims, lims, 'k--', linewidth=1, alpha=0.5, label='Perfect agreement')

ax2.set_xlabel('2 × (idWeight − permWeight(σ))', fontsize=11)
ax2.set_ylabel('Σᵢ pairDeficit(i, σ(i))', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

max_err = max(abs(a - b) for a, b in zip(two_times_deficit, pair_deficits_sum))
ax2.text(0.02, 0.95, f'Max error: {max_err:.2e}',
         transform=ax2.transAxes, fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_deficit_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
