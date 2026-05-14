#!/usr/bin/env python3
"""
Tropical Complexity Theory: Algorithms

Implements the core algorithms from the research paper:
1. Tropical (min-plus) matrix operations
2. Walk detection and path enumeration
3. Layered system analysis
4. Minimum cycle mean computation (Karp's algorithm)
5. Tropical spectral gap computation
6. Bounded-space computation encoding
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass
from collections import defaultdict

INF = float('inf')


# ============================================================
# Core Tropical Algebra
# ============================================================

class TropicalMatrix:
    """
    Matrix over the tropical (min-plus) semiring.

    In the min-plus semiring:
    - Addition is min: a ⊕ b = min(a, b)
    - Multiplication is +: a ⊗ b = a + b
    - Additive identity (zero): ∞
    - Multiplicative identity (one): 0

    Attributes:
        data: numpy array with float values (inf = no edge)
    """

    def __init__(self, data: np.ndarray):
        """Initialize from a numpy array."""
        self.data = data.astype(float)
        self.n = data.shape[0]

    @classmethod
    def identity(cls, n: int) -> 'TropicalMatrix':
        """Create the tropical identity matrix (0 on diagonal, ∞ elsewhere)."""
        I = np.full((n, n), INF)
        np.fill_diagonal(I, 0.0)
        return cls(I)

    @classmethod
    def zero(cls, n: int) -> 'TropicalMatrix':
        """Create the tropical zero matrix (all ∞)."""
        return cls(np.full((n, n), INF))

    @classmethod
    def from_adjacency(cls, adj: np.ndarray) -> 'TropicalMatrix':
        """Create a 0/∞ tropical matrix from a boolean adjacency matrix.

        Args:
            adj: boolean numpy array where True means edge present

        Returns:
            TropicalMatrix with 0 for edges, ∞ for non-edges
        """
        return cls(np.where(adj, 0.0, INF))

    def __matmul__(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j])

        Time complexity: O(n³)
        Space complexity: O(n²)
        """
        assert self.data.shape[1] == other.data.shape[0]
        n, m = self.data.shape[0], other.data.shape[1]
        p = self.data.shape[1]
        C = np.full((n, m), INF)
        for i in range(n):
            for j in range(m):
                for k in range(p):
                    val = self.data[i, k] + other.data[k, j]
                    if val < C[i, j]:
                        C[i, j] = val
        return TropicalMatrix(C)

    def power(self, k: int) -> 'TropicalMatrix':
        """Compute W^k in the tropical semiring via repeated squaring.

        Time complexity: O(n³ log k)
        Space complexity: O(n²)
        """
        if k == 0:
            return TropicalMatrix.identity(self.n)
        if k == 1:
            return TropicalMatrix(self.data.copy())

        # Repeated squaring
        result = TropicalMatrix.identity(self.n)
        base = TropicalMatrix(self.data.copy())
        while k > 0:
            if k % 2 == 1:
                result = result @ base
            base = base @ base
            k //= 2
        return result

    def closure(self) -> 'TropicalMatrix':
        """Compute the tropical closure W* = I ⊕ W ⊕ W² ⊕ ...

        This is the all-pairs shortest path matrix.
        Uses Floyd-Warshall algorithm.

        Time complexity: O(n³)
        Space complexity: O(n²)
        """
        D = self.data.copy()
        np.fill_diagonal(D, np.minimum(np.diag(D), 0.0))
        n = self.n
        for k in range(n):
            for i in range(n):
                for j in range(n):
                    via_k = D[i, k] + D[k, j]
                    if via_k < D[i, j]:
                        D[i, j] = via_k
        return TropicalMatrix(D)

    def has_walk(self, s: int, t: int, k: int) -> bool:
        """Check if there's a walk of length k from s to t.

        For 0/∞ matrices, equivalent to (W^k)[s,t] = 0.
        """
        Wk = self.power(k)
        return Wk.data[s, t] == 0.0

    def __repr__(self):
        rows = []
        for i in range(self.n):
            row = []
            for j in range(self.n):
                v = self.data[i, j]
                row.append("∞" if v == INF else f"{v:.1f}" if v != int(v) else str(int(v)))
            rows.append("[" + ", ".join(f"{x:>4s}" for x in row) + "]")
        return "\n".join(rows)


# ============================================================
# Layered Graph Analysis
# ============================================================

