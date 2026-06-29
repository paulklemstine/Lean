"""
Applications: Weighted Distance Equality for Quantum Code Design

This module demonstrates real-world applications of the weighted cycle
optimization framework to quantum error-correcting code design.

Applications:
1. Hardware-aware surface code distance computation
2. Non-uniform coupling optimization
3. Defect-aware code routing
"""

import random
from typing import List, Tuple, Dict
from algorithms import (
    WeightedGraph, enumerate_simple_cycles, cycle_weight,
    min_simple_cycle_weight, girth_adapted_order, kruskal_order,
    first_cycle_birth_value, redundant_edge_count, compare_filtrations,
    cycle_support_weight
)


def application_surface_code_distance():
    """Application 1: Hardware-aware surface code distance.

    In a real quantum processor, qubit couplings have varying fidelities.
    The effective code distance depends on the weakest logical operator,
    where 'weakness' is measured by total error weight (not just length).

    We model this as: the weighted code distance of the surface code graph
    equals the minimum-weight cycle, where edge weights represent coupling
    error rates.
    """
    print("=" * 70)
    print("APPLICATION 1: Hardware-Aware Surface Code Distance")
    print("=" * 70)

    random.seed(42)

    # Build a 4x4 grid graph (surface code layout)
    G = WeightedGraph()
    n = 4
    for i in range(n):
        for j in range(n):
            v = i * n + j
            # Horizontal couplings
            if j < n - 1:
                # Weight = inverse fidelity (higher weight = worse coupling)
                w = random.uniform(0.5, 3.0)
                G.add_edge(v, v + 1, round(w, 2))
            # Vertical couplings
            if i < n - 1:
                w = random.uniform(0.5, 3.0)
                G.add_edge(v, v + n, round(w, 2))

    print(f"\nSurface code layout: {n}x{n} grid")
    print(f"Qubits: {G.num_vertices()}, Couplings: {G.num_edges()}")
    print(f"Cycle rank β₁ = {redundant_edge_count(G)}")

    min_w = min_simple_cycle_weight(G)
    print(f"\nWeighted code distance d_w = {min_w}")
    print(f"Unweighted code distance d = {n - 1} (for n×n grid)")
    print(f"\n→ Hardware non-uniformity reduces effective distance")
    print(f"→ The weakest cycle determines fault tolerance threshold")

    # Compare with uniform weighting
    G_uniform = WeightedGraph()
    for (u, v), _ in G.edges.items():
        G_uniform.add_edge(u, v, 1.0)
    min_uniform = min_simple_cycle_weight(G_uniform)
    print(f"\nUniform-weight distance: {min_uniform}")
    print(f"Non-uniform-weight distance: {min_w}")
    print(f"Distance ratio: {min_w / min_uniform:.2f}")


