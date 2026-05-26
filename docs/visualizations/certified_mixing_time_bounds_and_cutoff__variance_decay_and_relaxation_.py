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
