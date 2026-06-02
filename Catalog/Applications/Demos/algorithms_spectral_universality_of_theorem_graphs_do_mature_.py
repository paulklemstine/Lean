"""
Spectral Universality of Theorem Graphs — Core Algorithms

Type-hinted implementations of the key algorithms:
1. Directed graph construction from adjacency lists
2. SCC computation (Tarjan's algorithm)
3. Coarse-graining (quotient graph)
4. Spectral moment computation
5. Wasserstein distance for spectral comparison
"""

from __future__ import annotations

import numpy as np
from typing import List, Dict, Set, Tuple, Optional
from dataclasses import dataclass, field
from collections import defaultdict


@dataclass
class DigraphOn:
    """A directed graph on n vertices, modeling theorem dependency networks."""
    n: int
    adj: np.ndarray  # n x n boolean adjacency matrix

    def __post_init__(self) -> None:
        assert self.adj.shape == (self.n, self.n)
        np.fill_diagonal(self.adj, False)  # irreflexivity

    @classmethod
    def from_edge_list(cls, n: int, edges: List[Tuple[int, int]]) -> "DigraphOn":
        adj = np.zeros((n, n), dtype=bool)
        for i, j in edges:
            if i != j:
                adj[i][j] = True
        return cls(n=n, adj=adj)

    def out_deg(self, i: int) -> int:
        return int(np.sum(self.adj[i]))

    def in_deg(self, i: int) -> int:
        return int(np.sum(self.adj[:, i]))

    def edge_count(self) -> int:
        return int(np.sum(self.adj))

    def out_degrees(self) -> np.ndarray:
        return np.sum(self.adj, axis=1).astype(int)

    def in_degrees(self) -> np.ndarray:
        return np.sum(self.adj, axis=0).astype(int)


def tarjan_scc(g: DigraphOn) -> List[List[int]]:
    """
    Compute strongly connected components using Tarjan's algorithm.
    Returns list of SCCs, each SCC is a list of vertex indices.
    Time: O(n + m)
    """
    n = g.n
    index_counter = [0]
    stack: List[int] = []
    on_stack = [False] * n
    index = [-1] * n
    lowlink = [-1] * n
    result: List[List[int]] = []

    def strongconnect(v: int) -> None:
        index[v] = index_counter[0]
        lowlink[v] = index_counter[0]
        index_counter[0] += 1
        stack.append(v)
        on_stack[v] = True

        for w in range(n):
            if not g.adj[v][w]:
                continue
            if index[w] == -1:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif on_stack[w]:
                lowlink[v] = min(lowlink[v], index[w])

        if lowlink[v] == index[v]:
            component: List[int] = []
            while True:
                w = stack.pop()
                on_stack[w] = False
                component.append(w)
                if w == v:
                    break
            result.append(component)

    for v in range(n):
        if index[v] == -1:
            strongconnect(v)

    return result


@dataclass
class SCCPartition:
    """Partition of vertices into SCC blocks."""
    num_blocks: int
    block_of: np.ndarray  # vertex -> block index
    block_sizes: np.ndarray  # block -> size

    @classmethod
    def from_sccs(cls, n: int, sccs: List[List[int]]) -> "SCCPartition":
        block_of = np.zeros(n, dtype=int)
        block_sizes = np.zeros(len(sccs), dtype=int)
        for b, scc in enumerate(sccs):
            block_sizes[b] = len(scc)
            for v in scc:
                block_of[v] = b
        return cls(num_blocks=len(sccs), block_of=block_of, block_sizes=block_sizes)

    def is_nontrivial(self) -> bool:
        return self.num_blocks < len(self.block_of)


def coarse_grain(g: DigraphOn, partition: SCCPartition) -> DigraphOn:
    """
    Construct the coarse-grained (quotient) graph.
    Vertices are SCC blocks; edge b1->b2 iff any vertex in b1 is adjacent to any in b2.
    """
    m = partition.num_blocks
    adj = np.zeros((m, m), dtype=bool)

    for i in range(g.n):
        for j in range(g.n):
            if g.adj[i][j]:
                b1 = partition.block_of[i]
                b2 = partition.block_of[j]
                if b1 != b2:
                    adj[b1][b2] = True

    return DigraphOn(n=m, adj=adj)


def spectral_moment(g: DigraphOn, k: int) -> float:
    """
    Compute the k-th spectral moment: tr(A^k) / n.
    Counts closed walks of length k, normalized by vertex count.
    """
    if g.n == 0:
        return 0.0
    A = g.adj.astype(float)
    Ak = np.linalg.matrix_power(A, k)
    return float(np.trace(Ak)) / g.n


def normalized_laplacian_spectrum(g: DigraphOn) -> np.ndarray:
    """
    Compute the eigenvalues of the normalized Laplacian of the symmetrized graph.
    L_norm = I - D^{-1/2} A_sym D^{-1/2}
    """
    A_sym = (g.adj | g.adj.T).astype(float)
    degrees = np.sum(A_sym, axis=1)

    # Handle isolated vertices
    D_inv_sqrt = np.zeros(g.n)
    for i in range(g.n):
        if degrees[i] > 0:
            D_inv_sqrt[i] = 1.0 / np.sqrt(degrees[i])

    D_inv_sqrt_mat = np.diag(D_inv_sqrt)
    L_norm = np.eye(g.n) - D_inv_sqrt_mat @ A_sym @ D_inv_sqrt_mat

    eigenvalues = np.linalg.eigvalsh(L_norm)
    return np.sort(eigenvalues)


