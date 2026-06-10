#!/usr/bin/env python3
"""
Applications of the Tropical Sherman-Morrison APSP update theorem.

1. Dynamic routing: incremental network updates
2. Scheduling: adding resource channels in min-plus linear systems
3. Impact analysis: measuring the effect of adding infrastructure
"""

import numpy as np
from algorithms import floyd_warshall, single_edge_update, batch_edge_update

INF = float('inf')


def application_routing():
    """
    APPLICATION 1: Dynamic Network Routing
    
    A communication network with 8 nodes. When a new link is added,
    we update all routing tables in O(n²) instead of O(n³).
    """
    print("=" * 60)
    print("APPLICATION 1: Dynamic Network Routing")
    print("=" * 60)
    
    n = 8
    # City network: bidirectional links with latencies (ms)
    cities = ["NYC", "CHI", "LAX", "HOU", "PHX", "PHI", "SAN", "DAL"]
    
    A = np.full((n, n), INF)
    links = [
        (0, 1, 12), (1, 0, 12),  # NYC-CHI
        (0, 5, 2),  (5, 0, 2),   # NYC-PHI
        (1, 3, 15), (3, 1, 15),  # CHI-HOU
        (2, 4, 6),  (4, 2, 6),   # LAX-PHX
        (2, 6, 3),  (6, 2, 3),   # LAX-SAN
        (3, 7, 4),  (7, 3, 4),   # HOU-DAL
        (4, 7, 10), (7, 4, 10),  # PHX-DAL
        (5, 1, 14), (1, 5, 14),  # PHI-CHI
    ]
    for u, v, w in links:
        A[u, v] = w
    
    S = floyd_warshall(A)
    
    print("\nCurrent shortest latencies (ms):")
    print("     " + "  ".join(f"{c:>5}" for c in cities))
    for i, city in enumerate(cities):
        row = "  ".join(f"{S[i,j]:5.0f}" if S[i,j] < INF else "    ∞" for j in range(n))
        print(f"  {city}: {row}")
    
    # New fiber link: LAX-NYC with 8ms latency
    u, v, w = 2, 0, 8
    print(f"\n→ New link: {cities[u]}→{cities[v]} with {w}ms latency")
    
    S_new = single_edge_update(S, u, v, w)
    # Also add reverse
    S_new = single_edge_update(S_new, v, u, w)
    
    print("\nUpdated latencies:")
    print("     " + "  ".join(f"{c:>5}" for c in cities))
    for i, city in enumerate(cities):
        row_parts = []
        for j in range(n):
            old = S[i, j]
            new = S_new[i, j]
            if new < old - 0.01:
                row_parts.append(f"{new:5.0f}*")
            elif new < INF:
                row_parts.append(f"{new:5.0f} ")
            else:
                row_parts.append("    ∞ ")
        print(f"  {city}: {''.join(row_parts)}")
    
    improved = np.sum(S_new < S - 0.01)
    print(f"\n  * = improved route ({improved} routes improved)")
    print(f"  Update cost: O(n²) = {n**2} operations (vs O(n³) = {n**3} for recomputation)")


