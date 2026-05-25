"""
Visualization: Network Resilience via Tropical Balance

This script visualizes a network resilience analysis using tropical
balance as a metric. Nodes are colored by their balance status
(resilient vs vulnerable) and edges are colored by weight degeneracy.

Key insight: Nodes where the minimum-weight edge is achieved by
multiple neighbors are "tropically balanced" — they have redundant
optimal routes and are thus more resilient to single-link failures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


class WeightedGraph:
    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        self.edge_list = edges
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [G.weight(i, j) + phi.get(j, 0) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


# Create two network scenarios
def create_resilient_network():
    """Network with high redundancy (many equal-weight links)."""
    return WeightedGraph(
        vertices=list(range(8)),
        edges=[
            (0, 1, 2), (0, 2, 2), (0, 3, 2),  # Hub with redundant links
            (1, 4, 3), (2, 4, 3), (3, 5, 3),   # Symmetric mid-layer
            (1, 5, 3), (2, 5, 3),               # More redundancy
            (4, 6, 1), (5, 6, 1),               # Converge
            (4, 7, 4), (5, 7, 4), (6, 7, 2),   # Final layer
        ]
    )


def create_vulnerable_network():
    """Network with unique optimal routes (all distinct weights)."""
    return WeightedGraph(
        vertices=list(range(8)),
        edges=[
            (0, 1, 1), (0, 2, 2), (0, 3, 4),
            (1, 4, 3), (2, 4, 5), (3, 5, 7),
            (1, 5, 6), (2, 5, 8),
            (4, 6, 9), (5, 6, 10),
            (4, 7, 11), (5, 7, 12), (6, 7, 13),
        ]
    )


def plot_network(G, ax, title, positions):
    """Plot a weighted graph with tropical balance coloring."""
    phi_zero = {v: 0 for v in G.vertices}

    # Draw edges
    for u, v, w in G.edge_list:
        x = [positions[u][0], positions[v][0]]
        y = [positions[u][1], positions[v][1]]
        # Check if this edge contributes to degeneracy at either endpoint
        degenerate = False
        for endpoint in [u, v]:
            nbrs = list(G.neighbors(endpoint))
            for a, b in combinations(nbrs, 2):
                if G.weight(endpoint, a) == G.weight(endpoint, b):
                    if a in (u, v) and b in (u, v):
                        degenerate = True
                    elif endpoint in (u, v):
                        other = u if endpoint == v else v
                        if other in (a, b):
                            nbr2 = b if a == other else a
                            if G.weight(endpoint, other) == G.weight(endpoint, nbr2):
                                degenerate = True

        color = '#e74c3c' if degenerate else '#bdc3c7'
        width = 3 if degenerate else 1.5
        ax.plot(x, y, color=color, linewidth=width, zorder=1)

        # Edge weight label
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.annotate(str(w), (mx, my), fontsize=8, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    # Draw vertices
    for v in G.vertices:
        balanced = trop_balanced_at(G, phi_zero, v)
        color = '#2ecc71' if balanced else '#e74c3c'
        marker_size = 400
        ax.scatter(positions[v][0], positions[v][1], c=color, s=marker_size,
                   zorder=2, edgecolors='black', linewidths=2)
        ax.annotate(str(v), positions[v], fontsize=12, ha='center', va='center',
                    fontweight='bold', zorder=3)

    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')


# Positions for the 8-node network
positions = {
    0: (0, 1.5),
    1: (1, 2.5), 2: (1, 1.5), 3: (1, 0.5),
    4: (2.5, 2), 5: (2.5, 1),
    6: (3.5, 2), 7: (3.5, 1),
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

G_resilient = create_resilient_network()
G_vulnerable = create_vulnerable_network()

plot_network(G_resilient, ax1, 'Resilient Network\n(many equal-weight links)', positions)
plot_network(G_vulnerable, ax2, 'Vulnerable Network\n(all distinct weights)', positions)

# Legend
from matplotlib.patches import Patch
from matplotlib.lines import Line2D
legend_elements = [
    Patch(facecolor='#2ecc71', edgecolor='black', label='Balanced (resilient)'),
    Patch(facecolor='#e74c3c', edgecolor='black', label='Unbalanced (vulnerable)'),
    Line2D([0], [0], color='#e74c3c', linewidth=3, label='Degenerate edge'),
    Line2D([0], [0], color='#bdc3c7', linewidth=1.5, label='Non-degenerate edge'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Network Resilience Analysis via Tropical Balance', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_network_resilience.png', dpi=150, bbox_inches='tight')
print("Saved viz_network_resilience.png")
