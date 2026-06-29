"""
Tropical Persistence Barcode — Real-World Applications

Demonstrates applications of tropical persistence barcodes to:
1. Infrastructure network resilience analysis
2. Communication network hub accessibility
3. Biological signaling network structure
"""

from algorithms import (
    Graph, tropical_kernel_dim, induced_cycle_rank,
    q_visible_component_count, compute_tropical_barcode,
    compute_dims, reconstruct_dims, verify_barcode_correctness,
    TropicalFiltrationEvent
)


def infrastructure_resilience():
    """Analyze an infrastructure network for hub-dependent resilience.

    Models a power grid with a central substation (q) and substations
    connected in a partially redundant topology.
    """
    print("=" * 60)
    print("APPLICATION 1: Infrastructure Network Resilience")
    print("=" * 60)

    # Power grid topology: substation 0 is the main transformer
    # Substations 1-6 serve different districts
    V = {0, 1, 2, 3, 4, 5, 6}
    E = {
        (0, 1), (0, 2),  # Direct connections to main
        (1, 3), (2, 4),  # First-hop extensions
        (3, 4),          # Cross-link creating redundancy
        (4, 5), (5, 6),  # Chain extension
        (3, 6),          # Long-range redundancy link
    }
    G = Graph(V, E)
    q = 0  # Main substation

    print(f"\nGrid topology: {sorted(G.edges)}")
    print(f"Main substation (hub): {q}")

    # Simulate progressive activation of substations
    activation_orders = [
        ("Nearest-first", [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}, {1,2,3,4,5}, {1,2,3,4,5,6}]),
        ("Farthest-first", [set(), {6}, {5,6}, {4,5,6}, {3,4,5,6}, {2,3,4,5,6}, {1,2,3,4,5,6}]),
    ]

    for name, filt in activation_orders:
        print(f"\n  Strategy: {name}")
        dims = compute_dims(G, q, filt)
        events = compute_tropical_barcode(G, q, filt)

        for k, S in enumerate(filt):
            cr = induced_cycle_rank(G, S)
            qv = q_visible_component_count(G, q, S)
            print(f"    Step {k}: substations={str(sorted(S)):30s} "
                  f"redundancy={cr} hub-access={qv} total-dim={dims[k]}")

        print(f"    Event summary:")
        for k, e in enumerate(events):
            desc = []
            if e.cycle_birth: desc.append(f"+{e.cycle_birth} redundancy")
            if e.q_visible_birth: desc.append(f"+{e.q_visible_birth} hub-access")
            if e.invisible_merge_death: desc.append(f"-{e.invisible_merge_death} merge")
            print(f"      Step {k}→{k+1}: {', '.join(desc) if desc else 'neutral'} (Δ={e.delta})")


def communication_network():
    """Analyze a communication network with sensor nodes.

    Models a wireless sensor network where node q is the base station.
    Tropical persistence tracks which sensor clusters can communicate
    with the base as new relay nodes are deployed.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Wireless Sensor Network Deployment")
    print("=" * 60)

    # Sensor network: base station at 0
    V = {0, 1, 2, 3, 4, 5, 6, 7}
    E = {
        (0, 1), (0, 2),        # Direct to base
        (1, 3), (2, 4),        # First relays
        (3, 5), (4, 5),        # Convergence point
        (5, 6), (6, 7),        # Remote chain
        (3, 7),                # Shortcut creating cycle
    }
    G = Graph(V, E)
    q = 0

    print(f"\nNetwork: {sorted(G.edges)}")
    print(f"Base station: {q}")

    # Deploy sensors in strategic order
    filt = [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}, {1,2,3,4,5},
            {1,2,3,4,5,6}, {1,2,3,4,5,6,7}]

    dims = compute_dims(G, q, filt)
    events = compute_tropical_barcode(G, q, filt)

    print("\n  Deployment sequence:")
    for k, S in enumerate(filt):
        cr = induced_cycle_rank(G, S)
        qv = q_visible_component_count(G, q, S)
        status = "✓" if qv > 0 else "✗"
        print(f"    Step {k}: sensors={str(sorted(S)):30s} "
              f"cycles={cr} base-visible={qv} [{status}] δ={dims[k]}")

    ok, direct, recon = verify_barcode_correctness(G, q, filt)
    print(f"\n  Barcode reconstruction verified: {ok}")


def biological_signaling():
    """Analyze a signaling pathway with a receptor hub.

    Models a protein signaling cascade where protein q is the membrane
    receptor. As downstream effectors are expressed, the tropical
    barcode tracks both feedback loops (cycles) and signal accessibility
    from the receptor (visibility).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Protein Signaling Cascade")
    print("=" * 60)

    # Signaling network: receptor at 0
    # Proteins: 0=receptor, 1=kinase, 2=phosphatase, 3=effector1,
    # 4=effector2, 5=transcription factor
    V = {0, 1, 2, 3, 4, 5}
    E = {
        (0, 1), (0, 2),   # Receptor activates kinase and phosphatase
        (1, 3), (2, 4),   # Downstream effectors
        (3, 5), (4, 5),   # Both effectors regulate transcription factor
        (1, 4),           # Cross-talk between pathways
    }
    G = Graph(V, E)
    q = 0  # Receptor

    print(f"\nPathway: {sorted(G.edges)}")
    print(f"Receptor: {q}")

    filt = [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}, {1,2,3,4,5}]
    dims = compute_dims(G, q, filt)
    events = compute_tropical_barcode(G, q, filt)

    labels = {1: "kinase", 2: "phosphatase", 3: "effector1",
              4: "effector2", 5: "TF"}

    print("\n  Expression cascade:")
    for k in range(1, len(filt)):
        new = filt[k] - filt[k-1]
        name = ", ".join(labels.get(v, str(v)) for v in new)
        e = events[k-1]
        print(f"    Express {name}: cycles={induced_cycle_rank(G, filt[k])} "
              f"receptor-visible={q_visible_component_count(G, q, filt[k])} "
              f"δ={dims[k]} "
              f"(+{e.cycle_birth} feedback, +{e.q_visible_birth} signal-access, "
              f"-{e.invisible_merge_death} merge)")

    print("\n  Insight: Cycle births mark feedback loop formation.")
    print("  Visibility births mark new signal-accessible clusters.")
    print("  Merges mark pathway convergence events.")


