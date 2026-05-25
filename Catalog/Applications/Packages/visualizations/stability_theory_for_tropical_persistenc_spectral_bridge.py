"""
Visualization: Spectral Bridge — From Graph Laplacian to Tropical Stability

Demonstrates the cross-domain bridge between spectral graph theory and
tropical persistence. The graph Laplacian operator norm bounds the maximum
degree, which in turn controls the tropical barcode stability constant.

Shows:
- Left: Degree distribution and Laplacian eigenvalues for various graphs
- Right: Stability constant comparison (degree-based vs spectral-based)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Dict, List, Tuple
from dataclasses import dataclass


@dataclass
class SimpleGraph:
    n: int
    adj: Dict[int, List[int]]

    def degree(self, v: int) -> int:
        return len(self.adj.get(v, []))

    def max_degree(self) -> int:
        return max((self.degree(v) for v in range(self.n)), default=0)

    def degrees(self) -> np.ndarray:
        return np.array([self.degree(v) for v in range(self.n)])

    def laplacian_matrix(self) -> np.ndarray:
        L = np.zeros((self.n, self.n))
        for v in range(self.n):
            for w in self.adj.get(v, []):
                L[v, w] = -1
            L[v, v] = self.degree(v)
        return L

    @classmethod
    def from_edges(cls, n: int, edges: List[Tuple[int, int]]) -> 'SimpleGraph':
        adj = {i: [] for i in range(n)}
        for u, v in edges:
            if u != v:
                if v not in adj[u]:
                    adj[u].append(v)
                if u not in adj[v]:
                    adj[v].append(u)
        return cls(n=n, adj=adj)

    @classmethod
    def erdos_renyi(cls, n, p, rng=None):
        if rng is None:
            rng = np.random.default_rng()
        edges = [(i, j) for i in range(n) for j in range(i+1, n) if rng.random() < p]
        return cls.from_edges(n, edges)

    @classmethod
    def cycle(cls, n):
        return cls.from_edges(n, [(i, (i+1)%n) for i in range(n)])

    @classmethod
    def star(cls, n):
        return cls.from_edges(n, [(0, i) for i in range(1, n)])

    @classmethod
    def path(cls, n):
        return cls.from_edges(n, [(i, i+1) for i in range(n-1)])


rng = np.random.default_rng(42)
n = 30

graphs = {
    'Path': SimpleGraph.path(n),
    'Cycle': SimpleGraph.cycle(n),
    'Star': SimpleGraph.star(n),
    'G(n,0.15)': SimpleGraph.erdos_renyi(n, 0.15, rng),
    'G(n,0.3)': SimpleGraph.erdos_renyi(n, 0.3, rng),
    'G(n,0.6)': SimpleGraph.erdos_renyi(n, 0.6, rng),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Max eigenvalue vs 2*max_degree
ax = axes[0, 0]
names = []
laplacian_norms = []
two_max_degrees = []
for name, G in graphs.items():
    L = G.laplacian_matrix()
    evals = np.linalg.eigvalsh(L)
    max_eval = float(np.max(evals))
    two_D = 2 * G.max_degree()
    names.append(name)
    laplacian_norms.append(max_eval)
    two_max_degrees.append(two_D)

x = np.arange(len(names))
width = 0.35
bars1 = ax.bar(x - width/2, laplacian_norms, width, color='#1565C0', label='λ_max(L)')
bars2 = ax.bar(x + width/2, two_max_degrees, width, color='#E65100', label='2·max_degree', alpha=0.7)
ax.set_xticks(x)
ax.set_xticklabels(names, rotation=30, ha='right', fontsize=10)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Spectral vs. Degree Bound\nλ_max(L) ≤ 2·max_degree', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Stability constants comparison
ax = axes[0, 1]
degree_constants = [G.max_degree() + 1 for G in graphs.values()]
spectral_constants = [np.max(np.linalg.eigvalsh(G.laplacian_matrix()))/2 + 1
                      for G in graphs.values()]
bars1 = ax.bar(x - width/2, degree_constants, width, color='#2E7D32',
               label='D+1 (degree bound)')
bars2 = ax.bar(x + width/2, spectral_constants, width, color='#6A1B9A',
               label='λ_max/2+1 (spectral)', alpha=0.7)
ax.set_xticks(x)
ax.set_xticklabels(names, rotation=30, ha='right', fontsize=10)
ax.set_ylabel('Stability Constant C', fontsize=12)
ax.set_title('Stability Constants: d_T ≤ C·ε\n(degree vs spectral)', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, axis='y')

# Panel 3: Degree distributions
ax = axes[1, 0]
colors = plt.cm.Set2(np.linspace(0, 1, len(graphs)))
for (name, G), color in zip(graphs.items(), colors):
    degs = G.degrees()
    vals, counts = np.unique(degs, return_counts=True)
    ax.scatter(vals, counts, color=color, s=60, label=name, zorder=3, alpha=0.8)
    ax.plot(vals, counts, color=color, alpha=0.4)
ax.set_xlabel('Degree', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Degree Distributions', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 4: Laplacian spectrum
ax = axes[1, 1]
for (name, G), color in zip(graphs.items(), colors):
    L = G.laplacian_matrix()
    evals = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(evals)), evals, 'o-', color=color, markersize=3,
            label=name, alpha=0.8)
ax.set_xlabel('Index', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Laplacian Spectra\n(max eigenvalue controls stability)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_bridge.png', dpi=150, bbox_inches='tight')
print("Saved spectral_bridge.png")
