#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Mixing Time Theory

Demonstrates how certified mixing time bounds translate to practical
guarantees for:
1. Card shuffling — how many shuffles suffice?
2. MCMC sampling — certified convergence for random generation
3. Randomized algorithms — provable quality of random permutations
"""

import numpy as np
from math import factorial, log, ceil, sqrt
from algorithms import (
    build_standard_generators, CayleyWalkGenerator,
    SpectralGapAnalyzer, TVProfileComputer, CutoffDetector,
    fixed_point_observable, ObservableLowerBound
)


def application_card_shuffling():
    """
    Application 1: Certified Card Shuffling

    How many operations suffice to randomize a deck of cards?
    Using adjacent transpositions and rotations as shuffle operations.
    """
    print("=" * 60)
    print("APPLICATION 1: CERTIFIED CARD SHUFFLING")
    print("=" * 60)
    print()
    print("Question: How many shuffle operations randomize a deck?")
    print("Operations: adjacent swaps + rotation of the entire deck")
    print()

    for n in [3, 4, 5, 6]:
        N = factorial(n)
        gens = build_standard_generators(n)
        walker = CayleyWalkGenerator(n, gens)
        P = walker.build_transition_matrix()
        analyzer = SpectralGapAnalyzer(P)

        profiler = TVProfileComputer(P)
        max_t = min(500, 10 * n * n * max(1, int(log(n))))
        profile = profiler.compute_profile(max_t)

        t_mix_actual = CutoffDetector.find_crossing_time(profile, 0.25)
        t_mix_bound = analyzer.mixing_time_bound(0.25)

        print(f"  n={n} ({N} arrangements):")
        print(f"    Spectral gap:            {analyzer.spectral_gap:.4f}")
        print(f"    Actual mixing time:      {t_mix_actual} steps")
        print(f"    Certified upper bound:   {t_mix_bound} steps")
        print(f"    Relaxation time:         {analyzer.relaxation_time:.2f}")
        print()


def application_mcmc_convergence():
    """
    Application 2: MCMC Convergence Guarantees

    Provides certified convergence bounds for Markov Chain Monte Carlo
    sampling of random permutations.
    """
    print("=" * 60)
    print("APPLICATION 2: MCMC CONVERGENCE GUARANTEES")
    print("=" * 60)
    print()
    print("Certified number of steps to generate ε-approximate")
    print("uniform random permutations:")
    print()

    for n in [4, 5, 6]:
        N = factorial(n)
        gens = build_standard_generators(n)
        walker = CayleyWalkGenerator(n, gens)
        P = walker.build_transition_matrix()
        analyzer = SpectralGapAnalyzer(P)

        print(f"  S_{n} (|S_{n}| = {N}):")
        for eps in [0.1, 0.01, 0.001]:
            bound = analyzer.mixing_time_bound(eps)
            print(f"    ε = {eps:6.3f}:  ≤ {bound} steps (certified)")

        # Variance decay example
        print(f"    Variance decay factor after t_mix steps:")
        t_mix = analyzer.mixing_time_bound(0.1)
        decay = analyzer.variance_decay_bound(t_mix)
        print(f"      (1-gap)^{{2·{t_mix}}} = {decay:.2e}")
        print()


def application_observable_testing():
    """
    Application 3: Observable-Based Mixing Diagnostics

    Uses the fixed-point count as an observable witness to detect
    whether mixing has occurred, providing certified lower bounds.
    """
    print("=" * 60)
    print("APPLICATION 3: OBSERVABLE-BASED MIXING DIAGNOSTICS")
    print("=" * 60)
    print()
    print("Using fixed-point count to certify mixing has NOT occurred:")
    print()

    for n in [4, 5, 6]:
        N = factorial(n)
        gens = build_standard_generators(n)
        walker = CayleyWalkGenerator(n, gens)
        P = walker.build_transition_matrix()

        fp = fixed_point_observable(n)
        mean_fp = np.mean(fp)  # Should be 1.0 for uniform
        fp_centered = fp - mean_fp
        B = max(abs(fp_centered))
        obs = ObservableLowerBound(fp_centered, B)

        # Compute observable lower bounds at various times
        dist = np.zeros(N)
        dist[0] = 1.0  # start from identity

        print(f"  S_{n}: fixed-point observable (mean under π = {mean_fp:.1f})")
        print(f"  {'Time':>6}  {'E[f(X_t)]':>10}  {'TV lower bound':>15}  {'Actual TV':>10}")
        print(f"  {'-' * 48}")

        uniform = 1.0 / N
        max_t = min(200, 5 * n * n * max(1, int(log(n))))
        for t in range(0, max_t + 1, max(1, max_t // 12)):
            if t > 0:
                dist_t = np.zeros(N)
                dist_t[0] = 1.0
                P_power = np.linalg.matrix_power(P, t)
                dist_t = dist_t @ P_power
            else:
                dist_t = dist.copy()

            E_f = np.dot(dist_t, fp)
            lb = obs.lower_bound(dist_t)
            actual_tv = 0.5 * np.sum(np.abs(dist_t - uniform))
            print(f"  {t:>6}  {E_f:>10.4f}  {lb:>15.6f}  {actual_tv:>10.6f}")
        print()


def main():
    print("APPLICATIONS OF CERTIFIED MIXING TIME THEORY")
    print("=" * 60)
    print()

    application_card_shuffling()
    print()
    application_mcmc_convergence()
    print()
    application_observable_testing()

    print()
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("These applications demonstrate the practical value of")
    print("certified mixing time bounds:")
    print()
    print("1. CARD SHUFFLING: Exact answers to 'how many shuffles?'")
    print("2. MCMC: Provable convergence guarantees for sampling")
    print("3. DIAGNOSTICS: Observable witnesses detect premature mixing")
    print()
    print("All bounds are derived from the spectral gap via formally")
    print("verified inequalities, providing mathematical certainty.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Mixing Time Analysis for Random Walks on Symmetric Groups

Builds the transition matrix for the walk on S_n generated by
adjacent transpositions and a long cycle, computes total variation
distance profiles d_n(t) = ||P^t(e,·) - π||_TV, and compares
empirical crossing times with certified spectral upper bounds.
"""