if __name__ == "__main__":
    infrastructure_resilience()
    communication_network()
    biological_signaling()


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
defs_lean = read_file('Pythagorean/TropicalBridge/Defs.lean')
persistence_lean = read_file('Pythagorean/TropicalBridge/FiltrationPersistence.lean')
viz1_code = read_file('viz_dimension_landscape.py')
viz2_code = read_file('viz_barcode_comparison.py')
viz3_code = read_file('viz_event_decomposition.py')
interactive_html = read_file('interactive_graph_filtration.html')

lean_proofs = defs_lean + "\n\n-- ========================================\n\n" + persistence_lean

package = {
    "title": "Tropical Persistence Barcodes for Graph Filtrations",
    "domain": "Algebraic Graph Topology / Tropical Linear Algebra / Topological Data Analysis",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Persistence Barcode Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Persistence Barcode Computation",
            "pseudocode": """Algorithm: ComputeTropicalBarcode
Input: Graph G = (V, E), basepoint q, filtration [S_0, ..., S_m]
Output: Event sequence [(cb, vb, md) for each step]

1. For k = 0 to m-1:
   a. Compute β₁(S_k), κ_q(S_k) using union-find on G[S_k]
   b. Compute β₁(S_{k+1}), κ_q(S_{k+1}) similarly
   c. Δβ₁ = β₁(S_{k+1}) - β₁(S_k)
   d. Δκ = κ_q(S_{k+1}) - κ_q(S_k)
   e. cycleBirth = max(Δβ₁, 0)
   f. visBirth = max(Δκ, 0)
   g. mergeDeath = max(-Δβ₁, 0) + max(-Δκ, 0)
   h. Record event (cycleBirth, visBirth, mergeDeath)

Time: O(m · (|V| + |E|))
Space: O(|V|)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Basepoint-Sensitive Dimension Landscape",
            "code": viz1_code,
            "description": "Heatmap showing how tropical kernel dimension varies across basepoint choices and filtration stages. Reveals the basepoint-sensitivity that distinguishes tropical persistence from ordinary persistent homology."
        },
        {
            "name": "Tropical vs Ordinary Barcode Comparison",
            "code": viz2_code,
            "description": "Side-by-side comparison of ordinary cycle persistence and tropical persistence for two filtrations, demonstrating that the tropical barcode captures strictly more information."
        },
        {
            "name": "Event Decomposition Along Filtration",
            "code": viz3_code,
            "description": "Stacked area chart showing the decomposition of tropical kernel dimension into cycle rank and visibility components, with event annotations marking births and deaths."
        }
    ],
    "interactive_demos": [
        {
            "name": "Tropical Persistence Barcode Explorer",
            "html": interactive_html,
            "description": "Interactive graph filtration explorer. Click vertices to add them to the filtration and watch the tropical kernel dimension evolve in real-time, decomposed into cycle rank and q-visible component contributions."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Persistence Barcode — Interactive Demo

Demonstrates the tropical persistence barcode theory on concrete graph examples.
Tests conjectures on small graphs (n ≤ 6) and shows cases where q-visibility
contributes information beyond ordinary cycle persistence.

Usage:
    python demo.py                   # Run all demos
    python demo.py --graph cycle 6   # Specific graph
    python demo.py --test-conjectures # Test conjectures on small graphs
"""

import sys
import itertools
from collections import defaultdict
from algorithms import (
    Graph, UnionFind,
    induced_cycle_rank, q_visible_component_count, tropical_kernel_dim,
    compute_tropical_barcode, compute_dims, reconstruct_dims,
    verify_barcode_correctness, graph_h1_rank_delta,
    complete_graph, cycle_graph, path_graph, star_graph, petersen_graph,
    TropicalFiltrationEvent
)


def print_header(title: str):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}")


