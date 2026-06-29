#!/usr/bin/env python3
"""
Algorithms for Metrized Graph Period Matrices and Tropical Jacobians

Implements the core computational methods from the formalized theory:
1. Period matrix construction Q = C^T diag(ℓ) C
2. Quadratic form evaluation (energy functional)
3. Stability bound computation
4. Cycle basis extraction from graphs
5. SNF comparison utilities

All algorithms have verified correctness properties in Lean 4.
"""

import numpy as np
from numpy.linalg import eigvalsh, det, svd, matrix_rank
from typing import List, Tuple, Optional, Dict
import itertools


# ──────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────

class MetrizedGraph:
    """A finite graph with positive edge lengths.
    
    Corresponds to the Lean structure MetrizedGraphData:
    - vertices: list of vertex labels
    - edges: list of (src, dst) pairs
    - lengths: positive real edge lengths
    """
    
    def __init__(self, n_vertices: int, edges: List[Tuple[int, int]], 
                 lengths: Optional[np.ndarray] = None):
        self.n_vertices = n_vertices
        self.edges = edges
        self.n_edges = len(edges)
        
        if lengths is None:
            self.lengths = np.ones(self.n_edges)
        else:
            assert len(lengths) == self.n_edges
            assert all(l > 0 for l in lengths), "Edge lengths must be positive"
            self.lengths = np.array(lengths, dtype=float)
    
    @property
    def genus(self) -> int:
        """First Betti number = |E| - |V| + connected components."""
        # Simple version assuming connected graph
        return self.n_edges - self.n_vertices + 1
    
    def adjacency_matrix(self) -> np.ndarray:
        """Weighted adjacency matrix."""
        A = np.zeros((self.n_vertices, self.n_vertices))
        for (u, v), w in zip(self.edges, self.lengths):
            A[u, v] += w
            A[v, u] += w
        return A
    
    def laplacian(self) -> np.ndarray:
        """Weighted graph Laplacian L = D - A."""
        A = self.adjacency_matrix()
        D = np.diag(A.sum(axis=1))
        return D - A
    
    def reduced_laplacian(self, vertex_to_remove: int = -1) -> np.ndarray:
        """Reduced Laplacian (delete one row and column).
        
        The determinant of this matrix equals the weighted number of
        spanning trees (Kirchhoff's theorem).
        """
        L = self.laplacian()
        idx = list(range(self.n_vertices))
        idx.pop(vertex_to_remove)
        return L[np.ix_(idx, idx)]


