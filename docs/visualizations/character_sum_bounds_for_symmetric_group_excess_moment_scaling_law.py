#!/usr/bin/env python3
"""
Visualization: Average Excess Moment Scaling Law

Plots the average excess moment A_{n,k} vs 1/n for symmetric groups S_n,
demonstrating the predicted O(1/n) decay law. Also plots n * A_{n,k}
to show convergence to the standard-representation constant.

This visualizes the central prediction: the deviation from free-group
universality scales as 1/n, where n is the degree of the symmetric group.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, Dict, List
import matplotlib.pyplot as plt
import numpy as np


# Self-contained permutation and moment computation
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

def moment_kernel(sigma: Perm, tau: Perm, m: int) -> Fraction:
    return Fraction(closed_word_count_dp(sigma, tau, m), 4**m)

def excess_moment(sigma: Perm, tau: Perm, m: int) -> Fraction:
    baseline = Fraction(1) if m == 0 else Fraction(0)
    return moment_kernel(sigma, tau, m) - baseline

def avg_excess_moment(n: int, m: int) -> Fraction:
    perms = all_permutations(n)
    total = Fraction(0)
    for sigma in perms:
        for tau in perms:
            total += excess_moment(sigma, tau, m)
    return total / Fraction(len(perms)**2)


# Compute data
ns = [3, 4, 5]
ks = [1, 2]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

for idx, k in enumerate(ks):
    m = 2 * k
    a_values = []
    na_values = []
    inv_n_values = []

    for n in ns:
        a = float(avg_excess_moment(n, m))
        a_values.append(a)
        na_values.append(n * a)
        inv_n_values.append(1.0 / n)

    # Left plot: A_{n,k} vs 1/n
    axes[0].plot(inv_n_values, a_values, 'o-', color=colors[idx],
                 label=f'k={k} (m={m})', markersize=8, linewidth=2)

    # Right plot: n * A_{n,k}
    axes[1].plot(ns, na_values, 's-', color=colors[idx],
                 label=f'k={k} (m={m})', markersize=8, linewidth=2)

# Left plot formatting
axes[0].set_xlabel('1/n', fontsize=14)
axes[0].set_ylabel('$A_{n,k}$ = avgExcessMoment(n, 2k)', fontsize=14)
axes[0].set_title('Excess Moment vs 1/n\n(Predicted: linear relationship)', fontsize=14)
axes[0].legend(fontsize=12)
axes[0].grid(True, alpha=0.3)

# Add regression line
for idx, k in enumerate(ks):
    m = 2 * k
    x_data = [1.0/n for n in ns]
    y_data = [float(avg_excess_moment(n, m)) for n in ns]
    if len(x_data) >= 2:
        coeffs = np.polyfit(x_data, y_data, 1)
        x_line = np.linspace(0, max(x_data) * 1.1, 100)
        y_line = np.polyval(coeffs, x_line)
        axes[0].plot(x_line, y_line, '--', color=colors[idx], alpha=0.5,
                     label=f'fit: {coeffs[0]:.3f}/n + {coeffs[1]:.3f}')

axes[0].legend(fontsize=10)

# Right plot formatting
axes[1].set_xlabel('n', fontsize=14)
axes[1].set_ylabel('$n \\cdot A_{n,k}$', fontsize=14)
axes[1].set_title('Scaled Excess Moment\n(Predicted: converges to constant $C_k$)',
                   fontsize=14)
axes[1].legend(fontsize=12)
axes[1].grid(True, alpha=0.3)
axes[1].set_xticks(ns)

plt.tight_layout()
plt.savefig('excess_moment_scaling.png', dpi=150, bbox_inches='tight')
print("Saved: excess_moment_scaling.png")
