"""
Visualization 1: Cross-Prime Synchronization Heatmap

Visualizes the pairwise synchronization index between orbit structures
of the quadratic map x -> x^2 + c modulo different primes. Each cell (i,j)
shows the synchronization index between primes p_i and p_j for a given
parameter c. Exceptional parameters (c=0, -1) show distinct patterns
compared to generic parameters (c=3, 7).
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from math import sqrt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(n)) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def orbit_signature(f, domain):
    visited = set()
    cycle_lengths = []
    tree_size = 0
    for start in domain:
        if start in visited:
            continue
        path = []
        seen = {}
        x = start
        step = 0
        while x not in seen and x not in visited:
            seen[x] = step
            path.append(x)
            x = f(x)
            step += 1
        if x in visited:
            for pt in path:
                visited.add(pt)
                tree_size += 1
        else:
            cycle_start = seen[x]
            period = step - cycle_start
            cycle_lengths.append(period)
            for i, pt in enumerate(path):
                visited.add(pt)
                if i < cycle_start:
                    tree_size += 1
    return sorted(cycle_lengths), tree_size


def sync_index(sig1, sig2):
    c1, _ = sig1
    c2, _ = sig2
    if not c1 or not c2:
        return 0.0
    counter1 = Counter(c1)
    counter2 = Counter(c2)
    common = sum((counter1 & counter2).values())
    return common / max(len(c1), len(c2))


# Setup
primes = [p for p in sieve_primes(60) if p > 2][:12]
c_values = [0, -1, 3, 7]
titles = ['c = 0 (Exceptional)', 'c = -1 (Exceptional)',
          'c = 3 (Generic)', 'c = 7 (Generic)']

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Cross-Prime Synchronization Matrices\nfor Quadratic Maps x → x² + c',
             fontsize=16, fontweight='bold')

for idx, (c, title) in enumerate(zip(c_values, titles)):
    ax = axes[idx // 2][idx % 2]
    
    sigs = {}
    for p in primes:
        f = lambda x, p=p, c=c: (x * x + c) % p
        sigs[p] = orbit_signature(f, list(range(p)))
    
    n = len(primes)
    matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                matrix[i][j] = 1.0
            else:
                matrix[i][j] = sync_index(sigs[primes[i]], sigs[primes[j]])
    
    im = ax.imshow(matrix, cmap='YlOrRd', vmin=0, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(primes, fontsize=8, rotation=45)
    ax.set_yticklabels(primes, fontsize=8)
    ax.set_xlabel('Prime p', fontsize=10)
    ax.set_ylabel('Prime q', fontsize=10)
    ax.set_title(title, fontsize=12, fontweight='bold')
    
    mean = np.mean(matrix[np.triu_indices(n, k=1)])
    ax.text(0.02, 0.98, f'Mean sync: {mean:.3f}',
            transform=ax.transAxes, fontsize=10,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

fig.colorbar(im, ax=axes, shrink=0.6, label='Synchronization Index')
plt.tight_layout()
plt.savefig('sync_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved sync_heatmap.png")