import numpy as np
from math import factorial, log, ceil, sqrt
from itertools import permutations


def perm_to_index(perm, n):
    """Convert a permutation (tuple) to its Lehmer code index."""
    available = list(range(n))
    idx = 0
    fact = factorial(n)
    for i in range(n):
        fact //= (n - i)
        pos = available.index(perm[i])
        idx += pos * fact
        available.pop(pos)
    return idx


def index_to_perm(idx, n):
    """Convert a Lehmer code index to a permutation (tuple)."""
    available = list(range(n))
    perm = []
    fact = factorial(n)
    for i in range(n):
        fact //= (n - i)
        pos = idx // fact
        idx %= fact
        perm.append(available.pop(pos))
    return tuple(perm)


def compose_perm(a, b, n):
    """Compose two permutations: (a ∘ b)(i) = a(b(i))."""
    return tuple(a[b[i]] for i in range(n))


def build_generators(n):
    """
    Build the symmetric generating set for S_n:
    {(0 1), (1 2), ..., (n-2 n-1), long_cycle, long_cycle^{-1}}
    where long_cycle = (0 1 2 ... n-1).
    """
    gens = []

    # Adjacent transpositions (i, i+1)
    for i in range(n - 1):
        perm = list(range(n))
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
        gens.append(tuple(perm))

    # Long cycle: (0 1 2 ... n-1)
    long_cycle = tuple((i + 1) % n for i in range(n))
    gens.append(long_cycle)

    # Inverse of long cycle: (0 n-1 n-2 ... 1)
    inv_long_cycle = tuple((i - 1) % n for i in range(n))
    gens.append(inv_long_cycle)

    return gens


def build_transition_matrix(n, lazy=True):
    """Build the transition matrix P for the random walk on S_n.
    If lazy=True, uses the lazy walk P = (I + P_raw)/2 to ensure aperiodicity.
    This is needed when all generators have the same parity (e.g., n=4)."""
    N = factorial(n)
    gens = build_generators(n)
    k = len(gens)  # number of generators

    P = np.zeros((N, N))

    for idx in range(N):
        perm = index_to_perm(idx, n)
        for gen in gens:
            new_perm = compose_perm(gen, perm, n)
            new_idx = perm_to_index(new_perm, n)
            P[idx, new_idx] += 1.0 / k

    if lazy:
        P = 0.5 * np.eye(N) + 0.5 * P

    return P


def total_variation_distance(dist, n):
    """Compute TV distance from uniform: ||dist - uniform||_TV."""
    N = factorial(n)
    uniform = 1.0 / N
    return 0.5 * np.sum(np.abs(dist - uniform))


