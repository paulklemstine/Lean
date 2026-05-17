#!/usr/bin/env python3
"""Tropical Matrix Powering Algorithms - Self-contained"""
import numpy as np

INF = float('inf')

def trop_mul(A, B):
    """Min-plus matrix multiplication. Time: O(n³)"""
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i,j] = min(C[i,j], A[i,k] + B[k,j])
    return C

def trop_pow(G, k):
    """Tropical power via repeated squaring. Time: O(n³ log k)"""
    n = G.shape[0]
    result = np.full((n, n), INF)
    np.fill_diagonal(result, 0)
    base = G.copy()
    while k > 0:
        if k % 2 == 1:
            result = trop_mul(result, base)
        base = trop_mul(base, base)
        k //= 2
    return result

def separation_gap(G):
    """Compute minimum separation gap. > 0 iff strictly separated."""
    n = G.shape[0]
    min_gap = INF
    for i in range(n):
        for j in range(n):
            vals = sorted(G[i,k] + G[k,j] for k in range(n))
            if len(vals) >= 2:
                min_gap = min(min_gap, vals[1] - vals[0])
    return min_gap

# Example
G = np.array([[1, 3, 7], [5, 2, 4], [8, 6, 3]], dtype=float)
print(f"Separation gap: {separation_gap(G)}")
print(f"G^5 =
{trop_pow(G, 5)}")
print(f"Power addition: G^3 ⊗ G^2 == G^5? {np.allclose(trop_mul(trop_pow(G,3), trop_pow(G,2)), trop_pow(G,5))}")