class CycleBasis:
    """An integral cycle basis for a graph.
    
    The cycle-edge incidence matrix C has dimensions |E| × g where g is the
    genus. Entry C[e, j] records the signed multiplicity of edge e in the
    j-th fundamental cycle.
    """
    
    def __init__(self, C: np.ndarray):
        self.C = C.astype(int)
        self.n_edges, self.genus = C.shape
        self.CR = C.astype(float)  # Real-valued version
    
    @classmethod
    def from_spanning_tree(cls, graph: MetrizedGraph, 
                           tree_edges: Optional[List[int]] = None) -> 'CycleBasis':
        """Extract a fundamental cycle basis from a spanning tree.
        
        Algorithm:
        1. If no tree given, compute one via BFS.
        2. For each non-tree edge e, find the fundamental cycle:
           the unique cycle in T ∪ {e}.
        3. Orient cycles consistently.
        
        Time complexity: O(|V| · |E|) for BFS + cycle extraction.
        Space complexity: O(|E| · g) for the incidence matrix.
        """
        n = graph.n_vertices
        m = graph.n_edges
        
        if tree_edges is None:
            tree_edges = cls._bfs_tree(graph)
        
        non_tree = [i for i in range(m) if i not in tree_edges]
        g = len(non_tree)  # genus
        
        # Build adjacency for tree
        tree_adj = {v: [] for v in range(n)}
        for idx in tree_edges:
            u, v = graph.edges[idx]
            tree_adj[u].append((v, idx))
            tree_adj[v].append((u, idx))
        
        C = np.zeros((m, g), dtype=int)
        
        for j, edge_idx in enumerate(non_tree):
            u, v = graph.edges[edge_idx]
            C[edge_idx, j] = 1  # non-tree edge is +1
            
            # Find path from u to v in tree via BFS
            path = cls._tree_path(tree_adj, u, v, n)
            if path is not None:
                for k in range(len(path) - 1):
                    a, b = path[k], path[k+1]
                    # Find which tree edge this is
                    for ti in tree_edges:
                        eu, ev = graph.edges[ti]
                        if (eu == a and ev == b):
                            C[ti, j] = -1
                            break
                        elif (eu == b and ev == a):
                            C[ti, j] = 1
                            break
        
        return cls(C)
    
    @staticmethod
    def _bfs_tree(graph: MetrizedGraph) -> List[int]:
        """BFS spanning tree, returns list of edge indices."""
        visited = {0}
        queue = [0]
        tree = []
        
        while queue:
            v = queue.pop(0)
            for i, (u, w) in enumerate(graph.edges):
                if u == v and w not in visited:
                    visited.add(w)
                    queue.append(w)
                    tree.append(i)
                elif w == v and u not in visited:
                    visited.add(u)
                    queue.append(u)
                    tree.append(i)
        
        return tree
    
    @staticmethod
    def _tree_path(adj, start, end, n):
        """Find path in tree from start to end via BFS."""
        visited = {start}
        parent = {start: None}
        queue = [start]
        
        while queue:
            v = queue.pop(0)
            if v == end:
                path = []
                while v is not None:
                    path.append(v)
                    v = parent[v]
                return path[::-1]
            for w, _ in adj[v]:
                if w not in visited:
                    visited.add(w)
                    parent[w] = v
                    queue.append(w)
        return None


# ──────────────────────────────────────────────────
# Period Matrix Algorithm
# ──────────────────────────────────────────────────

def compute_period_matrix(basis: CycleBasis, lengths: np.ndarray) -> np.ndarray:
    """Compute the period matrix Q = C^T · diag(ℓ) · C.
    
    This is the central construction of the theory. The period matrix:
    - Is symmetric (Theorem: periodMatrix_symm)
    - Satisfies x^T Q x = Σ_e ℓ_e (Σ_i C_ei x_i)² (Theorem: periodMatrix_quadratic_form)
    - Is positive definite when C has full rank (Theorem: periodMatrix_posDef)
    - Equals C^T C when all lengths are 1 (Theorem: uniform_length_period_equals_cycle_gram)
    
    Args:
        basis: Integral cycle basis with incidence matrix C
        lengths: Positive edge lengths
    
    Returns:
        g × g symmetric positive definite matrix Q
    
    Time complexity: O(|E| · g²)
    Space complexity: O(g²)
    """
    L = np.diag(lengths)
    return basis.CR.T @ L @ basis.CR


def evaluate_quadratic_form(Q: np.ndarray, x: np.ndarray) -> float:
    """Evaluate x^T Q x, the energy of cycle coordinate vector x.
    
    By the energy identity (periodMatrix_quadratic_form), this equals
    Σ_e ℓ_e (Σ_i C_ei x_i)², the weighted sum of squared edge flows.
    """
    return float(x @ Q @ x)


def compute_edge_energy(basis: CycleBasis, lengths: np.ndarray, 
                        x: np.ndarray) -> float:
    """Compute Σ_e ℓ_e (Σ_i C_ei x_i)², the edge-flow energy.
    
    By the energy identity, this equals x^T Q x.
    """
    flows = basis.CR @ x
    return float(np.sum(lengths * flows**2))


# ──────────────────────────────────────────────────
# Stability Analysis
# ──────────────────────────────────────────────────

