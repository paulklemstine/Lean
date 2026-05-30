"""
Visualization: Matroid Exchange Graph

For a DPP support of size d, draws a graph where nodes are bases (subsets
with positive principal minor) and edges connect bases that differ by a
single element swap. The exchange property guarantees this graph is connected.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
import matplotlib.patches as mpatches


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    B = np.random.randn(rank, n)
    return B.T @ B


def principal_minor(K, S):
    S_list = list(S)
    return np.linalg.det(K[np.ix_(S_list, S_list)])


def hamming_distance(S1, S2):
    return len(set(S1) - set(S2))


np.random.seed(42)
n = 6
rank = 3
K = random_psd_matrix(n, rank)

d = 3
subsets = list(combinations(range(n), d))
minors = [principal_minor(K, S) for S in subsets]
support = [S for S, m in zip(subsets, minors) if m > 1e-10]

# Layout using spring embedding
num_nodes = len(support)
if num_nodes > 1:
    # Build adjacency
    adj = np.zeros((num_nodes, num_nodes))
    for i in range(num_nodes):
        for j in range(i + 1, num_nodes):
            if hamming_distance(support[i], support[j]) == 1:
                adj[i, j] = adj[j, i] = 1

    # Simple force-directed layout
    pos = np.random.randn(num_nodes, 2) * 2
    for _ in range(200):
        forces = np.zeros_like(pos)
        for i in range(num_nodes):
            for j in range(num_nodes):
                if i == j:
                    continue
                diff = pos[i] - pos[j]
                dist = max(np.linalg.norm(diff), 0.01)
                # Repulsion
                forces[i] += diff / dist ** 2 * 0.5
                # Attraction for edges
                if adj[i, j]:
                    forces[i] -= diff * 0.1
        pos += forces * 0.05
        pos -= pos.mean(axis=0)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    fig.suptitle(f'Matroid Exchange Graph\nDPP Support (n={n}, d={d}, rank={rank})',
                 fontsize=14, fontweight='bold')

    # Draw edges
    for i in range(num_nodes):
        for j in range(i + 1, num_nodes):
            if adj[i, j]:
                ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                        'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    minor_vals = [principal_minor(K, S) for S in support]
    max_minor = max(minor_vals)
    colors = [plt.cm.YlOrRd(0.3 + 0.7 * m / max_minor) for m in minor_vals]

    for i in range(num_nodes):
        circle = plt.Circle(pos[i], 0.15, color=colors[i], ec='black',
                           linewidth=1.5, zorder=5)
        ax.add_patch(circle)
        label = '{' + ','.join(str(x) for x in support[i]) + '}'
        ax.annotate(label, pos[i], ha='center', va='center', fontsize=7,
                   fontweight='bold', zorder=6)

    ax.set_xlim(pos[:, 0].min() - 0.5, pos[:, 0].max() + 0.5)
    ax.set_ylim(pos[:, 1].min() - 0.5, pos[:, 1].max() + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    green_patch = mpatches.Patch(color='#e6550d', label=f'Bases ({num_nodes} total)')
    edge_line = plt.Line2D([0], [0], color='black', alpha=0.3,
                           label='Exchange edge (Hamming dist 1)')
    ax.legend(handles=[green_patch, edge_line], loc='lower right', fontsize=10)

    plt.tight_layout()
    plt.savefig('exchange_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved exchange_graph.png ({num_nodes} nodes)")
else:
    print("Not enough support elements to draw graph")
