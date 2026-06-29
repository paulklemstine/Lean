#!/usr/bin/env python3
"""
Algorithms for Overlap Support Theory

Implements the core algorithms from the overlap support theory paper:
1. Restricted Laplacian computation
2. Overlap interaction matrix extraction
3. Energy decomposition
4. Smith Normal Form computation
5. Invariant factor extraction and cokernel classification

All algorithms work with integer matrices over ℤ.
"""

import numpy as np
from typing import List, Tuple, Set, Optional
from itertools import combinations


class Graph:
    """Simple undirected graph represented by adjacency set."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        """
        Args:
            n: number of vertices (labeled 0..n-1)
            edges: list of (u,v) pairs with 0 ≤ u < v < n
        """
        self.n = n
        self.edges = edges
        self.adj: Set[Tuple[int, int]] = set()
        for u, v in edges:
            self.adj.add((u, v))
            self.adj.add((v, u))

    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return sum(1 for u in range(self.n) if (v, u) in self.adj)

    def is_adjacent(self, u: int, v: int) -> bool:
        """Check if u and v are adjacent."""
        return (u, v) in self.adj

    def laplacian(self) -> np.ndarray:
        """Compute the graph Laplacian matrix.

        L[i,j] = deg(i) if i == j
        L[i,j] = -1     if i ~ j
        L[i,j] = 0      otherwise

        Time: O(n²)
        Space: O(n²)
        """
        L = np.zeros((self.n, self.n), dtype=int)
        for i in range(self.n):
            for j in range(self.n):
                if i == j:
                    L[i, j] = self.degree(i)
                elif self.is_adjacent(i, j):
                    L[i, j] = -1
        return L

    def is_connected(self) -> bool:
        """Check connectivity via BFS. Time: O(n + m)."""
        if self.n == 0:
            return True
        visited = {0}
        queue = [0]
        while queue:
            v = queue.pop(0)
            for u in range(self.n):
                if u not in visited and (v, u) in self.adj:
                    visited.add(u)
                    queue.append(u)
        return len(visited) == self.n


def restricted_laplacian(G: Graph, S: List[int]) -> np.ndarray:
    """Compute the restricted Laplacian L_S.

    The restricted Laplacian is the principal submatrix of the graph
    Laplacian indexed by the vertices in S.

    Args:
        G: input graph
        S: sorted list of vertex indices

    Returns:
        |S| × |S| integer matrix

    Time: O(|S|² + n²) for Laplacian computation
    Space: O(|S|²)
    """
    L = G.laplacian()
    k = len(S)
    L_S = np.zeros((k, k), dtype=int)
    for a, i in enumerate(S):
        for b, j in enumerate(S):
            L_S[a, b] = L[i, j]
    return L_S


def diagonal_degree_matrix(L_S: np.ndarray) -> np.ndarray:
    """Extract the diagonal degree matrix D_S from restricted Laplacian L_S.

    D_S[i,i] = L_S[i,i] = deg(v_i)
    D_S[i,j] = 0 for i ≠ j

    Time: O(n²)
    Space: O(n²)
    """
    n = L_S.shape[0]
    D = np.zeros((n, n), dtype=int)
    for i in range(n):
        D[i, i] = L_S[i, i]
    return D


def overlap_interaction_matrix(L_S: np.ndarray) -> np.ndarray:
    """Extract the overlap interaction matrix Ω_S.

    Ω_S = L_S - D_S (off-diagonal part of the restricted Laplacian)
    Ω_S[i,j] = -1 if v_i ~ v_j (both in S)
    Ω_S[i,j] = 0  otherwise (including diagonal)

    Time: O(n²)
    Space: O(n²)
    """
    return L_S - diagonal_degree_matrix(L_S)


def is_separated(G: Graph, S: List[int]) -> bool:
    """Check if subset S is separated (independent) in G.

    S is separated if no two vertices in S are adjacent.

    Time: O(|S|²)
    """
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if G.is_adjacent(S[i], S[j]):
                return False
    return True


def overlap_energy(L_S: np.ndarray, x: np.ndarray) -> int:
    """Compute the overlap energy (Laplacian quadratic form) x^T L_S x.

    This is the discrete analogue of Dirichlet energy / dissipated power
    in electrical network theory.

    Time: O(n²)
    """
    return int(x @ L_S @ x)


def self_energy(L_S: np.ndarray, x: np.ndarray) -> int:
    """Compute the self-energy component: x^T D_S x.

    Equals sum of deg(v_i) * x_i² over i.

    Time: O(n)
    """
    D = diagonal_degree_matrix(L_S)
    return int(x @ D @ x)


def interaction_energy(L_S: np.ndarray, x: np.ndarray) -> int:
    """Compute the interaction energy component: x^T Ω_S x.

    Equals sum of -x_i * x_j over adjacent pairs (i,j) in S.

    Time: O(n²)
    """
    Omega = overlap_interaction_matrix(L_S)
    return int(x @ Omega @ x)


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute Smith Normal Form of integer matrix M.

    Returns (U, D, V) such that U @ M @ V = D where D is diagonal
    with d_1 | d_2 | ... | d_r and U, V are unimodular.

    Algorithm: iterative row/column reduction using integer GCD operations.

    Time: O(n³ log(max entry)) amortized
    Space: O(n²)
    """
    A = M.copy().astype(int)
    n, m = A.shape
    U = np.eye(n, dtype=int)
    Vt = np.eye(m, dtype=int)

    for k in range(min(n, m)):
        # Find nonzero pivot
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if A[i, j] != 0:
                    A[[k, i]] = A[[i, k]]
                    U[[k, i]] = U[[i, k]]
                    A[:, [k, j]] = A[:, [j, k]]
                    Vt[:, [k, j]] = Vt[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break

        changed = True
        while changed:
            changed = False
            if A[k, k] < 0:
                A[k] = -A[k]
                U[k] = -U[k]
            for j in range(k + 1, m):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    Vt[:, j] -= q * Vt[:, k]
                    if A[k, j] != 0:
                        A[:, [k, j]] = A[:, [j, k]]
                        Vt[:, [k, j]] = Vt[:, [j, k]]
                        changed = True
            for i in range(k + 1, n):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i] -= q * A[k]
                    U[i] -= q * U[k]
                    if A[i, k] != 0:
                        A[[k, i]] = A[[i, k]]
                        U[[k, i]] = U[[i, k]]
                        changed = True

    return U, A, Vt


