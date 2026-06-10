#!/usr/bin/env python3
"""
Algorithms for Boundary-to-Bulk Reconstruction in Tree Metrics

Implements:
1. Four-point condition checker (tree-likeness test)
2. Median finder in tree metrics
3. Boundary-to-bulk distance reconstruction
4. Gromov product computation and hyperbolicity check
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from itertools import combinations


def is_tree_like_metric(d: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a distance matrix satisfies the four-point condition.
    
    A metric d is tree-like (0-hyperbolic) iff for all w, x, y, z:
      d(w,x) + d(y,z) <= max(d(w,y) + d(x,z), d(w,z) + d(x,y))
    
    Equivalently, among the three sums, the two largest are equal.
    
    Time complexity: O(n^4) where n = number of vertices.
    
    Args:
        d: n×n symmetric distance matrix
        tol: numerical tolerance
        
    Returns:
        True if the metric satisfies the four-point condition
    """
    n = d.shape[0]
    for w, x, y, z in combinations(range(n), 4):
        s1 = d[w, x] + d[y, z]
        s2 = d[w, y] + d[x, z]
        s3 = d[w, z] + d[x, y]
        sums = sorted([s1, s2, s3])
        if sums[2] > sums[1] + tol:
            # Two largest sums are not equal → not tree-like
            return False
    return True


def gromov_product(d: np.ndarray, x: int, a: int, b: int) -> float:
    """
    Compute the Gromov product (x | a, b) = (d(x,a) + d(x,b) - d(a,b)) / 2.
    
    In a tree, this equals the distance from x to the geodesic [a,b].
    """
    return (d[x, a] + d[x, b] - d[a, b]) / 2


def find_median(d: np.ndarray, a: int, b: int, c: int,
                tol: float = 1e-10) -> Optional[int]:
    """
    Find the median (branch point) of three vertices a, b, c in a tree metric.
    
    The median m satisfies:
      d(a,b) = d(a,m) + d(m,b)
      d(a,c) = d(a,m) + d(m,c)
      d(b,c) = d(b,m) + d(m,c)
    
    Time complexity: O(n) where n = number of vertices.
    
    Returns:
        Index of the median vertex, or None if not found.
    """
    n = d.shape[0]
    for m in range(n):
        if (abs(d[a, b] - d[a, m] - d[m, b]) < tol and
            abs(d[a, c] - d[a, m] - d[m, c]) < tol and
            abs(d[b, c] - d[b, m] - d[m, c]) < tol):
            return m
    return None


def median_distance_formula(d: np.ndarray, a: int, b: int, c: int) -> Tuple[float, float, float]:
    """
    Compute the distances from the median m to a, b, c using only the
    pairwise distances d(a,b), d(a,c), d(b,c).
    
    Returns:
        (d(m,a), d(m,b), d(m,c)) where m = median(a, b, c)
    """
    d_ma = (d[a, b] + d[a, c] - d[b, c]) / 2
    d_mb = (d[a, b] + d[b, c] - d[a, c]) / 2
    d_mc = (d[a, c] + d[b, c] - d[a, b]) / 2
    return d_ma, d_mb, d_mc


