#!/usr/bin/env python3
"""
Tropical Functorial Surgery Calculus — Real-World Applications

Demonstrates practical applications of tropical surgery composition:
1. Network routing optimization
2. Manufacturing pipeline scheduling
3. Viterbi decoding (speech/sequence recognition)
4. Supply chain cost optimization
"""

import numpy as np
from algorithms import min_plus_mul, Surgery, compose_surgeries, optimal_path, tropical_closure


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Network Routing (ISP Backbone Optimization)
# ═══════════════════════════════════════════════════════════════════════

def network_routing_demo():
    """Optimize routing through a multi-layer ISP network.

    Each layer is a 'surgery' that maps ingress points to egress points
    with associated latency costs. Composing surgeries via min-plus
    multiplication finds optimal end-to-end routes.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing Optimization")
    print("=" * 70)

    # Layer 1: Edge routers → Core routers (latency in ms)
    edge_to_core = Surgery(
        np.array([
            [2, 5, 10],   # Edge router A
            [8, 3, 4],    # Edge router B
            [6, 7, 1],    # Edge router C
            [3, 9, 5],    # Edge router D
        ], dtype=float),
        name="Edge→Core"
    )

    # Layer 2: Core routers → Distribution routers
    core_to_dist = Surgery(
        np.array([
            [1, 4, 7, 2],  # Core 1
            [3, 2, 5, 8],  # Core 2
            [6, 1, 3, 4],  # Core 3
        ], dtype=float),
        name="Core→Dist"
    )

    # Layer 3: Distribution routers → Customer premises
    dist_to_cust = Surgery(
        np.array([
            [2, 5],   # Dist A
            [3, 1],   # Dist B
            [4, 6],   # Dist C
            [1, 3],   # Dist D
        ], dtype=float),
        name="Dist→Customer"
    )

    # Compose the entire network path
    pipeline = [edge_to_core, core_to_dist, dist_to_cust]
    end_to_end = compose_surgeries(compose_surgeries(edge_to_core, core_to_dist), dist_to_cust)

    print(f"\nEnd-to-end latency matrix (edge router → customer):")
    print(end_to_end.cost)
    print(f"\nOptimal latency from Edge A to Customer 1: {end_to_end.cost[0,0]:.0f} ms")
    print(f"Optimal latency from Edge A to Customer 2: {end_to_end.cost[0,1]:.0f} ms")

    # Find optimal route
    cost, path = optimal_path(pipeline, start=0, end=1)
    labels = [["EdgeA","EdgeB","EdgeC","EdgeD"],
              ["Core1","Core2","Core3"],
              ["DistA","DistB","DistC","DistD"],
              ["Cust1","Cust2"]]
    route = " → ".join(labels[i][path[i]] for i in range(len(path)))
    print(f"\nOptimal route EdgeA → Cust2: {route} (latency: {cost:.0f} ms)")

    return end_to_end


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Manufacturing Pipeline Scheduling
# ═══════════════════════════════════════════════════════════════════════

def manufacturing_demo():
    """Optimize a manufacturing pipeline with multiple processing stages.

    Each stage has machines that process items with different costs.
    Tropical composition finds the minimum-cost production path.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Manufacturing Pipeline Optimization")
    print("=" * 70)

    # Stage 1: Raw material → Rough machining (3 input configs × 3 machines)
    rough = Surgery(
        np.array([
            [10, 15, 25],  # Standard steel
            [12, 8, 20],   # High-grade steel
            [18, 22, 12],  # Composite
        ], dtype=float),
        name="Rough machining"
    )

    # Stage 2: Rough → Precision machining (3 machines → 4 machines)
    precision = Surgery(
        np.array([
            [5, 8, 12, 6],   # Machine A
            [7, 4, 9, 11],   # Machine B
            [10, 6, 3, 8],   # Machine C
        ], dtype=float),
        name="Precision machining"
    )

    # Stage 3: Precision → Quality control & packaging (4 machines → 2 output lines)
    qc = Surgery(
        np.array([
            [3, 7],   # QC Line 1
            [5, 2],   # QC Line 2
            [4, 6],   # QC Line 3
            [2, 4],   # QC Line 4
        ], dtype=float),
        name="QC & Packaging"
    )

    total = compose_surgeries(compose_surgeries(rough, precision), qc)

    print(f"\nTotal cost matrix (material type → output line):")
    print(total.cost)

    materials = ["Standard steel", "High-grade steel", "Composite"]
    for i, mat in enumerate(materials):
        best_line = np.argmin(total.cost[i])
        print(f"  {mat}: optimal cost = {total.cost[i].min():.0f} "
              f"(output line {best_line + 1})")

    # Find optimal path for high-grade steel
    pipeline = [rough, precision, qc]
    cost, path = optimal_path(pipeline, start=1, end=1)
    print(f"\nOptimal path for high-grade steel → Output 2:")
    stage_names = ["Material", "Rough Machine", "Precision Machine", "QC Line"]
    for i, p in enumerate(path):
        print(f"  {stage_names[i]} {p+1}", end="")
    print(f" → Cost: {cost:.0f}")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Viterbi-Style Sequence Decoding
