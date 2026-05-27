#!/usr/bin/env python3
"""
Visualization: Moment Kernel Heatmap across Generator Pairs

Creates a heatmap showing how the moment kernel (return probability)
varies across different generating pairs in S_n. Each cell represents
a specific pair of generators, colored by their m=4 spectral moment.

This visualizes the central prediction: most generating pairs should
give moments close to the free-group baseline (the "blue" region),
with only degenerate pairs showing elevated moments (the "red" region).
"""

import itertools
import random
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ──── Self-contained functions ────

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

def perm_to_str(p):
    """Convert permutation to cycle notation string."""
    n = len(p)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if visited[i] or p[i] == i:
            visited[i] = True
            continue
        cycle = []
        j = i
        while not visited[j]:
            visited[j] = True
            cycle.append(str(j))
            j = p[j]
        if len(cycle) > 1:
            cycles.append("(" + "".join(cycle) + ")")
    return "".join(cycles) if cycles else "e"

# ──── Main visualization ────

random.seed(123)

n = 4
# Generate a diverse set of permutations
all_perms = [list(p) for p in itertools.permutations(range(n))]
# Select a subset of interesting permutations
selected = []
seen_types = set()
for p in all_perms:
    if is_identity(p):
        continue
    # Classify by cycle type
    visited = [False] * n
    cycle_lengths = []
    for i in range(n):
        if not visited[i]:
            length = 0
            j = i
            while not visited[j]:
                visited[j] = True
                length += 1
                j = p[j]
            cycle_lengths.append(length)
    cycle_type = tuple(sorted(cycle_lengths, reverse=True))
    if cycle_type not in seen_types or len(selected) < 8:
        seen_types.add(cycle_type)
        selected.append(p)
    if len(selected) >= 8:
        break

# Compute moment kernel matrix
grid_size = len(selected)
moment_grid = np.zeros((grid_size, grid_size))

for i, sigma in enumerate(selected):
    for j, tau in enumerate(selected):
        moment_grid[i][j] = moment_kernel(sigma, tau, n, 4)

# Plot
fig, ax = plt.subplots(figsize=(10, 8))

labels = [perm_to_str(p) for p in selected]
im = ax.imshow(moment_grid, cmap='RdYlBu_r', aspect='auto',
               vmin=7/64, vmax=0.5)

ax.set_xticks(range(grid_size))
ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
ax.set_yticks(range(grid_size))
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Generator τ', fontsize=12)
ax.set_ylabel('Generator σ', fontsize=12)
ax.set_title(f'Moment Kernel μ₄(σ,τ) for S₄\n'
             f'Free-group baseline: {7/64:.4f}',
             fontsize=14, fontweight='bold')

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Return probability at m=4', fontsize=11)

# Add text annotations for values
for i in range(grid_size):
    for j in range(grid_size):
        val = moment_grid[i][j]
        color = 'white' if val > 0.3 else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                fontsize=7, color=color)

plt.tight_layout()
plt.savefig('moment_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: moment_heatmap.png")
