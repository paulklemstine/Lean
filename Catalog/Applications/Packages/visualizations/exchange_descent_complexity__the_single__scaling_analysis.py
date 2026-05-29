#!/usr/bin/env python3
"""
Visualization: Descent Complexity Scaling Analysis

Visualizes how worst-case descent length (WDL) compares to the theoretical
bounds d^(d-k) and d^(d-k-1) for different exchange family constructions.

Three panels:
1. WDL vs d for linear families (log scale)
2. Normalized ratios WDL/d^(d-k) for different k values
3. Product amplification: WDL(F×G) vs WDL(F) + WDL(G)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

# ─── Inline: Exchange family classes ───

class ExchangeFamily:
    def __init__(self, states, measure, step_fn, name=""):
        self.states = list(states)
        self.measure = measure
        self.step_fn = step_fn
        self.name = name
        self._cache = {}
    
    def successors(self, x):
        return [y for y in self.states if self.step_fn(x, y)]
    
    def max_descent_from(self, x):
        if x in self._cache:
            return self._cache[x]
        succs = self.successors(x)
        result = 0 if not succs else 1 + max(self.max_descent_from(y) for y in succs)
        self._cache[x] = result
        return result
    
    def worst_descent_length(self):
        return max(self.max_descent_from(x) for x in self.states) if self.states else 0

def linear_family(d):
    states = list(range(d + 1))
    return ExchangeFamily(states, {i: i for i in states},
                          lambda x, y: y < x, f"Linear(d={d})")

def chain_family(d):
    states = list(range(d + 1))
    return ExchangeFamily(states, {i: i for i in states},
                          lambda x, y: y == x - 1, f"Chain(d={d})")

def product_family(F, G):
    states = [(x, y) for x in F.states for y in G.states]
    measure = {(x, y): F.measure[x] + G.measure[y] for (x, y) in states}
    def step_fn(p, q):
        return (F.step_fn(p[0], q[0]) and p[1] == q[1]) or \
               (p[0] == q[0] and G.step_fn(p[1], q[1]))
    return ExchangeFamily(states, measure, step_fn, f"({F.name}×{G.name})")

# ─── Data collection ───

ds = list(range(2, 16))

# Panel 1: WDL comparison
wdl_linear = [linear_family(d).worst_descent_length() for d in ds]
wdl_chain = [chain_family(d).worst_descent_length() for d in ds]
d_pow_d = [d ** d for d in ds]
d_pow_d1 = [d ** max(0, d - 1) for d in ds]

# Panel 2: Normalized ratios for k = 0, 1, 2
ratios = {}
for k in [0, 1, 2]:
    ratios[k] = []
    for d in ds:
        wdl = d  # Linear family WDL = d
        denom = d ** max(0, d - k)
        ratios[k].append(wdl / denom if denom > 0 else 0)

# Panel 3: Product amplification
prod_data = []
for d1 in range(2, 7):
    for d2 in range(d1, 7):
        F = linear_family(d1)
        G = linear_family(d2)
        P = product_family(F, G)
        wf = F.worst_descent_length()
        wg = G.worst_descent_length()
        wp = P.worst_descent_length()
        prod_data.append((wf + wg, wp))

# ─── Plotting ───

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Exchange Descent Complexity: Scaling Analysis',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1
ax = axes[0]
ax.semilogy(ds, d_pow_d, 'r--', linewidth=2, label='$d^d$ (upper bound, k=0)')
ax.semilogy(ds, d_pow_d1, 'b--', linewidth=2, label='$d^{d-1}$ (lower bound?)')
ax.semilogy(ds, wdl_linear, 'ko-', linewidth=2, markersize=6,
            label='WDL (linear family)')
ax.semilogy(ds, wdl_chain, 'g^-', linewidth=1.5, markersize=5,
            label='WDL (chain family)')
ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Descent Length (log scale)', fontsize=12)
ax.set_title('Worst-Case Descent vs Bounds', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 2
ax = axes[1]
colors = ['#e41a1c', '#377eb8', '#4daf4a']
for k, color in zip([0, 1, 2], colors):
    ax.plot(ds, ratios[k], 'o-', color=color, linewidth=2,
            markersize=5, label=f'WDL / $d^{{d-{k}}}$  (k={k})')
ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Normalized Ratio', fontsize=12)
ax.set_title('Normalized Descent (→ 0 = gap exists)', fontsize=12)
ax.set_yscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3
ax = axes[2]
sums = [p[0] for p in prod_data]
prods = [p[1] for p in prod_data]
max_val = max(max(sums), max(prods))
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='Equality line')
ax.scatter(sums, prods, c='#e41a1c', s=60, zorder=5,
           label='(WDL(F)+WDL(G), WDL(F×G))')
ax.set_xlabel('WDL(F) + WDL(G)', fontsize=12)
ax.set_ylabel('WDL(F × G)', fontsize=12)
ax.set_title('Product Amplification Theorem', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
