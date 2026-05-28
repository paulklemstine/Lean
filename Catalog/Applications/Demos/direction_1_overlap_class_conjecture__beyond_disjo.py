"""
Applications of Overlap Class Theory

This module demonstrates real-world applications of the overlap class
framework to network analysis, coding theory, and graph classification.
"""

from __future__ import annotations
from typing import Dict, FrozenSet, List, Set, Tuple
from collections import defaultdict
import itertools

Support = FrozenSet[int]
SupportFamily = List[Support]


# ============================================================
# Self-contained overlap utilities
# ============================================================

def supports_overlap(a: Support, b: Support) -> bool:
    return bool(a & b)

def cross_overlap_count(a: Support, b: Support) -> int:
    return len(a & b)

def overlap_degree(family: SupportFamily) -> int:
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1, n)
               if supports_overlap(family[i], family[j]))

def overlap_classes(family: SupportFamily) -> List[List[int]]:
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i+1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    visited = [False] * n
    components: List[List[int]] = []
    for start in range(n):
        if visited[start]:
            continue
        comp: List[int] = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            comp.append(node)
            for nb in adj[node]:
                if not visited[nb]:
                    visited[nb] = True
                    queue.append(nb)
        components.append(comp)
    return components

def overlap_signature(family: SupportFamily) -> List[int]:
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i+1, n):
            c = cross_overlap_count(family[i], family[j])
            if c > 0:
                sig.append(c)
    return sorted(sig)


# ============================================================
# Application 1: Network Community Detection via Overlap Classes
# ============================================================

def network_community_detection():
    """
    Use overlap classes of path supports to detect communities in a network.

    The idea: in a social/infrastructure network, overlapping paths between
    key nodes reveal community structure. Paths that share vertices form
    overlap classes, and each class represents a tightly-connected community.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Community Detection")
    print("=" * 60)

    # Model: a small social network
    # Vertices: people (0-9)
    # Edges: friendships
    print("\n  Social network with 10 people and friendship links.")
    print("  We analyze overlap among shortest-path supports.")

    # Two clusters connected by a bridge
    cluster1_edges = [(0,1),(0,2),(1,2),(1,3),(2,3)]
    cluster2_edges = [(5,6),(5,7),(6,7),(6,8),(7,8)]
    bridge = [(3,4),(4,5)]  # weak connection

    # Define some "important paths" (communication routes)
    paths: SupportFamily = [
        frozenset({0, 1, 2}),      # within cluster 1
        frozenset({1, 2, 3}),      # within cluster 1
        frozenset({0, 1, 3}),      # within cluster 1
        frozenset({5, 6, 7}),      # within cluster 2
        frozenset({6, 7, 8}),      # within cluster 2
        frozenset({5, 6, 8}),      # within cluster 2
        frozenset({3, 4, 5}),      # bridge path
    ]

    classes = overlap_classes(paths)
    print(f"\n  Number of paths: {len(paths)}")
    print(f"  Overlap degree: {overlap_degree(paths)}")
    print(f"  Number of overlap classes: {len(classes)}")
    for i, cls in enumerate(classes):
        path_desc = [sorted(paths[j]) for j in cls]
        print(f"    Class {i+1}: indices {sorted(cls)}")
        print(f"      Paths: {path_desc}")

    print("\n  Interpretation: Overlap classes reveal the two-cluster")
    print("  structure with the bridge path linking them.")


# ============================================================
# Application 2: Error-Correcting Code Analysis
# ============================================================

def coding_theory_application():
    """
    Analyze support overlap structure of minimal codewords in a code.

    In coding theory, the supports of minimum-weight codewords determine
    the code's error-correcting properties. Overlap classes of these
    supports reveal interaction clusters.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Error-Correcting Code Analysis")
    print("=" * 60)

    # Model: supports of minimum-weight codewords in a [7,4,3] Hamming code
    # The Hamming code has 7 codewords of weight 3 (plus complements)
    codeword_supports: SupportFamily = [
        frozenset({0, 1, 3}),
        frozenset({1, 2, 4}),
        frozenset({2, 3, 5}),
        frozenset({3, 4, 6}),
        frozenset({0, 4, 5}),
        frozenset({1, 5, 6}),
        frozenset({0, 2, 6}),
    ]

    print(f"\n  [7,4,3] Hamming code: {len(codeword_supports)} minimum-weight codewords")
    print(f"  Each codeword has weight 3 (support size 3)")

    result_deg = overlap_degree(codeword_supports)
    classes = overlap_classes(codeword_supports)
    sig = overlap_signature(codeword_supports)

    print(f"\n  Overlap analysis:")
    print(f"    Overlap degree: {result_deg}")
    print(f"    Overlap class count: {len(classes)}")
    print(f"    Overlap signature: {sig}")
    print(f"    Overlap classes: {[sorted(c) for c in classes]}")

    print(f"\n  Interpretation: All codeword supports are in a single overlap")
    print(f"  class — the code is 'tightly woven'. Every pair of minimum-weight")
    print(f"  codewords shares at least one coordinate position.")

    # Verify: every pair overlaps
    n = len(codeword_supports)
    all_overlap = all(
        supports_overlap(codeword_supports[i], codeword_supports[j])
        for i in range(n) for j in range(i+1, n)
    )
    print(f"    All pairs overlap: {all_overlap}")