def print_subheader(title: str):
    print(f"\n--- {title} ---")


def demonstrate_single_filtration(G: Graph, q, filtration, label: str):
    """Show the full tropical persistence analysis for one filtration."""
    print_subheader(f"{label}, basepoint q={q}")

    dims = compute_dims(G, q, filtration)
    events = compute_tropical_barcode(G, q, filtration)
    recon = reconstruct_dims(dims[0], events)
    correct = dims == recon

    print(f"  Filtration stages:")
    for k, S in enumerate(filtration):
        cr = induced_cycle_rank(G, S)
        qv = q_visible_component_count(G, q, S)
        print(f"    S_{k} = {str(sorted(S)):20s}  β₁={cr}  κ_q={qv}  δ={dims[k]}")

    print(f"\n  Event barcode:")
    for k, e in enumerate(events):
        print(f"    Step {k}→{k+1}: "
              f"cycleBirth={e.cycle_birth} "
              f"qVisBirth={e.q_visible_birth} "
              f"invisDeath={e.invisible_merge_death} "
              f"Δ={e.delta}")

    print(f"\n  Dimension sequence (direct):        {dims}")
    print(f"  Dimension sequence (reconstructed): {recon}")
    print(f"  Barcode reconstruction correct: {correct}")
    return dims, events


def demo_visibility_matters():
    """Show a case where q-visibility changes contribute to δ beyond β₁."""
    print_header("DEMO 1: When Visibility Matters")
    print("  In this example, the tropical kernel dimension jumps due to")
    print("  a q-visibility change, not a cycle birth. Ordinary persistent H₁")
    print("  would miss this transition entirely.")

    # Star graph: center=0, leaves=1,2,3,4
    # q=0 (the center)
    # Filtration adds leaves one by one
    G = star_graph(5)
    q = 0
    filtration = [set(), {1}, {1, 2}, {1, 2, 3}, {1, 2, 3, 4}]

    dims, events = demonstrate_single_filtration(
        G, q, filtration, "Star graph S_5"
    )

    print("\n  KEY INSIGHT: Every dimension jump comes from q-visible births,")
    print("  not cycle births — there are no cycles in a star graph!")
    print("  Ordinary persistent H₁ sees NOTHING here; tropical persistence")
    print("  captures the accessibility structure.")


def demo_cycle_and_visibility():
    """Show a case where both cycles and visibility contribute."""
    print_header("DEMO 2: Cycles AND Visibility")

    # Cycle graph C_6, q=0
    G = cycle_graph(6)
    q = 0
    filtration = [set(), {1}, {1, 2}, {1, 2, 3}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}]

    dims, events = demonstrate_single_filtration(
        G, q, filtration, "Cycle graph C_6"
    )

    print("\n  Notice: The cycle birth occurs at the LAST step (closing the cycle),")
    print("  while visibility births happen earlier. The tropical barcode")
    print("  records BOTH types of events.")


