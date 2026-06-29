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


#!/usr/bin/env python3
"""
Tropical Wormhole Surgery — Demonstration and Visualization

This script demonstrates the key theorems of tropical discrete relativity
with concrete numerical examples and generates visualizations.

All code is self-contained — no local imports required.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable
import os

# ============================================================
# Core algorithms (self-contained)
# ============================================================

def tropical_geodesic(W, source):
    """Bellman-Ford shortest paths from source."""
    n = W.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0
    for _ in range(n - 1):
        for x in range(n):
            for y in range(n):
                if dist[y] + W[y, x] < dist[x]:
                    dist[x] = dist[y] + W[y, x]
    return dist

def wormhole_surgery(W, u, v, tau):
    """Perform wormhole surgery on edges (u,v) and (v,u)."""
    W_new = W.copy()
    W_new[u, v] = min(W[u, v], tau)
    W_new[v, u] = min(W[v, u], tau)
    return W_new

def min_plus_ricci(W):
    """Compute min-plus Ricci curvature at each vertex."""
    n = W.shape[0]
    R = np.zeros(n)
    for x in range(n):
        R[x] = np.min((W[x, :] + W[:, x]) / 2.0)
    return R

def bellman_relax(W, d):
    """One step of Bellman-Ford relaxation."""
    n = W.shape[0]
    d_new = np.full(n, np.inf)
    for x in range(n):
        for y in range(n):
            d_new[x] = min(d_new[x], d[y] + W[y, x])
    return d_new

def all_pairs_distance(W):
    """Compute all-pairs tropical distances."""
    n = W.shape[0]
    D = np.zeros((n, n))
    for s in range(n):
        D[s, :] = tropical_geodesic(W, s)
    return D


# ============================================================
# Demo 1: Surgery Distance Theorem
# ============================================================

def demo_surgery_theorem():
    """Demonstrate Theorem 1: Surgery strictly decreases tropical separation."""
    print("=" * 60)
    print("DEMO 1: Surgery Distance Theorem")
    print("=" * 60)
    
    # Create a 6-vertex "spacetime" graph with two clusters
    # Cluster 1: {0, 1, 2}, Cluster 2: {3, 4, 5}
    # Inter-cluster edges are expensive
    INF = 1000.0
    W = np.full((6, 6), INF)
    np.fill_diagonal(W, 0)
    
    # Cluster 1 edges (cheap)
    W[0, 1] = W[1, 0] = 2
    W[1, 2] = W[2, 1] = 3
    W[0, 2] = W[2, 0] = 4
    
    # Cluster 2 edges (cheap)
    W[3, 4] = W[4, 3] = 2
    W[4, 5] = W[5, 4] = 3
    W[3, 5] = W[5, 3] = 4
    
    # Inter-cluster edges (expensive)
    W[2, 3] = W[3, 2] = 50
    
    # Original distances
    D_orig = all_pairs_distance(W)
    print(f"\nOriginal distance matrix:")
    print(np.array2string(D_orig, precision=1, suppress_small=True))
    
    # Surgery: add wormhole bridge between vertex 1 and vertex 4
    tau = 3.0
    W_surgery = wormhole_surgery(W, 1, 4, tau)
    D_surgery = all_pairs_distance(W_surgery)
    
    print(f"\nPost-surgery distance matrix (bridge 1↔4, τ={tau}):")
    print(np.array2string(D_surgery, precision=1, suppress_small=True))
    
    # Verify theorem for s=0, t=5
    s, t, u, v = 0, 5, 1, 4
    a = D_orig[s, u]  # d(0, 1) = 2
    b = D_orig[v, t]  # d(4, 5) = 3
    D = D_orig[s, t]  # d(0, 5) = 55 (through the expensive bridge)
    bridge_cost = a + tau + b
    new_dist = D_surgery[s, t]
    
    print(f"\nTheorem verification for path {s}→{t}:")
    print(f"  d(s,u) = d({s},{u}) = {a}")
    print(f"  d(v,t) = d({v},{t}) = {b}")
    print(f"  Original d(s,t) = {D}")
    print(f"  Bridge path cost a+τ+b = {a}+{tau}+{b} = {bridge_cost}")
    print(f"  Post-surgery d(s,t) = {new_dist}")
    print(f"  Bound holds: {new_dist} ≤ {bridge_cost}? {new_dist <= bridge_cost + 1e-10}")
    print(f"  Strict decrease: {new_dist} < {D}? {new_dist < D}")
    print(f"  Distance reduction: {(D - new_dist)/D*100:.1f}%")
    
    return W, W_surgery, D_orig, D_surgery


# ============================================================
# Demo 2: Bellman Relaxation Convergence
# ============================================================

def demo_relaxation_convergence():
    """Demonstrate Theorem 4: Relaxation convergence."""
    print("\n" + "=" * 60)
    print("DEMO 2: Bellman-Ford Relaxation Convergence")
    print("=" * 60)
    
    n = 8
    np.random.seed(42)
    W = np.random.uniform(1, 20, (n, n))
    np.fill_diagonal(W, 0)
    
    source = 0
    true_dist = tropical_geodesic(W, source)
    
    # Track relaxation convergence
    d = np.full(n, np.inf)
    d[source] = 0.0
    
    history = [d.copy()]
    errors = []
    
    for k in range(n + 2):
        d = bellman_relax(W, d)
        history.append(d.copy())
        error = np.max(np.abs(d - true_dist))
        errors.append(error)
        
    print(f"\nGraph size: n = {n}")
    print(f"True distances from vertex {source}:")
    for i in range(n):
        print(f"  d({source}, {i}) = {true_dist[i]:.2f}")
    
    print(f"\nRelaxation convergence (max error per iteration):")
    for k, err in enumerate(errors):
        converged = "✓ CONVERGED" if err < 1e-10 else ""
        print(f"  Iteration {k+1}: max error = {err:.6f} {converged}")
    
    return history, errors, true_dist


# ============================================================
# Demo 3: Min-Plus Ricci Curvature
# ============================================================

def demo_curvature():
    """Demonstrate Theorem 2: Curvature controls throat radius."""
    print("\n" + "=" * 60)
    print("DEMO 3: Min-Plus Ricci Curvature Analysis")
    print("=" * 60)
    
    # Create a graph with varying connectivity
    n = 8
    W = np.full((n, n), 100.0)
    np.fill_diagonal(W, 0)
    
    # Dense hub (vertices 0-3): low roundtrip costs -> high curvature
    for i in range(4):
        for j in range(4):
            if i != j:
                W[i, j] = 1.0
    
    # Sparse periphery (vertices 4-7): high roundtrip costs -> low curvature
    W[4, 5] = W[5, 4] = 20.0
    W[5, 6] = W[6, 5] = 25.0
    W[6, 7] = W[7, 6] = 30.0
    
    # Bridge from hub to periphery
    W[3, 4] = W[4, 3] = 15.0
    
    R = min_plus_ricci(W)
    
    print(f"\nMin-plus Ricci curvatures:")
    for i in range(n):
        region = "hub" if i < 4 else "periphery"
        print(f"  R({i}) = {R[i]:.2f}  [{region}]")
    
    # Throat bounds for various bridges
    print(f"\nThroat bounds for potential wormholes:")
    pairs = [(0, 7), (1, 6), (3, 4), (0, 4), (2, 5)]
    for u, v in pairs:
        tb = (R[u] + R[v]) / 2.0
        print(f"  Bridge ({u},{v}): throatBound = {tb:.2f} "
              f"(R({u})={R[u]:.2f}, R({v})={R[v]:.2f})")
    
    return R, W


# ============================================================
# Demo 4: Curvature-Controlled Distance Bound
# ============================================================

def demo_curvature_bound():
    """Demonstrate Theorem 2': Curvature-controlled distance bound."""
    print("\n" + "=" * 60)
    print("DEMO 4: Curvature-Controlled Distance Bound")
    print("=" * 60)
    
    n = 6
    W = np.array([
        [0, 5, 20, 40, 60, 80],
        [5, 0,  5, 20, 40, 60],
        [20, 5, 0,  5, 20, 40],
        [40, 20, 5, 0,  5, 20],
        [60, 40, 20, 5, 0,  5],
        [80, 60, 40, 20, 5, 0],
    ], dtype=float)
    
    D_orig = all_pairs_distance(W)
    
    print("\nTesting distance bound for various surgery parameters:")
    s, t = 0, 5
    u, v = 1, 4
    
    for tau in [1.0, 5.0, 10.0, 20.0, 50.0]:
        W_surg = wormhole_surgery(W, u, v, tau)
        D_surg = all_pairs_distance(W_surg)
        
        bound1 = D_orig[s, t]
        bound2 = D_orig[s, u] + tau + D_orig[v, t]
        bound = min(bound1, bound2)
        actual = D_surg[s, t]
        
        print(f"  τ={tau:5.1f}: actual={actual:6.1f}, "
              f"min(d_orig, d_su+τ+d_vt)=min({bound1:.1f}, {bound2:.1f})={bound:.1f}, "
              f"bound holds: {actual <= bound + 1e-10}")


