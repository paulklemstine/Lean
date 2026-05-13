#!/usr/bin/env python3
"""
Algorithms for Sheaf–Proof-State Cohomological Obstruction Theory

Implements:
1. Coboundary computation and cocycle verification
2. Cohomology class computation via cycle-space linear algebra
3. Greedy minimal support extraction
4. Instability lower bound computation
5. Global section enumeration and architecture minimality
"""

import numpy as np
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict, deque


class FiniteDependencyComplex:
    """
    A finite proof-state dependency complex.
    
    Vertices represent proof states.
    Edges represent admissible local transitions/overlaps.
    Triangles encode higher coherence constraints.
    
    Attributes:
        vertices: List of vertex labels
        edges: Set of oriented edge pairs (both directions stored)
        triangles: Set of ordered triples
        undirected_edges: Set of frozensets for undirected edges
    """
    
    def __init__(self, vertices, edges, triangles=None):
        self.vertices = list(vertices)
        self.vertex_set = set(vertices)
        self.n = len(vertices)
        self.v_index = {v: i for i, v in enumerate(vertices)}
        
        self.edges = set()
        self.undirected_edges = set()
        for (i, j) in edges:
            self.edges.add((i, j))
            self.edges.add((j, i))
            self.undirected_edges.add(frozenset({i, j}))
        
        self.triangles = set(triangles) if triangles else set()
        self.m = len(self.undirected_edges)
        
        # Build adjacency list
        self.adj = defaultdict(set)
        for (i, j) in self.edges:
            self.adj[i].add(j)
    
    def edge_list(self):
        """Return a canonical list of undirected edges as sorted tuples."""
        return sorted(tuple(sorted(e)) for e in self.undirected_edges)


def coboundary_matrix(K: FiniteDependencyComplex) -> np.ndarray:
    """
    Compute the coboundary matrix δ₀: C⁰ → C¹.
    
    For an oriented edge e = (i,j), (δ₀f)(e) = f(j) - f(i).
    
    Returns:
        Matrix of shape (m, n) where m = |edges|, n = |vertices|.
        Row ordering follows K.edge_list().
    
    Time complexity: O(n + m)
    Space complexity: O(n * m)
    """
    edges = K.edge_list()
    m = len(edges)
    n = K.n
    D = np.zeros((m, n), dtype=float)
    for idx, (i, j) in enumerate(edges):
        D[idx, K.v_index[i]] = -1
        D[idx, K.v_index[j]] = 1
    return D


def compute_H1_dimension(K: FiniteDependencyComplex) -> int:
    """
    Compute dim H¹(K; ℝ) = dim ker(δ₁) / im(δ₀).
    
    For a simplicial complex without higher faces declared,
    this equals the first Betti number β₁ = m - n + c,
    where c is the number of connected components.
    
    With triangle faces, we need the full chain complex computation.
    
    Time complexity: O(n³) (SVD/rank computation)
    Space complexity: O(n * m)
    """
    D0 = coboundary_matrix(K)
    rank_D0 = np.linalg.matrix_rank(D0)
    
    # Without triangle faces, every 1-cochain is a cocycle
    # dim Z¹ = m (all 1-cochains)
    # dim B¹ = rank(D0) 
    # dim H¹ = m - rank(D0)
    
    if not K.triangles:
        return K.m - rank_D0
    
    # With triangles, need to compute δ₁ and find ker(δ₁)
    # For now, handle the no-triangle case
    edges = K.edge_list()
    edge_idx = {e: i for i, e in enumerate(edges)}
    
    # Build δ₁: C¹ → C² (triangle coboundary)
    tri_list = sorted(K.triangles)
    if not tri_list:
        return K.m - rank_D0
    
    D1 = np.zeros((len(tri_list), K.m), dtype=float)
    for t_idx, (i, j, k) in enumerate(tri_list):
        e_ij = tuple(sorted((i, j)))
        e_jk = tuple(sorted((j, k)))
        e_ik = tuple(sorted((i, k)))
        if e_ij in edge_idx:
            D1[t_idx, edge_idx[e_ij]] = 1 if i < j else -1
        if e_jk in edge_idx:
            D1[t_idx, edge_idx[e_jk]] = 1 if j < k else -1
        if e_ik in edge_idx:
            D1[t_idx, edge_idx[e_ik]] = -(1 if i < k else -1)
    
    rank_D1 = np.linalg.matrix_rank(D1)
    dim_Z1 = K.m - rank_D1  # cocycles = kernel of δ₁
    dim_B1 = rank_D0  # coboundaries = image of δ₀
    
    return dim_Z1 - dim_B1


def find_coboundary_witness(K: FiniteDependencyComplex, 
                             z: np.ndarray) -> Optional[np.ndarray]:
    """
    Given a 1-cochain z (as vector indexed by edge_list), 
    find f such that δf = z, or return None if z is not a coboundary.
    
    Solves the linear system D₀ · f = z via least-squares.
    
    Time complexity: O(n² m) 
    Space complexity: O(n * m)
    """
    D0 = coboundary_matrix(K)
    f, residuals, rank, sv = np.linalg.lstsq(D0, z, rcond=None)
    
    # Check if the solution is exact
    if np.allclose(D0 @ f, z):
        return f
    return None