def demo_distinguishing_filtrations():
    """Find filtrations with same H₁ but different tropical barcodes."""
    print_header("DEMO 3: Tropical Barcode Distinguishes More Than H₁")

    # Build a graph where different basepoints give different visibility patterns
    # but the same cycle structure
    # Graph: 0-1-2-3-0 (a 4-cycle) plus edge 0-4
    V = {0, 1, 2, 3, 4}
    E = {(0, 1), (1, 2), (2, 3), (0, 3), (0, 4)}
    G = Graph(V, E)

    # Two filtrations with same vertex additions but different basepoints
    filtration = [set(), {1}, {1, 2}, {1, 2, 3}, {1, 2, 3, 4}]

    print("  Graph: 4-cycle (0-1-2-3-0) with pendant edge (0-4)")
    print(f"  Edges: {sorted(G.edges)}")

    # Compare with q=0 vs different filtration order
    filtration_A = [set(), {1}, {1, 4}, {1, 2, 4}, {1, 2, 3, 4}]
    filtration_B = [set(), {4}, {1, 4}, {1, 2, 4}, {1, 2, 3, 4}]

    q = 0
    dims_A, events_A = demonstrate_single_filtration(
        G, q, filtration_A, "Filtration A (add 1, 4, 2, 3)"
    )
    dims_B, events_B = demonstrate_single_filtration(
        G, q, filtration_B, "Filtration B (add 4, 1, 2, 3)"
    )

    # Check H₁ sequences
    h1_A = [induced_cycle_rank(G, S) for S in filtration_A]
    h1_B = [induced_cycle_rank(G, S) for S in filtration_B]

    print(f"\n  H₁ sequence A: {h1_A}")
    print(f"  H₁ sequence B: {h1_B}")
    print(f"  Tropical dim sequence A: {dims_A}")
    print(f"  Tropical dim sequence B: {dims_B}")

    if h1_A == h1_B and dims_A != dims_B:
        print("\n  ★ FOUND: Same H₁ barcodes but DIFFERENT tropical barcodes!")
        print("  This confirms Conjecture A for this example.")
    else:
        print("\n  These filtrations do not directly demonstrate Conjecture A.")
        print("  (H₁ sequences differ or tropical sequences match.)")


def generate_connected_graphs(n: int):
    """Generate all connected simple graphs on n labeled vertices.

    Uses the approach of generating all possible edge sets and filtering
    for connectivity.
    """
    vertices = set(range(n))
    all_possible_edges = [(i, j) for i in range(n) for j in range(i+1, n)]

    for r in range(n - 1, len(all_possible_edges) + 1):
        for edge_combo in itertools.combinations(all_possible_edges, r):
            G = Graph(vertices, set(edge_combo))
            # Check connectivity
            if n <= 1:
                yield G
                continue
            visited = set()
            stack = [0]
            while stack:
                v = stack.pop()
                if v not in visited:
                    visited.add(v)
                    stack.extend(G.neighbors(v) - visited)
            if len(visited) == n:
                yield G


def generate_filtrations(vertices: set, q, max_stages=None):
    """Generate all increasing filtrations of vertices \ {q}.

    Each filtration is a sequence [∅, S_1, ..., S_m] where each S_i ⊆ V\{q}
    and S_i ⊆ S_{i+1}, adding one vertex at a time.
    """
    available = sorted(vertices - {q})
    if not available:
        yield [set()]
        return

    # Generate all permutations (orderings of vertex additions)
    for perm in itertools.permutations(available):
        filtration = [set()]
        for v in perm:
            filtration.append(filtration[-1] | {v})
        yield filtration


def test_conjecture_A(max_n=5):
    """Test Conjecture A: strict refinement over ordinary persistence.

    Search for pairs of filtrations with identical H₁ barcodes but
    distinct tropical barcodes.
    """
    print_header("CONJECTURE A TEST: Strict Refinement")
    print(f"  Searching graphs on n ≤ {max_n} vertices...")

    found_examples = []

    for n in range(3, max_n + 1):
        count = 0
        for G in generate_connected_graphs(n):
            count += 1
            for q in range(n):
                # Collect (H1_seq, tropical_seq) pairs for all filtrations
                barcode_map = defaultdict(list)  # H1_seq -> list of tropical_seqs

                for filt in generate_filtrations(G.vertices, q):
                    h1_seq = tuple(induced_cycle_rank(G, S) for S in filt)
                    trop_seq = tuple(tropical_kernel_dim(G, q, S) for S in filt)
                    barcode_map[h1_seq].append((trop_seq, filt))

                # Look for same H₁ but different tropical
                for h1_seq, entries in barcode_map.items():
                    trop_seqs = set(e[0] for e in entries)
                    if len(trop_seqs) > 1:
                        found_examples.append((n, sorted(G.edges), q, entries[:2]))
                        if len(found_examples) <= 3:
                            print(f"\n  ★ Example found! n={n}, q={q}")
                            print(f"    Edges: {sorted(G.edges)}")
                            for tseq, filt in entries[:2]:
                                print(f"    H₁={h1_seq}, tropical={tseq}")
                                print(f"      Filtration: {[sorted(s) for s in filt]}")

        print(f"  n={n}: checked {count} connected graphs")

    if found_examples:
        print(f"\n  RESULT: Conjecture A CONFIRMED — found {len(found_examples)} examples")
    else:
        print(f"\n  RESULT: No counterexamples found (conjecture remains open for n ≤ {max_n})")


