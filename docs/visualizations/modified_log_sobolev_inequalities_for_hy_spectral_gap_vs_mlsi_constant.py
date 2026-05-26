#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs Modified Log-Sobolev Constant

Compares the spectral gap (Poincaré constant) with the estimated MLSI
constant for the hybrid walk on S_n, n = 3, 4, 5.

The spectral gap controls variance decay: Var(P^t f) <= (1-lambda_1)^t Var(f)
The MLSI constant controls entropy decay: Ent(P^t f) <= exp(-2*rho*t) Ent(f)

The relationship rho <= lambda_1 always holds. For the hybrid walk,
both scale as Theta(1/n^2), but rho carries strictly more information.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


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


def estimate_rho(P, N, num_trials=5000):
    mu = np.ones(N) / N
    rng = np.random.RandomState(42)
    min_ratio = float('inf')

    for trial in range(num_trials):
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

    return min_ratio


ns = [3, 4, 5]
spectral_gaps = []
rho_estimates = []

for n in ns:
    P, N = build_hybrid_walk(n)
    eigs = np.linalg.eigvalsh(P)
    eigs.sort()
    spectral_gaps.append(1 - eigs[-2])
    rho_estimates.append(estimate_rho(P, N))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Raw values comparison
ax = axes[0]
x = np.arange(len(ns))
width = 0.35
bars1 = ax.bar(x - width/2, spectral_gaps, width, label='Spectral gap $\\lambda_1$',
               color='#2196F3', alpha=0.8)
bars2 = ax.bar(x + width/2, rho_estimates, width, label='MLSI constant $\\rho_n$ (est.)',
               color='#FF5722', alpha=0.8)
ax.set_xticks(x)
ax.set_xticklabels([f'$S_{n}$' for n in ns])
ax.set_ylabel('Constant value', fontsize=12)
ax.set_title('Spectral Gap vs MLSI Constant', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, axis='y', alpha=0.3)

# Panel 2: Scaled values (× n²)
ax = axes[1]
gap_scaled = [g * n**2 for g, n in zip(spectral_gaps, ns)]
rho_scaled = [r * n**2 for r, n in zip(rho_estimates, ns)]

ax.plot(ns, gap_scaled, 'o-', linewidth=2, markersize=8,
        color='#2196F3', label='$\\lambda_1 \\cdot n^2$')
ax.plot(ns, rho_scaled, 's-', linewidth=2, markersize=8,
        color='#FF5722', label='$\\rho_n \\cdot n^2$ (est.)')
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('$n$', fontsize=12)
ax.set_ylabel('Scaled constant $\\times n^2$', fontsize=12)
ax.set_title('$n^2$-Scaling: Both $\\Theta(1/n^2)$', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Entropy vs variance decay comparison for S_4
ax = axes[2]
n = 4
P, N = build_hybrid_walk(n)
mu = np.ones(N) / N
eigs = np.linalg.eigvalsh(P)
eigs.sort()
gap = 1 - eigs[-2]

# Initial function
f = np.ones(N) * 0.1
f[0] = N * 0.3
f[1] = N * 0.2

steps = 40
entropies = []
variances = []

f_ent = f.copy()
f_var = f.copy()

for t in range(steps):
    # Entropy
    ef = np.dot(mu, f_ent)
    if ef > 0 and np.all(f_ent > 0):
        ent = np.dot(mu, f_ent * np.log(f_ent)) - ef * np.log(ef)
    else:
        ent = 0
    entropies.append(max(ent, 1e-20))

    # Variance
    mean_f = np.dot(mu, f_var)
    var = np.dot(mu, (f_var - mean_f)**2)
    variances.append(max(var, 1e-20))

    f_ent = P.T @ f_ent
    f_var = P.T @ f_var

ax.semilogy(range(steps), entropies, '-', linewidth=2.5, color='#FF5722',
            label='Entropy $\\mathrm{Ent}_\\mu(P^t f)$')
ax.semilogy(range(steps), variances, '--', linewidth=2.5, color='#2196F3',
            label='Variance $\\mathrm{Var}_\\mu(P^t f)$')
ax.set_xlabel('Time steps $t$', fontsize=12)
ax.set_ylabel('Value (log scale)', fontsize=12)
ax.set_title(f'Entropy vs Variance Decay ($S_{n}$)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_vs_entropy_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectral_vs_entropy_visualization.png")