@dataclass
class LayeredGraph:
    """A layered directed graph with rank function.

    Properties:
    - Every edge goes from rank i to rank i+1
    - rank(source) = 0
    - rank(target) = L (the depth)
    """
    n_vertices: int
    rank: List[int]
    adjacency: np.ndarray  # boolean adjacency matrix
    source: int
    target: int

    @property
    def depth(self) -> int:
        """The depth L = rank(target) - rank(source)."""
        return self.rank[self.target] - self.rank[self.source]

    @property
    def n_layers(self) -> int:
        """Number of distinct layers."""
        return max(self.rank) + 1

    def layer_width(self, i: int) -> int:
        """Number of vertices at rank i."""
        return sum(1 for r in self.rank if r == i)

    def min_layer_width(self) -> int:
        """Minimum width across all layers (the bottleneck)."""
        return min(self.layer_width(i) for i in range(self.n_layers))

    def tropical_matrix(self) -> TropicalMatrix:
        """Convert to tropical transition matrix."""
        return TropicalMatrix.from_adjacency(self.adjacency)

    def verify_layering(self) -> bool:
        """Verify that every edge increases rank by exactly 1."""
        for i in range(self.n_vertices):
            for j in range(self.n_vertices):
                if self.adjacency[i, j]:
                    if self.rank[j] != self.rank[i] + 1:
                        return False
        return True

    def enumerate_paths(self) -> List[List[int]]:
        """Enumerate all paths from source to target.

        Time complexity: O(|paths| × L) where L is the depth.
        """
        paths = []

        def dfs(current: int, path: List[int]):
            if current == self.target:
                paths.append(path[:])
                return
            for j in range(self.n_vertices):
                if self.adjacency[current, j]:
                    path.append(j)
                    dfs(j, path)
                    path.pop()

        dfs(self.source, [self.source])
        return paths

    def verify_exact_depth(self) -> dict:
        """Verify the exact depth theorem: walks exist only at depth L.

        Returns a dict with verification results.
        """
        W = self.tropical_matrix()
        L = self.depth
        results = {}
        for k in range(L + 2):
            reachable = W.has_walk(self.source, self.target, k)
            results[k] = reachable

        return {
            'depth': L,
            'walk_at_depth': results.get(L, False),
            'no_shortcuts': all(not results.get(k, False) for k in range(L)),
            'no_overshoot': all(not results.get(k, False) for k in range(L + 1, L + 2)),
            'details': results
        }


def create_layered_graph(widths: List[int]) -> LayeredGraph:
    """Create a fully-connected layered graph with specified layer widths.

    Args:
        widths: list of widths [w_0, w_1, ..., w_L] for each layer

    Returns:
        LayeredGraph with source at vertex 0, target at last vertex
    """
    n = sum(widths)
    rank = []
    for i, w in enumerate(widths):
        rank.extend([i] * w)

    adj = np.zeros((n, n), dtype=bool)
    offset = 0
    for i in range(len(widths) - 1):
        for s in range(widths[i]):
            for t in range(widths[i + 1]):
                adj[offset + s, offset + widths[i] + t] = True
        offset += widths[i]

    return LayeredGraph(
        n_vertices=n,
        rank=rank,
        adjacency=adj,
        source=0,
        target=n - 1
    )


# ============================================================
# Minimum Cycle Mean (Karp's Algorithm)
# ============================================================

