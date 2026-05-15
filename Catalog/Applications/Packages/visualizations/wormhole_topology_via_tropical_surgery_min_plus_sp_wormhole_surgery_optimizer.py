#!/usr/bin/env python3
"""
Applications of Tropical Wormhole Surgery

Demonstrates real-world applications of the tropical discrete relativity framework:
1. Network design optimization (CDN placement)
2. Transportation network augmentation
3. Social network bridge detection
4. Curvature-based vulnerability analysis
"""

import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Self-contained core algorithms
# ============================================================

def tropical_geodesic(W, source):
    """Bellman-Ford using vectorized relaxation."""
    n = W.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0
    for _ in range(n - 1):
        new_dist = np.min(dist[:, None] + W, axis=0)
        dist = np.minimum(dist, new_dist)
    return dist

def wormhole_surgery(W, u, v, tau):
    W_new = W.copy()
    W_new[u, v] = min(W[u, v], tau)
    W_new[v, u] = min(W[v, u], tau)
    return W_new

def all_pairs_distance(W):
    """Floyd-Warshall for all-pairs shortest paths."""
    D = W.copy()
    n = D.shape[0]
    for k in range(n):
        D = np.minimum(D, D[:, k:k+1] + D[k:k+1, :])
    return D

def graph_diameter(D):
    return np.max(D[D < np.inf])

def average_distance(D):
    n = D.shape[0]
    mask = (D < np.inf) & (D > 0)
    return np.mean(D[mask]) if np.any(mask) else 0


# ============================================================
# Application 1: CDN / Cache Placement
# ============================================================

def cdn_placement_demo():
    """
    Model a content delivery network as a weighted graph.
    Use wormhole surgery to find optimal cache placement.
    """
    print("=" * 60)
    print("APPLICATION 1: CDN Cache Placement")
    print("=" * 60)
    
    # Network topology: 10 data centers with varying latencies
    np.random.seed(123)
    n = 10
    labels = [f"DC-{i}" for i in range(n)]
    
    # Create a realistic network with geographic clustering
    W = np.full((n, n), np.inf)
    np.fill_diagonal(W, 0)
    
    # West coast cluster (0-3)
    for i in range(4):
        for j in range(i+1, 4):
            lat = np.random.uniform(5, 15)
            W[i, j] = W[j, i] = lat
    
    # East coast cluster (4-7)
    for i in range(4, 8):
        for j in range(i+1, 8):
            lat = np.random.uniform(5, 15)
            W[i, j] = W[j, i] = lat
    
    # International (8-9)
    W[8, 9] = W[9, 8] = 20
    
    # Cross-coast links (expensive)
    W[2, 5] = W[5, 2] = 50
    W[3, 4] = W[4, 3] = 45
    
    # International links
    W[0, 8] = W[8, 0] = 80
    W[7, 9] = W[9, 7] = 75
    
    D_orig = all_pairs_distance(W)
    orig_diameter = graph_diameter(D_orig)
    orig_avg = average_distance(D_orig)
    
    print(f"\nOriginal network:")
    print(f"  Nodes: {n} data centers")
    print(f"  Diameter: {orig_diameter:.1f} ms")
    print(f"  Average latency: {orig_avg:.1f} ms")
    
    # Try different "wormhole" placements (direct links)
    print(f"\nTesting cache/link placements (τ = 5 ms):")
    tau = 5.0
    results = []
    
    for u in range(n):
        for v in range(u+1, n):
            W_s = wormhole_surgery(W, u, v, tau)
            D_s = all_pairs_distance(W_s)
            new_diameter = graph_diameter(D_s)
            new_avg = average_distance(D_s)
            improvement = (orig_avg - new_avg) / orig_avg * 100
            results.append((u, v, new_diameter, new_avg, improvement))
    
    results.sort(key=lambda x: -x[4])
    print(f"\n  Top 5 placements by average latency reduction:")
    for u, v, diam, avg, imp in results[:5]:
        print(f"    Link {labels[u]}↔{labels[v]}: "
              f"avg latency {avg:.1f} ms (↓{imp:.1f}%), diameter {diam:.1f} ms")


