#!/usr/bin/env python3
"""Certified Reconstruction Algorithm for Closure-Cost / Lawvere Duality."""

import numpy as np

def reconstruct(n, cl, cost):
    """
    Extract canonical minimal Lawvere system from closure-cost presentation.
    
    Returns: (closed_elements, distance_matrix, certificate)
    
    Time: O(n^3) for validation, O(k^2) for extraction
    Space: O(k^2) where k = number of closed elements
    """
    cl = np.array(cl, dtype=int)
    cost = np.array(cost, dtype=float)
    
    # Find closed elements (fixed points)
    closed = [x for x in range(n) if cl[x] == x]
    k = len(closed)
    
    # Extract sub-distance matrix
    dist = np.zeros((k, k))
    for i, x in enumerate(closed):
        for j, y in enumerate(closed):
            dist[i, j] = cost[x, y]
    
    # Verify spectrum distance = cost (isometry)
    isometric = True
    for x in range(n):
        for y in range(n):
            diffs = np.maximum(cost[x, :] - cost[y, :], 0)
            sd = np.max(diffs)
            if abs(sd - cost[x, y]) > 1e-10:
                isometric = False
    
    cert = {
        "input_size": n,
        "output_size": k,
        "compression": f"{k/n:.0%}",
        "isometric": isometric,
        "separated": all(
            not (cost[x,y] < 1e-10 and cost[y,x] < 1e-10)
            for x in closed for y in closed if x != y
        )
    }
    
    return closed, dist, cert

# Demo: 6 elements, 3 closure classes
n = 6
cl = [0, 0, 2, 2, 4, 4]
cost = np.zeros((n, n))
pairs = {(0,2): 5, (2,0): 3, (0,4): 8, (4,0): 6, (2,4): 4, (4,2): 7}
for i in range(n):
    for j in range(n):
        ci, cj = cl[i], cl[j]
        if ci != cj:
            cost[i, j] = pairs.get((ci, cj), 100)

states, dist, cert = reconstruct(n, cl, cost)
print(f"Input: {n} elements → Output: {len(states)} states")
print(f"States: {states}")
print(f"Distances:
{dist}")
print(f"Certificate: {cert}")
