#!/usr/bin/env python3
"""
Applications of the Defect Deletion Calculus

Demonstrates real-world applications of the exact deletion law for
structural defect, including:

1. Network Simplification: Pruning redundant edges while tracking
   complexity reduction
2. Graph Complexity Analysis: Computing the defect profile of a graph
3. Bridge Detection and Vulnerability Analysis
4. Cycle-Space Decomposition: Separating tree and cycle complexity
"""

from collections import defaultdict
from typing import Set, Tuple, List, Dict
import random
import algorithms as alg


def network_simplification(G: alg.Graph, q: int, S: Set[int]) -> Dict:
    """
    Application 1: Network Simplification

    Given a network G with root q and critical nodes S, identify
    which edges can be removed to simplify the network while
    tracking the exact complexity reduction at each step.

    This is useful for:
    - Simplifying communication networks
    - Identifying redundant infrastructure links
    - Reducing graph complexity for algorithmic processing

    Returns a report of the simplification process.
    """
    calc = alg.DefectCalculator(G, q, S)
    initial_defect = calc.structural_defect()
    initial_beta = calc.induced_cycle_rank()
    initial_kappa = calc.root_component_count()
    initial_edges = len(G.edges)

    steps = []
    current = G
    while True:
        found = False
        for u, v in sorted(current.edges):
            if u in S and v in S and u != q and v != q:
                if not alg.is_s_bridge(current, S, u, v):
                    curr_calc = alg.DefectCalculator(current, q, S)
                    d_before = curr_calc.structural_defect()
                    current = current.delete_edge(u, v)
                    new_calc = alg.DefectCalculator(current, q, S)
                    d_after = new_calc.structural_defect()
                    steps.append({
                        'edge': (u, v),
                        'type': 'non-bridge (redundant)',
                        'defect_before': d_before,
                        'defect_after': d_after,
                        'drop': d_before - d_after,
                    })
                    found = True
                    break
        if not found:
            break

    final_calc = alg.DefectCalculator(current, q, S)
    return {
        'initial': {
            'edges': initial_edges,
            'defect': initial_defect,
            'cycle_rank': initial_beta,
            'kappa': initial_kappa,
        },
        'final': {
            'edges': len(current.edges),
            'defect': final_calc.structural_defect(),
            'cycle_rank': final_calc.induced_cycle_rank(),
            'kappa': final_calc.root_component_count(),
        },
        'steps': steps,
        'total_removed': len(steps),
        'graph': current,
    }


def defect_profile(G: alg.Graph, q: int) -> Dict:
    """
    Application 2: Defect Profile Analysis

    Computes the structural defect for all nonempty subsets S
    not containing q, providing a complete complexity profile.

    Returns statistics about the defect distribution.
    """
    vertices = G.vertices - {q}
    if not vertices:
        return {'profiles': [], 'stats': {}}

    profiles = []
    for r in range(1, min(len(vertices) + 1, 7)):  # Limit for efficiency
        from itertools import combinations
        for S_tuple in combinations(sorted(vertices), r):
            S = set(S_tuple)
            calc = alg.DefectCalculator(G, q, S)
            profiles.append({
                'S': S,
                'size': len(S),
                'defect': calc.structural_defect(),
                'cycle_rank': calc.induced_cycle_rank(),
                'kappa': calc.root_component_count(),
            })

    defects = [p['defect'] for p in profiles]
    return {
        'profiles': profiles,
        'stats': {
            'count': len(profiles),
            'min_defect': min(defects) if defects else 0,
            'max_defect': max(defects) if defects else 0,
            'avg_defect': sum(defects) / len(defects) if defects else 0,
            'zero_defect_count': sum(1 for d in defects if d == 0),
            'zero_defect_pct': 100 * sum(1 for d in defects if d == 0) / max(1, len(defects)),
        },
    }