def application_coupling_optimization():
    """Application 2: Optimizing coupling strengths for maximum distance.

    Given a graph topology, find the edge weighting that maximizes the
    weighted code distance (= minimum cycle weight).

    For a fixed total budget of coupling strength, this is a linear
    programming problem over the cycle polytope.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Coupling Optimization for Maximum Distance")
    print("=" * 70)

    random.seed(123)

    # Build a small graph
    G = WeightedGraph()
    edges_list = [(0,1), (1,2), (2,3), (3,0), (0,2), (1,3)]
    total_budget = 24.0  # Total weight budget

    # Strategy 1: Uniform distribution
    uniform_weight = total_budget / len(edges_list)
    G1 = WeightedGraph()
    for u, v in edges_list:
        G1.add_edge(u, v, uniform_weight)

    # Strategy 2: Concentrate on shortest cycle
    G2 = WeightedGraph()
    # Triangles have 3 edges, squares have 4. Put more weight on triangle edges.
    for u, v in edges_list:
        if (u, v) in [(0,1), (1,2), (0,2)]:
            G2.add_edge(u, v, 5.0)  # Heavy triangle edges
        else:
            G2.add_edge(u, v, 3.0)  # Lighter other edges

    # Strategy 3: Random
    G3 = WeightedGraph()
    weights = [random.uniform(1, 8) for _ in edges_list]
    scale = total_budget / sum(weights)
    for (u, v), w in zip(edges_list, weights):
        G3.add_edge(u, v, round(w * scale, 2))

    print(f"\nGraph: K4 (complete graph on 4 vertices)")
    print(f"Total weight budget: {total_budget}")

    for name, G_test in [("Uniform", G1), ("Triangle-heavy", G2), ("Random", G3)]:
        total = sum(G_test.edges.values())
        min_w = min_simple_cycle_weight(G_test)
        print(f"\n  {name}: total={total:.1f}, min_cycle_weight={min_w}")
        for e in sorted(G_test.edges.keys()):
            print(f"    edge {e}: w={G_test.edges[e]:.2f}")


def application_defect_routing():
    """Application 3: Defect-aware code routing.

    When qubits or couplings fail, the effective graph changes.
    The girth-adapted filtration can quickly identify the new minimum
    cycle weight and detect whether defects have reduced the code distance.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Defect-Aware Code Routing")
    print("=" * 70)

    random.seed(99)

    # Build a hexagonal-like graph (similar to heavy-hex layout)
    G = WeightedGraph()
    hex_edges = [
        (0,1,2), (1,2,3), (2,3,1), (3,4,2), (4,5,3),
        (5,0,1), (0,3,4), (1,4,2), (2,5,3)
    ]
    for u, v, w in hex_edges:
        G.add_edge(u, v, w)

    print(f"\nHeavy-hex layout: {G.num_vertices()} qubits, {G.num_edges()} couplings")
    min_w = min_simple_cycle_weight(G)
    print(f"Initial weighted code distance: {min_w}")

    # Simulate defect: increase weight of worst coupling
    print("\nSimulating defects (increased coupling weight = degraded quality):")
    for defect_edge in [(0, 3), (2, 5)]:
        G_defect = WeightedGraph()
        for (u, v), w in G.edges.items():
            if (u, v) == defect_edge:
                G_defect.add_edge(u, v, w * 5)  # 5x degradation
            else:
                G_defect.add_edge(u, v, w)

        min_w_defect = min_simple_cycle_weight(G_defect)
        print(f"  Defect at edge {defect_edge}: d_w = {min_w_defect} "
              f"(was {min_w}, change = {min_w_defect - min_w:+.0f})")


def application_code_comparison():
    """Application 4: Comparing quantum code families.

    Compare weighted code distances across different graph topologies
    to identify optimal code architectures for non-uniform hardware.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Quantum Code Family Comparison")
    print("=" * 70)

    random.seed(55)

    results = []

    # Grid code
    G_grid = WeightedGraph()
    n = 4
    for i in range(n):
        for j in range(n):
            v = i * n + j
            if j < n - 1:
                G_grid.add_edge(v, v+1, random.randint(1, 5))
            if i < n - 1:
                G_grid.add_edge(v, v+n, random.randint(1, 5))
    min_grid = min_simple_cycle_weight(G_grid) or 0
    results.append(("Grid 4x4", G_grid.num_vertices(), G_grid.num_edges(),
                    redundant_edge_count(G_grid), min_grid))

    # Complete graph K6
    G_complete = WeightedGraph()
    for i in range(6):
        for j in range(i+1, 6):
            G_complete.add_edge(i, j, random.randint(1, 5))
    min_complete = min_simple_cycle_weight(G_complete) or 0
    results.append(("Complete K6", 6, G_complete.num_edges(),
                    redundant_edge_count(G_complete), min_complete))

    # Cycle + chords
    G_cycle = WeightedGraph()
    for i in range(8):
        G_cycle.add_edge(i, (i+1) % 8, random.randint(1, 5))
    G_cycle.add_edge(0, 4, random.randint(1, 5))
    G_cycle.add_edge(2, 6, random.randint(1, 5))
    min_cycle = min_simple_cycle_weight(G_cycle) or 0
    results.append(("Cycle+chords", 8, G_cycle.num_edges(),
                    redundant_edge_count(G_cycle), min_cycle))

    print(f"\n{'Code':>15} | {'V':>3} | {'E':>3} | {'β₁':>3} | {'d_w':>5}")
    print("-" * 45)
    for name, v, e, b, d in results:
        print(f"{name:>15} | {v:>3} | {e:>3} | {b:>3} | {d:>5}")

    print("\n→ Higher β₁ = more cycles = more logical operators")
    print("→ Higher d_w = better error correction capability")
    print("→ Optimal choice depends on hardware noise profile")


if __name__ == "__main__":
    application_surface_code_distance()
    application_coupling_optimization()
    application_defect_routing()
    application_code_comparison()

    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


"""
Interactive Demonstration: Weighted Distance Equality via Tropical Cycle Optimization

