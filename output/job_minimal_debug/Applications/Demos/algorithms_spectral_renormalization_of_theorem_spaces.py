"""
Spectral Renormalization of Proof Spaces — Core Algorithms

Type-hinted implementations of derivation graph analysis, ball growth computation,
spectral Laplacian construction, and coarse-graining (renormalization) operations.
"""

from __future__ import annotations

import numpy as np
from typing import Optional
from collections import deque


class DerivationGraph:
    """
    A directed graph modeling one-step proof derivability in a formal theory.

    Nodes are formal statements (integers 0..n-1).
    A directed edge (i, j) means statement j is derivable from statement i
    in a single proof step.
    """

    def __init__(self, n: int, edges: list[tuple[int, int]]):
        """
        Create a derivation graph with n nodes and given directed edges.

        Args:
            n: Number of statement nodes
            edges: List of (source, target) pairs for one-step derivations
        """
        self.n = n
        self.adj: dict[int, set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            assert 0 <= u < n and 0 <= v < n, f"Invalid edge ({u}, {v})"
            self.adj[u].add(v)

    def out_degree(self, v: int) -> int:
        """Out-degree of vertex v."""
        return len(self.adj[v])

    def max_out_degree(self) -> int:
        """Maximum out-degree across all vertices."""
        return max(self.out_degree(v) for v in range(self.n)) if self.n > 0 else 0

    def ball(self, v: int, k: int) -> set[int]:
        """
        Forward-reachable ball of radius k from vertex v.

        Returns the set of all vertices reachable from v in at most k steps.
        Matches the Lean definition: ball v 0 = {v},
        ball v (k+1) = ball v k ∪ ⋃_{u ∈ ball v k} outNbrs(u).
        """
        current = {v}
        for _ in range(k):
            expansion = set()
            for u in current:
                expansion |= self.adj[u]
            current = current | expansion
        return current

    def proof_distance(self, s: int, t: int) -> Optional[int]:
        """
        Minimum derivation chain length from s to t, or None if unreachable.

        Uses BFS on the directed graph.
        """
        if s == t:
            return 0
        visited = {s}
        queue = deque([(s, 0)])
        while queue:
            u, dist = queue.popleft()
            for w in self.adj[u]:
                if w == t:
                    return dist + 1
                if w not in visited:
                    visited.add(w)
                    queue.append((w, dist + 1))
        return None

    def diameter(self) -> Optional[int]:
        """
        Maximum proof distance over all reachable pairs, or None if disconnected.
        """
        max_dist = 0
        for s in range(self.n):
            for t in range(self.n):
                d = self.proof_distance(s, t)
                if d is None:
                    return None
                max_dist = max(max_dist, d)
        return max_dist

    def graph_laplacian(self) -> np.ndarray:
        """
        Compute the (combinatorial) graph Laplacian matrix L = D - A
        where D is the out-degree diagonal and A is the adjacency matrix.

        For directed graphs, we use the symmetrized version:
        L_sym = D_sym - (A + A^T)/2
        where D_sym is the degree matrix of the symmetrized graph.
        """
        A = np.zeros((self.n, self.n))
        for u in range(self.n):
            for v in self.adj[u]:
                A[u, v] = 1.0
        A_sym = (A + A.T) / 2.0
        D_sym = np.diag(A_sym.sum(axis=1))
        return D_sym - A_sym

    def laplacian_spectrum(self) -> np.ndarray:
        """
        Compute and return the sorted eigenvalues of the symmetrized Laplacian.
        """
        L = self.graph_laplacian()
        eigenvalues = np.linalg.eigvalsh(L)
        return np.sort(eigenvalues)

    def spectral_gap(self) -> float:
        """
        The spectral gap: second-smallest eigenvalue of the Laplacian.
        This is related to graph expansion via Cheeger's inequality.
        """
        spectrum = self.laplacian_spectrum()
        if len(spectrum) < 2:
            return 0.0
        return float(spectrum[1])

    def expansion_ratio(self) -> float:
        """
        Vertex expansion ratio: min over small sets S of |N(S)\S| / |S|.
        """
        if self.n <= 1:
            return 0.0
        min_ratio = float('inf')
        # Iterate over all non-empty subsets of size ≤ n/2
        for mask in range(1, 2**self.n):
            S = {i for i in range(self.n) if mask & (1 << i)}
            if len(S) > self.n // 2:
                continue
            boundary = set()
            for u in S:
                boundary |= self.adj[u]
            boundary -= S
            ratio = len(boundary) / len(S)
            min_ratio = min(min_ratio, ratio)
        return min_ratio


def coarse_grain(
    G: DerivationGraph,
    partition: list[set[int]]
) -> DerivationGraph:
    """
    Coarse-grain a derivation graph by merging nodes according to a partition.

    Each block of the partition becomes a single node in the coarse graph.
    An edge exists from block i to block j (i ≠ j) if any node in block i
    has an edge to any node in block j.

    This implements the CoarseGraining structure from the Lean formalization.

    Args:
        G: Original derivation graph
        partition: List of disjoint sets covering {0, ..., n-1}

    Returns:
        The coarse-grained derivation graph
    """
    m = len(partition)
    # Build node-to-block mapping
    node_to_block: dict[int, int] = {}
    for block_idx, block in enumerate(partition):
        for node in block:
            node_to_block[node] = block_idx

    # Build coarse edges
    coarse_edges: list[tuple[int, int]] = []
    for u in range(G.n):
        for v in G.adj[u]:
            bu, bv = node_to_block[u], node_to_block[v]
            if bu != bv:
                coarse_edges.append((bu, bv))

    return DerivationGraph(m, coarse_edges)


def renormalization_flow(
    G: DerivationGraph,
    num_steps: int = 5,
    merge_factor: int = 2
) -> list[tuple[DerivationGraph, np.ndarray]]:
    """
    Compute a renormalization flow: iteratively coarse-grain and track spectra.

    At each step, merge groups of `merge_factor` consecutive nodes.

    Args:
        G: Starting derivation graph
        num_steps: Number of coarse-graining steps
        merge_factor: How many nodes to merge per block

    Returns:
        List of (coarse_graph, spectrum) pairs at each scale
    """
    flow: list[tuple[DerivationGraph, np.ndarray]] = []
    current = G
    flow.append((current, current.laplacian_spectrum()))

    for _ in range(num_steps):
        if current.n <= merge_factor:
            break
        # Build partition by merging consecutive nodes
        partition: list[set[int]] = []
        for i in range(0, current.n, merge_factor):
            block = set(range(i, min(i + merge_factor, current.n)))
            partition.append(block)

        current = coarse_grain(current, partition)
        if current.n > 0:
            flow.append((current, current.laplacian_spectrum()))

    return flow


def normalized_spectrum(spectrum: np.ndarray) -> np.ndarray:
    """
    Normalize a Laplacian spectrum to [0, 1] range for cross-scale comparison.
    """
    if len(spectrum) <= 1:
        return spectrum
    max_val = spectrum[-1]
    if max_val <= 1e-12:
        return spectrum
    return spectrum / max_val


def spectral_distance(spec1: np.ndarray, spec2: np.ndarray) -> float:
    """
    Wasserstein-1 distance between two normalized spectra.
    Pads the shorter spectrum with zeros for comparison.
    """
    n1, n2 = len(spec1), len(spec2)
    max_n = max(n1, n2)
    s1 = np.zeros(max_n)
    s2 = np.zeros(max_n)
    s1[:n1] = normalized_spectrum(spec1)
    s2[:n2] = normalized_spectrum(spec2)
    # Interpolate to common grid
    from numpy import interp
    grid = np.linspace(0, 1, 100)
    cdf1 = np.array([np.sum(s1 <= x) / max_n for x in grid])
    cdf2 = np.array([np.sum(s2 <= x) / max_n for x in grid])
    return float(np.mean(np.abs(cdf1 - cdf2)))
