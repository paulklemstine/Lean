#!/usr/bin/env python3
"""
Visualization: Edge Decomposition by Gap (Theorem 1)

Shows the fundamental arithmetic-topological dictionary entry:
the edge count of the prime gap clique complex decomposes as
    E = Σ_{h ∈ S} primePairCount(h)

Each bar shows how many edges come from each gap value, directly
connecting the topological 1-skeleton to prime pair statistics.
Also compares against the Bernoulli random prediction.
"""

import math
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ── Self-contained utilities ──

def sieve(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    all_p = set(sieve(n + L))
    return sorted(p for p in all_p if n <= p <= n + L - 1)

def prime_pair_count(primes, h):
    ps = set(primes)
    return sum(1 for p in primes if p + h in ps)

# ── Compute decompositions ──

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

configs = [
    (100, 100, "Small window"),
    (1000, 200, "Medium window"),
    (10000, 300, "Large window"),
    (50000, 400, "Very large window"),
]

max_gap = 30
gaps = list(range(2, max_gap + 1, 2))

for ax, (n, L, label) in zip(axes.flat, configs):
    primes = primes_in_window(n, L)
    density = len(primes) / L
    
    # Actual pair counts
    actual_counts = [prime_pair_count(primes, h) for h in gaps]
    
    # Bernoulli prediction: p² · (L - h) for each gap
    bernoulli_counts = [density**2 * max(L - h, 0) for h in gaps]
    
    x = np.arange(len(gaps))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, actual_counts, width, color='crimson',
                   alpha=0.8, label='Actual primes')
    bars2 = ax.bar(x + width/2, bernoulli_counts, width, color='steelblue',
                   alpha=0.8, label='Bernoulli prediction')
    
    ax.set_xlabel('Gap h', fontsize=10)
    ax.set_ylabel('Pair count', fontsize=10)
    ax.set_title(f'{label}: [{n}, {n+L-1}]\n'
                 f'V={len(primes)}, E_actual={sum(actual_counts)}, '
                 f'E_bernoulli={sum(bernoulli_counts):.0f}',
                 fontsize=10)
    ax.set_xticks(x)
    ax.set_xticklabels(gaps, fontsize=8)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('Edge Count Decomposition: E = Σ primePairCount(h)\n'
             '(Theorem 1: Arithmetic-Topological Dictionary)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('edge_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved edge_decomposition.png")