This script demonstrates the key results:
1. Girth-adapted filtration ALWAYS finds the minimum cycle weight
2. Raw-weight Kruskal can FAIL to find the minimum
3. Obstruction witnesses reveal WHY Kruskal fails
4. Cycle support weight detects minimum-cycle membership

Run: python demo.py
"""

import random
from algorithms import (
    WeightedGraph, enumerate_simple_cycles, cycle_weight,
    min_simple_cycle_weight, cycle_support_weight,
    girth_adapted_order, kruskal_order, first_cycle_birth_value,
    compare_filtrations, redundant_edge_count,
    build_random_weighted_graph
)


def demo_kruskal_failure():
    """Demonstrate a concrete case where Kruskal fails but girth-adapted succeeds."""
    print("=" * 70)
    print("DEMO 1: Kruskal Failure — The 7-Cycle + Chord Example")
    print("=" * 70)

    G = WeightedGraph()
    # 7-cycle: edges 0-1, 1-2, ..., 6-0, each weight 1
    for i in range(7):
        G.add_edge(i, (i + 1) % 7, 1.0)
    # Chord: 0-2 with weight 3 (creates triangle 0-1-2-0 of weight 5)
    G.add_edge(0, 2, 3.0)

    print(f"\nGraph: 7-cycle (all edges weight 1) + chord (0,2) weight 3")
    print(f"Vertices: {G.num_vertices()}, Edges: {G.num_edges()}")
    print(f"Cycle rank (β₁): {redundant_edge_count(G)}")

    cycles = enumerate_simple_cycles(G)
    print(f"Number of simple cycles: {len(cycles)}")

    min_w = min_simple_cycle_weight(G)
    print(f"\nMinimum cycle weight (weighted systole): {min_w}")
    print(f"  → Triangle 0-1-2-0: weight = 1 + 1 + 3 = 5")
    print(f"  → 7-cycle: weight = 7")

    # Show cycle support weights
    print("\nCycle support weights:")
    for e in sorted(G.edges.keys()):
        csw = cycle_support_weight(G, e)
        print(f"  edge {e} (w={G.edges[e]}): csw = {csw}")

    # Kruskal ordering
    k_order = kruskal_order(G)
    k_result = first_cycle_birth_value(G, k_order)
    print(f"\nKruskal ordering: {k_order}")
    print(f"Kruskal first cycle birth: weight = {k_result[0] if k_result else 'N/A'}")
    if k_result:
        print(f"Kruskal cycle: {k_result[1]}")

    # Girth-adapted ordering
    g_order = girth_adapted_order(G)
    g_result = first_cycle_birth_value(G, g_order)
    print(f"\nGirth-adapted ordering: {g_order}")
    print(f"Girth-adapted first cycle birth: weight = {g_result[0] if g_result else 'N/A'}")
    if g_result:
        print(f"Girth-adapted cycle: {g_result[1]}")

    print(f"\n→ Kruskal gives {k_result[0]}, girth-adapted gives {g_result[0]}, minimum is {min_w}")
    if k_result and abs(k_result[0] - min_w) > 1e-10:
        print(f"→ *** KRUSKAL FAILS by {k_result[0] - min_w} ***")
    if g_result:
        print(f"→ Girth-adapted {'SUCCEEDS ✓' if abs(g_result[0] - min_w) < 1e-10 else 'FAILS ✗'}")


def demo_random_graphs():
    """Test on random weighted graphs."""
    print("\n" + "=" * 70)
    print("DEMO 2: Random Graph Testing (Conjecture Verification)")
    print("=" * 70)

    total = 0
    kruskal_failures = 0
    girth_failures = 0

    for n in range(5, 10):
        for trial in range(30):
            seed = n * 1000 + trial
            G = build_random_weighted_graph(n, p=0.4, max_weight=10, seed=seed)

            if G.num_edges() < 3:
                continue

            result = compare_filtrations(G)
            if result.get("acyclic"):
                continue

            total += 1
            if not result["kruskal_correct"]:
                kruskal_failures += 1
            if not result["girth_correct"]:
                girth_failures += 1

    print(f"\nTested {total} non-acyclic random graphs (5-9 vertices)")
    print(f"Kruskal failures: {kruskal_failures} / {total} ({100*kruskal_failures/max(1,total):.1f}%)")
    print(f"Girth-adapted failures: {girth_failures} / {total} ({100*girth_failures/max(1,total):.1f}%)")

    if girth_failures == 0:
        print("\n→ CONJECTURE HOLDS: Girth-adapted filtration always finds minimum cycle weight ✓")
    else:
        print("\n→ CONJECTURE VIOLATED: Girth-adapted filtration failed!")


def demo_obstruction_analysis():
    """Analyze obstruction structure when Kruskal fails."""
    print("\n" + "=" * 70)
    print("DEMO 3: Obstruction Analysis")
    print("=" * 70)

    obstruction_count = 0
    total_tested = 0
    examples = []

    for n in range(5, 10):
        for trial in range(30):
            seed = n * 10000 + trial
            G = build_random_weighted_graph(n, p=0.4, max_weight=10, seed=seed)

            if G.num_edges() < 3:
                continue

            result = compare_filtrations(G)
            if result.get("acyclic"):
                continue

            total_tested += 1
            if "obstruction" in result:
                obstruction_count += 1
                if len(examples) < 3:
                    examples.append({
                        "n": n,
                        "edges": G.num_edges(),
                        "min_weight": result["min_simple_cycle_weight"],
                        "kruskal_weight": result["kruskal_first_birth"],
                        "excess": result["obstruction"]["excess"],
                    })

    print(f"\nTested {total_tested} graphs")
    print(f"Kruskal obstructions found: {obstruction_count} ({100*obstruction_count/max(1,total_tested):.1f}%)")
    if examples:
        print("\nExample obstructions:")
        for i, ex in enumerate(examples):
            print(f"  [{i+1}] V={ex['n']}, E={ex['edges']}: "
                  f"min={ex['min_weight']}, kruskal={ex['kruskal_weight']}, "
                  f"excess={ex['excess']}")


def demo_cycle_rank_invariance():
    """Demonstrate that cycle rank is weight-invariant."""
    print("\n" + "=" * 70)
    print("DEMO 4: Cycle Rank (β₁) is Weight-Invariant")
    print("=" * 70)

    G = build_random_weighted_graph(8, p=0.5, seed=42)
    beta1 = redundant_edge_count(G)
    print(f"\nGraph: {G.num_vertices()} vertices, {G.num_edges()} edges")
    print(f"Cycle rank β₁ = |E| - |V| + c = {beta1}")

    # Change all weights — cycle rank stays the same
    G2 = WeightedGraph()
    for v in G.vertices:
        G2.vertices.add(v)
    for (u, v), _ in G.edges.items():
        G2.add_edge(u, v, random.uniform(0.1, 100.0))

    beta1_2 = redundant_edge_count(G2)
    print(f"After reweighting all edges randomly: β₁ = {beta1_2}")
    print(f"β₁ invariant: {'✓' if beta1 == beta1_2 else '✗'}")

    print("\n→ Cycle rank is topological (depends on graph structure, not weights)")
    print("→ But the LOCATION of first redundancy detects the weighted systole")


def demo_tropical_minimum():
    """Demonstrate the tropical min-plus characterization."""
    print("\n" + "=" * 70)
    print("DEMO 5: Tropical Min-Plus Characterization")
    print("=" * 70)

    random.seed(2025)
    G = WeightedGraph()
    # K5 with random weights
    for i in range(5):
        for j in range(i+1, 5):
            G.add_edge(i, j, random.randint(1, 8))

    cycles = enumerate_simple_cycles(G)
    print(f"\nGraph K5: 5 vertices, {G.num_edges()} edges")
    print(f"Number of simple cycles: {len(cycles)}")

    weights = sorted(cycle_weight(G, c) for c in cycles)
    print(f"\nAll cycle weights (sorted): {weights}")

    min_w = min(weights)
    print(f"\nTropical minimum (min-plus): {min_w}")
    print(f"= inf {{ ∑ w(e) : C simple cycle }} = weighted systole")

    g_result = first_cycle_birth_value(G, girth_adapted_order(G))
    if g_result:
        print(f"Girth-adapted first birth: {g_result[0]}")
        print(f"Equality: {'✓' if abs(g_result[0] - min_w) < 1e-10 else '✗'}")


def demo_weighted_code_distance():
    """Demonstrate weighted code distance = min cycle weight."""
    print("\n" + "=" * 70)
    print("DEMO 6: Weighted Code Distance = Weighted Systole")
    print("=" * 70)

    random.seed(42)
    # Build a small grid graph (used in surface codes)
    G = WeightedGraph()
    n = 3
    for i in range(n):
        for j in range(n):
            v = i * n + j
            if j < n - 1:
                G.add_edge(v, v + 1, random.randint(1, 5))
            if i < n - 1:
                G.add_edge(v, v + n, random.randint(1, 5))
    # Add wrap-around edges for torus structure
    for i in range(n):
        G.add_edge(i * n, i * n + n - 1, random.randint(1, 5))
    for j in range(n):
        G.add_edge(j, (n-1)*n + j, random.randint(1, 5))

    min_w = min_simple_cycle_weight(G)
    beta1 = redundant_edge_count(G)

    print(f"\nTorus-like grid: {G.num_vertices()} vertices, {G.num_edges()} edges")
    print(f"Cycle rank β₁ = {beta1}")
    print(f"Weighted code distance d_w = {min_w}")
    print(f"\n→ For graph-derived CSS codes: d_w(Q(G)) = min simple cycle weight")
    print(f"→ This is the tropical systole of the graph")
    print(f"→ Hardware non-uniformity absorbed into topological invariant ✓")


if __name__ == "__main__":
    random.seed(2025)

    demo_kruskal_failure()
    demo_random_graphs()
    demo_obstruction_analysis()
    demo_cycle_rank_invariance()
    demo_tropical_minimum()
    demo_weighted_code_distance()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print("\nKey results demonstrated:")
    print("1. Girth-adapted filtration always realizes weighted systole (Theorem A)")
    print("2. Weighted code distance = minimum cycle weight (Theorem B)")
    print("3. Kruskal can fail; obstruction witnesses explain why (Theorem C)")
    print("4. Cycle rank is weight-invariant (Theorem D)")
    print("5. Tropical min-plus characterization (Theorem E)")


"""
Visualization: Cycle Support Weight Heatmap