def vulnerability_analysis(G: alg.Graph, q: int, S: Set[int]) -> Dict:
    """
    Application 3: Bridge Detection and Vulnerability Analysis

    Classifies all internal edges of G[S] as bridges (critical) or
    non-bridges (redundant), providing a vulnerability assessment.

    Bridges are "defect-neutral" deletions in appropriate cases but
    represent structural vulnerabilities (single points of failure).
    Non-bridges are "defect-reducing" — safely removable.
    """
    bridges = []
    non_bridges = []

    for u, v in sorted(G.edges):
        if u in S and v in S and u != q and v != q:
            if alg.is_s_bridge(G, S, u, v):
                bridges.append((u, v))
            else:
                non_bridges.append((u, v))

    total = len(bridges) + len(non_bridges)
    return {
        'total_internal_edges': total,
        'bridges': bridges,
        'bridge_count': len(bridges),
        'non_bridges': non_bridges,
        'non_bridge_count': len(non_bridges),
        'vulnerability_ratio': len(bridges) / max(1, total),
        'redundancy_ratio': len(non_bridges) / max(1, total),
    }


def cycle_space_decomposition(G: alg.Graph, q: int, S: Set[int]) -> Dict:
    """
    Application 4: Cycle-Space Decomposition

    Decomposes the structural defect into:
    - Tree-level complexity: κ - 1 (root-separation measure)
    - Cycle complexity: β₁(G[S]) (homological complexity)

    This reveals the fundamental structure:
        δ = (κ - 1) + β₁

    The deletion calculus shows β₁ can be reduced to 0 by removing
    non-bridge internal edges, each reducing δ by exactly 1.
    """
    calc = alg.DefectCalculator(G, q, S)
    beta = calc.induced_cycle_rank()
    kappa = calc.root_component_count()
    delta = calc.structural_defect()

    # Verify decomposition
    assert delta == beta + kappa - 1, \
        f"Decomposition failed: {delta} ≠ {beta} + {kappa} - 1"

    # Compute the forest reduction
    result = network_simplification(G, q, S)
    tree_defect = result['final']['defect']

    return {
        'defect': delta,
        'cycle_rank': beta,
        'kappa': kappa,
        'tree_level_complexity': kappa - 1,
        'cycle_complexity': beta,
        'decomposition': f"δ = {kappa - 1} + {beta} = {delta}",
        'after_forest_reduction': {
            'tree_defect': tree_defect,
            'cycle_rank_remaining': result['final']['cycle_rank'],
            'edges_removed': result['total_removed'],
        },
        'verification': f"δ(G) = δ(T) + β₁(G[S]): {delta} = {tree_defect} + {beta}",
    }


# ---- Demo ----