def application_scheduling():
    """
    APPLICATION 2: Job-Shop Scheduling with New Machine
    
    In min-plus algebra, matrix multiplication models sequential task composition.
    Adding a new processing route is an edge insertion.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Job-Shop Scheduling")
    print("=" * 60)
    
    # 5 processing stages
    stages = ["Raw", "Cut", "Weld", "Paint", "Ship"]
    n = 5
    
    # Processing times between stages (hours)
    A = np.full((n, n), INF)
    A[0, 1] = 2   # Raw→Cut
    A[1, 2] = 3   # Cut→Weld
    A[2, 3] = 4   # Weld→Paint
    A[3, 4] = 1   # Paint→Ship
    A[0, 2] = 8   # Raw→Weld (direct, slower)
    A[1, 3] = 6   # Cut→Paint (direct)
    
    S = floyd_warshall(A)
    
    print("\nMinimum processing times (hours) between stages:")
    print("       " + "  ".join(f"{s:>6}" for s in stages))
    for i, stage in enumerate(stages):
        row = "  ".join(f"{S[i,j]:6.0f}" if S[i,j] < INF else "     ∞" for j in range(n))
        print(f"  {stage}: {row}")
    
    # New express route: Raw→Paint with 5 hours
    u, v, w = 0, 3, 5
    print(f"\n→ New express route: {stages[u]}→{stages[v]} in {w} hours")
    
    S_new = single_edge_update(S, u, v, w)
    
    total_before = S[0, 4]
    total_after = S_new[0, 4]
    print(f"\n  Total time {stages[0]}→{stages[4]}: {total_before:.0f}h → {total_after:.0f}h")
    print(f"  Time saved: {total_before - total_after:.0f} hours")
    
    # Show which routes improved
    print("\n  Improved routes:")
    for i in range(n):
        for j in range(n):
            if S_new[i, j] < S[i, j] - 0.01:
                print(f"    {stages[i]}→{stages[j]}: {S[i,j]:.0f}h → {S_new[i,j]:.0f}h")


def application_impact():
    """
    APPLICATION 3: Infrastructure Impact Analysis
    
    Analyze how adding a new road affects travel times in a city,
    using parametric sensitivity from the theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Infrastructure Impact Analysis")
    print("=" * 60)
    
    # 7 districts connected by roads
    districts = ["Downtown", "Airport", "University", "Hospital", 
                 "Suburb-N", "Suburb-S", "Industrial"]
    n = 7
    
    A = np.full((n, n), INF)
    roads = [
        (0, 1, 25), (1, 0, 25),  # Downtown-Airport
        (0, 2, 10), (2, 0, 10),  # Downtown-University
        (0, 3, 15), (3, 0, 15),  # Downtown-Hospital
        (2, 4, 8),  (4, 2, 8),   # University-Suburb-N
        (3, 5, 12), (5, 3, 12),  # Hospital-Suburb-S
        (1, 6, 20), (6, 1, 20),  # Airport-Industrial
        (5, 6, 18), (6, 5, 18),  # Suburb-S-Industrial
        (4, 1, 30), (1, 4, 30),  # Suburb-N-Airport
    ]
    for u, v, w in roads:
        A[u, v] = w
    
    S = floyd_warshall(A)
    
    # Proposed new road: University (2) → Industrial (6)
    u, v = 2, 6
    print(f"\nProposed new road: {districts[u]} → {districts[v]}")
    print("\nImpact analysis at different investment levels (road speeds):")
    
    for w in [5, 10, 15, 20, 30]:
        S_new = single_edge_update(S, u, v, w)
        S_new = single_edge_update(S_new, v, u, w)  # bidirectional
        
        # Compute total improvement
        total_improvement = 0
        count_improved = 0
        for i in range(n):
            for j in range(i+1, n):
                diff = S[i, j] - S_new[i, j]
                if diff > 0.01:
                    total_improvement += diff
                    count_improved += 1
        
        print(f"\n  Travel time = {w} min:")
        print(f"    Routes improved: {count_improved}/{n*(n-1)//2}")
        print(f"    Total time saved: {total_improvement:.0f} minutes across all pairs")
        
        # Key route: Airport to Suburb-N
        key_before = S[1, 4]
        key_after = S_new[1, 4]
        print(f"    {districts[1]}→{districts[4]}: {key_before:.0f} → {key_after:.0f} min")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Tropical Sherman-Morrison Theorem      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    application_routing()
    application_scheduling()
    application_impact()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Tropical Sherman-Morrison theorem for APSP edge update.

Demonstrates with concrete numerical examples that when a single edge is added
to a weighted directed graph, the all-pairs shortest path matrix updates via:

    S'(i,j) = min( S(i,j),  S(i,u) + w + S(v,j) )

This is verified against full Floyd-Warshall recomputation.
"""

import numpy as np
from typing import Tuple

INF = float('inf')


def floyd_warshall(A: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths via Floyd-Warshall.
    
    Args:
        A: n×n adjacency matrix with INF for missing edges.
    Returns:
        n×n shortest-path distance matrix.
    """
    n = A.shape[0]
    S = A.copy()
    # Set diagonal to 0 (zero-cost self-loop)
    for i in range(n):
        S[i, i] = 0.0
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if S[i, k] + S[k, j] < S[i, j]:
                    S[i, j] = S[i, k] + S[k, j]
    return S


def edge_update_formula(S: np.ndarray, u: int, v: int, w: float) -> np.ndarray:
    """Apply the tropical Sherman-Morrison formula.
    
    S'(i,j) = min( S(i,j),  S(i,u) + w + S(v,j) )
    
    Args:
        S: Current APSP closure matrix.
        u, v: Edge endpoints.
        w: Edge weight.
    Returns:
        Updated APSP closure matrix.
    """
    n = S.shape[0]
    S_new = np.empty_like(S)
    for i in range(n):
        for j in range(n):
            S_new[i, j] = min(S[i, j], S[i, u] + w + S[v, j])
    return S_new