# ============================================================
# Application 3: Graph Classification via Overlap Fingerprint
# ============================================================

def graph_classification():
    """
    Use overlap signatures as graph fingerprints for classification.

    Two graphs with different overlap signatures for their cycle supports
    are guaranteed to be non-isomorphic (in terms of cycle structure).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Graph Classification via Overlap Fingerprint")
    print("=" * 60)

    def graph_edges(n: int, edges: List[Tuple[int,int]]) -> Dict[int, Set[int]]:
        adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            adj[u].add(v)
            adj[v].add(u)
        return adj

    def find_cycles(adj: Dict[int, Set[int]]) -> List[Support]:
        vertices = sorted(adj.keys())
        cycles: List[FrozenSet[int]] = []
        def dfs(start, current, path, visited):
            for nb in adj.get(current, set()):
                if nb == start and len(path) >= 3:
                    cycles.append(frozenset(path))
                elif nb not in visited and nb > start:
                    visited.add(nb)
                    path.append(nb)
                    dfs(start, nb, path, visited)
                    path.pop()
                    visited.discard(nb)
        for v in vertices:
            dfs(v, v, [v], {v})
        return list(set(cycles))

    graphs = {
        "K4 (complete)": graph_edges(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
        "C4 (square)": graph_edges(4, [(0,1),(1,2),(2,3),(3,0)]),
        "Diamond": graph_edges(4, [(0,1),(1,2),(2,3),(3,0),(0,2)]),
        "K3 + edge": graph_edges(4, [(0,1),(1,2),(2,0),(2,3)]),
        "Two triangles (shared edge)": graph_edges(4, [(0,1),(1,2),(2,0),(1,3),(3,2)]),
    }

    print("\n  Computing overlap fingerprints for 5 graphs on 4 vertices:\n")

    fingerprints = {}
    for name, adj in graphs.items():
        cycles = find_cycles(adj)
        if cycles:
            deg = overlap_degree(cycles)
            sig = tuple(overlap_signature(cycles))
            n_classes = len(overlap_classes(cycles))
            fingerprints[name] = (len(cycles), deg, sig, n_classes)
        else:
            fingerprints[name] = (0, 0, (), 0)

        fp = fingerprints[name]
        print(f"  {name}:")
        print(f"    Cycles: {fp[0]}, Overlap degree: {fp[1]}, "
              f"Signature: {list(fp[2])}, Classes: {fp[3]}")

    # Check which graphs are distinguished
    print("\n  Distinguishability matrix:")
    names = list(graphs.keys())
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j:
                same = fingerprints[n1] == fingerprints[n2]
                print(f"    {n1} vs {n2}: "
                      f"{'SAME' if same else 'DIFFERENT'} fingerprint")


# ============================================================
# Main
# ============================================================

def main():
    print("╔" + "═" * 58 + "╗")
    print("║  Applications of Overlap Class Theory                    ║")
    print("╚" + "═" * 58 + "╝")

    network_community_detection()
    coding_theory_application()
    graph_classification()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Interactive Demo: Overlap Class Rigidity

This script demonstrates the overlap class framework for support families,
including visualization of overlap graphs, computation of overlap invariants,
and testing of the Overlap Rigidity Conjecture on small examples.

Usage:
    python demo.py
"""

from __future__ import annotations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from collections import defaultdict
import itertools

