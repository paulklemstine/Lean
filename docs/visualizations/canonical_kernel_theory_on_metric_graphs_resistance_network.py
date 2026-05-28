"""
Visualization: Effective Resistance Network and Refinement Convergence

Shows how effective resistance (a key cross-domain quantity linking
tropical geometry, electrical networks, and quantum graphs) is computed
via canonical kernels, and how it remains stable under mesh refinement.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict
from dataclasses import dataclass, field


@dataclass
class MetricGraphModel:
    n_vertices: int
    edges: List[Tuple[int, int, float]]
    adj: Dict[int, List[Tuple[int, float]]] = field(default_factory=dict)

    def __post_init__(self):
        self.adj = {i: [] for i in range(self.n_vertices)}
        for i, j, length in self.edges:
            self.adj[i].append((j, length))
            self.adj[j].append((i, length))


def build_weighted_laplacian(M):
    n = M.n_vertices
    L = np.zeros((n, n))
    for i, j, length in M.edges:
        c = 1.0 / length
        L[i, j] = -c
        L[j, i] = -c
        L[i, i] += c
        L[j, j] += c
    return L


def compute_effective_resistance(M, s, t):
    n = M.n_vertices
    L = build_weighted_laplacian(M)
    b = np.zeros(n)
    b[s] = 1.0
    b[t] = -1.0
    A = L.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    f = np.linalg.solve(A, b)
    return f[s] - f[t]


def uniform_subdivision(M, n_per_edge):
    new_edges = []
    next_v = M.n_vertices
    for i, j, length in M.edges:
        seg = length / (n_per_edge + 1)
        prev = i
        for _ in range(n_per_edge):
            new_edges.append((prev, next_v, seg))
            prev = next_v
            next_v += 1
        new_edges.append((prev, j, seg))
    return MetricGraphModel(next_v, new_edges)


def cycle_graph(n, lengths=None):
    if lengths is None:
        lengths = [1.0] * n
    return MetricGraphModel(n, [(i, (i+1)%n, lengths[i]) for i in range(n)])


def theta_graph(l1, l2, l3):
    edges = [
        (0, 2, l1/2), (2, 1, l1/2),
        (0, 3, l2/2), (3, 1, l2/2),
        (0, 4, l3/2), (4, 1, l3/2),
    ]
    return MetricGraphModel(5, edges)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Effective Resistance and Refinement Stability\n'
             'Cross-domain: Tropical Geometry ↔ Electrical Networks ↔ Quantum Graphs',
             fontsize=13, fontweight='bold')

# Panel 1: Resistance matrix for cycle graph
ax = axes[0]
M = cycle_graph(6, [1.0, 1.5, 2.0, 0.5, 1.0, 3.0])
n = M.n_vertices
R = np.zeros((n, n))
for i in range(n):
    for j in range(i+1, n):
        R[i, j] = compute_effective_resistance(M, i, j)
        R[j, i] = R[i, j]

im = ax.imshow(R, cmap='hot_r', aspect='equal')
ax.set_title('Effective Resistance\nC₆ with ℓ=[1, 1.5, 2, 0.5, 1, 3]', fontsize=11)
ax.set_xlabel('Vertex j')
ax.set_ylabel('Vertex i')
ax.set_xticks(range(n))
ax.set_yticks(range(n))
for i in range(n):
    for j in range(n):
        ax.text(j, i, f'{R[i,j]:.2f}', ha='center', va='center', fontsize=8,
                color='white' if R[i,j] > np.max(R)*0.6 else 'black')
plt.colorbar(im, ax=ax, shrink=0.8, label='Resistance (Ω)')

# Panel 2: Refinement convergence
ax = axes[1]
test_graphs = [
    ("C₃ [1,2,1.5]", cycle_graph(3, [1.0, 2.0, 1.5]), 0, 1),
    ("C₄ [1,1,1,1]", cycle_graph(4), 0, 2),
    ("Θ(1,√2,√3)", theta_graph(1.0, np.sqrt(2), np.sqrt(3)), 0, 1),
]

subdivisions = [0, 1, 2, 4, 8, 16, 32]
for name, M_base, s, t in test_graphs:
    R_exact = compute_effective_resistance(M_base, s, t)
    resistances = []
    for n_sub in subdivisions:
        if n_sub == 0:
            M_sub = M_base
        else:
            M_sub = uniform_subdivision(M_base, n_sub)
        R_sub = compute_effective_resistance(M_sub, s, t)
        resistances.append(R_sub)
    errors = [abs(r - R_exact) for r in resistances]
    ax.plot(subdivisions, errors, 'o-', label=f'{name}, R({s},{t})', markersize=4)

ax.set_xlabel('Subdivision level')
ax.set_ylabel('|R_subdivided - R_exact|')
ax.set_title('Refinement Invariance\nof Effective Resistance', fontsize=11)
ax.set_yscale('log')
ax.set_ylim(bottom=1e-16, top=1e-10)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.02, 'Machine precision → subdivision-invariant',
        transform=ax.transAxes, ha='center', fontsize=9, style='italic')

# Panel 3: Energy spectrum under pendant attachment
ax = axes[2]
base = cycle_graph(4, [1.0, 1.5, 2.0, 2.5])
S = [0, 1, 2, 3]

pendant_lengths = np.logspace(-2, 2, 20)
spectra = []

for stick_len in pendant_lengths:
    edges = list(base.edges) + [(0, 4, stick_len)]
    M_lol = MetricGraphModel(5, edges)
    L = build_weighted_laplacian(M_lol)
    # Energy pairing on S
    generators = []
    for idx in range(1, len(S)):
        D = np.zeros(len(S))
        D[idx] = 1.0
        D[0] = -1.0
        b = np.zeros(5)
        for k, v in enumerate(S):
            b[v] = D[k]
        A = L.copy()
        A[-1, :] = 1.0
        b[-1] = 0.0
        f = np.linalg.solve(A, b)
        generators.append(f)
    r = len(generators)
    Q = np.zeros((r, r))
    for i in range(r):
        for j in range(r):
            Q[i, j] = generators[i] @ L @ generators[j]
    eigvals = np.sort(np.linalg.eigvalsh(Q))
    spectra.append(eigvals)

spectra = np.array(spectra)
for k in range(spectra.shape[1]):
    ax.plot(pendant_lengths, spectra[:, k], '-', linewidth=2,
            label=f'λ_{k+1}')

ax.set_xscale('log')
ax.set_xlabel('Pendant edge length')
ax.set_ylabel('Energy eigenvalue')
ax.set_title('Energy Spectrum Stability\nunder Pendant Attachment', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.02, 'Spectrum invariant → pendant trees irrelevant',
        transform=ax.transAxes, ha='center', fontsize=9, style='italic')

plt.tight_layout()
plt.savefig('viz_resistance_network.png', dpi=150, bbox_inches='tight')
print("Saved viz_resistance_network.png")
