#!/usr/bin/env python3
"""
Visualization: Truncated Excess Partition Function

Shows the truncated excess partition function Z_K(β) as a function of β
for different truncation levels K, demonstrating the cross-domain bridge
between moment bounds and statistical mechanics observables.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, Dict, List
import matplotlib.pyplot as plt
import numpy as np


Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    n = len(p)
    inv = [0] * n
    for i in range(n): inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Perm:
    return tuple(range(n))

def all_permutations(n: int) -> List[Perm]:
    return [tuple(p) for p in itertools.permutations(range(n))]

def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)
    dist = {e: 1}
    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in gens:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist
    return dist.get(e, 0)

def moment_kernel_float(sigma: Perm, tau: Perm, m: int) -> float:
    return closed_word_count_dp(sigma, tau, m) / 4**m

def excess_moment_float(sigma: Perm, tau: Perm, m: int) -> float:
    baseline = 1.0 if m == 0 else 0.0
    return moment_kernel_float(sigma, tau, m) - baseline


# Parameters
n = 4
perms = all_permutations(n)
card = len(perms)

# Pick representative generators
sigma = tuple((i + 1) % n for i in range(n))  # (0 1 2 3)
tau = (1, 0) + tuple(range(2, n))               # (0 1)

# Compute truncated partition function for varying β and K
betas = np.linspace(0, 3, 50)
K_values = [2, 4, 6, 8]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

# Left: Z_K(β) for a single pair (σ, τ)
for idx, K in enumerate(K_values):
    Z_values = []
    for beta in betas:
        Z = sum(
            beta**k / math.factorial(k) * excess_moment_float(sigma, tau, k)
            for k in range(K + 1)
        )
        Z_values.append(Z)
    axes[0].plot(betas, Z_values, '-', color=colors[idx % len(colors)],
                 linewidth=2, label=f'K={K}')

axes[0].set_xlabel('β (inverse temperature)', fontsize=13)
axes[0].set_ylabel('$Z_K(\\beta; \\sigma, \\tau)$', fontsize=13)
axes[0].set_title(f'Truncated Excess Partition Function\n'
                   f'Generators: σ={(0,1,2,3)}, τ=(0,1) in $S_{n}$',
                   fontsize=13)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)
axes[0].axhline(y=0, color='gray', linewidth=0.5)

# Right: Average Z_K(1) across all pairs, compared to bound
avg_Z_values = []
bound_values = []
K_range = range(1, 8)

for K in K_range:
    # Average over a sample of pairs
    np.random.seed(42)
    sample_size = min(50, card)
    total_Z = 0.0
    for _ in range(sample_size):
        s = perms[np.random.randint(card)]
        t = perms[np.random.randint(card)]
        Z = sum(
            1.0 / math.factorial(k) * excess_moment_float(s, t, k)
            for k in range(K + 1)
        )
        total_Z += Z
    avg_Z = total_Z / sample_size
    avg_Z_values.append(avg_Z)

    # Bound: sum of 1/k!
    bound = sum(1.0 / math.factorial(k) for k in range(K + 1))
    bound_values.append(bound)

axes[1].bar(list(K_range), avg_Z_values, alpha=0.7, color='#2196F3',
            label='Average $Z_K(1)$')
axes[1].plot(list(K_range), bound_values, 'rs-', markersize=8, linewidth=2,
             label='Bound: $\\sum 1/k!$')
axes[1].set_xlabel('Truncation level K', fontsize=13)
axes[1].set_ylabel('Value', fontsize=13)
axes[1].set_title(f'Average Partition Function vs Bound\n$S_{n}$, β=1',
                   fontsize=13)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('partition_function.png', dpi=150, bbox_inches='tight')
print("Saved: partition_function.png")
