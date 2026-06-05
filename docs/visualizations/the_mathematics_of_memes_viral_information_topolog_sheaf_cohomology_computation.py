#!/usr/bin/env python3
"""
Algorithms for Viral Information Topology

Type-hinted implementations of sheaf cohomology computations on graphs.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict


@dataclass
class DirectedGraph:
    """A directed multigraph with labeled vertices and edges."""
    n_vertices: int
    edges: List[Tuple[int, int]]  # (source, target) pairs
    
    @property
    def n_edges(self) -> int:
        return len(self.edges)
    
    def adjacency_matrix(self) -> np.ndarray:
        A = np.zeros((self.n_vertices, self.n_vertices))
        for s, t in self.edges:
            A[s, t] += 1
        return A


@dataclass 
class ConstantSheafCohomology:
    """Cohomology dimensions for the constant sheaf on a graph."""
    h0: int          # dim H^0 = dim ker(δ)
    h1: int          # dim H^1 = dim coker(δ)
    rank_delta: int  # rank of coboundary map
    euler_char: int  # χ = h0 - h1 = |V| - |E|


@dataclass
class PropagationSheaf:
    """A propagation sheaf on a directed graph with edge weights."""
    graph: DirectedGraph
    weights: List[float]  # one weight per edge
    
    def __post_init__(self) -> None:
        assert len(self.weights) == self.graph.n_edges, \
            f"Expected {self.graph.n_edges} weights, got {len(self.weights)}"


def coboundary_matrix(graph: DirectedGraph) -> np.ndarray:
    """
    Compute the coboundary matrix δ: R^V → R^E for the constant sheaf.
    
    Algorithm:
        For each edge e_i = (s, t):
            δ[i, t] = +1 (target contributes positively)
            δ[i, s] = -1 (source contributes negatively)
    
    Time complexity: O(|E|)
    Space complexity: O(|E| × |V|)
    """
    delta = np.zeros((graph.n_edges, graph.n_vertices))
    for i, (s, t) in enumerate(graph.edges):
        delta[i, t] = 1.0
        delta[i, s] = -1.0
    return delta


def weighted_coboundary_matrix(sheaf: PropagationSheaf) -> np.ndarray:
    """
    Compute the weighted coboundary matrix δ_w: R^V → R^E.
    
    Algorithm:
        For each edge e_i = (s, t) with weight w_i:
            δ_w[i, t] = +w_i (target scaled by weight)
            δ_w[i, s] = -1   (source contributes with unit weight)
    
    The asymmetry models directed information transmission:
    the receiver transforms the message by factor w.
    """
    G = sheaf.graph
    delta = np.zeros((G.n_edges, G.n_vertices))
    for i, ((s, t), w) in enumerate(zip(G.edges, sheaf.weights)):
        delta[i, t] = w
        delta[i, s] = -1.0
    return delta


def compute_constant_sheaf_cohomology(graph: DirectedGraph) -> ConstantSheafCohomology:
    """
    Compute H^0 and H^1 for the constant sheaf.
    
    Algorithm:
        1. Build coboundary matrix δ
        2. Compute rank(δ) via SVD
        3. H^0 = |V| - rank(δ)   (rank-nullity theorem)
        4. H^1 = |E| - rank(δ)   (dimension of cokernel)
    
    Time complexity: O(min(|V|, |E|) × |V| × |E|) for SVD
    """
    delta = coboundary_matrix(graph)
    rank = int(np.linalg.matrix_rank(delta, tol=1e-10))
    h0 = graph.n_vertices - rank
    h1 = graph.n_edges - rank
    return ConstantSheafCohomology(h0=h0, h1=h1, rank_delta=rank,
                                    euler_char=h0 - h1)


def compute_propagation_cohomology(sheaf: PropagationSheaf) -> ConstantSheafCohomology:
    """
    Compute H^0 and H^1 for a propagation sheaf.
    
    Algorithm:
        Same as constant sheaf but using weighted coboundary matrix.
    """
    delta = weighted_coboundary_matrix(sheaf)
    rank = int(np.linalg.matrix_rank(delta, tol=1e-10))
    h0 = sheaf.graph.n_vertices - rank
    h1 = sheaf.graph.n_edges - rank
    return ConstantSheafCohomology(h0=h0, h1=h1, rank_delta=rank,
                                    euler_char=h0 - h1)


def virality_index(coh: ConstantSheafCohomology, n_edges: int) -> int:
    """
    Compute the virality index V = H^0 × (|E| + 1 - H^1).
    
    Maximized when H^1 = 0 (no barriers) and H^0 is large (many interpretations).
    Upper bound: |V| × (|E| + 1).
    """
    return coh.h0 * (n_edges + 1 - coh.h1)


def graph_laplacian(graph: DirectedGraph) -> np.ndarray:
    """
    Compute the graph Laplacian L = δᵀδ.
    
    The kernel of L equals ker(δ) = H^0.
    Eigenvalues reveal community structure (spectral clustering).
    """
    delta = coboundary_matrix(graph)
    return delta.T @ delta


def detect_communities_spectral(graph: DirectedGraph, n_communities: int) -> np.ndarray:
    """
    Spectral community detection using the sheaf Laplacian.
    
    Algorithm:
        1. Compute Laplacian L = δᵀδ
        2. Find eigenvectors for smallest eigenvalues
        3. Cluster vertices using k-means on eigenvector coordinates
    
    Returns: array of community labels for each vertex.
    """
    L = graph_laplacian(graph)
    eigenvalues, eigenvectors = np.linalg.eigh(L)
    
    # Use the first n_communities eigenvectors (smallest eigenvalues)
    features = eigenvectors[:, :n_communities]
    
    # Simple k-means clustering
    from scipy.cluster.vq import kmeans2  # type: ignore
    try:
        _, labels = kmeans2(features, n_communities, minit='points')
    except ImportError:
        # Fallback: assign by eigenvector sign
        labels = np.zeros(graph.n_vertices, dtype=int)
        for i in range(min(n_communities - 1, features.shape[1])):
            labels += (features[:, i] > 0).astype(int) * (2 ** i)
        labels = labels % n_communities
    
    return labels


def simulate_meme_spread(graph: DirectedGraph, 
                          initial_infected: List[int],
                          weights: Optional[List[float]] = None,
                          steps: int = 10) -> List[List[int]]:
    """
    Simulate meme propagation on a graph.
    
    Algorithm:
        At each step, each infected node transmits along outgoing edges.
        An edge with weight w transmits with probability |w|.
        Returns the set of infected nodes at each step.
    """
    rng = np.random.default_rng(42)
    infected = set(initial_infected)
    history = [sorted(infected)]
    
    if weights is None:
        weights = [1.0] * graph.n_edges
    
    for _ in range(steps):
        new_infected = set()
        for i, (s, t) in enumerate(graph.edges):
            if s in infected:
                if rng.random() < abs(weights[i]):
                    new_infected.add(t)
            if t in infected:
                if rng.random() < abs(weights[i]):
                    new_infected.add(s)
        infected = infected | new_infected
        history.append(sorted(infected))
    
    return history


if __name__ == "__main__":
    # Example: Two communities connected by a bridge
    G = DirectedGraph(
        n_vertices=8,
        edges=[(0,1),(1,2),(2,3),(0,3),  # Community 1 (K4-ish)
               (4,5),(5,6),(6,7),(4,7),  # Community 2 (K4-ish)
               (3,4)]                     # Bridge
    )
    
    coh = compute_constant_sheaf_cohomology(G)
    vi = virality_index(coh, G.n_edges)
    
    print(f"Graph: {G.n_vertices} vertices, {G.n_edges} edges")
    print(f"H⁰ = {coh.h0}, H¹ = {coh.h1}")
    print(f"Euler characteristic: {coh.euler_char} = {G.n_vertices} - {G.n_edges}")
    print(f"Virality index: {vi}")
    print(f"Upper bound: {G.n_vertices * (G.n_edges + 1)}")
    
    # Simulate meme spread
    history = simulate_meme_spread(G, [0], steps=5)
    print(f"\nMeme spread from node 0:")
    for step, nodes in enumerate(history):
        print(f"  Step {step}: {nodes}")
