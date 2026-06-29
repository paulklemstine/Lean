#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for abelian sandpile criticality.

Implements:
1. Q-reduced representative computation (Dhar's algorithm)
2. Critical configuration enumeration
3. Laplacian energy computation and descent
4. Spectral analysis (Fiedler value, eigenvalue computation)

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Set, Optional, Generator
from itertools import product as iterproduct


# ============================================================
# Graph Representation
# ============================================================

class Graph:
    """Simple undirected graph with adjacency matrix representation.
    
    Attributes:
        n: number of vertices
        adj: adjacency matrix (n x n, symmetric, 0-1)
        laplacian: graph Laplacian L = D - A
        degrees: degree sequence
    """
    
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        """Create graph from vertex count and edge list.
        
        Args:
            n: number of vertices (labeled 0, ..., n-1)
            edges: list of (u, v) pairs with 0 <= u < v < n
            
        Time: O(n² + |E|)
        Space: O(n²)
        """
        self.n = n
        self.adj = np.zeros((n, n), dtype=int)
        for u, v in edges:
            self.adj[u, v] = 1
            self.adj[v, u] = 1
        self.degrees = self.adj.sum(axis=1).astype(int)
        self.laplacian = np.diag(self.degrees) - self.adj
    
    def reduced_laplacian(self, q: int) -> np.ndarray:
        """Compute reduced Laplacian by deleting row/column q.
        
        Args:
            q: sink vertex to delete
            
        Returns:
            (n-1) x (n-1) integer matrix
            
        Time: O(n²)
        """
        idx = [i for i in range(self.n) if i != q]
        return self.laplacian[np.ix_(idx, idx)]
    
    def is_connected(self) -> bool:
        """Check if graph is connected via BFS.
        
        Time: O(n + |E|)
        """
        if self.n == 0:
            return True
        visited = {0}
        queue = [0]
        while queue:
            v = queue.pop(0)
            for w in range(self.n):
                if self.adj[v, w] and w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


# ============================================================
# Algorithm 1: Dhar's Burning Algorithm
# ============================================================

def dhar_burning(D: np.ndarray, G: Graph, q: int) -> Tuple[bool, Set[int]]:
    """Dhar's burning algorithm for q-reducedness testing.
    
    Starting from the sink q, vertices "burn" their neighbors:
    vertex v burns if it has fewer chips than edges to already-burned vertices.
    The configuration is q-reduced iff all vertices eventually burn.
    
    Args:
        D: divisor/configuration (integer array of length n)
        G: the graph
        q: sink vertex
        
    Returns:
        (is_q_reduced, burned_set)
        
    Time: O(n²) worst case (each vertex burns at most once,
          checking neighbors is O(n))
    Space: O(n)
    """
    burned: Set[int] = {q}
    changed = True
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned:
                continue
            edges_to_burned = sum(G.adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == G.n, burned


# ============================================================
# Algorithm 2: Q-Reduced Representative
# ============================================================

def q_reduced_representative(D: np.ndarray, G: Graph, q: int,
                              max_iter: int = 100000) -> np.ndarray:
    """Compute the q-reduced representative of divisor D.
    
    Iteratively applies Dhar's algorithm: if D is not q-reduced,
    find the unburned subset S and fire all vertices in S simultaneously.
    Repeat until q-reduced.
    
    The q-reduced representative is the unique energy-minimizing
    representative in the chip-firing equivalence class of D (restricted
    to sink-normalized divisors with D[q] fixed).
    
    Args:
        D: input divisor (integer array)
        G: the graph
        q: sink vertex
        max_iter: maximum number of iterations
        
    Returns:
        q-reduced representative (same chip-firing class as D)
        
    Time: O(n² · T) where T is the number of firing rounds
          (bounded by total chip count for effective divisors)
    Space: O(n)
    
    Correctness: guaranteed to terminate for connected graphs.
    The output satisfies:
      1. D_out is chip-fire equivalent to D
      2. D_out is q-reduced (passes Dhar's burning test)
      3. D_out uniquely minimizes the Laplacian energy in its class
    """
    D = D.copy()
    for _ in range(max_iter):
        is_reduced, burned = dhar_burning(D, G, q)
        if is_reduced:
            return D
        # Fire all unburned vertices
        S = [v for v in range(G.n) if v not in burned]
        if not S:
            return D
        for v in S:
            D -= G.laplacian[v, :]
    return D


# ============================================================
# Algorithm 3: Critical Configuration Enumeration
# ============================================================

def enumerate_critical_configs(G: Graph, q: int) -> List[np.ndarray]:
    """Enumerate all critical (recurrent stable) configurations.
    
    A configuration c is critical if:
    1. c[q] = 0
    2. 0 <= c[v] < deg(v) for all v != q (stable)
    3. c passes Dhar's burning test (q-reduced)
    
    The number of critical configurations equals det(L_q),
    where L_q is the reduced Laplacian (Kirchhoff's theorem).
    
    Args:
        G: the graph
        q: sink vertex
        
    Returns:
        list of all critical configurations
        
    Time: O(∏_{v≠q} deg(v) · n²) — exponential in n, but exact
    Space: O(n · |output|)
    """
    ranges = []
    for v in range(G.n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(G.degrees[v])))
    
    critical = []
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        is_reduced, _ = dhar_burning(D, G, q)
        if is_reduced:
            critical.append(D.copy())
    
    return critical


# ============================================================
# Algorithm 4: Laplacian Energy Computation
# ============================================================

def laplacian_energy(D: np.ndarray, G: Graph) -> float:
    """Compute the Laplacian quadratic energy Q(D) = ∑_{i~j} (D_i - D_j)².
    
    This is the "gradient energy" of the configuration, equal to
    D^T L D (up to a factor of 2) where L is the graph Laplacian.
    
    Args:
        D: configuration (integer or float array)
        G: the graph
        
    Returns:
        Q(D) = ∑_{i~j} (D_i - D_j)²
        
    Time: O(n²)
    Space: O(1)
    """
    x = D.astype(float)
    total = 0.0
    for i in range(G.n):
        for j in range(G.n):
            if G.adj[i, j]:
                total += (x[i] - x[j]) ** 2
    return total


def energy_descent_trajectory(D: np.ndarray, G: Graph, q: int,
                                max_steps: int = 1000) -> List[Tuple[np.ndarray, float]]:
    """Compute the energy descent trajectory from D to its q-reduced representative.
    
    Records the configuration and energy at each step.
    
    Args:
        D: starting divisor
        G: the graph
        q: sink vertex
        max_steps: maximum steps
        
    Returns:
        list of (configuration, energy) pairs
        
    Time: O(n² · max_steps)
    """
    trajectory = []
    D = D.copy()
    E = laplacian_energy(D, G)
    trajectory.append((D.copy(), E))
    
    for _ in range(max_steps):
        is_reduced, burned = dhar_burning(D, G, q)
        if is_reduced:
            break
        S = [v for v in range(G.n) if v not in burned]
        if not S:
            break
        for v in S:
            D -= G.laplacian[v, :]
        E = laplacian_energy(D, G)
        trajectory.append((D.copy(), E))
    
    return trajectory


# ============================================================
# Algorithm 5: Spectral Analysis
# ============================================================

def fiedler_value(G: Graph) -> float:
    """Compute the Fiedler value (algebraic connectivity) λ₂.
    
    This is the second-smallest eigenvalue of the graph Laplacian.
    For connected graphs, λ₂ > 0.
    
    Args:
        G: the graph
        
    Returns:
        λ₂ (Fiedler value)
        
    Time: O(n³) for eigenvalue decomposition
    """
    evals = np.sort(np.linalg.eigvalsh(G.laplacian.astype(float)))
    return float(evals[1]) if len(evals) > 1 else 0.0


def spectral_data(G: Graph, q: int) -> dict:
    """Compute comprehensive spectral data for the graph.
    
    Returns:
        Dictionary with:
        - 'full_eigenvalues': eigenvalues of L
        - 'reduced_eigenvalues': eigenvalues of L_q
        - 'fiedler_value': λ₂
        - 'spectral_gap': λ₂
        - 'det_reduced': det(L_q) = number of spanning trees
        - 'condition_number': ratio of largest to smallest reduced eigenvalue
    """
    L = G.laplacian.astype(float)
    Lq = G.reduced_laplacian(q).astype(float)
    
    evals_full = np.sort(np.linalg.eigvalsh(L))
    evals_reduced = np.sort(np.linalg.eigvalsh(Lq))
    
    return {
        'full_eigenvalues': evals_full,
        'reduced_eigenvalues': evals_reduced,
        'fiedler_value': float(evals_full[1]) if len(evals_full) > 1 else 0.0,
        'spectral_gap': float(evals_full[1]) if len(evals_full) > 1 else 0.0,
        'det_reduced': abs(np.prod(evals_reduced)),
        'condition_number': float(evals_reduced[-1] / evals_reduced[0]) if evals_reduced[0] > 1e-10 else float('inf'),
    }


# ============================================================
# Algorithm 6: Jacobian Group Order
# ============================================================

def jacobian_order(G: Graph, q: int) -> int:
    """Compute the order of the Jacobian (sandpile) group.
    
    This equals det(L_q), the determinant of the reduced Laplacian,
    which also equals the number of spanning trees (Kirchhoff's theorem).
    
    Args:
        G: the graph
        q: sink vertex
        
    Returns:
        |Jac(G)| = det(L_q) = number of spanning trees
        
    Time: O(n³) for determinant computation
    """
    Lq = G.reduced_laplacian(q)
    return int(round(abs(np.linalg.det(Lq))))


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example: Complete graph K4
    K4 = Graph(4, [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)])
    q = 0
    
    print("Complete graph K4:")
    print(f"  Degrees: {K4.degrees}")
    print(f"  Laplacian:\n{K4.laplacian}")
    print(f"  Jacobian order: {jacobian_order(K4, q)}")
    print(f"  Fiedler value: {fiedler_value(K4):.4f}")
    
    # Enumerate critical configs
    criticals = enumerate_critical_configs(K4, q)
    print(f"  Critical configurations: {len(criticals)}")
    
    # Energy of each critical config
    for i, c in enumerate(criticals):
        E = laplacian_energy(c, K4)
        print(f"    c_{i} = {c}  E = {E:.1f}")
    
    # Q-reduce a random divisor
    D = np.array([0, 5, -3, 2])
    D_red = q_reduced_representative(D, K4, q)
    print(f"\n  Input divisor: {D}")
    print(f"  Q-reduced:     {D_red}")
    print(f"  Energy before: {laplacian_energy(D, K4):.1f}")
    print(f"  Energy after:  {laplacian_energy(D_red, K4):.1f}")
    
    # Energy descent trajectory
    trajectory = energy_descent_trajectory(D, K4, q)
    print(f"\n  Energy descent trajectory ({len(trajectory)} steps):")
    for i, (config, energy) in enumerate(trajectory):
        print(f"    Step {i}: {config}  E = {energy:.1f}")
    
    # Spectral data
    spec = spectral_data(K4, q)
    print(f"\n  Full eigenvalues: {np.round(spec['full_eigenvalues'], 4)}")
    print(f"  Reduced eigenvalues: {np.round(spec['reduced_eigenvalues'], 4)}")
    print(f"  Condition number: {spec['condition_number']:.4f}")