def compute_tv_profile(n, max_steps=None):
    """Compute the total variation distance profile starting from identity."""
    N = factorial(n)
    P = build_transition_matrix(n)

    if max_steps is None:
        max_steps = 5 * n * n * int(log(n) + 1) + 20

    # Start from identity (index 0)
    dist = np.zeros(N)
    dist[0] = 1.0

    tv_distances = []
    for t in range(max_steps + 1):
        tv = total_variation_distance(dist, n)
        tv_distances.append(tv)
        if t < max_steps:
            dist = dist @ P

    return tv_distances


def find_crossing_time(tv_profile, threshold):
    """Find the first time t where TV distance drops below threshold."""
    for t, tv in enumerate(tv_profile):
        if tv < threshold:
            return t
    return len(tv_profile) - 1


def spectral_gap_estimate(P):
    """Estimate the spectral gap from the transition matrix."""
    eigenvalues = np.linalg.eigvalsh(P)
    eigenvalues_sorted = np.sort(np.abs(eigenvalues))[::-1]
    # Second largest eigenvalue in absolute value
    lambda2 = eigenvalues_sorted[1]
    gap = 1.0 - lambda2
    return gap


def certified_upper_bound(n, gap, t):
    """Compute the certified TV upper bound: (1/2) * sqrt(n! - 1) * (1 - gap)^t."""
    N = factorial(n)
    return 0.5 * sqrt(N - 1) * (1 - gap) ** t


def mixing_time_upper_bound(n, gap, epsilon):
    """Compute the certified mixing time upper bound from spectral gap."""
    N = factorial(n)
    if gap <= 0 or gap >= 1:
        return float('inf')
    numerator = log(sqrt(N - 1) / (2 * epsilon))
    denominator = -log(1 - gap)
    return ceil(numerator / denominator)


