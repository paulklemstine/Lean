"""
Visualization: Canonical Kernel Convergence Under Subdivision

Tracks the entries of the canonical kernel matrix as the metric graph
is uniformly refined. Demonstrates the resolution-stability conjecture:
kernel entries converge to finite limits independent of refinement scheme.

Key insight: The kernel matrix entries stabilize as the mesh refines,
suggesting that the discrete canonical kernels converge to well-defined
continuous objects — the metric graph Green's functions.
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List


@dataclass
class MG:
    n: int
    adj: np.ndarray
    lengths: np.ndarray

    @property
    def laplacian(self) -> np.ndarray:
        C = np.zeros_like(self.lengths)
        mask = self.adj > 0
        C[mask] = 1.0 / self.lengths[mask]
        L = -C.copy()
        np.fill_diagonal(L, C.sum(axis=1))
        return L


def make_cycle(lengths):
    n = len(lengths)
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        adj[i, j] = adj[j, i] = 1
        el[i, j] = el[j, i] = lengths[i]
    return MG(n, adj, el)


def subdivide_all(model):
    edges = []
    for i in range(model.n):
        for j in range(i + 1, model.n):
            if model.adj[i, j] == 1:
                edges.append((i, j, model.lengths[i, j]))
    new_n = model.n + len(edges)
    new_adj = np.zeros((new_n, new_n))
    new_len = np.zeros((new_n, new_n))
    mid = model.n
    for i, j, l in edges:
        h = l / 2
        new_adj[i, mid] = new_adj[mid, i] = 1
        new_adj[mid, j] = new_adj[j, mid] = 1
        new_len[i, mid] = new_len[mid, i] = h
        new_len[mid, j] = new_len[j, mid] = h
        mid += 1
    return MG(new_n, new_adj, new_len)


def solve_kernel(model, support, divisor):
    n = model.n
    L = model.laplacian
    rhs = np.zeros(n)
    for i, s in enumerate(support):
        rhs[s] = divisor[i]
    A = np.zeros((n + 1, n + 1))
    A[:n, :n] = L
    A[:n, n] = 1.0
    A[n, :n] = 1.0
    b = np.zeros(n + 1)
    b[:n] = rhs
    return np.linalg.lstsq(A, b, rcond=None)[0][:n]


def kernel_matrix(model, support):
    k = len(support)
    K = np.zeros((k, k))
    for i in range(k):
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1
        f = solve_kernel(model, support, D)
        for j in range(k):
            K[i, j] = f[support[j]]
    return K


# ============================================================
# Compute convergence data for multiple graphs
# ============================================================

graphs = [
    ("C₃ (1, √2, π/2)", make_cycle([1.0, np.sqrt(2), np.pi/2])),
    ("C₄ (1, 2, 1.5, 0.8)", make_cycle([1.0, 2.0, 1.5, 0.8])),
    ("C₅ (1, 1, 1, 1, 1)", make_cycle([1.0, 1.0, 1.0, 1.0, 1.0])),
]

support = [0, 1]  # Same support for all
max_levels = 5

fig, axes = plt.subplots(2, 3, figsize=(15, 8))

for col, (name, base_graph) in enumerate(graphs):
    levels = list(range(max_levels + 1))
    K_entries = {(i, j): [] for i in range(2) for j in range(2)}
    n_vertices = []

    current = base_graph
    for level in levels:
        K = kernel_matrix(current, support)
        for i in range(2):
            for j in range(2):
                K_entries[(i, j)].append(K[i, j])
        n_vertices.append(current.n)
        if level < max_levels:
            current = subdivide_all(current)

    # Top row: kernel entries vs refinement level
    ax1 = axes[0, col]
    for (i, j), vals in K_entries.items():
        ax1.plot(levels, vals, 'o-', linewidth=2, markersize=5,
                 label=f'K[{i},{j}]')
    ax1.set_xlabel('Refinement Level', fontsize=10)
    ax1.set_ylabel('Kernel Entry Value', fontsize=10)
    ax1.set_title(f'{name}', fontsize=11, fontweight='bold')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Bottom row: convergence rate (log of differences)
    ax2 = axes[1, col]
    for (i, j), vals in K_entries.items():
        diffs = [abs(vals[k+1] - vals[k]) for k in range(len(vals)-1)]
        if any(d > 0 for d in diffs):
            ax2.semilogy(levels[1:], diffs, 's-', linewidth=2, markersize=5,
                         label=f'|ΔK[{i},{j}]|')
    ax2.set_xlabel('Refinement Level', fontsize=10)
    ax2.set_ylabel('|K_{n+1} - K_n|', fontsize=10)
    ax2.set_title('Convergence Rate', fontsize=11)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

fig.suptitle('Canonical Kernel Convergence Under Uniform Subdivision\n'
             'Support S = {v₀, v₁}', fontsize=13, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_kernel_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_kernel_convergence.png")