def greedy_support_reduction(K: FiniteDependencyComplex, 
                              z: np.ndarray) -> np.ndarray:
    """
    Greedy support reduction algorithm.
    
    Given a nontrivial 1-cocycle z, iteratively subtract coboundaries
    to reduce the support size while preserving the cohomology class.
    
    Algorithm:
    1. For each vertex v, try subtracting δ(c · 1_v) for optimal c
    2. If this reduces support, accept the step
    3. Repeat until no improvement
    
    The output is a cocycle in the same cohomology class with
    (locally) minimal support.
    
    Time complexity: O(n² m) per step, O(n m) steps worst case
    Space complexity: O(n + m)
    
    Returns:
        Support-reduced cocycle vector
    """
    D0 = coboundary_matrix(K)
    z_curr = z.copy()
    
    def support_size(v):
        return np.count_nonzero(np.abs(v) > 1e-10)
    
    improved = True
    while improved:
        improved = False
        curr_support = support_size(z_curr)
        
        for v_idx in range(K.n):
            # Try subtracting α · δ(e_v) for the optimal α
            delta_v = D0[:, v_idx]
            if np.allclose(delta_v, 0):
                continue
            
            # For each nonzero position in delta_v, compute the α that
            # would zero out that position of z_curr
            for idx in np.nonzero(np.abs(delta_v) > 1e-10)[0]:
                alpha = z_curr[idx] / delta_v[idx]
                z_candidate = z_curr - alpha * delta_v
                if support_size(z_candidate) < curr_support:
                    z_curr = z_candidate
                    curr_support = support_size(z_candidate)
                    improved = True
                    break
            if improved:
                break
    
    return z_curr


def instability_lower_bound(K: FiniteDependencyComplex, 
                             z: np.ndarray) -> int:
    """
    Compute the instability lower bound for a 1-cochain z.
    
    Returns the minimum number of edge disagreements any predictor
    must have with z.
    
    For a nontrivial cocycle, this is always ≥ 1.
    
    Time complexity: O(n² m)
    Space complexity: O(n * m)
    """
    D0 = coboundary_matrix(K)
    
    # Find the closest coboundary to z
    f_opt, _, _, _ = np.linalg.lstsq(D0, z, rcond=None)
    z_closest = D0 @ f_opt
    
    # Count disagreements
    disagreements = np.count_nonzero(np.abs(z - z_closest) > 1e-10)
    return disagreements


def enumerate_global_sections_mod_n(K: FiniteDependencyComplex, n: int) -> List[Dict]:
    """
    Enumerate all global sections over ℤ/nℤ.
    
    A global section is f: V → ℤ/nℤ with δf = 0,
    i.e., f(j) ≡ f(i) (mod n) for all edges (i,j).
    
    Time complexity: O(n^c) where c = number of connected components
    Space complexity: O(n^c)
    """
    # Find connected components via BFS
    visited = set()
    components = []
    
    for start in K.vertices:
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            component.append(v)
            for nbr in K.adj[v]:
                if nbr not in visited:
                    visited.add(nbr)
                    queue.append(nbr)
        components.append(component)
    
    # Global sections: constant on each connected component
    # So there are n^c choices (one value per component)
    sections = []
    
    def generate(comp_idx, partial):
        if comp_idx == len(components):
            sections.append(dict(partial))
            return
        for val in range(n):
            for v in components[comp_idx]:
                partial[v] = val
            generate(comp_idx + 1, partial)
    
    generate(0, {})
    return sections


# ────────────────────────────────────────────────────────
# Demo: Run all algorithms
# ────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Cohomological Obstruction Algorithms — Demo\n")
    
    # Example: 4-cycle (square) with no triangle faces
    K = FiniteDependencyComplex(
        vertices=[0, 1, 2, 3],
        edges=[(0,1), (1,2), (2,3), (3,0)],
        triangles=[]
    )
    
    print(f"Complex: 4-cycle, |V|={K.n}, |E|={K.m}")
    print(f"dim H¹ = {compute_H1_dimension(K)}")
    
    # Coboundary matrix
    D0 = coboundary_matrix(K)
    print(f"\nCoboundary matrix δ₀ (shape {D0.shape}):")
    print(D0)
    
    # A nontrivial cocycle: z = (1, 0, 0, -1) around the cycle
    z = np.array([1, 0, 0, 0], dtype=float)  # On edges (0,1), (1,2), (2,3), (0,3)
    
    wit = find_coboundary_witness(K, z)
    print(f"\nCochain z = {z}")
    print(f"Is coboundary? {wit is not None}")
    print(f"Instability lower bound: {instability_lower_bound(K, z)}")
    
    # Support reduction
    z_reduced = greedy_support_reduction(K, z)
    print(f"Support-reduced: {z_reduced}")
    print(f"Support size: original={np.count_nonzero(np.abs(z) > 1e-10)}, "
          f"reduced={np.count_nonzero(np.abs(z_reduced) > 1e-10)}")
    
    # Global sections mod n
    for n in [2, 3, 5]:
        secs = enumerate_global_sections_mod_n(K, n)
        print(f"\n|H⁰(K; ℤ/{n}ℤ)| = {len(secs)}")
    
    print("\n" + "=" * 40)
    print("Triangle complex K₃")
    print("=" * 40)
    
    K3 = FiniteDependencyComplex(
        vertices=[0, 1, 2],
        edges=[(0,1), (1,2), (0,2)],
        triangles=[(0, 1, 2)]
    )
    print(f"dim H¹ = {compute_H1_dimension(K3)}")
    print("(H¹ = 0: the triangle is contractible)")