def invariant_factors(M: np.ndarray) -> List[int]:
    """Compute the invariant factors of an integer matrix M.

    These are the nonzero diagonal entries of the Smith Normal Form,
    which determine the structure of ℤ^n / Im(M) as a finite abelian group.

    Time: O(n³ log(max entry))
    """
    _, D, _ = smith_normal_form(M)
    factors = []
    for i in range(min(D.shape)):
        d = abs(int(D[i, i]))
        if d != 0:
            factors.append(d)
    return sorted(factors)


def cokernel_structure(M: np.ndarray) -> str:
    """Describe the cokernel ℤ^n / Im(M) as a direct sum of cyclic groups.

    Uses the invariant factors from Smith Normal Form.

    Returns a string description like "ℤ/2ℤ ⊕ ℤ/6ℤ".
    """
    factors = invariant_factors(M)
    n = M.shape[0]
    parts = []
    units = sum(1 for f in factors if f == 1)
    nontrivial = [f for f in factors if f > 1]
    free_rank = n - len(factors)

    for f in nontrivial:
        parts.append(f"ℤ/{f}ℤ")
    if free_rank > 0:
        parts.extend(["ℤ"] * free_rank)

    if not parts:
        return "0"
    return " ⊕ ".join(parts)


def analyze_subset(G: Graph, S: List[int]) -> dict:
    """Complete analysis of a vertex subset S in graph G.

    Returns a dictionary with:
    - restricted_laplacian: L_S matrix
    - diagonal_degree: D_S matrix
    - interaction: Ω_S matrix
    - is_separated: bool
    - invariant_factors: list of int
    - cokernel: string description
    - sample_energies: list of (x, E, E_self, E_int) tuples
    """
    L_S = restricted_laplacian(G, S)
    D_S = diagonal_degree_matrix(L_S)
    Omega_S = overlap_interaction_matrix(L_S)
    sep = is_separated(G, S)
    factors = invariant_factors(L_S)
    coker = cokernel_structure(L_S)

    # Sample energy computations
    k = len(S)
    samples = []
    for _ in range(3):
        x = np.random.randint(-3, 4, size=k)
        E = overlap_energy(L_S, x)
        E_s = self_energy(L_S, x)
        E_i = interaction_energy(L_S, x)
        samples.append((x.tolist(), E, E_s, E_i))

    return {
        "subset": S,
        "restricted_laplacian": L_S,
        "diagonal_degree": D_S,
        "interaction": Omega_S,
        "is_separated": sep,
        "invariant_factors": factors,
        "cokernel": coker,
        "sample_energies": samples,
    }


# Example usage
if __name__ == "__main__":
    # Create the Petersen-like graph (cycle with chords)
    G = Graph(5, [(0,1), (1,2), (2,3), (3,4), (4,0)])
    print("Cycle graph C5 on 5 vertices")
    print(f"Laplacian:\n{G.laplacian()}\n")

    for S in [[0,1], [0,2], [0,1,2], [0,1,2,3], [0,1,2,3,4]]:
        result = analyze_subset(G, S)
        print(f"S = {S}")
        print(f"  Separated: {result['is_separated']}")
        print(f"  L_S:\n{result['restricted_laplacian']}")
        print(f"  Ω_S:\n{result['interaction']}")
        print(f"  Invariant factors: {result['invariant_factors']}")
        print(f"  Cokernel: {result['cokernel']}")
        print(f"  Sample energies: {result['sample_energies'][:1]}")
        print()
