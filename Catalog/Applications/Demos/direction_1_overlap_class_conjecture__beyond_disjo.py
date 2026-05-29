#!/usr/bin/env python3
"""
applications.py — Applications of Overlap Class Theory

Demonstrates real-world applications of the overlap class framework:
1. Graph classification via overlap profiles
2. Code support analysis (coding theory connection)
3. Network topology decomposition
4. Matroid circuit interaction analysis
"""

from collections import defaultdict
from typing import List, Set, Tuple, Dict, FrozenSet
import itertools
import random


# ─────────────────────────────────────────────────────────────────────
# Core functions (self-contained)
# ─────────────────────────────────────────────────────────────────────

def overlap_classes(family: List[Set[int]]) -> List[List[int]]:
    """Connected components of the support interaction graph."""
    n = len(family)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)

    groups = defaultdict(list)
    for i in range(n):
        groups[find(i)].append(i)
    return list(groups.values())


def overlap_profile(family: List[Set[int]]) -> Tuple[int, int, int, List[int]]:
    """Compute the full overlap profile: (class_count, degree, complexity, signature)."""
    n = len(family)
    degree = 0
    complexity = 0
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            inter = len(family[i] & family[j])
            if inter > 0:
                degree += 1
                complexity += inter
                sig.append(inter)
    return len(overlap_classes(family)), degree, complexity, sorted(sig)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Graph Classification
# ─────────────────────────────────────────────────────────────────────

def app_graph_classification():
    """Classify small graphs by their cycle-support overlap profiles."""
    print("=" * 70)
    print("APPLICATION 1: Graph Classification via Overlap Profiles")
    print("=" * 70)

    # Named graphs with their cycle supports
    graphs = {
        "Triangle (C₃)": [
            {0, 1, 2}
        ],
        "Square (C₄)": [
            {0, 1, 2, 3}
        ],
        "Diamond (K₄ - e)": [
            {0, 1, 2},
            {0, 2, 3},
            {0, 1, 2, 3}
        ],
        "K₄ (complete)": [
            {0, 1, 2},
            {0, 1, 3},
            {0, 2, 3},
            {1, 2, 3},
        ],
        "Bowtie": [
            {0, 1, 2},
            {2, 3, 4}
        ],
        "Theta graph": [
            {0, 1, 2, 3},
            {0, 1, 4, 3},
            {0, 2, 4, 3}  # via different path
        ],
        "Two disjoint triangles": [
            {0, 1, 2},
            {3, 4, 5}
        ],
    }

    print(f"\n{'Graph':<25} {'Classes':>8} {'Degree':>8} {'Complexity':>11} {'Signature':<20}")
    print("-" * 75)
    for name, cycles in graphs.items():
        cc, deg, comp, sig = overlap_profile(cycles)
        print(f"{name:<25} {cc:>8} {deg:>8} {comp:>11} {str(sig):<20}")

    print("\nKey insight: The overlap profile is a graph invariant that captures")
    print("how the cycle space is structured. Graphs with different profiles")
    print("have fundamentally different interaction patterns among their cycles.")
    print("\nNote: Two disjoint triangles have 2 classes (independent sectors),")
    print("while the bowtie has 1 class despite being 'almost disjoint' —")
    print("the shared vertex creates an interaction channel.")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Coding Theory
# ─────────────────────────────────────────────────────────────────────

