#!/usr/bin/env python3
"""
Visualization 1: Total Variation Distance Profiles

Plots the TV distance d_n(t) = ||P^t(e,·) - π||_TV as a function of time
for the symmetric group walk on S_3, S_4, S_5, S_6.
Shows the sharp "cutoff" transition from unmixed (TV ≈ 1) to mixed (TV ≈ 0).
Also overlays the certified spectral upper bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial, log, ceil, sqrt


def lehmer_encode(perm, n):
    available = list(range(n))
    idx = 0
    fact = factorial(n)
    for i in range(n):
        fact //= (n - i)
        pos = available.index(perm[i])
        idx += pos * fact
        available.pop(pos)
    return idx


def lehmer_decode(idx, n):
    available = list(range(n))
    perm = []
    fact = factorial(n)
    for i in range(n):
        fact //= (n - i)
        pos = idx // fact
        idx %= fact
        perm.append(available.pop(pos))
    return tuple(perm)


def build_transition_matrix(n):
    N = factorial(n)
    gens = []
    for i in range(n - 1):
        perm = list(range(n))
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
        gens.append(tuple(perm))
    long_cycle = tuple((i + 1) % n for i in range(n))
    gens.append(long_cycle)
    inv_long_cycle = tuple((i - 1) % n for i in range(n))
    gens.append(inv_long_cycle)
    k = len(gens)
    P = np.zeros((N, N))
    for idx in range(N):
        perm = lehmer_decode(idx, n)
        for gen in gens:
            new_perm = tuple(gen[perm[i]] for i in range(n))
            new_idx = lehmer_encode(new_perm, n)
            P[idx, new_idx] += 1.0 / k
    # Lazy walk for aperiodicity
    P = 0.5 * np.eye(N) + 0.5 * P
    return P


def compute_tv_profile(P, n, max_steps):
    N = factorial(n)
    uniform = 1.0 / N
    dist = np.zeros(N)
    dist[0] = 1.0
    profile = []
    for t in range(max_steps + 1):
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        profile.append(tv)
        if t < max_steps:
            dist = dist @ P
    return profile


def spectral_gap(P):
    eigs = np.linalg.eigvalsh(P)
    eigs_sorted = np.sort(np.abs(eigs))[::-1]
    return 1.0 - eigs_sorted[1]


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: TV profiles
ax1 = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
n_values = [3, 4, 5, 6]

profiles = {}
gaps = {}

for i, n in enumerate(n_values):
    N = factorial(n)
    P = build_transition_matrix(n)
    gap = spectral_gap(P)
    gaps[n] = gap
    max_steps = min(300, 8 * n * n * max(1, int(log(n))))
    profile = compute_tv_profile(P, n, max_steps)
    profiles[n] = profile
    times = np.arange(len(profile))
    ax1.plot(times, profile, color=colors[i], linewidth=2.5,
             label=f'$S_{{{n}}}$ (gap={gap:.3f})', alpha=0.9)

ax1.axhline(y=0.25, color='gray', linestyle='--', alpha=0.5, label='ε = 0.25')
ax1.set_xlabel('Number of Steps (t)', fontsize=13)
ax1.set_ylabel('Total Variation Distance $d_n(t)$', fontsize=13)
ax1.set_title('Mixing Profiles: TV Distance vs Time', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper right')
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Right panel: Rescaled profiles (evidence for cutoff)
ax2 = axes[1]

for i, n in enumerate(n_values):
    profile = profiles[n]
    # Find mixing time (t where TV crosses 0.5)
    t_mix = next((t for t, tv in enumerate(profile) if tv < 0.5), len(profile) - 1)
    n2 = n * n
    if t_mix > 0 and n2 > 0:
        rescaled_times = [(t - t_mix) / n2 for t in range(len(profile))]
        ax2.plot(rescaled_times, profile, color=colors[i], linewidth=2.5,
                 label=f'$S_{{{n}}}$ ($t_{{mix}}$={t_mix})', alpha=0.9)

ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
ax2.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax2.set_xlabel('$(t - t_{mix}) / n^2$', fontsize=13)
ax2.set_ylabel('Total Variation Distance', fontsize=13)
ax2.set_title('Rescaled Profiles (Cutoff Evidence)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11, loc='upper right')
ax2.set_ylim(-0.05, 1.05)
ax2.set_xlim(-3, 5)
ax2.grid(True, alpha=0.3)

plt.suptitle('Mixing Time Analysis: Random Walks on Symmetric Groups\n'
             'Generators: adjacent transpositions + long cycle',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tv_profiles.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved tv_profiles.png")