def add_edge(A: np.ndarray, u: int, v: int, w: float) -> np.ndarray:
    """Add edge u→v with weight w to adjacency matrix."""
    A_new = A.copy()
    A_new[u, v] = min(A_new[u, v], w)
    return A_new


def demo_basic():
    """Basic 4-vertex example."""
    print("=" * 60)
    print("DEMO 1: Basic 4-vertex graph")
    print("=" * 60)
    
    # Graph: 0→1→2→3 with unit weights
    n = 4
    A = np.full((n, n), INF)
    A[0, 1] = 1.0
    A[1, 2] = 1.0
    A[2, 3] = 1.0
    
    print("\nOriginal adjacency matrix A:")
    print_matrix(A)
    
    S = floyd_warshall(A)
    print("\nAPSP closure S = FW(A):")
    print_matrix(S)
    
    # Add edge 0→3 with weight 1 (shortcut!)
    u, v, w = 0, 3, 1.0
    print(f"\nAdding edge {u}→{v} with weight {w}")
    
    # Method 1: Full recomputation
    A_new = add_edge(A, u, v, w)
    S_recomputed = floyd_warshall(A_new)
    print("\nFull recomputation S' = FW(A'):")
    print_matrix(S_recomputed)
    
    # Method 2: Sherman-Morrison formula
    S_formula = edge_update_formula(S, u, v, w)
    print("\nSherman-Morrison formula S'(i,j) = min(S(i,j), S(i,u)+w+S(v,j)):")
    print_matrix(S_formula)
    
    # Verify equality
    assert np.allclose(S_recomputed, S_formula, equal_nan=True), "MISMATCH!"
    print("\n✓ Results match perfectly!")


def demo_cycle():
    """Example creating a cycle."""
    print("\n" + "=" * 60)
    print("DEMO 2: Creating a cycle")
    print("=" * 60)
    
    n = 3
    A = np.full((n, n), INF)
    A[0, 1] = 2.0
    A[1, 2] = 3.0
    
    print("\nOriginal: 0 →(2)→ 1 →(3)→ 2")
    S = floyd_warshall(A)
    print("\nAPSP closure:")
    print_matrix(S)
    
    # Close the cycle: 2→0 with weight 4
    u, v, w = 2, 0, 4.0
    print(f"\nAdding edge {u}→{v} with weight {w} (creates cycle)")
    
    S_recomputed = floyd_warshall(add_edge(A, u, v, w))
    S_formula = edge_update_formula(S, u, v, w)
    
    print("\nRecomputed:")
    print_matrix(S_recomputed)
    print("\nFormula:")
    print_matrix(S_formula)
    
    assert np.allclose(S_recomputed, S_formula), "MISMATCH!"
    print("\n✓ Results match! Cycle distances computed correctly.")


def demo_large_random():
    """Random graph stress test."""
    print("\n" + "=" * 60)
    print("DEMO 3: Random graph stress test (n=20, 50 edge insertions)")
    print("=" * 60)
    
    np.random.seed(42)
    n = 20
    
    # Start with a sparse random graph
    A = np.full((n, n), INF)
    for _ in range(40):
        i, j = np.random.randint(0, n, size=2)
        if i != j:
            A[i, j] = np.random.uniform(0.1, 10.0)
    
    S = floyd_warshall(A)
    
    # Apply 50 random edge insertions
    all_match = True
    for trial in range(50):
        u = np.random.randint(0, n)
        v = np.random.randint(0, n)
        while v == u:
            v = np.random.randint(0, n)
        w = np.random.uniform(0.1, 10.0)
        
        # Update adjacency
        A = add_edge(A, u, v, w)
        
        # Formula update
        S_formula = edge_update_formula(S, u, v, w)
        
        # Full recomputation for verification
        S_recomputed = floyd_warshall(A)
        
        if not np.allclose(S_formula, S_recomputed, atol=1e-10):
            print(f"  ✗ Mismatch at trial {trial}!")
            all_match = False
            break
        
        S = S_formula  # Use formula result for next iteration
    
    if all_match:
        print(f"\n✓ All 50 edge insertions verified correctly!")
        print(f"  Formula updates: O(n²) = O({n**2}) per update")
        print(f"  Full recomputation: O(n³) = O({n**3}) per update")
        print(f"  Speedup factor: {n}x")