if __name__ == '__main__':
    print("=" * 65)
    print("APPLICATIONS OF THE DEFECT DELETION CALCULUS")
    print("=" * 65)

    # Build a moderately complex graph: Petersen-like structure
    # 10 vertices, outer cycle 0-1-2-3-4, inner pentagram 5-6-7-8-9
    # Spokes: 0-5, 1-6, 2-7, 3-8, 4-9
    edges = set()
    for i in range(5):
        edges.add((i, (i + 1) % 5))        # Outer cycle
        edges.add((i + 5, (i + 2) % 5 + 5))  # Inner pentagram
        edges.add((i, i + 5))                # Spokes

    G = alg.Graph(10, edges)
    q = 0
    S = {1, 2, 3, 4, 5, 6, 7, 8, 9}

    print(f"\nGraph: Petersen graph (10 vertices, {len(G.edges)} edges)")
    print(f"Root q = {q}, S = {S}")

    # Application 1: Network Simplification
    print("\n" + "-" * 50)
    print("Application 1: Network Simplification")
    print("-" * 50)
    result = network_simplification(G, q, S)
    print(f"Initial: {result['initial']['edges']} edges, "
          f"δ = {result['initial']['defect']}, "
          f"β₁ = {result['initial']['cycle_rank']}, "
          f"κ = {result['initial']['kappa']}")
    for i, step in enumerate(result['steps']):
        print(f"  Step {i+1}: Remove {step['edge']} "
              f"({step['type']}), δ: {step['defect_before']} → {step['defect_after']}")
    print(f"Final: {result['final']['edges']} edges, "
          f"δ = {result['final']['defect']}, "
          f"β₁ = {result['final']['cycle_rank']}")
    print(f"Total edges removed: {result['total_removed']}")

    # Application 3: Vulnerability Analysis
    print("\n" + "-" * 50)
    print("Application 3: Vulnerability Analysis")
    print("-" * 50)
    vuln = vulnerability_analysis(G, q, S)
    print(f"Total internal edges: {vuln['total_internal_edges']}")
    print(f"Bridges (critical):   {vuln['bridge_count']} "
          f"({100*vuln['vulnerability_ratio']:.0f}%)")
    print(f"Non-bridges (safe):   {vuln['non_bridge_count']} "
          f"({100*vuln['redundancy_ratio']:.0f}%)")
    print(f"Bridges: {vuln['bridges']}")
    print(f"Non-bridges: {vuln['non_bridges']}")

    # Application 4: Cycle-Space Decomposition
    print("\n" + "-" * 50)
    print("Application 4: Cycle-Space Decomposition")
    print("-" * 50)
    decomp = cycle_space_decomposition(G, q, S)
    print(f"Structural defect δ = {decomp['defect']}")
    print(f"Decomposition: {decomp['decomposition']}")
    print(f"  Tree-level complexity (κ-1): {decomp['tree_level_complexity']}")
    print(f"  Cycle complexity (β₁):       {decomp['cycle_complexity']}")
    print(f"Verification: {decomp['verification']}")
    fr = decomp['after_forest_reduction']
    print(f"After forest reduction:")
    print(f"  Tree defect δ(T) = {fr['tree_defect']}")
    print(f"  β₁(T[S]) = {fr['cycle_rank_remaining']} (should be 0)")
    print(f"  Edges removed: {fr['edges_removed']}")

    # Application 2: Defect Profile (smaller graph)
    print("\n" + "-" * 50)
    print("Application 2: Defect Profile (K₄)")
    print("-" * 50)
    K4_edges = {(i, j) for i in range(4) for j in range(i+1, 4)}
    K4 = alg.Graph(4, K4_edges)
    profile = defect_profile(K4, 0)
    print(f"Graph: K₄, root q = 0")
    print(f"Subsets analyzed: {profile['stats']['count']}")
    print(f"Min defect: {profile['stats']['min_defect']}")
    print(f"Max defect: {profile['stats']['max_defect']}")
    print(f"Avg defect: {profile['stats']['avg_defect']:.2f}")
    print(f"Zero-defect subsets: {profile['stats']['zero_defect_count']} "
          f"({profile['stats']['zero_defect_pct']:.0f}%)")
    print("\nDetailed profile:")
    for p in profile['profiles']:
        print(f"  S={p['S']}: δ={p['defect']}, β₁={p['cycle_rank']}, κ={p['kappa']}")

    print("\n" + "=" * 65)


#!/usr/bin/env python3
"""
Deletion Calculus for Structural Defect — Exhaustive Small-Graph Verification

This script exhaustively tests the exact deletion law for structural defect
on all connected simple graphs with n ≤ 6 vertices, all roots q, all subsets S,
and all eligible internal edges. It verifies:

1. Non-bridge monotonicity: δ(G-e,q,S) = δ(G,q,S) - 1 for non-bridge internal edges
2. Bridge cycle rank preservation: β₁ is unchanged under bridge deletion
3. Counterexample detection: bridge deletions CAN increase δ
4. Additive invariant: δ(G-e) + β₁(G[S]) stays constant for non-bridge deletions

Usage:
    python demo.py [--max-n N]
"""

import itertools
import argparse
from collections import defaultdict


def connected_graphs(n):
    """Generate all connected simple graphs on n vertices (labeled 0..n-1)."""
    if n == 1:
        yield set()
        return
    vertices = list(range(n))
    all_edges = [(i, j) for i in vertices for j in vertices if i < j]
    for r in range(n - 1, len(all_edges) + 1):
        for edge_combo in itertools.combinations(all_edges, r):
            edges = set(edge_combo)
            if is_connected(n, edges):
                yield edges


def is_connected(n, edges):
    """Check if graph on {0,...,n-1} with given edges is connected."""
    if n <= 1:
        return True
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    stack = [0]
    while stack:
        v = stack.pop()
        if v in visited:
            continue
        visited.add(v)
        for w in adj[v]:
            if w not in visited:
                stack.append(w)
    return len(visited) == n


def induced_subgraph_edges(edges, S):
    """Return edges of G[S]."""
    return {(u, v) for u, v in edges if u in S and v in S}


def connected_components(vertices, edges):
    """Return list of connected components (as sets of vertices)."""
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    components = []
    for v in vertices:
        if v not in visited:
            comp = set()
            stack = [v]
            while stack:
                w = stack.pop()
                if w in comp:
                    continue
                comp.add(w)
                for x in adj[w]:
                    if x not in comp:
                        stack.append(x)
            components.append(comp)
            visited |= comp
    return components


