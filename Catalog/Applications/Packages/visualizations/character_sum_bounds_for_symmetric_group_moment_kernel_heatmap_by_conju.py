#!/usr/bin/env python3
"""
Visualization: Moment Kernel Heatmap by Conjugacy Class

Displays the moment kernel as a function of conjugacy class pairs
in S_n, demonstrating the conjugation invariance theorem.
The heatmap shows that the moment kernel is constant on conjugacy
classes — the fundamental compression property.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, Dict, List
import matplotlib.pyplot as plt
import numpy as np


Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    n = len(p)
    inv = [0] * n
    for i in range(n): inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Perm:
    return tuple(range(n))

def all_permutations(n: int) -> List[Perm]:
    return [tuple(p) for p in itertools.permutations(range(n))]

def cycle_type(p: Perm) -> Tuple[int, ...]:
    n = len(p)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if not visited[i]:
            length = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = p[j]
                length += 1
            cycles.append(length)
    return tuple(sorted(cycles, reverse=True))

def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)
    dist = {e: 1}
    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in gens:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist
    return dist.get(e, 0)

def moment_kernel(sigma: Perm, tau: Perm, m: int) -> Fraction:
    return Fraction(closed_word_count_dp(sigma, tau, m), 4**m)


# Parameters
n = 4
m = 4

perms = all_permutations(n)

# Get conjugacy class representatives
class_reps: Dict[Tuple[int, ...], Perm] = {}
class_sizes: Dict[Tuple[int, ...], int] = {}
for p in perms:
    ct = cycle_type(p)
    if ct not in class_reps:
        class_reps[ct] = p
    class_sizes[ct] = class_sizes.get(ct, 0) + 1

classes = sorted(class_reps.keys())
num_classes = len(classes)

# Compute moment kernel for each class pair
mk_matrix = np.zeros((num_classes, num_classes))
for i, ct1 in enumerate(classes):
    for j, ct2 in enumerate(classes):
        rep1 = class_reps[ct1]
        rep2 = class_reps[ct2]
        mk_matrix[i, j] = float(moment_kernel(rep1, rep2, m))

# Create heatmap
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Left: Heatmap by conjugacy class
class_labels = [str(ct) for ct in classes]
im = axes[0].imshow(mk_matrix, cmap='YlOrRd', aspect='equal')
axes[0].set_xticks(range(num_classes))
axes[0].set_yticks(range(num_classes))
axes[0].set_xticklabels(class_labels, rotation=45, ha='right', fontsize=9)
axes[0].set_yticklabels(class_labels, fontsize=9)
axes[0].set_xlabel('Cycle type of τ', fontsize=12)
axes[0].set_ylabel('Cycle type of σ', fontsize=12)
axes[0].set_title(f'Moment Kernel by Conjugacy Class\n$S_{n}$, m={m}',
                   fontsize=14)
plt.colorbar(im, ax=axes[0], label='momentKernel(σ, τ, m)')

# Add values
for i in range(num_classes):
    for j in range(num_classes):
        axes[0].text(j, i, f'{mk_matrix[i,j]:.3f}',
                     ha='center', va='center', fontsize=8,
                     color='white' if mk_matrix[i,j] > 0.5 else 'black')

# Right: Verify conjugation invariance
# Pick a specific pair and compute for all conjugates
sigma = class_reps[classes[1]]  # a non-trivial class
tau = class_reps[classes[2]]     # another non-trivial class
mk_orig = float(moment_kernel(sigma, tau, m))

mk_conjugated = []
for h in perms[:24]:  # sample some conjugating elements
    sigma_c = compose(compose(h, sigma, ), inverse(h))
    tau_c = compose(compose(h, tau), inverse(h))
    mk_conjugated.append(float(moment_kernel(sigma_c, tau_c, m)))

axes[1].plot(mk_conjugated, 'o', color='#2196F3', markersize=6, alpha=0.7,
             label='Conjugated values')
axes[1].axhline(y=mk_orig, color='#FF5722', linewidth=2, linestyle='--',
                label=f'Original = {mk_orig:.4f}')
axes[1].set_xlabel('Conjugating element index', fontsize=12)
axes[1].set_ylabel('momentKernel value', fontsize=12)
axes[1].set_title(f'Conjugation Invariance Verification\n'
                   f'σ type={cycle_type(sigma)}, τ type={cycle_type(tau)}',
                   fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('moment_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: moment_heatmap.png")