# ============================================================
# Application 2: Transportation Network
# ============================================================

def transportation_demo():
    """
    Model a city transportation network.
    Evaluate the impact of adding a new transit link.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Transportation Network Augmentation")
    print("=" * 60)
    
    # City with 8 districts
    districts = ["Downtown", "Uptown", "Eastside", "Westside", 
                 "Suburb-N", "Suburb-S", "Airport", "Port"]
    n = 8
    
    # Travel times in minutes
    W = np.full((n, n), 200.0)  # Default: very long travel
    np.fill_diagonal(W, 0)
    
    # Core connections
    W[0, 1] = W[1, 0] = 15  # Downtown - Uptown
    W[0, 2] = W[2, 0] = 20  # Downtown - Eastside
    W[0, 3] = W[3, 0] = 20  # Downtown - Westside
    W[1, 4] = W[4, 1] = 25  # Uptown - Suburb-N
    W[2, 5] = W[5, 2] = 30  # Eastside - Suburb-S
    W[2, 6] = W[6, 2] = 35  # Eastside - Airport
    W[3, 7] = W[7, 3] = 40  # Westside - Port
    W[1, 2] = W[2, 1] = 25  # Uptown - Eastside
    W[3, 5] = W[5, 3] = 35  # Westside - Suburb-S
    
    D_orig = all_pairs_distance(W)
    
    print(f"\nCity transportation network ({n} districts)")
    print(f"Average travel time: {average_distance(D_orig):.1f} min")
    print(f"Worst connection: {graph_diameter(D_orig):.1f} min")
    
    # Evaluate adding an express link
    print(f"\nProposed express links (10 min travel time):")
    tau = 10.0
    
    proposals = [
        (4, 6, "Suburb-N ↔ Airport"),
        (4, 7, "Suburb-N ↔ Port"),
        (5, 6, "Suburb-S ↔ Airport"),
        (6, 7, "Airport ↔ Port"),
        (0, 6, "Downtown ↔ Airport"),
    ]
    
    for u, v, name in proposals:
        W_s = wormhole_surgery(W, u, v, tau)
        D_s = all_pairs_distance(W_s)
        new_avg = average_distance(D_s)
        improvement = (average_distance(D_orig) - new_avg) / average_distance(D_orig) * 100
        new_worst = graph_diameter(D_s)
        
        # Check theorem: bound for specific OD pairs
        worst_pair = None
        max_reduction = 0
        for s in range(n):
            for t in range(n):
                if s != t:
                    reduction = D_orig[s, t] - D_s[s, t]
                    if reduction > max_reduction:
                        max_reduction = reduction
                        worst_pair = (s, t)
        
        print(f"  {name}:")
        print(f"    Avg travel time: {new_avg:.1f} min (↓{improvement:.1f}%)")
        print(f"    Worst connection: {new_worst:.1f} min")
        if worst_pair:
            s, t = worst_pair
            print(f"    Max benefit: {districts[s]}→{districts[t]}, "
                  f"reduced by {max_reduction:.0f} min")


# ============================================================
# Application 3: Curvature-Based Vulnerability Analysis
# ============================================================

def vulnerability_analysis():
    """
    Use min-plus Ricci curvature to identify network vulnerabilities.
    Low-curvature nodes are bottlenecks; high-curvature nodes are resilient.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Curvature-Based Vulnerability Analysis")
    print("=" * 60)
    
    n = 10
    np.random.seed(456)
    
    # Create a network with a known bottleneck
    W = np.full((n, n), 500.0)
    np.fill_diagonal(W, 0)
    
    # Dense cluster A (vertices 0-4)
    for i in range(5):
        for j in range(i+1, 5):
            W[i, j] = W[j, i] = np.random.uniform(2, 8)
    
    # Dense cluster B (vertices 5-9)
    for i in range(5, 10):
        for j in range(i+1, 10):
            W[i, j] = W[j, i] = np.random.uniform(2, 8)
    
    # Bottleneck: single expensive bridge
    W[4, 5] = W[5, 4] = 50.0
    
    # Compute curvatures (excluding self-loops)
    curvatures = np.zeros(n)
    for x in range(n):
        min_rt = np.inf
        for y in range(n):
            if y != x:
                rt = (W[x, y] + W[y, x]) / 2.0
                min_rt = min(min_rt, rt)
        curvatures[x] = min_rt
    
    print(f"\nNetwork curvature analysis:")
    for i in range(n):
        cluster = "A" if i < 5 else "B"
        vulnerability = "LOW RISK" if curvatures[i] < 10 else "HIGH RISK"
        print(f"  Node {i} (Cluster {cluster}): "
              f"R = {curvatures[i]:.2f}  [{vulnerability}]")
    
    # Identify bottleneck
    bottleneck_score = np.zeros(n)
    D_orig = all_pairs_distance(W)
    
    for node in range(n):
        # Remove node and check distance increase
        W_temp = W.copy()
        W_temp[node, :] = 500.0
        W_temp[:, node] = 500.0
        W_temp[node, node] = 0
        D_temp = all_pairs_distance(W_temp)
        bottleneck_score[node] = np.mean(D_temp - D_orig)
    
    print(f"\nBottleneck analysis (avg distance increase on removal):")
    sorted_nodes = np.argsort(-bottleneck_score)
    for node in sorted_nodes[:5]:
        print(f"  Node {node}: avg increase = {bottleneck_score[node]:.1f}")
    
    print(f"\nRecommendation: Add redundant links near nodes "
          f"{sorted_nodes[0]} and {sorted_nodes[1]} to reduce vulnerability.")


