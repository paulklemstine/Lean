#!/usr/bin/env python3
"""
Visualization 1: Weighted Laplacian and Resistance Heatmaps

Visualizes the weighted Laplacian matrix and effective resistance matrix
for several graph topologies (cycle, star, complete, theta), showing how
graph structure and edge lengths determine the algebraic properties.

The Laplacian encodes conductance structure; the resistance matrix encodes
pairwise distances in the tropical metric.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


# ─── Inline graph classes and algorithms ───

class MetricGraph:
    def __init__(self, n_vertices, edges, lengths):
        self.n_vertices = n_vertices
        self.edges = edges
        self.lengths = lengths

    @property
    def genus(self):
        return len(self.edges) - self.n_vertices + 1


def weighted_laplacian(G):
    n = G.n_vertices
    L = np.zeros((n, n))
    for (i, j), length in zip(G.edges, G.lengths):
        c = 1.0 / length
        L[i, j] -= c
        L[j, i] -= c
        L[i, i] += c
        L[j, j] += c
    return L


def effective_resistance_matrix(G):
    L = weighted_laplacian(G)
    L_pinv = np.linalg.pinv(L)
    n = G.n_vertices
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = L_pinv[i, i] + L_pinv[j, j] - 2 * L_pinv[i, j]
    return R


# ─── Graphs ───

graphs = {
    "Cycle C₅\n(genus 1)": MetricGraph(5,
        [(0,1),(1,2),(2,3),(3,4),(4,0)],
        [1.0, 1.5, 2.0, 2.5, 3.0]),
    "Star K₁,₄\n(genus 0)": MetricGraph(5,
        [(0,1),(0,2),(0,3),(0,4)],
        [1.0, 2.0, 3.0, 4.0]),
    "Complete K₄\n(genus 3)": MetricGraph(4,
        [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)],
        [1.0, 2.0, 3.0, 1.5, 2.5, 3.5]),
    "Theta Θ(2,3,5)\n(genus 2)": MetricGraph(5,
        [(0,2),(2,1),(0,3),(3,1),(0,4),(4,1)],
        [1.0, 1.0, 1.5, 1.5, 2.5, 2.5]),
}

fig = plt.figure(figsize=(16, 10))
fig.suptitle("Weighted Laplacian & Effective Resistance Matrices\nfor Metric Graphs",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 4, hspace=0.4, wspace=0.3,
                       top=0.88, bottom=0.05, left=0.05, right=0.95)

for idx, (name, G) in enumerate(graphs.items()):
    L = weighted_laplacian(G)
    R = effective_resistance_matrix(G)

    # Laplacian heatmap (top row)
    ax1 = fig.add_subplot(gs[0, idx])
    vmax = max(abs(L.min()), abs(L.max()))
    im1 = ax1.imshow(L, cmap='RdBu_r', vmin=-vmax, vmax=vmax, aspect='equal')
    ax1.set_title(name, fontsize=10)
    ax1.set_xlabel("vertex j", fontsize=8)
    if idx == 0:
        ax1.set_ylabel("Laplacian L(i,j)", fontsize=10)
    for i in range(L.shape[0]):
        for j in range(L.shape[1]):
            ax1.text(j, i, f"{L[i,j]:.2f}", ha='center', va='center',
                     fontsize=6, color='white' if abs(L[i,j]) > vmax*0.6 else 'black')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Resistance heatmap (bottom row)
    ax2 = fig.add_subplot(gs[1, idx])
    im2 = ax2.imshow(R, cmap='YlOrRd', aspect='equal')
    ax2.set_xlabel("vertex j", fontsize=8)
    if idx == 0:
        ax2.set_ylabel("Resistance R(i,j)", fontsize=10)
    for i in range(R.shape[0]):
        for j in range(R.shape[1]):
            ax2.text(j, i, f"{R[i,j]:.2f}", ha='center', va='center',
                     fontsize=6, color='white' if R[i,j] > R.max()*0.6 else 'black')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    # Add Kirchhoff index annotation
    Kf = np.sum(R) / 2
    ax2.text(0.5, -0.15, f"Kf = {Kf:.2f}", transform=ax2.transAxes,
             ha='center', fontsize=8, style='italic')

plt.savefig("viz_laplacian_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_heatmap.png")
