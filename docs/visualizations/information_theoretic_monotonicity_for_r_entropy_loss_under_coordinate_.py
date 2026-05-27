#!/usr/bin/env python3
"""
Visualization: Entropy Loss Under Coordinate Deletion

Shows the entropy drop H(μ) - H(delete_k(μ)) for various uniform matroid
distributions, compared against the proved upper bound of log 2.
Demonstrates the data processing inequality and how Lorentzian negativity
keeps entropy loss well below the theoretical maximum.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def make_matroid(n, r):
    subs = [frozenset(c) for c in combinations(range(n), r)]
    w = 1.0 / len(subs)
    weights = {}
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        weights[s] = w if s in set(subs) else 0.0
    return weights


def entropy(weights):
    return -sum(w * log(w) for w in weights.values() if w > 0)


def delete_coord(n, weights, k):
    new_w = {}
    for s, w in weights.items():
        s2 = frozenset(x if x < k else x-1 for x in s if x != k)
        new_w[s2] = new_w.get(s2, 0.0) + w
    return new_w


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

# Panel 1: Entropy drops for various matroids
configs = []
for n in range(4, 11):
    for r in range(1, n):
        if comb(n, r) <= 5000:  # Avoid huge computations
            configs.append((n, r))

entropy_drops = []
labels = []
ns = []

for n, r in configs:
    w = make_matroid(n, r)
    H = entropy(w)
    drops = []
    for k in range(n):
        w_del = delete_coord(n, w, k)
        H_del = entropy(w_del)
        drops.append(H - H_del)
    max_drop = max(drops)
    entropy_drops.append(max_drop)
    labels.append(f"U({n},{r})")
    ns.append(n)

# Color by n
colors = plt.cm.viridis(np.linspace(0, 1, max(ns) - min(ns) + 1))
bar_colors = [colors[n - min(ns)] for n in ns]

x_pos = range(len(entropy_drops))
ax1.bar(x_pos, entropy_drops, color=bar_colors, alpha=0.8, edgecolor='black', linewidth=0.5)
ax1.axhline(y=log(2), color='red', linestyle='--', linewidth=2, label=f'Bound: log 2 ≈ {log(2):.3f}')
ax1.set_xticks(x_pos)
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
ax1.set_ylabel('Max Entropy Drop (nats)')
ax1.set_title('Entropy Drop Under Coordinate Deletion', fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(0, log(2) * 1.2)

# Panel 2: Entropy drop vs rank ratio r/n
ratios = []
drops_norm = []
for (n, r), d in zip(configs, entropy_drops):
    ratios.append(r / n)
    drops_norm.append(d / log(2))

ax2.scatter(ratios, drops_norm, c=[n for n, r in configs], cmap='viridis',
            s=40, edgecolors='black', linewidth=0.5, alpha=0.8)
ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Bound: 1.0')
ax2.set_xlabel('Rank ratio r/n')
ax2.set_ylabel('Entropy drop / log 2')
ax2.set_title('Normalized Entropy Drop vs Rank Ratio', fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(0, 1.3)
cbar = plt.colorbar(ax2.collections[0], ax=ax2, label='n')

fig.suptitle('Entropy Monotonicity: Deletion Cannot Destroy Too Much Information',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved entropy_deletion.png")
