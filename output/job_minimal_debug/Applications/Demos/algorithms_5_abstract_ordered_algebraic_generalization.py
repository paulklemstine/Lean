#!/usr/bin/env python3
"""
Algorithms based on the Ordered Additive Aggregation Principle.

Implements concrete algorithms where the aggregation theorem provides
correctness guarantees:
1. Bellman-Ford shortest path verification
2. Amortized analysis potential method verification
3. Tropical matrix power monotonicity
4. Multi-component cost budget verification
"""

import numpy as np
from typing import List, Tuple, Optional, Dict


def verify_shortest_path_certificate(
    adj: np.ndarray,
    dist: np.ndarray,
    source: int
) -> Dict:
    """
    Verify a shortest-path distance certificate using the aggregation principle.

    Given a directed graph with edge weights `adj[i,j]` and claimed distances
    `dist[i]` from `source`, verify that the reduced costs are nonneg.

    The aggregation theorem guarantees: if each edge (u,v) satisfies
      dist[u] + adj[u,v] ≥ dist[v]  (i.e., edge_weight + src_potential ≤ tgt_potential)
    then summing over any path preserves this bound globally.

    Args:
        adj: n×n adjacency matrix (inf for no edge)
        dist: claimed shortest distances from source
        source: source vertex index

    Returns:
        Dictionary with verification results
    """
    n = len(dist)
    violations = []
    reduced_costs = []

    for u in range(n):
        for v in range(n):
            if adj[u, v] < float('inf'):
                rc = adj[u, v] + dist[u] - dist[v]
                reduced_costs.append((u, v, rc))
                if rc < -1e-10:
                    violations.append((u, v, rc))

    is_valid = len(violations) == 0 and abs(dist[source]) < 1e-10

    return {
        "n_vertices": n,
        "source": source,
        "distances": dist.tolist(),
        "n_edges": len(reduced_costs),
        "n_violations": len(violations),
        "violations": violations,
        "is_valid_certificate": is_valid,
        "min_reduced_cost": min(rc for _, _, rc in reduced_costs) if reduced_costs else float('inf'),
    }


