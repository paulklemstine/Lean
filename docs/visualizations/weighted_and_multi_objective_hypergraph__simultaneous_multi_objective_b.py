#!/usr/bin/env python3
"""
Visualization 3: Simultaneous Multi-Objective Bound

Visualizes the key result that ONE threshold-rounded set simultaneously
approximates ALL objectives within factor d_max. Shows gap ratios across
multiple objectives for many random instances.
"""

import numpy as np
from scipy.optimize import linprog
import matplotlib.pyplot as plt


def random_hypergraph(n, m, seed):
    rng = np.random.default_rng(seed)
    edges = set()
    for _ in range(m):
        k = rng.choice([2, 3, 4])
        e = tuple(sorted(rng.choice(n, size=min(k, n), replace=False)))
        edges.add(e)
    return list(edges)


n = 20
k_objectives = 5
num_trials = 200

all_gaps = {i: [] for i in range(k_objectives)}
trial_d_max = []

for trial in range(num_trials):
    seed = 5555 + trial
    rng = np.random.default_rng(seed)
    m = rng.integers(8, 25)
    edges = random_hypergraph(n, m, seed)
    if not edges:
        continue
    d = max(len(e) for e in edges)

    costs = [rng.uniform(0.5, 8.0, size=n) for _ in range(k_objectives)]
    w_avg = sum(costs) / k_objectives

    A_ub = [[-1.0 if v in e else 0.0 for v in range(n)] for e in edges]
    b_ub = [-1.0] * len(edges)
    res = linprog(w_avg, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    if not res.success:
        continue

    x = res.x
    S = np.where(x >= 1.0/d - 1e-12)[0]
    ind = np.zeros(n); ind[S] = 1.0

    trial_d_max.append(d)
    for i, c in enumerate(costs):
        frac_cost = np.dot(c, x)
        int_cost = np.dot(c, ind)
        if frac_cost > 1e-10:
            all_gaps[i].append(int_cost / frac_cost)
        else:
            all_gaps[i].append(0.0)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes_flat = axes.flatten()

# Plot distribution for each objective
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']
for i in range(k_objectives):
    ax = axes_flat[i]
    gaps = all_gaps[i]
    ax.hist(gaps, bins=30, color=colors[i], alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.axvline(x=4.0, color='red', linestyle='--', linewidth=2,
               label=f'd_max bound (≤ {max(trial_d_max)})')
    ax.set_xlabel('Gap ratio (int cost / frac cost)', fontsize=11)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title(f'Objective {i+1}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

# Summary plot: max gap across objectives per trial
ax = axes_flat[5]
max_gaps = [max(all_gaps[i][t] for i in range(k_objectives)) for t in range(len(all_gaps[0]))]
ax.hist(max_gaps, bins=30, color='#607D8B', alpha=0.7, edgecolor='black', linewidth=0.5)
ax.axvline(x=4.0, color='red', linestyle='--', linewidth=2, label='d_max bound')
ax.set_xlabel('Max gap across all objectives', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Worst-Case Simultaneous Gap', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle(
    f'Simultaneous Multi-Objective Bound: {k_objectives} Objectives, {num_trials} Trials\n'
    f'ONE rounded set controls ALL objectives within factor d_max',
    fontsize=15, y=1.02
)
plt.tight_layout()
plt.savefig('viz_simultaneous_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_simultaneous_bound.png")
