#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Applications

Demonstrates real-world applications of tropical spectral theory:
1. Network routing depth analysis
2. Dynamic programming circuit complexity
3. Supply chain propagation bounds
"""

import numpy as np
from algorithms import (tropical_mul, tropical_pow, tropical_perm,
                         depth_lower_bound_from_perm, depth_lower_bound_from_spectral_gap)


def application_network_routing():
    """
    Application 1: Network Routing Depth Analysis

    In a communication network, data must propagate from sources to destinations
    through relay layers. Each relay adds latency (edge weight). The tropical
    circuit framework gives provable lower bounds on the number of relay layers
    needed to achieve a target end-to-end latency.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing — Relay Layer Lower Bounds")
    print("=" * 70)

    # Network with 4 nodes: 2 sources, 2 destinations
    # Latency matrix (microseconds)
    latency = np.array([
        [10, 5, 20, 15],  # Node 0 connections
        [8, 12, 3, 25],   # Node 1 connections
        [15, 7, 8, 4],    # Node 2 connections
        [20, 10, 6, 9]    # Node 3 connections
    ], dtype=float)

    print(f"\nNetwork latency matrix (μs):")
    print(latency.astype(int))

    perm_val, best_perm = tropical_perm(latency)
    print(f"\nTropical permanent = {int(perm_val)} μs")
    print(f"  Optimal assignment: {best_perm}")
    print(f"  Each source-destination pair uses a dedicated relay path")

    for max_relay_latency in [5, 3, 2, 1]:
        depth = depth_lower_bound_from_perm(latency, max_relay_latency)
        print(f"\n  With max relay latency = {max_relay_latency} μs:")
        print(f"    Minimum relay layers needed: d ≥ {depth}")
        print(f"    (from tropPerm/(n×W) = {perm_val}/{4*max_relay_latency} = {perm_val/(4*max_relay_latency):.1f})")


def application_dynamic_programming():
    """
    Application 2: Dynamic Programming Circuit Complexity

    Many optimization problems use dynamic programming, which corresponds
    to tropical matrix computation. The depth of the DP circuit determines
    the number of sequential stages. Our theorems give lower bounds on
    how many stages are needed.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Dynamic Programming — Stage Lower Bounds")
    print("=" * 70)

    # Transition cost matrix for a shortest-path DP
    # M[i][j] = cost of transitioning from state i to state j
    n = 5
    np.random.seed(42)
    transition = np.random.randint(2, 15, size=(n, n)).astype(float)

    print(f"\nTransition cost matrix ({n} states):")
    print(transition.astype(int))

    min_w = np.min(transition)
    max_W = np.max(transition)
    perm_val, _ = tropical_perm(transition)

    print(f"\nMin entry (spectral gap): {int(min_w)}")
    print(f"Max entry: {int(max_W)}")
    print(f"Tropical permanent: {int(perm_val)}")

    # Track how costs grow with DP stages
    print(f"\nCost evolution over DP stages:")
    for k in range(6):
        Mk = tropical_pow(transition, k)
        min_cost = np.min(Mk)
        max_cost = np.max(Mk)
        min_diag = min(Mk[i, i] for i in range(n))
        print(f"  Stage {k+1}: min_cost={int(min_cost):4d}, max_cost={int(max_cost):4d}, "
              f"min_cycle={int(min_diag):4d}, "
              f"bounds: [{int((k+1)*min_w)}, {int((k+1)*max_W)}]")

    target_cost = 30
    gap_bound = depth_lower_bound_from_spectral_gap(transition, target_cost)
    print(f"\n  To achieve total cost ≤ {target_cost}:")
    print(f"    Spectral gap bound: at most {gap_bound+1} stages needed")
    print(f"    (from B/w = {target_cost}/{int(min_w)} = {target_cost/min_w:.1f})")


def application_supply_chain():
    """
    Application 3: Supply Chain Propagation Bounds

    In a supply chain, goods propagate through processing layers.
    Each layer adds cost. The tropical framework tells us:
    - Minimum layers to achieve a target total cost
    - Maximum throughput given layer constraints
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Supply Chain — Processing Layer Bounds")
    print("=" * 70)

    # Cost matrix: processing costs between supply chain stages
    # M[i][j] = cost of routing item from facility i to facility j
    cost_matrix = np.array([
        [5, 2, 8, 12],
        [3, 6, 4, 9],
        [7, 1, 5, 3],
        [10, 8, 2, 7]
    ], dtype=float)

    print(f"\nFacility-to-facility cost matrix:")
    print(cost_matrix.astype(int))

    perm_val, best_assign = tropical_perm(cost_matrix)
    print(f"\nOptimal facility assignment (tropical permanent): ${int(perm_val)}")
    print(f"  Assignment: {best_assign}")
    for i, j in enumerate(best_assign):
        print(f"    Source {i} → Destination {j}: cost ${int(cost_matrix[i,j])}")

    print(f"\nProcessing depth analysis (cost per processing layer):")
    for cap in [1, 2, 3, 5]:
        depth = depth_lower_bound_from_perm(cost_matrix, cap)
        total_capacity = 4 * (depth + 1) * cap
        print(f"  Max cost/layer = ${cap}: need ≥ {depth+1} layers "
              f"(total capacity: ${total_capacity})")


if __name__ == "__main__":
    application_network_routing()
    application_dynamic_programming()
    application_supply_chain()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)