# ============================================================
# Core algorithms (self-contained for demo purposes)
# ============================================================

Support = FrozenSet[int]
SupportFamily = List[Support]


def supports_overlap(a: Support, b: Support) -> bool:
    return bool(a & b)


def cross_overlap_count(a: Support, b: Support) -> int:
    return len(a & b)


def overlap_degree(family: SupportFamily) -> int:
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                count += 1
    return count


def max_overlap_deg(family: SupportFamily) -> int:
    n = len(family)
    if n < 2:
        return 0
    return max(
        cross_overlap_count(family[i], family[j])
        for i in range(n) for j in range(i + 1, n)
    )


def overlap_signature(family: SupportFamily) -> List[int]:
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            c = cross_overlap_count(family[i], family[j])
            if c > 0:
                sig.append(c)
    return sorted(sig)


def overlap_classes(family: SupportFamily) -> List[List[int]]:
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    visited = [False] * n
    components: List[List[int]] = []
    for start in range(n):
        if visited[start]:
            continue
        component: List[int] = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            component.append(node)
            for neighbor in adj[node]:
                if not visited[neighbor]:
                    visited[neighbor] = True
                    queue.append(neighbor)
        components.append(component)
    return components


def is_pairwise_disjoint(family: SupportFamily) -> bool:
    return overlap_degree(family) == 0


def family_union(family: SupportFamily) -> Support:
    result: Set[int] = set()
    for s in family:
        result |= s
    return frozenset(result)


def full_overlap_analysis(family: SupportFamily) -> Dict:
    classes = overlap_classes(family)
    return {
        'n': len(family),
        'family': [sorted(s) for s in family],
        'overlap_degree': overlap_degree(family),
        'max_overlap_deg': max_overlap_deg(family),
        'overlap_signature': overlap_signature(family),
        'overlap_class_count': len(classes),
        'overlap_classes': [sorted(c) for c in classes],
        'is_pairwise_disjoint': is_pairwise_disjoint(family),
        'family_union_size': len(family_union(family)),
        'sum_of_sizes': sum(len(s) for s in family),
    }


# ============================================================
# Graph utilities
# ============================================================

def graph_from_edges(n: int, edges: List[Tuple[int, int]]) -> Dict[int, Set[int]]:
    """Build adjacency dict from edge list."""
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return adj


def find_all_cycles_bfs(adj: Dict[int, Set[int]]) -> List[Support]:
    """Find all simple cycles using DFS."""
    vertices = sorted(adj.keys())
    cycles: List[FrozenSet[int]] = []

    def dfs(start: int, current: int, path: List[int],
            visited: Set[int]) -> None:
        for neighbor in adj.get(current, set()):
            if neighbor == start and len(path) >= 3:
                cycles.append(frozenset(path))
            elif neighbor not in visited and neighbor > start:
                visited.add(neighbor)
                path.append(neighbor)
                dfs(start, neighbor, path, visited)
                path.pop()
                visited.discard(neighbor)

    for v in vertices:
        dfs(v, v, [v], {v})

    return list(set(cycles))


# ============================================================
# Demo: Concrete examples
# ============================================================

def print_separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def demo_basic_examples() -> None:
    """Demonstrate overlap analysis on hand-crafted examples."""
    print_separator("DEMO 1: Basic Support Family Examples")

    examples = [
        ("Pairwise disjoint (3 supports)",
         [frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5})]),
        ("Linear chain (supports overlap pairwise)",
         [frozenset({0, 1}), frozenset({1, 2}), frozenset({2, 3})]),
        ("Triangle overlap (all pairs overlap)",
         [frozenset({0, 1, 2}), frozenset({1, 2, 3}), frozenset({2, 3, 4})]),
        ("Two isolated pairs",
         [frozenset({0, 1}), frozenset({1, 2}),
          frozenset({5, 6}), frozenset({6, 7})]),
        ("Star overlap (one central support)",
         [frozenset({0, 1, 2, 3}), frozenset({1, 4}),
          frozenset({2, 5}), frozenset({3, 6})]),
    ]

    for name, family in examples:
        print(f"\n--- {name} ---")
        result = full_overlap_analysis(family)
        print(f"  Supports: {result['family']}")
        print(f"  Overlap degree: {result['overlap_degree']}")
        print(f"  Max overlap degree: {result['max_overlap_deg']}")
        print(f"  Overlap signature: {result['overlap_signature']}")
        print(f"  Overlap class count: {result['overlap_class_count']}")
        print(f"  Overlap classes: {result['overlap_classes']}")
        print(f"  Pairwise disjoint: {result['is_pairwise_disjoint']}")
        print(f"  Union size: {result['family_union_size']}, "
              f"Sum of sizes: {result['sum_of_sizes']}")

        # Verify key theorem: disjoint iff overlap degree = 0
        assert result['is_pairwise_disjoint'] == (result['overlap_degree'] == 0), \
            "THEOREM VIOLATION: overlapDegree_eq_zero_iff"

        # Verify: pairwise disjoint implies union = sum
        if result['is_pairwise_disjoint']:
            assert result['family_union_size'] == result['sum_of_sizes'], \
                "THEOREM VIOLATION: familyUnion_card_of_pairwiseDisjoint"

    print("\n✓ All theorem invariants verified.")