def app_coding_theory():
    """Analyze support overlap in error-correcting codes."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Codeword Support Analysis (Coding Theory)")
    print("=" * 70)

    # Simulate minimum-weight codewords of a [7,4] Hamming code
    # The supports of minimum-weight codewords (weight 3)
    hamming_supports = [
        {0, 1, 3},
        {1, 2, 4},
        {2, 3, 5},
        {3, 4, 6},
        {0, 4, 5},
        {1, 5, 6},
        {0, 2, 6},
    ]

    print(f"\n[7,4] Hamming code — minimum weight codeword supports:")
    for i, s in enumerate(hamming_supports):
        print(f"  Codeword {i}: support = {s}")

    classes = overlap_classes(hamming_supports)
    cc, deg, comp, sig = overlap_profile(hamming_supports)

    print(f"\nOverlap analysis:")
    print(f"  Overlap classes: {len(classes)} (all codewords interact)")
    print(f"  Overlap degree: {deg}")
    print(f"  Overlap complexity: {comp}")
    print(f"  Overlap signature: {sig}")

    print(f"\nInterpretation: All minimum-weight codewords form a single")
    print(f"interaction class. This reflects the high symmetry (transitivity)")
    print(f"of the Hamming code: no codeword is 'isolated' from the others.")

    # Compare with a code having isolated codewords
    print(f"\nComparison — code with isolated sectors:")
    isolated_supports = [
        {0, 1, 2},
        {1, 2, 3},
        {5, 6, 7},
        {6, 7, 8},
    ]
    for i, s in enumerate(isolated_supports):
        print(f"  Codeword {i}: support = {s}")

    classes2 = overlap_classes(isolated_supports)
    cc2, deg2, comp2, sig2 = overlap_profile(isolated_supports)
    print(f"\n  Overlap classes: {classes2}")
    print(f"  Class count: {cc2} (two independent sectors)")
    print(f"  → These sectors can be decoded independently!")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Network Topology
# ─────────────────────────────────────────────────────────────────────

def app_network_topology():
    """Decompose a network by its cycle interaction structure."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Network Topology Decomposition")
    print("=" * 70)

    # Model a network with redundant paths
    print("\nNetwork: A communication network with redundant routing loops")
    print("Each cycle represents a redundant path that can carry traffic")
    print("if the primary path fails.\n")

    cycles = [
        {1, 2, 3, 4},       # Loop A: data center ring 1
        {3, 4, 5, 6},       # Loop B: overlap with A at nodes 3,4
        {7, 8, 9},          # Loop C: isolated backup ring
        {10, 11, 12, 13},   # Loop D: regional backbone
        {12, 13, 14, 15},   # Loop E: overlap with D
        {14, 15, 16},       # Loop F: overlap with E
    ]

    for i, c in enumerate(cycles):
        print(f"  Loop {chr(65+i)}: nodes {c}")

    classes = overlap_classes(cycles)
    cc, deg, comp, sig = overlap_profile(cycles)

    print(f"\nOverlap class decomposition:")
    for i, cls in enumerate(classes):
        loop_names = [chr(65 + j) for j in cls]
        combined = set()
        for j in cls:
            combined |= cycles[j]
        print(f"  Sector {i+1}: Loops {loop_names}, nodes {combined}")

    print(f"\n  Total sectors: {cc}")
    print(f"  Overlap degree: {deg}")
    print(f"  Overlap complexity: {comp}")

    print(f"\nEngineering insight: Each sector can be managed independently.")
    print(f"Failure in Sector 1 does not affect Sector 2 or 3.")
    print(f"This is the network-science analogue of the componentwise")
    print(f"factorization theorem for tropical kernel generators.")


# ─────────────────────────────────────────────────────────────────────
# Application 4: Matroid Circuit Analysis
# ─────────────────────────────────────────────────────────────────────

def app_matroid_circuits():
    """Analyze circuit interactions in graphic matroids."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Matroid Circuit Interaction Analysis")
    print("=" * 70)

    print("\nIn the graphic matroid M(G), circuits correspond to cycles.")
    print("The circuit intersection graph captures how circuits interact.")
    print("Our overlap class theory gives a rigorous decomposition.\n")

    # Petersen graph has rich circuit structure
    # Use a simpler example: K₃,₃ (complete bipartite)
    print("Graph: K₃,₃ (complete bipartite on {0,1,2} and {3,4,5})")
    print("Edge set encodes the bipartite structure.\n")

    # 4-cycles in K₃,₃
    four_cycles = []
    left = [0, 1, 2]
    right = [3, 4, 5]
    for l1, l2 in itertools.combinations(left, 2):
        for r1, r2 in itertools.combinations(right, 2):
            four_cycles.append({l1, r1, l2, r2})

    print(f"4-cycles (circuits of size 4): {len(four_cycles)}")
    for i, c in enumerate(four_cycles):
        print(f"  C_{i}: {c}")

    classes = overlap_classes(four_cycles)
    cc, deg, comp, sig = overlap_profile(four_cycles)

    print(f"\nCircuit interaction analysis:")
    print(f"  Overlap classes: {cc}")
    print(f"  Overlap degree: {deg}")
    print(f"  Overlap complexity: {comp}")
    print(f"  Overlap signature (first 10): {sig[:10]}{'...' if len(sig) > 10 else ''}")

    print(f"\nMatroid-theoretic insight: All 4-circuits of K₃,₃ form")
    print(f"a single interaction class. This reflects the high connectivity")
    print(f"of the graphic matroid — circuit elimination can transform")
    print(f"any circuit into any other via a chain of overlapping circuits.")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Overlap Class Theory — Applications                              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    app_graph_classification()
    app_coding_theory()
    app_network_topology()
    app_matroid_circuits()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Overlap Class Theory for Tropical Kernel Rigidity

This script demonstrates the overlap class conjecture:
  For a family of supports (modeling cycle supports in an induced subgraph),
  the overlap class count (connected components of the support interaction graph)
  is a tropical projective equivalence (TPE) invariant.

Usage:
  python demo.py              # Run all demonstrations
  python demo.py --search N   # Search for counterexamples on graphs up to N vertices
"""

import itertools
import random
import sys
from collections import defaultdict


# ─────────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────────

def supports_overlap(A, B):
    """Check if two sets have nonempty intersection."""
    return bool(A & B)


def overlap_degree(family):
    """Count the number of overlapping pairs in a support family."""
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                count += 1
    return count