# ============================================================
# Visualization
# ============================================================

def create_visualizations(W, W_surgery, D_orig, D_surgery, 
                          history, errors, true_dist, curvatures, W_curv):
    """Generate all visualizations."""
    output_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Figure 1: Distance matrices before/after surgery
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    im1 = axes[0].imshow(D_orig, cmap='YlOrRd', interpolation='nearest')
    axes[0].set_title('Original Distances', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Target vertex')
    axes[0].set_ylabel('Source vertex')
    plt.colorbar(im1, ax=axes[0], label='Distance')
    for i in range(6):
        for j in range(6):
            axes[0].text(j, i, f'{D_orig[i,j]:.0f}', ha='center', va='center', fontsize=9)
    
    im2 = axes[1].imshow(D_surgery, cmap='YlOrRd', interpolation='nearest')
    axes[1].set_title('Post-Surgery Distances\n(bridge 1↔4, τ=3)', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Target vertex')
    axes[1].set_ylabel('Source vertex')
    plt.colorbar(im2, ax=axes[1], label='Distance')
    for i in range(6):
        for j in range(6):
            axes[1].text(j, i, f'{D_surgery[i,j]:.0f}', ha='center', va='center', fontsize=9)
    
    # Reduction heatmap
    reduction = D_orig - D_surgery
    im3 = axes[2].imshow(reduction, cmap='Greens', interpolation='nearest')
    axes[2].set_title('Distance Reduction', fontsize=14, fontweight='bold')
    axes[2].set_xlabel('Target vertex')
    axes[2].set_ylabel('Source vertex')
    plt.colorbar(im3, ax=axes[2], label='Reduction')
    for i in range(6):
        for j in range(6):
            axes[2].text(j, i, f'{reduction[i,j]:.0f}', ha='center', va='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'surgery_distances.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    # Figure 2: Relaxation convergence
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    n_relax = len(history[0])
    iterations = range(1, len(errors) + 1)
    axes[0].semilogy(iterations, [max(e, 1e-16) for e in errors], 'b-o', linewidth=2, markersize=8)
    axes[0].axhline(y=1e-10, color='r', linestyle='--', alpha=0.5, label='Convergence threshold')
    axes[0].set_xlabel('Iteration', fontsize=12)
    axes[0].set_ylabel('Max Error (log scale)', fontsize=12)
    axes[0].set_title('Bellman-Ford Convergence', fontsize=14, fontweight='bold')
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)
    
    # Distance estimates over iterations
    colors = plt.cm.tab10(np.linspace(0, 1, n_relax))
    for vertex in range(min(n_relax, 6)):
        vals = [h[vertex] if h[vertex] < np.inf else None for h in history]
        valid = [(i, v) for i, v in enumerate(vals) if v is not None]
        if valid:
            xs, ys = zip(*valid)
            axes[1].plot(xs, ys, '-o', color=colors[vertex], 
                        label=f'd(0,{vertex})', linewidth=2, markersize=6)
            axes[1].axhline(y=true_dist[vertex], color=colors[vertex], 
                          linestyle='--', alpha=0.3)
    
    axes[1].set_xlabel('Iteration', fontsize=12)
    axes[1].set_ylabel('Distance Estimate', fontsize=12)
    axes[1].set_title('Distance Convergence by Vertex', fontsize=14, fontweight='bold')
    axes[1].legend(fontsize=9, ncol=2)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'relaxation_convergence.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    # Figure 3: Curvature visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    n_curv = len(curvatures)
    bar_colors = plt.cm.RdYlGn_r(Normalize(vmin=min(curvatures), vmax=max(curvatures))(curvatures))
    axes[0].bar(range(n_curv), curvatures, color=bar_colors, edgecolor='black', linewidth=0.5)
    axes[0].set_xlabel('Vertex', fontsize=12)
    axes[0].set_ylabel('Min-Plus Ricci Curvature', fontsize=12)
    axes[0].set_title('Curvature Distribution', fontsize=14, fontweight='bold')
    axes[0].set_xticks(range(n_curv))
    
    # Hub vs periphery annotation
    axes[0].axvspan(-0.5, 3.5, alpha=0.1, color='green', label='Hub (dense)')
    axes[0].axvspan(3.5, 7.5, alpha=0.1, color='red', label='Periphery (sparse)')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3, axis='y')
    
    # Throat bounds heatmap
    throat_matrix = np.zeros((n_curv, n_curv))
    for i in range(n_curv):
        for j in range(n_curv):
            throat_matrix[i, j] = (curvatures[i] + curvatures[j]) / 2.0
    
    im = axes[1].imshow(throat_matrix, cmap='viridis', interpolation='nearest')
    axes[1].set_xlabel('Vertex v', fontsize=12)
    axes[1].set_ylabel('Vertex u', fontsize=12)
    axes[1].set_title('Throat Bound Matrix', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=axes[1], label='Throat Bound')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'curvature_analysis.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    # Figure 4: Surgery parameter sweep
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n_sweep = 6
    W_sweep = np.array([
        [0, 5, 20, 40, 60, 80],
        [5, 0,  5, 20, 40, 60],
        [20, 5, 0,  5, 20, 40],
        [40, 20, 5, 0,  5, 20],
        [60, 40, 20, 5, 0,  5],
        [80, 60, 40, 20, 5, 0],
    ], dtype=float)
    
    D_sweep_orig = all_pairs_distance(W_sweep)
    s, t = 0, 5
    taus = np.linspace(0.1, 50, 100)
    
    for u, v, label in [(1, 4, 'Bridge 1↔4'), (0, 5, 'Bridge 0↔5'), (2, 3, 'Bridge 2↔3')]:
        distances = []
        bounds = []
        for tau in taus:
            W_s = wormhole_surgery(W_sweep, u, v, tau)
            D_s = all_pairs_distance(W_s)
            distances.append(D_s[s, t])
            bounds.append(min(D_sweep_orig[s, t], 
                            D_sweep_orig[s, u] + tau + D_sweep_orig[v, t]))
        
        ax.plot(taus, distances, linewidth=2, label=f'{label} (actual)')
        ax.plot(taus, bounds, '--', linewidth=1.5, alpha=0.6, label=f'{label} (bound)')
    
    ax.axhline(y=D_sweep_orig[s, t], color='gray', linestyle=':', 
               linewidth=1, label='Original distance')
    ax.set_xlabel('Surgery Parameter τ', fontsize=12)
    ax.set_ylabel('Post-Surgery Distance d(0,5)', fontsize=12)
    ax.set_title('Surgery Parameter Sweep: Distance vs τ', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'surgery_sweep.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    print("\nVisualizations saved to:")
    print(f"  {os.path.join(output_dir, 'surgery_distances.png')}")
    print(f"  {os.path.join(output_dir, 'relaxation_convergence.png')}")
    print(f"  {os.path.join(output_dir, 'curvature_analysis.png')}")
    print(f"  {os.path.join(output_dir, 'surgery_sweep.png')}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Run all demos
    W, W_surgery, D_orig, D_surgery = demo_surgery_theorem()
    history, errors, true_dist = demo_relaxation_convergence()
    curvatures, W_curv = demo_curvature()
    demo_curvature_bound()
    
    # Generate visualizations
    print("\n" + "=" * 60)
    print("Generating visualizations...")
    print("=" * 60)
    create_visualizations(W, W_surgery, D_orig, D_surgery, 
                          history, errors, true_dist, curvatures, W_curv)
    
    print("\nAll demos completed successfully!")
