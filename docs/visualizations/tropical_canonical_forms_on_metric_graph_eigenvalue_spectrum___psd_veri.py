#!/usr/bin/env python3
"""
Visualization 2: Eigenvalue Spectrum and PSD Verification

Shows the eigenvalue spectrum of weighted Laplacians for various metric graphs,
visually confirming positive semi-definiteness. Includes the spectral gap
(smallest nonzero eigenvalue), which measures algebraic connectivity.

Also shows how edge lengths affect the spectrum: longer edges reduce
conductance and shift eigenvalues toward zero.
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


# ─── Figure ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Eigenvalue Spectra of Weighted Laplacians\n(Positive Semi-Definiteness Verification)",
             fontsize=14, fontweight='bold')

# Panel 1: Different graph topologies with unit lengths
ax = axes[0, 0]
topologies = {
    "Path P₅": MetricGraph(5, [(0,1),(1,2),(2,3),(3,4)], [1]*4),
    "Cycle C₅": MetricGraph(5, [(0,1),(1,2),(2,3),(3,4),(4,0)], [1]*5),
    "Star K₁,₄": MetricGraph(5, [(0,1),(0,2),(0,3),(0,4)], [1]*4),
    "Complete K₅": MetricGraph(5,
        [(i,j) for i in range(5) for j in range(i+1,5)],
        [1]*10),
}
colors = plt.cm.Set2(np.linspace(0, 1, len(topologies)))
for (name, G), color in zip(topologies.items(), colors):
    L = weighted_laplacian(G)
    eigs = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(eigs)), eigs, 'o-', color=color, label=name, markersize=8)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel("Index", fontsize=10)
ax.set_ylabel("Eigenvalue λ", fontsize=10)
ax.set_title("Different Topologies (unit lengths)", fontsize=11)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Same topology, varying edge length scale
ax = axes[0, 1]
scales = [0.5, 1.0, 2.0, 5.0, 10.0]
colors2 = plt.cm.viridis(np.linspace(0.2, 0.9, len(scales)))
for scale, color in zip(scales, colors2):
    G = MetricGraph(5, [(0,1),(1,2),(2,3),(3,4),(4,0)], [scale]*5)
    L = weighted_laplacian(G)
    eigs = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(eigs)), eigs, 'o-', color=color,
            label=f"ℓ = {scale}", markersize=8)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel("Index", fontsize=10)
ax.set_ylabel("Eigenvalue λ", fontsize=10)
ax.set_title("Cycle C₅ with varying edge length", fontsize=11)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Spectral gap vs number of vertices (cycle graph)
ax = axes[1, 0]
ns = range(3, 21)
gaps = []
for n in ns:
    edges = [(i, (i+1)%n) for i in range(n)]
    G = MetricGraph(n, edges, [1.0]*n)
    L = weighted_laplacian(G)
    eigs = np.sort(np.linalg.eigvalsh(L))
    gap = eigs[1]  # smallest nonzero eigenvalue
    gaps.append(gap)
ax.plot(list(ns), gaps, 'bo-', markersize=6)
# Theoretical: λ_1 = 2(1 - cos(2π/n)) for unit cycle
theoretical = [2*(1 - np.cos(2*np.pi/n)) for n in ns]
ax.plot(list(ns), theoretical, 'r--', label=r"$2(1-\cos(2\pi/n))$", alpha=0.7)
ax.set_xlabel("Number of vertices n", fontsize=10)
ax.set_ylabel("Spectral gap λ₁", fontsize=10)
ax.set_title("Spectral Gap vs. Graph Size (unit cycle)", fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Quadratic form x^T L x for random vectors (histogram)
ax = axes[1, 1]
G = MetricGraph(6, [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),(0,3),(1,4)],
                [1,2,1,2,1,2,3,3])
L = weighted_laplacian(G)
np.random.seed(42)
n_samples = 5000
quad_vals = []
for _ in range(n_samples):
    x = np.random.randn(G.n_vertices)
    qf = x @ L @ x
    quad_vals.append(qf)

ax.hist(quad_vals, bins=60, density=True, color='steelblue', alpha=0.7,
        edgecolor='white')
ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='x = 0')
ax.set_xlabel("x^T L x", fontsize=10)
ax.set_ylabel("Density", fontsize=10)
ax.set_title("Quadratic Form Distribution (PSD: all ≥ 0)", fontsize=11)
ax.annotate(f"min = {min(quad_vals):.4f}\nall values ≥ 0 ✓",
            xy=(0.65, 0.85), xycoords='axes fraction', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("viz_eigenvalue_spectrum.png", dpi=150, bbox_inches='tight')
print("Saved viz_eigenvalue_spectrum.png")
