#!/usr/bin/env python3
"""
Algorithms for Tropical Gauge Theory on Weighted Directed Graphs.

Implements the core algorithms from the research paper:
1. Pure gauge construction and verification
2. Charged shortest path computation
3. Gauge-accelerated shortest paths
4. Circulation computation and exactness testing
5. Potential recovery from exact fields
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from collections import defaultdict
import heapq


# ============================================================================
# Core Data Structures
# ============================================================================

class WeightedGraph:
    """A weighted directed graph represented by an adjacency weight matrix.
    
    Attributes:
        n: Number of vertices
        w: Edge weight matrix (n x n), where w[i,j] is the weight of edge i -> j
    """
    
    def __init__(self, w: np.ndarray):
        """Initialize from weight matrix.
        
        Args:
            w: Square matrix of edge weights
        """
        assert w.ndim == 2 and w.shape[0] == w.shape[1]
        self.n = w.shape[0]
        self.w = w.copy()
    
    @classmethod
    def random(cls, n: int, weight_range: Tuple[float, float] = (1.0, 10.0),
               seed: Optional[int] = None) -> 'WeightedGraph':
        """Generate a random weighted directed graph.
        
        Args:
            n: Number of vertices
            weight_range: (min_weight, max_weight) for edge weights
            seed: Random seed for reproducibility
            
        Returns:
            A random WeightedGraph instance
        """
        if seed is not None:
            np.random.seed(seed)
        w = np.random.uniform(weight_range[0], weight_range[1], (n, n))
        return cls(w)


# ============================================================================
# Algorithm 1: Pure Gauge Field Construction
# ============================================================================

def construct_pure_gauge(phi: np.ndarray) -> np.ndarray:
    """Construct a pure gauge field from a vertex potential.
    
    Given potential φ : V → ℝ, constructs A(i,j) = φ(j) - φ(i).
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    
    Args:
        phi: Vertex potential array of length n
        
    Returns:
        n x n matrix A where A[i,j] = phi[j] - phi[i]
    
    Example:
        >>> phi = np.array([1.0, 3.0, -2.0])
        >>> A = construct_pure_gauge(phi)
        >>> print(A)
        [[ 0.  2. -3.]
         [-2.  0. -5.]
         [ 3.  5.  0.]]
    """
    n = len(phi)
    return phi[np.newaxis, :] - phi[:, np.newaxis]


# ============================================================================
# Algorithm 2: Charged Shortest Paths (Bellman-Ford)
# ============================================================================

def bellman_ford(w: np.ndarray, source: int) -> Tuple[np.ndarray, np.ndarray]:
    """Compute single-source shortest paths using Bellman-Ford.
    
    Handles negative edge weights (but not negative cycles).
    
    Time complexity: O(n³)
    Space complexity: O(n)
    
    Args:
        w: Edge weight matrix
        source: Source vertex index
        
    Returns:
        (distances, predecessors) where distances[v] is the shortest
        distance from source to v, and predecessors[v] is the previous
        vertex on the shortest path (-1 if unreachable or source).
        
    Raises:
        ValueError: If a negative-weight cycle is detected
    """
    n = w.shape[0]
    dist = np.full(n, np.inf)
    pred = np.full(n, -1, dtype=int)
    dist[source] = 0.0
    
    for iteration in range(n - 1):
        updated = False
        for i in range(n):
            if dist[i] == np.inf:
                continue
            for j in range(n):
                if dist[i] + w[i, j] < dist[j]:
                    dist[j] = dist[i] + w[i, j]
                    pred[j] = i
                    updated = True
        if not updated:
            break
    
    # Check for negative cycles
    for i in range(n):
        if dist[i] == np.inf:
            continue
        for j in range(n):
            if dist[i] + w[i, j] < dist[j] - 1e-10:
                raise ValueError("Negative-weight cycle detected")
    
    return dist, pred


def floyd_warshall(w: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths using Floyd-Warshall.
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Args:
        w: Edge weight matrix
        
    Returns:
        n x n matrix where entry (i,j) is the shortest distance from i to j
    """
    n = w.shape[0]
    dist = w.copy()
    for i in range(n):
        dist[i, i] = 0.0
    
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i, k] + dist[k, j] < dist[i, j]:
                    dist[i, j] = dist[i, k] + dist[k, j]
    
    return dist


# ============================================================================
# Algorithm 3: Gauge-Accelerated Shortest Paths
# ============================================================================

