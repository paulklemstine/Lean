#!/usr/bin/env python3
"""
algorithms.py — Tropical Hodge Theory: Core Algorithms

Implements the algorithms from the research paper with full docstrings,
type hints, and complexity analysis.
"""

from typing import List, Tuple, Set, Dict, Optional
from collections import defaultdict
import itertools

INF = float('inf')


# ============================================================
# Algorithm 1: Tropical Semiring Operations
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b).

    Time: O(1). Space: O(1).

    Examples:
        >>> trop_add(3, 5)
        3
        >>> trop_add(float('inf'), 7)
        7
    """
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with infinity handling).

    Time: O(1). Space: O(1).

    Examples:
        >>> trop_mul(3, 5)
        8
        >>> trop_mul(float('inf'), 7)
        inf
    """
    if a == INF or b == INF:
        return INF
    return a + b


# ============================================================
# Algorithm 2: Tropical Matrix-Vector Product
# ============================================================

def trop_matvec(M: List[List[float]], x: List[float]) -> List[float]:
    """Min-plus matrix-vector product: (Mx)_i = min_j(M[i][j] + x[j]).

    Time: O(n*m) where M is n×m. Space: O(n).

    Args:
        M: n×m matrix with entries in ℝ ∪ {∞}
        x: m-vector with entries in ℝ ∪ {∞}

    Returns:
        n-vector result of min-plus multiplication

    Examples:
        >>> M = [[0, INF], [INF, 0]]
        >>> trop_matvec(M, [3, 5])
        [3, 5]
    """
    n = len(M)
    m = len(x)
    result = [INF] * n
    for i in range(n):
        for j in range(m):
            result[i] = trop_add(result[i], trop_mul(M[i][j], x[j]))
    return result


# ============================================================
# Algorithm 3: Tropical Matrix Multiplication
# ============================================================