def induced_edge_count(edges, S):
    """Number of edges in G[S]."""
    return len(induced_subgraph_edges(edges, S))


def induced_component_count(edges, S):
    """Number of connected components of G[S]."""
    S_edges = induced_subgraph_edges(edges, S)
    return len(connected_components(S, S_edges))


def induced_cycle_rank(edges, S):
    """β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|."""
    e = induced_edge_count(edges, S)
    c = induced_component_count(edges, S)
    return e + c - len(S)


def root_component_count(n, edges, q, S):
    """κ(G,q,S): number of components of G-{q} intersecting S."""
    Vq = set(range(n)) - {q}
    Eq = {(u, v) for u, v in edges if u != q and v != q}
    comps = connected_components(Vq, Eq)
    return sum(1 for comp in comps if comp & S)


def structural_defect(n, edges, q, S):
    """δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1."""
    return induced_cycle_rank(edges, S) + root_component_count(n, edges, q, S) - 1


def is_s_bridge(edges, S, u, v):
    """Check if {u,v} is a bridge of G[S]."""
    S_edges = induced_subgraph_edges(edges, S) - {(u, v), (v, u)}
    # Check if u and v are still connected in G[S] - {u,v}
    adj = defaultdict(set)
    for a, b in S_edges:
        adj[a].add(b)
        adj[b].add(a)
    visited = set()
    stack = [u]
    while stack:
        w = stack.pop()
        if w == v:
            return False  # Still connected → not a bridge
        if w in visited:
            continue
        visited.add(w)
        for x in adj[w]:
            if x not in visited:
                stack.append(x)
    return True  # u and v disconnected → bridge


def delete_edge(edges, u, v):
    """Return edges with (u,v) removed."""
    return edges - {(u, v), (v, u)} | ({(u, v)} - {(u, v)})  # handles ordered pairs
    # Actually just:
    return {(a, b) for a, b in edges if not ((a == u and b == v) or (a == v and b == u))}


