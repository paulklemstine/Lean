"""
Visualization: Effective Resistance Heatmap and Kernel Structure

Displays the effective resistance matrix for several metric graph models,
showing how edge lengths determine the electrical distance structure.
Also shows how the canonical kernel matrix encodes this information.

Key insight: The effective resistance is a metric on the vertices of a
graph. It is computable from the canonical kernel matrix and connects
tropical geometry to electrical network theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass


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


def solve_mz(model, rhs):
    n = model.n
    L = model.laplacian
    A = np.zeros((n + 1, n + 1))
    A[:n, :n] = L
    A[:n, n] = 1.0
    A[n, :n] = 1.0
    b = np.zeros(n + 1)
    b[:n] = rhs
    return np.linalg.lstsq(A, b, rcond=None)[0][:n]


def eff_resistance(model, s, t):
    rhs = np.zeros(model.n)
    rhs[s] = 1.0
    rhs[t] = -1.0
    f = solve_mz(model, rhs)
    return f[s] - f[t]


def eff_res_matrix(model):
    n = model.n
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            R[i, j] = R[j, i] = eff_resistance(model, i, j)
    return R


# Build several graph models
def make_cycle(lengths):
    n = len(lengths)
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        adj[i, j] = adj[j, i] = 1
        el[i, j] = el[j, i] = lengths[i]
    return MG(n, adj, el)


def make_complete(n, length=1.0):
    adj = np.ones((n, n)) - np.eye(n)
    el = np.ones((n, n)) * length
    np.fill_diagonal(el, 0)
    return MG(n, adj, el)


def make_path(lengths):
    n = len(lengths) + 1
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(len(lengths)):
        adj[i, i+1] = adj[i+1, i] = 1
        el[i, i+1] = el[i+1, i] = lengths[i]
    return MG(n, adj, el)


def make_star(n_leaves, lengths):
    n = n_leaves + 1  # center = 0
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n_leaves):
        adj[0, i+1] = adj[i+1, 0] = 1
        el[0, i+1] = el[i+1, 0] = lengths[i]
    return MG(n, adj, el)


graphs = [
    ("Cycle C₅\n(1,1,1,1,1)", make_cycle([1, 1, 1, 1, 1])),
    ("Cycle C₅\n(1,2,3,4,5)", make_cycle([1, 2, 3, 4, 5])),
    ("Complete K₄\n(unit)", make_complete(4)),
    ("Path P₅\n(1,1,1,1)", make_path([1, 1, 1, 1])),
    ("Star S₅\n(1,2,3,4)", make_star(4, [1, 2, 3, 4])),
    ("Complete K₅\n(unit)", make_complete(5)),
]

fig, axes = plt.subplots(2, 3, figsize=(14, 9))

for idx, (name, G) in enumerate(graphs):
    ax = axes[idx // 3, idx % 3]
    R = eff_res_matrix(G)

    im = ax.imshow(R, cmap='YlOrRd', interpolation='nearest')
    plt.colorbar(im, ax=ax, shrink=0.8, label='R_eff (Ω)')
    ax.set_title(name, fontsize=11, fontweight='bold')

    # Annotate cells
    for i in range(G.n):
        for j in range(G.n):
            color = 'white' if R[i, j] > R.max() * 0.6 else 'black'
            ax.text(j, i, f'{R[i, j]:.2f}', ha='center', va='center',
                    fontsize=7, color=color)

    ax.set_xlabel('Vertex', fontsize=9)
    ax.set_ylabel('Vertex', fontsize=9)
    ax.set_xticks(range(G.n))
    ax.set_yticks(range(G.n))

fig.suptitle('Effective Resistance Matrices for Metric Graph Models\n'
             'R_eff(i,j) = voltage drop for unit current injection (i→j)',
             fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_effective_resistance.png', dpi=150, bbox_inches='tight')
print("Saved viz_effective_resistance.png")
