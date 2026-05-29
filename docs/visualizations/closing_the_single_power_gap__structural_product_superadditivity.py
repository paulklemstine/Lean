#!/usr/bin/env python3
"""
Visualization 3: Product Superadditivity and Path Count Convolution

Left panel: Demonstrates that worst-case descent lengths are superadditive
under the product construction (the tensorization lower bound).

Right panel: Shows descending path counts for individual families and their
product, illustrating the convolution bound from statistical mechanics.

This visualization connects exchange complexity to hardness amplification
and partition function theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math
from collections import defaultdict

# ─── Inline Implementation ───
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

def linear_chain(d):
    states = list(range(d + 1))
    measure = {s: s for s in states}
    edges = {(i, i - 1) for i in range(1, d + 1)}
    return ExchangeFamily(d, states, measure, edges)

def product_family(F, G):
    n_g = len(G.states)
    g_idx = {s: i for i, s in enumerate(G.states)}
    f_idx = {s: i for i, s in enumerate(F.states)}
    states, measure, edges = [], {}, set()
    for sf in F.states:
        for sg in G.states:
            pair = f_idx[sf] * n_g + g_idx[sg]
            states.append(pair)
            measure[pair] = F.measure[sf] + G.measure[sg]
    for sf in F.states:
        for tf in F.adj[sf]:
            for sg in G.states:
                u = f_idx[sf] * n_g + g_idx[sg]
                v = f_idx[tf] * n_g + g_idx[sg]
                edges.add((u, v))
    for sg in G.states:
        for tg in G.adj[sg]:
            for sf in F.states:
                u = f_idx[sf] * n_g + g_idx[sg]
                v = f_idx[sf] * n_g + g_idx[tg]
                edges.add((u, v))
    return ExchangeFamily(F.dim + G.dim, states, measure, edges)

def count_paths(F, n):
    current = {s: 1 for s in F.states}
    if n == 0: return sum(current.values())
    for _ in range(n):
        nxt = defaultdict(int)
        for s in F.states:
            if current.get(s, 0) > 0:
                for t in F.adj[s]:
                    nxt[t] += current[s]
        current = dict(nxt)
    return sum(current.values())

# ─── Left Panel: Superadditivity ───
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

dims = list(range(2, 8))
worst_F = []
worst_G = []
worst_P = []
sums = []

for d in dims:
    F = linear_chain(d)
    G = linear_chain(d)
    P = product_family(F, G)
    wf = compute_longest_chain(F)
    wg = compute_longest_chain(G)
    wp = compute_longest_chain(P)
    worst_F.append(wf)
    worst_G.append(wg)
    worst_P.append(wp)
    sums.append(wf + wg)

x = range(len(dims))
width = 0.35
bars1 = ax1.bar([i - width/2 for i in x], sums, width, label='F + G (sum)',
                color='#3498db', alpha=0.8)
bars2 = ax1.bar([i + width/2 for i in x], worst_P, width, label='F × G (product)',
                color='#e74c3c', alpha=0.8)

ax1.set_xlabel('Dimension d (each factor)', fontsize=13)
ax1.set_ylabel('Worst-case descent length', fontsize=13)
ax1.set_title('Product Superadditivity\nwdl(F×G) ≥ wdl(F) + wdl(G)', fontsize=14)
ax1.set_xticks(list(x))
ax1.set_xticklabels([str(d) for d in dims])
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3, axis='y')

# ─── Right Panel: Path Count Convolution ───
d = 4
F = linear_chain(d)
G = linear_chain(d)
P = product_family(F, G)

max_n = 2 * d + 2
ns = list(range(max_n))
counts_f = [count_paths(F, n) for n in ns]
counts_g = [count_paths(G, n) for n in ns]
counts_p = [count_paths(P, n) for n in ns]
convolution = []
for n in ns:
    conv = sum(counts_f[i] * counts_g[n - i]
               for i in range(n + 1)
               if n - i < len(counts_g))
    convolution.append(conv)

ax2.plot(ns, counts_p, 'o-', color='#e74c3c', linewidth=2, markersize=6,
         label='Z_product(n)')
ax2.plot(ns, convolution, 's--', color='#3498db', linewidth=2, markersize=6,
         label='(Z_F * Z_G)(n) [convolution]')

ax2.set_xlabel('Path length n', fontsize=13)
ax2.set_ylabel('Number of paths', fontsize=13)
ax2.set_title(f'Path Count Convolution (d={d})\nPartition function decomposition', fontsize=14)
ax2.legend(fontsize=12)
ax2.grid(True, alpha=0.3)
if max(counts_p + convolution) > 100:
    ax2.set_yscale('log')

fig.suptitle('Hardness Amplification via Product Families', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('viz_product_superadditivity.png', dpi=150, bbox_inches='tight')
print("Saved viz_product_superadditivity.png")