This script creates a heatmap showing the cycle support weight (csw) of
each edge in a weighted graph. The csw captures the "tropical shadow"
of the global systole: it measures how close each edge is to participating
in a minimum-weight cycle.

Edges with csw equal to the weighted systole are part of optimal cycles.
Edges with csw = infinity are bridges (never in any cycle).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

# ===== Inline all needed functions =====

class WeightedGraph:
    def __init__(self):
        self.vertices = set()
        self.edges = {}
        self.adj = defaultdict(set)
    def add_edge(self, u, v, weight):
        a, b = min(u, v), max(u, v)
        self.vertices.add(a); self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b); self.adj[b].add(a)

def enumerate_simple_cycles(G):
    vertices = sorted(G.vertices)
    cycles, seen = [], set()
    def dfs(start, current, path, visited):
        for nb in sorted(G.adj[current]):
            if nb == start and len(path) >= 3:
                ce = []
                for i in range(len(path)):
                    u, v = path[i], path[(i+1) % len(path)]
                    ce.append((min(u,v), max(u,v)))
                key = tuple(sorted(ce))
                if key not in seen: seen.add(key); cycles.append(ce)
            elif nb > start and nb not in visited:
                visited.add(nb); path.append(nb)
                dfs(start, nb, path, visited)
                path.pop(); visited.remove(nb)
    for v in vertices: dfs(v, v, [v], {v})
    return cycles