def demo_monotonicity():
    """Demonstrate that edge insertion only decreases distances."""
    print("\n" + "=" * 60)
    print("DEMO 4: Monotonicity — edge insertion never increases distances")
    print("=" * 60)
    
    np.random.seed(123)
    n = 8
    A = np.full((n, n), INF)
    for _ in range(15):
        i, j = np.random.randint(0, n, size=2)
        if i != j:
            A[i, j] = np.random.uniform(1.0, 10.0)
    
    S = floyd_warshall(A)
    
    u, v, w = 3, 7, 2.5
    S_new = edge_update_formula(S, u, v, w)
    
    print(f"\nAdding edge {u}→{v} with weight {w}")
    print(f"\nEntries that decreased:")
    count = 0
    for i in range(n):
        for j in range(n):
            if S_new[i, j] < S[i, j]:
                print(f"  S({i},{j}): {S[i,j]:.2f} → {S_new[i,j]:.2f}  "
                      f"(via {i}→*→{u}→{v}→*→{j}: "
                      f"{S[i,u]:.2f}+{w}+{S[v,j]:.2f}={S[i,u]+w+S[v,j]:.2f})")
                count += 1
    
    # Verify monotonicity
    assert np.all(S_new <= S + 1e-10), "Monotonicity violated!"
    print(f"\n✓ {count} entries decreased, none increased. Monotonicity verified!")


def demo_idempotence():
    """Demonstrate that double application is idempotent."""
    print("\n" + "=" * 60)
    print("DEMO 5: Idempotence — applying same edge twice = once")
    print("=" * 60)
    
    n = 5
    A = np.full((n, n), INF)
    A[0, 1] = 3; A[1, 2] = 4; A[2, 3] = 2; A[3, 4] = 1
    A[0, 4] = 20
    
    S = floyd_warshall(A)
    u, v, w = 1, 4, 2.0
    
    S1 = edge_update_formula(S, u, v, w)
    S2 = edge_update_formula(S1, u, v, w)
    
    print(f"\nS' (one application):")
    print_matrix(S1)
    print(f"\nS'' (two applications):")
    print_matrix(S2)
    
    assert np.allclose(S1, S2), "Idempotence violated!"
    print("\n✓ S' = S'' — idempotence verified!")