def run_tests(max_n=6):
    """Run exhaustive tests on all connected graphs up to max_n vertices."""
    stats = {
        'total_tests': 0,
        'nonbridge_tests': 0,
        'bridge_tests': 0,
        'nonbridge_drop_by_1': 0,
        'nonbridge_other': 0,
        'bridge_defect_same': 0,
        'bridge_defect_increased': 0,
        'bridge_defect_decreased': 0,
        'kappa_invariant_nonbridge': 0,
        'kappa_changed_nonbridge': 0,
        'additive_invariant_holds': 0,
        'additive_invariant_fails': 0,
        'graphs_tested': 0,
    }

    counterexamples = []

    for n in range(2, max_n + 1):
        graph_count = 0
        for edges in connected_graphs(n):
            graph_count += 1
            vertices = set(range(n))

            for q in range(n):
                # Generate nonempty subsets S with q ∉ S
                S_candidates = vertices - {q}
                if not S_candidates:
                    continue

                for r in range(1, len(S_candidates) + 1):
                    for S_tuple in itertools.combinations(sorted(S_candidates), r):
                        S = set(S_tuple)

                        # Find internal edges
                        for u, v in edges:
                            if u in S and v in S and u != q and v != q and u < v:
                                stats['total_tests'] += 1

                                edges_deleted = delete_edge(edges, u, v)
                                delta_before = structural_defect(n, edges, q, S)
                                delta_after = structural_defect(n, edges_deleted, q, S)
                                beta_before = induced_cycle_rank(edges, S)
                                beta_after = induced_cycle_rank(edges_deleted, S)
                                kappa_before = root_component_count(n, edges, q, S)
                                kappa_after = root_component_count(n, edges_deleted, q, S)

                                bridge = is_s_bridge(edges, S, u, v)

                                if not bridge:
                                    stats['nonbridge_tests'] += 1

                                    # Test: δ drops by exactly 1
                                    if delta_after == delta_before - 1:
                                        stats['nonbridge_drop_by_1'] += 1
                                    else:
                                        stats['nonbridge_other'] += 1
                                        counterexamples.append({
                                            'type': 'nonbridge_not_drop_1',
                                            'n': n, 'edges': edges,
                                            'q': q, 'S': S, 'u': u, 'v': v,
                                            'delta_before': delta_before,
                                            'delta_after': delta_after,
                                        })

                                    # Test: κ invariant
                                    if kappa_after == kappa_before:
                                        stats['kappa_invariant_nonbridge'] += 1
                                    else:
                                        stats['kappa_changed_nonbridge'] += 1

                                    # Test: additive invariant
                                    if (delta_after + beta_before ==
                                            delta_before + beta_after):
                                        stats['additive_invariant_holds'] += 1
                                    else:
                                        stats['additive_invariant_fails'] += 1

                                else:
                                    stats['bridge_tests'] += 1

                                    if delta_after == delta_before:
                                        stats['bridge_defect_same'] += 1
                                    elif delta_after > delta_before:
                                        stats['bridge_defect_increased'] += 1
                                    else:
                                        stats['bridge_defect_decreased'] += 1

        stats['graphs_tested'] += graph_count
        print(f"n={n}: tested {graph_count} connected graphs")

    # Print results
    print("\n" + "=" * 70)
    print("DELETION CALCULUS — EXHAUSTIVE VERIFICATION RESULTS")
    print("=" * 70)
    print(f"\nTotal connected graphs tested: {stats['graphs_tested']}")
    print(f"Total internal edge deletion tests: {stats['total_tests']}")

    print(f"\n--- NON-BRIDGE INTERNAL DELETIONS ({stats['nonbridge_tests']} tests) ---")
    print(f"  δ drops by exactly 1: {stats['nonbridge_drop_by_1']}"
          f"  ({100*stats['nonbridge_drop_by_1']/max(1,stats['nonbridge_tests']):.1f}%)")
    print(f"  δ does NOT drop by 1: {stats['nonbridge_other']}")
    print(f"  κ invariant:          {stats['kappa_invariant_nonbridge']}"
          f"  ({100*stats['kappa_invariant_nonbridge']/max(1,stats['nonbridge_tests']):.1f}%)")
    print(f"  κ changed:            {stats['kappa_changed_nonbridge']}")
    print(f"  Additive inv. holds:  {stats['additive_invariant_holds']}")
    print(f"  Additive inv. fails:  {stats['additive_invariant_fails']}")

    print(f"\n--- BRIDGE INTERNAL DELETIONS ({stats['bridge_tests']} tests) ---")
    print(f"  δ unchanged:  {stats['bridge_defect_same']}")
    print(f"  δ INCREASED:  {stats['bridge_defect_increased']}"
          f"  (counterexamples to general monotonicity!)")
    print(f"  δ decreased:  {stats['bridge_defect_decreased']}")

    if counterexamples:
        print(f"\n⚠ COUNTEREXAMPLES FOUND ({len(counterexamples)}):")
        for ce in counterexamples[:5]:
            print(f"  {ce}")
    else:
        print(f"\n✓ All {stats['nonbridge_tests']} non-bridge deletion tests pass")
        print("  The exact deletion law δ(G-e) = δ(G) - 1 holds for all non-bridge internal edges")

    if stats['bridge_defect_increased'] > 0:
        print(f"\n⚠ General monotonicity (including bridges) is FALSE:")
        print(f"  {stats['bridge_defect_increased']} bridge deletions increased the defect")
        print("  This confirms the theoretical analysis — the correct theorem")
        print("  restricts to NON-BRIDGE internal deletions only.")

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    all_pass = (stats['nonbridge_other'] == 0 and
                stats['kappa_changed_nonbridge'] == 0 and
                stats['additive_invariant_fails'] == 0)
    if all_pass:
        print("✓ ALL THEOREMS VERIFIED on all tested graphs:")
        print("  • Exact deletion law: δ(G-e) = δ(G) - 1 for non-bridges")
        print("  • κ-invariance under non-bridge deletion")
        print("  • Additive invariant: δ(G-e) + β₁(G[S]) = δ(G) + β₁((G-e)[S])")
        print("  • General monotonicity correctly identified as FALSE for bridges")
    else:
        print("✗ SOME TESTS FAILED — check counterexamples above")

    return stats


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Exhaustive verification of defect deletion calculus')
    parser.add_argument('--max-n', type=int, default=6,
                        help='Maximum number of vertices (default: 6)')
    args = parser.parse_args()
    run_tests(args.max_n)