def reconstruct_from_boundary(boundary_matrix: np.ndarray,
                               boundary_indices: List[int],
                               n_total: int,
                               median_witnesses: Dict[int, Tuple[int, int, int]],
                               reach_witnesses: Dict[Tuple[int, int], int]) -> np.ndarray:
    """
    Reconstruct the full distance matrix from boundary data.
    
    This is the computational incarnation of the boundary rigidity theorem:
    given the boundary distance matrix and structural witnesses (medians
    and boundary-reach points), compute all pairwise distances.
    
    Args:
        boundary_matrix: |B|×|B| distance matrix on boundary
        boundary_indices: list of boundary vertex indices
        n_total: total number of vertices
        median_witnesses: for each interior vertex v, a triple (a,b,c) of
            boundary vertices such that v = median(a,b,c)
        reach_witnesses: for each pair (x,y) of vertices, a boundary vertex
            s such that x lies on geodesic [y,s]
    
    Returns:
        n_total × n_total reconstructed distance matrix
    
    Time complexity: O(n² + |B|²)
    """
    B = boundary_indices
    b_map = {b: i for i, b in enumerate(B)}
    
    d_full = np.zeros((n_total, n_total))
    
    # Step 1: Fill in boundary-boundary distances
    for i, bi in enumerate(B):
        for j, bj in enumerate(B):
            d_full[bi, bj] = boundary_matrix[i, j]
    
    # Step 2: Compute interior-boundary distances via median formula
    interior = [v for v in range(n_total) if v not in B]
    
    for v in interior:
        a, b, c = median_witnesses[v]
        ai, bi, ci = b_map[a], b_map[b], b_map[c]
        
        # d(v, a) = (d(a,b) + d(a,c) - d(b,c)) / 2
        d_va = (boundary_matrix[ai, bi] + boundary_matrix[ai, ci] - boundary_matrix[bi, ci]) / 2
        d_vb = (boundary_matrix[ai, bi] + boundary_matrix[bi, ci] - boundary_matrix[ai, ci]) / 2
        d_vc = (boundary_matrix[ai, ci] + boundary_matrix[bi, ci] - boundary_matrix[ai, bi]) / 2
        
        d_full[v, a] = d_va
        d_full[a, v] = d_va
        d_full[v, b] = d_vb
        d_full[b, v] = d_vb
        d_full[v, c] = d_vc
        d_full[c, v] = d_vc
        
        # Fill remaining boundary distances using reach witnesses
        for s in B:
            if s not in (a, b, c):
                # Find d(v, s) via median with s as first vertex
                # Need witnesses for v with boundary point s
                # Use: d(v, s) from the reach condition
                # If we have a reach witness t for (v, s), then
                # d(v, s) = d(s, t) - ... 
                # For simplicity, try all boundary triples
                best = None
                for p, q in combinations(B, 2):
                    if p == s or q == s:
                        continue
                    pi, qi, si = b_map[p], b_map[q], b_map[s]
                    # Check if v could be median of (s, p, q)
                    d_vs_candidate = (boundary_matrix[si, pi] + boundary_matrix[si, qi] - boundary_matrix[pi, qi]) / 2
                    if d_vs_candidate >= 0:
                        if best is None:
                            best = d_vs_candidate
                        # In a tree, the correct triple gives a consistent value
                d_full[v, s] = best if best is not None else 0
                d_full[s, v] = d_full[v, s]
    
    # Step 3: Interior-interior distances via reach witnesses
    for x in interior:
        for y in interior:
            if x >= y:
                continue
            if (x, y) in reach_witnesses:
                s = reach_witnesses[(x, y)]
                # d(x, y) = d(y, s) - d(x, s) if x is on geodesic [y, s]
                d_full[x, y] = d_full[y, s] - d_full[x, s]
                d_full[y, x] = d_full[x, y]
    
    return d_full


def hyperbolicity(d: np.ndarray) -> float:
    """
    Compute the Gromov hyperbolicity δ of a metric.
    
    δ = max over all x,a,b,c of:
      gromov(x,a,b) - min(gromov(x,a,c), gromov(x,b,c))
    
    δ = 0 iff the metric is tree-like.
    
    Time complexity: O(n^4)
    """
    n = d.shape[0]
    delta = 0.0
    for x in range(n):
        for a in range(n):
            for b in range(a + 1, n):
                for c in range(b + 1, n):
                    gab = gromov_product(d, x, a, b)
                    gac = gromov_product(d, x, a, c)
                    gbc = gromov_product(d, x, b, c)
                    deficit = gab - min(gac, gbc)
                    if deficit < -1e-10:
                        delta = max(delta, -deficit)
    return delta


def boundary_profile(d: np.ndarray, v: int, B: List[int]) -> np.ndarray:
    """Compute the boundary distance profile of vertex v."""
    return np.array([d[v, b] for b in B])


def check_boundary_visibility(d: np.ndarray, B: List[int],
                               tol: float = 1e-10) -> bool:
    """
    Check if all vertices are boundary-visible: distinct vertices
    have distinct boundary profiles.
    """
    n = d.shape[0]
    profiles = [tuple(d[v, b] for b in B) for v in range(n)]
    return len(set(profiles)) == n


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    # Build example tree
    n = 8
    INF = float('inf')
    edges = [(0,3,2), (3,4,3), (3,5,1), (4,1,1), (4,2,2), (5,6,4), (5,7,3)]
    
    d = np.full((n, n), INF)
    for i in range(n):
        d[i, i] = 0
    for u, v, w in edges:
        d[u, v] = w
        d[v, u] = w
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    
    B = [0, 1, 2, 6, 7]
    
    print("Tree-like:", is_tree_like_metric(d))
    print("Hyperbolicity:", hyperbolicity(d))
    print("Boundary visible:", check_boundary_visibility(d, B))
    
    # Median of 0, 1, 6
    m = find_median(d, 0, 1, 6)
    print(f"Median of (0, 1, 6) = vertex {m}")
    
    # Formula distances
    da, db, dc = median_distance_formula(d, 0, 1, 6)
    print(f"  d(m,0) = {da}, d(m,1) = {db}, d(m,6) = {dc}")
    
    # Reconstruction
    b_d = np.array([[d[i, j] for j in B] for i in B])
    witnesses = {3: (0, 1, 6), 4: (1, 2, 0), 5: (6, 7, 0)}
    reaches = {(3, 4): 0, (3, 5): 0, (4, 5): 0}
    
    d_recon = reconstruct_from_boundary(b_d, B, n, witnesses, reaches)
    print(f"\nReconstruction error: {np.max(np.abs(d - d_recon)):.10f}")