def overlap_complexity(family):
    """Sum of pairwise intersection cardinalities."""
    n = len(family)
    total = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(family[i] & family[j])
    return total


def overlap_graph_edges(family):
    """Return edges of the support interaction graph."""
    n = len(family)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                edges.append((i, j))
    return edges


def connected_components(n, edges):
    """Find connected components using union-find."""
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for u, v in edges:
        union(u, v)

    components = defaultdict(list)
    for i in range(n):
        components[find(i)].append(i)
    return list(components.values())


def overlap_class_count(family):
    """Number of connected components of the support interaction graph."""
    if not family:
        return 0
    edges = overlap_graph_edges(family)
    return len(connected_components(len(family), edges))


def overlap_signature(family):
    """Sorted multiset of intersection cardinalities for overlapping pairs."""
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            inter_size = len(family[i] & family[j])
            if inter_size > 0:
                sig.append(inter_size)
    return sorted(sig)


def family_union(family):
    """Union of all sets in the family."""
    result = set()
    for s in family:
        result |= s
    return result


# ─────────────────────────────────────────────────────────────────────
# Tropical Projective Equivalence simulation
# ─────────────────────────────────────────────────────────────────────

def apply_tpe(functions, sigma, constants):
    """Apply TPE transformation: F₂(σ(i), v) = F₁(i, v) + c(i)."""
    n = len(functions)
    vertices = set()
    for f in functions:
        vertices |= set(f.keys())

    result = [None] * n
    for i in range(n):
        new_f = {}
        for v in vertices:
            new_f[v] = functions[i].get(v, 0) + constants[i]
        result[sigma[i]] = new_f
    return result


def variation_support(f, v0):
    """Compute VarSupport: {v | f(v) ≠ f(v₀)}."""
    f_v0 = f.get(v0, 0)
    return frozenset(v for v in f if f[v] != f_v0)


def var_support_family(functions, v0):
    """Compute VarSupportFamily for all functions in the family."""
    return [variation_support(f, v0) for f in functions]


# ─────────────────────────────────────────────────────────────────────
# Graph generation and cycle supports
# ─────────────────────────────────────────────────────────────────────

def generate_connected_graphs(n):
    """Generate all connected simple graphs on n vertices (small n only)."""
    vertices = list(range(n))
    all_edges = list(itertools.combinations(vertices, 2))

    for r in range(n - 1, len(all_edges) + 1):
        for edges in itertools.combinations(all_edges, r):
            adj = defaultdict(set)
            for u, v in edges:
                adj[u].add(v)
                adj[v].add(u)
            # Check connectivity via BFS
            visited = set()
            queue = [0]
            while queue:
                node = queue.pop()
                if node not in visited:
                    visited.add(node)
                    queue.extend(adj[node] - visited)
            if len(visited) == n:
                yield vertices, list(edges), adj


def find_cycles_dfs(vertices, adj, max_cycles=20):
    """Find simple cycles in a graph using DFS."""
    cycles = []
    n = len(vertices)

    def dfs(start, current, path, visited):
        if len(cycles) >= max_cycles:
            return
        for neighbor in sorted(adj[current]):
            if neighbor == start and len(path) >= 3:
                cycle = frozenset(path)
                if cycle not in cycles:
                    cycles.append(cycle)
            elif neighbor not in visited and neighbor > start:
                visited.add(neighbor)
                path.append(neighbor)
                dfs(start, neighbor, path, visited)
                path.pop()
                visited.discard(neighbor)

    for v in sorted(vertices):
        dfs(v, v, [v], {v})
        if len(cycles) >= max_cycles:
            break

    return [set(c) for c in cycles]


# ─────────────────────────────────────────────────────────────────────
# Demonstration functions
# ─────────────────────────────────────────────────────────────────────

def demo_basic_overlap():
    """Demonstrate basic overlap concepts."""
    print("=" * 70)
    print("DEMO 1: Basic Overlap Concepts")
    print("=" * 70)

    # Example: three supports with various overlap patterns
    A = {1, 2, 3}
    B = {3, 4, 5}
    C = {6, 7, 8}

    family = [A, B, C]
    print(f"\nSupport family:")
    for i, s in enumerate(family):
        print(f"  F[{i}] = {s}")

    print(f"\nOverlap relations:")
    print(f"  F[0] ∩ F[1] = {A & B} (overlap: {supports_overlap(A, B)})")
    print(f"  F[0] ∩ F[2] = {A & C} (overlap: {supports_overlap(A, C)})")
    print(f"  F[1] ∩ F[2] = {B & C} (overlap: {supports_overlap(B, C)})")

    print(f"\nOverlap degree: {overlap_degree(family)}")
    print(f"Overlap complexity: {overlap_complexity(family)}")
    print(f"Overlap class count: {overlap_class_count(family)}")

    edges = overlap_graph_edges(family)
    print(f"Overlap graph edges: {edges}")

    components = connected_components(len(family), edges)
    print(f"Overlap classes: {components}")
    print(f"  → Supports {{1,2,3}} and {{3,4,5}} are in the same class (interact)")
    print(f"  → Support {{6,7,8}} is in its own class (independent)")


