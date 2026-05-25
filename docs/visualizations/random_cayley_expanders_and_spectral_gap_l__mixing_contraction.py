#!/usr/bin/env python3
"""
Visualization 2: L² Mixing Contraction on Cayley Graphs

Shows how the L² norm of a mean-zero function decays under repeated
application of the Cayley averaging operator. The decay rate is
controlled by the spectral gap: ‖A^k f‖₂² ≤ (1-gap)^(2k) · ‖f‖₂².

This demonstrates the proven theorem that the averaging operator
is an L² contraction, and visualizes the exponential convergence
to equilibrium.

Output: Plot showing L² decay curves for different generator pairs.
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
        nf = []
        for g in frontier:
            for s in all_gens:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    nf.append(h)
        frontier = nf
    return visited

def build_matrix(sigma, tau, n):
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
    return A

def spectral_gap(A):
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    return 1.0 - eigs[1]


np.random.seed(42)
n = 5
N = factorial(n)
num_steps = 40

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# Collect several generating pairs
pairs = []
while len(pairs) < 5:
    s = random_perm(n)
    t = random_perm(n)
    if len(closure([s, t], n)) == N:
        pairs.append((s, t))

# Also include standard generators
tau = tuple((i + 1) % n for i in range(n))
sigma_list = list(range(n))
sigma_list[0], sigma_list[1] = sigma_list[1], sigma_list[0]
sigma = tuple(sigma_list)
pairs.insert(0, (sigma, tau))

colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(pairs)))

# Left plot: L² decay
for idx_p, (s, t) in enumerate(pairs):
    A = build_matrix(s, t, n)
    gap = spectral_gap(A)

    # Random mean-zero function
    f = np.random.randn(N)
    f -= np.mean(f)

    norms = [np.sum(f ** 2)]
    current = f.copy()
    for _ in range(num_steps):
        current = A @ current
        norms.append(np.sum(current ** 2))

    norms = np.array(norms) / norms[0]  # Normalize

    label = f'gap={gap:.4f}' + (' (standard)' if idx_p == 0 else '')
    ax1.semilogy(range(num_steps + 1), norms, 'o-', color=colors[idx_p],
                markersize=3, linewidth=1.5, label=label)

    # Theoretical bound
    bound = [(1 - gap) ** (2 * k) for k in range(num_steps + 1)]
    ax1.semilogy(range(num_steps + 1), bound, '--', color=colors[idx_p],
                alpha=0.4, linewidth=1)

ax1.set_xlabel('Step k', fontsize=13)
ax1.set_ylabel('‖A^k f‖₂² / ‖f‖₂²  (log scale)', fontsize=13)
ax1.set_title('L² Contraction Under Averaging', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-16, 2)

# Right plot: Total variation distance from uniform
ax2_colors = ['#E91E63', '#2196F3', '#4CAF50']

for idx_p, (s, t) in enumerate(pairs[:3]):
    A = build_matrix(s, t, n)
    gap = spectral_gap(A)

    # Start from delta at identity
    dist = np.zeros(N)
    dist[0] = 1.0  # Identity is first element
    uniform = np.ones(N) / N

    tv_dists = []
    for k in range(num_steps + 1):
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        tv_dists.append(tv)
        dist = A @ dist

    label = f'gap={gap:.4f}' + (' (standard)' if idx_p == 0 else '')
    ax2.semilogy(range(num_steps + 1), tv_dists, 'o-', color=ax2_colors[idx_p],
                markersize=3, linewidth=2, label=label)

ax2.set_xlabel('Step k', fontsize=13)
ax2.set_ylabel('Total Variation Distance (log scale)', fontsize=13)
ax2.set_title('Mixing: Convergence to Uniform', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0.01, color='gray', linestyle=':', alpha=0.5, label='TV = 0.01')

fig.suptitle(f'Spectral Gap Controls Mixing Speed (S_{n}, |S_{n}| = {N})',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mixing.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing.png")