def print_matrix(M: np.ndarray):
    """Pretty-print a distance matrix."""
    n = M.shape[0]
    for i in range(n):
        row = []
        for j in range(n):
            if M[i, j] == INF:
                row.append("  ∞  ")
            else:
                row.append(f"{M[i,j]:5.1f}")
        print("  " + " ".join(row))


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Sherman-Morrison Theorem: APSP Edge Update    ║")
    print("║  S'(i,j) = min( S(i,j),  S(i,u) + w + S(v,j) )       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_basic()
    demo_cycle()
    demo_large_random()
    demo_monotonicity()
    demo_idempotence()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Tropical Sherman-Morrison APSP update theorem.

Generates figures showing:
1. Before/after distance matrices as heatmaps
2. Sensitivity of APSP entries to edge weight parameter
3. Graph visualization with shortest paths highlighted
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import floyd_warshall, single_edge_update

INF = float('inf')


def visualize_heatmaps():
    """Create before/after APSP heatmaps."""
    n = 6
    A = np.full((n, n), INF)
    edges = [(0,1,2), (1,2,3), (2,3,1), (3,4,4), (4,5,2),
             (0,3,15), (1,4,10), (5,0,8), (2,5,6)]
    for u, v, w in edges:
        A[u, v] = w
    
    S = floyd_warshall(A)
    
    # Add edge 0→5 with weight 3
    u, v, w = 0, 5, 3
    S_new = single_edge_update(S, u, v, w)
    
    # Create masked arrays for display
    S_disp = np.where(S >= 1e10, np.nan, S)
    S_new_disp = np.where(S_new >= 1e10, np.nan, S_new)
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    vmax = np.nanmax([np.nanmax(S_disp), np.nanmax(S_new_disp)])
    
    im1 = axes[0].imshow(S_disp, cmap='YlOrRd', vmin=0, vmax=vmax)
    axes[0].set_title('Before: APSP(A)', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Destination j')
    axes[0].set_ylabel('Source i')
    for i in range(n):
        for j in range(n):
            val = S_disp[i, j]
            if not np.isnan(val):
                axes[0].text(j, i, f'{val:.0f}', ha='center', va='center', fontsize=11)
            else:
                axes[0].text(j, i, '∞', ha='center', va='center', fontsize=11, color='gray')
    
    im2 = axes[1].imshow(S_new_disp, cmap='YlOrRd', vmin=0, vmax=vmax)
    axes[1].set_title(f'After: APSP(A ⊕ E({u},{v},{w}))', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Destination j')
    for i in range(n):
        for j in range(n):
            val = S_new_disp[i, j]
            if not np.isnan(val):
                color = 'blue' if S_new[i,j] < S[i,j] - 0.01 else 'black'
                weight = 'bold' if S_new[i,j] < S[i,j] - 0.01 else 'normal'
                axes[1].text(j, i, f'{val:.0f}', ha='center', va='center', 
                           fontsize=11, color=color, fontweight=weight)
            else:
                axes[1].text(j, i, '∞', ha='center', va='center', fontsize=11, color='gray')
    
    # Difference
    diff = S_disp - S_new_disp
    diff = np.where(np.isnan(diff), 0, diff)
    im3 = axes[2].imshow(diff, cmap='Greens', vmin=0)
    axes[2].set_title('Improvement: S − S\'', fontsize=14, fontweight='bold')
    axes[2].set_xlabel('Destination j')
    for i in range(n):
        for j in range(n):
            val = diff[i, j]
            axes[2].text(j, i, f'{val:.0f}', ha='center', va='center', fontsize=11)
    
    plt.colorbar(im3, ax=axes[2], label='Distance reduction')
    plt.tight_layout()
    plt.savefig('viz_heatmaps.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_heatmaps.png")


def visualize_sensitivity():
    """Show how APSP entries depend on the new edge weight."""
    n = 5
    A = np.full((n, n), INF)
    edges = [(0,1,3), (1,2,2), (2,3,4), (3,4,1), (0,4,20)]
    for u_, v_, w_ in edges:
        A[u_, v_] = w_
    
    S = floyd_warshall(A)
    
    u, v = 1, 4
    weights = np.linspace(0, 15, 100)
    
    # Track specific entries
    pairs = [(0, 4), (0, 3), (1, 4), (2, 4)]
    labels = [f'S\'({i},{j})' for i, j in pairs]
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for (i, j), label in zip(pairs, labels):
        values = []
        for w in weights:
            S_new = single_edge_update(S, u, v, w)
            values.append(S_new[i, j])
        
        original = S[i, j]
        values = np.array(values)
        values = np.where(values > 1e10, np.nan, values)
        
        ax.plot(weights, values, linewidth=2.5, label=label)
        ax.axhline(y=original, color='gray', linestyle=':', alpha=0.3)
    
    ax.set_xlabel('New edge weight w', fontsize=13)
    ax.set_ylabel('Shortest path distance', fontsize=13)
    ax.set_title(f'Sensitivity: APSP entries vs. edge weight\n'
                 f'Adding edge {u}→{v} with varying weight w', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    # Add annotation
    ax.annotate('Breakpoint: new edge\nbecomes useful', 
                xy=(6, 7), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('viz_sensitivity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_sensitivity.png")


def visualize_update_structure():
    """Visualize the rank-one structure of the update."""
    n = 6
    A = np.full((n, n), INF)
    edges = [(0,1,2), (1,2,3), (2,3,1), (3,4,4), (4,5,2),
             (5,0,8), (0,3,10), (2,5,6)]
    for u_, v_, w_ in edges:
        A[u_, v_] = w_
    
    S = floyd_warshall(A)
    u, v, w = 0, 5, 3
    
    col_u = S[:, u]  # S(·, u)
    row_v = S[v, :]  # S(v, ·)
    
    fig, axes = plt.subplots(1, 4, figsize=(18, 4.5))
    
    # Column S(·,u)
    col_disp = np.where(col_u >= 1e10, np.nan, col_u).reshape(-1, 1)
    axes[0].imshow(col_disp, cmap='Blues', aspect=0.3)
    axes[0].set_title(f'Column S(·,{u})', fontsize=13, fontweight='bold')
    axes[0].set_xticks([])
    for i in range(n):
        val = col_disp[i, 0]
        txt = f'{val:.0f}' if not np.isnan(val) else '∞'
        axes[0].text(0, i, txt, ha='center', va='center', fontsize=12)
    
    # Row S(v,·)
    row_disp = np.where(row_v >= 1e10, np.nan, row_v).reshape(1, -1)
    axes[1].imshow(row_disp, cmap='Oranges', aspect=3)
    axes[1].set_title(f'Row S({v},·)', fontsize=13, fontweight='bold')
    axes[1].set_yticks([])
    for j in range(n):
        val = row_disp[0, j]
        txt = f'{val:.0f}' if not np.isnan(val) else '∞'
        axes[1].text(j, 0, txt, ha='center', va='center', fontsize=12)
    
    # Outer product
    outer = col_u.reshape(-1, 1) + w + row_v.reshape(1, -1)
    outer_disp = np.where(outer >= 1e10, np.nan, outer)
    axes[2].imshow(outer_disp, cmap='Purples', vmin=0)
    axes[2].set_title(f'S(·,{u}) + {w} + S({v},·)', fontsize=13, fontweight='bold')
    for i in range(n):
        for j in range(n):
            val = outer_disp[i, j]
            txt = f'{val:.0f}' if not np.isnan(val) else '∞'
            axes[2].text(j, i, txt, ha='center', va='center', fontsize=10)
    
    # Result: min(S, outer)
    S_new = np.minimum(S, outer)
    result_disp = np.where(S_new >= 1e10, np.nan, S_new)
    axes[3].imshow(result_disp, cmap='YlOrRd', vmin=0)
    axes[3].set_title("S' = min(S, outer)", fontsize=13, fontweight='bold')
    for i in range(n):
        for j in range(n):
            val = result_disp[i, j]
            if not np.isnan(val):
                changed = S_new[i,j] < S[i,j] - 0.01
                color = 'blue' if changed else 'black'
                weight = 'bold' if changed else 'normal'
                axes[3].text(j, i, f'{val:.0f}', ha='center', va='center', 
                           fontsize=10, color=color, fontweight=weight)
            else:
                axes[3].text(j, i, '∞', ha='center', va='center', fontsize=10, color='gray')
    
    plt.suptitle('Tropical Sherman–Morrison: Rank-One Update Structure', 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_structure.png")


def visualize_batch_updates():
    """Show convergence of iterated single-edge updates vs recomputation."""
    np.random.seed(42)
    n = 15
    
    # Create random sparse graph
    A = np.full((n, n), INF)
    for _ in range(30):
        i, j = np.random.randint(0, n, size=2)
        if i != j:
            A[i, j] = np.random.uniform(1, 20)
    
    S = floyd_warshall(A)
    
    # Track a specific entry as we add edges
    track_i, track_j = 0, n-1
    num_updates = 30
    
    entry_values = [S[track_i, track_j] if S[track_i, track_j] < INF else np.nan]
    avg_distances = [np.mean(S[S < INF])]
    
    S_current = S.copy()
    A_current = A.copy()
    
    for _ in range(num_updates):
        u = np.random.randint(0, n)
        v = np.random.randint(0, n)
        while v == u:
            v = np.random.randint(0, n)
        w = np.random.uniform(0.5, 15)
        
        A_current[u, v] = min(A_current[u, v], w)
        S_current = single_edge_update(S_current, u, v, w)
        
        val = S_current[track_i, track_j]
        entry_values.append(val if val < INF else np.nan)
        finite = S_current[S_current < INF]
        avg_distances.append(np.mean(finite) if len(finite) > 0 else np.nan)
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
    
    ax1.plot(range(len(entry_values)), entry_values, 'b-o', markersize=4, linewidth=1.5)
    ax1.set_xlabel('Number of edge insertions', fontsize=12)
    ax1.set_ylabel(f'S({track_i},{track_j})', fontsize=12)
    ax1.set_title(f'Shortest path {track_i}→{track_j} under sequential edge insertions', 
                  fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    
    ax2.plot(range(len(avg_distances)), avg_distances, 'r-s', markersize=4, linewidth=1.5)
    ax2.set_xlabel('Number of edge insertions', fontsize=12)
    ax2.set_ylabel('Average finite distance', fontsize=12)
    ax2.set_title('Average shortest path distance vs. edge insertions', 
                  fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_batch.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_batch.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    visualize_heatmaps()
    visualize_sensitivity()
    visualize_update_structure()
    visualize_batch_updates()
    print("\nAll visualizations generated!")
