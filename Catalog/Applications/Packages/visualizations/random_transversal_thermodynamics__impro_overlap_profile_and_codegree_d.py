"""
Visualization: Overlap Profile and Pair Codegree Distribution

Shows how the pair codegree distribution evolves with edge density.
At low density, most pairs share 0 edges (low overlap).
At high density, overlap increases, approaching the regime where
the worst-case integrality gap d could be approached.

This visualizes the pseudorandomness structure that governs
the improved rounding bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

# ── Inline needed functions ──

class Hypergraph:
    def __init__(self, n, edges):
        self.n = n
        self.edges = [frozenset(e) for e in edges]

    @staticmethod
    def random_uniform(n, m, d, rng=None):
        if rng is None:
            rng = np.random.default_rng()
        edges = []
        vertices = list(range(n))
        for _ in range(m):
            e = frozenset(rng.choice(vertices, size=d, replace=False))
            edges.append(e)
        return Hypergraph(n, edges)

    def unique_edges(self):
        return list(set(self.edges))


def compute_codegree_distribution(H):
    codeg = {}
    for e in H.unique_edges():
        for u, v in combinations(sorted(e), 2):
            codeg[(u, v)] = codeg.get((u, v), 0) + 1
    if not codeg:
        return {0: 1}
    dist = {}
    for val in codeg.values():
        dist[val] = dist.get(val, 0) + 1
    return dist


# ── Main visualization ──

def run_visualization():
    d = 3
    n = 80
    rng = np.random.default_rng(42)

    c_values = [0.5, 1.0, 2.0, 3.0, 5.0]
    num_samples = 50

    fig, axes = plt.subplots(1, len(c_values), figsize=(18, 4),
                              sharey=True)
    fig.suptitle(f'Pair Codegree Distribution (d={d}, n={n})',
                 fontsize=14, fontweight='bold')

    max_codeg_means = []
    mean_codeg_means = []

    for idx, c in enumerate(c_values):
        m = max(1, int(c * n))
        all_dists = {}
        max_codegs = []

        for _ in range(num_samples):
            H = Hypergraph.random_uniform(n, m, d, rng=rng)
            dist = compute_codegree_distribution(H)
            for k, v in dist.items():
                all_dists[k] = all_dists.get(k, 0) + v
            max_codegs.append(max(dist.keys()))

        max_codeg_means.append(np.mean(max_codegs))

        # Normalize
        total = sum(all_dists.values())
        keys = sorted(all_dists.keys())
        vals = [all_dists[k] / total for k in keys]

        ax = axes[idx]
        ax.bar(keys, vals, color=plt.cm.viridis(c / 6.0), alpha=0.8,
               edgecolor='black', linewidth=0.5)
        ax.set_xlabel('Pair codegree', fontsize=10)
        if idx == 0:
            ax.set_ylabel('Frequency', fontsize=10)
        ax.set_title(f'c = {c:.1f}\nm = {m}', fontsize=11)
        ax.set_xlim(-0.5, max(6, max(keys) + 1))
        ax.grid(True, alpha=0.3, axis='y')

        # Annotate max codegree
        ax.annotate(f'E[max] = {np.mean(max_codegs):.1f}',
                    xy=(0.95, 0.92), xycoords='axes fraction',
                    fontsize=9, ha='right',
                    bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    plt.savefig('overlap_codegree.png', dpi=150, bbox_inches='tight')
    print("Saved overlap_codegree.png")

    # Additional plot: max codegree vs c (continuous)
    fig2, ax2 = plt.subplots(figsize=(8, 5))
    c_fine = np.linspace(0.1, 6.0, 40)
    max_codegs_fine = []

    for c in c_fine:
        m = max(1, int(c * n))
        mc = []
        for _ in range(30):
            H = Hypergraph.random_uniform(n, m, d, rng=rng)
            dist = compute_codegree_distribution(H)
            mc.append(max(dist.keys()))
        max_codegs_fine.append(np.mean(mc))

    ax2.plot(c_fine, max_codegs_fine, 'b-o', markersize=3, linewidth=2)
    ax2.axhline(y=1, color='green', linestyle='--', alpha=0.7,
                label='Low overlap threshold K=1')
    ax2.set_xlabel('Edge density c', fontsize=12)
    ax2.set_ylabel('Mean max pair codegree', fontsize=12)
    ax2.set_title(f'Overlap Growth with Density (d={d}, n={n})',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('overlap_growth.png', dpi=150, bbox_inches='tight')
    print("Saved overlap_growth.png")

run_visualization()