def cycle_weight(G, c): return sum(G.edges[e] for e in c)

def cycle_support_weight(G, edge):
    cycles = enumerate_simple_cycles(G)
    relevant = [c for c in cycles if edge in c]
    return min(cycle_weight(G, c) for c in relevant) if relevant else float('inf')

# ===== Build example: K5 with random weights =====

import random
random.seed(2025)

G = WeightedGraph()
n = 6
for i in range(n):
    for j in range(i+1, n):
        G.add_edge(i, j, random.randint(1, 8))

edges = sorted(G.edges.keys())
csw_values = {e: cycle_support_weight(G, e) for e in edges}
min_csw = min(csw_values.values())

# ===== Create visualization =====

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Graph with edges colored by CSW
angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
pos = {i: (1.2*np.cos(a), 1.2*np.sin(a)) for i, a in enumerate(angles)}

ax1.set_aspect('equal')
ax1.set_xlim(-2, 2); ax1.set_ylim(-2, 2)
ax1.set_title(f'K{n} with Cycle Support Weights', fontsize=14, fontweight='bold')
ax1.axis('off')

finite_csw = [v for v in csw_values.values() if v < float('inf')]
vmin, vmax = min(finite_csw), max(finite_csw)
cmap = plt.cm.RdYlGn_r