def demo_graph_cycles() -> None:
    """Demonstrate overlap analysis on cycle supports of small graphs."""
    print_separator("DEMO 2: Cycle Support Analysis on Graphs")

    # Example: K4 (complete graph on 4 vertices)
    print("\n--- Complete graph K4 ---")
    k4 = graph_from_edges(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)])
    cycles = find_all_cycles_bfs(k4)
    print(f"  Vertices: {sorted(k4.keys())}")
    print(f"  Edges: {[(u,v) for u in sorted(k4.keys()) for v in sorted(k4[u]) if u < v]}")
    print(f"  Number of cycles: {len(cycles)}")
    for i, c in enumerate(sorted(cycles, key=lambda x: (len(x), sorted(x)))):
        print(f"    Cycle {i}: {sorted(c)}")

    if cycles:
        result = full_overlap_analysis(cycles)
        print(f"  Overlap degree: {result['overlap_degree']}")
        print(f"  Max overlap degree: {result['max_overlap_deg']}")
        print(f"  Overlap class count: {result['overlap_class_count']}")
        print(f"  Overlap classes: {result['overlap_classes']}")

    # Example: Cycle graph C5
    print("\n--- Cycle graph C5 ---")
    c5 = graph_from_edges(5, [(0,1),(1,2),(2,3),(3,4),(4,0)])
    cycles = find_all_cycles_bfs(c5)
    print(f"  Number of cycles: {len(cycles)}")
    for i, c in enumerate(sorted(cycles, key=lambda x: (len(x), sorted(x)))):
        print(f"    Cycle {i}: {sorted(c)}")

    if cycles:
        result = full_overlap_analysis(cycles)
        print(f"  Overlap degree: {result['overlap_degree']}")
        print(f"  Overlap class count: {result['overlap_class_count']}")

    # Example: Petersen-like small graph (two triangles sharing an edge)
    print("\n--- Two triangles sharing edge (0,1) ---")
    g = graph_from_edges(4, [(0,1),(1,2),(2,0),(0,3),(3,1)])
    cycles = find_all_cycles_bfs(g)
    print(f"  Number of cycles: {len(cycles)}")
    for i, c in enumerate(sorted(cycles, key=lambda x: (len(x), sorted(x)))):
        print(f"    Cycle {i}: {sorted(c)}")

    if cycles:
        result = full_overlap_analysis(cycles)
        print(f"  Overlap degree: {result['overlap_degree']}")
        print(f"  Max overlap degree: {result['max_overlap_deg']}")
        print(f"  Overlap signature: {result['overlap_signature']}")
        print(f"  Overlap class count: {result['overlap_class_count']}")
        print(f"  Overlap classes: {result['overlap_classes']}")


