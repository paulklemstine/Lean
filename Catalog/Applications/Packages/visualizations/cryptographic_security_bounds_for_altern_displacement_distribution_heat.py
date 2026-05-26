#!/usr/bin/env python3
"""
Visualization: Displacement Heatmap

Shows how the distribution of total displacement evolves with rounds T
for a fixed number of swaps k. Compares the network distribution against
the uniform distribution over S_n.

The key visual insight: shallow networks cluster near low displacement,
while uniform permutations spread across a much wider range. The
transition from concentrated to spread-out is the "mixing" process.
"""

import math
import random
import itertools
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

def total_displacement(perm):
    return sum(abs(perm[i] - i) for i in range(len(perm)))

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


random.seed(42)
n = 8
k = 2
T_values = list(range(1, 21))
num_samples = 30000

# Compute uniform displacement distribution
n_factorial = math.factorial(n)
uniform_disps = Counter()
for p in itertools.permutations(range(n)):
    uniform_disps[total_displacement(p)] += 1
max_disp = max(uniform_disps.keys())
uniform_dist = {d: c / n_factorial for d, c in uniform_disps.items()}

# Build heatmap data
disp_range = list(range(0, max_disp + 1, 2))  # Displacement is always even
heatmap = np.zeros((len(T_values), len(disp_range)))

for ti, T in enumerate(T_values):
    counts = Counter()
    for _ in range(num_samples):
        d = total_displacement(build_network(n, T, k))
        counts[d] += 1
    for di, d in enumerate(disp_range):
        heatmap[ti, di] = counts.get(d, 0) / num_samples

# Uniform distribution row
uniform_row = np.array([uniform_dist.get(d, 0) for d in disp_range])

fig, axes = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [4, 1]})

# Heatmap
ax = axes[0]
im = ax.imshow(heatmap, aspect='auto', cmap='YlOrRd', origin='lower',
               extent=[disp_range[0]-1, disp_range[-1]+1, T_values[0]-0.5, T_values[-1]+0.5])
ax.set_xlabel('Total Displacement', fontsize=12)
ax.set_ylabel('Number of Rounds T', fontsize=12)
ax.set_title(f'Displacement Distribution vs Rounds (n={n}, k={k})', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='Probability')

# Mark the uniform mean displacement
uniform_mean = sum(d * p for d, p in uniform_dist.items())
ax.axvline(x=uniform_mean, color='cyan', linestyle='--', linewidth=2, alpha=0.7,
           label=f'Uniform mean = {uniform_mean:.1f}')
ax.legend(loc='upper right', fontsize=10)

# Comparison: network vs uniform for selected T values
ax2 = axes[1]
T_compare = [2, 5, 10, 20]
colors_compare = ['#e74c3c', '#f39c12', '#3498db', '#2ecc71']
ax2.bar(disp_range, uniform_row, width=1.5, alpha=0.3, color='gray', label='Uniform')
for T_val, col in zip(T_compare, colors_compare):
    if T_val in T_values:
        ti = T_values.index(T_val)
        ax2.plot(disp_range, heatmap[ti], 'o-', color=col, markersize=3,
                 label=f'T={T_val}', linewidth=1.5)
ax2.set_xlabel('Total Displacement', fontsize=12)
ax2.set_ylabel('Probability', fontsize=12)
ax2.set_title('Network Distribution vs Uniform', fontsize=12)
ax2.legend(fontsize=9, ncol=5)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('displacement_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved displacement_heatmap.png")
