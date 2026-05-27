#!/usr/bin/env python3
"""
Visualization: Eigenvalue Spectrum of Random Cayley Graphs on S_n

This script computes and plots the eigenvalue distribution of the normalized
adjacency matrix of random 2-generator Cayley graphs on S_n. The key observation
is that as n grows, the eigenvalue distribution approaches that of a random
4-regular graph (the Kesten-McKay distribution for trees), which is the
spectral signature of near-optimal expansion.

Output: viz_spectrum.png
"""

import itertools
import math
import random
import numpy as np
import matplotlib.pyplot as plt


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

def build_adj_matrix(sigma, tau):
    n = len(sigma)
    elements = list(itertools.permutations(range(n)))
    elem_to_idx = {e: i for i, e in enumerate(elements)}
    N = len(elements)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for gen in gens:
            h = tuple(compose(gen, list(g)))
            j = elem_to_idx[h]
            A[i][j] += 1
    return A / 4.0  # normalized

def kesten_mckay_density(x, d=4):
    """Kesten-McKay distribution for d-regular trees (free group baseline)."""
    if abs(x) >= 1:
        return 0
    # For the normalized adjacency of a d-regular graph,
    # the Kesten-McKay law is supported on [-2√(d-1)/d, 2√(d-1)/d]
    threshold = 2 * math.sqrt(d - 1) / d
    if abs(x) >= threshold:
        return 0
    return d * math.sqrt(4 * (d - 1) - (d * x) ** 2) / (2 * math.pi * (d ** 2 - (d * x) ** 2))


# ─── Data Collection ─────────────────────────────────────────────────────

random.seed(123)
ns = [4, 5, 6]
num_samples = 5  # samples per n

all_eigenvalues = {}

for n in ns:
    all_eigenvalues[n] = []
    samples = 0
    attempts = 0
    while samples < num_samples and attempts < 200:
        attempts += 1
        sigma = list(range(n))
        tau = list(range(n))
        random.shuffle(sigma)
        random.shuffle(tau)
        if not generates_sn(sigma, tau):
            continue
        samples += 1
        A_norm = build_adj_matrix(sigma, tau)
        eigs = np.linalg.eigvalsh(A_norm)
        all_eigenvalues[n].extend(eigs.tolist())


# ─── Plotting ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, len(ns), figsize=(15, 5))
fig.suptitle('Eigenvalue Distribution of Random Cayley Graphs on $S_n$',
             fontsize=14, fontweight='bold')

colors = {4: '#e74c3c', 5: '#3498db', 6: '#2ecc71'}

for idx, n in enumerate(ns):
    ax = axes[idx]
    eigs = all_eigenvalues[n]
    
    # Remove the trivial eigenvalue 1
    nontrivial = [e for e in eigs if abs(e - 1.0) > 0.001]
    
    # Histogram of nontrivial eigenvalues
    ax.hist(nontrivial, bins=50, density=True, alpha=0.6, 
            color=colors[n], edgecolor='black', linewidth=0.5,
            label=f'Empirical ($S_{{{n}}}$)')
    
    # Kesten-McKay overlay
    x_range = np.linspace(-1, 1, 500)
    km_values = [kesten_mckay_density(x) for x in x_range]
    ax.plot(x_range, km_values, 'k--', linewidth=2, alpha=0.7,
            label='Kesten-McKay ($F_2$)')
    
    # Ramanujan bound
    ramanujan = 2 * math.sqrt(3) / 4
    ax.axvline(x=ramanujan, color='red', linestyle=':', alpha=0.5, linewidth=1.5)
    ax.axvline(x=-ramanujan, color='red', linestyle=':', alpha=0.5, linewidth=1.5,
               label=f'Ramanujan bound ±{ramanujan:.3f}')
    
    ax.set_title(f'$S_{{{n}}}$  ($|S_{{{n}}}| = {math.factorial(n)}$)', fontsize=12)
    ax.set_xlabel('Eigenvalue $\\lambda$')
    ax.set_ylabel('Density')
    ax.legend(fontsize=8)
    ax.set_xlim(-1.1, 1.1)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectrum.png")