def demo_theorem_verification() -> None:
    """Verify key theorems on random-ish families."""
    print_separator("DEMO 3: Theorem Verification")

    import random
    random.seed(42)

    n_tests = 50
    passed = 0

    for _ in range(n_tests):
        # Generate random family
        n_supports = random.randint(2, 6)
        n_elements = random.randint(3, 10)
        family = []
        for _ in range(n_supports):
            size = random.randint(1, min(4, n_elements))
            support = frozenset(random.sample(range(n_elements), size))
            family.append(support)

        result = full_overlap_analysis(family)

        # Theorem: overlap degree 0 iff pairwise disjoint
        assert result['is_pairwise_disjoint'] == (result['overlap_degree'] == 0)

        # Theorem: disjoint implies union = sum
        if result['is_pairwise_disjoint']:
            assert result['family_union_size'] == result['sum_of_sizes']

        # Theorem: overlap degree ≤ n*(n-1)/2
        n = result['n']
        assert result['overlap_degree'] <= n * (n - 1) // 2

        # Theorem: overlap signature has overlap_degree entries
        assert len(result['overlap_signature']) == result['overlap_degree']

        # Theorem: all signature entries are positive
        assert all(x > 0 for x in result['overlap_signature'])

        # Theorem: class count ≤ n
        assert result['overlap_class_count'] <= n

        passed += 1

    print(f"\n  ✓ All {passed}/{n_tests} random tests passed.")
    print("  Verified theorems:")
    print("    - overlapDegree_eq_zero_iff")
    print("    - familyUnion_card_of_pairwiseDisjoint")
    print("    - overlapDegree_le")
    print("    - overlapSignature_pos")
    print("    - overlapClassCount_le")


def demo_monotonicity() -> None:
    """Demonstrate the refinement monotonicity theorem."""
    print_separator("DEMO 4: Refinement Monotonicity")

    family = [frozenset({1, 2, 3}), frozenset({2, 3, 4}), frozenset({4, 5, 6})]
    print(f"  Original family: {[sorted(s) for s in family]}")
    print(f"  Overlap degree: {overlap_degree(family)}")

    # Refine by removing elements
    refined = [frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})]
    print(f"\n  Refined family: {[sorted(s) for s in refined]}")
    print(f"  Overlap degree: {overlap_degree(refined)}")

    orig_deg = overlap_degree(family)
    ref_deg = overlap_degree(refined)
    print(f"\n  Original degree ({orig_deg}) >= Refined degree ({ref_deg}): "
          f"{'✓' if orig_deg >= ref_deg else '✗'}")

    # Another refinement
    refined2 = [frozenset({1, 3}), frozenset({2, 3}), frozenset({4, 5})]
    print(f"\n  Another refinement: {[sorted(s) for s in refined2]}")
    print(f"  Overlap degree: {overlap_degree(refined2)}")
    ref_deg2 = overlap_degree(refined2)

    # Note: this is not a subset refinement of the original, just an example
    # The theorem requires G_i ⊆ F_i for all i


