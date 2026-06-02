#!/usr/bin/env python3
"""
Algorithms for Graph Riemann-Roch Theory

Type-hinted implementations of:
1. Chip-firing and the graph Laplacian
2. Dhar's burning algorithm for q-reduced divisors
3. Rank computation via exhaustive search
4. Jacobian group computation via Smith normal form
"""

import numpy as np
from typing import List, Tuple, Set, Optional, Dict
from itertools import product
from functools import reduce
from math import gcd


# ============================================================
# Core Data Structures
# ============================================================

class Graph:
    """A simple undirected graph on n vertices {0, 1, ..., n-1}."""
    
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: np.ndarray = np.zeros((n, n), dtype=int)
        for u, v in edges:
            self.adj[u][v] = 1
            self.adj[v][u] = 1
    
    @staticmethod
    def complete(n: int) -> 'Graph':
        """Create the complete graph K_n."""
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return Graph(n, edges)
    
    @staticmethod
    def cycle(n: int) -> 'Graph':
        """Create the cycle graph C_n."""
        edges = [(i, (i + 1) % n) for i in range(n)]
        return Graph(n, edges)
    
    @staticmethod
    def path(n: int) -> 'Graph':
        """Create the path graph P_n."""
        edges = [(i, i + 1) for i in range(n - 1)]
        return Graph(n, edges)
    
    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return int(self.adj[v].sum())
    
    def neighbors(self, v: int) -> List[int]:
        """List of neighbors of v."""
        return [w for w in range(self.n) if self.adj[v][w]]
    
    def num_edges(self) -> int:
        """Number of edges."""
        return int(self.adj.sum()) // 2
    
    def genus(self) -> int:
        """Genus g = |E| - |V| + 1."""
        return self.num_edges() - self.n + 1
    
    def laplacian(self) -> np.ndarray:
        """Graph Laplacian L = D - A."""
        return np.diag([self.degree(v) for v in range(self.n)]) - self.adj
    
    def canonical_divisor(self) -> np.ndarray:
        """Canonical divisor K_G(v) = deg(v) - 2."""
        return np.array([self.degree(v) - 2 for v in range(self.n)])


# ============================================================
# Chip-Firing
# ============================================================

def chip_fire(G: Graph, D: np.ndarray, v: int) -> np.ndarray:
    """Fire vertex v: sends one chip along each edge.
    
    Pseudocode:
        D'[v] = D[v] - deg(v)
        for each neighbor w of v:
            D'[w] = D[w] + 1
    """
    result = D.copy()
    result[v] -= G.degree(v)
    for w in G.neighbors(v):
        result[w] += 1
    return result


def chip_fire_set(G: Graph, D: np.ndarray, S: Set[int]) -> np.ndarray:
    """Fire all vertices in set S simultaneously."""
    result = D.copy()
    for v in S:
        result = chip_fire(G, result, v)
    return result


# ============================================================
# Dhar's Burning Algorithm
# ============================================================

def dhars_burning(G: Graph, D: np.ndarray, q: int) -> Tuple[bool, Set[int]]:
    """Dhar's burning algorithm to test if D is q-reduced.
    
    Returns (is_reduced, burning_set) where:
    - is_reduced = True if no non-empty subset S ⊆ V\\{q} can fire
    - burning_set = the set of vertices that "survive" the fire
    
    Pseudocode:
        burned = {q}
        repeat:
            for each unburned vertex v:
                if (edges from v to burned) > D[v]:
                    burn v
        until no change
        If all vertices burned: D is q-reduced
        Else: the unburned set can fire
    """
    burned: Set[int] = {q}
    changed = True
    
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned:
                continue
            # Count edges from v to burned vertices
            edges_to_burned = sum(1 for w in G.neighbors(v) if w in burned)
            if edges_to_burned > D[v]:
                burned.add(v)
                changed = True
    
    unburned = set(range(G.n)) - burned
    return (len(unburned) == 0, unburned)


def q_reduce(G: Graph, D: np.ndarray, q: int) -> np.ndarray:
    """Compute the q-reduced divisor equivalent to D.
    
    Repeatedly finds a firable subset and fires it until
    no subset can fire (the divisor is q-reduced).
    
    Pseudocode:
        while D is not q-reduced:
            find firable subset S via Dhar's algorithm
            fire all vertices in S
        return D
    """
    current = D.copy()
    max_iter = 10000
    
    for _ in range(max_iter):
        is_reduced, firable = dhars_burning(G, current, q)
        if is_reduced:
            return current
        # Fire the firable set
        for v in firable:
            current = chip_fire(G, current, v)
    
    raise RuntimeError("q-reduction did not converge")


# ============================================================
# Rank Computation
# ============================================================

def divisor_rank(G: Graph, D: np.ndarray, q: int = 0) -> int:
    """Compute the rank r(D) of a divisor.
    
    r(D) = max{k : for all effective E with deg(E) = k,
                   D - E is equivalent to an effective divisor}
    
    Returns -1 if D is not equivalent to any effective divisor.
    
    Pseudocode:
        D_red = q_reduce(D)
        if D_red[q] < 0: return -1
        r = 0
        for k = 1, 2, ...:
            for each effective E of degree k supported on V\\{q}:
                D' = q_reduce(D - E)
                if D'[q] < 0: return k - 1
        return k
    """
    # First check if D is equivalent to an effective divisor
    D_red = q_reduce(G, D, q)
    if D_red[q] < 0:
        return -1
    
    r = 0
    n = G.n
    
    # Check rank iteratively
    for k in range(1, int(D.sum()) + 2):
        # Check if we can subtract any effective divisor of degree k
        # and still get something equivalent to effective
        found_failure = False
        
        # Generate all effective divisors of degree k on V\{q}
        # This is exponential but correct for small examples
        non_q_vertices = [v for v in range(n) if v != q]
        
        for combo in _effective_divisors_of_degree(k, non_q_vertices):
            E = np.zeros(n, dtype=int)
            for v, count in zip(non_q_vertices, combo):
                E[v] = count
            
            D_minus_E_red = q_reduce(G, D - E, q)
            if D_minus_E_red[q] < 0:
                found_failure = True
                break
        
        if found_failure:
            return k - 1
        r = k
    
    return r


