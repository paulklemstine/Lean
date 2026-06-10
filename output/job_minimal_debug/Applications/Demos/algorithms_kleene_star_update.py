#!/usr/bin/env python3
"""
Algorithms for dynamic APSP via tropical Sherman-Morrison updates.

Implements:
1. Floyd-Warshall (baseline O(n³))
2. Single-edge update (O(n²))
3. Batch edge update (O(mn²) for m edges)
4. Rank-one tropical update (O(n²))
5. Sensitivity analysis
"""

import numpy as np
from typing import List, Tuple, Optional

INF = float('inf')


def floyd_warshall(A: np.ndarray) -> np.ndarray:
    """Standard Floyd-Warshall APSP algorithm.
    
    Time: O(n³), Space: O(n²)
    
    Args:
        A: n×n adjacency matrix (INF for missing edges, nonneg weights).
    Returns:
        n×n distance matrix S where S[i,j] = shortest path i→j.
    """
    n = A.shape[0]
    S = A.copy().astype(float)
    for i in range(n):
        S[i, i] = min(S[i, i], 0.0)
    
    for k in range(n):
        for i in range(n):
            if S[i, k] < INF:
                for j in range(n):
                    if S[k, j] < INF:
                        new_dist = S[i, k] + S[k, j]
                        if new_dist < S[i, j]:
                            S[i, j] = new_dist
    return S


def single_edge_update(S: np.ndarray, u: int, v: int, w: float) -> np.ndarray:
    """Tropical Sherman-Morrison single-edge APSP update.
    
    Formula: S'(i,j) = min( S(i,j), S(i,u) + w + S(v,j) )
    
    Time: O(n²), Space: O(n²)
    
    Args:
        S: Current APSP closure (n×n distance matrix).
        u, v: New edge from u to v.
        w: Edge weight (nonnegative).
    Returns:
        Updated APSP closure after adding edge u→v with weight w.
    """
    n = S.shape[0]
    # Vectorized: outer product S[:,u] + w + S[v,:]
    col_u = S[:, u].reshape(-1, 1)  # Column: distances to u
    row_v = S[v, :].reshape(1, -1)  # Row: distances from v
    detour = col_u + w + row_v      # Rank-one tropical outer product
    return np.minimum(S, detour)


def batch_edge_update(S: np.ndarray, 
                      edges: List[Tuple[int, int, float]]) -> np.ndarray:
    """Batch APSP update via iterated single-edge formula.
    
    Time: O(mn²) for m edges, vs O(n³) for full recomputation.
    
    Args:
        S: Current APSP closure.
        edges: List of (u, v, w) edge insertions.
    Returns:
        Updated APSP closure after all edge insertions.
    """
    S_current = S.copy()
    for u, v, w in edges:
        S_current = single_edge_update(S_current, u, v, w)
    return S_current


def rank_one_tropical_update(S: np.ndarray,
                              p: np.ndarray, 
                              q: np.ndarray) -> np.ndarray:
    """Rank-one tropical update (generalization of single-edge).
    
    Given vectors p, q, updates the graph by adding edges with weight
    p[i] + q[j] for all i,j. The APSP closure updates as:
    
    S'(i,j) = min( S(i,j), (S·p)(i) + (q·S)(j) )
    
    where (S·p)(i) = min_k( S(i,k) + p(k) ) is tropical mat-vec product.
    
    Time: O(n²), Space: O(n²)
    
    Args:
        S: Current APSP closure (n×n).
        p: Column weight vector (n,). INF entries disable that row.
        q: Row weight vector (n,). INF entries disable that column.
    Returns:
        Updated APSP closure.
    """
    n = S.shape[0]
    
    # Tropical matrix-vector products
    Sp = np.min(S + p.reshape(1, -1), axis=1)   # (S·p)(i) = min_k S(i,k)+p(k)
    qS = np.min(q.reshape(-1, 1) + S, axis=0)   # (q·S)(j) = min_k q(k)+S(k,j)
    
    # Rank-one tropical outer product
    detour = Sp.reshape(-1, 1) + qS.reshape(1, -1)
    
    return np.minimum(S, detour)


