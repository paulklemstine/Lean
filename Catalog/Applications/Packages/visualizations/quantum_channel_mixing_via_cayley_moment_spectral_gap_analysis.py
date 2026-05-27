"""
Visualization: Spectral Gap and Eigenvalue Distribution

Shows the eigenvalue spectrum of normalized adjacency matrices for Cayley graphs
on S₃ and S₄, highlighting the spectral gap that controls quantum mixing.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict


# --- Inline group operations ---
def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def symmetric_group(n):
    return [tuple(p) for p in permutations(range(n))]

def default_generators(n):
    sigma = list(range(n))
    sigma[0], sigma[1] = sigma[1], sigma[0]
    tau = tuple((i + 1) % n for i in range(n))
    return tuple(sigma), tau


def build_adjacency(G, gens):
    n_g = len(G)
    g_to_idx = {g: i for i, g in enumerate(G)}
    weight = 1.0 / len(gens)
    A = np.zeros((n_g, n_g))
    for i, g in enumerate(G):
        for s in gens:
            sg = compose_perm(s, g)
            j = g_to_idx[sg]
            A[j, i] += weight
    return A


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for col, n in enumerate([3, 4]):
    G = symmetric_group(n)
    sigma, tau = default_generators(n)
    gens = [sigma, inverse_perm(sigma), tau, inverse_perm(tau)]
    A = build_adjacency(G, gens)
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    gap = 1 - max(abs(eigs[1]), abs(eigs[-1]))

    # Top: eigenvalue bar chart
    ax = axes[0, col]
    colors = ['red' if i == 0 else ('orange' if abs(e) == max(abs(eigs[1]), abs(eigs[-1]))
              else 'steelblue') for i, e in enumerate(eigs)]
    ax.bar(range(len(eigs)), eigs, color=colors, edgecolor='black', linewidth=0.5)
    ax.axhline(y=1-gap, color='green', linestyle='--', linewidth=2,
               label=f'1-λ = {1-gap:.3f}')
    ax.axhline(y=-(1-gap), color='green', linestyle='--', linewidth=2)
    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('Eigenvalue', fontsize=12)
    ax.set_title(f'Spectrum of Cayley Graph on S_{n}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    # Bottom: centered purity decay (log scale)
    ax = axes[1, col]
    max_k = 15 if n == 3 else 10
    ks = list(range(1, max_k + 1))
    group_size = len(G)

    centered_purities = []
    for k in ks:
        dist = defaultdict(float)
        dist[tuple(range(n))] = 1.0
        weight = 0.25
        for _ in range(k):
            new_dist = defaultdict(float)
            for x, px in dist.items():
                if px == 0: continue
                for g in gens:
                    new_dist[compose_perm(g, x)] += weight * px
            dist = new_dist
        pur = sum(p**2 for p in dist.values())
        centered_purities.append(pur - 1.0/group_size)

    envelope = [(1 - 1.0/group_size) * (1 - gap)**(2*k) for k in ks]

    ax.semilogy(ks, centered_purities, 'bo-', markersize=6, label='Centered purity', linewidth=2)
    ax.semilogy(ks, envelope, 'g--', linewidth=2,
                label=f'(1-λ)^{{2k}} envelope, λ={gap:.3f}')
    ax.set_xlabel('Steps k', fontsize=12)
    ax.set_ylabel('Centered Purity (log scale)', fontsize=12)
    ax.set_title(f'Exponential Purity Decay on S_{n}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

fig.suptitle('Spectral Gap Controls Quantum Channel Mixing',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap.png")
