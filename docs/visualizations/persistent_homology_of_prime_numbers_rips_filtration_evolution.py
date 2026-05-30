#!/usr/bin/env python3
"""
Visualization 2: Rips Filtration on the Prime Point Cloud

Shows how connected components evolve as the scale parameter ε increases.
The Betti number β₀(ε) tracks the number of components. This visualizes
the filtration monotonicity theorem (epsChain_monotone) and the
completeness theorem (rips_connected_at_N).

What this visualizes: The topology of the prime point cloud changing with
scale, demonstrating the fundamental filtration monotonicity.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


class UnionFind:
    def __init__(self, elements):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}
        self.n_components = len(elements)

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.n_components -= 1
        return True

    def components(self):
        comps = defaultdict(list)
        for x in self.parent:
            comps[self.find(x)].append(x)
        return list(comps.values())


def main():
    N = 100
    primes = sieve_primes(N)

    fig, axes = plt.subplots(2, 2, figsize=(16, 12))

    # Compute Betti curve
    gaps = sorted(set(primes[i + 1] - primes[i] for i in range(len(primes) - 1)))
    edges_by_gap = defaultdict(list)
    for i in range(len(primes) - 1):
        g = primes[i + 1] - primes[i]
        edges_by_gap[g].append((primes[i], primes[i + 1]))

    betti_eps = [0]
    betti_val = [len(primes)]
    uf_global = UnionFind(primes)

    for gap in gaps:
        for p, q in edges_by_gap[gap]:
            uf_global.union(p, q)
        betti_eps.append(gap)
        betti_val.append(uf_global.n_components)

    # --- Top left: Betti curve ---
    ax = axes[0][0]
    ax.step(betti_eps, betti_val, where='post', color='#2c3e50', linewidth=2.5)
    ax.fill_between(betti_eps, betti_val, step='post', alpha=0.15, color='#3498db')
    ax.set_xlabel('Scale parameter ε', fontsize=12)
    ax.set_ylabel('β₀(ε) = # Components', fontsize=12)
    ax.set_title('Betti Number Function β₀(ε)\nMonotone Decreasing (epsChain_monotone)',
                 fontsize=13, fontweight='bold')
    ax.axhline(y=1, color='#e74c3c', linestyle='--', alpha=0.5, label='Fully connected')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # --- Top right: Point cloud at different scales ---
    ax = axes[0][1]
    epsilon_values = [1, 2, 6, 14]
    y_offsets = [3, 2, 1, 0]

    for eps_val, y_off in zip(epsilon_values, y_offsets):
        uf = UnionFind(primes)
        for i in range(len(primes) - 1):
            if primes[i + 1] - primes[i] <= eps_val:
                uf.union(primes[i], primes[i + 1])

        comps = uf.components()
        comp_colors = plt.cm.Set3(np.linspace(0, 1, max(len(comps), 1)))

        for idx, comp in enumerate(comps):
            color = comp_colors[idx % len(comp_colors)]
            ax.scatter(comp, [y_off] * len(comp), c=[color], s=30,
                      edgecolors='black', linewidths=0.3, zorder=5)
            if len(comp) > 1:
                ax.plot([min(comp), max(comp)], [y_off, y_off],
                       color=color, alpha=0.5, linewidth=2)

    ax.set_yticks(y_offsets)
    ax.set_yticklabels([f'ε={e}' for e in epsilon_values])
    ax.set_xlabel('Prime Value', fontsize=12)
    ax.set_title('Connected Components at Different Scales\n'
                 'Colors show clusters', fontsize=13, fontweight='bold')

    # --- Bottom left: Bertrand ratio plot ---
    ax = axes[1][0]
    N_large = 10000
    primes_large = sieve_primes(N_large)
    ratios = [(primes_large[i + 1] - primes_large[i]) / primes_large[i]
              for i in range(len(primes_large) - 1)]

    ax.scatter(primes_large[:-1], ratios, s=1, alpha=0.3, color='#3498db')
    ax.axhline(y=1, color='#e74c3c', linewidth=2, linestyle='--',
               label='Bertrand bound (gap/birth < 1)')

    # Running max
    running_max = []
    curr_max = 0
    for r in ratios:
        curr_max = max(curr_max, r)
        running_max.append(curr_max)
    ax.plot(primes_large[:-1], running_max, color='#e74c3c', alpha=0.7,
            linewidth=1, label='Running maximum')

    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Gap / p', fontsize=12)
    ax.set_title(f'Bertrand Bar Length Bound (N={N_large})\n'
                 'All ratios < 1 (formally verified)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.3)

    # --- Bottom right: Deaths per scale ---
    ax = axes[1][1]
    N_deaths = 1000
    primes_d = sieve_primes(N_deaths)
    gap_counts = defaultdict(int)
    for i in range(len(primes_d) - 1):
        g = primes_d[i + 1] - primes_d[i]
        gap_counts[g] += 1

    gap_vals = sorted(gap_counts.keys())
    counts = [gap_counts[g] for g in gap_vals]

    ax.bar(gap_vals, counts, color='#9b59b6', edgecolor='white', alpha=0.85)
    ax.set_xlabel('Gap Size ε (Filtration Death Scale)', fontsize=12)
    ax.set_ylabel('Number of Deaths', fontsize=12)
    ax.set_title(f'Gap-Death Correspondence (N={N_deaths})\n'
                 'Each gap = exactly one bar death', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
    print("Saved viz_filtration.png")


if __name__ == "__main__":
    main()