def verify_amortized_potential(
    actual_costs: np.ndarray,
    amortized_costs: np.ndarray,
    potentials: np.ndarray
) -> Dict:
    """
    Verify an amortized analysis using the potential method.

    The potential method says: amortized_cost[i] = actual_cost[i] + Φ[i+1] - Φ[i].
    The aggregation theorem guarantees that if each operation's amortized cost
    bounds the actual cost plus potential change, then the total amortized cost
    bounds the total actual cost plus net potential change.

    This is exactly: ∀i, w[i] + a[i] ≤ b[i] implies Σw + Σa ≤ Σb
    where w[i] = actual_cost[i], a[i] = Φ[i], b[i] = amortized_cost[i] + Φ[i]
    (after rearranging the potential telescope).

    Args:
        actual_costs: actual cost of each operation (length n)
        amortized_costs: claimed amortized cost of each operation (length n)
        potentials: potential function values Φ[0], ..., Φ[n] (length n+1)

    Returns:
        Dictionary with verification results
    """
    n = len(actual_costs)
    assert len(potentials) == n + 1

    # Check: amortized[i] ≥ actual[i] + Φ[i+1] - Φ[i]
    pointwise_valid = []
    for i in range(n):
        diff = amortized_costs[i] - (actual_costs[i] + potentials[i + 1] - potentials[i])
        pointwise_valid.append(diff >= -1e-10)

    total_actual = np.sum(actual_costs)
    total_amortized = np.sum(amortized_costs)
    net_potential = potentials[-1] - potentials[0]

    # Aggregation: Σ amortized ≥ Σ actual + Φ[n] - Φ[0]
    global_valid = total_amortized >= total_actual + net_potential - 1e-10

    return {
        "n_operations": n,
        "total_actual_cost": float(total_actual),
        "total_amortized_cost": float(total_amortized),
        "net_potential_change": float(net_potential),
        "pointwise_all_valid": all(pointwise_valid),
        "global_bound_valid": bool(global_valid),
        "slack": float(total_amortized - total_actual - net_potential),
    }


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    This is the standard operation for shortest-path computation:
    A^n gives shortest paths using exactly n edges.

    Args:
        A: n×n matrix (use inf for no connection)
        B: n×n matrix

    Returns:
        n×n tropical product matrix
    """
    n = A.shape[0]
    C = np.full((n, n), float('inf'))
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def verify_tropical_monotonicity(
    A: np.ndarray, B: np.ndarray, n_powers: int = 5
) -> Dict:
    """
    Verify that tropical matrix power is monotone: if A ≤ B entrywise,
    then A^⊗n ≤ B^⊗n entrywise for all n.

    This is a consequence of the aggregation principle applied to each
    entry of the tropical product.

    Args:
        A: n×n matrix
        B: n×n matrix with A[i,j] ≤ B[i,j] for all i,j
        n_powers: number of powers to check

    Returns:
        Dictionary with monotonicity verification results
    """
    dim = A.shape[0]
    assert np.all(A <= B + 1e-10), "A must be entrywise ≤ B"

    results = []
    A_pow = np.eye(dim) * 0  # tropical identity (0 on diagonal, inf off)
    for i in range(dim):
        for j in range(dim):
            if i != j:
                A_pow[i, j] = float('inf')

    B_pow = A_pow.copy()

    for power in range(1, n_powers + 1):
        A_pow = tropical_matrix_multiply(A_pow, A)
        B_pow = tropical_matrix_multiply(B_pow, B)
        monotone = np.all(A_pow <= B_pow + 1e-10)
        max_gap = np.max(np.where(np.isfinite(B_pow - A_pow), B_pow - A_pow, 0))
        results.append({
            "power": power,
            "monotone": bool(monotone),
            "max_gap": float(max_gap),
        })

    return {
        "dim": dim,
        "n_powers": n_powers,
        "all_monotone": all(r["monotone"] for r in results),
        "powers": results,
    }


def multi_component_budget_check(
    costs: np.ndarray,
    weights: np.ndarray,
    budgets: np.ndarray
) -> Dict:
    """
    Multi-component cost budget verification.

    Given k components, each with cost[i], weight[i], and budget[i],
    verify that if weight[i] + cost[i] ≤ budget[i] for each component,
    then the total weighted cost is within the total budget.

    This is a direct application of the aggregation principle in
    resource allocation, scheduling, and portfolio optimization.

    Args:
        costs: per-component costs
        weights: per-component weights (e.g., importance, priority)
        budgets: per-component budgets

    Returns:
        Dictionary with budget verification results
    """
    k = len(costs)
    pointwise = weights + costs <= budgets + 1e-10
    total_weighted_cost = np.sum(weights) + np.sum(costs)
    total_budget = np.sum(budgets)

    return {
        "n_components": k,
        "total_weighted_cost": float(total_weighted_cost),
        "total_budget": float(total_budget),
        "all_within_budget": bool(np.all(pointwise)),
        "global_within_budget": bool(total_weighted_cost <= total_budget + 1e-10),
        "surplus": float(total_budget - total_weighted_cost),
        "per_component_slack": (budgets - weights - costs).tolist(),
    }


# === Example usage ===

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Shortest Path Certificate Verification")
    print("=" * 60)

    # Small graph: 4 vertices
    INF = float('inf')
    adj = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [INF, INF, INF, 0],
    ], dtype=float)

    # True shortest distances from vertex 0
    dist = np.array([0, 3, 5, 6], dtype=float)
    result = verify_shortest_path_certificate(adj, dist, source=0)
    print(f"  Valid certificate: {result['is_valid_certificate']}")
    print(f"  Min reduced cost: {result['min_reduced_cost']:.4f}")
    print()

    print("=" * 60)
    print("Algorithm 2: Amortized Analysis Verification")
    print("=" * 60)

    # Dynamic array doubling: actual costs [1,1,1,4,1,1,1,8,...]
    # Amortized cost = 3 per operation
    n_ops = 8
    actual = np.array([1, 1, 4, 1, 1, 1, 1, 8], dtype=float)
    amortized = np.full(n_ops, 3.0)
    # Potential = 2*size - capacity
    potentials = np.array([0, 1, 2, 1, 2, 3, 4, 5, 2], dtype=float)

    result = verify_amortized_potential(actual, amortized, potentials)
    print(f"  Total actual: {result['total_actual_cost']}")
    print(f"  Total amortized: {result['total_amortized_cost']}")
    print(f"  Global bound valid: {result['global_bound_valid']}")
    print()

    print("=" * 60)
    print("Algorithm 3: Tropical Matrix Power Monotonicity")
    print("=" * 60)

    A = np.array([[0, 2, INF], [INF, 0, 1], [3, INF, 0]], dtype=float)
    B = np.array([[0, 3, INF], [INF, 0, 2], [4, INF, 0]], dtype=float)

    result = verify_tropical_monotonicity(A, B, n_powers=4)
    print(f"  All powers monotone: {result['all_monotone']}")
    for p in result['powers']:
        print(f"    Power {p['power']}: monotone={p['monotone']}, max_gap={p['max_gap']:.2f}")
    print()

    print("=" * 60)
    print("Algorithm 4: Multi-Component Budget Verification")
    print("=" * 60)

    costs = np.array([2.5, 1.8, 3.2, 0.9, 2.1])
    weights = np.array([1.0, 0.5, 1.5, 0.3, 0.8])
    budgets = np.array([4.0, 3.0, 5.0, 1.5, 3.5])

    result = multi_component_budget_check(costs, weights, budgets)
    print(f"  Components: {result['n_components']}")
    print(f"  Total weighted cost: {result['total_weighted_cost']:.2f}")
    print(f"  Total budget: {result['total_budget']:.2f}")
    print(f"  All within budget: {result['all_within_budget']}")
    print(f"  Global within budget: {result['global_within_budget']}")
    print(f"  Total surplus: {result['surplus']:.2f}")