def demo_tpe_invariance():
    """Demonstrate that overlap class count is TPE-invariant."""
    print("\n" + "=" * 70)
    print("DEMO 2: TPE Invariance of Overlap Class Count")
    print("=" * 70)

    vertices = {0, 1, 2, 3, 4, 5}
    v0 = 0  # basepoint

    # Original family F₁
    f1 = [{0: 0, 1: 3, 2: 1, 3: 0, 4: 0, 5: 0},
           {0: 0, 1: 0, 2: 2, 3: 5, 4: 0, 5: 0},
           {0: 0, 1: 0, 2: 0, 3: 0, 4: 7, 5: 3}]

    print(f"\nOriginal family F₁ (basepoint v₀ = {v0}):")
    for i, f in enumerate(f1):
        vs = variation_support(f, v0)
        print(f"  F₁[{i}]: values = {f}, VarSupport = {set(vs)}")

    vsf1 = [set(variation_support(f, v0)) for f in f1]
    print(f"\nVariation support family:")
    for i, vs in enumerate(vsf1):
        print(f"  VS₁[{i}] = {vs}")
    print(f"Overlap class count (F₁): {overlap_class_count(vsf1)}")
    print(f"Overlap degree (F₁): {overlap_degree(vsf1)}")
    print(f"Overlap complexity (F₁): {overlap_complexity(vsf1)}")

    # Apply TPE: permutation σ = (0→2, 1→0, 2→1), constants c = (10, -5, 3)
    sigma = [2, 0, 1]
    constants = [10, -5, 3]
    f2 = apply_tpe(f1, sigma, constants)

    print(f"\nTPE transformation: σ = {sigma}, c = {constants}")
    print(f"Transformed family F₂:")
    for i, f in enumerate(f2):
        vs = variation_support(f, v0)
        print(f"  F₂[{i}]: values = {f}, VarSupport = {set(vs)}")

    vsf2 = [set(variation_support(f, v0)) for f in f2]
    print(f"\nVariation support family (F₂):")
    for i, vs in enumerate(vsf2):
        print(f"  VS₂[{i}] = {vs}")
    print(f"Overlap class count (F₂): {overlap_class_count(vsf2)}")
    print(f"Overlap degree (F₂): {overlap_degree(vsf2)}")
    print(f"Overlap complexity (F₂): {overlap_complexity(vsf2)}")

    # Verify invariance
    cc1 = overlap_class_count(vsf1)
    cc2 = overlap_class_count(vsf2)
    od1 = overlap_degree(vsf1)
    od2 = overlap_degree(vsf2)
    oc1 = overlap_complexity(vsf1)
    oc2 = overlap_complexity(vsf2)

    print(f"\n{'Invariant':<25} {'F₁':>5} {'F₂':>5} {'Match':>7}")
    print("-" * 45)
    print(f"{'Overlap class count':<25} {cc1:>5} {cc2:>5} {'✓' if cc1 == cc2 else '✗':>7}")
    print(f"{'Overlap degree':<25} {od1:>5} {od2:>5} {'✓' if od1 == od2 else '✗':>7}")
    print(f"{'Overlap complexity':<25} {oc1:>5} {oc2:>5} {'✓' if oc1 == oc2 else '✗':>7}")


def demo_disjoint_recovery():
    """Demonstrate that overlap-degree 0 recovers the disjoint case."""
    print("\n" + "=" * 70)
    print("DEMO 3: Overlap Degree Zero Recovers Disjoint Case")
    print("=" * 70)

    # Pairwise disjoint family
    family = [{1, 2}, {3, 4}, {5, 6}, {7, 8}]
    print(f"\nPairwise disjoint family:")
    for i, s in enumerate(family):
        print(f"  F[{i}] = {s}")

    od = overlap_degree(family)
    oc = overlap_complexity(family)
    cc = overlap_class_count(family)

    print(f"\nOverlap degree: {od} (zero ⟺ pairwise disjoint ✓)")
    print(f"Overlap complexity: {oc}")
    print(f"Overlap class count: {cc} (= n = {len(family)} ✓)")
    print(f"Family union size: {len(family_union(family))}")
    print(f"Sum of sizes: {sum(len(s) for s in family)}")
    print(f"  → Union = Sum (no overlaps, inclusion-exclusion trivial)")


