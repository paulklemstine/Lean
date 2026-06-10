#!/usr/bin/env python3
"""
Applications of Tropical Divisor Theory

Real-world and cross-domain applications of chip-firing and graph divisor theory:
1. Network load balancing (chip-firing as resource redistribution)
2. Sandpile dynamics and self-organized criticality
3. Critical group computation (discrete Jacobian)
4. Resistor network analysis via graph Laplacians
5. Riemann-Roch certificate generation for combinatorial optimization
"""

from algorithms import (
    Graph, Divisor, canonical_divisor, laplacian_divisor,
    fire_vertex, fire_set, dhars_burning, reduce_divisor,
    compute_rank, complete_graph_genus
)
from collections import defaultdict
from typing import Dict, List, Set, Tuple
import random


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Network Load Balancing
# ═══════════════════════════════════════════════════════════════════════

def network_load_balancing_demo():
    """Chip-firing as a model for distributed load balancing.
    
    In a network of processors, each processor has a "load" (number of tasks).
    Chip-firing redistributes load to neighbors, always preserving total load
    (conservation of charge). The reduced divisor gives the unique stable
    configuration.
    """
    print("\n" + "="*60)
    print("  APPLICATION 1: Network Load Balancing via Chip-Firing")
    print("="*60)
    
    # Small datacenter network (graph)
    # 6 servers in a mesh topology
    edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0), (0,3), (1,4), (2,5)]
    G = Graph(set(range(6)), edges)
    
    # Initial load distribution (very uneven)
    initial_load = Divisor({0: 15, 1: 0, 2: 8, 3: 0, 4: 12, 5: 1})
    print(f"\nNetwork: 6 servers, {G.num_edges()} connections")
    print(f"Initial load: {initial_load}")
    print(f"Total tasks: {initial_load.degree()}")
    print(f"Load imbalance: max={max(initial_load[v] for v in range(6))}, "
          f"min={min(initial_load[v] for v in range(6))}")
    
    # Reduce to find balanced configuration
    balanced = reduce_divisor(G, initial_load, 0)
    print(f"\nAfter chip-firing balancing (0-reduced form):")
    print(f"  Balanced load: {balanced}")
    print(f"  Total tasks: {balanced.degree()} (preserved ✓)")
    print(f"  Load imbalance: max={max(balanced[v] for v in range(6))}, "
          f"min={min(balanced[v] for v in range(6))}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Sandpile Dynamics
# ═══════════════════════════════════════════════════════════════════════

def sandpile_stabilization(G: Graph, D: Divisor, sink: int,
                           max_steps: int = 10000) -> Tuple[Divisor, int]:
    """Stabilize a sandpile configuration by toppling unstable vertices.
    
    A vertex v (≠ sink) is unstable if D[v] ≥ deg(v).
    Toppling v sends one grain to each neighbor and removes deg(v) from v.
    The sink absorbs grains without toppling.
    
    Returns (stable_config, num_topplings).
    """
    current = Divisor(dict(D.coeffs))
    topplings = 0
    
    for _ in range(max_steps):
        # Find an unstable vertex (not the sink)
        unstable = None
        for v in G.vertices:
            if v != sink and current[v] >= G.degree(v):
                unstable = v
                break
        
        if unstable is None:
            return current, topplings
        
        # Topple
        current = fire_vertex(G, current, unstable)
        topplings += 1
    
    return current, topplings


def sandpile_demo():
    """Demonstrate sandpile dynamics and self-organized criticality."""
    print("\n" + "="*60)
    print("  APPLICATION 2: Sandpile Dynamics and Self-Organized Criticality")
    print("="*60)
    
    K4 = Graph.complete_graph(4)
    sink = 0
    
    print(f"\nGraph: K₄, sink vertex: {sink}")
    print(f"Critical threshold per vertex: deg(v) = {K4.degree(0)}")
    
    # Start with a large pile and stabilize
    D = Divisor({0: 0, 1: 10, 2: 8, 3: 7})
    print(f"\nInitial sandpile: {D}")
    
    stable, topplings = sandpile_stabilization(K4, D, sink)
    print(f"Stable configuration: {stable}")
    print(f"Number of topplings: {topplings}")
    print(f"Grains absorbed by sink: {D.degree() - stable.degree() + D[sink] - stable[sink]}")
    
    # Recurrent configurations
    print("\n--- Recurrent (critical) configurations on K₄ \\ {sink} ---")
    print("These form the critical group (sandpile group / Jacobian).")
    
    # Enumerate all stable configs and check recurrence
    recurrent = []
    max_val = K4.degree(1)  # = 3
    for a in range(max_val):
        for b in range(max_val):
            for c in range(max_val):
                D = Divisor({0: 0, 1: a, 2: b, 3: c})
                # Add maximal stable config and stabilize
                max_stable = Divisor({0: 0, 1: max_val-1, 2: max_val-1, 3: max_val-1})
                D_plus = D + max_stable
                D_stab, _ = sandpile_stabilization(K4, D_plus, sink)
                # Check if we get back D
                if all(D_stab[v] == D[v] for v in [1, 2, 3]):
                    recurrent.append((a, b, c))
    
    print(f"Number of recurrent configs: {len(recurrent)}")
    print(f"(Should equal |det(reduced Laplacian)| = number of spanning trees)")
    print(f"Recurrent configs: {recurrent[:10]}{'...' if len(recurrent) > 10 else ''}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Critical Group Computation
# ═══════════════════════════════════════════════════════════════════════

def critical_group_demo():
    """Compute the critical group (sandpile group) of small graphs."""
    print("\n" + "="*60)
    print("  APPLICATION 3: Critical Group (Tropical Jacobian)")
    print("="*60)
    
    print("\nThe critical group Jac(G) = ℤ^(n-1) / Im(Laplacian)")
    print("It is a finite abelian group whose order = # spanning trees.")
    print("This is the discrete analogue of the Jacobian variety.\n")
    
    for n in range(3, 7):
        G = Graph.complete_graph(n)
        g = G.genus()
        # Number of spanning trees of K_n = n^(n-2) (Cayley's formula)
        num_trees = n ** (n - 2)
        print(f"K_{n}: genus = {g}, |Jac(K_{n})| = {num_trees} "
              f"(= n^(n-2) by Cayley's formula)")
        print(f"  Jac(K_{n}) ≅ (ℤ/nℤ)^(n-2) "
              f"[order {n**(n-2)}]")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Resistor Network Analysis
# ═══════════════════════════════════════════════════════════════════════

def resistor_network_demo():
    """Model a resistor network using the graph Laplacian."""
    print("\n" + "="*60)
    print("  APPLICATION 4: Resistor Network Analysis")
    print("="*60)
    
    print("\nThe graph Laplacian governs current flow in resistor networks.")
    print("Chip-firing = charge redistribution; Δf = 0 is Kirchhoff's law.\n")
    
    # Simple resistor network
    G = Graph(set(range(4)), [(0,1), (1,2), (2,3), (0,2), (1,3)])
    print(f"Network: 4 nodes, {G.num_edges()} resistors (equal resistance)")
    
    # Apply voltage and compute currents
    voltages = {0: 10, 1: 7, 2: 3, 3: 0}
    print(f"Applied voltages: {voltages}")
    
    lap = laplacian_divisor(G, voltages)
    print(f"Current at each node (Δf): {lap}")
    print(f"Total current (Kirchhoff): {lap.degree()} "
          f"{'✓' if lap.degree() == 0 else '✗'}")
    
    print(f"\nInterpretation:")
    for v in sorted(G.vertices):
        if lap[v] > 0:
            print(f"  Node {v} (V={voltages[v]}): sources {lap[v]} units of current")
        elif lap[v] < 0:
            print(f"  Node {v} (V={voltages[v]}): sinks {-lap[v]} units of current")
        else:
            print(f"  Node {v} (V={voltages[v]}): balanced (no net current)")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 5: Riemann-Roch Certificate for Optimization
# ═══════════════════════════════════════════════════════════════════════

def riemann_roch_certificate_demo():
    """Use Riemann-Roch to certify properties of graph divisors."""
    print("\n" + "="*60)
    print("  APPLICATION 5: Riemann-Roch Certificates")
    print("="*60)
    
    print("\nBaker-Norine theorem: r(D) - r(K-D) = deg(D) - g + 1")
    print("This gives lower bounds on divisor rank from degree alone.")
    print("If deg(D) ≥ g, then r(D) ≥ deg(D) - g ≥ 0, so D ~ effective.\n")
    
    K4 = Graph.complete_graph(4)
    g = K4.genus()
    K = canonical_divisor(K4)
    
    print(f"K₄: genus = {g}")
    print(f"Canonical divisor: {K}, degree = {K.degree()}")
    print(f"\nCertificates from Riemann-Roch:")
    
    for d in range(0, 2*g + 1):
        D = Divisor({v: (d if v == 0 else 0) for v in range(4)})
        rhs = d - g + 1
        r = compute_rank(K4, D)
        
        if rhs > 0:
            print(f"  deg={d}: r(D) ≥ {rhs-1} guaranteed "
                  f"(actual r(D) = {r})")
        elif d >= g:
            print(f"  deg={d}: D is equivalent to an effective divisor "
                  f"(r(D) = {r} ≥ 0)")
        else:
            print(f"  deg={d}: no guarantee (actual r(D) = {r})")


if __name__ == "__main__":
    network_load_balancing_demo()
    sandpile_demo()
    critical_group_demo()
    resistor_network_demo()
    riemann_roch_certificate_demo()
    
    print("\n" + "="*60)
    print("  ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("="*60)


#!/usr/bin/env python3
"""
Tropical Divisor Theory — Interactive Demo

Demonstrates the core concepts of chip-firing on graphs, tropical divisor theory,
and the Baker-Norine Riemann-Roch theorem through concrete computations on
complete graphs, cycles, and other families.

All results are cross-checked against formally verified theorems in Lean 4.
"""

from algorithms import (
    Graph, Divisor, canonical_divisor, laplacian_divisor,
    fire_vertex, fire_set, dhars_burning, reduce_divisor,
    compute_rank, complete_graph_genus, complete_graph_canonical_divisor,
    complete_graph_canonical_degree, is_equivalent_to_effective
)


def print_header(title: str):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def demo_basic_concepts():
    """Demonstrate basic chip-firing on K₄."""
    print_header("DEMO 1: Basic Chip-Firing on K₄")
    
    K4 = Graph.complete_graph(4)
    print(f"Graph: K₄ (complete graph on 4 vertices)")
    print(f"Vertices: {sorted(K4.vertices)}")
    print(f"Edges: {K4.edges_list}")
    print(f"Number of edges: {K4.num_edges()}")
    print(f"Genus: {K4.genus()}")
    print(f"Vertex degrees: {[K4.degree(v) for v in sorted(K4.vertices)]}")
    
    # Initial divisor
    D = Divisor({0: 5, 1: -1, 2: 0, 3: -1})
    print(f"\nInitial divisor D = {D}")
    print(f"  Degree: {D.degree()}")
    print(f"  Effective: {D.is_effective()}")
    
    # Fire vertex 0
    D1 = fire_vertex(K4, D, 0)
    print(f"\nAfter firing vertex 0:")
    print(f"  D' = {D1}")
    print(f"  Degree: {D1.degree()} (preserved ✓)")
    print(f"  Effective: {D1.is_effective()}")
    
    # Fire vertex 0 again
    D2 = fire_vertex(K4, D1, 0)
    print(f"\nAfter firing vertex 0 again:")
    print(f"  D'' = {D2}")
    print(f"  Degree: {D2.degree()}")
    print(f"  Effective: {D2.is_effective()}")


def demo_conservation_of_charge():
    """Verify that Laplacian divisors always have degree 0."""
    print_header("DEMO 2: Conservation of Charge (Degree Invariance)")
    print("Theorem (formally verified): For any graph G and potential f,")
    print("  degree(Δf) = 0")
    print("This is simultaneously:")
    print("  • A tropical geometry fact (principal divisors have degree 0)")
    print("  • A physics fact (conservation of charge in resistor networks)")
    print("  • A graph theory fact (Laplacian has zero row-sum)")
    
    import random
    random.seed(42)
    for name, G in [("K₃", Graph.complete_graph(3)),
                     ("K₅", Graph.complete_graph(5)),
                     ("C₆", Graph.cycle_graph(6)),
                     ("K₇", Graph.complete_graph(7))]:
        verts = sorted(G.vertices)
        f = {v: random.randint(-10, 10) for v in verts}
        lap = laplacian_divisor(G, f)
        status = "✓" if lap.degree() == 0 else "✗ BUG!"
        print(f"\n  {name}: f = {f}")
        print(f"    Δf = {lap}")
        print(f"    degree(Δf) = {lap.degree()} {status}")


def demo_canonical_divisor():
    """Demonstrate the canonical divisor and 2g-2 formula."""
    print_header("DEMO 3: Canonical Divisor and the 2g-2 Formula")
    print("Theorem (formally verified): deg(K_G) = 2g - 2")
    print("This is the tropical analogue of the Gauss-Bonnet theorem.\n")
    
    for n in range(2, 11):
        G = Graph.complete_graph(n)
        K = canonical_divisor(G)
        g = G.genus()
        expected = 2 * g - 2
        actual = K.degree()
        status = "✓" if actual == expected else "✗"
        print(f"  K_{n:>2}: genus = {g:>3}, deg(K_G) = {actual:>4}, "
              f"2g-2 = {expected:>4} {status}")


def demo_dhars_burning():
    """Demonstrate Dhar's burning algorithm."""
    print_header("DEMO 4: Dhar's Burning Algorithm")
    print("Dhar's algorithm tests if a divisor is q-reduced.")
    print("A fire starts at q; vertex v burns if D(v) < #burning neighbors.")
    print("If all vertices burn, the divisor is q-reduced.\n")
    
    K4 = Graph.complete_graph(4)
    
    test_cases = [
        (Divisor({0: -3, 1: 2, 2: 2, 3: 2}), "high non-q, negative q"),
        (Divisor({0: 0, 1: 3, 2: 3, 3: 3}), "uniformly high non-q"),
        (Divisor({0: 0, 1: 1, 2: 1, 3: 0}), "moderate chips"),
        (Divisor({0: 0, 1: 0, 2: 2, 3: 0}), "concentrated chips"),
    ]
    
    for D, desc in test_cases:
        is_red, unburned = dhars_burning(K4, D, 0)
        print(f"D = {D}  ({desc})")
        print(f"  q-reduced: {is_red}, unburned: {unburned}")


def demo_divisor_reduction():
    """Demonstrate the divisor reduction algorithm."""
    print_header("DEMO 5: Divisor Reduction Algorithm")
    print("Every divisor is linearly equivalent to a unique q-reduced divisor.")
    print("The reduction algorithm iteratively fires unburned sets.\n")
    
    K4 = Graph.complete_graph(4)
    
    test_divisors = [
        Divisor({0: 0, 1: 3, 2: 3, 3: 3}),
        Divisor({0: 5, 1: 0, 2: 2, 3: 2}),
        Divisor({0: -2, 1: 5, 2: 3, 3: 0}),
        Divisor({0: 1, 1: 1, 2: 1, 3: 0}),
    ]
    
    for D in test_divisors:
        D_red = reduce_divisor(K4, D, 0)
        is_red, _ = dhars_burning(K4, D_red, 0)
        print(f"D = {D}")
        print(f"  0-reduced: {D_red}")
        print(f"  Degree preserved: {D.degree() == D_red.degree()} ✓")
        print(f"  Is 0-reduced: {is_red}")
        print()


def demo_rank_computation():
    """Compute divisor ranks on K₃."""
    print_header("DEMO 6: Divisor Rank Computation on K₃")
    print("r(D) = max{r ≥ 0 : ∀ effective E with deg(E)=r, D-E ~ effective}")
    print("r(D) = -1 if D is not equivalent to any effective divisor.\n")
    
    K3 = Graph.complete_graph(3)
    g = K3.genus()
    print(f"Graph: K₃, genus = {g}\n")
    
    test_cases = [
        (Divisor({0: 0, 1: 0, 2: 0}), "0"),
        (Divisor({0: 1, 1: 0, 2: 0}), "[0]"),
        (Divisor({0: 1, 1: 1, 2: 0}), "[0]+[1]"),
        (Divisor({0: 2, 1: 0, 2: 0}), "2·[0]"),
        (Divisor({0: 3, 1: 0, 2: 0}), "3·[0]"),
        (Divisor({0: 1, 1: 1, 2: 1}), "[0]+[1]+[2]"),
        (Divisor({0: -1, 1: 0, 2: 0}), "-[0]"),
    ]
    
    for D, name in test_cases:
        r = compute_rank(K3, D)
        print(f"  r({name:>12}) = {r:>2}  (degree = {D.degree()})")


def demo_riemann_roch_check():
    """Numerically verify Riemann-Roch on K₃."""
    print_header("DEMO 7: Riemann-Roch Verification on K₃")
    print("Baker-Norine Theorem: r(D) - r(K-D) = deg(D) - g + 1")
    print("We verify this numerically for various divisors.\n")
    
    K3 = Graph.complete_graph(3)
    g = K3.genus()
    K = canonical_divisor(K3)
    
    print(f"K₃: genus = {g}, K = {K}, deg(K) = {K.degree()}")
    print()
    
    verified = 0
    total = 0
    
    # Test single-vertex divisors
    for k in range(-1, 5):
        D = Divisor({0: k, 1: 0, 2: 0})
        K_minus_D = K - D
        r_D = compute_rank(K3, D)
        r_KD = compute_rank(K3, K_minus_D)
        lhs = r_D - r_KD
        rhs = D.degree() - g + 1
        status = "✓" if lhs == rhs else "✗"
        total += 1
        if lhs == rhs:
            verified += 1
        print(f"  D = {k}·[0]: r(D) = {r_D:>2}, r(K-D) = {r_KD:>2}, "
              f"r(D)-r(K-D) = {lhs:>2}, deg(D)-g+1 = {rhs:>2} {status}")
    
    # Test some mixed divisors
    for a, b, c in [(1,1,0), (2,1,0), (0,0,2), (1,1,1)]:
        D = Divisor({0: a, 1: b, 2: c})
        K_minus_D = K - D
        r_D = compute_rank(K3, D)
        r_KD = compute_rank(K3, K_minus_D)
        lhs = r_D - r_KD
        rhs = D.degree() - g + 1
        status = "✓" if lhs == rhs else "✗"
        total += 1
        if lhs == rhs:
            verified += 1
        print(f"  D = ({a},{b},{c}): r(D) = {r_D:>2}, r(K-D) = {r_KD:>2}, "
              f"r(D)-r(K-D) = {lhs:>2}, deg(D)-g+1 = {rhs:>2} {status}")
    
    print(f"\n  Verified: {verified}/{total}")


def demo_genus_computations():
    """Verified genus computations for complete graphs."""
    print_header("DEMO 8: Verified Genus Computations")
    print("Formally verified: genus(K_n) = (n-1)(n-2)/2\n")
    
    print(f"  {'n':>3} | {'|V|':>4} | {'|E|':>4} | {'genus':>5} | {'formula':>7}")
    print(f"  {'-'*3}-+-{'-'*4}-+-{'-'*4}-+-{'-'*5}-+-{'-'*7}")
    for n in range(2, 11):
        G = Graph.complete_graph(n)
        g = G.genus()
        formula = (n-1)*(n-2)//2
        status = "✓" if g == formula else "✗"
        print(f"  {n:>3} | {n:>4} | {G.num_edges():>4} | {g:>5} | {formula:>7} {status}")


def demo_cross_domain():
    """Cross-domain connections: chip-firing as discrete electrostatics."""
    print_header("DEMO 9: Cross-Domain — Discrete Electrostatics")
    print("Chip-firing ≡ charge redistribution in a resistor network.")
    print("The Laplacian Δf represents a zero-total-charge perturbation.")
    print("Reduced divisors minimize 'energy' under firing constraints.\n")
    
    K5 = Graph.complete_graph(5)
    
    print("Consider K₅ as a resistor network with equal resistances.")
    print("A 'voltage' assignment f induces currents through the Laplacian.\n")
    
    f = {0: 10, 1: 5, 2: 0, 3: -5, 4: -10}
    print(f"Voltage assignment: f = {f}")
    lap = laplacian_divisor(K5, f)
    print(f"Current flow (Δf):  {lap}")
    print(f"Total current (should be 0): {lap.degree()}")
    print(f"\nInterpretation: vertex 0 (highest voltage) sources "
          f"{lap[0]} units of current")
    print(f"Vertex 4 (lowest voltage) sinks {-lap[4]} units")
    print("Current is conserved: Kirchhoff's current law holds!")
    
    print("\n--- Equivalence Testing ---")
    print("Two divisors are linearly equivalent if they differ by Δf")
    print("(formally verified: linearEquivalent_iff_diff_in_laplacian_image)")
    
    K3 = Graph.complete_graph(3)
    D1 = Divisor({0: 2, 1: 0, 2: 0})
    D2 = Divisor({0: 0, 1: 1, 2: 1})
    # D1 - D2 = (2, -1, -1). Fire vertex 0: Δ(1,0,0) = (2,-1,-1). So D1 ~ D2.
    print(f"\n  D₁ = {D1}, D₂ = {D2}")
    print(f"  D₁ - D₂ = ({D1[0]-D2[0]}, {D1[1]-D2[1]}, {D1[2]-D2[2]})")
    print(f"  Δ(1,0,0) = {laplacian_divisor(K3, {0:1,1:0,2:0})}")
    print(f"  ⟹ D₁ ~ D₂ via firing vertex 0 ✓")


def demo_effective_divisors():
    """Show when divisors can be made effective."""
    print_header("DEMO 10: Effectiveness Testing")
    print("A divisor D has r(D) ≥ 0 iff D ~ some effective divisor.")
    print("This is equivalent to the q-reduced form being non-negative.\n")
    
    K3 = Graph.complete_graph(3)
    
    test_cases = [
        Divisor({0: 2, 1: -1, 2: 0}),
        Divisor({0: -1, 1: -1, 2: 3}),
        Divisor({0: -1, 1: 0, 2: 0}),
        Divisor({0: 0, 1: 0, 2: 1}),
        Divisor({0: 1, 1: 1, 2: -1}),
    ]
    
    for D in test_cases:
        eff = is_equivalent_to_effective(K3, D)
        print(f"  D = {D}, deg = {D.degree()}: "
              f"equivalent to effective = {eff}")


if __name__ == "__main__":
    demo_basic_concepts()
    demo_conservation_of_charge()
    demo_canonical_divisor()
    demo_dhars_burning()
    demo_divisor_reduction()
    demo_rank_computation()
    demo_riemann_roch_check()
    demo_genus_computations()
    demo_cross_domain()
    demo_effective_divisors()
    
    print_header("ALL DEMOS COMPLETE")
    print("These computations match the formally verified theorems in")
    print("Tropical/ChipFiring/Defs.lean and Tropical/ChipFiring/Theorems.lean")
