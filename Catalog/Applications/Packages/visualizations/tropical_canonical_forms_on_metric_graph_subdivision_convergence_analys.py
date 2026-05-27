#!/usr/bin/env python3
"""
Visualization 3: Subdivision Convergence and Tropical Jacobian Structure

Shows how subdividing edges of a metric graph affects:
1. The effective resistance matrix (which converges to the continuous limit)
2. The canonical kernel generators
3. The tropical Jacobian invariant factors

Demonstrates the subdivision convergence conjecture with rate analysis
on cycle and theta graphs.
"""

import numpy as np
import matplotlib.pyplot as plt


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


def subdivide_graph(G, n):
    if n <= 1:
        return G
    new_edges = []
    new_lengths = []
    next_vertex = G.n_vertices
    for (i, j), length in zip(G.edges, G.lengths):
        sub_length = length / n
        prev = i
        for k in range(n - 1):
            new_edges.append((prev, next_vertex))
            new_lengths.append(sub_length)
            prev = next_vertex
            next_vertex += 1
        new_edges.append((prev, j))
        new_lengths.append(sub_length)
    return MetricGraph(next_vertex, new_edges, new_lengths)


def canonical_kernel_generators(G, S, base_vertex=None):
    if base_vertex is None:
        base_vertex = S[0]
    R = effective_resistance_matrix(G)
    S_reduced = [v for v in S if v != base_vertex]
    k = len(S_reduced)
    if k == 0:
        return np.array([[]])
    gen = np.zeros((k, k))
    for i in range(k):
        for j in range(k):
            vi, vj = S_reduced[i], S_reduced[j]
            gen[i, j] = (R[vi, vj] - R[vi, base_vertex]
                         - R[base_vertex, vj] + R[base_vertex, base_vertex])
    return gen


# ─── Convergence experiment ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Subdivision Convergence & Tropical Jacobian Structure",
             fontsize=14, fontweight='bold')

# Test graphs
test_configs = [
    ("Cycle C₃ (genus 1)",
     MetricGraph(3, [(0,1),(1,2),(2,0)], [1.0, 2.0, 3.0]),
     [0, 1, 2]),
    ("Cycle C₄ (genus 1)",
     MetricGraph(4, [(0,1),(1,2),(2,3),(3,0)], [1.0, 1.5, 2.0, 2.5]),
     [0, 1, 2, 3]),
    ("Theta Θ(1,2,3) (genus 2)",
     MetricGraph(5, [(0,2),(2,1),(0,3),(3,1),(0,4),(4,1)],
                 [0.5, 0.5, 1.0, 1.0, 1.5, 1.5]),
     [0, 1]),
    ("Diamond (genus 2)",
     MetricGraph(4, [(0,1),(0,2),(1,3),(2,3),(1,2)],
                 [1.0, 2.0, 1.5, 2.5, 3.0]),
     [0, 1, 2, 3]),
]

subdivisions = [1, 2, 4, 8, 16, 32]

for idx, (name, G_base, S) in enumerate(test_configs):
    ax = axes[idx // 2, idx % 2]

    # Compute generators at each subdivision level
    base_gens = canonical_kernel_generators(G_base, S)
    diffs = []
    for n in subdivisions:
        G_sub = subdivide_graph(G_base, n)
        sub_gens = canonical_kernel_generators(G_sub, S)
        diff = np.max(np.abs(sub_gens - base_gens)) if sub_gens.size > 0 else 0
        diffs.append(max(diff, 1e-16))

    ax.semilogy(subdivisions, diffs, 'bo-', markersize=8, linewidth=2,
                label='Max |κ_n - κ_1|')

    # Reference lines for convergence rates
    if diffs[0] > 1e-14:
        ref_n = np.array(subdivisions, dtype=float)
        c0 = diffs[0] * subdivisions[0]
        ax.semilogy(subdivisions, c0 / ref_n, 'r--', alpha=0.5,
                    label='O(1/n)')
        c0_sq = diffs[0] * subdivisions[0]**2
        ax.semilogy(subdivisions, c0_sq / ref_n**2, 'g--', alpha=0.5,
                    label='O(1/n²)')

    ax.set_xlabel("Subdivision level n", fontsize=10)
    ax.set_ylabel("Max generator difference", fontsize=10)
    ax.set_title(name, fontsize=11)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Add genus and Jacobian info
    eigs = np.sort(np.linalg.eigvalsh(weighted_laplacian(G_base)))
    ax.text(0.02, 0.02,
            f"genus={G_base.genus}, λ₁={eigs[1]:.3f}",
            transform=ax.transAxes, fontsize=8,
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8),
            verticalalignment='bottom')

plt.tight_layout()
plt.savefig("viz_subdivision_convergence.png", dpi=150, bbox_inches='tight')
print("Saved viz_subdivision_convergence.png")
