"""
Algorithms for Spectral Analysis of Theorem Dependency Graphs

Type-hinted implementations of the core algorithms formalized in Lean 4.
"""

from __future__ import annotations
from typing import Optional
import math


class DGraph:
    """Directed graph on n vertices with no self-loops."""

    def __init__(self, n: int, edges: list[tuple[int, int]]):
        self.n = n
        self.adj: list[list[bool]] = [[False] * n for _ in range(n)]
        for i, j in edges:
            if i != j:
                self.adj[i][j] = True

    def out_deg(self, i: int) -> int:
        """Out-degree of vertex i."""
        return sum(1 for j in range(self.n) if self.adj[i][j])

    def in_deg(self, i: int) -> int:
        """In-degree of vertex i."""
        return sum(1 for j in range(self.n) if self.adj[j][i])

    def edge_count(self) -> int:
        """Total number of edges."""
        return sum(1 for i in range(self.n) for j in range(self.n) if self.adj[i][j])

    def walk_count(self, k: int, i: int, j: int) -> int:
        """Number of directed walks of length k from i to j.

        Uses the recursive matrix-power definition:
          walkCount(0, i, j) = 1 if i == j else 0
          walkCount(k+1, i, j) = sum_w walkCount(k, i, w) * adj(w, j)
        """
        if k == 0:
            return 1 if i == j else 0
        return sum(
            self.walk_count(k - 1, i, w) * (1 if self.adj[w][j] else 0)
            for w in range(self.n)
        )

    def closed_walk_count(self, k: int) -> int:
        """Number of closed walks of length k (trace of A^k)."""
        return sum(self.walk_count(k, i, i) for i in range(self.n))

    def degree_variance(self) -> float:
        """Population variance of the out-degree sequence.

        Var(d) = (1/n) * sum(d_i^2) - ((1/n) * sum(d_i))^2
        """
        if self.n == 0:
            return 0.0
        degs = [self.out_deg(i) for i in range(self.n)]
        mean_sq = sum(d ** 2 for d in degs) / self.n
        sq_mean = (sum(degs) / self.n) ** 2
        return mean_sq - sq_mean

    def is_dag(self) -> bool:
        """Check if the graph is a DAG using DFS."""
        WHITE, GRAY, BLACK = 0, 1, 2
        color = [WHITE] * self.n

        def dfs(u: int) -> bool:
            color[u] = GRAY
            for v in range(self.n):
                if self.adj[u][v]:
                    if color[v] == GRAY:
                        return False
                    if color[v] == WHITE and not dfs(v):
                        return False
            color[u] = BLACK
            return True

        return all(dfs(u) if color[u] == WHITE else True for u in range(self.n))


class Partition:
    """Surjective partition of {0, ..., n-1} into m blocks."""

    def __init__(self, n: int, block_of: list[int]):
        self.n = n
        self.block_of = block_of
        self.m = max(block_of) + 1 if block_of else 0

    def block_size(self, b: int) -> int:
        """Size of block b."""
        return sum(1 for i in range(self.n) if self.block_of[i] == b)


def quotient_graph(g: DGraph, p: Partition) -> DGraph:
    """Compute the quotient graph induced by partition p.

    Vertices are blocks. Edge b1 -> b2 iff exists i in b1, j in b2 with adj(i,j) and b1 != b2.
    """
    m = p.m
    edges: list[tuple[int, int]] = []
    for b1 in range(m):
        for b2 in range(m):
            if b1 == b2:
                continue
            found = False
            for i in range(g.n):
                if p.block_of[i] != b1:
                    continue
                for j in range(g.n):
                    if p.block_of[j] == b2 and g.adj[i][j]:
                        found = True
                        break
                if found:
                    break
            if found:
                edges.append((b1, b2))
    return DGraph(m, edges)


def spectral_distance(mu: list[float], nu: list[float], K: int) -> float:
    """Spectral distance between two moment sequences truncated at level K.

    d_K(mu, nu) = max_{k <= K} |mu[k] - nu[k]|
    """
    return max(abs(mu[k] - nu[k]) for k in range(min(K + 1, len(mu), len(nu))))


def coarse_grain_chain(g: DGraph, partition_fn) -> list[int]:
    """Iterate coarse-graining until stabilization.

    partition_fn: DGraph -> Partition (computes the SCC partition or similar)
    Returns the sequence of vertex counts.
    """
    counts = [g.n]
    current = g
    for _ in range(g.n + 1):
        p = partition_fn(current)
        new_g = quotient_graph(current, p)
        counts.append(new_g.n)
        if new_g.n == current.n:
            break
        current = new_g
    return counts


def compute_scc_partition(g: DGraph) -> Partition:
    """Compute SCC partition using Tarjan's algorithm."""
    index_counter = [0]
    stack: list[int] = []
    on_stack = [False] * g.n
    index = [-1] * g.n
    lowlink = [-1] * g.n
    scc_id = [-1] * g.n
    scc_count = [0]

    def strongconnect(v: int) -> None:
        index[v] = index_counter[0]
        lowlink[v] = index_counter[0]
        index_counter[0] += 1
        stack.append(v)
        on_stack[v] = True

        for w in range(g.n):
            if g.adj[v][w]:
                if index[w] == -1:
                    strongconnect(w)
                    lowlink[v] = min(lowlink[v], lowlink[w])
                elif on_stack[w]:
                    lowlink[v] = min(lowlink[v], index[w])

        if lowlink[v] == index[v]:
            while True:
                w = stack.pop()
                on_stack[w] = False
                scc_id[w] = scc_count[0]
                if w == v:
                    break
            scc_count[0] += 1

    for v in range(g.n):
        if index[v] == -1:
            strongconnect(v)

    return Partition(g.n, scc_id)


def compute_spectral_moments(g: DGraph, max_k: int) -> list[float]:
    """Compute normalized spectral moments mu_k = closedWalkCount(k) / n."""
    if g.n == 0:
        return [0.0] * (max_k + 1)
    return [g.closed_walk_count(k) / g.n for k in range(max_k + 1)]
