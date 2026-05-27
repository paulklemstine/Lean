#!/usr/bin/env python3
"""
Visualization: Spectral Moment Profiles for Random Cayley Graphs

Shows how the moment kernel μ_{2k} varies across random generating pairs
in S_n for different n, compared against the free-group baseline.
This visualizes the core prediction of the Random Cayley Expander Conjecture:
moments should stay bounded and converge to free-group values.
"""

import random
import math
import itertools
import matplotlib.pyplot as plt
import numpy as np

# --- Inline all needed functions ---

def identity(n):
    return tuple(range(n))

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0]*len(p)
    for i in range(len(p)):
        inv[p[i]] = i
    return tuple(inv)

def eval_word(sigma, tau, word):
    n = len(sigma)
    gens = {0: sigma, 1: inverse(sigma), 2: tau, 3: inverse(tau)}
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result

def closed_word_count(sigma, tau, m):
    n = len(sigma)
    id_perm = identity(n)
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if eval_word(sigma, tau, list(word)) == id_perm:
            count += 1
    return count

def generates_sn(sigma, tau, n):
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    visited = {identity(n)}
    frontier = [identity(n)]
    while frontier:
        new = []
        for g in frontier:
            for s in gens:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    new.append(h)
        frontier = new
    return len(visited) == math.factorial(n)

def free_group_return_prob(k):
    from math import comb
    return comb(2*k, k) * (3**k) / (4**(2*k))

# --- Main visualization ---

random.seed(42)
num_samples = 30

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Moment Method for Random Cayley Expander Conjecture', fontsize=14, fontweight='bold')

for idx, n in enumerate([5, 6, 7]):
    ax = axes[idx]
    
    moment_data = {1: [], 2: [], 3: []}
    
    found = 0
    attempts = 0
    while found < num_samples and attempts < num_samples * 30:
        attempts += 1
        p = list(range(n))
        random.shuffle(p)
        sigma = tuple(p)
        random.shuffle(p)
        tau = tuple(p)
        if not generates_sn(sigma, tau, n):
            continue
        found += 1
        
        for k in [1, 2]:
            m = 2*k
            cwc = closed_word_count(sigma, tau, m)
            mk = cwc / (4**m)
            moment_data[k].append(mk)
    
    # Plot
    positions = [1, 2]
    labels = ['μ₂', 'μ₄']
    
    bp = ax.boxplot([moment_data[1], moment_data[2]],
                    positions=positions, widths=0.6,
                    patch_artist=True,
                    boxprops=dict(facecolor='lightblue', alpha=0.7),
                    medianprops=dict(color='red', linewidth=2))
    
    # Free-group baselines
    for k, pos in zip([1, 2], positions):
        fv = free_group_return_prob(k)
        ax.axhline(y=fv, color='green', linestyle='--', alpha=0.5)
        ax.plot(pos, fv, 'g^', markersize=10, label='Free group' if k==1 else '')
    
    ax.set_title(f'S_{n} (|G|={math.factorial(n)})', fontsize=12)
    ax.set_xticks(positions)
    ax.set_xticklabels(labels)
    ax.set_ylabel('Moment Kernel Value')
    ax.set_ylim(0, 0.5)
    ax.grid(True, alpha=0.3)
    if idx == 0:
        ax.legend(loc='upper right')

plt.tight_layout()
plt.savefig('moment_profiles.png', dpi=150, bbox_inches='tight')
print("Saved moment_profiles.png")