# ═══════════════════════════════════════════════════════════════════════

def viterbi_demo():
    """Demonstrate Viterbi decoding as tropical surgery composition.

    In speech recognition or DNA sequence alignment, each time step
    is a surgery: hidden states transition with costs, and emission
    costs are added. The composed surgery gives the Viterbi path.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Viterbi Decoding as Tropical Surgery")
    print("=" * 70)

    # Hidden Markov Model: 3 hidden states (Sunny, Cloudy, Rainy)
    # Observations: Walk, Shop, Clean
    states = ["Sunny", "Cloudy", "Rainy"]

    # Transition costs (-log probabilities)
    trans = np.array([
        [0.7, 1.5, 3.0],   # From Sunny
        [1.2, 0.8, 1.5],   # From Cloudy
        [2.5, 1.0, 0.5],   # From Rainy
    ], dtype=float)

    # Emission costs (-log probabilities)
    emit = {
        "Walk":  np.array([0.3, 1.2, 2.5]),
        "Shop":  np.array([1.0, 0.5, 1.8]),
        "Clean": np.array([2.0, 1.5, 0.4]),
    }

    # Observed sequence
    observations = ["Walk", "Shop", "Clean", "Walk"]

    print(f"\nObservation sequence: {' → '.join(observations)}")
    print(f"Hidden states: {states}")

    # Each time step is a surgery: add transition cost + emission cost
    surgeries = []
    for obs in observations:
        # Surgery: old state → new state, cost = transition + emission of new state
        S = trans.copy()
        for j in range(3):
            S[:, j] += emit[obs][j]
        surgeries.append(Surgery(S, name=f"emit({obs})"))

    # Initial costs (start from Sunny with 0 cost, others with higher cost)
    init_costs = np.array([0.0, 1.0, 2.0])

    # Compose all surgeries
    composed = surgeries[0]
    for s in surgeries[1:]:
        composed = compose_surgeries(composed, s)

    # Find best final state
    total_costs = init_costs.reshape(1, -1) @ np.eye(3)
    total_costs = min_plus_mul(total_costs, composed.cost)
    best_end = np.argmin(total_costs)
    print(f"\nBest ending state: {states[best_end]}")
    print(f"Minimum total cost: {total_costs.min():.2f}")

    # Optimal Viterbi cost from each starting state
    for i in range(3):
        best_j = np.argmin(composed.cost[i])
        print(f"  Start {states[i]}: best end = {states[best_j]}, "
              f"cost = {composed.cost[i, best_j]:.2f}")


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Supply Chain Optimization
# ═══════════════════════════════════════════════════════════════════════

def supply_chain_demo():
    """Model a supply chain as a sequence of tropical surgeries.

    Suppliers → Warehouses → Distribution centers → Retail stores.
    Transportation costs form surgery cost matrices.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Supply Chain Cost Optimization")
    print("=" * 70)

    # Suppliers → Regional warehouses
    supplier_to_warehouse = Surgery(
        np.array([
            [5, 12, 8],    # Supplier 1 (China)
            [15, 4, 10],   # Supplier 2 (Mexico)
            [10, 8, 3],    # Supplier 3 (Germany)
        ], dtype=float),
        name="Supplier→Warehouse"
    )

    # Warehouses → Distribution centers
    warehouse_to_dc = Surgery(
        np.array([
            [2, 7, 4, 9],   # East warehouse
            [6, 3, 8, 2],   # Central warehouse
            [5, 4, 1, 6],   # West warehouse
        ], dtype=float),
        name="Warehouse→DC"
    )

    # Distribution centers → Retail stores
    dc_to_retail = Surgery(
        np.array([
            [1, 3, 5],   # DC North
            [4, 2, 3],   # DC South
            [2, 5, 1],   # DC East
            [3, 1, 4],   # DC West
        ], dtype=float),
        name="DC→Retail"
    )

    # Full supply chain composition
    full_chain = compose_surgeries(
        compose_surgeries(supplier_to_warehouse, warehouse_to_dc),
        dc_to_retail
    )

    suppliers = ["China", "Mexico", "Germany"]
    stores = ["Store A", "Store B", "Store C"]

    print(f"\nFull supply chain cost matrix:")
    print(full_chain.cost)
    print()

    for i, sup in enumerate(suppliers):
        for j, store in enumerate(stores):
            print(f"  {sup:>8s} → {store}: ${full_chain.cost[i,j]:.0f}")
        print()

    # Find overall cheapest supply route
    best = np.unravel_index(np.argmin(full_chain.cost), full_chain.cost.shape)
    print(f"Cheapest overall: {suppliers[best[0]]} → {stores[best[1]]} "
          f"= ${full_chain.cost[best]:.0f}")

    # Perturbation analysis: what if China costs increase by $3?
    perturbed = supplier_to_warehouse.cost.copy()
    perturbed[0, :] += 3  # China surcharge
    perturbed_chain = compose_surgeries(
        compose_surgeries(Surgery(perturbed), warehouse_to_dc),
        dc_to_retail
    )
    print(f"\nAfter $3 surcharge on China shipping:")
    print(f"  New cheapest from China to Store A: ${perturbed_chain.cost[0,0]:.0f} "
          f"(was ${full_chain.cost[0,0]:.0f})")
    print(f"  Monotonicity verified: all costs increased = "
          f"{np.all(perturbed_chain.cost[0] >= full_chain.cost[0])}")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    network_routing_demo()
    manufacturing_demo()
    viterbi_demo()
    supply_chain_demo()

    print("\n" + "=" * 70)
    print("All application demonstrations completed!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Functorial Surgery Calculus — Demonstration

This script demonstrates the core mathematical results:
1. Min-plus matrix multiplication as surgery composition
2. Associativity of min-plus multiplication
3. Monotonicity under cost perturbations
4. Min-plus / max-plus duality via negation
5. Dynamic programming / shortest-path interpretation
"""

import numpy as np
from typing import List, Tuple

def min_plus_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.

    (A ⊛ B)[i,k] = min_j (A[i,j] + B[j,k])

    This is the Bellman composition of cost kernels.
    """
    m, n = A.shape
    n2, p = B.shape
    assert n == n2, "Inner dimensions must match"
    C = np.full((m, p), np.inf)
    for i in range(m):
        for k in range(p):
            C[i, k] = min(A[i, j] + B[j, k] for j in range(n))
    return C


def max_plus_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Max-plus matrix multiplication (dual tropical).

    (A ⊕ B)[i,k] = max_j (A[i,j] + B[j,k])
    """
    m, n = A.shape
    n2, p = B.shape
    assert n == n2
    C = np.full((m, p), -np.inf)
    for i in range(m):
        for k in range(p):
            C[i, k] = max(A[i, j] + B[j, k] for j in range(n))
    return C


# ─────────────────────────────────────────────────────────────────────
# Demo 1: Basic min-plus multiplication = surgery composition
# ─────────────────────────────────────────────────────────────────────
print("=" * 70)
print("DEMO 1: Min-Plus Matrix Multiplication = Surgery Composition")
print("=" * 70)

# Surgery S₁: 3 input states → 4 intermediate states
A = np.array([
    [2, 5, 1, 8],
    [3, 1, 7, 2],
    [6, 4, 3, 5]
], dtype=float)

# Surgery S₂: 4 intermediate states → 2 output states
B = np.array([
    [3, 7],
    [1, 4],
    [5, 2],
    [2, 6]
], dtype=float)

C = min_plus_mul(A, B)

print(f"\nSurgery S₁ cost matrix A (3×4):\n{A}")
print(f"\nSurgery S₂ cost matrix B (4×2):\n{B}")
print(f"\nComposed surgery (A ⊛ B) (3×2):\n{C}")
print("\nInterpretation: C[i,k] = min cost path from input i to output k")
print("  through any intermediate state j.")
print(f"\nExample: C[0,0] = {C[0,0]}")
print(f"  = min(A[0,0]+B[0,0], A[0,1]+B[1,0], A[0,2]+B[2,0], A[0,3]+B[3,0])")
print(f"  = min({A[0,0]}+{B[0,0]}, {A[0,1]}+{B[1,0]}, {A[0,2]}+{B[2,0]}, {A[0,3]}+{B[3,0]})")
print(f"  = min({A[0,0]+B[0,0]}, {A[0,1]+B[1,0]}, {A[0,2]+B[2,0]}, {A[0,3]+B[3,0]})")
print(f"  = {C[0,0]}")

# ─────────────────────────────────────────────────────────────────────
# Demo 2: Associativity — (A⊛B)⊛C = A⊛(B⊛C)
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 2: Associativity of Min-Plus Multiplication")
print("=" * 70)

# Three surgeries: 3→4→3→2
D = np.array([
    [1, 4, 2],
    [3, 2, 5],
    [7, 1, 3],
    [2, 6, 4]
], dtype=float)

E = np.array([
    [3, 1],
    [2, 5],
    [4, 2]
], dtype=float)

left_assoc = min_plus_mul(min_plus_mul(A, D), E)
right_assoc = min_plus_mul(A, min_plus_mul(D, E))

print(f"\nA (3×4):\n{A}")
print(f"\nD (4×3):\n{D}")
print(f"\nE (3×2):\n{E}")
print(f"\n(A ⊛ D) ⊛ E =\n{left_assoc}")
print(f"\nA ⊛ (D ⊛ E) =\n{right_assoc}")
print(f"\nAssociativity holds: {np.allclose(left_assoc, right_assoc)}")

# ─────────────────────────────────────────────────────────────────────
# Demo 3: Monotonicity under cost perturbation
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 3: Monotonicity — Cheaper Inputs → Cheaper Composition")
print("=" * 70)

A_cheaper = A - 1  # Every cost reduced by 1
B_cheaper = B - 0.5

C_original = min_plus_mul(A, B)
C_cheaper = min_plus_mul(A_cheaper, B_cheaper)

print(f"\nOriginal A ⊛ B:\n{C_original}")
print(f"\nCheaper (A-1) ⊛ (B-0.5):\n{C_cheaper}")
print(f"\nAll entries decreased: {np.all(C_cheaper <= C_original)}")
print(f"Entry-wise differences:\n{C_original - C_cheaper}")

# ─────────────────────────────────────────────────────────────────────
# Demo 4: Min-Plus / Max-Plus Duality
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 4: Min-Plus ↔ Max-Plus Duality via Negation")
print("=" * 70)

neg_minplus = -min_plus_mul(A, B)
maxplus_neg = max_plus_mul(-A, -B)

print(f"\n-(A ⊛ B) =\n{neg_minplus}")
print(f"\n(-A) ⊕ (-B) [max-plus] =\n{maxplus_neg}")
print(f"\nDuality holds: {np.allclose(neg_minplus, maxplus_neg)}")
print("\nInterpretation: minimizing costs ↔ maximizing negated energies")

# ─────────────────────────────────────────────────────────────────────
# Demo 5: Shortest-Path / Dynamic Programming Interpretation
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 5: Shortest-Path Interpretation")
print("=" * 70)

# Weighted adjacency matrix of a 5-node graph (∞ = no direct edge)
INF = np.inf
W = np.array([
    [0,   3,   8, INF, INF],
    [INF, 0,   2,   5, INF],
    [INF, INF, 0,   1,   6],
    [INF, INF, INF, 0,   4],
    [INF, INF, INF, INF, 0]
], dtype=float)

print("Weighted adjacency matrix W (5 nodes):")
print(W)

# Tropical matrix power = shortest k-hop paths
W2 = min_plus_mul(W, W)
W4 = min_plus_mul(W2, W2)

print(f"\nW² (shortest 1-or-2-hop paths):\n{W2}")
print(f"\nW⁴ (shortest paths up to 4 hops):\n{W4}")

# Floyd-Warshall for comparison
def floyd_warshall(W):
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    return D

FW = floyd_warshall(W)
print(f"\nFloyd-Warshall all-pairs shortest paths:\n{FW}")
print(f"\nW⁴ matches Floyd-Warshall: {np.allclose(W4, FW)}")
print("\n→ Surgery composition IS dynamic programming!")

# ─────────────────────────────────────────────────────────────────────
# Demo 6: Three-Stage Surgery Composition
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 6: Three-Stage Surgery Pipeline")
print("=" * 70)

S1 = np.array([[1, 3], [2, 1]], dtype=float)
S2 = np.array([[4, 2, 5], [1, 3, 2]], dtype=float)
S3 = np.array([[2], [3], [1]], dtype=float)

pipeline = min_plus_mul(min_plus_mul(S1, S2), S3)
pipeline_alt = min_plus_mul(S1, min_plus_mul(S2, S3))

print(f"S₁ (2×2): preprocessing costs\n{S1}")
print(f"\nS₂ (2×3): main processing costs\n{S2}")
print(f"\nS₃ (3×1): postprocessing costs\n{S3}")
print(f"\n(S₁ ⊛ S₂) ⊛ S₃ = {pipeline.flatten()}")
print(f"S₁ ⊛ (S₂ ⊛ S₃) = {pipeline_alt.flatten()}")
print(f"Associative: {np.allclose(pipeline, pipeline_alt)}")
print(f"\nOptimal pipeline cost from state 0: {pipeline[0,0]}")
print(f"Optimal pipeline cost from state 1: {pipeline[1,0]}")

print("\n" + "=" * 70)
print("All demonstrations completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Functorial Surgery Calculus — Visualizations

Generates figures showing:
1. Min-plus multiplication as shortest paths
2. Surgery composition pipeline diagram
3. Associativity verification heat map
4. Cost perturbation monotonicity
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import min_plus_mul, tropical_closure


def fig1_surgery_composition_heatmap():
    """Visualize surgery composition as heatmaps."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    A = np.array([[2, 5, 1, 8], [3, 1, 7, 2], [6, 4, 3, 5]], dtype=float)
    B = np.array([[3, 7], [1, 4], [5, 2], [2, 6]], dtype=float)
    C = min_plus_mul(A, B)

    for ax, mat, title in zip(axes[:3], [A, B, C],
                               ["S₁ cost (3×4)", "S₂ cost (4×2)", "S₁ ⊛ S₂ (3×2)"]):
        im = ax.imshow(mat, cmap='YlOrRd', aspect='auto')
        ax.set_title(title, fontsize=13, fontweight='bold')
        for i in range(mat.shape[0]):
            for j in range(mat.shape[1]):
                ax.text(j, i, f'{mat[i,j]:.0f}', ha='center', va='center',
                        fontsize=12, fontweight='bold')
        ax.set_xticks(range(mat.shape[1]))
        ax.set_yticks(range(mat.shape[0]))
        plt.colorbar(im, ax=ax, shrink=0.8)

    # Show the formula
    axes[3].axis('off')
    axes[3].text(0.5, 0.5,
        "Functoriality\nTheorem:\n\n"
        "updateMatrix(S₂ ∘ S₁)\n= minPlusMul(\n"
        "    updateMatrix(S₁),\n"
        "    updateMatrix(S₂))",
        fontsize=12, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightblue', alpha=0.8),
        fontfamily='monospace')

    plt.tight_layout()
    plt.savefig('fig1_surgery_composition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig1_surgery_composition.png")


def fig2_shortest_paths():
    """Visualize tropical closure as shortest path computation."""
    INF = np.inf
    W = np.array([
        [0,   3,   8, INF, INF],
        [INF, 0,   2,   5, INF],
        [INF, INF, 0,   1,   6],
        [INF, INF, INF, 0,   4],
        [INF, INF, INF, INF, 0]
    ])

    W2 = min_plus_mul(W, W)
    W4 = min_plus_mul(W2, W2)
    D = tropical_closure(W)

    fig, axes = plt.subplots(1, 4, figsize=(18, 4.5))
    titles = ["W (direct edges)", "W² (≤2 hops)", "W⁴ (≤4 hops)",
              "W* (all shortest)"]
    matrices = [W, W2, W4, D]

    for ax, mat, title in zip(axes, matrices, titles):
        display = mat.copy()
        display[display == INF] = np.nan
        im = ax.imshow(display, cmap='viridis_r', aspect='equal')
        ax.set_title(title, fontsize=12, fontweight='bold')
        for i in range(5):
            for j in range(5):
                val = mat[i, j]
                text = '∞' if np.isinf(val) else f'{val:.0f}'
                color = 'white' if (not np.isinf(val) and val > 6) else 'black'
                ax.text(j, i, text, ha='center', va='center',
                        fontsize=11, fontweight='bold', color=color)
        ax.set_xticks(range(5))
        ax.set_yticks(range(5))
        ax.set_xlabel("Target node")
        ax.set_ylabel("Source node")
        plt.colorbar(im, ax=ax, shrink=0.8)

    plt.suptitle("Tropical Power = Shortest Paths via Surgery Composition",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig2_shortest_paths.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig2_shortest_paths.png")


def fig3_associativity():
    """Verify and visualize associativity."""
    np.random.seed(42)
    sizes = [(3,4), (4,5), (5,3)]

    A = np.random.rand(sizes[0][0], sizes[0][1]) * 10
    B = np.random.rand(sizes[1][0], sizes[1][1]) * 10
    C = np.random.rand(sizes[2][0], sizes[2][1]) * 10

    left = min_plus_mul(min_plus_mul(A, B), C)
    right = min_plus_mul(A, min_plus_mul(B, C))
    diff = np.abs(left - right)

    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    im0 = axes[0].imshow(left, cmap='YlOrRd', aspect='auto')
    axes[0].set_title("(A ⊛ B) ⊛ C", fontsize=13, fontweight='bold')
    plt.colorbar(im0, ax=axes[0], shrink=0.8)

    im1 = axes[1].imshow(right, cmap='YlOrRd', aspect='auto')
    axes[1].set_title("A ⊛ (B ⊛ C)", fontsize=13, fontweight='bold')
    plt.colorbar(im1, ax=axes[1], shrink=0.8)

    im2 = axes[2].imshow(diff, cmap='Greens', aspect='auto', vmin=0, vmax=1e-10)
    axes[2].set_title("Difference (≈ 0)", fontsize=13, fontweight='bold')
    plt.colorbar(im2, ax=axes[2], shrink=0.8)
    for i in range(diff.shape[0]):
        for j in range(diff.shape[1]):
            axes[2].text(j, i, f'{diff[i,j]:.1e}', ha='center', va='center',
                        fontsize=8, color='darkgreen')

    plt.suptitle("Associativity: (A ⊛ B) ⊛ C = A ⊛ (B ⊛ C)", fontsize=14,
                 fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig3_associativity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig3_associativity.png")


def fig4_monotonicity():
    """Visualize monotonicity of min-plus multiplication."""
    np.random.seed(123)
    A = np.random.rand(4, 5) * 10
    B = np.random.rand(5, 4) * 10

    epsilons = np.linspace(0, 5, 20)
    original = min_plus_mul(A, B)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Track specific entries as we increase costs
    entries = [(0,0), (1,1), (2,2), (3,3), (0,3), (2,1)]
    colors = plt.cm.Set2(np.linspace(0, 1, len(entries)))

    for (i, k), color in zip(entries, colors):
        vals = []
        for eps in epsilons:
            A_pert = A + eps
            result = min_plus_mul(A_pert, B)
            vals.append(result[i, k])
        axes[0].plot(epsilons, vals, '-o', color=color, markersize=3,
                    label=f'C[{i},{k}]')

    axes[0].set_xlabel("Cost perturbation ε", fontsize=12)
    axes[0].set_ylabel("(A+ε) ⊛ B entry value", fontsize=12)
    axes[0].set_title("Monotonicity: increasing A → increasing A⊛B",
                      fontsize=12, fontweight='bold')
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Heatmap of cost increase
    A_big = A + 3
    C_big = min_plus_mul(A_big, B)
    increase = C_big - original

    im = axes[1].imshow(increase, cmap='Oranges', aspect='equal')
    axes[1].set_title("Cost increase (ε=3)", fontsize=12, fontweight='bold')
    for i in range(increase.shape[0]):
        for j in range(increase.shape[1]):
            axes[1].text(j, i, f'{increase[i,j]:.1f}', ha='center', va='center',
                        fontsize=10)
    plt.colorbar(im, ax=axes[1], shrink=0.8)

    plt.suptitle("Monotonicity of Min-Plus Multiplication",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig4_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig4_monotonicity.png")


def fig5_duality():
    """Visualize min-plus / max-plus duality."""
    A = np.array([[2, 5, 1], [3, 1, 7], [6, 4, 3]], dtype=float)
    B = np.array([[3, 1], [1, 4], [5, 2]], dtype=float)

    minplus = min_plus_mul(A, B)
    neg_minplus = -minplus

    # Max-plus of negated matrices
    negA, negB = -A, -B
    m, n = negA.shape
    n2, p = negB.shape
    maxplus_neg = np.full((m, p), -np.inf)
    for i in range(m):
        for k in range(p):
            maxplus_neg[i, k] = max(negA[i, j] + negB[j, k] for j in range(n))

    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    matrices = [neg_minplus, maxplus_neg, neg_minplus - maxplus_neg]
    titles = ["−(A ⊛ B)", "(−A) ⊕ (−B)\n[max-plus]", "Difference"]
    cmaps = ['RdYlBu', 'RdYlBu', 'Greens']

    for ax, mat, title, cmap in zip(axes, matrices, titles, cmaps):
        im = ax.imshow(mat, cmap=cmap, aspect='auto')
        ax.set_title(title, fontsize=13, fontweight='bold')
        for i in range(mat.shape[0]):
            for j in range(mat.shape[1]):
                ax.text(j, i, f'{mat[i,j]:.1f}', ha='center', va='center',
                        fontsize=12, fontweight='bold')
        plt.colorbar(im, ax=ax, shrink=0.8)

    plt.suptitle("Min-Plus ↔ Max-Plus Duality via Negation",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig5_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig5_duality.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    fig1_surgery_composition_heatmap()
    fig2_shortest_paths()
    fig3_associativity()
    fig4_monotonicity()
    fig5_duality()
    print("\nAll visualizations generated!")
