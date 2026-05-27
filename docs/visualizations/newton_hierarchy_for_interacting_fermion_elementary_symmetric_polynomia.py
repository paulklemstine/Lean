#!/usr/bin/env python3
"""
Visualization: Lipschitz Stability of Elementary Symmetric Polynomials

Shows how the difference |e_k(p) - e_k(q)| scales with the sup-norm
distance ε = max_i |p_i - q_i|, confirming the Lipschitz bound from
the formal theorem esymm_lipschitz_supnorm.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

# ─── Inlined core functions ───

def esymm_dp(spectrum, max_k):
    n = len(spectrum)
    K = min(max_k, n)
    e = [0.0] * (K + 1)
    e[0] = 1.0
    for x in spectrum:
        for j in range(min(K, n), 0, -1):
            e[j] += x * e[j - 1]
    return e + [0.0] * max(0, max_k - K)

# ─── Parameters ───

n = 6
p = np.array([0.9, 0.7, 0.5, 0.3, 0.2, 0.1])
B = 1.0

epsilons = np.logspace(-4, -0.5, 40)
max_k = n

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: |e_k(p) - e_k(q)| vs epsilon for each k
ax = axes[0]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, max_k))

np.random.seed(42)
for k in range(1, max_k + 1):
    diffs = []
    for eps in epsilons:
        # Multiple random perturbations, take max
        max_diff = 0
        for _ in range(20):
            delta = np.random.uniform(-eps, eps, n)
            q = np.clip(p + delta, 0, 1)
            e_p = esymm_dp(list(p), k)
            e_q = esymm_dp(list(q), k)
            max_diff = max(max_diff, abs(e_p[k] - e_q[k]))
        diffs.append(max(max_diff, 1e-16))

    ax.loglog(epsilons, diffs, '-', color=colors[k-1],
              linewidth=2, label=f'k = {k}')

ax.loglog(epsilons, epsilons, '--', color='gray', linewidth=1,
          alpha=0.7, label='slope = 1')
ax.set_xlabel('Perturbation ε', fontsize=13)
ax.set_ylabel('|e_k(p) − e_k(q)|', fontsize=13)
ax.set_title('Esymm Lipschitz Stability\n(confirms |Δe_k| ≤ C·ε)', fontsize=14)
ax.legend(fontsize=9, loc='lower right')
ax.grid(True, alpha=0.3)

# Right: Effective Lipschitz constants vs k
ax2 = axes[1]
eps_test = 0.01
eff_constants = []
theoretical_constants = []
ks = list(range(1, max_k + 1))

for k in ks:
    max_ratio = 0
    for _ in range(100):
        delta = np.random.uniform(-eps_test, eps_test, n)
        q = np.clip(p + delta, 0, 1)
        actual_eps = max(abs(pi - qi) for pi, qi in zip(p, q))
        if actual_eps > 1e-10:
            e_p = esymm_dp(list(p), k)
            e_q = esymm_dp(list(q), k)
            ratio = abs(e_p[k] - e_q[k]) / actual_eps
            max_ratio = max(max_ratio, ratio)
    eff_constants.append(max_ratio)

    from math import comb
    theoretical_constants.append(comb(n, k) * k * B ** max(k - 1, 0))

ax2.bar(np.array(ks) - 0.15, eff_constants, width=0.3, color='steelblue',
        label='Empirical C_k', alpha=0.8)
ax2.bar(np.array(ks) + 0.15, theoretical_constants, width=0.3, color='coral',
        label='Theoretical C_k', alpha=0.8)
ax2.set_xlabel('Level k', fontsize=13)
ax2.set_ylabel('Lipschitz Constant C_k', fontsize=13)
ax2.set_title(f'Effective vs. Theoretical Lipschitz Constants\n(n={n}, B={B}, ε={eps_test})',
              fontsize=14)
ax2.legend(fontsize=11)
ax2.set_xticks(ks)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('esymm_lipschitz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved esymm_lipschitz.png")
