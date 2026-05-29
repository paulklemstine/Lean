"""
Visualization: Entropy Retention Under Coordinate Deletion
============================================================

Shows how deletion of coordinates affects entropy for uniform matroid
distributions, and compares the entropy drop against the log(1/ε) bound.

Demonstrates the projection stability theorem: robust Lorentzian
negativity prevents catastrophic entropy collapse under deletion.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log
from itertools import combinations


class FinsetLaw:
    def __init__(self, n, weights):
        self.n = n
        self.weights = weights
    
    @classmethod
    def uniform_matroid(cls, n, k):
        c = comb(n, k)
        return cls(n, {frozenset(s): 1.0/c for s in combinations(range(n), k)})


def total_entropy(mu):
    return -sum(w * log(w) for w in mu.weights.values() if w > 1e-30)

def coord_prob(mu, i):
    return sum(w for s, w in mu.weights.items() if i in s)

def coord_cov(mu, i, j):
    pij = sum(w for s, w in mu.weights.items() if i in s and j in s)
    return pij - coord_prob(mu, i) * coord_prob(mu, j)

def estimate_gap(mu):
    eps = 0.0
    for i in range(mu.n):
        for j in range(i+1, mu.n):
            pi, pj = coord_prob(mu, i), coord_prob(mu, j)
            if pi * pj > 1e-15:
                eps = max(eps, abs(coord_cov(mu, i, j)) / (pi * pj))
    return eps

def deletion_entropy(mu, k):
    new_w = {}
    for s, w in mu.weights.items():
        proj = frozenset(x for x in s if x != k)
        new_w[proj] = new_w.get(proj, 0.0) + w
    return -sum(w * log(w) for w in new_w.values() if w > 1e-30)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Entropy before and after deletion
ax = axes[0]
ns = list(range(4, 13))
entropies = []
del_entropies = []
drops = []

for n in ns:
    k = n // 2
    mu = FinsetLaw.uniform_matroid(n, k)
    ent = total_entropy(mu)
    del_ent = deletion_entropy(mu, 0)  # delete first coordinate (symmetric)
    entropies.append(ent)
    del_entropies.append(del_ent)
    drops.append(ent - del_ent)

ax.plot(ns, entropies, 'bo-', label='H(μ)', markersize=6)
ax.plot(ns, del_entropies, 'rs--', label='H(π₀μ)', markersize=6)
ax.fill_between(ns, del_entropies, entropies, alpha=0.2, color='orange', label='Entropy drop')
ax.set_xlabel('n')
ax.set_ylabel('Entropy (nats)')
ax.set_title('Entropy Before/After Deletion')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Entropy drop vs log(1/ε) bound
ax = axes[1]
log_bounds = []
for n in ns:
    k = n // 2
    mu = FinsetLaw.uniform_matroid(n, k)
    eps = estimate_gap(mu)
    log_bounds.append(log(1/eps) if eps > 0 else 10)

ax.plot(ns, drops, 'go-', label='Actual drop', markersize=6)
ax.plot(ns, log_bounds, 'r^--', label='log(1/ε)', markersize=6)
ax.set_xlabel('n')
ax.set_ylabel('Value (nats)')
ax.set_title('Entropy Drop vs log(1/ε) Bound')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Retention ratio and gap parameter
ax = axes[2]
ratios = [d / e * 100 if e > 0 else 100 for d, e in zip(del_entropies, entropies)]
epsilons = []
for n in ns:
    k = n // 2
    mu = FinsetLaw.uniform_matroid(n, k)
    epsilons.append(estimate_gap(mu))

ax2 = ax.twinx()
ax.plot(ns, ratios, 'b^-', label='Retention %', markersize=6)
ax2.plot(ns, epsilons, 'rs--', label='ε (gap)', markersize=5)
ax.set_xlabel('n')
ax.set_ylabel('Entropy Retention (%)', color='blue')
ax2.set_ylabel('ε (Lorentzian gap)', color='red')
ax.set_title('Entropy Retention & Robustness Gap')
ax.tick_params(axis='y', labelcolor='blue')
ax2.tick_params(axis='y', labelcolor='red')
ax.grid(True, alpha=0.3)

lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, loc='center right')

plt.suptitle('Projection Stability: Entropy Under Coordinate Deletion', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_deletion_entropy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_deletion_entropy.png")