def test_conjecture_B(max_n=5):
    """Test Conjecture B: monotonicity under q-anchored filtrations.

    A filtration is q-anchored if every new vertex is adjacent to the
    current set or to q.
    """
    print_header("CONJECTURE B TEST: Monotonicity Under Anchoring")
    print(f"  Searching graphs on n ≤ {max_n} vertices...")

    violations = []

    for n in range(3, max_n + 1):
        count = 0
        for G in generate_connected_graphs(n):
            count += 1
            for q in range(n):
                for filt in generate_filtrations(G.vertices, q):
                    # Check if filtration is q-anchored
                    is_anchored = True
                    for k in range(1, len(filt)):
                        new_verts = filt[k] - filt[k-1]
                        for v in new_verts:
                            # v must be adjacent to filt[k-1] or to q
                            adj_to_filt = any(u in G.neighbors(v) for u in filt[k-1])
                            adj_to_q = q in G.neighbors(v)
                            if not adj_to_filt and not adj_to_q:
                                is_anchored = False
                                break
                        if not is_anchored:
                            break

                    if not is_anchored:
                        continue

                    # Check monotonicity
                    dims = compute_dims(G, q, filt)
                    for k in range(len(dims) - 1):
                        if dims[k+1] < dims[k]:
                            violations.append((n, sorted(G.edges), q, filt, dims))
                            break

        print(f"  n={n}: checked {count} connected graphs")

    if violations:
        print(f"\n  RESULT: Conjecture B VIOLATED — found {len(violations)} counterexamples")
        for n, edges, q, filt, dims in violations[:3]:
            print(f"    n={n}, q={q}, edges={edges}")
            print(f"    dims={dims}")
    else:
        print(f"\n  RESULT: Conjecture B CONFIRMED for all n ≤ {max_n}")


def demo_comprehensive():
    """Run comprehensive demo with multiple graph families."""
    print_header("COMPREHENSIVE DEMO: Multiple Graph Families")

    examples = [
        ("Path P_5", path_graph(5), 0,
         [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}]),
        ("Cycle C_5", cycle_graph(5), 0,
         [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}]),
        ("Complete K_4", complete_graph(4), 0,
         [set(), {1}, {1,2}, {1,2,3}]),
        ("Star S_4", star_graph(4), 0,
         [set(), {1}, {1,2}, {1,2,3}]),
    ]

    for label, G, q, filt in examples:
        dims, events = demonstrate_single_filtration(G, q, filt, label)
        ok, _, _ = verify_barcode_correctness(G, q, filt)
        print(f"  Barcode reconstruction verified: {ok}")


def demo_network_application():
    """Demonstrate network accessibility interpretation."""
    print_header("APPLICATION: Network Accessibility Analysis")
    print("  Consider a communication network with a central hub (q=0).")
    print("  As we 'activate' nodes one by one, the tropical barcode tracks")
    print("  both redundancy (cycles) and hub accessibility (visibility).\n")

    # Small network: hub at 0, with clusters
    V = {0, 1, 2, 3, 4, 5}
    E = {(0, 1), (0, 2), (1, 3), (2, 4), (3, 4), (4, 5)}
    G = Graph(V, E)
    q = 0

    print(f"  Network: {sorted(G.edges)}")
    print(f"  Hub (q): {q}")
    print()

    # Activate nodes in order of distance from hub
    filtration = [set(), {1}, {1, 2}, {1, 2, 3}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}]
    dims, events = demonstrate_single_filtration(
        G, q, filtration, "Network activation order"
    )

    print("\n  INTERPRETATION:")
    for k, e in enumerate(events):
        interpretation = []
        if e.cycle_birth > 0:
            interpretation.append(f"{e.cycle_birth} redundant path(s) created")
        if e.q_visible_birth > 0:
            interpretation.append(f"{e.q_visible_birth} new hub-accessible cluster(s)")
        if e.invisible_merge_death > 0:
            interpretation.append(f"{e.invisible_merge_death} isolated cluster(s) absorbed")
        if not interpretation:
            interpretation.append("neutral step")
        print(f"    Step {k}→{k+1}: {'; '.join(interpretation)}")