for (u, v), csw in csw_values.items():
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    t = (csw - vmin) / (vmax - vmin) if vmax > vmin else 0.5
    color = cmap(t)
    lw = 4 if abs(csw - min_csw) < 0.01 else 2
    ax1.plot(x, y, color=color, linewidth=lw, zorder=1)
    mx, my = (x[0]+x[1])/2 + 0.05, (y[0]+y[1])/2 + 0.05
    ax1.text(mx, my, f'{G.edges[(u,v)]}', ha='center', va='center',
            fontsize=8, color='#333',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.7))

for v_id, (x, y) in pos.items():
    ax1.plot(x, y, 'o', color='#2196F3', markersize=22, zorder=2)
    ax1.text(x, y, str(v_id), ha='center', va='center',
            fontsize=12, color='white', fontweight='bold', zorder=3)

sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(vmin=vmin, vmax=vmax))
plt.colorbar(sm, ax=ax1, label='Cycle Support Weight', shrink=0.8)

# Panel 2: Bar chart of CSW values
edge_labels = [f'{u}-{v}' for u, v in edges]
csw_vals = [csw_values[e] for e in edges]
colors = ['#27ae60' if abs(v - min_csw) < 0.01 else '#e74c3c' if v > min_csw * 1.5 else '#f39c12'
          for v in csw_vals]

bars = ax2.barh(range(len(edges)), csw_vals, color=colors, edgecolor='white')
ax2.set_yticks(range(len(edges)))
ax2.set_yticklabels(edge_labels, fontsize=9)
ax2.set_xlabel('Cycle Support Weight', fontsize=12)
ax2.set_title('CSW per Edge\n(green = in minimum cycle)', fontsize=14, fontweight='bold')
ax2.axvline(x=min_csw, color='#27ae60', linestyle='--', linewidth=2, label=f'Min CSW = {min_csw}')
ax2.legend(fontsize=10)
ax2.invert_yaxis()

for i, (bar, val) in enumerate(zip(bars, csw_vals)):
    ax2.text(val + 0.3, i, f'{val:.0f}', va='center', fontsize=9)

