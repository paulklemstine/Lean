"""
Visualization: Canonical Kernel Heatmap and Effective Resistance

Generates a side-by-side visualization showing:
1. The canonical Green kernel matrix g(p,q) as a heatmap
2. The effective resistance matrix R(p,q) as a heatmap
3. Kernel column profiles (tropical potential landscapes)

This visualizes the core mathematical objects of the canonical
kernel calculus: the symmetric Green function and its polarization
into effective resistance.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


class WeightedGraph:
    """Inline implementation for self-contained visualization."""
    def __init__(self, n, edges):
        self.n = n
        self.edges = edges
        L = np.zeros((n, n))
        for u, v, w in edges:
            L[u, v] -= w
            L[v, u] -= w
            L[u, u] += w
            L[v, v] += w
        self.laplacian = L

    def canonical_kernel(self):
        n = self.n
        evals, evecs = np.linalg.eigh(self.laplacian)
        tol = 1e-10 * max(abs(evals))
        g = np.zeros((n, n))
        for i in range(n):
            if abs(evals[i]) > tol:
                g += (1.0 / evals[i]) * np.outer(evecs[:, i], evecs[:, i])
        g -= g.mean(axis=0)[np.newaxis, :]
        g -= g.mean(axis=1)[:, np.newaxis]
        return g

    def all_resistances(self):
        g = self.canonical_kernel()
        d = np.diag(g)
        return d[:, None] + d[None, :] - 2 * g


# Build test graphs
def make_lollipop(cs, pl):
    n = cs + pl
    edges = [(i, (i+1) % cs, 1.0) for i in range(cs)]
    for i in range(pl):
        u = cs - 1 if i == 0 else cs + i - 1
        edges.append((u, cs + i, 1.0))
    return WeightedGraph(n, edges)


# Create figure
fig = plt.figure(figsize=(16, 12))
fig.suptitle("Canonical Kernel Calculus on Metric Graphs",
             fontsize=16, fontweight='bold', y=0.98)
gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.35)

graphs = {
    'Cycle C₈': WeightedGraph(8, [(i, (i+1)%8, 1.0) for i in range(8)]),
    'Lollipop(5,3)': make_lollipop(5, 3),
    'Petersen-like': WeightedGraph(6, [
        (0,1,1), (1,2,1), (2,3,1), (3,4,1), (4,5,1), (5,0,1),
        (0,3,0.5), (1,4,0.5), (2,5,0.5)
    ]),
}

for idx, (name, graph) in enumerate(graphs.items()):
    g = graph.canonical_kernel()
    R = graph.all_resistances()

    # Kernel heatmap
    ax1 = fig.add_subplot(gs[0, idx])
    im1 = ax1.imshow(g, cmap='RdBu_r', aspect='equal',
                     interpolation='nearest')
    ax1.set_title(f'{name}\nKernel g(p,q)', fontsize=11)
    ax1.set_xlabel('q')
    ax1.set_ylabel('p')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Resistance heatmap
    ax2 = fig.add_subplot(gs[1, idx])
    im2 = ax2.imshow(R, cmap='YlOrRd', aspect='equal',
                     interpolation='nearest')
    ax2.set_title(f'{name}\nResistance r(p,q)', fontsize=11)
    ax2.set_xlabel('q')
    ax2.set_ylabel('p')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

plt.savefig('viz_kernel_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_kernel_heatmap.png")
