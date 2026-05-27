#!/usr/bin/env python3
"""
Visualization 2: Entropy Under Coordinate Deletion

Visualizes how entropy changes when coordinates are deleted from
robustly Lorentzian measures. Shows that entropy loss is bounded
and tracks log(1/ε), confirming the projection stability principle.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def uniform_matroid_weights(n, r):
    total = comb(n, r)
    return {frozenset(s): 1.0/total for s in combinations(range(n), r)}


def perturbed_matroid_weights(n, r, eps):
    weights = {}
    for s in combinations(range(n), r):
        fs = frozenset(s)
        weights[fs] = 1.0 + eps * (1.0 if 0 in s else 0.0)
    total = sum(weights.values())
    return {s: w/total for s, w in weights.items()}


def entropy(weights):
    return -sum(w * log(w) for w in weights.values() if w > 0)


def delete_coord(n, weights, k):
    new_w = {}
    for s, w in weights.items():
        ns = frozenset(i if i < k else i-1 for i in s if i != k)
        new_w[ns] = new_w.get(ns, 0.0) + w
    return new_w


def coord_prob(weights, i):
    return sum(w for s, w in weights.items() if i in s)


def coord_cov(weights, i, j):
    pij = sum(w for s, w in weights.items() if i in s and j in s)
    return pij - coord_prob(weights, i) * coord_prob(weights, j)


def robustness_gap(n, weights):
    max_ratio = 0.0
    for i in range(n):
        pi = coord_prob(weights, i)
        for j in range(i+1, n):
            pj = coord_prob(weights, j)
            if pi > 0 and pj > 0:
                ratio = abs(coord_cov(weights, i, j)) / (pi * pj)
                max_ratio = max(max_ratio, ratio)
    return max_ratio


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Entropy Stability Under Coordinate Deletion',
             fontsize=14, fontweight='bold')

# Plot 1: Entropy drops for different matroids
ax1 = axes[0]
for n, r, color in [(4, 2, 'blue'), (5, 2, 'green'), (6, 3, 'red'), (7, 3, 'purple')]:
    w = uniform_matroid_weights(n, r)
    H = entropy(w)
    drops = [H - entropy(delete_coord(n, w, k)) for k in range(n)]
    ax1.bar(np.arange(n) + 0.15*(n-4), drops, width=0.15,
            label=f'U({n},{r})', color=color, alpha=0.7)
ax1.set_xlabel('Deleted coordinate k')
ax1.set_ylabel('Entropy drop H(μ) - H(π_k μ)')
ax1.set_title('Entropy drop per coordinate')
ax1.legend(fontsize=9)
ax1.set_ylim(bottom=0)

# Plot 2: Entropy drop vs perturbation strength
ax2 = axes[1]
n, r = 6, 3
eps_values = np.linspace(0.01, 3.0, 30)
max_drops = []
gaps = []
for eps in eps_values:
    w = perturbed_matroid_weights(n, r, eps)
    H = entropy(w)
    max_drop = max(H - entropy(delete_coord(n, w, k)) for k in range(n))
    gap = robustness_gap(n, w)
    max_drops.append(max_drop)
    gaps.append(gap)

ax2.plot(eps_values, max_drops, 'b-', linewidth=2, label='Max entropy drop')
ax2.plot(eps_values, [log(1/g) if g > 0 else 0 for g in gaps],
         'r--', linewidth=1.5, label='log(1/ε)')
ax2.set_xlabel('Perturbation strength')
ax2.set_ylabel('Entropy drop / bound')
ax2.set_title(f'Entropy drop vs log(1/ε)\nPerturbed U({n},{r})')
ax2.legend()

# Plot 3: Gap vs perturbation
ax3 = axes[2]
ax3.plot(eps_values, gaps, 'g-', linewidth=2, label='Robustness gap ε')
ax3.set_xlabel('Perturbation strength')
ax3.set_ylabel('Gap ε')
ax3.set_title('Robustness gap under perturbation')
ax3.legend()

plt.tight_layout()
plt.savefig('viz_entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_deletion.png")
