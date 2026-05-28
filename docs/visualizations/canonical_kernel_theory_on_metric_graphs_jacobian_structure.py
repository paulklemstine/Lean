"""
Visualization: S-Supported Jacobian Structure and Pruning

Visualizes how the S-supported Jacobian quotient changes with different
support sets, and how pendant-tree pruning reduces computation without
altering the Jacobian structure. This is the core algorithmic insight
of canonical kernel theory.
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

    def degree(self, v): return len(self.adj[v])
    def is_leaf(self, v): return self.degree(v) == 1


def build_weighted_laplacian(M):
    n = M.n_vertices
    L = np.zeros((n, n))
    for i, j, length in M.edges:
        c = 1.0 / length
        L[i, j] = -c; L[j, i] = -c; L[i, i] += c; L[j, j] += c
    return L


def prune_pendant_trees(M):
    n = M.n_vertices
    degree = [M.degree(v) for v in range(n)]
    removed = [False] * n
    queue = [v for v in range(n) if degree[v] <= 1]
    while queue:
        v = queue.pop()
        if removed[v] or degree[v] > 1: continue
        removed[v] = True
        for nb, _ in M.adj[v]:
            if not removed[nb]:
                degree[nb] -= 1
                if degree[nb] <= 1: queue.append(nb)
    core_verts = [v for v in range(n) if not removed[v]]
    if not core_verts: return MetricGraphModel(0, []), {}
    vmap = {new: old for new, old in enumerate(core_verts)}
    inv = {old: new for new, old in enumerate(core_verts)}
    edges = []
    seen = set()
    for i, j, l in M.edges:
        if not removed[i] and not removed[j]:
            k = (min(i,j), max(i,j))
            if k not in seen: seen.add(k); edges.append((inv[i], inv[j], l))
    return MetricGraphModel(len(core_verts), edges), vmap


def first_betti(M):
    visited = [False]*M.n_vertices; comps = 0
    for s in range(M.n_vertices):
        if visited[s]: continue
        comps += 1; q = [s]; visited[s] = True
        while q:
            v = q.pop()
            for nb, _ in M.adj[v]:
                if not visited[nb]: visited[nb] = True; q.append(nb)
    return len(M.edges) - M.n_vertices + comps


fig, axes = plt.subplots(2, 2, figsize=(13, 11))
fig.suptitle('S-Supported Jacobian Structure and Pendant-Tree Pruning\n'
             'Canonical Kernel Theory on Metric Graphs',
             fontsize=14, fontweight='bold')

# Panel 1: Jacobian rank vs support size
ax = axes[0, 0]
for n_cycle, label in [(4, 'C₄'), (6, 'C₆'), (8, 'C₈')]:
    M = MetricGraphModel(n_cycle,
        [(i, (i+1)%n_cycle, 1.0) for i in range(n_cycle)])
    beta = first_betti(M)
    sizes = range(2, n_cycle + 1)
    ranks = []
    for s in sizes:
        S = list(range(s))
        L = build_weighted_laplacian(M)
        L_S = L[np.ix_(S, S)]
        eigs = np.linalg.eigvalsh(L_S)
        rank = int(np.sum(np.abs(eigs) > 1e-10))
        ranks.append(min(rank, s-1))
    ax.plot(list(sizes), ranks, 'o-', label=f'{label} (β₁={beta})', markersize=6)
    ax.axhline(y=beta, linestyle='--', alpha=0.3)

ax.set_xlabel('|S| (support size)')
ax.set_ylabel('Jacobian rank')
ax.set_title('Jacobian Rank vs Support Size', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Pruning effect on different graphs
ax = axes[0, 1]
graph_data = []

# Tree (path graph)
for n in range(3, 12):
    M = MetricGraphModel(n, [(i, i+1, 1.0) for i in range(n-1)])
    core, _ = prune_pendant_trees(M)
    graph_data.append(('Path', n, first_betti(M), core.n_vertices, first_betti(core) if core.n_vertices > 0 else 0))

# Cycle + pendant
for n_pend in range(0, 8):
    edges = [(i, (i+1)%4, 1.0) for i in range(4)]
    prev = 0
    for k in range(n_pend):
        edges.append((prev if k == 0 else 4+k-1, 4+k, 1.0))
    M = MetricGraphModel(4 + n_pend, edges)
    core, _ = prune_pendant_trees(M)
    graph_data.append(('C₄+path', n_pend,
        first_betti(M), core.n_vertices,
        first_betti(core) if core.n_vertices > 0 else 0))

paths = [(d[1], d[2]) for d in graph_data if d[0] == 'Path']
cyc_p = [(d[1], d[4]) for d in graph_data if d[0] == 'C₄+path']

ax.bar([p[0]-0.15 for p in paths], [p[1] for p in paths], 0.3,
       label='Path graph β₁', color='tab:blue', alpha=0.7)
ax.bar([p[0]+0.15 for p in cyc_p], [p[1] for p in cyc_p], 0.3,
       label='C₄+path core β₁', color='tab:orange', alpha=0.7)
ax.set_xlabel('Parameter (path length / pendant length)')
ax.set_ylabel('Betti number')
ax.set_title('Pruning Preserves Cycle Structure', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Energy spectrum comparison before/after pruning
ax = axes[1, 0]
n_cycle = 5
base_edges = [(i, (i+1)%n_cycle, 1.0 + 0.5*i) for i in range(n_cycle)]
M_base = MetricGraphModel(n_cycle, base_edges)

configs = [
    ("No pendant", []),
    ("+1 leaf", [(0, n_cycle, 2.0)]),
    ("+2 leaves", [(0, n_cycle, 2.0), (2, n_cycle+1, 3.0)]),
    ("+3 leaves", [(0, n_cycle, 2.0), (2, n_cycle+1, 3.0), (4, n_cycle+2, 1.0)]),
]

S = list(range(n_cycle))
spectra_labels = []

for idx, (label, extra_edges) in enumerate(configs):
    all_edges = list(base_edges) + extra_edges
    n_total = n_cycle + len(extra_edges)
    M = MetricGraphModel(n_total, all_edges)
    L = build_weighted_laplacian(M)

    generators = []
    for k in range(1, len(S)):
        D = np.zeros(len(S))
        D[k] = 1.0; D[0] = -1.0
        b = np.zeros(n_total)
        for ki, v in enumerate(S): b[v] = D[ki]
        A = L.copy(); A[-1, :] = 1.0; b[-1] = 0.0
        f = np.linalg.solve(A, b)
        generators.append(f)

    r = len(generators)
    Q = np.zeros((r, r))
    for i in range(r):
        for j in range(r):
            Q[i, j] = generators[i] @ L @ generators[j]

    eigvals = np.sort(np.linalg.eigvalsh(Q))
    x = np.arange(len(eigvals)) + idx * 0.2 - 0.3
    ax.bar(x, eigvals, 0.18, label=label, alpha=0.8)

ax.set_xlabel('Eigenvalue index')
ax.set_ylabel('Energy eigenvalue')
ax.set_title('Energy Spectrum: Pendant Invariance', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Laplacian eigenvalue distribution
ax = axes[1, 1]
for n_cycle, ls, label in [
    (5, [1]*5, 'C₅ uniform'),
    (5, [1,2,3,4,5], 'C₅ graded'),
    (8, [1]*8, 'C₈ uniform'),
]:
    M = MetricGraphModel(n_cycle,
        [(i, (i+1)%n_cycle, ls[i]) for i in range(n_cycle)])
    L = build_weighted_laplacian(M)
    eigs = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(eigs)), eigs, 'o-', label=label, markersize=5)

ax.set_xlabel('Index')
ax.set_ylabel('Eigenvalue')
ax.set_title('Laplacian Spectrum\n(always ≥ 0, kernel = constants)', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_jacobian_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_jacobian_structure.png")