def trop_matmul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Min-plus matrix multiplication: C[i][j] = min_k(A[i][k] + B[k][j]).

    Time: O(n*m*p) where A is n×m, B is m×p. Space: O(n*p).

    Args:
        A: n×m matrix
        B: m×p matrix

    Returns:
        n×p result matrix

    Examples:
        >>> A = [[0, 1], [2, 0]]
        >>> B = [[0, 3], [1, 0]]
        >>> trop_matmul(A, B)
        [[0, 1], [1, 0]]
    """
    n = len(A)
    m = len(B)
    p = len(B[0]) if B else 0
    C = [[INF] * p for _ in range(n)]
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C


# ============================================================
# Algorithm 4: Graph Tropical Laplacian
# ============================================================

def tropical_laplacian(n: int, edges: List[Tuple[int, int]]) -> List[List[float]]:
    """Compute the tropical Laplacian of a simple graph.

    L(i,i) = deg(i), L(i,j) = 0 if {i,j} is an edge, ∞ otherwise.

    Time: O(n² + m) where m = |edges|. Space: O(n²).

    Args:
        n: number of vertices (labeled 0..n-1)
        edges: list of undirected edges (u, v)

    Returns:
        n×n tropical Laplacian matrix

    Examples:
        >>> tropical_laplacian(3, [(0,1), (1,2)])
        [[1, 0, inf], [0, 2, 0], [inf, 0, 1]]
    """
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)

    L = [[INF] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = len(adj[i])
        for j in adj[i]:
            L[i][j] = 0
    return L


# ============================================================
# Algorithm 5: Tropical Incidence Matrix
# ============================================================

def tropical_incidence(n: int, edges: List[Tuple[int, int]]) -> List[List[float]]:
    """Compute the tropical incidence matrix B: vertices × edges.

    B(v, e) = 0 if v is an endpoint of edge e, ∞ otherwise.

    Time: O(n*m). Space: O(n*m).

    Args:
        n: number of vertices
        edges: list of edges

    Returns:
        n × |E| matrix
    """
    m = len(edges)
    B = [[INF] * m for _ in range(n)]
    for e_idx, (u, v) in enumerate(edges):
        B[u][e_idx] = 0
        B[v][e_idx] = 0
    return B


# ============================================================
# Algorithm 6: Tropical Kernel Computation
# ============================================================

def tropical_kernel(L: List[List[float]]) -> List[List[float]]:
    """Compute the tropical kernel of a matrix L.

    ker_trop(L) = {x : min_j(L[i][j] + x[j]) = ∞ for all i}

    For the tropical Laplacian, the kernel is always {(∞,...,∞)} because
    L[i][i] is finite, forcing x[i] = ∞.

    Time: O(n²) to verify. Space: O(n).

    Returns:
        List of vectors in the kernel (always just [∞,...,∞] for Laplacians)
    """
    n = len(L)
    # For any Laplacian, the diagonal is finite, so x must be all ∞
    return [[INF] * n]


# ============================================================
# Algorithm 7: Tropical Boundary Map
# ============================================================

def tropical_boundary(B: List[List[float]], phi: List[float]) -> List[float]:
    """Tropical boundary map: (∂φ)(v) = min_e(B(v,e) + φ(e)).

    Time: O(n*m). Space: O(n).

    Args:
        B: incidence matrix (n × m)
        phi: 1-chain (m-vector)

    Returns:
        0-chain (n-vector)
    """
    return trop_matvec(B, phi)


# ============================================================
# Algorithm 8: Cycle Rank (Tropical Betti Number)
# ============================================================

def cycle_rank(n: int, edges: List[Tuple[int, int]]) -> int:
    """Compute the cycle rank (first Betti number) β₁ = |E| - |V| + c.

    Time: O(n + m) using union-find. Space: O(n).

    Args:
        n: number of vertices
        edges: list of edges

    Returns:
        The cycle rank β₁
    """
    # Union-Find for counting components
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
            return True
        return False

    components = n
    for u, v in edges:
        if union(u, v):
            components -= 1

    return len(edges) - n + components


# ============================================================
# Algorithm 9: Tropical Chain Complex Construction
# ============================================================

def construct_tropical_chain_complex(
    n: int, edges: List[Tuple[int, int]]
) -> Dict:
    """Construct the full tropical chain complex for a graph.

    Returns C₁ → C₀ with the tropical boundary map.

    Time: O(n*m + n²). Space: O(n*m + n²).

    Returns:
        Dictionary with keys:
        - 'C0_dim': dimension of C₀ (= n)
        - 'C1_dim': dimension of C₁ (= |E|)
        - 'boundary': incidence matrix B
        - 'laplacian': tropical Laplacian L
        - 'beta_1': first Betti number
        - 'kernel': tropical kernel of L
    """
    B = tropical_incidence(n, edges)
    L = tropical_laplacian(n, edges)
    beta_1 = cycle_rank(n, edges)
    ker = tropical_kernel(L)

    return {
        'C0_dim': n,
        'C1_dim': len(edges),
        'boundary': B,
        'laplacian': L,
        'beta_1': beta_1,
        'kernel': ker,
    }


# ============================================================
# Algorithm 10: Off-Diagonal Factorization Verification
# ============================================================

def verify_offdiag_factorization(
    n: int, edges: List[Tuple[int, int]]
) -> bool:
    """Verify that L(i,j) = (B⊗Bᵀ)(i,j) for all i ≠ j.

    Time: O(n²*m). Space: O(n²).

    Returns:
        True if the off-diagonal factorization holds
    """
    L = tropical_laplacian(n, edges)
    B = tropical_incidence(n, edges)
    m = len(edges)
    Bt = [[B[j][i] for j in range(n)] for i in range(m)]
    BBt = trop_matmul(B, Bt)

    for i in range(n):
        for j in range(n):
            if i != j and L[i][j] != BBt[i][j]:
                return False
    return True


# ============================================================
# EXAMPLE USAGE
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Hodge Theory: Algorithm Examples ===\n")

    # Example 1: Path graph P4
    print("Path Graph P₄:")
    n, edges = 4, [(0, 1), (1, 2), (2, 3)]
    complex_data = construct_tropical_chain_complex(n, edges)
    print(f"  C₀ dim = {complex_data['C0_dim']}")
    print(f"  C₁ dim = {complex_data['C1_dim']}")
    print(f"  β₁ = {complex_data['beta_1']}")
    print(f"  Kernel size = {len(complex_data['kernel'])}")
    print(f"  Off-diag factorization: {verify_offdiag_factorization(n, edges)}")

    # Example 2: Cycle graph C5
    print("\nCycle Graph C₅:")
    n, edges = 5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]
    complex_data = construct_tropical_chain_complex(n, edges)
    print(f"  C₀ dim = {complex_data['C0_dim']}")
    print(f"  C₁ dim = {complex_data['C1_dim']}")
    print(f"  β₁ = {complex_data['beta_1']}")
    print(f"  Kernel size = {len(complex_data['kernel'])}")
    print(f"  Off-diag factorization: {verify_offdiag_factorization(n, edges)}")

    # Example 3: Complete graph K4
    print("\nComplete Graph K₄:")
    n = 4
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    complex_data = construct_tropical_chain_complex(n, edges)
    print(f"  C₀ dim = {complex_data['C0_dim']}")
    print(f"  C₁ dim = {complex_data['C1_dim']}")
    print(f"  β₁ = {complex_data['beta_1']}")
    print(f"  Off-diag factorization: {verify_offdiag_factorization(n, edges)}")

    # Example 4: Petersen graph
    print("\nPetersen Graph:")
    n = 10
    outer = [(i, (i+1) % 5) for i in range(5)]
    inner = [(i+5, ((i+2) % 5)+5) for i in range(5)]
    spokes = [(i, i+5) for i in range(5)]
    edges = outer + inner + spokes
    complex_data = construct_tropical_chain_complex(n, edges)
    print(f"  C₀ dim = {complex_data['C0_dim']}")
    print(f"  C₁ dim = {complex_data['C1_dim']}")
    print(f"  β₁ = {complex_data['beta_1']}")
    print(f"  Off-diag factorization: {verify_offdiag_factorization(n, edges)}")