def karp_minimum_cycle_mean(W: np.ndarray) -> float:
    """Compute the minimum cycle mean using Karp's algorithm.

    The minimum cycle mean is:
        μ(W) = min over all cycles C of (sum of edge weights in C / |C|)

    This is the tropical analogue of the spectral radius.

    Args:
        W: weighted adjacency matrix (∞ for no edge)

    Returns:
        Minimum cycle mean, or ∞ if no cycles exist

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = W.shape[0]

    # D[k][v] = min cost of a walk of length k ending at v, starting from any vertex
    # We compute D[k][v] for all v and k = 0, ..., n
    D = np.full((n + 1, n), INF)

    # Initialize: D[0][v] = 0 for all v (start anywhere)
    D[0, :] = 0.0

    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if W[u, v] < INF:
                    val = D[k - 1, u] + W[u, v]
                    if val < D[k, v]:
                        D[k, v] = val

    # Karp's formula: μ = min_v max_k (D[n][v] - D[k][v]) / (n - k)
    mu = INF
    for v in range(n):
        if D[n, v] < INF:
            max_ratio = -INF
            for k in range(n):
                if D[k, v] < INF:
                    ratio = (D[n, v] - D[k, v]) / (n - k)
                    max_ratio = max(max_ratio, ratio)
            if max_ratio < mu:
                mu = max_ratio

    return mu


def tropical_spectral_gap(W: np.ndarray) -> Optional[float]:
    """Compute the tropical spectral gap.

    The gap is the difference between the second-smallest
    and smallest cycle means.

    Args:
        W: weighted adjacency matrix

    Returns:
        The spectral gap, or None if fewer than 2 distinct cycle means exist
    """
    n = W.shape[0]
    # Find all elementary cycles and their means
    cycle_means = set()

    # Simple DFS-based cycle detection for small graphs
    def find_cycles(start: int, current: int, visited: Set[int],
                    cost: float, length: int):
        for next_v in range(n):
            if W[current, next_v] < INF:
                new_cost = cost + W[current, next_v]
                if next_v == start and length > 0:
                    cycle_means.add(new_cost / (length + 1))
                elif next_v not in visited and length < n:
                    visited.add(next_v)
                    find_cycles(start, next_v, visited, new_cost, length + 1)
                    visited.discard(next_v)

    for start in range(n):
        find_cycles(start, start, {start}, 0.0, 0)

    if len(cycle_means) < 2:
        return None

    sorted_means = sorted(cycle_means)
    return sorted_means[1] - sorted_means[0]


# ============================================================
# Bounded-Space Computation Encoding
# ============================================================

@dataclass
class BoundedSpaceComputation:
    """Represents a bounded-space computation as a tropical reachability problem.

    A computation with s bits of space has at most 2^s configurations.
    The computation accepts iff there is a path from start to accept
    in the configuration graph.
    """
    space_bits: int
    n_configs: int
    transition_matrix: TropicalMatrix
    start_config: int
    accept_config: int
    rank: Optional[List[int]] = None

    def accepts(self) -> bool:
        """Check if the computation accepts (tropical reachability)."""
        W_star = self.transition_matrix.closure()
        return W_star.data[self.start_config, self.accept_config] < INF

    def min_time(self) -> int:
        """Find minimum number of steps to acceptance."""
        for k in range(self.n_configs + 1):
            if self.transition_matrix.has_walk(self.start_config, self.accept_config, k):
                return k
        return -1  # Does not accept


def encode_counter_machine(bits: int) -> BoundedSpaceComputation:
    """Encode a simple counter machine as a bounded-space computation.

    The machine counts from 0 to 2^bits - 1 in binary.
    Configuration = current counter value.
    Transition: i → i+1 (mod 2^bits).
    Accepts at configuration 2^bits - 1.

    This demonstrates the tropical encoding of a polynomial-space computation.
    """
    n = 2 ** bits
    adj = np.zeros((n, n), dtype=bool)

    # Transition: i → i+1 (wrapping)
    for i in range(n):
        adj[i, (i + 1) % n] = True

    # For layered version, unfold the computation
    # Rank = step number
    rank = list(range(n))

    return BoundedSpaceComputation(
        space_bits=bits,
        n_configs=n,
        transition_matrix=TropicalMatrix.from_adjacency(adj),
        start_config=0,
        accept_config=n - 1,
        rank=rank
    )


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("Tropical Complexity Theory — Algorithm Demonstrations")
    print("=" * 55)
    print()

    # 1. Tropical matrix operations
    print("1. Tropical Matrix Multiplication")
    A = TropicalMatrix(np.array([[0, 3, INF], [INF, 0, 1], [2, INF, 0]]))
    print(f"A =\n{A}\n")
    A2 = A @ A
    print(f"A² =\n{A2}\n")
    Astar = A.closure()
    print(f"A* (all-pairs shortest paths) =\n{Astar}\n")

    # 2. Layered graph
    print("2. Layered Graph Analysis")
    G = create_layered_graph([1, 3, 4, 3, 1])
    print(f"Layered graph: widths = [1, 3, 4, 3, 1]")
    print(f"Depth: {G.depth}")
    print(f"Layering valid: {G.verify_layering()}")
    verification = G.verify_exact_depth()
    print(f"Exact depth verified: {verification['walk_at_depth'] and verification['no_shortcuts']}")
    print(f"Number of paths: {len(G.enumerate_paths())}")
    print()

    # 3. Minimum cycle mean
    print("3. Minimum Cycle Mean (Karp's Algorithm)")
    W = np.array([
        [INF, 1.0, INF],
        [INF, INF, 2.0],
        [3.0, INF, INF]
    ])
    mu = karp_minimum_cycle_mean(W)
    print(f"Cycle 0→1→2→0: mean = (1+2+3)/3 = {(1+2+3)/3:.2f}")
    print(f"Karp's algorithm: μ = {mu:.2f}")
    print()

    # 4. Counter machine encoding
    print("4. Bounded-Space Computation Encoding")
    for bits in [2, 3, 4]:
        machine = encode_counter_machine(bits)
        accepts = machine.accepts()
        min_t = machine.min_time()
        print(f"  {bits}-bit counter: {machine.n_configs} configs, "
              f"accepts={accepts}, min_time={min_t}")
    print()

    print("All algorithms completed successfully!")
