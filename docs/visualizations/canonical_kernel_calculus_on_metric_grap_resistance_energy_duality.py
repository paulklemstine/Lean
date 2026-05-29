"""
Visualization: Resistance–Energy Duality (Cross-Domain Theorem)

Demonstrates the formally verified identity:
    r(p,q) = E(g_p - g_q) = g(p,p) + g(q,q) - 2g(p,q)

This bridges tropical geometry (kernel), electrical networks (resistance),
and energy minimization (Dirichlet energy) in a single visual.

Shows scatter plots of r(p,q) vs E(g_p - g_q) for multiple graph types,
confirming they lie perfectly on the diagonal y = x.
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


def compute_pairs(graph):
    """Compute (resistance, dipole_energy) for all vertex pairs."""
    g = graph.canonical_kernel()
    L = graph.laplacian
    resistances = []
    energies = []
    for p in range(graph.n):
        for q in range(p+1, graph.n):
            r = g[p,p] + g[q,q] - 2*g[p,q]
            dipole = g[p,:] - g[q,:]
            e = float(dipole @ L @ dipole)
            resistances.append(r)
            energies.append(e)
    return np.array(resistances), np.array(energies)


# Build graphs
graphs = {
    'Path P₇': WeightedGraph(7, [(i,i+1,1.0) for i in range(6)]),
    'Cycle C₈': WeightedGraph(8, [(i,(i+1)%8,1.0) for i in range(8)]),
    'Complete K₅': WeightedGraph(5, [(i,j,1.0) for i in range(5) for j in range(i+1,5)]),
    'Star S₆': WeightedGraph(6, [(0,i,1.0) for i in range(1,6)]),
    'Random (n=8)': None,  # filled below
    'Weighted cycle': WeightedGraph(6, [(i,(i+1)%6, 0.5+i*0.3) for i in range(6)]),
}

# Random graph
np.random.seed(42)
n = 8
re = []
for i in range(n):
    for j in range(i+1, n):
        if np.random.random() < 0.5:
            re.append((i, j, np.random.uniform(0.3, 2.0)))
# Ensure connected
for i in range(n-1):
    found = any(u==i and v==i+1 or u==i+1 and v==i for u,v,_ in re)
    if not found:
        re.append((i, i+1, 1.0))
graphs['Random (n=8)'] = WeightedGraph(n, re)

# Create figure
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle("Resistance–Energy Duality: r(p,q) = E(g_p − g_q)\n"
             "(Cross-Domain Theorem — Formally Verified)",
             fontsize=14, fontweight='bold')

colors = ['#2196F3', '#4CAF50', '#FF5722', '#9C27B0', '#FF9800', '#607D8B']

for idx, (name, graph) in enumerate(graphs.items()):
    ax = axes[idx // 3, idx % 3]
    r, e = compute_pairs(graph)

    ax.scatter(r, e, c=colors[idx], s=40, alpha=0.7, edgecolors='k', linewidths=0.5)

    # Perfect diagonal
    lim = max(r.max(), e.max()) * 1.1
    ax.plot([0, lim], [0, lim], 'k--', alpha=0.3, linewidth=1)

    ax.set_xlim(-0.02*lim, lim)
    ax.set_ylim(-0.02*lim, lim)
    ax.set_xlabel('Effective Resistance r(p,q)')
    ax.set_ylabel('Dipole Energy E(g_p − g_q)')
    ax.set_title(name, fontsize=11)
    ax.set_aspect('equal')

    # Error annotation
    max_err = np.max(np.abs(r - e))
    ax.text(0.05, 0.92, f'max error: {max_err:.1e}',
            transform=ax.transAxes, fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('viz_resistance_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_resistance_energy.png")
