#!/usr/bin/env python3
"""
Visualization: Spectral Moment Landscape for Random Cayley Graphs

Visualizes how the normalized spectral moments (return probabilities)
of random 2-generator Cayley graphs on S_n compare to the free-group
baseline. This is the central prediction of the Random Cayley Expander
Conjecture: moments should concentrate near free-group values.

The plot shows:
- Empirical moment distributions for different n
- Free-group baseline values
- Convergence trends as n increases
"""

import itertools
import random
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ──── Self-contained permutation operations ────

def compose(p, q):
    return [p[q[i]] for i in range(len(p))]

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return inv

def identity(n):
    return list(range(n))

def is_identity(p):
    return all(p[i] == i for i in range(len(p)))

def random_perm(n):
    p = list(range(n))
    random.shuffle(p)
    return p

ALPHABET = [0, 1, 2, 3]

def eval_word(word, sigma, tau, n):
    sigma_inv = inverse(sigma)
    tau_inv = inverse(tau)
    gen_map = {0: sigma, 1: sigma_inv, 2: tau, 3: tau_inv}
    result = identity(n)
    for letter in word:
        result = compose(gen_map[letter], result)
    return result

def moment_kernel(sigma, tau, n, m):
    count = 0
    for word in itertools.product(ALPHABET, repeat=m):
        if is_identity(eval_word(word, sigma, tau, n)):
            count += 1
    return count / (4 ** m)

# ──── Main visualization ────

random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Free-group baselines
fg_baselines = {2: 0.25, 4: 7/64}

for idx, m in enumerate([2, 4]):
    ax = axes[idx]
    n_values = [4, 5, 6]
    num_samples = 40

    all_data = {}
    for n in n_values:
        moments = []
        for _ in range(num_samples):
            sigma = random_perm(n)
            tau = random_perm(n)
            mk = moment_kernel(sigma, tau, n, m)
            moments.append(mk)
        all_data[n] = moments

    # Box plot
    positions = range(len(n_values))
    bp = ax.boxplot([all_data[n] for n in n_values],
                    positions=positions,
                    widths=0.5,
                    patch_artist=True,
                    boxprops=dict(facecolor='lightblue', alpha=0.7),
                    medianprops=dict(color='navy', linewidth=2))

    # Free-group baseline
    ax.axhline(y=fg_baselines[m], color='red', linestyle='--',
               linewidth=2, label=f'Free group F₂ baseline')

    ax.set_xticks(positions)
    ax.set_xticklabels([f'S_{n}\n(n!={factorial(n)})' for n in n_values])
    ax.set_ylabel('Moment Kernel μ(m)', fontsize=12)
    ax.set_title(f'Spectral Moment m = {m}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Add individual points
    for i, n in enumerate(n_values):
        jitter = np.random.normal(0, 0.05, len(all_data[n]))
        ax.scatter([i + j for j in jitter], all_data[n],
                   alpha=0.3, s=20, color='navy', zorder=5)

fig.suptitle('Random Cayley Expander Conjecture: Moment Convergence',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('moment_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: moment_convergence.png")
