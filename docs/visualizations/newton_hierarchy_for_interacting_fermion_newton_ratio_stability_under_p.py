#!/usr/bin/env python3
"""
Visualization: Newton Ratio Stability Under Perturbation

Visualizes how Newton ratio profiles change under increasing perturbation
strength, demonstrating the Lipschitz stability theorem. The plot shows
deviation vs. coupling strength U on a log-log scale, confirming the
predicted linear scaling.
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

def nr(spectrum, k, ev=None):
    if ev is None:
        ev = esymm_dp(spectrum, k + 1)
    if k - 1 < 0 or k + 1 >= len(ev):
        return 0.0
    d = ev[k - 1] * ev[k + 1]
    return ev[k] ** 2 / d if abs(d) > 1e-30 else 0.0

# ─── Parameters ───

n = 8
K = 5
free_spec = np.array([0.97, 0.85, 0.70, 0.55, 0.45, 0.30, 0.15, 0.03])
delta = np.array([-0.05, -0.08, 0.03, 0.10, -0.10, -0.03, 0.08, 0.05])

U_values = np.logspace(-3, 0, 50)
deviations = {k: [] for k in range(1, K + 1)}

for U in U_values:
    interacting = np.clip(free_spec + U * delta, 0.001, 0.999)
    for k in range(1, K + 1):
        dev = abs(nr(interacting, k) - nr(free_spec, k))
        deviations[k].append(max(dev, 1e-16))

# ─── Plot ───

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: log-log plot of deviations
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, K))
for k in range(1, K + 1):
    ax.loglog(U_values, deviations[k], '-', color=colors[k-1],
              linewidth=2, label=f'k = {k}')

# Reference line with slope 1
ax.loglog(U_values, 0.5 * U_values, '--', color='gray', linewidth=1,
          alpha=0.7, label='slope = 1')
ax.set_xlabel('Coupling Strength U', fontsize=13)
ax.set_ylabel('|ρ_k(λ(U)) − ρ_k(λ(0))|', fontsize=13)
ax.set_title('Newton Ratio Deviation vs. Coupling\n(Weak-Coupling Universality Test)', fontsize=14)
ax.legend(fontsize=10, loc='lower right')
ax.grid(True, alpha=0.3)

# Right: Newton ratio profiles at selected U values
ax2 = axes[1]
U_selected = [0.0, 0.01, 0.05, 0.1, 0.5]
for U in U_selected:
    spec = np.clip(free_spec + U * delta, 0.001, 0.999)
    ev = esymm_dp(list(spec), K + 1)
    profile = [nr(list(spec), k, ev) for k in range(1, K + 1)]
    ax2.plot(range(1, K + 1), profile, 'o-', linewidth=2, markersize=6,
             label=f'U = {U}')

ax2.set_xlabel('Newton Level k', fontsize=13)
ax2.set_ylabel('Newton Ratio ρ_k', fontsize=13)
ax2.set_title('Newton Ratio Profiles\nAcross Coupling Strengths', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(1, K + 1))

plt.tight_layout()
plt.savefig('newton_stability.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved newton_stability.png")