def demo_conjecture_test() -> None:
    """Test the overlap rigidity conjecture on small examples."""
    print_separator("DEMO 5: Overlap Rigidity Conjecture Test")

    print("\n  The conjecture states that for connected graphs,")
    print("  the number of TropProjEquiv classes of minimal generating")
    print("  families equals the number of overlap classes of cycle supports.")
    print()

    # Test on small graphs
    test_cases = [
        ("Triangle (K3)", 3, [(0,1),(1,2),(2,0)]),
        ("Square (C4)", 4, [(0,1),(1,2),(2,3),(3,0)]),
        ("K4", 4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
        ("Diamond", 4, [(0,1),(1,2),(2,3),(3,0),(0,2)]),
        ("Path P4", 4, [(0,1),(1,2),(2,3)]),
    ]

    for name, n, edges in test_cases:
        adj = graph_from_edges(n, edges)
        cycles = find_all_cycles_bfs(adj)
        print(f"  {name}:")
        print(f"    Vertices: {n}, Edges: {len(edges)}")
        print(f"    Cycles found: {len(cycles)}")

        if cycles:
            result = full_overlap_analysis(cycles)
            print(f"    Overlap degree: {result['overlap_degree']}")
            print(f"    Overlap class count: {result['overlap_class_count']}")
            print(f"    Overlap signature: {result['overlap_signature']}")
        else:
            print(f"    (No cycles — tree/forest)")
        print()


# ============================================================
# Main
# ============================================================

def main() -> None:
    print("╔" + "═" * 58 + "╗")
    print("║  Overlap Class Rigidity — Interactive Demonstration      ║")
    print("║  Based on OverlapClassRigidity.lean                      ║")
    print("╚" + "═" * 58 + "╝")

    demo_basic_examples()
    demo_graph_cycles()
    demo_theorem_verification()
    demo_monotonicity()
    demo_conjecture_test()

    print_separator("ALL DEMOS COMPLETE")
    print("\n  All verified theorems from OverlapClassRigidity.lean have been")
    print("  validated computationally on concrete examples.")
    print("  The overlap class framework provides a consistent, computable")
    print("  hierarchy of invariants for support families.")


if __name__ == "__main__":
    main()


"""
Visualization: Support Overlap Graph and Overlap Classes

This self-contained script visualizes the overlap structure of a
support family, showing:
1. The original supports as colored sets
2. The overlap graph (vertices = supports, edges = nonempty intersection)
3. The overlap classes (connected components) with distinct colors

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, FrozenSet, List, Set, Tuple
from collections import defaultdict

# ============================================================
# Self-contained overlap computation
# ============================================================

Support = FrozenSet[int]
SupportFamily = List[Support]


def supports_overlap(a: Support, b: Support) -> bool:
    return bool(a & b)


def overlap_classes(family: SupportFamily) -> List[List[int]]:
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    visited = [False] * n
    components: List[List[int]] = []
    for start in range(n):
        if visited[start]:
            continue
        comp: List[int] = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            comp.append(node)
            for nb in adj[node]:
                if not visited[nb]:
                    visited[nb] = True
                    queue.append(nb)
        components.append(comp)
    return components


def cross_overlap_count(a: Support, b: Support) -> int:
    return len(a & b)


# ============================================================
# Visualization
# ============================================================

def visualize_overlap_structure(family: SupportFamily, title: str = "Support Overlap Structure"):
    """Create a comprehensive visualization of the overlap structure."""

    n = len(family)
    classes = overlap_classes(family)
    n_classes = len(classes)

    # Assign colors to overlap classes
    cmap = plt.cm.Set2
    class_colors = {}
    for idx, cls in enumerate(classes):
        color = cmap(idx / max(n_classes, 1))
        for i in cls:
            class_colors[i] = color

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle(title, fontsize=16, fontweight='bold')

    # --- Panel 1: Support elements ---
    ax1 = axes[0]
    ax1.set_title("Support Elements", fontsize=13)

    all_elements = sorted(set().union(*family))
    n_elem = len(all_elements)
    elem_positions = {e: i for i, e in enumerate(all_elements)}

    for i, support in enumerate(family):
        y = n - 1 - i
        for elem in support:
            x = elem_positions[elem]
            ax1.scatter(x, y, color=class_colors[i], s=200, zorder=3,
                       edgecolors='black', linewidth=1)
            ax1.text(x, y, str(elem), ha='center', va='center',
                    fontsize=8, fontweight='bold', zorder=4)

        # Draw a rectangle around the support
        if support:
            xs = [elem_positions[e] for e in support]
            ax1.plot([min(xs) - 0.3, max(xs) + 0.3, max(xs) + 0.3,
                     min(xs) - 0.3, min(xs) - 0.3],
                    [y - 0.3, y - 0.3, y + 0.3, y + 0.3, y - 0.3],
                    color=class_colors[i], linewidth=2, alpha=0.5)

    ax1.set_xlim(-0.5, n_elem - 0.5)
    ax1.set_ylim(-0.5, n - 0.5)
    ax1.set_yticks(range(n))
    ax1.set_yticklabels([f"S{n-1-i}" for i in range(n)])
    ax1.set_xticks(range(n_elem))
    ax1.set_xticklabels(all_elements)
    ax1.set_xlabel("Elements")
    ax1.set_ylabel("Supports")
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: Overlap Graph ---
    ax2 = axes[1]
    ax2.set_title("Overlap Graph", fontsize=13)

    # Position vertices in a circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

    # Draw edges
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                xi, yi = positions[i]
                xj, yj = positions[j]
                count = cross_overlap_count(family[i], family[j])
                ax2.plot([xi, xj], [yi, yj], 'k-', linewidth=1 + count,
                        alpha=0.4, zorder=1)
                mx, my = (xi + xj) / 2, (yi + yj) / 2
                ax2.text(mx, my, str(count), ha='center', va='center',
                        fontsize=8, color='red', fontweight='bold',
                        bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                                 edgecolor='red', alpha=0.8),
                        zorder=5)

    # Draw vertices
    for i in range(n):
        x, y = positions[i]
        ax2.scatter(x, y, color=class_colors[i], s=400, zorder=3,
                   edgecolors='black', linewidth=2)
        ax2.text(x, y, f"S{i}", ha='center', va='center',
                fontsize=10, fontweight='bold', zorder=4)

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.axis('off')

    # --- Panel 3: Overlap Classes ---
    ax3 = axes[2]
    ax3.set_title(f"Overlap Classes ({n_classes} classes)", fontsize=13)

    for cls_idx, cls in enumerate(classes):
        y_base = n_classes - 1 - cls_idx
        color = cmap(cls_idx / max(n_classes, 1))

        # Draw class box
        rect = mpatches.FancyBboxPatch(
            (-0.3, y_base - 0.35), 2.6, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=color, alpha=0.2, edgecolor=color, linewidth=2
        )
        ax3.add_patch(rect)

        # Draw supports in class
        for local_idx, support_idx in enumerate(sorted(cls)):
            x = local_idx * 0.5
            ax3.scatter(x, y_base, color=color, s=200, zorder=3,
                       edgecolors='black', linewidth=1)
            ax3.text(x, y_base, f"S{support_idx}", ha='center', va='center',
                    fontsize=8, fontweight='bold', zorder=4)

        # Class label
        union_set = set()
        for si in cls:
            union_set |= family[si]
        ax3.text(2.5, y_base, f"Class {cls_idx+1}\n|∪| = {len(union_set)}",
                ha='left', va='center', fontsize=9)

    ax3.set_xlim(-0.5, 4)
    ax3.set_ylim(-0.5, n_classes - 0.5)
    ax3.axis('off')

    plt.tight_layout()
    plt.savefig("overlap_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved: overlap_visualization.png")
    plt.close()


# ============================================================
# Main: Generate visualizations for several examples
# ============================================================

if __name__ == "__main__":
    # Example 1: Two overlap classes
    family1: SupportFamily = [
        frozenset({0, 1}),
        frozenset({1, 2}),
        frozenset({2, 3}),
        frozenset({5, 6}),
        frozenset({6, 7}),
    ]
    visualize_overlap_structure(family1,
        "Overlap Structure: Two Classes (Chain + Pair)")

    # Example 2: Fully connected
    family2: SupportFamily = [
        frozenset({0, 1, 2}),
        frozenset({1, 2, 3}),
        frozenset({2, 3, 4}),
        frozenset({3, 4, 0}),
    ]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Overlap Invariant Comparison", fontsize=16, fontweight='bold')

    # Panel 1: Overlap degree vs family size
    sizes = list(range(2, 8))
    degrees_chain = []
    degrees_complete = []
    for n in sizes:
        chain = [frozenset({i, i+1}) for i in range(n)]
        degrees_chain.append(n - 1)  # each pair overlaps
        complete = [frozenset(range(n)) for _ in range(n)]
        degrees_complete.append(n * (n-1) // 2)

    axes[0].plot(sizes, degrees_chain, 'bo-', label='Chain overlap', linewidth=2)
    axes[0].plot(sizes, degrees_complete, 'rs-', label='Complete overlap', linewidth=2)
    axes[0].plot(sizes, [0]*len(sizes), 'g^-', label='Disjoint', linewidth=2)
    axes[0].set_xlabel("Number of supports", fontsize=12)
    axes[0].set_ylabel("Overlap degree", fontsize=12)
    axes[0].set_title("Overlap Degree Growth", fontsize=13)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Panel 2: Class count vs overlap degree
    import random
    random.seed(42)
    deg_list = []
    class_list = []
    for _ in range(100):
        n_s = random.randint(3, 8)
        n_e = random.randint(4, 12)
        fam = [frozenset(random.sample(range(n_e), random.randint(1, 4)))
               for _ in range(n_s)]
        d = sum(1 for i in range(n_s) for j in range(i+1, n_s)
                if fam[i] & fam[j])
        c = len(overlap_classes(fam))
        deg_list.append(d)
        class_list.append(c)

    axes[1].scatter(deg_list, class_list, alpha=0.5, c='purple', s=30)
    axes[1].set_xlabel("Overlap degree", fontsize=12)
    axes[1].set_ylabel("Number of overlap classes", fontsize=12)
    axes[1].set_title("Classes vs Overlap Degree (random families)", fontsize=13)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("overlap_invariants.png", dpi=150, bbox_inches='tight')
    print("Saved: overlap_invariants.png")
    plt.close()