def wasserstein_distance(spec1: np.ndarray, spec2: np.ndarray) -> float:
    """
    Compute the 1-Wasserstein distance between two spectral distributions.
    Uses sorted eigenvalue lists and linear interpolation.
    """
    if len(spec1) == 0 or len(spec2) == 0:
        return float('inf')

    # Normalize to [0, 1]
    max_val = max(np.max(np.abs(spec1)), np.max(np.abs(spec2)), 1e-10)
    s1 = np.sort(spec1) / max_val
    s2 = np.sort(spec2) / max_val

    # Interpolate to common grid
    n_points = max(len(s1), len(s2), 100)
    grid = np.linspace(0, 1, n_points)

    cdf1 = np.interp(grid, np.linspace(0, 1, len(s1)), s1)
    cdf2 = np.interp(grid, np.linspace(0, 1, len(s2)), s2)

    return float(np.mean(np.abs(cdf1 - cdf2)))


def renormalize(g: DigraphOn) -> Tuple[DigraphOn, SCCPartition]:
    """
    One step of renormalization: compute SCCs and coarse-grain.
    Returns the coarse-grained graph and the partition used.
    """
    sccs = tarjan_scc(g)
    partition = SCCPartition.from_sccs(g.n, sccs)
    g_coarse = coarse_grain(g, partition)
    return g_coarse, partition


def iterated_renormalization(
    g: DigraphOn,
    max_steps: int = 100
) -> List[Tuple[DigraphOn, Optional[SCCPartition]]]:
    """
    Apply renormalization iteratively until fixed point or max_steps.
    Returns the sequence of (graph, partition_used) pairs.
    """
    history: List[Tuple[DigraphOn, Optional[SCCPartition]]] = [(g, None)]
    current = g

    for _ in range(max_steps):
        g_new, partition = renormalize(current)
        if g_new.n == current.n:  # Fixed point reached
            break
        history.append((g_new, partition))
        current = g_new

    return history


def degree_entropy(g: DigraphOn) -> float:
    """
    Shannon entropy of the normalized out-degree distribution.
    H = -Σ p(d) log₂ p(d) where p(d) = fraction of vertices with out-degree d.
    """
    if g.n == 0:
        return 0.0

    degrees = g.out_degrees()
    unique, counts = np.unique(degrees, return_counts=True)
    probs = counts / g.n
    # Filter out zero probabilities
    probs = probs[probs > 0]
    return float(-np.sum(probs * np.log2(probs)))


def generate_random_dag(n: int, p: float, seed: Optional[int] = None) -> DigraphOn:
    """
    Generate a random DAG on n vertices with edge probability p.
    Uses a random topological ordering (permutation of [0..n-1]).
    Edge (i, j) exists with probability p if i < j in the ordering.
    """
    rng = np.random.default_rng(seed)
    perm = rng.permutation(n)
    adj = np.zeros((n, n), dtype=bool)

    for idx_i in range(n):
        for idx_j in range(idx_i + 1, n):
            if rng.random() < p:
                i, j = perm[idx_i], perm[idx_j]
                adj[i][j] = True

    return DigraphOn(n=n, adj=adj)


def generate_layered_dag(
    layers: List[int], p: float, seed: Optional[int] = None
) -> DigraphOn:
    """
    Generate a layered DAG where each layer connects to the next with probability p.
    layers[i] = number of vertices in layer i.
    """
    rng = np.random.default_rng(seed)
    n = sum(layers)
    adj = np.zeros((n, n), dtype=bool)

    offsets = [0]
    for size in layers:
        offsets.append(offsets[-1] + size)

    for layer_idx in range(len(layers) - 1):
        for i in range(offsets[layer_idx], offsets[layer_idx + 1]):
            for j in range(offsets[layer_idx + 1], offsets[layer_idx + 2]):
                if rng.random() < p:
                    adj[i][j] = True

    return DigraphOn(n=n, adj=adj)


if __name__ == "__main__":
    # Quick self-test
    g = generate_random_dag(20, 0.3, seed=42)
    print(f"Random DAG: {g.n} vertices, {g.edge_count()} edges")
    print(f"Out-degrees: {g.out_degrees()}")
    print(f"Spectral moment μ₀ = {spectral_moment(g, 0):.4f}")
    print(f"Spectral moment μ₁ = {spectral_moment(g, 1):.4f}")
    print(f"Spectral moment μ₂ = {spectral_moment(g, 2):.4f}")
    print(f"Degree entropy: {degree_entropy(g):.4f}")

    spec = normalized_laplacian_spectrum(g)
    print(f"Laplacian spectrum (first 5): {spec[:5]}")
    print(f"Trace = {np.sum(spec):.4f} (should be {g.n})")
