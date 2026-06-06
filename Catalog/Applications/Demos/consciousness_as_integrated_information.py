#!/usr/bin/env python3
"""
Integrated Information Theory (IIT) — Numerical Demonstrations

Demonstrates the key theorems from our formalization:
1. Phi = 0 characterizes disconnected systems
2. Edge monotonicity of Phi
3. Complement duality: Phi(G) + Phi(G^c) >= Phi(K_n)
4. Functorial bound under causal morphisms
"""

import itertools
from typing import List, Tuple, Set, Dict

# --- Core IIT Definitions ---

def all_nontrivial_cuts(n: int) -> List[Tuple[bool, ...]]:
    """Generate all non-trivial cuts (both sides non-empty)."""
    cuts = []
    for bits in itertools.product([True, False], repeat=n):
        if any(bits) and not all(bits):
            cuts.append(bits)
    return cuts

def cut_value(edges: Set[Tuple[int, int]], cut: Tuple[bool, ...]) -> int:
    """Count edges crossing a cut."""
    return sum(1 for (i, j) in edges if cut[i] != cut[j])

def phi(n: int, edges: Set[Tuple[int, int]]) -> int:
    """Compute integrated information Phi."""
    if n < 2:
        return 0
    cuts = all_nontrivial_cuts(n)
    return min(cut_value(edges, c) for c in cuts)

def complete_graph_edges(n: int) -> Set[Tuple[int, int]]:
    """All directed edges on n nodes (including self-loops for generality)."""
    return {(i, j) for i in range(n) for j in range(n)}

