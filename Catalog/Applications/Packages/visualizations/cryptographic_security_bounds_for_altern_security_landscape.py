#!/usr/bin/env python3
"""
Visualization: Security Landscape

A 2D heatmap showing TV distance from uniform as a function of both
rounds T (y-axis) and swaps per layer k (x-axis). This reveals the
"security landscape" — the region where the network is provably insecure
vs where it approaches uniformity.

Also shows contour lines for specific security thresholds (TV = 0.5, 0.1, 0.01).
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
k_values = list(range(1, 5))
T_values = list(range(1, 21))
num_samples = 20000

# Compute TV distance grid
tv_grid = np.zeros((len(T_values), len(k_values)))
support_grid = np.zeros((len(T_values), len(k_values)))

for ki, k in enumerate(k_values):
    for ti, T in enumerate(T_values):
        counts = Counter()
        for _ in range(num_samples):
            counts[build_network(n, T, k)] += 1
        tv_grid[ti, ki] = empirical_tv(counts, n_factorial, num_samples)
        support_grid[ti, ki] = len(counts)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap 1: TV distance
im1 = ax1.imshow(tv_grid, aspect='auto', cmap='RdYlGn_r', origin='lower',
                 extent=[k_values[0]-0.5, k_values[-1]+0.5,
                         T_values[0]-0.5, T_values[-1]+0.5],
                 vmin=0, vmax=1)
# Contour lines
cs = ax1.contour(np.arange(len(k_values)), np.arange(len(T_values)),
                 tv_grid, levels=[0.01, 0.1, 0.5],
                 colors=['white', 'lightgray', 'black'], linewidths=2)
ax1.clabel(cs, fmt={0.01: 'TV=0.01', 0.1: 'TV=0.1', 0.5: 'TV=0.5'},
           fontsize=10)
ax1.set_xticks(range(len(k_values)))
ax1.set_xticklabels(k_values)
ax1.set_yticks(range(0, len(T_values), 2))
ax1.set_yticklabels([T_values[i] for i in range(0, len(T_values), 2)])
ax1.set_xlabel('Swaps per Layer (k)', fontsize=12)
ax1.set_ylabel('Number of Rounds (T)', fontsize=12)
ax1.set_title('TV Distance from Uniform', fontsize=13, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='TV Distance')

# Heatmap 2: Support size (log scale)
log_support = np.log2(support_grid + 1)
im2 = ax2.imshow(log_support, aspect='auto', cmap='viridis', origin='lower',
                 extent=[k_values[0]-0.5, k_values[-1]+0.5,
                         T_values[0]-0.5, T_values[-1]+0.5])
ax2.set_xticks(range(len(k_values)))
ax2.set_xticklabels(k_values)
ax2.set_yticks(range(0, len(T_values), 2))
ax2.set_yticklabels([T_values[i] for i in range(0, len(T_values), 2)])
ax2.set_xlabel('Swaps per Layer (k)', fontsize=12)
ax2.set_ylabel('Number of Rounds (T)', fontsize=12)
ax2.set_title(f'Support Size (log₂ scale, max = log₂({n_factorial}) = {math.log2(n_factorial):.1f})',
              fontsize=13, fontweight='bold')
cbar = plt.colorbar(im2, ax=ax2, label='log₂(support size)')
ax2.axhline(y=len(T_values)-0.5, color='white', alpha=0)  # dummy for layout

fig.suptitle(f'Security Landscape: Alternating Permutation Networks on S₈',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
print("Saved security_landscape.png")