if __name__ == "__main__":
    if "--test-conjectures" in sys.argv:
        max_n = 5
        for i, arg in enumerate(sys.argv):
            if arg == "--max-n" and i + 1 < len(sys.argv):
                max_n = int(sys.argv[i + 1])
        test_conjecture_A(max_n)
        test_conjecture_B(max_n)
    elif "--graph" in sys.argv:
        idx = sys.argv.index("--graph")
        gtype = sys.argv[idx + 1] if idx + 1 < len(sys.argv) else "cycle"
        n = int(sys.argv[idx + 2]) if idx + 2 < len(sys.argv) else 5

        builders = {
            "cycle": cycle_graph, "path": path_graph,
            "complete": complete_graph, "star": star_graph
        }
        G = builders.get(gtype, cycle_graph)(n)
        q = 0
        available = sorted(G.vertices - {q})
        filtration = [set()]
        for v in available:
            filtration.append(filtration[-1] | {v})

        demonstrate_single_filtration(G, q, filtration, f"{gtype.title()} graph, n={n}")
    else:
        demo_visibility_matters()
        demo_cycle_and_visibility()
        demo_distinguishing_filtrations()
        demo_comprehensive()
        demo_network_application()
        print("\n" + "="*70)
        print("  Run with --test-conjectures to test on all small graphs")
        print("="*70)


"""
Visualization: Tropical vs Ordinary Barcode Comparison

This script creates a side-by-side comparison of ordinary cycle persistence
(H₁ barcode) and the tropical persistence barcode, showing that the tropical
version captures strictly more information.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (
    Graph, tropical_kernel_dim, induced_cycle_rank,
    q_visible_component_count, compute_tropical_barcode,
    compute_dims
)

# Graph: square with two pendants
V = {0, 1, 2, 3, 4, 5}
E = {(0, 1), (1, 2), (2, 3), (0, 3), (0, 4), (2, 5)}
G = Graph(V, E)
q = 0

# Two filtrations with same H₁ but (potentially) different tropical barcodes
filt_A = [set(), {1}, {1, 4}, {1, 3, 4}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}]
filt_B = [set(), {4}, {1, 4}, {1, 3, 4}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}]

h1_A = [induced_cycle_rank(G, S) for S in filt_A]
h1_B = [induced_cycle_rank(G, S) for S in filt_B]
trop_A = compute_dims(G, q, filt_A)
trop_B = compute_dims(G, q, filt_B)
vis_A = [q_visible_component_count(G, q, S) for S in filt_A]
vis_B = [q_visible_component_count(G, q, S) for S in filt_B]

events_A = compute_tropical_barcode(G, q, filt_A)
events_B = compute_tropical_barcode(G, q, filt_B)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

steps = range(len(filt_A))

# Top left: H₁ comparison
axes[0, 0].plot(steps, h1_A, 'bo-', linewidth=2, markersize=8, label='Filtration A')
axes[0, 0].plot(steps, h1_B, 'rs--', linewidth=2, markersize=8, label='Filtration B')
axes[0, 0].set_title('Ordinary Cycle Rank β₁', fontsize=13, fontweight='bold')
axes[0, 0].set_xlabel('Filtration Step')
axes[0, 0].set_ylabel('β₁(G[S])')
axes[0, 0].legend()
axes[0, 0].set_ylim(-0.5, max(max(h1_A), max(h1_B)) + 1)
axes[0, 0].grid(True, alpha=0.3)

# Top right: Tropical dimension comparison
axes[0, 1].plot(steps, trop_A, 'bo-', linewidth=2, markersize=8, label='Filtration A')
axes[0, 1].plot(steps, trop_B, 'rs--', linewidth=2, markersize=8, label='Filtration B')
axes[0, 1].set_title('Tropical Kernel Dimension δ', fontsize=13, fontweight='bold')
axes[0, 1].set_xlabel('Filtration Step')
axes[0, 1].set_ylabel('δ(S) = β₁ + κ_q')
axes[0, 1].legend()
axes[0, 1].set_ylim(-0.5, max(max(trop_A), max(trop_B)) + 1)
axes[0, 1].grid(True, alpha=0.3)

# Bottom left: Visibility component
axes[1, 0].plot(steps, vis_A, 'g^-', linewidth=2, markersize=8, label='Filtration A')
axes[1, 0].plot(steps, vis_B, 'mv--', linewidth=2, markersize=8, label='Filtration B')
axes[1, 0].set_title('q-Visible Components κ_q', fontsize=13, fontweight='bold')
axes[1, 0].set_xlabel('Filtration Step')
axes[1, 0].set_ylabel('κ_q(S)')
axes[1, 0].legend()
axes[1, 0].set_ylim(-0.5, max(max(vis_A), max(vis_B)) + 1)
axes[1, 0].grid(True, alpha=0.3)

# Bottom right: Event barcode visualization
event_steps = np.arange(len(events_A))
width = 0.35
bars_A_cycle = [e.cycle_birth for e in events_A]
bars_A_vis = [e.q_visible_birth for e in events_A]
bars_A_death = [-e.invisible_merge_death for e in events_A]

axes[1, 1].bar(event_steps - width/2, bars_A_cycle, width, color='steelblue',
               label='Cycle births (A)', alpha=0.8)
axes[1, 1].bar(event_steps - width/2, bars_A_vis, width, bottom=bars_A_cycle,
               color='forestgreen', label='Vis. births (A)', alpha=0.8)
axes[1, 1].bar(event_steps - width/2, bars_A_death, width, color='indianred',
               label='Merges (A)', alpha=0.8)

bars_B_cycle = [e.cycle_birth for e in events_B]
bars_B_vis = [e.q_visible_birth for e in events_B]
bars_B_death = [-e.invisible_merge_death for e in events_B]

axes[1, 1].bar(event_steps + width/2, bars_B_cycle, width, color='steelblue',
               alpha=0.4, hatch='//')
axes[1, 1].bar(event_steps + width/2, bars_B_vis, width, bottom=bars_B_cycle,
               color='forestgreen', alpha=0.4, hatch='//', label='Vis. births (B)')
axes[1, 1].bar(event_steps + width/2, bars_B_death, width, color='indianred',
               alpha=0.4, hatch='//', label='Merges (B)')

axes[1, 1].set_title('Event Barcode Decomposition', fontsize=13, fontweight='bold')
axes[1, 1].set_xlabel('Transition')
axes[1, 1].set_ylabel('Event Count')
axes[1, 1].legend(fontsize=8)
axes[1, 1].grid(True, alpha=0.3)

fig.suptitle('Tropical Persistence vs Ordinary Cycle Persistence\n'
             f'Graph: square + 2 pendants, q={q}',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_barcode_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_barcode_comparison.png")


"""
Visualization: Tropical Kernel Dimension Landscape