def gauge_accelerated_shortest_paths(
    w: np.ndarray, A: np.ndarray, phi: np.ndarray
) -> np.ndarray:
    """Compute charged shortest paths using gauge reduction.
    
    Instead of computing shortest paths in the charged graph directly,
    uses the gauge invariance theorem:
        d_{w+A}(s,t) = d_w(s,t) + φ(t) - φ(s)
    
    This is computationally equivalent to standard shortest paths
    (both are O(n³)), but demonstrates the gauge reduction principle.
    When the uncharged distances are already cached, this gives
    charged distances in O(1) per query.
    
    Time complexity: O(n³) for initial computation, O(1) per subsequent query
    Space complexity: O(n²)
    
    Args:
        w: Base edge weight matrix
        A: Charge field matrix (must be pure gauge: A[i,j] = phi[j] - phi[i])
        phi: Gauge potential
        
    Returns:
        n x n matrix of charged shortest path distances
        
    Example:
        >>> w = np.array([[0, 3, 8], [np.inf, 0, 2], [np.inf, np.inf, 0]])
        >>> phi = np.array([1.0, 3.0, -2.0])
        >>> A = construct_pure_gauge(phi)
        >>> dist_charged = gauge_accelerated_shortest_paths(w, A, phi)
    """
    # Step 1: Compute uncharged distances (standard Floyd-Warshall)
    dist_w = floyd_warshall(w)
    
    # Step 2: Apply gauge correction (Theorem 3.5)
    n = w.shape[0]
    dist_charged = np.zeros((n, n))
    for s in range(n):
        for t in range(n):
            dist_charged[s, t] = dist_w[s, t] + phi[t] - phi[s]
    
    return dist_charged


# ============================================================================
# Algorithm 4: Circulation Computation
# ============================================================================

def compute_circulation(A: np.ndarray, cycle: List[int]) -> float:
    """Compute the circulation of field A around a cycle.
    
    The circulation is the sum of A(v_k, v_{k+1}) around the cycle.
    
    Time complexity: O(|cycle|)
    Space complexity: O(1)
    
    Args:
        A: Charge field matrix
        cycle: List of vertices forming a cycle (first = last)
        
    Returns:
        The circulation value
    """
    return sum(A[cycle[k], cycle[k + 1]] for k in range(len(cycle) - 1))


def find_fundamental_cycles(n: int, edges: List[Tuple[int, int]]) -> List[List[int]]:
    """Find a set of fundamental cycles for an undirected graph.
    
    Uses a spanning tree and back-edges to construct fundamental cycles.
    
    Args:
        n: Number of vertices
        edges: List of (i, j) edges
        
    Returns:
        List of cycles, each as a list of vertices (first = last)
    """
    adj = defaultdict(set)
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)
    
    visited = set()
    parent = {}
    tree_edges = set()
    cycles = []
    
    def bfs(start):
        queue = [start]
        visited.add(start)
        parent[start] = -1
        
        while queue:
            v = queue.pop(0)
            for u in adj[v]:
                if u not in visited:
                    visited.add(u)
                    parent[u] = v
                    tree_edges.add((min(v, u), max(v, u)))
                    queue.append(u)
    
    bfs(0)
    
    for i, j in edges:
        edge = (min(i, j), max(i, j))
        if edge not in tree_edges:
            # Found a back edge; construct the fundamental cycle
            path_i = []
            v = i
            while v != -1:
                path_i.append(v)
                v = parent.get(v, -1)
            
            path_j = []
            v = j
            while v != -1:
                path_j.append(v)
                v = parent.get(v, -1)
            
            # Find common ancestor
            set_i = set(path_i)
            for k, v in enumerate(path_j):
                if v in set_i:
                    idx_i = path_i.index(v)
                    cycle = path_i[:idx_i + 1][::-1] + path_j[:k][::-1]
                    cycle.append(cycle[0])
                    cycles.append(cycle)
                    break
    
    return cycles


# ============================================================================
# Algorithm 5: Exactness Test and Potential Recovery
# ============================================================================

