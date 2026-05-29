"""
Visualization 2: Rips Filtration of the Prime Point Cloud

Shows how the prime point cloud evolves under the Rips filtration:
at each scale ε, we connect primes within distance ε. This visualization
shows snapshots at different scales, revealing the topological transitions.

The key insight: primes have structure — they are NOT random, and their
gaps create a specific persistent homology signature.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Use primes up to 100 for clear visualization
primes = sieve_primes(100)
N = len(primes)

fig, axes = plt.subplots(3, 2, figsize=(16, 12))

scales = [0, 1, 2, 4, 6, 14]
titles = [
    'ε = 0: All isolated',
    'ε = 1: Only (2,3) connected',
    'ε = 2: Twin primes merge',
    'ε = 4: Most small gaps close',
    'ε = 6: Major clustering',
    'ε = 14: Fully connected'
]

for idx, (eps, title) in enumerate(zip(scales, titles)):
    ax = axes[idx // 2][idx % 2]

    # Assign components via union-find
    parent = list(range(N))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    for i in range(N - 1):
        if primes[i + 1] - primes[i] <= eps:
            union(i, i + 1)

    # Color by component
    components = {}
    for i in range(N):
        root = find(i)
        if root not in components:
            components[root] = len(components)

    n_comp = len(components)
    cmap = plt.cm.Set3
    colors = [cmap(components[find(i)] % 12 / 12) for i in range(N)]

    # Draw connections
    for i in range(N - 1):
        if primes[i + 1] - primes[i] <= eps:
            ax.plot([primes[i], primes[i+1]], [0, 0], '-', color='gray',
                    linewidth=1.5, alpha=0.5)

    # Draw points
    ax.scatter(primes, [0]*N, c=colors, s=60, zorder=5, edgecolors='black', linewidth=0.5)

    ax.set_title(f'{title} ({n_comp} components)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Prime value')
    ax.set_yticks([])
    ax.set_xlim(-2, 102)

plt.suptitle('Rips Filtration of Prime Numbers (2 to 97)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")
