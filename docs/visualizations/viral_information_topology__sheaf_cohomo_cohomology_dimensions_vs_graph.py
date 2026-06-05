#!/usr/bin/env python3
"""
Visualization: Sheaf Cohomology Dimensions vs Graph Structure

Shows how H^0 and H^1 change as edges are added to a graph,
demonstrating the Euler characteristic formula.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def coboundary_matrix(n_vertices, edges):
    m = len(edges)
    delta = np.zeros((m, n_vertices))
    for i, (s, t) in enumerate(edges):
        delta[i, t] = 1.0
        delta[i, s] = -1.0
    return delta


def compute_cohomology(n_vertices, edges):
    if len(edges) == 0:
        return n_vertices, 0, 0
    delta = coboundary_matrix(n_vertices, edges)
    rank = int(np.linalg.matrix_rank(delta, tol=1e-10))
    h0 = n_vertices - rank
    h1 = len(edges) - rank
    return h0, h1, rank


def main():
    n = 8
    # Add edges one by one to build up a graph
    all_edges = [
        (0, 1), (1, 2), (2, 3), (3, 0),  # cycle in community 1
        (4, 5), (5, 6), (6, 7), (7, 4),  # cycle in community 2
        (3, 4),  # bridge
        (0, 2), (4, 6),  # diagonals
        (1, 5), (2, 6),  # extra cross-edges
    ]
    
    h0_vals, h1_vals, euler_vals, n_edges = [], [], [], []
    virality_vals = []
    
    for k in range(len(all_edges) + 1):
        edges = all_edges[:k]
        h0, h1, rank = compute_cohomology(n, edges)
        h0_vals.append(h0)
        h1_vals.append(h1)
        euler_vals.append(h0 - h1)
        n_edges.append(k)
        virality_vals.append(h0 * (k + 1 - h1))
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Sheaf Cohomology on Social Graphs: Edge Addition Sequence',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: H^0 and H^1
    ax1 = axes[0, 0]
    ax1.plot(n_edges, h0_vals, 'b-o', linewidth=2, markersize=6, label='dim H⁰ (interpretations)')
    ax1.plot(n_edges, h1_vals, 'r-s', linewidth=2, markersize=6, label='dim H¹ (barriers)')
    ax1.set_xlabel('Number of Edges')
    ax1.set_ylabel('Dimension')
    ax1.set_title('Cohomology Dimensions')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Euler characteristic
    ax2 = axes[0, 1]
    ax2.plot(n_edges, euler_vals, 'g-^', linewidth=2, markersize=6, label='χ = dim H⁰ - dim H¹')
    ax2.plot(n_edges, [n - k for k in n_edges], 'k--', linewidth=1, label='|V| - |E|')
    ax2.set_xlabel('Number of Edges')
    ax2.set_ylabel('Euler Characteristic')
    ax2.set_title('Euler Characteristic Formula: χ = |V| - |E|')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Virality index
    ax3 = axes[1, 0]
    ax3.plot(n_edges, virality_vals, 'm-D', linewidth=2, markersize=6, label='Virality Index')
    upper_bound = [n * (k + 1) for k in n_edges]
    ax3.plot(n_edges, upper_bound, 'k--', linewidth=1, alpha=0.5, label='Upper bound |V|·(|E|+1)')
    ax3.set_xlabel('Number of Edges')
    ax3.set_ylabel('Virality Index')
    ax3.set_title('Virality Index: H⁰ × (|E| + 1 - H¹)')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # Plot 4: Phase diagram
    ax4 = axes[1, 1]
    scatter = ax4.scatter(h0_vals, h1_vals, c=virality_vals, s=100,
                          cmap='plasma', edgecolors='black', linewidth=0.5)
    for i, k in enumerate(n_edges):
        ax4.annotate(f'{k}e', (h0_vals[i] + 0.05, h1_vals[i] + 0.05), fontsize=8)
    ax4.set_xlabel('dim H⁰ (Polysemy)')
    ax4.set_ylabel('dim H¹ (Barriers)')
    ax4.set_title('Cohomological Phase Diagram')
    plt.colorbar(scatter, ax=ax4, label='Virality Index')
    ax4.grid(True, alpha=0.3)
    
    # Add annotation for the "viral sweet spot"
    ax4.annotate('Viral\nSweet\nSpot', xy=(max(h0_vals), 0),
                 xytext=(max(h0_vals) - 1, max(h1_vals) - 0.5),
                 arrowprops=dict(arrowstyle='->', color='red'),
                 fontsize=10, color='red', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('cohomology_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cohomology_visualization.png")


if __name__ == "__main__":
    main()