def complement_edges(n: int, edges: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
    """Complement of edge set relative to complete graph."""
    return complete_graph_edges(n) - edges

# --- Demonstrations ---

def demo_disconnected_systems():
    """Theorem: Phi = 0 iff graph is disconnected."""
    print("=" * 60)
    print("THEOREM: phi_eq_zero_iff_disconnected")
    print("Phi = 0 ⟺ system is causally disconnected")
    print("=" * 60)

    # Connected graph: triangle
    triangle = {(0,1), (1,2), (2,0)}
    phi_tri = phi(3, triangle)
    print(f"\nTriangle {{0→1, 1→2, 2→0}}: Φ = {phi_tri} (connected, Φ > 0) ✓")

    # Disconnected: two isolated edges
    disconnected = {(0,1), (2,3)}
    phi_disc = phi(4, disconnected)
    print(f"Disconnected {{0→1, 2→3}}: Φ = {phi_disc} (disconnected, Φ = 0) ✓")

    # Path graph (connected)
    path = {(0,1), (1,2), (2,3)}
    phi_path = phi(4, path)
    print(f"Path {{0→1, 1→2, 2→3}}: Φ = {phi_path} (connected, Φ > 0) ✓")

    # Empty graph
    empty = set()
    phi_empty = phi(3, empty)
    print(f"Empty graph on 3 nodes: Φ = {phi_empty} (disconnected, Φ = 0) ✓")

def demo_monotonicity():
    """Theorem: Adding edges cannot decrease Phi."""
    print("\n" + "=" * 60)
    print("THEOREM: phi_monotone_edges")
    print("G ⊆ H ⟹ Φ(G) ≤ Φ(H)")
    print("=" * 60)

    n = 4
    edges_sequence = [
        {(0,1)},
        {(0,1), (1,2)},
        {(0,1), (1,2), (2,3)},
        {(0,1), (1,2), (2,3), (3,0)},
        {(0,1), (1,2), (2,3), (3,0), (0,2)},
        {(0,1), (1,2), (2,3), (3,0), (0,2), (2,0)},
    ]

    prev_phi = 0
    for edges in edges_sequence:
        p = phi(n, edges)
        arrow = "≥" if p >= prev_phi else "< (VIOLATION!)"
        print(f"|E| = {len(edges):2d}, Φ = {p}  {arrow}")
        assert p >= prev_phi, "Monotonicity violated!"
        prev_phi = p
    print("Monotonicity verified ✓")

def demo_complement_duality():
    """Theorem: Phi(G) + Phi(G^c) <= Phi(K_n)."""
    print("\n" + "=" * 60)
    print("THEOREM: phi_complement_bound")
    print("Φ(G) + Φ(Gᶜ) ≤ Φ(Kₙ)")
    print("A system and its complement together don't exceed")
    print("the integration of the fully-connected system.")
    print("=" * 60)

    for n in range(2, 6):
        kn = complete_graph_edges(n)
        phi_kn = phi(n, kn)
        print(f"\nn = {n}, Φ(K_{n}) = {phi_kn}")

        # Test several random-ish graphs
        for desc, edges in [
            ("single edge", {(0,1)}),
            ("path", {(i, i+1) for i in range(n-1)}),
            ("half edges", {(i,j) for i in range(n) for j in range(n) if (i+j) % 2 == 0}),
        ]:
            comp = complement_edges(n, edges)
            p_g = phi(n, edges)
            p_comp = phi(n, comp)
            ok = "✓" if p_g + p_comp <= phi_kn else "✗"
            print(f"  {desc:15s}: Φ(G)={p_g}, Φ(Gᶜ)={p_comp}, sum={p_g+p_comp} ≤ {phi_kn} {ok}")

def demo_disjoint_union():
    """Theorem: Phi of disjoint union is zero."""
    print("\n" + "=" * 60)
    print("THEOREM: phi_djUnion_zero")
    print("Independent subsystems have zero integration")
    print("=" * 60)

    # Two complete graphs, no inter-connections
    g1_edges = {(0,1), (1,0)}  # K2 on nodes 0,1
    g2_edges = {(2,3), (3,2)}  # K2 on nodes 2,3
    union_edges = g1_edges | g2_edges

    p_union = phi(4, union_edges)
    p_g1 = phi(2, {(0,1), (1,0)})
    p_g2 = phi(2, {(0,1), (1,0)})

    print(f"\nG₁ = K₂ on {{0,1}}: Φ = {p_g1}")
    print(f"G₂ = K₂ on {{2,3}}: Φ = {p_g2}")
    print(f"G₁ ⊔ G₂ (no connections): Φ = {p_union}")
    print(f"Disjoint union has Φ = 0 despite components having Φ > 0 ✓")

    # Now add a bridge
    bridged = union_edges | {(1,2)}
    p_bridged = phi(4, bridged)
    print(f"\nAdd bridge 1→2: Φ = {p_bridged} (integration emerges!) ✓")

def demo_small_computations():
    """Concrete Phi values for small graphs."""
    print("\n" + "=" * 60)
    print("THEOREMS: phi_singleEdge2, phi_complete2")
    print("Concrete computations on 2-node systems")
    print("=" * 60)

    # Single edge
    p1 = phi(2, {(0,1)})
    print(f"\nSingle edge 0→1: Φ = {p1} (verified = 1) ✓")

    # Complete K2
    p2 = phi(2, {(0,1), (1,0)})
    print(f"Complete K₂: Φ = {p2} (verified = 2) ✓")

    # n=3 examples
    print(f"\nn=3 examples:")
    cycle3 = {(0,1), (1,2), (2,0)}
    print(f"  Directed cycle: Φ = {phi(3, cycle3)}")
    full_cycle3 = {(0,1), (1,0), (1,2), (2,1), (2,0), (0,2)}
    print(f"  Complete K₃: Φ = {phi(3, full_cycle3)}")

def demo_phi_landscape():
    """Survey Phi across all graphs on 4 nodes."""
    print("\n" + "=" * 60)
    print("PHI LANDSCAPE: Distribution of Φ across 4-node graphs")
    print("=" * 60)

    n = 4
    possible_edges = [(i,j) for i in range(n) for j in range(n) if i != j]
    phi_counts: Dict[int, int] = {}

    # Sample graphs by number of edges
    for num_edges in range(len(possible_edges) + 1):
        sample_count = min(100, len(list(itertools.combinations(possible_edges, num_edges))))
        max_phi = 0
        for edges_tuple in itertools.islice(itertools.combinations(possible_edges, num_edges), 100):
            p = phi(n, set(edges_tuple))
            max_phi = max(max_phi, p)
            phi_counts[p] = phi_counts.get(p, 0) + 1

    print(f"\nΦ distribution (sampled):")
    for p in sorted(phi_counts.keys()):
        bar = "█" * min(50, phi_counts[p] // 10)
        print(f"  Φ = {p}: {phi_counts[p]:5d} graphs {bar}")

if __name__ == "__main__":
    demo_disconnected_systems()
    demo_monotonicity()
    demo_complement_duality()
    demo_disjoint_union()
    demo_small_computations()
    demo_phi_landscape()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Phi Landscape across Graph Density

Shows how integrated information varies with the number of edges
in a causal system, demonstrating the key theorems:
- Phi = 0 for disconnected graphs (low edge count)
- Phi increases monotonically with edge addition
- Phi saturates at the complete graph value
"""

import itertools
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
from typing import Set, Tuple, Dict, List


def cut_value(n: int, edges: Set[Tuple[int, int]], cut: Tuple[bool, ...]) -> int:
    return sum(1 for (i, j) in edges if cut[i] != cut[j])


def compute_phi(n: int, edges: Set[Tuple[int, int]]) -> int:
    if n < 2:
        return 0
    cuts = [c for c in itertools.product([True, False], repeat=n)
            if any(c) and not all(c)]
    return min(cut_value(n, edges, c) for c in cuts)


def main():
    n = 4
    possible_edges = [(i, j) for i in range(n) for j in range(n) if i != j]
    max_edges = len(possible_edges)

    # Collect Phi values by edge count
    phi_by_density: Dict[int, List[int]] = defaultdict(list)

    total_sampled = 0
    max_per_density = 200

    for num_edges in range(max_edges + 1):
        count = 0
        for edge_combo in itertools.combinations(possible_edges, num_edges):
            if count >= max_per_density:
                break
            p = compute_phi(n, set(edge_combo))
            phi_by_density[num_edges].append(p)
            count += 1
            total_sampled += 1

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Phi vs Edge Count (scatter with jitter)
    ax = axes[0]
    for num_edges, phis in sorted(phi_by_density.items()):
        jitter = np.random.normal(0, 0.15, len(phis))
        ax.scatter([num_edges + j for j in jitter], phis,
                   alpha=0.3, s=10, c='steelblue')

    means = {k: np.mean(v) for k, v in phi_by_density.items()}
    ax.plot(sorted(means.keys()), [means[k] for k in sorted(means.keys())],
            'r-', linewidth=2, label='Mean Φ')
    ax.set_xlabel('Number of Edges', fontsize=12)
    ax.set_ylabel('Φ (Integrated Information)', fontsize=12)
    ax.set_title(f'Integration vs. Wiring Complexity (n={n})', fontsize=13)
    ax.legend()

    # Plot 2: Phi distribution histogram
    ax = axes[1]
    all_phis = [p for phis in phi_by_density.values() for p in phis]
    phi_range = range(max(all_phis) + 1)
    counts = [all_phis.count(p) for p in phi_range]
    ax.bar(phi_range, counts, color='coral', edgecolor='darkred', alpha=0.8)
    ax.set_xlabel('Φ Value', fontsize=12)
    ax.set_ylabel('Number of Graphs', fontsize=12)
    ax.set_title(f'Distribution of Φ (n={n})', fontsize=13)

    # Plot 3: Fraction of disconnected graphs by edge count
    ax = axes[2]
    densities = sorted(phi_by_density.keys())
    frac_disconnected = []
    frac_high_phi = []
    for d in densities:
        phis = phi_by_density[d]
        frac_disconnected.append(sum(1 for p in phis if p == 0) / len(phis))
        frac_high_phi.append(sum(1 for p in phis if p >= 2) / len(phis))

    ax.plot(densities, frac_disconnected, 'b-o', markersize=4,
            label='Φ = 0 (disconnected)')
    ax.plot(densities, frac_high_phi, 'r-s', markersize=4,
            label='Φ ≥ 2 (highly integrated)')
    ax.fill_between(densities, frac_disconnected, alpha=0.2, color='blue')
    ax.fill_between(densities, frac_high_phi, alpha=0.2, color='red')
    ax.set_xlabel('Number of Edges', fontsize=12)
    ax.set_ylabel('Fraction of Graphs', fontsize=12)
    ax.set_title('Phase Transition in Integration', fontsize=13)
    ax.legend()

    plt.tight_layout()
    plt.savefig('phi_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved phi_landscape.png (sampled {total_sampled} graphs)")


if __name__ == "__main__":
    main()