def stability_bound(basis: CycleBasis, ℓ1: np.ndarray, ℓ2: np.ndarray, 
                    x: np.ndarray) -> Dict[str, float]:
    """Compute the stability bound for edge-length perturbation.
    
    Theorem (periodMatrix_stability_quadratic):
    |x^T(Q(ℓ) - Q(ℓ'))x| ≤ Σ_e |ℓ_e - ℓ'_e| · (Σ_i C_ei x_i)²
    
    Returns dict with actual difference, bound, and ratio.
    """
    Q1 = compute_period_matrix(basis, ℓ1)
    Q2 = compute_period_matrix(basis, ℓ2)
    
    actual = abs(float(x @ (Q1 - Q2) @ x))
    
    flows = basis.CR @ x
    bound = float(np.sum(np.abs(ℓ1 - ℓ2) * flows**2))
    
    return {
        "actual_difference": actual,
        "upper_bound": bound,
        "ratio": actual / bound if bound > 1e-15 else 0.0,
        "bound_satisfied": actual <= bound + 1e-12
    }


def eigenvalue_sensitivity(basis: CycleBasis, lengths: np.ndarray,
                           perturbation: np.ndarray, 
                           n_steps: int = 50) -> np.ndarray:
    """Track eigenvalues of Q(ℓ + t·δℓ) as t varies from 0 to 1.
    
    Returns array of shape (n_steps, g) with eigenvalue trajectories.
    """
    g = basis.genus
    t_values = np.linspace(0, 1, n_steps)
    trajectories = np.zeros((n_steps, g))
    
    for i, t in enumerate(t_values):
        Q = compute_period_matrix(basis, lengths + t * perturbation)
        trajectories[i] = eigvalsh(Q)
    
    return trajectories


# ──────────────────────────────────────────────────
# SNF Comparison
# ──────────────────────────────────────────────────

def smith_normal_form_diag(M: np.ndarray) -> List[int]:
    """Compute diagonal of Smith normal form of integer matrix M.
    
    Uses the standard algorithm: reduce by row/column operations
    preserving integer entries.
    
    Returns list of invariant factors (diagonal entries of SNF).
    """
    M = M.copy().astype(int)
    rows, cols = M.shape
    n = min(rows, cols)
    
    for k in range(n):
        # Find pivot
        found = False
        for iteration in range(100):  # prevent infinite loops
            # Find minimum nonzero entry in submatrix
            submat = np.abs(M[k:, k:])
            submat_nonzero = submat.copy()
            submat_nonzero[submat_nonzero == 0] = 10**18
            
            if np.min(submat_nonzero) >= 10**18:
                break
            
            mi, mj = np.unravel_index(np.argmin(submat_nonzero), submat_nonzero.shape)
            mi += k
            mj += k
            
            # Swap to pivot position
            M[[k, mi]] = M[[mi, k]]
            M[:, [k, mj]] = M[:, [mj, k]]
            
            if M[k, k] < 0:
                M[k] = -M[k]
            
            if M[k, k] == 0:
                break
            
            # Eliminate row k
            changed = False
            for j in range(k+1, cols):
                if M[k, j] != 0:
                    q = M[k, j] // M[k, k]
                    M[:, j] -= q * M[:, k]
                    if M[k, j] != 0:
                        changed = True
            
            # Eliminate column k
            for i in range(k+1, rows):
                if M[i, k] != 0:
                    q = M[i, k] // M[k, k]
                    M[i] -= q * M[k]
                    if M[i, k] != 0:
                        changed = True
            
            if not changed:
                # Check divisibility
                all_divisible = True
                for i in range(k+1, rows):
                    for j in range(k+1, cols):
                        if M[i, j] % M[k, k] != 0:
                            M[i] += M[k]
                            all_divisible = False
                            break
                    if not all_divisible:
                        break
                if all_divisible:
                    found = True
                    break
        
        if not found and M[k, k] == 0:
            break
    
    diag = [abs(M[i, i]) for i in range(n)]
    return [d for d in diag if d != 0]