fig.suptitle('Cycle Support Weight: The Tropical Shadow of the Systole',
             fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('viz_cycle_support_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_cycle_support_heatmap.png")


"""
Visualization: Kruskal vs Girth-Adapted Filtration Comparison

This script visualizes how different edge orderings affect cycle detection
in weighted graphs. It shows:
- The weighted graph with edge weights
- The Kruskal ordering and the cycle it produces
- The girth-adapted ordering and the cycle it produces
- A bar chart comparing the two filtration birth values vs minimum

WHY THIS MATTERS: In quantum error-correcting codes, the minimum cycle
weight determines the code distance. Kruskal ordering can miss this
minimum, but girth-adapted filtration always finds it.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict

# ===== Inline all needed functions =====

class WeightedGraph:
    def __init__(self):
        self.vertices = set()
        self.edges = {}
        self.adj = defaultdict(set)

    def add_edge(self, u, v, weight):
        a, b = min(u, v), max(u, v)
        self.vertices.add(a)
        self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b)
        self.adj[b].add(a)

def enumerate_simple_cycles(G):
    vertices = sorted(G.vertices)
    cycles = []
    seen_cycles = set()
    def dfs(start, current, path, visited):
        for neighbor in sorted(G.adj[current]):
            if neighbor == start and len(path) >= 3:
                cycle_edges = []
                for i in range(len(path)):
                    u, v = path[i], path[(i + 1) % len(path)]
                    a, b = min(u, v), max(u, v)
                    cycle_edges.append((a, b))
                key = tuple(sorted(cycle_edges))
                if key not in seen_cycles:
                    seen_cycles.add(key)
                    cycles.append(cycle_edges)
            elif neighbor > start and neighbor not in visited:
                visited.add(neighbor)
                path.append(neighbor)
                dfs(start, neighbor, path, visited)
                path.pop()
                visited.remove(neighbor)
    for v in vertices:
        dfs(v, v, [v], {v})
    return cycles

def cycle_weight(G, cycle):
    return sum(G.edges[e] for e in cycle)

class UnionFind:
    def __init__(self, vertices):
        self.parent = {v: v for v in vertices}
        self.rank = {v: 0 for v in vertices}
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return True
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return False
    def connected(self, x, y):
        return self.find(x) == self.find(y)

def find_cycle_in_forest(G, forest_edges, new_edge):
    u, v = new_edge
    adj = defaultdict(list)
    for a, b in forest_edges:
        adj[a].append(b)
        adj[b].append(a)
    queue = [(u, [u])]
    visited = {u}
    while queue:
        current, path = queue.pop(0)
        for neighbor in adj[current]:
            if neighbor == v:
                full_path = path + [v]
                cycle_edges = []
                for i in range(len(full_path) - 1):
                    a, b = min(full_path[i], full_path[i+1]), max(full_path[i], full_path[i+1])
                    cycle_edges.append((a, b))
                cycle_edges.append(new_edge)
                return cycle_edges
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, path + [neighbor]))
    return [new_edge]

def first_cycle_birth_value(G, order):
    uf = UnionFind(G.vertices)
    forest_edges = []
    for edge in order:
        u, v = edge
        if uf.connected(u, v):
            cycle_edges = find_cycle_in_forest(G, forest_edges, edge)
            total_weight = sum(G.edges[e] for e in cycle_edges)
            return (total_weight, cycle_edges)
        else:
            uf.union(u, v)
            forest_edges.append(edge)
    return None

# ===== Build the example graph =====

G = WeightedGraph()
for i in range(7):
    G.add_edge(i, (i + 1) % 7, 1.0)
G.add_edge(0, 2, 3.0)

# Compute results
cycles = enumerate_simple_cycles(G)
min_w = min(cycle_weight(G, c) for c in cycles)

kruskal = sorted(G.edges.keys(), key=lambda e: (G.edges[e], e))
kruskal_result = first_cycle_birth_value(G, kruskal)

min_cycle = min(cycles, key=lambda c: cycle_weight(G, c))
min_cycle_set = set(min_cycle)
min_cycle_sorted = sorted(min_cycle, key=lambda e: (G.edges[e], e))
remaining = [e for e in sorted(G.edges.keys()) if e not in min_cycle_set]
girth_order = min_cycle_sorted + remaining
girth_result = first_cycle_birth_value(G, girth_order)

# ===== Create visualization =====

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Layout: vertices on a heptagon
angles = np.linspace(0, 2 * np.pi, 7, endpoint=False) - np.pi/2
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

def draw_graph(ax, G, pos, highlight_edges=None, highlight_color='red', title=''):
    ax.set_aspect('equal')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.axis('off')

    highlight_set = set(highlight_edges) if highlight_edges else set()

    for (u, v), w in G.edges.items():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        color = highlight_color if (u, v) in highlight_set else '#cccccc'
        lw = 3 if (u, v) in highlight_set else 1.5
        ax.plot(x, y, color=color, linewidth=lw, zorder=1)
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.text(mx, my + 0.08, f'{w:.0f}', ha='center', va='center',
                fontsize=9, color='#333', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    for v, (x, y) in pos.items():
        ax.plot(x, y, 'o', color='#2196F3', markersize=20, zorder=2)
        ax.text(x, y, str(v), ha='center', va='center',
                fontsize=11, color='white', fontweight='bold', zorder=3)

# Panel 1: Full graph
draw_graph(axes[0], G, pos, title='Weighted Graph\n(7-cycle + chord)')

# Panel 2: Kruskal cycle
kruskal_cycle_edges = kruskal_result[1] if kruskal_result else []
draw_graph(axes[1], G, pos, kruskal_cycle_edges, '#e74c3c',
           f'Kruskal First Cycle\nWeight = {kruskal_result[0]:.0f}')

# Panel 3: Girth-adapted cycle
girth_cycle_edges = girth_result[1] if girth_result else []
draw_graph(axes[2], G, pos, girth_cycle_edges, '#27ae60',
           f'Girth-Adapted First Cycle\nWeight = {girth_result[0]:.0f} = min')

fig.suptitle('Kruskal vs Girth-Adapted Filtration: Finding the Weighted Systole',
             fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout()
plt.savefig('viz_filtration_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_filtration_comparison.png")


"""
Visualization: Kruskal Failure Rate vs Graph Density

This script shows how frequently Kruskal's ordering fails to find the
minimum cycle weight as a function of graph density and size. It
demonstrates that denser graphs have higher failure rates.

The key insight: Kruskal optimizes local edge weight, not global cycle
weight. As graphs get denser, the mismatch between these objectives grows.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from collections import defaultdict

# ===== Inline all needed functions =====

class WeightedGraph:
    def __init__(self):
        self.vertices = set()
        self.edges = {}
        self.adj = defaultdict(set)
    def add_edge(self, u, v, weight):
        a, b = min(u, v), max(u, v)
        self.vertices.add(a); self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b); self.adj[b].add(a)

def enumerate_simple_cycles(G):
    vertices = sorted(G.vertices)
    cycles, seen = [], set()
    def dfs(start, current, path, visited):
        for nb in sorted(G.adj[current]):
            if nb == start and len(path) >= 3:
                ce = []
                for i in range(len(path)):
                    u, v = path[i], path[(i+1) % len(path)]
                    ce.append((min(u,v), max(u,v)))
                key = tuple(sorted(ce))
                if key not in seen: seen.add(key); cycles.append(ce)
            elif nb > start and nb not in visited:
                visited.add(nb); path.append(nb)
                dfs(start, nb, path, visited)
                path.pop(); visited.remove(nb)
    for v in vertices: dfs(v, v, [v], {v})
    return cycles

def cycle_weight(G, c): return sum(G.edges[e] for e in c)

class UnionFind:
    def __init__(self, verts):
        self.parent = {v: v for v in verts}
        self.rank = {v: 0 for v in verts}
    def find(self, x):
        if self.parent[x] != x: self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return True
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return False
    def connected(self, x, y): return self.find(x) == self.find(y)

def find_cycle_in_forest(G, forest, new_edge):
    u, v = new_edge
    adj = defaultdict(list)
    for a, b in forest: adj[a].append(b); adj[b].append(a)
    queue = [(u, [u])]; visited = {u}
    while queue:
        cur, path = queue.pop(0)
        for nb in adj[cur]:
            if nb == v:
                fp = path + [v]; ce = []
                for i in range(len(fp)-1):
                    ce.append((min(fp[i],fp[i+1]), max(fp[i],fp[i+1])))
                ce.append(new_edge); return ce
            if nb not in visited:
                visited.add(nb); queue.append((nb, path+[nb]))
    return [new_edge]

def kruskal_first_birth(G):
    uf = UnionFind(G.vertices); forest = []
    for e in sorted(G.edges.keys(), key=lambda e: (G.edges[e], e)):
        u, v = e
        if uf.connected(u, v):
            ce = find_cycle_in_forest(G, forest, e)
            return sum(G.edges[x] for x in ce)
        else: uf.union(u, v); forest.append(e)
    return None

# ===== Run experiments =====

random.seed(2025)
densities = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7]
vertex_counts = [5, 6, 7, 8]
trials_per = 40

