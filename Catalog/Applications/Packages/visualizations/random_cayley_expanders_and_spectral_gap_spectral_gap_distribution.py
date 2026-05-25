#!/usr/bin/env python3
"""
Visualization 1: Spectral Gap Distribution of Random Cayley Graphs of S_n

Visualizes the distribution of spectral gaps across random generating pairs
for S_5, S_6, and S_7, demonstrating the Random Cayley Expander Conjecture:
random generators typically produce Cayley graphs with a uniform spectral gap
bounded away from zero.

Output: Histogram subplots comparing gap distributions across group sizes.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def random_perm(n):
    p = list(range(n))
    np.random.shuffle(p)
    return tuple(p)

def closure(generators, n):
    e = identity(n)
    all_gens = list(generators) + [inverse(s) for s in generators]
    visited = {e}
    frontier = [e]
    while frontier:
        next_frontier = []
        for g in frontier:
            for s in all_gens:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    next_frontier.append(h)
        frontier = next_frontier
    return visited

def spectral_gap_for_pair(sigma, tau, n):
    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    d = len(gens)
    elements = sorted(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    N = len(elements)
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d
    eigs = np.linalg.eigvalsh(A)
    eigs = np.sort(eigs)[::-1]
    return 1.0 - eigs[1]

def collect_gaps(n, num_samples=50):
    gaps = []
    while len(gaps) < num_samples:
        s = random_perm(n)
        t = random_perm(n)
        if len(closure([s, t], n)) == factorial(n):
            gaps.append(spectral_gap_for_pair(s, t, n))
    return np.array(gaps)


np.random.seed(2025)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

colors = ['#2196F3', '#FF9800', '#4CAF50']
ns = [5, 6, 7]
samples = [60, 30, 10]

all_gaps = {}
for i, (n, num) in enumerate(zip(ns, samples)):
    gaps = collect_gaps(n, num)
    all_gaps[n] = gaps

    ax = axes[i]
    ax.hist(gaps, bins=15, edgecolor='white', alpha=0.85, color=colors[i],
            linewidth=1.2)
    ax.axvline(x=0.01, color='red', linestyle='--', linewidth=2,
              label='Threshold c₀ = 0.01')
    ax.set_xlabel('Spectral Gap', fontsize=13)
    ax.set_ylabel('Count', fontsize=13)
    ax.set_title(f'S_{n}  (|S_{n}| = {factorial(n)})', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(0, max(gaps) * 1.15)

    # Add statistics
    stats_text = (f'min = {gaps.min():.4f}\n'
                  f'mean = {gaps.mean():.4f}\n'
                  f'n = {num}')
    ax.text(0.97, 0.97, stats_text, transform=ax.transAxes,
            fontsize=9, verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.7))

fig.suptitle('Spectral Gaps of Random Cayley Graphs of Symmetric Groups',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_gaps.png")
