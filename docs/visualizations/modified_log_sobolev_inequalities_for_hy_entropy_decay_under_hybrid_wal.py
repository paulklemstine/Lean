#!/usr/bin/env python3
"""
Visualization: Entropy Decay under the Hybrid Walk

Shows how relative entropy Ent_μ(P^t f) decays over time for the hybrid
adjacent-transposition-plus-cycle walk on S_n, for n = 3, 4, 5.

The plot demonstrates:
1. Exponential entropy decay (linear on log scale)
2. Faster decay for smaller n (larger ρ_n)
3. The data processing inequality: entropy never increases
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def build_hybrid_walk(n):
    perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)

    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)
    return P, N


def compute_entropy(f, mu):
    ef = np.dot(mu, f)
    if ef <= 0 or np.any(f <= 0):
        return 0.0
    return np.dot(mu, f * np.log(f)) - ef * np.log(ef)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

colors = {3: '#2196F3', 4: '#FF5722', 5: '#4CAF50'}

# Left panel: Entropy decay curves
ax = axes[0]
for n in [3, 4, 5]:
    P, N = build_hybrid_walk(n)
    mu = np.ones(N) / N

    # Start from peaked distribution (delta at identity)
    f = np.ones(N) * 0.01
    f[0] = N * 0.5

    num_steps = 60
    entropies = []
    for t in range(num_steps):
        ent = compute_entropy(f, mu)
        entropies.append(max(ent, 1e-20))
        f = P.T @ f

    ax.semilogy(range(num_steps), entropies, '-', linewidth=2.5,
                color=colors[n], label=f'$S_{n}$ (n={n}, |S_n|={N})')

ax.set_xlabel('Time steps $t$', fontsize=13)
ax.set_ylabel('$\\mathrm{Ent}_\\mu(P^t f)$', fontsize=13)
ax.set_title('Entropy Decay under Hybrid Walk', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=1e-16)

# Right panel: Scaling of rho * n^2
ax = axes[1]
ns = [3, 4, 5]
rho_n2_values = []

for n in ns:
    P, N = build_hybrid_walk(n)
    mu = np.ones(N) / N

    rng = np.random.RandomState(42)
    min_ratio = float('inf')

    for trial in range(3000):
        if trial % 3 == 0:
            f = np.exp(rng.randn(N) * 0.5)
        elif trial % 3 == 1:
            f = 1.0 + rng.randn(N) * 0.1
            f = np.maximum(f, 0.01)
        else:
            f = rng.pareto(2.0, N) + 0.01

        logf = np.log(f)
        ef = np.dot(mu, f)
        ent = np.dot(mu, f * logf) - ef * np.log(ef)
        if ent < 1e-15:
            continue
        df = f[:, None] - f[None, :]
        dlogf = logf[:, None] - logf[None, :]
        dirichlet = 0.5 * np.sum(mu[:, None] * P * df * dlogf)
        if dirichlet < 0:
            continue
        ratio = dirichlet / ent
        if ratio < min_ratio:
            min_ratio = ratio

    rho_n2_values.append(min_ratio * n**2)

ax.bar(ns, rho_n2_values, color=[colors[n] for n in ns], alpha=0.8, width=0.6)
ax.set_xlabel('$n$', fontsize=13)
ax.set_ylabel('$\\rho_n \\cdot n^2$', fontsize=13)
ax.set_title('MLSI Scaling: $\\rho_n \\cdot n^2$ (bounded away from 0)', fontsize=14, fontweight='bold')
ax.set_xticks(ns)
ax.grid(True, axis='y', alpha=0.3)

# Add horizontal line at minimum
min_val = min(rho_n2_values)
ax.axhline(y=min_val, color='red', linestyle='--', alpha=0.7,
           label=f'min = {min_val:.2f}')
ax.legend(fontsize=11)

plt.tight_layout()
plt.savefig('entropy_decay_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved entropy_decay_visualization.png")