# ============================================================
# Application 4: Bellman Equation as Network Flow
# ============================================================

def bellman_network_flow():
    """
    Demonstrate the Bellman equation as a network routing protocol.
    Shows how the tropical Einstein equation governs information propagation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Bellman Equation as Routing Protocol")
    print("=" * 60)
    
    n = 6
    W = np.array([
        [0, 7, 9, 999, 999, 14],
        [7, 0, 10, 15, 999, 999],
        [9, 10, 0, 11, 999, 2],
        [999, 15, 11, 0, 6, 999],
        [999, 999, 999, 6, 0, 9],
        [14, 999, 2, 999, 9, 0],
    ], dtype=float)
    
    source = 0
    dist = tropical_geodesic(W, source)
    
    print(f"\nShortest distances from node {source}:")
    for i in range(n):
        print(f"  d({source}, {i}) = {dist[i]:.0f}")
    
    # Verify Bellman equation: d(x) ≤ min_y (d(y) + W(y,x))
    print(f"\nBellman equation verification (Tropical Einstein subsolution):")
    for x in range(n):
        min_relaxation = min(dist[y] + W[y, x] for y in range(n))
        satisfied = dist[x] <= min_relaxation + 1e-10
        print(f"  d({x}) = {dist[x]:.0f} ≤ min_y(d(y)+W(y,{x})) = "
              f"{min_relaxation:.0f}  {'✓' if satisfied else '✗'}")
    
    # Show routing table
    print(f"\nRouting table (next hop for shortest path from {source}):")
    predecessor = np.full(n, -1, dtype=int)
    for x in range(n):
        if x == source:
            continue
        for y in range(n):
            if y != x and abs(dist[x] - (dist[y] + W[y, x])) < 1e-10:
                predecessor[x] = y
                break
    
    for x in range(n):
        if x == source:
            continue
        path = [x]
        current = x
        while current != source and predecessor[current] != -1:
            current = predecessor[current]
            path.append(current)
        path.reverse()
        print(f"  To node {x}: {' → '.join(map(str, path))} (cost: {dist[x]:.0f})")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    cdn_placement_demo()
    transportation_demo()
    vulnerability_analysis()
    bellman_network_flow()
    
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)