def compare_period_snf(graph: MetrizedGraph, basis: CycleBasis) -> Dict:
    """Compare period matrix invariants with discrete SNF data.
    
    At uniform edge lengths (ℓ=1), the period matrix Q = C^T C is an
    integer matrix whose Smith normal form relates to the graph's
    critical group structure.
    """
    # Period matrix at uniform lengths
    Q_uniform = compute_period_matrix(basis, np.ones(graph.n_edges))
    Q_int = np.round(Q_uniform).astype(int)
    
    # Reduced Laplacian
    L_red = graph.reduced_laplacian()
    L_red_int = np.round(L_red).astype(int)
    
    # SNF of both
    snf_Q = smith_normal_form_diag(Q_int)
    snf_L = smith_normal_form_diag(L_red_int)
    
    return {
        "period_matrix": Q_int,
        "reduced_laplacian": L_red_int,
        "snf_period": snf_Q,
        "snf_laplacian": snf_L,
        "det_period": int(round(det(Q_uniform))),
        "det_laplacian": int(round(det(L_red))),
        "period_eigenvalues": eigvalsh(Q_uniform),
        "laplacian_eigenvalues": eigvalsh(L_red),
    }


# ──────────────────────────────────────────────────
# Example Graph Library
# ──────────────────────────────────────────────────

def cycle_graph(n: int, lengths: Optional[np.ndarray] = None) -> Tuple[MetrizedGraph, CycleBasis]:
    """Cycle graph C_n with optional edge lengths."""
    edges = [(i, (i+1) % n) for i in range(n)]
    C = np.ones((n, 1), dtype=int)
    graph = MetrizedGraph(n, edges, lengths)
    basis = CycleBasis(C)
    return graph, basis


def theta_graph(lengths: Optional[np.ndarray] = None) -> Tuple[MetrizedGraph, CycleBasis]:
    """Theta graph: 2 vertices, 3 parallel edges. Genus 2."""
    edges = [(0, 1), (0, 1), (0, 1)]
    C = np.array([[1, 1], [-1, 0], [0, -1]], dtype=int)
    graph = MetrizedGraph(2, edges, lengths)
    basis = CycleBasis(C)
    return graph, basis


def banana_graph(k: int, lengths: Optional[np.ndarray] = None) -> Tuple[MetrizedGraph, CycleBasis]:
    """Banana graph B_k: 2 vertices, k parallel edges. Genus k-1."""
    edges = [(0, 1)] * k
    g = k - 1
    C = np.zeros((k, g), dtype=int)
    for j in range(g):
        C[0, j] = 1
        C[j+1, j] = -1
    graph = MetrizedGraph(2, edges, lengths)
    basis = CycleBasis(C)
    return graph, basis


# ──────────────────────────────────────────────────
# Usage Example
# ──────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: Theta graph with custom lengths
    graph, basis = theta_graph(np.array([1.0, 2.0, 3.0]))
    Q = compute_period_matrix(basis, graph.lengths)
    
    print("Period Matrix for Theta Graph:")
    print(f"  Edge lengths: {graph.lengths}")
    print(f"  Q = {Q}")
    print(f"  Eigenvalues: {eigvalsh(Q)}")
    print(f"  Symmetric: {np.allclose(Q, Q.T)}")
    
    # Energy identity verification
    x = np.array([1.0, -0.5])
    e1 = evaluate_quadratic_form(Q, x)
    e2 = compute_edge_energy(basis, graph.lengths, x)
    print(f"\n  Energy identity: x^TQx = {e1:.6f}, edge energy = {e2:.6f}")
    
    # Stability
    ℓ2 = np.array([1.1, 1.9, 3.2])
    result = stability_bound(basis, graph.lengths, ℓ2, x)
    print(f"\n  Stability: actual={result['actual_difference']:.6f}, "
          f"bound={result['upper_bound']:.6f}, "
          f"satisfied={result['bound_satisfied']}")
    
    # SNF comparison at uniform lengths
    graph_uniform, basis_uniform = theta_graph()
    comparison = compare_period_snf(graph_uniform, basis_uniform)
    print(f"\n  SNF comparison (uniform lengths):")
    print(f"    Q = {comparison['period_matrix']}")
    print(f"    SNF(Q) = {comparison['snf_period']}")
    print(f"    det(Q) = {comparison['det_period']}")
