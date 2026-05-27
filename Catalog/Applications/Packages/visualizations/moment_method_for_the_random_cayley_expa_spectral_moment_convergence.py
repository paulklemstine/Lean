#!/usr/bin/env python3
"""
Visualization 1: Spectral Moment Convergence to Free-Group Values

Visualizes the key prediction of the Random Cayley Expander Conjecture:
as n grows, the empirical spectral moments of random Cayley graphs on S_n
converge to the free-group F_2 return probabilities.

Each panel shows the distribution of moment kernels for random generating
pairs, compared against the free-group benchmark (red dashed line).
"""

import itertools
import random
from math import factorial, comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ─── Self-contained utilities ───

def compose(p, q):
    return [p[q[i]] for i in range(len(p))]

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return inv

def identity(n):
    return list(range(n))

def random_perm(n):
    p = list(range(n))
    random.shuffle(p)
    return p

def eval_word(sigma, tau, word):
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result

def closed_word_count(sigma, tau, m):
    n = len(sigma)
    id_perm = identity(n)
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if eval_word(sigma, tau, word) == id_perm:
            count += 1
    return count

def moment_kernel(sigma, tau, m):
    return closed_word_count(sigma, tau, m) / (4 ** m)

def generates_sn(sigma, tau, n):
    visited = set()
    id_perm = tuple(range(n))
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    queue = [id_perm]
    visited.add(id_perm)
    while queue:
        current = queue.pop(0)
        for g in gens:
            nxt = tuple(compose(g, list(current)))
            if nxt not in visited:
                visited.add(nxt)
                queue.append(nxt)
    return len(visited) == factorial(n)

def free_group_return_prob(two_k):
    if two_k % 2 != 0:
        return 0.0
    k = two_k // 2
    if k == 0:
        return 1.0
    catalan = comb(2 * k, k) // (k + 1)
    return catalan * (3 ** k) / (4 ** two_k)

# ─── Data collection ───

random.seed(42)
n_values = [3, 4, 5, 6]
k_values = [1, 2, 3]
num_samples = 40

data = {n: {k: [] for k in k_values} for n in n_values}

for n in n_values:
    found = 0
    attempts = 0
    while found < num_samples and attempts < num_samples * 30:
        attempts += 1
        sigma = random_perm(n)
        tau = random_perm(n)
        if not generates_sn(sigma, tau, n):
            continue
        found += 1
        for k in k_values:
            mk = moment_kernel(sigma, tau, 2 * k)
            data[n][k].append(mk)

# ─── Plotting ───

fig, axes = plt.subplots(len(k_values), 1, figsize=(10, 10), sharex=False)
fig.suptitle('Spectral Moment Convergence to Free-Group Values\n'
             'Random Cayley Expander Conjecture', fontsize=14, fontweight='bold')

colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']

for ki, k in enumerate(k_values):
    ax = axes[ki]
    fp = free_group_return_prob(2 * k)
    
    positions = []
    box_data = []
    
    for ni, n in enumerate(n_values):
        vals = data[n][k]
        if vals:
            positions.append(ni)
            box_data.append(vals)
    
    bp = ax.boxplot(box_data, positions=positions, widths=0.6,
                     patch_artist=True, showfliers=True)
    
    for patch, color in zip(bp['boxes'], colors[:len(positions)]):
        patch.set_facecolor(color)
        patch.set_alpha(0.6)
    
    ax.axhline(y=fp, color='red', linestyle='--', linewidth=2, 
               label=f'F₂ benchmark = {fp:.4f}')
    
    ax.set_xticks(range(len(n_values)))
    ax.set_xticklabels([f'S_{n}' for n in n_values])
    ax.set_ylabel(f'μ_{{{2*k}}} (moment kernel)')
    ax.set_title(f'2k = {2*k}: Return probability at step {2*k}')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('visualize_moments.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_moments.png")
