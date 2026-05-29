#!/usr/bin/env python3
"""
Visualization 1: Descent Complexity Ratios

Plots the normalized ratio T(d,k)/d^(d-k) and T(d,k)/d^(d-k-1) for
d = 4..15 and k ∈ {0, 1, 2}, visually testing the Single-Power Gap Conjecture.

If T(d,k)/d^(d-k) stabilizes away from 0, the upper bound exponent is sharp.
If it converges to 0, the true exponent is strictly less than d-k.

This visualization is the primary diagnostic for the conjecture.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math
from collections import defaultdict

# ─── Inline Exchange Family Implementation ───
class ExchangeFamily:
    def __init__(self, dim, states, measure, edges):
        self.dim = dim
        self.states = sorted(states)
        self.measure = measure
        self.adj = defaultdict(list)
        for (u, v) in edges:
            self.adj[u].append(v)

def compute_longest_chain(F):
    dp = {}
    def dfs(s):
        if s in dp: return dp[s]
        dp[s] = 0
        for t in F.adj[s]:
            dp[s] = max(dp[s], 1 + dfs(t))
        return dp[s]
    return max(dfs(s) for s in F.states) if F.states else 0

def adversarial_family(d, k=0):
    max_m = min(d ** max(1, d - k), d ** 4)
    states = list(range(max_m + 1))
    measure = {s: s for s in states}
    edges = set()
    for s in states:
        for delta in range(1, min(d + 1, s + 1)):
            edges.add((s, s - delta))
    return ExchangeFamily(d, states, measure, edges)

# ─── Compute Data ───
d_range = list(range(4, 16))
k_values = [0, 1, 2]
colors = {0: '#e74c3c', 1: '#3498db', 2: '#2ecc71'}
markers = {0: 'o', 1: 's', 2: '^'}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for k in k_values:
    ds, ratios_upper, ratios_lower = [], [], []
    for d in d_range:
        if d <= k + 1:
            continue
        F = adversarial_family(d, k)
        T = compute_longest_chain(F)
        exp_upper = d - k
        exp_lower = max(0, d - k - 1)
        d_upper = d ** exp_upper
        d_lower = d ** exp_lower if exp_lower > 0 else 1
        ds.append(d)
        ratios_upper.append(T / d_upper if d_upper > 0 else 0)
        ratios_lower.append(T / d_lower if d_lower > 0 else 0)

    axes[0].plot(ds, ratios_upper, color=colors[k], marker=markers[k],
                 label=f'k={k}', linewidth=2, markersize=8)
    axes[1].plot(ds, ratios_lower, color=colors[k], marker=markers[k],
                 label=f'k={k}', linewidth=2, markersize=8)

axes[0].set_xlabel('Dimension d', fontsize=13)
axes[0].set_ylabel('T(d,k) / d^(d-k)', fontsize=13)
axes[0].set_title('Upper Bound Ratio\n(Stabilization ≠ 0 ⟹ sharp exponent)', fontsize=14)
axes[0].set_yscale('log')
axes[0].legend(fontsize=12)
axes[0].grid(True, alpha=0.3)

axes[1].set_xlabel('Dimension d', fontsize=13)
axes[1].set_ylabel('T(d,k) / d^(d-k-1)', fontsize=13)
axes[1].set_title('Lower Bound Ratio\n(Growth ⟹ gap exists)', fontsize=14)
axes[1].set_yscale('log')
axes[1].legend(fontsize=12)
axes[1].grid(True, alpha=0.3)

fig.suptitle('Single-Power Gap Conjecture — Diagnostic Ratios', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('viz_descent_ratios.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_ratios.png")
