"""
Visualization: Kernel Column Profiles — Tropical Potential Landscapes

Plots the kernel columns g(p, ·) for various source vertices p on
different graph types. Each column is a "potential landscape" — the
voltage induced by placing a unit charge at p.

Key features visible:
- Symmetry: g(p,q) = g(q,p) means the landscape at p evaluated at q
  equals the landscape at q evaluated at p
- Mean-zero: each landscape integrates to zero
- Diagonal dominance: g(p,p) > g(p,q) for p ≠ q on connected graphs
"""

import numpy as np
import matplotlib.pyplot as plt


class WeightedGraph:
    """Inline implementation for self-contained visualization."""
    def __init__(self, n, edges):
        self.n = n
        self.edges = edges
        L = np.zeros((n, n))
        for u, v, w in edges:
            L[u, v] -= w; L[v, u] -= w
            L[u, u] += w; L[v, v] += w
        self.laplacian = L

    def canonical_kernel(self):
        evals, evecs = np.linalg.eigh(self.laplacian)
        tol = 1e-10 * max(abs(evals))
        g = np.zeros((self.n, self.n))
        for i in range(self.n):
            if abs(evals[i]) > tol:
                g += (1.0/evals[i]) * np.outer(evecs[:,i], evecs[:,i])
        g -= g.mean(axis=0)[np.newaxis,:]
        g -= g.mean(axis=1)[:,np.newaxis]
        return g


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Canonical Kernel Column Profiles: Tropical Potential Landscapes",
             fontsize=14, fontweight='bold')

graphs = [
    ('Path P₈ (unit weights)', WeightedGraph(8, [(i,i+1,1.0) for i in range(7)])),
    ('Cycle C₈ (unit weights)', WeightedGraph(8, [(i,(i+1)%8,1.0) for i in range(8)])),
    ('Star S₇ (center=0)', WeightedGraph(7, [(0,i,1.0) for i in range(1,7)])),
    ('Weighted cycle C₆', WeightedGraph(6, [(i,(i+1)%6, 0.5+0.5*i) for i in range(6)])),
]

colors = plt.cm.Set2(np.linspace(0, 1, 8))

for idx, (name, graph) in enumerate(graphs):
    ax = axes[idx // 2, idx % 2]
    g = graph.canonical_kernel()
    n = graph.n

    x = np.arange(n)
    # Plot kernel columns for a few source vertices
    sources = [0, n//4, n//2, 3*n//4] if n > 4 else list(range(min(4, n)))
    sources = sorted(set(s for s in sources if s < n))

    for i, p in enumerate(sources):
        ax.plot(x, g[p, :], 'o-', color=colors[i], linewidth=2,
                markersize=6, label=f'g({p}, ·)')

    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Vertex q')
    ax.set_ylabel('g(p, q)')
    ax.set_title(name, fontsize=11)
    ax.legend(fontsize=9, loc='best')
    ax.set_xticks(x)
    ax.grid(True, alpha=0.3)

    # Annotate diagonal value for p=0
    ax.annotate(f'g(0,0)={g[0,0]:.3f}', xy=(0, g[0,0]),
                xytext=(1.5, g[0,0]+0.03),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('viz_kernel_columns.png', dpi=150, bbox_inches='tight')
print("Saved viz_kernel_columns.png")