def demo_inclusion_exclusion():
    """Demonstrate the inclusion-exclusion bound."""
    print("\n" + "=" * 70)
    print("DEMO 4: Inclusion-Exclusion Bound via Overlap Complexity")
    print("=" * 70)

    family = [{1, 2, 3, 4}, {3, 4, 5, 6}, {5, 6, 7, 8}, {7, 8, 1, 2}]
    print(f"\nCyclic overlap family:")
    for i, s in enumerate(family):
        print(f"  F[{i}] = {s}")

    union_size = len(family_union(family))
    sum_sizes = sum(len(s) for s in family)
    oc = overlap_complexity(family)
    deficit = sum_sizes - union_size

    print(f"\n  |⋃ Fᵢ| = {union_size}")
    print(f"  Σ |Fᵢ| = {sum_sizes}")
    print(f"  Deficit = Σ|Fᵢ| - |⋃Fᵢ| = {deficit}")
    print(f"  Overlap complexity = {oc}")
    print(f"  Deficit ≤ Overlap complexity: {deficit} ≤ {oc} {'✓' if deficit <= oc else '✗'}")
    print(f"\n  Overlap degree: {overlap_degree(family)}")
    print(f"  Overlap class count: {overlap_class_count(family)}")
    print(f"  Overlap signature: {overlap_signature(family)}")


def demo_cycle_supports():
    """Demonstrate cycle support overlap on a small graph."""
    print("\n" + "=" * 70)
    print("DEMO 5: Cycle Supports in a Graph")
    print("=" * 70)

    # K4 (complete graph on 4 vertices)
    vertices = [0, 1, 2, 3]
    edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)

    print(f"\nGraph: K₄ (complete graph on 4 vertices)")
    print(f"Vertices: {vertices}")
    print(f"Edges: {edges}")

    cycles = find_cycles_dfs(vertices, adj)
    print(f"\nCycle supports found: {len(cycles)}")
    for i, c in enumerate(cycles):
        print(f"  Cycle {i}: {c}")

    if cycles:
        od = overlap_degree(cycles)
        oc = overlap_complexity(cycles)
        cc = overlap_class_count(cycles)
        sig = overlap_signature(cycles)

        print(f"\nOverlap analysis:")
        print(f"  Overlap degree: {od}")
        print(f"  Overlap complexity: {oc}")
        print(f"  Overlap class count: {cc}")
        print(f"  Overlap signature: {sig}")

        edges_og = overlap_graph_edges(cycles)
        print(f"  Overlap graph edges: {edges_og}")


def demo_search(max_n=6):
    """Search for counterexamples to the overlap class conjecture."""
    print("\n" + "=" * 70)
    print(f"DEMO 6: Counterexample Search (n ≤ {max_n})")
    print("=" * 70)

    total_tested = 0
    for n in range(3, max_n + 1):
        count = 0
        for vertices, edges, adj in generate_connected_graphs(n):
            count += 1
            cycles = find_cycles_dfs(vertices, adj)
            if len(cycles) >= 2:
                # Test TPE invariance by random TPE transformations
                v0 = 0
                # Create random functions with these cycle supports
                functions = []
                for cycle in cycles:
                    f = {v: 0 for v in vertices}
                    for v in cycle:
                        f[v] = random.randint(1, 10)
                    functions.append(f)

                vsf_orig = [set(variation_support(f, v0)) for f in functions]
                cc_orig = overlap_class_count(vsf_orig)

                # Apply random TPE
                perm = list(range(len(functions)))
                random.shuffle(perm)
                consts = [random.randint(-20, 20) for _ in functions]
                f2 = apply_tpe(functions, perm, consts)
                vsf_tpe = [set(variation_support(f, v0)) for f in f2]
                cc_tpe = overlap_class_count(vsf_tpe)

                if cc_orig != cc_tpe:
                    print(f"\n  ⚠ COUNTEREXAMPLE FOUND!")
                    print(f"    Graph: n={n}, edges={edges}")
                    print(f"    Cycle supports: {cycles}")
                    print(f"    Original class count: {cc_orig}")
                    print(f"    TPE class count: {cc_tpe}")
                    return False

                total_tested += 1

        print(f"  n = {n}: tested {count} connected graphs, {total_tested} total cycle tests — all pass ✓")

    print(f"\nNo counterexamples found in {total_tested} tests.")
    print("The overlap class count appears to be a genuine TPE invariant.")
    return True


