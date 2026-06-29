"""
Spectral Renormalization of Proof Spaces — Core Algorithms

Type-hinted implementations of the key algorithms for analyzing
derivation graphs through ball growth, expansion, renormalization,
and proof space entropy.
"""

from __future__ import annotations
import numpy as np
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from collections import defaultdict


class DiGraph:
    """Directed graph with Bool-valued adjacency.

    Mirrors the Lean `DiGraph` structure. Vertices are integers 0..n-1.
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]]) -> None:
        """Create a directed graph on n vertices with given edge list."""
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        for u, v in edges:
            assert 0 <= u < n and 0 <= v < n
            self.adj[u].add(v)

    def out_neighbors(self, v: int) -> Set[int]:
        """Return the set of out-neighbors of vertex v."""
        return self.adj[v]

    def out_deg(self, v: int) -> int:
        """Return the out-degree of vertex v."""
        return len(self.adj[v])

    def max_out_deg(self) -> int:
        """Return the maximum out-degree."""
        return max((self.out_deg(v) for v in range(self.n)), default=0)

    def ball(self, sources: Set[int], k: int) -> Set[int]:
        """Compute the k-step forward ball from a source set.

        Corresponds to DiGraph.ball in the Lean formalization.
        Time: O(k * |E|) where |E| is the number of edges.
        """
        current = set(sources)
        for _ in range(k):
            expansion = set()
            for v in current:
                expansion |= self.adj[v]
            current = current | expansion
        return current

    def expansion(self, s: Set[int]) -> Set[int]:
        """Compute the expansion set: new vertices reachable in one step.

        expansion(S) = (⋃_{v ∈ S} outNeighbors(v)) \ S
        """
        neighbors = set()
        for v in s:
            neighbors |= self.adj[v]
        return neighbors - s

    def vertex_expansion_ratio(self, s: Set[int]) -> float:
        """Compute the vertex expansion ratio |expansion(S)| / |S|."""
        if len(s) == 0:
            return 0.0
        return len(self.expansion(s)) / len(s)

    def ball_growth_profile(self, v: int, max_steps: int) -> List[int]:
        """Compute ball sizes from vertex v for steps 0, 1, ..., max_steps.

        Returns a list of (max_steps + 1) integers.
        """
        sizes: List[int] = []
        current = {v}
        for k in range(max_steps + 1):
            sizes.append(len(current))
            expansion = set()
            for u in current:
                expansion |= self.adj[u]
            current = current | expansion
        return sizes

    def proof_space_entropy(self, v: int, k: int) -> float:
        """Compute the proof space entropy at step k from vertex v.

        H(G, v, k) = log(|ball({v}, k+1)| / |ball({v}, k)|)
        """
        bk = len(self.ball({v}, k))
        bk1 = len(self.ball({v}, k + 1))
        if bk == 0:
            return 0.0
        return float(np.log(bk1 / bk))

    def total_proof_entropy(self, v: int, n: int) -> float:
        """Compute total proof entropy up to n steps.

        By the telescoping theorem, this equals log(|ball({v}, n)|).
        """
        total = 0.0
        sizes = self.ball_growth_profile(v, n)
        for k in range(n):
            if sizes[k] > 0:
                total += np.log(sizes[k + 1] / sizes[k])
        return total

    def entropy_profile(self, v: int, max_steps: int) -> List[float]:
        """Compute the full entropy profile from vertex v."""
        sizes = self.ball_growth_profile(v, max_steps)
        profile: List[float] = []
        for k in range(max_steps):
            if sizes[k] > 0:
                profile.append(float(np.log(sizes[k + 1] / sizes[k])))
            else:
                profile.append(0.0)
        return profile


def quotient_graph(g: DiGraph, f: Dict[int, int], m: int) -> DiGraph:
    """Construct the quotient graph under map f : {0..n-1} -> {0..m-1}.

    Corresponds to DiGraph.quotientGraph in the Lean formalization.

    Args:
        g: Original directed graph on n vertices.
        f: Quotient map, mapping each vertex of g to a vertex in {0..m-1}.
        m: Number of vertices in the quotient graph.

    Returns:
        The quotient DiGraph on m vertices.
    """
    edges: List[Tuple[int, int]] = []
    seen: Set[Tuple[int, int]] = set()
    for u in range(g.n):
        for v in g.adj[u]:
            w1, w2 = f[u], f[v]
            if (w1, w2) not in seen:
                seen.add((w1, w2))
                edges.append((w1, w2))
    return DiGraph(m, edges)


def estimate_min_expansion(
    g: DiGraph,
    max_set_size: int,
    num_samples: int = 1000,
    rng: Optional[np.random.Generator] = None,
) -> float:
    """Estimate the minimum vertex expansion ratio by random sampling.

    Samples random subsets of sizes 1 to max_set_size and returns
    the minimum observed expansion ratio.
    """
    if rng is None:
        rng = np.random.default_rng(42)

    min_ratio = float("inf")
    vertices = list(range(g.n))

    for _ in range(num_samples):
        size = rng.integers(1, max_set_size + 1)
        sample = set(rng.choice(vertices, size=size, replace=False))
        ratio = g.vertex_expansion_ratio(sample)
        min_ratio = min(min_ratio, ratio)

    return min_ratio


def ball_growth_upper_bound(s_card: int, d: int, k: int) -> int:
    """Compute the theoretical upper bound |S| * (d + 1)^k.

    This is the bound proved in ball_card_bound.
    """
    return s_card * (d + 1) ** k


def expansion_lower_bound(h: float, k: int) -> float:
    """Compute the theoretical lower bound (1 + h)^k on ball size.

    This is the bound proved in expansion_proof_length_bound.
    """
    return (1 + h) ** k


def laplacian_matrix(g: DiGraph) -> np.ndarray:
    """Compute the Laplacian matrix L = D - A of the directed graph.

    Where D is the diagonal out-degree matrix and A is the adjacency matrix.
    """
    n = g.n
    L = np.zeros((n, n), dtype=float)
    for v in range(n):
        deg = g.out_deg(v)
        L[v, v] = deg
        for w in g.adj[v]:
            L[v, w] -= 1.0
    return L


def spectral_gap(g: DiGraph) -> float:
    """Estimate the spectral gap of the symmetrized Laplacian.

    Returns the second smallest eigenvalue of (L + L^T) / 2.
    """
    L = laplacian_matrix(g)
    L_sym = (L + L.T) / 2.0
    eigenvalues = np.sort(np.linalg.eigvalsh(L_sym))
    # Second smallest eigenvalue (first is ~0 for connected graphs)
    return float(eigenvalues[1]) if len(eigenvalues) > 1 else 0.0
