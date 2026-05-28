"""
Visualization: Growth of heterogeneity and integrality gap
in the two-scale hypergraph family.

Shows how the gap between integer and fractional transversal
numbers grows alongside edge-size heterogeneity as the
family parameter increases. Demonstrates the core
disorder-forcing mechanism.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from collections import Counter
import math


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


def two_scale_family(m):
    n = 2 * m + 1
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append(frozenset([i, j]))
    edges.append(frozenset(range(n)))
    return Hypergraph(n, edges)


def main():
    ms = list(range(2, 9))
    hets, taus, tau_stars, gaps, cis = [], [], [], [], []

    for m in ms:
        H = two_scale_family(m)
        het = H.edge_heterogeneity()
        tau = H.transversal_number_brute()
        tau_star = H.fractional_transversal_number()

        hets.append(het)
        taus.append(tau)
        tau_stars.append(tau_star)
        gaps.append(tau - tau_star)
        cis.append(H.edge_size_collision_index())

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: τ and τ* vs m
    ax = axes[0, 0]
    ax.plot(ms, taus, 'bo-', linewidth=2, markersize=8, label='τ (integer)')
    ax.plot(ms, tau_stars, 'rs-', linewidth=2, markersize=8, label='τ* (fractional)')
    ax.fill_between(ms, tau_stars, taus, alpha=0.15, color='purple')
    ax.set_xlabel('Parameter m', fontsize=12)
    ax.set_ylabel('Transversal Number', fontsize=12)
    ax.set_title('Integer vs. Fractional Transversal', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Gap vs m
    ax = axes[0, 1]
    colors = ['green' if g >= 1 else 'orange' for g in gaps]
    ax.bar(ms, gaps, color=colors, alpha=0.8, edgecolor='black')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Gap = 1')
    ax.set_xlabel('Parameter m', fontsize=12)
    ax.set_ylabel('Integrality Gap (τ − τ*)', fontsize=12)
    ax.set_title('Gap Growth with Scale', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 3: Heterogeneity vs m
    ax = axes[1, 0]
    ax.plot(ms, hets, 'k^-', linewidth=2, markersize=8, label='Heterogeneity (σ²)')
    ax.set_xlabel('Parameter m', fontsize=12)
    ax.set_ylabel('Edge Heterogeneity', fontsize=12)
    ax.set_title('Disorder Growth', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 4: Gap vs Heterogeneity (direct)
    ax = axes[1, 1]
    ax.plot(hets, gaps, 'mp-', linewidth=2, markersize=10)
    for i, m in enumerate(ms):
        ax.annotate(f'm={m}', (hets[i], gaps[i]), textcoords="offset points",
                    xytext=(8, 5), fontsize=9)
    ax.set_xlabel('Edge Heterogeneity (σ²)', fontsize=12)
    ax.set_ylabel('Integrality Gap', fontsize=12)
    ax.set_title('Disorder → Gap: The Core Mechanism', fontsize=14)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Two-Scale Family: Disorder Forces Integrality Separation',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('family_growth.png', dpi=150, bbox_inches='tight')
    print("Saved: family_growth.png")


if __name__ == "__main__":
    main()