def demo_overlap_profile():
    """Demonstrate overlap profiles for classification."""
    print("\n" + "=" * 70)
    print("DEMO 7: Overlap Profiles for Graph Classification")
    print("=" * 70)

    examples = [
        ("Disjoint", [{1, 2}, {3, 4}, {5, 6}]),
        ("Chain", [{1, 2, 3}, {3, 4, 5}, {5, 6, 7}]),
        ("Star", [{1, 2, 3}, {1, 4, 5}, {1, 6, 7}]),
        ("Triangle", [{1, 2, 3}, {2, 3, 4}, {3, 4, 1}]),
        ("Full overlap", [{1, 2, 3}, {1, 2, 3}, {1, 2, 3}]),
    ]

    print(f"\n{'Name':<16} {'Classes':>8} {'Degree':>8} {'Complexity':>11} {'Signature':<20}")
    print("-" * 65)
    for name, family in examples:
        cc = overlap_class_count(family)
        od = overlap_degree(family)
        oc = overlap_complexity(family)
        sig = overlap_signature(family)
        print(f"{name:<16} {cc:>8} {od:>8} {oc:>11} {str(sig):<20}")

    print("\nNote: Different overlap profiles distinguish different interaction regimes.")
    print("The overlap class count is the coarsest invariant (connected components).")
    print("The overlap signature is a finer invariant capturing intersection sizes.")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Overlap Class Theory — Tropical Kernel Rigidity Demo              ║")
    print("║  Beyond Disjoint Supports: Interaction Sectors in Tropical Algebra ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    max_search = 6
    if len(sys.argv) > 2 and sys.argv[1] == "--search":
        max_search = int(sys.argv[2])

    demo_basic_overlap()
    demo_tpe_invariance()
    demo_disjoint_recovery()
    demo_inclusion_exclusion()
    demo_cycle_supports()
    demo_search(max_search)
    demo_overlap_profile()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Support Interaction Graph and Overlap Classes

Visualizes the support overlap graph for a family of sets.
Each node represents a support (labeled with its elements).
Edges connect overlapping supports. Colors indicate overlap classes.
This illustrates the core concept: overlap classes partition
supports into independent interaction sectors.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
import math


def overlap_classes_uf(family):
    """Find overlap classes using union-find."""
    n = len(family)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)
                edges.append((i, j))

    groups = defaultdict(list)
    for i in range(n):
        groups[find(i)].append(i)
    return list(groups.values()), edges


def draw_overlap_graph(family, labels=None, title="Support Interaction Graph"):
    """Draw the support overlap graph with overlap class coloring."""
    n = len(family)
    classes, edges = overlap_classes_uf(family)

    # Assign colors to classes
    cmap = plt.cm.Set2
    class_colors = {}
    for ci, cls in enumerate(classes):
        color = cmap(ci / max(len(classes), 1))
        for idx in cls:
            class_colors[idx] = color

    # Layout: arrange in a circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    radius = 2.0
    positions = {i: (radius * np.cos(a), radius * np.sin(a))
                 for i, a in enumerate(angles)}

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw edges
    for i, j in edges:
        xi, yi = positions[i]
        xj, yj = positions[j]
        inter_size = len(family[i] & family[j])
        lw = 1 + inter_size * 0.8
        ax.plot([xi, xj], [yi, yj], 'k-', linewidth=lw, alpha=0.3, zorder=1)
        # Label intersection size
        mx, my = (xi + xj) / 2, (yi + yj) / 2
        ax.text(mx, my, str(inter_size), fontsize=8, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.7),
                zorder=3)

    # Draw nodes
    node_size = 800
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.35, color=class_colors[i],
                            ec='black', linewidth=2, zorder=2)
        ax.add_patch(circle)
        label = labels[i] if labels else str(set(family[i]))
        ax.text(x, y, f"F{i}\n{label}", fontsize=7, ha='center', va='center',
                fontweight='bold', zorder=4)

    # Legend for overlap classes
    legend_patches = []
    for ci, cls in enumerate(classes):
        color = cmap(ci / max(len(classes), 1))
        members = ', '.join(f'F{i}' for i in cls)
        legend_patches.append(
            mpatches.Patch(color=color, label=f'Class {ci+1}: {members}'))

    ax.legend(handles=legend_patches, loc='upper left', fontsize=9)

    # Annotations
    info_text = (f"Supports: {n}  |  "
                 f"Overlap classes: {len(classes)}  |  "
                 f"Overlap degree: {len(edges)}")
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.text(0.5, -0.05, info_text, transform=ax.transAxes,
            ha='center', fontsize=10, style='italic')

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    return fig


# ─────────────────────────────────────────────────────────────────────
# Main visualization
# ─────────────────────────────────────────────────────────────────────

# Example: family with 3 overlap classes
family = [
    frozenset({1, 2, 3}),      # Class 1
    frozenset({3, 4, 5}),      # Class 1 (overlaps with F0)
    frozenset({4, 5, 6}),      # Class 1 (overlaps with F1)
    frozenset({10, 11, 12}),   # Class 2
    frozenset({12, 13}),       # Class 2 (overlaps with F3)
    frozenset({20, 21, 22}),   # Class 3 (isolated)
]