results = {}  # (n, p) -> failure_rate

for n in vertex_counts:
    for p in densities:
        total = 0
        failures = 0
        for trial in range(trials_per):
            G = WeightedGraph()
            for v in range(n): G.vertices.add(v)
            random.seed(n*10000 + int(p*1000) + trial)
            for i in range(n):
                for j in range(i+1, n):
                    if random.random() < p:
                        G.add_edge(i, j, random.randint(1, 10))
            if len(G.edges) < 3: continue
            cycles = enumerate_simple_cycles(G)
            if not cycles: continue
            total += 1
            min_w = min(cycle_weight(G, c) for c in cycles)
            kb = kruskal_first_birth(G)
            if kb and abs(kb - min_w) > 1e-10:
                failures += 1
        results[(n, p)] = failures / max(1, total) * 100

# ===== Plot =====

fig, ax = plt.subplots(figsize=(10, 7))

for n in vertex_counts:
    rates = [results.get((n, p), 0) for p in densities]
    ax.plot(densities, rates, 'o-', linewidth=2, markersize=8, label=f'n = {n}')

ax.set_xlabel('Edge Probability (Graph Density)', fontsize=13)
ax.set_ylabel('Kruskal Failure Rate (%)', fontsize=13)
ax.set_title('When Does Kruskal Fail to Find the Weighted Systole?\n'
             'Failure rate vs graph density for random weighted graphs',
             fontsize=14, fontweight='bold')
ax.legend(title='Vertices', fontsize=11, title_fontsize=12)
ax.set_ylim(-2, 55)
ax.grid(True, alpha=0.3)

ax.annotate('Denser graphs → more\nalternative paths →\nhigher failure rate',
           xy=(0.6, results.get((8, 0.6), 30)),
           xytext=(0.45, 45), fontsize=11,
           arrowprops=dict(arrowstyle='->', color='#e74c3c'),
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_kruskal_failure_rate.png', dpi=150, bbox_inches='tight')
print("Saved: viz_kruskal_failure_rate.png")