def _effective_divisors_of_degree(k: int, vertices: List[int]) -> List[Tuple[int, ...]]:
    """Generate all ways to place k chips on the given vertices."""
    n = len(vertices)
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    
    result = []
    for first in range(k + 1):
        for rest in _effective_divisors_of_degree(k - first, vertices[1:]):
            result.append((first,) + rest)
    return result


# ============================================================
# Jacobian Group via Smith Normal Form
# ============================================================

def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """Compute the Smith normal form of an integer matrix.
    
    Returns (SNF, invariant_factors) where invariant_factors
    are the diagonal entries of the SNF (> 0, dividing each other).
    """
    A = M.copy().astype(int)
    m, n = A.shape
    
    for col in range(min(m, n)):
        # Find pivot
        found = False
        for i in range(col, m):
            for j in range(col, n):
                if A[i, j] != 0:
                    # Swap rows and columns to bring pivot to (col, col)
                    A[[col, i]] = A[[i, col]]
                    A[:, [col, j]] = A[:, [j, col]]
                    found = True
                    break
            if found:
                break
        
        if not found:
            break
        
        # Reduce using the pivot
        changed = True
        while changed:
            changed = False
            
            # Make pivot positive
            if A[col, col] < 0:
                A[col] = -A[col]
            
            # Eliminate column entries
            for i in range(col + 1, m):
                if A[i, col] != 0:
                    q = A[i, col] // A[col, col]
                    A[i] -= q * A[col]
                    if A[i, col] != 0:
                        changed = True
                        if abs(A[i, col]) < abs(A[col, col]):
                            A[[col, i]] = A[[i, col]]
            
            # Eliminate row entries
            for j in range(col + 1, n):
                if A[col, j] != 0:
                    q = A[col, j] // A[col, col]
                    A[:, j] -= q * A[:, col]
                    if A[col, j] != 0:
                        changed = True
                        if abs(A[col, j]) < abs(A[col, col]):
                            A[:, [col, j]] = A[:, [j, col]]
    
    invariant_factors = [int(A[i, i]) for i in range(min(m, n)) if A[i, i] != 0]
    return A, invariant_factors


def jacobian_group(G: Graph, q: int = 0) -> List[int]:
    """Compute the invariant factor decomposition of Jac(G).
    
    Jac(G) = Div^0(G) / Prin(G) ≅ ℤ^{n-1} / L̃·ℤ^{n-1}
    
    where L̃ is the reduced Laplacian (remove row/col q).
    
    Returns the invariant factors [d_1, d_2, ...] such that
    Jac(G) ≅ ℤ/d_1 × ℤ/d_2 × ...
    """
    L = G.laplacian()
    # Remove row q and column q
    indices = [i for i in range(G.n) if i != q]
    L_red = L[np.ix_(indices, indices)]
    
    _, factors = smith_normal_form(L_red)
    # Filter out 1s (trivial factors)
    return [f for f in factors if f > 1]


# ============================================================
# Verification
# ============================================================

def verify_riemann_roch_complete(n: int) -> bool:
    """Verify Riemann-Roch for all 'simple' divisors on K_n.
    
    For small n, checks r(D) - r(K-D) = deg(D) + 1 - g
    for divisors of specific degrees.
    """
    G = Graph.complete(n)
    g = G.genus()
    K = G.canonical_divisor()
    
    print(f"\nK_{n}: genus = {g}, K = {K}")
    
    # Check for D = K (canonical divisor)
    r_K = divisor_rank(G, K)
    r_0 = divisor_rank(G, np.zeros(n, dtype=int))
    deg_K = int(K.sum())
    
    lhs = r_K - r_0
    rhs = deg_K + 1 - g
    
    print(f"  D = K: r(K) = {r_K}, r(0) = {r_0}")
    print(f"  r(K) - r(0) = {lhs}, deg(K) + 1 - g = {rhs}")
    print(f"  Riemann-Roch: {'✓' if lhs == rhs else '✗'}")
    
    return lhs == rhs


if __name__ == "__main__":
    print("ALGORITHMS FOR GRAPH RIEMANN-ROCH")
    print("=" * 50)
    
    # Test Jacobian groups
    print("\n--- Jacobian Groups ---")
    for n in range(3, 7):
        G = Graph.complete(n)
        jac = jacobian_group(G)
        order = reduce(lambda a, b: a * b, jac, 1)
        print(f"Jac(K_{n}) ≅ {'×'.join(f'ℤ/{d}' for d in jac)}, "
              f"|Jac| = {order}, n^(n-2) = {n**(n-2)}")
    
    # Verify Riemann-Roch on small complete graphs
    print("\n--- Riemann-Roch Verification ---")
    for n in range(3, 6):
        verify_riemann_roch_complete(n)
