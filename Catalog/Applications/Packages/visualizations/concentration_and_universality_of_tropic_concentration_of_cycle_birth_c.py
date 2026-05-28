"""
Visualization: Concentration of Cycle-Birth Distributions

Illustrates how empirical cycle-birth CDFs concentrate as graph size n grows.
Multiple independent trials of G(n,p) with uniform edge weights produce
empirical CDFs that cluster more tightly for larger n, demonstrating
the concentration phenomenon predicted by the McDiarmid/Azuma bound
(Theorem 3).

This is the visual analogue of the tropical spectral law: just as
the eigenvalue distribution of a random matrix concentrates to the
semicircle law, the cycle-birth distribution concentrates to a
deterministic tropical spectral measure.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# Self-contained implementations
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
    return births


def sample_gnp(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    return edges


# Parameters
p = 0.15
sizes = [30, 100, 300]
num_trials = 15
rng = np.random.default_rng(2025)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['#2196F3', '#FF9800', '#4CAF50']

for idx, n in enumerate(sizes):
    ax = axes[idx]
    for trial in range(num_trials):
        edges = sample_gnp(n, p, rng)
        births = compute_births(n, edges)
        if births:
            sorted_b = np.sort(births)
            cdf_y = np.arange(1, len(sorted_b) + 1) / len(sorted_b)
            ax.step(sorted_b, cdf_y, alpha=0.4, linewidth=1.2,
                    color=colors[idx])

    ax.set_title(f'n = {n}', fontsize=14, fontweight='bold')
    ax.set_xlabel('Edge Weight', fontsize=11)
    ax.set_ylabel('Empirical CDF', fontsize=11)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Add concentration annotation
    ax.text(0.05, 0.92, f'{num_trials} trials', transform=ax.transAxes,
            fontsize=9, color='gray')

fig.suptitle('Concentration of Cycle-Birth CDFs as n → ∞\n'
             'G(n, 0.15) with Uniform[0,1] edge weights',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('concentration_plot.png', dpi=150, bbox_inches='tight')
print("Saved concentration_plot.png")
