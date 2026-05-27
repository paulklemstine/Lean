#!/usr/bin/env python3
"""
Visualization: Moment Kernel Heatmap across S_n

Shows how the moment kernel μ_m varies for different generating pairs
and word lengths, revealing the spectral fingerprint of random Cayley graphs.
The heatmap displays moment kernel values for multiple random generating
pairs in S_5, illustrating the boundedness predicted by the conjecture.
"""

import random
import math
import itertools
import matplotlib.pyplot as plt
import numpy as np

# --- Inline functions ---

def identity(n): return tuple(range(n))
def compose(p, q): return tuple(p[q[i]] for i in range(len(p)))
def inverse(p):
    inv = [0]*len(p)
    for i in range(len(p)): inv[p[i]] = i
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

# --- Computation ---

random.seed(42)
n = 5
num_pairs = 15
max_m = 6

# Collect generating pairs
pairs = []
attempts = 0
while len(pairs) < num_pairs and attempts < 500:
    attempts += 1
    p = list(range(n))
    random.shuffle(p)
    sigma = tuple(p)
    random.shuffle(p)
    tau = tuple(p)
    if generates_sn(sigma, tau, n):
        pairs.append((sigma, tau))

# Compute moment kernels
data = np.zeros((num_pairs, max_m))
for i, (sigma, tau) in enumerate(pairs):
    for m in range(1, max_m + 1):
        cwc = closed_word_count(sigma, tau, m)
        data[i, m-1] = cwc / (4**m)

# --- Plot ---
fig, ax = plt.subplots(figsize=(10, 8))

im = ax.imshow(data, aspect='auto', cmap='YlOrRd', vmin=0, vmax=0.5)
ax.set_xlabel('Word length m', fontsize=12)
ax.set_ylabel('Generating pair index', fontsize=12)
ax.set_title(f'Moment Kernel Heatmap: S_{n} ({num_pairs} random generating pairs)', 
             fontsize=14, fontweight='bold')
ax.set_xticks(range(max_m))
ax.set_xticklabels(range(1, max_m+1))
ax.set_yticks(range(num_pairs))
ax.set_yticklabels(range(1, num_pairs+1))

# Add colorbar
cbar = plt.colorbar(im, ax=ax, label='Moment Kernel μ_m')

# Add text annotations
for i in range(num_pairs):
    for j in range(max_m):
        val = data[i, j]
        color = 'white' if val > 0.3 else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center', 
                fontsize=7, color=color)

plt.tight_layout()
plt.savefig('moment_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved moment_heatmap.png")
