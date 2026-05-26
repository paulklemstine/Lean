#!/usr/bin/env python3
"""
Visualization 2: Certified Spectral Bounds vs Actual TV Distance

Compares the certified upper bound (1/2)√(n!-1)·(1-gap)^t from the
formally verified theorem with the actual TV distance, showing the
quality of the spectral bound across different group sizes.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial, log, sqrt


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


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

n_values = [3, 4, 5, 6]
colors_actual = ['#2ecc71', '#2ecc71', '#2ecc71', '#2ecc71']
colors_bound = ['#e74c3c', '#e74c3c', '#e74c3c', '#e74c3c']

for idx, n in enumerate(n_values):
    ax = axes[idx]
    N = factorial(n)
    P = build_transition_matrix(n)
    gap = spectral_gap(P)

    max_steps = min(400, 10 * n * n * max(1, int(log(n))))
    profile = compute_tv_profile(P, n, max_steps)
    times = np.arange(len(profile))

    # Certified upper bound
    bound = [min(0.5 * sqrt(N - 1) * (1 - gap) ** t, 2.0) for t in times]

    # Observable lower bound (fixed points)
    # At t=0, separation = |n - 1| / (2*(n-1)) = 1/2
    fp_lower = []
    dist = np.zeros(N)
    dist[0] = 1.0
    for t in range(len(profile)):
        # Expected fixed points under current distribution
        E_fp = 0
        for i in range(N):
            perm = lehmer_decode(i, n)
            fp_count = sum(1 for j in range(n) if perm[j] == j)
            E_fp += dist[i] * fp_count
        separation = abs(E_fp - 1.0)  # mean under uniform is 1
        lb = separation / (2 * (n - 1))  # B = n - 1 (max |f - mean|)
        fp_lower.append(min(lb, 1.0))
        if t < len(profile) - 1:
            dist = dist @ P

    ax.fill_between(times, fp_lower, bound, alpha=0.15, color='#3498db')
    ax.plot(times, profile, color='#2ecc71', linewidth=2.5,
            label='Actual TV distance', zorder=3)
    ax.plot(times, bound, color='#e74c3c', linewidth=2, linestyle='--',
            label=f'Spectral upper bound', zorder=2)
    ax.plot(times, fp_lower, color='#9b59b6', linewidth=2, linestyle=':',
            label='Observable lower bound', zorder=2)

    ax.set_xlabel('Time (t)', fontsize=12)
    ax.set_ylabel('TV Distance', fontsize=12)
    ax.set_title(f'$S_{{{n}}}$ — gap = {gap:.4f}, τ = {1/gap:.1f}',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.set_ylim(-0.05, min(max(bound[:10]) * 1.1, 2.5))
    ax.set_xlim(0, max_steps)
    ax.grid(True, alpha=0.3)

    # Annotate mixing time
    t_mix = next((t for t, tv in enumerate(profile) if tv < 0.25), len(profile) - 1)
    ax.axvline(x=t_mix, color='gray', linestyle='-.', alpha=0.5)
    ax.annotate(f'$t_{{mix}}={t_mix}$', xy=(t_mix, 0.3),
                fontsize=10, color='gray')

plt.suptitle('Certified Spectral Bounds vs Actual Mixing\n'
             'Green: actual TV | Red: upper bound (Theorem 1) | Purple: lower bound (Theorem 3)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('spectral_bounds.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectral_bounds.png")
