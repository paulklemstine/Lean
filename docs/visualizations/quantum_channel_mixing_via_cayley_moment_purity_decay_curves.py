"""
Visualization: Purity Decay Curves for Quantum Channels on Symmetric Groups

Shows the exponential decay of purity (L² mass) for quantum channels induced
by random walks on S₃ and S₄, compared with the spectral gap decay envelope.
Demonstrates the main theorem: walkPurity(k) = momentKernel(2k).
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

def identity_perm(n):
    return tuple(range(n))

def symmetric_group(n):
    return [tuple(p) for p in permutations(range(n))]

def default_generators(n):
    sigma = list(range(n))
    sigma[0], sigma[1] = sigma[1], sigma[0]
    tau = tuple((i + 1) % n for i in range(n))
    return tuple(sigma), tau

def walk_distribution(G, gens, k):
    n = len(G[0])
    weight = 1.0 / len(gens)
    dist = defaultdict(float)
    dist[identity_perm(n)] = 1.0
    for _ in range(k):
        new_dist = defaultdict(float)
        for x, px in dist.items():
            if px == 0: continue
            for g in gens:
                new_dist[compose_perm(g, x)] += weight * px
        dist = new_dist
    return dist

def compute_purity(dist):
    return sum(p**2 for p in dist.values())

def compute_return_prob(dist, n):
    return dist.get(identity_perm(n), 0.0)

def spectral_gap(G, gens):
    n_g = len(G)
    g_to_idx = {g: i for i, g in enumerate(G)}
    weight = 1.0 / len(gens)
    A = np.zeros((n_g, n_g))
    for i, g in enumerate(G):
        for s in gens:
            sg = compose_perm(s, g)
            j = g_to_idx[sg]
            A[j, i] += weight
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    return 1 - max(abs(eigs[1]), abs(eigs[-1]))


# --- Main visualization ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, n in enumerate([3, 4]):
    ax = axes[idx]
    G = symmetric_group(n)
    sigma, tau = default_generators(n)
    gens = [sigma, inverse_perm(sigma), tau, inverse_perm(tau)]
    gap = spectral_gap(G, gens)
    group_size = len(G)
    uniform_pur = 1.0 / group_size

    max_k = 12 if n == 3 else 10
    ks = list(range(max_k + 1))
    purities = []
    return_probs = []

    for k in ks:
        dist_k = walk_distribution(G, gens, k)
        purities.append(compute_purity(dist_k))
        dist_2k = walk_distribution(G, gens, 2 * k)
        return_probs.append(compute_return_prob(dist_2k, n))

    # Decay envelope
    envelope = [uniform_pur + (1 - uniform_pur) * (1 - gap)**(2*k) for k in ks]

    ax.plot(ks, purities, 'bo-', markersize=8, label='walkPurity(k)', linewidth=2)
    ax.plot(ks, return_probs, 'rx', markersize=10, label='momentKernel(2k)',
            markeredgewidth=2)
    ax.plot(ks, envelope, 'g--', linewidth=2,
            label=f'Decay envelope (1-λ)^{{2k}}, λ={gap:.3f}')
    ax.axhline(y=uniform_pur, color='gray', linestyle=':', linewidth=1.5,
               label=f'Uniform: 1/|G| = 1/{group_size}')

    ax.set_xlabel('Steps k', fontsize=13)
    ax.set_ylabel('Purity', fontsize=13)
    ax.set_title(f'S_{n}  (|G| = {group_size})', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)

fig.suptitle('Quantum Channel Purity Decay: walkPurity(k) = momentKernel(2k)',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('purity_decay.png', dpi=150, bbox_inches='tight')
print("Saved purity_decay.png")
