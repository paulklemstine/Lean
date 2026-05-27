#!/usr/bin/env python3
"""
Visualization: Spectral Moments of Random Cayley Graphs vs Free Group Baseline

This script produces a publication-quality plot comparing empirical spectral
moments of random 2-generator Cayley graphs on S_n (for n=4,5,6,7) against
the free-group return probability baseline. The moment method predicts that
these moments converge to the free-group values as n → ∞, which is the
core of the Random Cayley Expander Conjecture.

Output: viz_moments.png
"""

import itertools
import math
import random
import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ─── Self-contained permutation utilities ────────────────────────────────

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
        if eval_word(sigma, tau, list(word)) == id_perm:
            count += 1
    return count

def generates_sn(sigma, tau):
    n = len(sigma)
    target = math.factorial(n)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    visited = {tuple(identity(n))}
    queue = [identity(n)]
    while queue:
        current = queue.pop(0)
        for g in gens:
            new = compose(g, current)
            t = tuple(new)
            if t not in visited:
                visited.add(t)
                queue.append(new)
                if len(visited) == target:
                    return True
    return len(visited) == target

def free_group_return_prob(k):
    return math.comb(2*k, k) * (3**k) / (4**(2*k))


# ─── Data Collection ─────────────────────────────────────────────────────

random.seed(42)
num_samples = 30
ns = [4, 5, 6, 7]
ks = [1, 2, 3]

# Collect empirical data
data = {}  # data[(n, k)] = list of moment values

for n in ns:
    for k in ks:
        data[(n, k)] = []
    
    samples = 0
    attempts = 0
    while samples < num_samples and attempts < num_samples * 30:
        attempts += 1
        sigma = list(range(n))
        tau = list(range(n))
        random.shuffle(sigma)
        random.shuffle(tau)
        
        if not generates_sn(sigma, tau):
            continue
        
        samples += 1
        for k in ks:
            m = 2 * k
            cwc = closed_word_count(sigma, tau, m)
            mk = cwc / (4 ** m)
            data[(n, k)].append(mk)


# ─── Plotting ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(14, 5))
fig.suptitle('Spectral Moments of Random Cayley Graphs on $S_n$\nvs Free Group Baseline',
             fontsize=14, fontweight='bold', y=1.02)

colors = {4: '#e74c3c', 5: '#3498db', 6: '#2ecc71', 7: '#9b59b6'}
markers = {4: 'o', 5: 's', 6: '^', 7: 'D'}

for idx, k in enumerate(ks):
    ax = axes[idx]
    m = 2 * k
    
    # Free group baseline
    baseline = free_group_return_prob(k)
    
    # Box plot data
    bp_data = []
    bp_positions = []
    bp_colors = []
    
    for i, n in enumerate(ns):
        values = data[(n, k)]
        if values:
            bp_data.append(values)
            bp_positions.append(i)
            bp_colors.append(colors[n])
    
    # Draw box plots
    bp = ax.boxplot(bp_data, positions=bp_positions, widths=0.6, 
                     patch_artist=True, showfliers=True,
                     flierprops=dict(marker='x', markersize=4, alpha=0.5))
    
    for patch, color in zip(bp['boxes'], bp_colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.3)
    
    # Overlay individual points
    for i, n in enumerate(ns):
        values = data[(n, k)]
        if values:
            jitter = np.random.normal(0, 0.08, len(values))
            ax.scatter([i] * len(values) + jitter, values, 
                      c=colors[n], marker=markers[n], s=20, alpha=0.6,
                      label=f'$S_{{{n}}}$' if idx == 0 else '', zorder=5)
    
    # Baseline line
    ax.axhline(y=baseline, color='black', linestyle='--', linewidth=1.5, 
               alpha=0.7, label=f'$F_2$ baseline' if idx == 0 else '')
    
    ax.set_title(f'$k = {k}$  ($m = {m}$)', fontsize=12)
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels([f'$S_{{{n}}}$' for n in ns])
    ax.set_ylabel(f'$\\mu^{{({m})}}(e) = $ closedWordCount$/4^{{{m}}}$')
    ax.set_xlabel('Group')
    ax.grid(True, alpha=0.3)

# Legend
handles, labels = axes[0].get_legend_handles_labels()
fig.legend(handles, labels, loc='upper right', bbox_to_anchor=(0.98, 0.98),
           framealpha=0.9, fontsize=10)

plt.tight_layout()
plt.savefig('viz_moments.png', dpi=150, bbox_inches='tight')
print("Saved viz_moments.png")
