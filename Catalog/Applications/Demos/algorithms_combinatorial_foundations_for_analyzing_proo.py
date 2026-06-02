#!/usr/bin/env python3
"""
Spectral Renormalization of Proof Spaces — Core Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import Dict, Set, FrozenSet, List, Tuple, Optional
from dataclasses import dataclass
import math


@dataclass
class DerivationGraph:
    """A directed graph modeling single-step derivability.
    
    Attributes:
        vertices: set of vertex identifiers
        adj: adjacency dict mapping each vertex to its out-neighbors
    """
    vertices: Set[int]
    adj: Dict[int, Set[int]]
    
    @property
    def n(self) -> int:
        return len(self.vertices)
    
    def out_neighbors(self, v: int) -> Set[int]:
        """Out-neighborhood of vertex v."""
        return self.adj.get(v, set())
    
    def out_neighbor_set(self, S: Set[int]) -> Set[int]:
        """Out-neighborhood of a set S."""
        result: Set[int] = set()
        for v in S:
            result.update(self.out_neighbors(v))
        return result
    
    def boundary(self, S: Set[int]) -> Set[int]:
        """Boundary of S: out-neighbors not in S."""
        return self.out_neighbor_set(S) - S


def proof_ball(G: DerivationGraph, S: Set[int], k: int) -> Set[int]:
    """Compute the proof ball Ball(S, k).
    
    Returns the set of all vertices reachable from S in at most k steps.
    Time complexity: O(k * |E|)
    """
    current = set(S)
    for _ in range(k):
        current = current | G.out_neighbor_set(current)
    return current


def proof_reach_count(G: DerivationGraph, S: Set[int], k: int) -> int:
    """Compute the proof reachability count RC(S, k) = |Ball(S, k)|."""
    return len(proof_ball(G, S, k))


def estimate_vertex_expansion(G: DerivationGraph, samples: int = 1000) -> float:
    """Estimate the vertex expansion ratio h by sampling subsets.
    
    For each sampled subset S with |S| ≤ n/2, computes |∂S|/|S|.
    Returns the minimum ratio found (a lower bound on true expansion).
    """
    import random
    n = G.n
    if n <= 1:
        return 0.0
    
    min_ratio = float('inf')
    vlist = list(G.vertices)
    
    for _ in range(samples):
        size = random.randint(1, max(1, n // 2))
        S = set(random.sample(vlist, size))
        bdry = G.boundary(S)
        ratio = len(bdry) / len(S)
        min_ratio = min(min_ratio, ratio)
    
    return min_ratio


def proof_length_lower_bound(n: int, h: float, s_size: int = 1) -> float:
    """Compute the expansion-based proof length lower bound.
    
    Returns log(n / s_size) / log(1 + h), the minimum number of steps
    to reach all n vertices from a set of size s_size.
    """
    if h <= 0 or s_size <= 0 or n <= s_size:
        return 0.0
    return math.log(n / s_size) / math.log(1 + h)


@dataclass
class RenormPartition:
    """A surjective partition of vertices into blocks."""
    assign: Dict[int, int]  # vertex -> block
    
    @property
    def blocks(self) -> Set[int]:
        return set(self.assign.values())
    
    def block_members(self, b: int) -> Set[int]:
        return {v for v, block in self.assign.items() if block == b}


def quotient_graph(G: DerivationGraph, pi: RenormPartition) -> DerivationGraph:
    """Compute the quotient (renormalized) derivation graph.
    
    Block b1 connects to block b2 iff any vertex in b1 connects to
    any vertex in b2 in the original graph.
    """
    blocks = pi.blocks
    quot_adj: Dict[int, Set[int]] = {b: set() for b in blocks}
    
    for u, neighbors in G.adj.items():
        b1 = pi.assign[u]
        for v in neighbors:
            b2 = pi.assign[v]
            quot_adj[b1].add(b2)
    
    return DerivationGraph(vertices=blocks, adj=quot_adj)


def find_stabilization_time(G: DerivationGraph, S: Set[int]) -> Tuple[int, Set[int]]:
    """Find K such that Ball(S, k) = Ball(S, K) for all k ≥ K.
    
    Returns (K, Ball(S, K)).
    """
    current = set(S)
    k = 0
    while True:
        next_ball = current | G.out_neighbor_set(current)
        if next_ball == current:
            return k, current
        current = next_ball
        k += 1


def is_closed(G: DerivationGraph, S: Set[int]) -> bool:
    """Check if S is closed under derivation (N+(S) ⊆ S)."""
    return G.out_neighbor_set(S).issubset(S)


def ball_growth_trajectory(G: DerivationGraph, S: Set[int], 
                           max_steps: int) -> List[Tuple[int, int, float]]:
    """Compute the ball growth trajectory.
    
    Returns list of (k, |Ball(S,k)|, growth_ratio) tuples.
    """
    trajectory: List[Tuple[int, int, float]] = []
    current = set(S)
    prev_size = len(current)
    trajectory.append((0, prev_size, 1.0))
    
    for k in range(1, max_steps + 1):
        current = current | G.out_neighbor_set(current)
        curr_size = len(current)
        ratio = curr_size / max(prev_size, 1)
        trajectory.append((k, curr_size, ratio))
        prev_size = curr_size
        if curr_size == G.n:
            break
    
    return trajectory


def spectral_gap_estimate(G: DerivationGraph) -> float:
    """Estimate the spectral gap λ₂ of the (symmetrized) Laplacian.
    
    Uses the power method on the Laplacian to approximate λ₂.
    Requires numpy.
    """
    try:
        import numpy as np
    except ImportError:
        return 0.0
    
    n = G.n
    if n <= 1:
        return 0.0
    
    vlist = sorted(G.vertices)
    idx = {v: i for i, v in enumerate(vlist)}
    
    # Build symmetrized adjacency matrix
    A = np.zeros((n, n))
    for u, neighbors in G.adj.items():
        for v in neighbors:
            A[idx[u], idx[v]] = 1
            A[idx[v], idx[u]] = 1  # symmetrize
    
    # Degree matrix and Laplacian
    D = np.diag(A.sum(axis=1))
    L = D - A
    
    # Eigenvalues
    eigenvalues = np.sort(np.linalg.eigvalsh(L))
    
    # λ₂ is the second smallest eigenvalue (Fiedler value)
    if len(eigenvalues) >= 2:
        return float(max(0.0, eigenvalues[1]))
    return 0.0


if __name__ == "__main__":
    import random
    random.seed(42)
    
    # Create a sample derivation graph
    n = 30
    vertices = set(range(n))
    adj: Dict[int, Set[int]] = {v: set() for v in vertices}
    for u in vertices:
        for v in vertices:
            if u != v and random.random() < 0.12:
                adj[u].add(v)
    
    G = DerivationGraph(vertices=vertices, adj=adj)
    
    print("Derivation Graph Analysis")
    print(f"Vertices: {G.n}")
    print(f"Expansion estimate: {estimate_vertex_expansion(G):.4f}")
    print(f"Spectral gap estimate: {spectral_gap_estimate(G):.4f}")
    
    S = {0}
    K, closure = find_stabilization_time(G, S)
    print(f"\nStabilization from {{0}}: K={K}, |closure|={len(closure)}")
    print(f"Closure is closed: {is_closed(G, closure)}")
    
    trajectory = ball_growth_trajectory(G, S, 10)
    print(f"\nBall growth trajectory:")
    for k, size, ratio in trajectory:
        print(f"  k={k}: |Ball|={size}, growth ratio={ratio:.3f}")
