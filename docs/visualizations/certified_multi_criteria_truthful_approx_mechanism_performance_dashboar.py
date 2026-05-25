#!/usr/bin/env python3
"""
Visualization: Multi-Criteria Truthful Mechanism Performance.

Produces three plots:
1. Approximation ratios across objectives and instances
2. Payment vs. true cost scatter (showing truthfulness margin)
3. Pareto frontier visualization for bi-objective case
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import math


def solve_fractional(n, edges, costs):
    x = [0.0] * n
    for _ in range(50):
        for edge in edges:
            cov = sum(x[v] for v in edge)
            if cov >= 1.0 - 1e-10:
                continue
            deficit = 1.0 - cov
            ic = [1.0 / max(costs[v], 1e-10) for v in edge]
            t = sum(ic)
            for j, v in enumerate(edge):
                x[v] = min(1.0, x[v] + deficit * ic[j] / t)
    return x


def threshold_round(x, tau):
    return {v for v in range(len(x)) if x[v] >= tau}


def critical_payment(n, edges, bids, tau, v):
    lo, hi = bids[v], max(bids) * 10 + 20.0
    for _ in range(25):
        mid = (lo + hi) / 2
        mb = bids[:]
        mb[v] = mid
        x = solve_fractional(n, edges, mb)
        if x[v] >= tau:
            lo = mid
        else:
            hi = mid
    return lo


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# ── Plot 1: Approximation ratios heatmap ──
rng = random.Random(42)
n_instances = 8
obj_names = ["Cost", "Fairness", "Equity", "Welfare"]
ratio_matrix = []

for i in range(n_instances):
    n = rng.randint(5, 8)
    n_e = rng.randint(3, 6)
    max_r = min(rng.randint(2, 3), n)
    edges = []
    for _ in range(n_e):
        sz = rng.randint(2, max_r)
        edges.append(sorted(rng.sample(range(n), min(sz, n))))
    rank = max(len(e) for e in edges)
    tau = 1.0 / rank
    costs = [rng.uniform(0.5, 5) for _ in range(n)]
    objs = [[rng.uniform(0, 1) for _ in range(n)] for _ in range(4)]

    x = solve_fractional(n, edges, costs)
    selected = threshold_round(x, tau)

    row = []
    for w in objs:
        ic = sum(w[v] for v in selected) if selected else 0
        fc = sum(w[v] * x[v] for v in range(n))
        row.append(ic / max(fc, 1e-10))
    ratio_matrix.append(row)

im = axes[0].imshow(ratio_matrix, aspect='auto', cmap='YlOrRd', vmin=0.5, vmax=3.0)
axes[0].set_xticks(range(4))
axes[0].set_xticklabels(obj_names, fontsize=9)
axes[0].set_ylabel("Instance", fontsize=11)
axes[0].set_title("Approximation Ratios\n(all ≤ rank bound)", fontsize=12, fontweight='bold')
plt.colorbar(im, ax=axes[0], label="Ratio")

# ── Plot 2: Payment vs true cost ──
all_costs = []
all_payments = []
n = 6
edges = [[0,1,2], [1,3,4], [2,4,5], [0,3,5]]
rank = 3
tau = 1.0 / rank

for trial in range(15):
    rng2 = random.Random(200 + trial)
    costs = [rng2.uniform(1, 8) for _ in range(n)]
    x = solve_fractional(n, edges, costs)
    selected = threshold_round(x, tau)
    for v in selected:
        p = critical_payment(n, edges, costs, tau, v)
        all_costs.append(costs[v])
        all_payments.append(p)

max_val = max(max(all_costs), max(all_payments)) * 1.1
axes[1].scatter(all_costs, all_payments, c='steelblue', alpha=0.7, s=50, edgecolors='navy')
axes[1].plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='Payment = Cost')
axes[1].set_xlabel("True Cost", fontsize=11)
axes[1].set_ylabel("Critical Payment", fontsize=11)
axes[1].set_title("Payment ≥ Cost\n(truthfulness margin)", fontsize=12, fontweight='bold')
axes[1].legend(fontsize=9)
axes[1].set_xlim(0, max_val)
axes[1].set_ylim(0, max_val)

# ── Plot 3: Bi-objective Pareto frontier ──
n = 5
edges = [[0,1], [1,2,3], [2,4], [0,3,4]]
rank = 3
tau = 1.0 / rank
w1 = [1.0, 0.5, 2.0, 1.5, 0.8]
w2 = [0.5, 2.0, 0.8, 1.0, 1.5]

# Generate many feasible solutions by varying costs
pareto_x = []
pareto_y = []
mech_x = []
mech_y = []

for trial in range(40):
    rng3 = random.Random(300 + trial)
    costs = [rng3.uniform(0.5, 5) for _ in range(n)]
    x = solve_fractional(n, edges, costs)
    sel = threshold_round(x, tau)
    c1 = sum(w1[v] for v in sel)
    c2 = sum(w2[v] for v in sel)
    pareto_x.append(c1)
    pareto_y.append(c2)

# Mechanism output (single canonical)
costs = [2.0, 1.5, 3.0, 2.5, 1.0]
x = solve_fractional(n, edges, costs)
sel = threshold_round(x, tau)
mc1 = sum(w1[v] for v in sel)
mc2 = sum(w2[v] for v in sel)

# Fractional optimum
fc1 = sum(w1[v] * x[v] for v in range(n))
fc2 = sum(w2[v] * x[v] for v in range(n))

axes[2].scatter(pareto_x, pareto_y, c='lightgray', alpha=0.6, s=30, label='Feasible solutions')
axes[2].scatter([mc1], [mc2], c='red', s=150, zorder=5, marker='*', label='Mechanism output')
axes[2].scatter([fc1], [fc2], c='green', s=100, zorder=5, marker='D', label='LP relaxation')

# Draw approximation region
axes[2].axhline(y=mc2 / rank, color='orange', linestyle=':', alpha=0.5)
axes[2].axvline(x=mc1 / rank, color='orange', linestyle=':', alpha=0.5, label=f'1/{rank} · mechanism cost')

axes[2].set_xlabel("Objective 1 (cost)", fontsize=11)
axes[2].set_ylabel("Objective 2 (cost)", fontsize=11)
axes[2].set_title("Bi-Objective Space\n(Pareto certification)", fontsize=12, fontweight='bold')
axes[2].legend(fontsize=8, loc='upper right')

plt.tight_layout()
plt.savefig('/workspace/request-project/mechanism_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: mechanism_visualization.png")
