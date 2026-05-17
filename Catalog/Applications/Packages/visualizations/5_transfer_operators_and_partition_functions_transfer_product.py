#!/usr/bin/env python3
"""Tropical Transfer Operator Algorithms - Self-Contained"""
import numpy as np
INF = float('inf')

def tropical_mul_vec(M, v):
    w = len(v)
    result = np.full(w, INF)
    for j in range(w):
        for i in range(w):
            result[j] = min(result[j], v[i] + M[i, j])
    return result

def tropical_mat_mul(A, B):
    w = A.shape[0]
    result = np.full((w, w), INF)
    for i in range(w):
        for j in range(w):
            for k in range(w):
                result[i, j] = min(result[i, j], A[i, k] + B[k, j])
    return result

def tropical_identity(w):
    M = np.full((w, w), INF)
    np.fill_diagonal(M, 0.0)
    return M

def bellman_propagation(edge_costs, start, w, d):
    """O(dw^2) layer state computation."""
    state = np.full(w, INF); state[start] = 0
    states = [state.copy()]
    for k in range(d):
        state = tropical_mul_vec(edge_costs[k], state)
        states.append(state.copy())
    return states

def transfer_product(edge_costs, w, d):
    """O(dw^3) transfer matrix product."""
    prod = tropical_identity(w)
    for k in range(d):
        prod = tropical_mat_mul(prod, edge_costs[k])
    return prod

def min_cost_with_path(edge_costs, start, accept, w, d):
    """Min-cost path with traceback."""
    states = bellman_propagation(edge_costs, start, w, d)
    cost = states[d][accept]
    if cost == INF: return cost, None
    path = [accept]
    for k in range(d-1, -1, -1):
        for u in range(w):
            if states[k][u] + edge_costs[k][u, path[0]] == states[k+1][path[0]]:
                path.insert(0, u); break
    return cost, path

# Example
np.random.seed(42)
w, d = 4, 3
edge_costs = [np.random.randint(1,10,(w,w)).astype(float) for _ in range(d)]
for M in edge_costs:
    M[np.random.random((w,w)) > 0.7] = INF

print("Algorithms Demo")
print("=" * 40)
states = bellman_propagation(edge_costs, 0, w, d)
for i, s in enumerate(states):
    print(f"Layer {i}: {['%.0f' % x if x<INF else 'inf' for x in s]}")
cost, path = min_cost_with_path(edge_costs, 0, 3, w, d)
print(f"Min cost: {cost}, Path: {path}")
prod = transfer_product(edge_costs, w, d)
start_v = np.full(w, INF); start_v[0] = 0
result = tropical_mul_vec(prod, start_v)
print(f"Transfer product confirms: {result[3]}")
