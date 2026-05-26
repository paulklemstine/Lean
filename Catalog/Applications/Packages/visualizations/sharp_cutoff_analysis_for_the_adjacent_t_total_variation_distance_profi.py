#!/usr/bin/env python3
"""
Visualization: Total Variation Distance Profiles for the Hybrid Walk

Plots the total variation distance d(t) = TV(P^t δ_id, π) as a function of time
for the adjacent-transposition-plus-cycle walk on S_n, for n = 3, 4, 5, 6.

The second panel rescales time by n² log n to test the conjecture that
mixing occurs at the diffusive scale Θ(n² log n). If the conjecture is correct,
the rescaled curves should approximately overlap.

This visualization demonstrates the cutoff phenomenon: a sharp transition from
"far from mixed" to "well mixed" occurring around a critical time.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial, log


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


def compute_tv_profile(n, max_steps=None):
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

    identity = tuple(range(n))
    dist = np.zeros(N)
    dist[perm_index[identity]] = 1.0
    uniform = 1.0 / N

    tv_distances = []
    for t in range(max_steps + 1):
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        tv_distances.append(tv)
        dist = dist @ P

    return tv_distances


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
colors = {3: '#e41a1c', 4: '#377eb8', 5: '#4daf4a', 6: '#984ea3'}

for n in [3, 4, 5, 6]:
    tv = compute_tv_profile(n)
    times = list(range(len(tv)))

    # Raw TV profile
    label = f'$S_{n}$ ({"lazy" if n % 2 == 0 else "non-lazy"})'
    axes[0].plot(times, tv, color=colors[n], linewidth=2, label=label)

    # Rescaled by n² log n
    scale = n * n * log(n) if n > 1 else 1
    rescaled_times = [t / scale for t in times]
    axes[1].plot(rescaled_times, tv, color=colors[n], linewidth=2, label=f'$S_{n}$')

# Panel 1: Raw profiles
axes[0].set_xlabel('Time $t$', fontsize=13)
axes[0].set_ylabel('$d(t) = \\mathrm{TV}(P^t \\delta_{\\mathrm{id}}, \\pi)$', fontsize=13)
axes[0].set_title('Total Variation Distance Profiles', fontsize=14)
axes[0].axhline(y=0.25, color='gray', linestyle='--', alpha=0.5, label='$\\varepsilon = 1/4$')
axes[0].legend(fontsize=10)
axes[0].set_ylim(-0.05, 1.05)
axes[0].grid(True, alpha=0.3)

# Panel 2: Rescaled
axes[1].set_xlabel('$t / (n^2 \\log n)$', fontsize=13)
axes[1].set_ylabel('$d(t)$', fontsize=13)
axes[1].set_title('Rescaled by $n^2 \\log n$ (Testing Cutoff Scale)', fontsize=14)
axes[1].axhline(y=0.25, color='gray', linestyle='--', alpha=0.5)
axes[1].legend(fontsize=10)
axes[1].set_ylim(-0.05, 1.05)
axes[1].set_xlim(0, 1.5)
axes[1].grid(True, alpha=0.3)

plt.suptitle('Adjacent-Transposition-Plus-Cycle Walk: Cutoff Phenomenon',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tv_profiles.png', dpi=150, bbox_inches='tight')
print("Saved tv_profiles.png")