def is_exact_gauge(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[np.ndarray]]:
    """Test whether a charge field is exact (pure gauge) and recover the potential.
    
    A field A is exact if A(i,j) = φ(j) - φ(i) for some potential φ.
    This is equivalent to having zero circulation on all cycles.
    
    Algorithm:
    1. Fix φ(0) = 0 as reference.
    2. For each vertex v, compute φ(v) by path integration from 0.
    3. Verify consistency: check that A(i,j) ≈ φ(j) - φ(i) for all i,j.
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    Args:
        A: Charge field matrix
        tol: Tolerance for floating-point comparison
        
    Returns:
        (is_exact, potential) where potential is the recovered φ if exact,
        None otherwise
        
    Example:
        >>> phi = np.array([1.0, 3.0, -2.0])
        >>> A = construct_pure_gauge(phi)
        >>> exact, recovered = is_exact_gauge(A)
        >>> print(exact)  # True
        >>> print(recovered - recovered[0])  # should match phi - phi[0]
    """
    n = A.shape[0]
    phi = np.zeros(n)
    
    # BFS to assign potentials
    visited = {0}
    queue = [0]
    
    while queue:
        i = queue.pop(0)
        for j in range(n):
            if j not in visited:
                phi[j] = phi[i] + A[i, j]
                visited.add(j)
                queue.append(j)
    
    # Verify consistency
    for i in range(n):
        for j in range(n):
            expected = phi[j] - phi[i]
            if abs(A[i, j] - expected) > tol:
                return False, None
    
    return True, phi


# ============================================================================
# Algorithm 6: Tropical Bellman Operator
# ============================================================================

def tropical_bellman_operator(w: np.ndarray, f: np.ndarray) -> np.ndarray:
    """Apply the tropical Bellman operator: T_w f(i) = min_j(w(i,j) + f(j)).
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    Args:
        w: Edge weight matrix
        f: Value function
        
    Returns:
        Updated value function T_w f
    """
    n = w.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = min(w[i, j] + f[j] for j in range(n))
    return result


def gauge_conjugated_bellman(
    w: np.ndarray, phi: np.ndarray, f: np.ndarray
) -> np.ndarray:
    """Apply the gauge-conjugated Bellman operator.
    
    Instead of computing T_{w+A} f directly, uses the conjugation identity:
        T_{w+A} f(i) = T_w(f + φ)(i) - φ(i)
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    Args:
        w: Base edge weight matrix
        phi: Gauge potential
        f: Value function
        
    Returns:
        T_{w+A} f where A is the pure gauge from phi
    """
    return tropical_bellman_operator(w, f + phi) - phi


# ============================================================================
# Main: Run all algorithms with examples
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL GAUGE THEORY: Algorithm Demonstrations")
    print("=" * 60)
    
    # Setup
    n = 5
    np.random.seed(42)
    w = np.random.uniform(1, 10, (n, n))
    phi = np.array([1.0, 3.0, -2.0, 4.0, -1.0])
    
    # Algorithm 1: Construct pure gauge
    print("\n--- Algorithm 1: Pure Gauge Construction ---")
    A = construct_pure_gauge(phi)
    print(f"Potential: {phi}")
    print(f"Gauge field A[0,1] = {A[0,1]:.4f} (expected: {phi[1]-phi[0]:.4f})")
    print(f"Gauge field A[2,4] = {A[2,4]:.4f} (expected: {phi[4]-phi[2]:.4f})")
    
    # Algorithm 3: Gauge-accelerated shortest paths
    print("\n--- Algorithm 3: Gauge-Accelerated Shortest Paths ---")
    dist_direct = floyd_warshall(w + A)
    dist_gauge = gauge_accelerated_shortest_paths(w, A, phi)
    max_err = np.max(np.abs(dist_direct - dist_gauge))
    print(f"Max error between direct and gauge-accelerated: {max_err:.2e}")
    
    # Algorithm 5: Exactness test
    print("\n--- Algorithm 5: Exactness Test ---")
    is_exact, recovered_phi = is_exact_gauge(A)
    print(f"Field is exact: {is_exact}")
    if recovered_phi is not None:
        # Potentials are defined up to a constant
        shift = phi[0] - recovered_phi[0]
        print(f"Recovered potential (shifted): {np.round(recovered_phi + shift, 4)}")
        print(f"Original potential:            {phi}")
    
    # Test non-exact field
    B = np.random.uniform(-1, 1, (n, n))
    is_exact_B, _ = is_exact_gauge(B)
    print(f"Random field is exact: {is_exact_B}")
    
    # Algorithm 6: Bellman conjugation
    print("\n--- Algorithm 6: Bellman Operator Conjugation ---")
    f = np.random.uniform(-3, 3, n)
    T_direct = tropical_bellman_operator(w + A, f)
    T_conjugated = gauge_conjugated_bellman(w, phi, f)
    bellman_err = np.max(np.abs(T_direct - T_conjugated))
    print(f"Max Bellman conjugation error: {bellman_err:.2e}")
    
    print("\n" + "=" * 60)
    print("All algorithm demonstrations completed successfully.")
    print("=" * 60)
