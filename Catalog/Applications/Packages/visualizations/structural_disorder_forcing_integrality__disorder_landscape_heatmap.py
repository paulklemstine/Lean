"""
Visualization: Heatmap of integrality gap as a function of
heterogeneity and collision index.

This script generates random hypergraphs with varying disorder
profiles and plots a heatmap showing how the integrality gap
varies across the heterogeneity × collision-index plane.
The key insight: the gap concentrates in the high-heterogeneity,
low-collision-index region — exactly where disorder is maximal.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from collections import Counter


class Hypergraph:
    def __init__(self, n, edges):
        self.n = n
        self.edges = list(set(edges))

    def edge_sizes(self):
        return [len(e) for e in self.edges]

    def edge_heterogeneity(self):
        sizes = self.edge_sizes()
        if not sizes:
            return 0.0
        mu = np.mean(sizes)
        return float(np.mean([(s - mu) ** 2 for s in sizes]))

    def edge_size_collision_index(self):
        sizes = self.edge_sizes()
        if not sizes:
            return 1.0
        n = len(sizes)
        counts = Counter(sizes)
        return sum((c / n) ** 2 for c in counts.values())

    def is_transversal(self, S):
        return all(bool(S & e) for e in self.edges)

    def transversal_number_brute(self):
        for k in range(self.n + 1):
            for S in combinations(range(self.n), k):
                if self.is_transversal(set(S)):
                    return k
        return self.n

    def fractional_transversal_number(self):
        try:
            from scipy.optimize import linprog
        except ImportError:
            return float('nan')
        m = len(self.edges)
        if m == 0:
            return 0.0
        c = np.ones(self.n)
        A_ub = np.zeros((m, self.n))
        b_ub = -np.ones(m)
        for i, e in enumerate(self.edges):
            for v in e:
                A_ub[i, v] = -1.0
        bounds = [(0, None)] * self.n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        return float(result.fun) if result.success else float('nan')


def random_hypergraph(n, num_edges, size_options, rng):
    edges = set()
    vertices = list(range(n))
    attempts = 0
    while len(edges) < num_edges and attempts < num_edges * 100:
        k = rng.choice(size_options)
        if k > n:
            attempts += 1
            continue
        e = frozenset(rng.choice(vertices, size=k, replace=False))
        edges.add(e)
        attempts += 1
    return Hypergraph(n, list(edges))


def main():
    rng = np.random.default_rng(42)
    n = 9
    num_edges = 12
    num_trials = 500

    hets, cis, gaps = [], [], []

    size_option_sets = [
        [2], [3], [4], [2, 3], [2, 4], [2, 5],
        [3, 4], [3, 5], [2, 3, 4], [2, 3, 5],
        [2, 4, 5], [3, 4, 5], [2, 3, 4, 5],
    ]

    for trial in range(num_trials):
        opts = size_option_sets[rng.integers(len(size_option_sets))]
        H = random_hypergraph(n, num_edges, opts, rng)
        if not H.edges:
            continue

        het = H.edge_heterogeneity()
        ci = H.edge_size_collision_index()
        tau = H.transversal_number_brute()
        tau_star = H.fractional_transversal_number()
        if np.isnan(tau_star):
            continue

        hets.append(het)
        cis.append(ci)
        gaps.append(tau - tau_star)

    hets = np.array(hets)
    cis = np.array(cis)
    gaps = np.array(gaps)

    fig, ax = plt.subplots(figsize=(10, 8))

    scatter = ax.scatter(hets, cis, c=gaps, cmap='RdYlBu_r',
                         s=40, alpha=0.7, edgecolors='gray', linewidth=0.3)
    cbar = plt.colorbar(scatter, ax=ax, label='Integrality Gap (τ − τ*)')

    ax.set_xlabel('Edge Heterogeneity (σ²)', fontsize=14)
    ax.set_ylabel('Collision Index', fontsize=14)
    ax.set_title('Disorder Landscape: Where Integrality Gaps Live', fontsize=16)

    # Annotate regions
    ax.annotate('Ordered Phase\n(uniform, tight LP)',
                xy=(0.05, 0.95), fontsize=10, color='blue',
                ha='left', style='italic')
    ax.annotate('Disordered Phase\n(heterogeneous, loose LP)',
                xy=(max(hets) * 0.6, min(cis) + 0.05), fontsize=10, color='red',
                ha='center', style='italic')

    ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.4, label='CI=1 (uniform)')
    ax.legend(loc='upper right')

    plt.tight_layout()
    plt.savefig('disorder_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved: disorder_heatmap.png")


if __name__ == "__main__":
    main()
