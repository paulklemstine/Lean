#!/usr/bin/env python3
"""
Visualization: Cycle Displacement Observable Decay

Plots the expected value of the cycle displacement observable
F_n(σ) = Σ_j cos(2π(σ(j)-j)/n) under the walk started at identity.

This observable starts at F_n(id) = n and decays toward 0 (its uniform mean
for n ≥ 3). The decay rate is approximately (1 - c/n²)^t, confirming that
the walk has a diffusive contraction rate.

The observable provides the lower bound on mixing time via:
TV(P^t δ_id, π) ≥ |E[F_n(X_t)]| / (2n)

This is the computational evidence for Theorem C.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial, log, cos, pi


def compose_perm(sigma, tau, n):
    return tuple(sigma[tau[i]] for i in range(n))


def build_generators(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    gens.append(tuple((i + 1) % n for i in range(n)))
    gens.append(tuple((i - 1) % n for i in range(n)))
    return gens


def cycle_displacement(sigma, n):
    return sum(cos(2 * pi * (sigma[j] - j) / n) for j in range(n))


def compute_observable_decay(n, max_steps=None):
    N = factorial(n)
    gens = build_generators(n)
    num_gens = len(gens)
    lazy = (n % 2 == 0)

    all_perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(all_perms)}

    P = np.zeros((N, N))
    for i, sigma in enumerate(all_perms):
        for g in gens:
            result = compose_perm(g, sigma, n)
            j = perm_index[result]
            P[i, j] += 1.0 / num_gens

    if lazy:
        P = 0.5 * np.eye(N) + 0.5 * P

    if max_steps is None:
        max_steps = int(4 * n * n * log(max(n, 2)) + 20)

    obs_values = np.array([cycle_displacement(sigma, n) for sigma in all_perms])

    identity = tuple(range(n))
    dist = np.zeros(N)
    dist[perm_index[identity]] = 1.0

    expectations = []
    for t in range(max_steps + 1):
        expectations.append(float(dist @ obs_values))
        dist = dist @ P

    return expectations


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
colors = {3: '#e41a1c', 4: '#377eb8', 5: '#4daf4a', 6: '#984ea3'}

for n in [3, 4, 5, 6]:
    obs = compute_observable_decay(n)
    times = list(range(len(obs)))

    # Normalized by initial value (= n)
    obs_normalized = [o / n for o in obs]

    # Raw decay
    axes[0].plot(times, obs_normalized, color=colors[n], linewidth=2,
                 label=f'$S_{n}$')

    # Log plot for exponential decay
    obs_positive = [max(abs(o), 1e-15) for o in obs_normalized]
    axes[1].semilogy(times, obs_positive, color=colors[n], linewidth=2,
                     label=f'$S_{n}$')

# Theoretical decay curves
for n in [3, 4, 5, 6]:
    # Compute spectral gap
    N = factorial(n)
    gens = build_generators(n)
    all_perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(all_perms)}
    P = np.zeros((N, N))
    for i, sigma in enumerate(all_perms):
        for g in gens:
            result = compose_perm(g, sigma, n)
            j = perm_index[result]
            P[i, j] += 1.0 / len(gens)
    if n % 2 == 0:
        P = 0.5 * np.eye(N) + 0.5 * P
    eigs = np.sort(np.linalg.eigvalsh(P))[::-1]
    lambda2 = eigs[1]

    max_t = int(4 * n * n * log(max(n, 2)) + 20)
    t_arr = np.arange(max_t + 1)
    theory = lambda2 ** t_arr
    axes[1].plot(t_arr, theory, '--', color=colors[n], alpha=0.5, linewidth=1)

axes[0].set_xlabel('Time $t$', fontsize=13)
axes[0].set_ylabel('$E[F_n(X_t)] / n$', fontsize=13)
axes[0].set_title('Observable Decay (Normalized)', fontsize=14)
axes[0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

axes[1].set_xlabel('Time $t$', fontsize=13)
axes[1].set_ylabel('$|E[F_n(X_t)]| / n$  (log scale)', fontsize=13)
axes[1].set_title('Exponential Decay (dashed = theoretical $\\lambda_2^t$)', fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(1e-6, 2)

plt.suptitle('Cycle Displacement Observable: Evidence for $\\Theta(n^2 \\log n)$ Lower Bound',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('observable_decay.png', dpi=150, bbox_inches='tight')
print("Saved observable_decay.png")
