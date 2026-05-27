"""
Visualization 2: Entropy Loss Under Coordinate Deletion

Shows how entropy changes when coordinates are deleted from uniform matroid
distributions. The proved bound H(π_k μ) ≥ H(μ) - log(2) is displayed as
a horizontal line. The gap between actual drop and bound reveals how tight
the certified inequality is.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def shannon_entropy(weights):
    return -sum(w * log(w) for w in weights if w > 0)


def matroid_deletion_profile(n, k):
    subsets = [frozenset(s) for s in combinations(range(n), k)]
    w = 1.0 / len(subsets)
    H_orig = log(len(subsets))
    drops = []
    for coord in range(n):
        proj = {}
        for s in subsets:
            s2 = frozenset(x for x in s if x != coord)
            proj[s2] = proj.get(s2, 0) + w
        H_del = shannon_entropy(list(proj.values()))
        drops.append(H_orig - H_del)
    return H_orig, drops


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Entropy Loss Under Coordinate Deletion', fontsize=14, fontweight='bold')

for idx, n in enumerate([5, 6, 7]):
    ax = axes[idx]
    x_vals = []
    drop_vals = []
    colors = []
    labels_set = set()

    for k in range(1, n):
        H, drops = matroid_deletion_profile(n, k)
        for c, d in enumerate(drops):
            x_vals.append(k)
            drop_vals.append(d)

    # Plot as scatter
    ax.scatter(x_vals, drop_vals, alpha=0.6, s=30, c='steelblue', label='Actual drop')
    ax.axhline(y=log(2), color='red', linestyle='--', linewidth=2, label=f'log(2) = {log(2):.3f}')
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

    ax.set_xlabel(f'Rank k (n={n})')
    ax.set_ylabel('Entropy drop H(μ) − H(π_k μ)')
    ax.set_title(f'n = {n}')
    ax.legend(fontsize=8)
    ax.set_ylim(-0.1, log(2) + 0.2)

plt.tight_layout()
plt.savefig('viz_entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_deletion.png")