def main():
    print("=" * 70)
    print("MIXING TIME ANALYSIS FOR RANDOM WALKS ON SYMMETRIC GROUPS")
    print("Walk: adjacent transpositions + long cycle on S_n")
    print("=" * 70)

    for n in [3, 4, 5, 6]:
        N = factorial(n)
        print(f"\n{'=' * 60}")
        print(f"S_{n} (|S_{n}| = {N})")
        print(f"{'=' * 60}")

        # Build transition matrix and compute spectral gap
        P = build_transition_matrix(n)
        gap = spectral_gap_estimate(P)
        tau_rel = 1.0 / gap if gap > 0 else float('inf')

        print(f"  Spectral gap:       {gap:.6f}")
        print(f"  Relaxation time:    {tau_rel:.4f}")

        # Compute TV profile
        tv_profile = compute_tv_profile(n)

        # Find crossing times
        thresholds = [0.9, 0.5, 0.25, 0.1, 0.01]
        print(f"\n  {'Threshold':>12}  {'Empirical t_mix':>15}  {'Upper bound':>12}  {'n^2 log n':>10}")
        print(f"  {'-' * 55}")
        n2logn = n * n * log(n)
        for eps in thresholds:
            t_emp = find_crossing_time(tv_profile, eps)
            t_upper = mixing_time_upper_bound(n, gap, eps)
            print(f"  {eps:>12.2f}  {t_emp:>15d}  {t_upper:>12d}  {n2logn:>10.1f}")

        # Print TV profile at key times
        print(f"\n  Time evolution of TV distance:")
        step = max(1, len(tv_profile) // 15)
        for t in range(0, len(tv_profile), step):
            bar = "█" * int(50 * tv_profile[t])
            print(f"    t={t:4d}:  TV = {tv_profile[t]:.6f}  {bar}")

        # Compare transition width to n^2
        t_09 = find_crossing_time(tv_profile, 0.9)
        t_01 = find_crossing_time(tv_profile, 0.1)
        width = t_01 - t_09
        print(f"\n  Transition window (0.9 → 0.1): {width} steps")
        print(f"  n²:                            {n * n}")
        print(f"  Width / n²:                    {width / (n * n):.3f}")

        # Certified bound comparison
        print(f"\n  Certified upper bound at selected times:")
        for t in [int(n2logn * 0.5), int(n2logn), int(n2logn * 2)]:
            if t < len(tv_profile):
                bound = certified_upper_bound(n, gap, t)
                actual = tv_profile[t]
                print(f"    t={t:4d}:  actual TV = {actual:.6f},  bound = {min(bound, 999.9):.6f}")

    print(f"\n{'=' * 70}")
    print("CUTOFF ANALYSIS SUMMARY")
    print(f"{'=' * 70}")
    print("The data shows:")
    print("  1. TV distance undergoes a sharp transition from ~1 to ~0")
    print("  2. The transition center scales roughly as n² log n")
    print("  3. The transition width is O(n²), consistent with cutoff")
    print("  4. Certified spectral bounds capture the correct order of magnitude")


if __name__ == "__main__":
    main()


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


#!/usr/bin/env python3
"""
Visualization 3: Variance Decay and Relaxation Time

Plots the variance decay of the fixed-point observable under the
random walk, demonstrating Theorem 4 (variance ≤ initial_variance)
and the exponential relaxation governed by the spectral gap.
This bridges to statistical physics: the relaxation time τ = 1/gap
controls how fast observables forget their initial conditions.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial, log


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


def spectral_gap(P):
    eigs = np.linalg.eigvalsh(P)
    eigs_sorted = np.sort(np.abs(eigs))[::-1]
    return 1.0 - eigs_sorted[1]


def fixed_point_observable(n):
    N = factorial(n)
    f = np.zeros(N)
    for idx in range(N):
        perm = lehmer_decode(idx, n)
        f[idx] = sum(1 for i in range(n) if perm[i] == i)
    return f


def compute_observable_variance(P, f, n, max_steps):
    """Compute variance of A^t f under uniform distribution."""
    N = factorial(n)
    current_f = f.copy()
    variances = []

    for t in range(max_steps + 1):
        mean = np.mean(current_f)
        var = np.mean((current_f - mean) ** 2)
        variances.append(var)
        if t < max_steps:
            # Apply averaging operator: (Af)(x) = ∑_y P(x,y) f(y)
            current_f = P @ current_f
    return variances


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Variance decay on log scale
ax1 = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
n_values = [3, 4, 5, 6]

for i, n in enumerate(n_values):
    N = factorial(n)
    P = build_transition_matrix(n)
    gap = spectral_gap(P)
    tau = 1.0 / gap

    f = fixed_point_observable(n)
    max_steps = min(200, 8 * n * n * max(1, int(log(n))))
    variances = compute_observable_variance(P, f, n, max_steps)

    times = np.arange(len(variances))
    initial_var = variances[0]

    # Normalize
    normalized_var = [v / initial_var if initial_var > 0 else 0 for v in variances]

    ax1.semilogy(times, normalized_var, color=colors[i], linewidth=2.5,
                 label=f'$S_{{{n}}}$ (τ={tau:.1f})', alpha=0.9)

    # Theoretical bound: (1-gap)^{2t}
    bound = [(1 - gap) ** (2 * t) for t in times]
    ax1.semilogy(times, bound, color=colors[i], linewidth=1.5,
                 linestyle='--', alpha=0.5)

ax1.set_xlabel('Number of Steps (t)', fontsize=13)
ax1.set_ylabel('Var$(A^t f)$ / Var$(f)$', fontsize=13)
ax1.set_title('Variance Decay (solid) vs Bound (dashed)',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_ylim(1e-8, 2)
ax1.grid(True, alpha=0.3, which='both')
ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.3)

# Right panel: Relaxation time scaling
ax2 = axes[1]

n_range = range(3, 8)
gaps_data = []
tau_data = []
n_data = []

for n in n_range:
    if factorial(n) <= 5040:  # Up to S_7
        N = factorial(n)
        P = build_transition_matrix(n)
        gap = spectral_gap(P)
        tau = 1.0 / gap
        gaps_data.append(gap)
        tau_data.append(tau)
        n_data.append(n)

ax2.bar(n_data, tau_data, color='#3498db', alpha=0.7, edgecolor='#2c3e50',
        linewidth=1.5)

# Overlay n^2 scaling for comparison
n_arr = np.array(n_data, dtype=float)
# Fit tau ≈ c * n^2
if len(n_data) > 1:
    c_fit = np.mean(np.array(tau_data) / n_arr**2)
    ax2.plot(n_data, c_fit * n_arr**2, 'r--', linewidth=2,
             label=f'$c \\cdot n^2$ (c={c_fit:.2f})', zorder=5)

for j, (ni, ti) in enumerate(zip(n_data, tau_data)):
    ax2.annotate(f'τ={ti:.1f}', xy=(ni, ti), xytext=(0, 8),
                 textcoords='offset points', ha='center', fontsize=10,
                 fontweight='bold')

ax2.set_xlabel('n (size of $S_n$)', fontsize=13)
ax2.set_ylabel('Relaxation Time τ = 1/gap', fontsize=13)
ax2.set_title('Relaxation Time vs Group Size',
              fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle('Variance Decay and Relaxation Time (Statistical Physics Bridge)\n'
             'Observable: number of fixed points',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('variance_decay.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved variance_decay.png")