This script creates a heatmap showing how the tropical kernel dimension
varies across different basepoint choices and filtration stages for a
fixed graph. It reveals the basepoint-sensitivity of the tropical
persistence barcode.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (
    Graph, tropical_kernel_dim, induced_cycle_rank,
    q_visible_component_count
)

# Build a moderately interesting graph
# Petersen-like: 8 vertices with mixed connectivity
V = set(range(8))
E = {
    (0, 1), (1, 2), (2, 3), (3, 0),  # outer square
    (4, 5), (5, 6), (6, 7), (7, 4),  # inner square
    (0, 4), (1, 5), (2, 6), (3, 7),  # connecting spokes
}
G = Graph(V, E)

# For each basepoint q, compute dimension sequence along canonical filtration
n = len(V)
basepoints = list(range(n))

# Use a canonical filtration that adds vertices 0,1,...,n-1 (excluding q)
dim_matrix = np.zeros((n, n), dtype=int)  # basepoint x filtration_step
cr_matrix = np.zeros((n, n), dtype=int)
qv_matrix = np.zeros((n, n), dtype=int)

for qi, q in enumerate(basepoints):
    available = sorted(V - {q})
    filt = [set()]
    for v in available:
        filt.append(filt[-1] | {v})

    for step, S in enumerate(filt):
        if step < n:
            dim_matrix[qi, step] = tropical_kernel_dim(G, q, S)
            cr_matrix[qi, step] = induced_cycle_rank(G, S)
            qv_matrix[qi, step] = q_visible_component_count(G, q, S)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Tropical kernel dimension