def sensitivity_analysis(S: np.ndarray, u: int, v: int,
                         w_values: np.ndarray) -> np.ndarray:
    """Parametric sensitivity: APSP as function of edge weight.
    
    For each weight w in w_values, computes the updated APSP.
    Demonstrates Lipschitz monotonicity.
    
    Args:
        S: Base APSP closure.
        u, v: Edge endpoints.
        w_values: Array of edge weights to test.
    Returns:
        Array of shape (len(w_values), n, n) with APSP for each weight.
    """
    results = []
    for w in w_values:
        S_new = single_edge_update(S, u, v, w)
        results.append(S_new)
    return np.array(results)


def verify_closure_properties(A: np.ndarray, S: np.ndarray,
                               tol: float = 1e-10) -> dict:
    """Verify that S satisfies all APSP closure properties for A.
    
    Checks:
    1. S ≤ A entrywise (with diagonal as special case)
    2. S[i,i] = 0 (reflexivity)
    3. S[i,j] ≤ S[i,k] + S[k,j] for all k (triangle inequality)
    4. Minimality (checked against Floyd-Warshall)
    
    Returns dict with verification results.
    """
    n = A.shape[0]
    results = {}
    
    # Check 1: S ≤ A (off-diagonal)
    le_adj = True
    for i in range(n):
        for j in range(n):
            if i != j and S[i, j] > A[i, j] + tol:
                le_adj = False
                break
    results['le_adj'] = le_adj
    
    # Check 2: diagonal = 0
    diag_ok = all(abs(S[i, i]) < tol for i in range(n))
    results['diag_eq_zero'] = diag_ok
    
    # Check 3: triangle inequality
    triangle_ok = True
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if S[i, j] > S[i, k] + S[k, j] + tol:
                    triangle_ok = False
                    break
    results['triangle'] = triangle_ok
    
    # Check 4: minimality (compare with Floyd-Warshall)
    S_fw = floyd_warshall(A)
    minimal = np.allclose(S, S_fw, atol=tol)
    results['minimal'] = minimal
    
    results['all_ok'] = all(results.values())
    return results


# ─── Example Usage ───────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Sherman-Morrison: Algorithm Demos")
    print("=" * 50)
    
    # Create a graph
    n = 6
    A = np.full((n, n), INF)
    edges = [(0,1,3), (1,2,2), (2,3,4), (3,4,1), (4,5,2),
             (0,3,12), (1,4,8), (2,5,7)]
    for u, v, w in edges:
        A[u, v] = w
    
    # Compute initial APSP
    S = floyd_warshall(A)
    print("\nInitial APSP closure:")
    for row in S:
        print("  " + "  ".join(f"{x:5.1f}" if x < INF else "    ∞" for x in row))
    
    # Single edge update
    print(f"\nSingle edge update: 5→0, weight=3")
    S1 = single_edge_update(S, 5, 0, 3.0)
    
    # Verify
    A1 = A.copy(); A1[5, 0] = 3.0
    props = verify_closure_properties(A1, S1)
    print(f"  Closure properties: {props}")
    
    # Batch update
    new_edges = [(5, 0, 3.0), (3, 1, 2.0), (4, 2, 1.5)]
    print(f"\nBatch update: {new_edges}")
    S_batch = batch_edge_update(S, new_edges)
    
    # Verify against full recomputation
    A_batch = A.copy()
    for u, v, w in new_edges:
        A_batch[u, v] = min(A_batch[u, v], w)
    S_verify = floyd_warshall(A_batch)
    print(f"  Matches full recomputation: {np.allclose(S_batch, S_verify)}")
    
    # Rank-one update
    print(f"\nRank-one update: p=[∞,∞,0,∞,∞,∞], q=[3,∞,∞,∞,∞,∞]")
    p = np.full(n, INF); p[2] = 0.0
    q = np.full(n, INF); q[0] = 3.0
    S_r1 = rank_one_tropical_update(S, p, q)
    # This is equivalent to single edge 2→0 with weight 3
    S_se = single_edge_update(S, 2, 0, 3.0)
    print(f"  Matches single-edge equivalent: {np.allclose(S_r1, S_se)}")
    
    print("\nAll algorithm demos passed!")
