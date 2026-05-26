#!/usr/bin/env python3
"""
Visualization: TV Distance Decay Curves

Visualizes how total variation distance from uniform decays as the number
of rounds T increases, for different values of k (swaps per layer).
Shows the theoretical support-size bound and the empirical decay.

This is the central experimental finding: shallow alternating permutation
networks leave a mathematically detectable scar that decays with rounds.
"""

import math
import random
from collections import Counter

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def identity(n):
    return tuple(range(n))

def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def adj_swap(n, j):
    p = list(range(n))
    p[j], p[j+1] = p[j+1], p[j]
    return tuple(p)

def cyclic_shift(n, t):
    return tuple((i + t) % n for i in range(n))

def random_adj_swap_layer(n, k):
    available = list(range(n-1))
    random.shuffle(available)
    layer = identity(n)
    used = set()
    count = 0
    for j in available:
        if j not in used and (j+1) not in used and count < k:
            layer = compose(adj_swap(n, j), layer)
            used.update([j, j+1])
            count += 1
    return layer

def build_network(n, T, k):
    result = identity(n)
    for r in range(T):
        if r % 2 == 0:
            result = compose(random_adj_swap_layer(n, k), result)
        else:
            result = compose(cyclic_shift(n, random.randint(0, n-1)), result)
    return result

def empirical_tv(counts, n_factorial, num_samples):
    uniform_prob = 1.0 / n_factorial
    tv = sum(abs(c/num_samples - uniform_prob) for c in counts.values())
    tv += (n_factorial - len(counts)) * uniform_prob
    return tv / 2.0


random.seed(42)
n = 8
n_factorial = math.factorial(n)
T_max = 24
k_values = [1, 2, 3, 4]
num_samples = 40000

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = {'1': '#e74c3c', '2': '#3498db', '3': '#2ecc71', '4': '#f39c12'}

for k in k_values:
    tvs = []
    supports = []
    Ts = list(range(1, T_max + 1))
    for T in Ts:
        counts = Counter()
        for _ in range(num_samples):
            counts[build_network(n, T, k)] += 1
        tvs.append(empirical_tv(counts, n_factorial, num_samples))
        supports.append(len(counts))

    c = colors[str(k)]
    ax1.plot(Ts, tvs, 'o-', color=c, label=f'k={k}', markersize=4, linewidth=1.5)

    # Support-size bound
    tv_bounds = [max(0, 1 - s/n_factorial) for s in supports]
    ax1.plot(Ts, tv_bounds, '--', color=c, alpha=0.4, linewidth=1)

    ax2.semilogy(Ts, [max(tv, 1e-4) for tv in tvs], 'o-', color=c,
                 label=f'k={k}', markersize=4, linewidth=1.5)

ax1.set_xlabel('Number of Rounds T', fontsize=12)
ax1.set_ylabel('TV Distance from Uniform', fontsize=12)
ax1.set_title('TV Distance Decay (linear scale)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0, top=1.05)
ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='TV = 0.5')

ax2.set_xlabel('Number of Rounds T', fontsize=12)
ax2.set_ylabel('TV Distance (log scale)', fontsize=12)
ax2.set_title('TV Distance Decay (log scale)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)

fig.suptitle(f'Alternating Permutation Network on S₈ (n={n}, n!={n_factorial})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tv_decay_curves.png', dpi=150, bbox_inches='tight')
print("Saved tv_decay_curves.png")