fig = draw_overlap_graph(
    family,
    title="Support Interaction Graph — Three Overlap Classes"
)
plt.tight_layout()
plt.savefig("viz_overlap_graph.png", dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")


#!/usr/bin/env python3
"""
Visualization: Cross-Overlap Matrix Heatmap

Visualizes the pairwise intersection cardinalities between supports
as a heatmap. The block-diagonal structure reveals overlap classes:
supports in different classes have zero intersection, creating
a visible block structure.

This illustrates the componentwise factorization theorem:
the interaction matrix decomposes into independent blocks
corresponding to overlap classes.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def overlap_classes_sorted(family):
    """Find overlap classes and return indices sorted by class."""
    n = len(family)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)

    groups = defaultdict(list)
    for i in range(n):
        groups[find(i)].append(i)

    # Sort so classes appear as contiguous blocks
    sorted_indices = []
    class_boundaries = []
    for cls in groups.values():
        class_boundaries.append(len(sorted_indices))
        sorted_indices.extend(cls)
    class_boundaries.append(len(sorted_indices))

    return sorted_indices, class_boundaries


def cross_overlap_matrix(family, order):
    """Compute cross-overlap matrix in given index order."""
    n = len(order)
    M = np.zeros((n, n), dtype=int)
    for a in range(n):
        for b in range(n):
            i, j = order[a], order[b]
            M[a][b] = len(family[i] & family[j])
    return M


# ─────────────────────────────────────────────────────────────────────
# Main visualization
# ─────────────────────────────────────────────────────────────────────

# A family with clear block structure
family = [
    frozenset({1, 2, 3, 4}),      # Block A
    frozenset({3, 4, 5, 6}),      # Block A
    frozenset({5, 6, 7}),         # Block A
    frozenset({10, 11, 12}),      # Block B
    frozenset({11, 12, 13, 14}),  # Block B
    frozenset({20, 21}),          # Block C (singleton class)
    frozenset({30, 31, 32}),      # Block D
    frozenset({31, 32, 33}),      # Block D
    frozenset({32, 33, 34, 35}),  # Block D
]

order, boundaries = overlap_classes_sorted(family)
M = cross_overlap_matrix(family, order)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: raw matrix (unsorted)
M_raw = cross_overlap_matrix(family, list(range(len(family))))
im1 = ax1.imshow(M_raw, cmap='YlOrRd', aspect='equal', interpolation='nearest')
ax1.set_title('Cross-Overlap Matrix (unsorted)', fontsize=13, fontweight='bold')
ax1.set_xlabel('Support index')
ax1.set_ylabel('Support index')
for i in range(len(family)):
    for j in range(len(family)):
        val = M_raw[i][j]
        color = 'white' if val > 2 else 'black'
        ax1.text(j, i, str(val), ha='center', va='center',
                fontsize=9, color=color, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='|Fᵢ ∩ Fⱼ|', shrink=0.8)

# Right: sorted by overlap class (block-diagonal visible)
im2 = ax2.imshow(M, cmap='YlOrRd', aspect='equal', interpolation='nearest')
ax2.set_title('Cross-Overlap Matrix (sorted by overlap class)', fontsize=13,
              fontweight='bold')
ax2.set_xlabel('Support index (reordered)')
ax2.set_ylabel('Support index (reordered)')
for i in range(len(family)):
    for j in range(len(family)):
        val = M[i][j]
        color = 'white' if val > 2 else 'black'
        ax2.text(j, i, str(val), ha='center', va='center',
                fontsize=9, color=color, fontweight='bold')

# Draw class boundaries
for b in boundaries[1:-1]:
    ax2.axhline(y=b - 0.5, color='blue', linewidth=2, linestyle='--')
    ax2.axvline(x=b - 0.5, color='blue', linewidth=2, linestyle='--')

plt.colorbar(im2, ax=ax2, label='|Fᵢ ∩ Fⱼ|', shrink=0.8)

# Add class labels
class_names = ['A', 'B', 'C', 'D']
for ci in range(len(boundaries) - 1):
    mid = (boundaries[ci] + boundaries[ci + 1]) / 2 - 0.5
    ax2.text(-1.2, mid, f'Class {class_names[ci]}', ha='right', va='center',
             fontsize=10, fontweight='bold', color='blue')

fig.suptitle('Overlap Class Block Structure\n'
             'Sorting by overlap classes reveals independent interaction sectors',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("viz_overlap_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_overlap_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: TPE Invariance of Overlap Invariants

Shows that all overlap invariants (class count, degree, complexity,
signature) are preserved under Tropical Projective Equivalence.
Generates random TPE transformations and plots the invariants
before and after, demonstrating perfect agreement.

This illustrates the main theorem: overlap structure is intrinsic
to the tropical projective equivalence class, not an artifact of
a particular representation.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from collections import defaultdict


def variation_support(f, v0):
    f_v0 = f.get(v0, 0)
    return frozenset(v for v in f if f[v] != f_v0)


def apply_tpe(functions, sigma, constants):
    n = len(functions)
    vertices = set()
    for f in functions:
        vertices |= set(f.keys())
    result = [None] * n
    for i in range(n):
        new_f = {}
        for v in vertices:
            new_f[v] = functions[i].get(v, 0) + constants[i]
        result[sigma[i]] = new_f
    return result


def overlap_classes_count(family):
    n = len(family)
    if n == 0:
        return 0
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)
    return len(set(find(i) for i in range(n)))


def overlap_degree(family):
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1, n) if family[i] & family[j])


def overlap_complexity(family):
    n = len(family)
    return sum(len(family[i] & family[j]) for i in range(n) for j in range(i+1, n))


def overlap_signature(family):
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            s = len(family[i] & family[j])
            if s > 0:
                sig.append(s)
    return tuple(sorted(sig))


# ─────────────────────────────────────────────────────────────────────
# Generate test data
# ─────────────────────────────────────────────────────────────────────

random.seed(42)
np.random.seed(42)

num_trials = 50
num_functions = 5
num_vertices = 8
v0 = 0

# Generate a base function family
base_functions = []
for _ in range(num_functions):
    f = {v: random.randint(-10, 10) for v in range(num_vertices)}
    base_functions.append(f)

# Record invariants for each random TPE
results = {
    'class_count_before': [],
    'class_count_after': [],
    'degree_before': [],
    'degree_after': [],
    'complexity_before': [],
    'complexity_after': [],
    'signature_match': [],
}

for trial in range(num_trials):
    # Random TPE
    sigma = list(range(num_functions))
    random.shuffle(sigma)
    constants = [random.randint(-50, 50) for _ in range(num_functions)]

    f2 = apply_tpe(base_functions, sigma, constants)

    vsf1 = [variation_support(f, v0) for f in base_functions]
    vsf2 = [variation_support(f, v0) for f in f2]

    cc1 = overlap_classes_count(vsf1)
    cc2 = overlap_classes_count(vsf2)
    od1 = overlap_degree(vsf1)
    od2 = overlap_degree(vsf2)
    oc1 = overlap_complexity(vsf1)
    oc2 = overlap_complexity(vsf2)
    sig1 = overlap_signature(vsf1)
    sig2 = overlap_signature(vsf2)

    results['class_count_before'].append(cc1)
    results['class_count_after'].append(cc2)
    results['degree_before'].append(od1)
    results['degree_after'].append(od2)
    results['complexity_before'].append(oc1)
    results['complexity_after'].append(oc2)
    results['signature_match'].append(sig1 == sig2)


# ─────────────────────────────────────────────────────────────────────
# Plot
# ─────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Class count
ax = axes[0, 0]
ax.scatter(results['class_count_before'], results['class_count_after'],
           c='steelblue', s=80, alpha=0.7, edgecolors='navy', zorder=2)
max_val = max(max(results['class_count_before']), max(results['class_count_after'])) + 1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (invariance)', zorder=1)
ax.set_xlabel('Before TPE', fontsize=11)
ax.set_ylabel('After TPE', fontsize=11)
ax.set_title('Overlap Class Count', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')

# Plot 2: Overlap degree
ax = axes[0, 1]
ax.scatter(results['degree_before'], results['degree_after'],
           c='coral', s=80, alpha=0.7, edgecolors='darkred', zorder=2)
max_val = max(max(results['degree_before']), max(results['degree_after'])) + 1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (invariance)', zorder=1)
ax.set_xlabel('Before TPE', fontsize=11)
ax.set_ylabel('After TPE', fontsize=11)
ax.set_title('Overlap Degree', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')

# Plot 3: Overlap complexity
ax = axes[1, 0]
ax.scatter(results['complexity_before'], results['complexity_after'],
           c='seagreen', s=80, alpha=0.7, edgecolors='darkgreen', zorder=2)
max_val = max(max(results['complexity_before']), max(results['complexity_after'])) + 1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (invariance)', zorder=1)
ax.set_xlabel('Before TPE', fontsize=11)
ax.set_ylabel('After TPE', fontsize=11)
ax.set_title('Overlap Complexity', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')

# Plot 4: Summary bar chart
ax = axes[1, 1]
invariants = ['Class\nCount', 'Overlap\nDegree', 'Overlap\nComplexity', 'Overlap\nSignature']
matches = [
    sum(a == b for a, b in zip(results['class_count_before'], results['class_count_after'])),
    sum(a == b for a, b in zip(results['degree_before'], results['degree_after'])),
    sum(a == b for a, b in zip(results['complexity_before'], results['complexity_after'])),
    sum(results['signature_match']),
]
colors = ['steelblue', 'coral', 'seagreen', 'mediumpurple']
bars = ax.bar(invariants, matches, color=colors, edgecolor='black', linewidth=1.5)
ax.set_ylabel(f'Matches (out of {num_trials})', fontsize=11)
ax.set_title('TPE Invariance Verification', fontsize=13, fontweight='bold')
ax.set_ylim(0, num_trials * 1.15)
for bar, val in zip(bars, matches):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
            f'{val}/{num_trials}', ha='center', va='bottom', fontweight='bold', fontsize=11)

fig.suptitle('Tropical Projective Equivalence Preserves All Overlap Invariants\n'
             f'({num_trials} random TPE transformations on a 5-function family)',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("viz_tpe_invariance.png", dpi=150, bbox_inches='tight')
print("Saved viz_tpe_invariance.png")
