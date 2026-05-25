"""
Visualization: Jacobian Group Order = Spanning Trees.

Creates a heatmap showing the Jacobian group order (= number of spanning
trees by Kirchhoff's theorem) for complete graphs K_n and cycle graphs C_n,
illustrating the matrix-tree theorem and the exponential growth of
spanning tree counts with graph complexity.
"""

import numpy as np
import matplotlib.pyplot as plt


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj


def spanning_tree_count(adj):
    if adj.shape[0] <= 1:
        return 1
    L = graph_laplacian(adj).astype(float)
    L_red = L[1:, 1:]
    return max(1, int(round(np.linalg.det(L_red))))


def complete_graph(n):
    adj = np.ones((n, n), dtype=int)
    np.fill_diagonal(adj, 0)
    return adj


def cycle_graph(n):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i+1)%n] = adj[(i+1)%n, i] = 1
    return adj


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Kirchhoff\'s Matrix-Tree Theorem: |Jac(G)| = τ(G)',
             fontsize=14, fontweight='bold')

# Plot 1: Spanning tree count for K_n (= n^{n-2} by Cayley's formula)
ns = list(range(2, 12))
kn_trees = [spanning_tree_count(complete_graph(n)) for n in ns]
cayley = [n ** (n-2) for n in ns]

ax1.semilogy(ns, kn_trees, 'o-', color='#e74c3c', markersize=8,
             linewidth=2, label='τ(Kₙ) computed')
ax1.semilogy(ns, cayley, 's--', color='#3498db', markersize=6,
             linewidth=1, label='n^(n-2) (Cayley)')
ax1.set_xlabel('n (vertices)', fontsize=12)
ax1.set_ylabel('Number of spanning trees', fontsize=12)
ax1.set_title('Complete Graphs Kₙ', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Annotate some values
for i, n in enumerate(ns[:6]):
    ax1.annotate(f'{kn_trees[i]}', (n, kn_trees[i]),
                textcoords="offset points", xytext=(0, 10),
                fontsize=8, ha='center')

# Plot 2: Genus vs spanning trees for various graph families
data = []
labels = []

# Cycle graphs
for n in range(3, 15):
    adj = cycle_graph(n)
    g = np.sum(adj) // 2 - n + 1
    t = spanning_tree_count(adj)
    data.append((g, t, 'Cycle'))

# Complete graphs
for n in range(3, 9):
    adj = complete_graph(n)
    m = np.sum(adj) // 2
    g = m - n + 1
    t = spanning_tree_count(adj)
    data.append((g, t, 'Complete'))

# Wheel graphs (cycle + center)
for n in range(3, 10):
    adj_size = n + 1
    adj = np.zeros((adj_size, adj_size), dtype=int)
    for i in range(n):
        adj[i, (i+1)%n] = adj[(i+1)%n, i] = 1
        adj[i, n] = adj[n, i] = 1
    m = np.sum(adj) // 2
    g = m - adj_size + 1
    t = spanning_tree_count(adj)
    data.append((g, t, 'Wheel'))

# Separate by family
for family, color, marker in [('Cycle', '#2ecc71', 'o'),
                                ('Complete', '#e74c3c', 's'),
                                ('Wheel', '#3498db', '^')]:
    pts = [(g, t) for g, t, f in data if f == family]
    if pts:
        gs, ts = zip(*pts)
        ax2.semilogy(gs, ts, f'{marker}-', color=color, markersize=7,
                    linewidth=1.5, label=f'{family} graphs', alpha=0.8)

ax2.set_xlabel('Genus g = |E| - |V| + 1', fontsize=12)
ax2.set_ylabel('|Jac(G)| = # spanning trees', fontsize=12)
ax2.set_title('Jacobian Order vs Genus', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_jacobian_order.png', dpi=150, bbox_inches='tight')
print("Saved viz_jacobian_order.png")