im0 = axes[0].imshow(dim_matrix, cmap='YlOrRd', aspect='auto', interpolation='nearest')
axes[0].set_title('Tropical Kernel Dimension δ(S)', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Filtration Step')
axes[0].set_ylabel('Basepoint q')
axes[0].set_yticks(range(n))
plt.colorbar(im0, ax=axes[0], label='δ')

# Cycle rank component
im1 = axes[1].imshow(cr_matrix, cmap='Blues', aspect='auto', interpolation='nearest')
axes[1].set_title('Cycle Rank β₁(G[S])', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Filtration Step')
axes[1].set_ylabel('Basepoint q')
axes[1].set_yticks(range(n))
plt.colorbar(im1, ax=axes[1], label='β₁')

# q-Visible component count
im2 = axes[2].imshow(qv_matrix, cmap='Greens', aspect='auto', interpolation='nearest')
axes[2].set_title('q-Visible Components κ_q(S)', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Filtration Step')
axes[2].set_ylabel('Basepoint q')
axes[2].set_yticks(range(n))
plt.colorbar(im2, ax=axes[2], label='κ_q')

fig.suptitle('Basepoint-Sensitive Tropical Persistence Landscape\n'
             '(Cube Graph: 8 vertices, 12 edges)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_dimension_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_dimension_landscape.png")


"""
Visualization: Event Decomposition Along a Filtration

Shows how the tropical kernel dimension evolves along a filtration,
decomposed into its cycle rank and visibility components, with
event annotations marking births and deaths.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (
    Graph, tropical_kernel_dim, induced_cycle_rank,
    q_visible_component_count, compute_tropical_barcode,
    compute_dims
)

# Interesting graph: two triangles sharing a vertex, plus a pendant
V = {0, 1, 2, 3, 4, 5, 6}
E = {
    (0, 1), (0, 2), (1, 2),     # Triangle 1
    (2, 3), (2, 4), (3, 4),     # Triangle 2
    (0, 5), (5, 6),             # Pendant chain
}
G = Graph(V, E)
q = 0

filt = [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}, {1,2,3,4,5}, {1,2,3,4,5,6}]

dims = compute_dims(G, q, filt)
cr_seq = [induced_cycle_rank(G, S) for S in filt]
vis_seq = [q_visible_component_count(G, q, S) for S in filt]
events = compute_tropical_barcode(G, q, filt)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 9), gridspec_kw={'height_ratios': [2, 1]})

steps = np.arange(len(filt))

# Top: Stacked area chart showing decomposition
ax1.fill_between(steps, 0, cr_seq, alpha=0.4, color='steelblue', label='Cycle Rank β₁')
ax1.fill_between(steps, cr_seq, dims, alpha=0.4, color='forestgreen', label='q-Visible κ_q')
ax1.plot(steps, dims, 'ko-', linewidth=2.5, markersize=8, label='Total δ = β₁ + κ_q', zorder=5)
ax1.plot(steps, cr_seq, 'b--', linewidth=1.5, alpha=0.7)

# Annotate events
for k, e in enumerate(events):
    x = k + 0.5
    y = max(dims[k], dims[k+1]) + 0.15
    annotations = []
    if e.cycle_birth > 0:
        annotations.append(f'+{e.cycle_birth}🔄')
    if e.q_visible_birth > 0:
        annotations.append(f'+{e.q_visible_birth}👁')
    if e.invisible_merge_death > 0:
        annotations.append(f'-{e.invisible_merge_death}⊕')
    if annotations:
        ax1.annotate(' '.join(annotations), (x, y),
                    fontsize=11, ha='center', va='bottom',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

ax1.set_title('Tropical Kernel Dimension: Decomposition Along Filtration',
             fontsize=14, fontweight='bold')
ax1.set_xlabel('Filtration Step', fontsize=12)
ax1.set_ylabel('Dimension', fontsize=12)
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xticks(steps)
ax1.set_xticklabels([f'S_{k}\n{str(sorted(S))[:20]}' for k, S in enumerate(filt)],
                    fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.3, max(dims) + 1.5)

# Bottom: Event bar chart
event_x = np.arange(len(events))
width = 0.25
bars_cycle = [e.cycle_birth for e in events]
bars_vis = [e.q_visible_birth for e in events]
bars_death = [-e.invisible_merge_death for e in events]
bars_delta = [e.delta for e in events]

ax2.bar(event_x - width, bars_cycle, width, color='steelblue', label='Cycle Birth', alpha=0.8)
ax2.bar(event_x, bars_vis, width, color='forestgreen', label='Visibility Birth', alpha=0.8)
ax2.bar(event_x + width, bars_death, width, color='indianred', label='Invisible Merge Death', alpha=0.8)
ax2.plot(event_x, bars_delta, 'k^-', markersize=10, linewidth=1.5, label='Net Δ', zorder=5)

ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_title('Event Decomposition per Step', fontsize=13, fontweight='bold')
ax2.set_xlabel('Transition', fontsize=12)
ax2.set_ylabel('Event Count', fontsize=12)
ax2.set_xticks(event_x)
ax2.set_xticklabels([f'{k}→{k+1}' for k in range(len(events))], fontsize=10)
ax2.legend(fontsize=9, ncol=4)
ax2.grid(True, alpha=0.3)

fig.suptitle(f'Tropical Persistence Barcode Analysis\n'
             f'Graph: two triangles + pendant, basepoint q={q}',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_event_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved: viz_event_decomposition.png")
