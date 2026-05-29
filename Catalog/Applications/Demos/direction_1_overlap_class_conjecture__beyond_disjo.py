"""
applications.py — Real-World Applications of Overlap Class Theory

Demonstrates applications of overlap class analysis to:
1. Network topology analysis
2. Error-correcting code support profiles
3. Chemical bond interaction patterns
4. Community detection in social networks

Each application shows how the overlap class framework reveals hidden
structure in real-world data.
"""

from collections import defaultdict, deque
from itertools import combinations
from typing import List, Set, Tuple, Dict, FrozenSet


# ============================================================
# Self-contained core (no local imports)
# ============================================================

class SupportFamily:
    def __init__(self, supports: List[FrozenSet[int]]):
        self.supports = list(supports)
        self.n = len(supports)


def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    return len(A & B) > 0


def compute_overlap_classes(family: SupportFamily) -> List[List[int]]:
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i, j in combinations(range(family.n), 2):
        if supports_overlap(family.supports[i], family.supports[j]):
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(family.n):
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            component.append(v)
            for w in adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        classes.append(sorted(component))
    return classes


def overlap_degree(family: SupportFamily) -> int:
    count = 0
    for i, j in combinations(range(family.n), 2):
        if supports_overlap(family.supports[i], family.supports[j]):
            count += 1
    return count


def overlap_signature(family: SupportFamily) -> List[int]:
    sizes = []
    for i, j in combinations(range(family.n), 2):
        isect = len(family.supports[i] & family.supports[j])
        if isect > 0:
            sizes.append(isect)
    return sorted(sizes)


# ============================================================
# Application 1: Network Topology — Identifying Independent Sectors
# ============================================================

def app_network_topology():
    """Analyze a communication network to find independent failure domains.

    In a network, cycles represent redundant paths. Overlap classes of
    cycle supports identify groups of cycles that share infrastructure.
    Different overlap classes are completely independent failure domains:
    a failure in one class cannot propagate to another.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Failure Domain Analysis")
    print("=" * 60)

    # Simulate a network with redundant paths
    # Nodes represent routers, cycles represent redundant paths
    cycle_supports = SupportFamily([
        frozenset({0, 1, 2}),       # Redundant path through routers 0-1-2
        frozenset({1, 2, 3}),       # Redundant path through routers 1-2-3
        frozenset({3, 4, 5}),       # Redundant path through routers 3-4-5
        frozenset({7, 8, 9}),       # Redundant path through routers 7-8-9
        frozenset({8, 9, 10}),      # Redundant path through routers 8-9-10
    ])

    classes = compute_overlap_classes(cycle_supports)
    print(f"\nNetwork has {cycle_supports.n} redundant path groups")
    print(f"Found {len(classes)} independent failure domains:")
    for i, cls in enumerate(classes):
        routers = set()
        for idx in cls:
            routers |= cycle_supports.supports[idx]
        print(f"  Domain {i+1}: paths {cls}, routers {sorted(routers)}")

    print(f"\nOverlap degree: {overlap_degree(cycle_supports)}")
    print(f"Overlap signature: {overlap_signature(cycle_supports)}")
    print("\nInterpretation: Domains are completely independent —")
    print("a failure in one domain cannot cascade to another.")


# ============================================================
# Application 2: Error-Correcting Codes — Codeword Support Clustering
# ============================================================

def app_coding_theory():
    """Analyze support patterns of minimum-weight codewords.

    In coding theory, the supports of minimum-weight codewords reveal the
    redundancy structure of the code. Overlap classes identify groups of
    codewords that share coordinates — these are the interaction sectors
    of the code's error-correcting capability.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Error-Correcting Code Analysis")
    print("=" * 60)

    # Simulated codeword supports from a [15,7,5] BCH code
    codeword_supports = SupportFamily([
        frozenset({0, 1, 3, 7, 14}),
        frozenset({1, 2, 4, 8, 14}),
        frozenset({5, 6, 9, 10, 11}),
        frozenset({6, 7, 10, 11, 12}),
        frozenset({3, 4, 5, 13, 14}),
    ])

    classes = compute_overlap_classes(codeword_supports)
    print(f"\nCode has {codeword_supports.n} minimum-weight codewords")
    print(f"Found {len(classes)} interaction clusters:")
    for i, cls in enumerate(classes):
        coords = set()
        for idx in cls:
            coords |= codeword_supports.supports[idx]
        print(f"  Cluster {i+1}: codewords {cls}, coordinates {sorted(coords)}")

    print(f"\nOverlap degree: {overlap_degree(codeword_supports)}")
    print(f"Overlap signature: {overlap_signature(codeword_supports)}")
    print("\nInterpretation: Codewords in the same cluster interact —")
    print("their error-correcting capabilities are coupled.")
    print("Codewords in different clusters operate independently.")


# ============================================================
# Application 3: Chemistry — Bond Interaction Patterns
# ============================================================

def app_chemistry():
    """Analyze interaction patterns in a molecular ring system.

    In chemistry, fused ring systems have cycles that share bonds (edges)
    and atoms (vertices). Overlap classes of cycle supports identify
    independent subsystems of the molecule.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Molecular Ring System Analysis")
    print("=" * 60)

    # Naphthalene (two fused benzene rings sharing atoms 4,5)
    # Ring 1: atoms 0-1-2-3-4-5
    # Ring 2: atoms 4-5-6-7-8-9
    naphthalene_rings = SupportFamily([
        frozenset({0, 1, 2, 3, 4, 5}),   # Ring 1
        frozenset({4, 5, 6, 7, 8, 9}),   # Ring 2
    ])

    # Biphenyl (two benzene rings connected but not fused)
    # Ring 1: atoms 0-1-2-3-4-5
    # Ring 2: atoms 6-7-8-9-10-11
    biphenyl_rings = SupportFamily([
        frozenset({0, 1, 2, 3, 4, 5}),
        frozenset({6, 7, 8, 9, 10, 11}),
    ])

    print("\n--- Naphthalene (fused rings) ---")
    print(f"Ring supports: {[sorted(s) for s in naphthalene_rings.supports]}")
    classes = compute_overlap_classes(naphthalene_rings)
    print(f"Overlap classes: {classes}")
    print(f"Overlap degree: {overlap_degree(naphthalene_rings)}")
    shared = naphthalene_rings.supports[0] & naphthalene_rings.supports[1]
    print(f"Shared atoms: {sorted(shared)}")
    print("→ One interaction cluster: rings are coupled")

    print("\n--- Biphenyl (connected but not fused) ---")
    print(f"Ring supports: {[sorted(s) for s in biphenyl_rings.supports]}")
    classes = compute_overlap_classes(biphenyl_rings)
    print(f"Overlap classes: {classes}")
    print(f"Overlap degree: {overlap_degree(biphenyl_rings)}")
    print("→ Two independent clusters: rings are decoupled")


# ============================================================
# Application 4: Community Detection — Overlapping Communities
# ============================================================

def app_community_detection():
    """Use overlap classes to identify meta-communities.

    When communities (detected by any method) share members, the overlap
    class structure reveals which communities are entangled and which
    operate independently.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Social Network Meta-Community Analysis")
    print("=" * 60)

    # Communities in a social network
    communities = SupportFamily([
        frozenset({0, 1, 2, 3}),          # Work team A
        frozenset({2, 3, 4, 5}),          # Work team B (shares members with A)
        frozenset({10, 11, 12, 13}),      # Sports club
        frozenset({12, 13, 14, 15}),      # Neighborhood group
        frozenset({20, 21, 22}),          # Online forum (isolated)
    ])

    classes = compute_overlap_classes(communities)
    labels = ['Work A', 'Work B', 'Sports', 'Neighborhood', 'Forum']
    print(f"\n{communities.n} communities detected")
    for i, s in enumerate(communities.supports):
        print(f"  {labels[i]}: members {sorted(s)}")

    print(f"\nMeta-community analysis:")
    print(f"Found {len(classes)} independent social spheres:")
    for i, cls in enumerate(classes):
        names = [labels[j] for j in cls]
        members = set()
        for idx in cls:
            members |= communities.supports[idx]
        print(f"  Sphere {i+1}: {names}")
        print(f"    Total members: {sorted(members)}")

    print(f"\nOverlap degree: {overlap_degree(communities)}")
    print(f"Overlap signature: {overlap_signature(communities)}")
    print("\nInterpretation: Information spreads within spheres but not across them.")
    print("This identifies natural boundaries for targeted communication.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    app_network_topology()
    app_coding_theory()
    app_chemistry()
    app_community_detection()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
demo.py — Interactive Demonstration of Overlap Class Theory

Demonstrates:
1. Construction and visualization of support overlap graphs
2. Overlap class computation for various graph families
3. Conjecture testing on small connected graphs
4. TPE invariance of variation supports

Run: python demo.py
"""

from collections import defaultdict, deque
from itertools import combinations, permutations
from typing import List, Set, Tuple, Dict, FrozenSet, Optional


# ============================================================
# Self-contained implementations (no local imports)
# ============================================================

class SupportFamily:
    def __init__(self, supports: List[FrozenSet[int]]):
        self.supports = list(supports)
        self.n = len(supports)

    def __repr__(self):
        return f"SupportFamily({[set(s) for s in self.supports]})"


class SimpleGraph:
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.edges_list = []
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)
                if u < v:
                    self.edges_list.append((u, v))
                else:
                    self.edges_list.append((v, u))
        self.edges_list = list(set(self.edges_list))

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited = set()
        queue = deque([0])
        visited.add(0)
        while queue:
            v = queue.popleft()
            for w in self.adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    return len(A & B) > 0


def compute_overlap_classes(family: SupportFamily) -> List[List[int]]:
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i, j in combinations(range(family.n), 2):
        if supports_overlap(family.supports[i], family.supports[j]):
            adj[i].add(j)
            adj[j].add(i)

    visited = set()
    classes = []
    for start in range(family.n):
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            component.append(v)
            for w in adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        classes.append(sorted(component))
    return classes


def overlap_degree(family: SupportFamily) -> int:
    count = 0
    for i, j in combinations(range(family.n), 2):
        if supports_overlap(family.supports[i], family.supports[j]):
            count += 1
    return count


def overlap_signature(family: SupportFamily) -> List[int]:
    sizes = []
    for i, j in combinations(range(family.n), 2):
        isect = len(family.supports[i] & family.supports[j])
        if isect > 0:
            sizes.append(isect)
    return sorted(sizes)


def find_cycles_dfs(adj_S: Dict[int, Set[int]], vertices: List[int]) -> List[List[int]]:
    visited = set()
    parent = {}
    cycles = []

    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in sorted(adj_S[v]):
            if w == p:
                continue
            if w in visited:
                # Trace back to find the cycle
                cycle = [w]
                curr = v
                safety = 0
                while curr != w and curr is not None and safety < len(vertices) + 1:
                    cycle.append(curr)
                    curr = parent.get(curr)
                    safety += 1
                if curr == w:
                    cycles.append(cycle)
            else:
                dfs(w, v)

    for v in vertices:
        if v not in visited:
            dfs(v, None)
    return cycles


def cycle_support_family(G: SimpleGraph, S: Set[int]) -> SupportFamily:
    vertices = sorted(S)
    adj_S: Dict[int, Set[int]] = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_S[u].add(v)
    cycles = find_cycles_dfs(adj_S, vertices)
    supports = [frozenset(c) for c in cycles]
    return SupportFamily(supports)


def generate_connected_graphs(n: int) -> List[SimpleGraph]:
    if n <= 0:
        return []
    if n == 1:
        return [SimpleGraph(1, [])]
    all_possible_edges = list(combinations(range(n), 2))
    m = len(all_possible_edges)
    graphs = []
    for mask in range(1, 1 << m):
        edges = [all_possible_edges[i] for i in range(m) if mask & (1 << i)]
        G = SimpleGraph(n, edges)
        if G.is_connected():
            graphs.append(G)
    return graphs


# ============================================================
# Demo functions
# ============================================================

def demo_basic_overlap():
    """Demonstrate basic overlap analysis."""
    print("=" * 60)
    print("DEMO 1: Basic Overlap Analysis")
    print("=" * 60)

    # A family with interesting overlap structure
    family = SupportFamily([
        frozenset({0, 1, 2}),      # Support A
        frozenset({2, 3, 4}),      # Support B (overlaps A at {2})
        frozenset({5, 6}),         # Support C (isolated)
        frozenset({6, 7, 8}),      # Support D (overlaps C at {6})
        frozenset({10, 11}),       # Support E (isolated)
    ])

    print(f"\nSupport family:")
    for i, s in enumerate(family.supports):
        print(f"  S_{i} = {sorted(s)}")

    print(f"\nOverlap degree: {overlap_degree(family)}")
    print(f"Overlap signature: {overlap_signature(family)}")

    classes = compute_overlap_classes(family)
    print(f"\nOverlap classes ({len(classes)} total):")
    for i, cls in enumerate(classes):
        supports_in_class = [sorted(family.supports[j]) for j in cls]
        print(f"  Class {i}: indices {cls}")
        for j in cls:
            print(f"    S_{j} = {sorted(family.supports[j])}")

    # Verify: supports from different classes are disjoint
    print("\nVerification — cross-class disjointness:")
    for ci, cj in combinations(range(len(classes)), 2):
        union_i = set().union(*(family.supports[k] for k in classes[ci]))
        union_j = set().union(*(family.supports[k] for k in classes[cj]))
        disjoint = len(union_i & union_j) == 0
        print(f"  Class {ci} ∪ vs Class {cj} ∪: {'DISJOINT ✓' if disjoint else 'OVERLAP ✗'}")


def demo_disjoint_recovery():
    """Show that overlap degree zero recovers the disjoint theory."""
    print("\n" + "=" * 60)
    print("DEMO 2: Disjoint Recovery (Overlap Degree Zero)")
    print("=" * 60)

    family = SupportFamily([
        frozenset({0, 1}),
        frozenset({2, 3}),
        frozenset({4, 5}),
        frozenset({6, 7}),
    ])

    print(f"\nPairwise disjoint family:")
    for i, s in enumerate(family.supports):
        print(f"  S_{i} = {sorted(s)}")

    deg = overlap_degree(family)
    classes = compute_overlap_classes(family)
    n = family.n

    print(f"\nOverlap degree: {deg}")
    print(f"Overlap class count: {len(classes)}")
    print(f"Family size n: {n}")
    print(f"\nTheorem verification:")
    print(f"  overlap_degree = 0: {deg == 0} ✓")
    print(f"  class_count = n = {n}: {len(classes) == n} ✓")
    print(f"  This recovers the disjoint-support uniqueness theorem.")


def demo_graph_cycles():
    """Analyze cycle supports in specific graphs."""
    print("\n" + "=" * 60)
    print("DEMO 3: Graph Cycle Support Analysis")
    print("=" * 60)

    # K4 (complete graph on 4 vertices)
    print("\n--- Complete Graph K4 ---")
    K4 = SimpleGraph(4, [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)])
    S = {0, 1, 2, 3}
    F = cycle_support_family(K4, S)
    print(f"Vertices: {sorted(S)}")
    print(f"Edges: {K4.edges_list}")
    print(f"Number of fundamental cycles: {F.n}")
    for i, s in enumerate(F.supports):
        print(f"  Cycle {i}: {sorted(s)}")
    print(f"Overlap degree: {overlap_degree(F)}")
    print(f"Overlap classes: {compute_overlap_classes(F)}")

    # Theta graph (two paths between vertices)
    print("\n--- Theta Graph (0-1-2, 0-3-2) ---")
    theta = SimpleGraph(4, [(0,1), (1,2), (0,3), (3,2)])
    S = {0, 1, 2, 3}
    F = cycle_support_family(theta, S)
    print(f"Vertices: {sorted(S)}")
    print(f"Edges: {theta.edges_list}")
    print(f"Number of fundamental cycles: {F.n}")
    for i, s in enumerate(F.supports):
        print(f"  Cycle {i}: {sorted(s)}")
    print(f"Overlap degree: {overlap_degree(F)}")
    print(f"Overlap classes: {compute_overlap_classes(F)}")

    # Two disjoint triangles connected by a bridge
    print("\n--- Two Triangles Connected by Bridge ---")
    G = SimpleGraph(6, [(0,1), (1,2), (2,0), (2,3), (3,4), (4,5), (5,3)])
    S = {0, 1, 2, 3, 4, 5}
    F = cycle_support_family(G, S)
    print(f"Vertices: {sorted(S)}")
    print(f"Edges: {G.edges_list}")
    print(f"Number of fundamental cycles: {F.n}")
    for i, s in enumerate(F.supports):
        print(f"  Cycle {i}: {sorted(s)}")
    print(f"Overlap degree: {overlap_degree(F)}")
    classes = compute_overlap_classes(F)
    print(f"Overlap classes: {classes}")
    print(f"Overlap class count: {len(classes)}")


def demo_tpe_invariance():
    """Demonstrate that variation supports are TPE-invariant."""
    print("\n" + "=" * 60)
    print("DEMO 4: TPE Invariance of Variation Supports")
    print("=" * 60)

    # Original family of functions
    F1 = [
        [1, 0, 3, 2],   # f_0
        [0, 2, 0, 1],   # f_1
        [4, 4, 0, 4],   # f_2
    ]

    # TPE: permutation (0→1, 1→2, 2→0), constants c = (5, -3, 10)
    perm = [1, 2, 0]
    constants = [5, -3, 10]

    F2 = [None, None, None]
    for i in range(3):
        j = perm[i]
        F2[j] = [F1[i][v] + constants[i] for v in range(4)]

    print("\nOriginal family F₁:")
    for i, f in enumerate(F1):
        print(f"  f_{i} = {f}")

    print(f"\nTPE: σ = {perm}, c = {constants}")

    print("\nTransformed family F₂:")
    for i, f in enumerate(F2):
        print(f"  g_{i} = {f}")

    # Variation supports (relative to v₀ = 0)
    v0 = 0
    print(f"\nVariation supports (basepoint v₀ = {v0}):")

    var_supp_F1 = []
    var_supp_F2 = []
    for i in range(3):
        vs1 = frozenset(v for v in range(4) if F1[i][v] != F1[i][v0])
        vs2 = frozenset(v for v in range(4) if F2[i][v] != F2[i][v0])
        var_supp_F1.append(vs1)
        var_supp_F2.append(vs2)
        print(f"  VarSupp(f_{i}) = {sorted(vs1)}")

    print()
    for i in range(3):
        print(f"  VarSupp(g_{i}) = {sorted(var_supp_F2[i])}")

    # Check that σ maps var supports correctly
    print(f"\nTPE maps variation supports:")
    for i in range(3):
        j = perm[i]
        match = var_supp_F1[i] == var_supp_F2[j]
        print(f"  VarSupp(f_{i}) = VarSupp(g_{j}): {match} {'✓' if match else '✗'}")

    # Check overlap preservation
    fam1 = SupportFamily(var_supp_F1)
    fam2 = SupportFamily([var_supp_F2[perm[i]] for i in range(3)])
    print(f"\nOverlap degree (F₁ var supports): {overlap_degree(fam1)}")
    print(f"Overlap degree (F₂ σ-reindexed var supports): {overlap_degree(fam2)}")
    print(f"Overlap classes (F₁): {compute_overlap_classes(fam1)}")
    print(f"Overlap classes (F₂ σ-reindexed): {compute_overlap_classes(fam2)}")


def demo_batch_search():
    """Search for conjecture evidence on small graphs."""
    print("\n" + "=" * 60)
    print("DEMO 5: Batch Conjecture Search")
    print("=" * 60)

    max_n = 6
    print(f"\nSearching all connected graphs on n ≤ {max_n} vertices...")

    total_instances = 0
    nontrivial_instances = 0
    max_overlap_deg = 0
    max_class_count = 0
    interesting_examples = []

    for n in range(2, max_n + 1):
        graphs = generate_connected_graphs(n)
        count_n = 0
        for G in graphs:
            for q in range(n):
                S = set(range(n)) - {q}
                F = cycle_support_family(G, S)
                total_instances += 1
                count_n += 1

                if F.n > 0:
                    nontrivial_instances += 1
                    od = overlap_degree(F)
                    cc = len(compute_overlap_classes(F))
                    max_overlap_deg = max(max_overlap_deg, od)
                    max_class_count = max(max_class_count, cc)

                    if od > 0 and len(interesting_examples) < 5:
                        interesting_examples.append({
                            'n': n,
                            'edges': G.edges_list,
                            'q': q,
                            'S': sorted(S),
                            'cycles': [sorted(s) for s in F.supports],
                            'overlap_degree': od,
                            'overlap_classes': compute_overlap_classes(F),
                        })

        print(f"  n = {n}: {len(graphs)} graphs, {count_n} instances")

    print(f"\nSummary:")
    print(f"  Total instances: {total_instances}")
    print(f"  Nontrivial (has cycles): {nontrivial_instances}")
    print(f"  Max overlap degree: {max_overlap_deg}")
    print(f"  Max overlap class count: {max_class_count}")

    if interesting_examples:
        print(f"\nInteresting examples with overlap (first {len(interesting_examples)}):")
        for i, ex in enumerate(interesting_examples):
            print(f"\n  Example {i+1}:")
            print(f"    Graph: n={ex['n']}, edges={ex['edges']}")
            print(f"    Basepoint: q={ex['q']}, S={ex['S']}")
            print(f"    Cycles: {ex['cycles']}")
            print(f"    Overlap degree: {ex['overlap_degree']}")
            print(f"    Overlap classes: {ex['overlap_classes']}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_basic_overlap()
    demo_disjoint_recovery()
    demo_graph_cycles()
    demo_tpe_invariance()
    demo_batch_search()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Overlap Degree Spectrum — Distribution of Overlap Complexity

Visualizes how overlap degree varies across all connected graphs of
a given size, showing the distribution from the fully disjoint regime
(degree 0) to the maximally overlapping regime.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque, Counter
from itertools import combinations
from typing import List, Set, Dict, FrozenSet, Tuple


# ============================================================
# Self-contained implementations
# ============================================================

class SupportFamily:
    def __init__(self, supports):
        self.supports = list(supports)
        self.n = len(supports)


class SimpleGraph:
    def __init__(self, n, edges):
        self.n = n
        self.adj = defaultdict(set)
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def is_connected(self):
        if self.n == 0:
            return True
        visited = set()
        queue = deque([0])
        visited.add(0)
        while queue:
            v = queue.popleft()
            for w in self.adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


def overlap_degree(family):
    count = 0
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            count += 1
    return count


def overlap_class_count(family):
    adj = defaultdict(set)
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    count = 0
    for start in range(family.n):
        if start in visited:
            continue
        count += 1
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            for w in adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
    return count


def find_cycles(adj_S, vertices):
    visited = set()
    parent = {}
    cycles = []
    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in adj_S[v]:
            if w == p:
                continue
            if w in visited:
                cycle = [w]
                curr = v
                while curr != w:
                    cycle.append(curr)
                    curr = parent[curr]
                cycles.append(cycle)
            else:
                dfs(w, v)
    for v in vertices:
        if v not in visited:
            dfs(v, -1)
    return cycles


def cycle_support_family(G, S):
    vertices = sorted(S)
    adj_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_S[u].add(v)
    cycles = find_cycles(adj_S, vertices)
    return SupportFamily([frozenset(c) for c in cycles])


def generate_connected_graphs(n):
    if n <= 1:
        return [SimpleGraph(max(n, 1), [])]
    all_edges = list(combinations(range(n), 2))
    m = len(all_edges)
    graphs = []
    for mask in range(1, 1 << m):
        edges = [all_edges[i] for i in range(m) if mask & (1 << i)]
        G = SimpleGraph(n, edges)
        if G.is_connected():
            graphs.append(G)
    return graphs


# ============================================================
# Visualization
# ============================================================

def visualize_degree_spectrum():
    """Create a multi-panel visualization of overlap degree statistics."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Overlap Degree Spectrum Across Graph Families',
                 fontsize=16, fontweight='bold')

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']

    # Collect data for n = 3, 4, 5, 6
    all_data = {}
    for n in [3, 4, 5, 6]:
        graphs = generate_connected_graphs(n)
        degrees = []
        class_counts = []
        num_cycles_list = []

        for G in graphs:
            for q in range(n):
                S = set(range(n)) - {q}
                F = cycle_support_family(G, S)
                if F.n > 0:
                    degrees.append(overlap_degree(F))
                    class_counts.append(overlap_class_count(F))
                    num_cycles_list.append(F.n)

        all_data[n] = {
            'degrees': degrees,
            'class_counts': class_counts,
            'num_cycles': num_cycles_list,
            'num_graphs': len(graphs),
        }

    # ---- Panel 1: Overlap Degree Distribution ----
    ax1 = axes[0, 0]
    ax1.set_title('Overlap Degree Distribution', fontweight='bold')

    for idx, n in enumerate([3, 4, 5, 6]):
        if all_data[n]['degrees']:
            counts = Counter(all_data[n]['degrees'])
            max_deg = max(counts.keys()) if counts else 0
            xs = list(range(max_deg + 1))
            ys = [counts.get(x, 0) for x in xs]
            ax1.bar([x + idx * 0.2 - 0.3 for x in xs], ys, width=0.18,
                   label=f'n={n}', color=colors[idx], alpha=0.8)

    ax1.set_xlabel('Overlap Degree')
    ax1.set_ylabel('Count')
    ax1.legend(fontsize=9)
    ax1.grid(axis='y', alpha=0.3)

    # ---- Panel 2: Class Count Distribution ----
    ax2 = axes[0, 1]
    ax2.set_title('Overlap Class Count Distribution', fontweight='bold')

    for idx, n in enumerate([3, 4, 5, 6]):
        if all_data[n]['class_counts']:
            counts = Counter(all_data[n]['class_counts'])
            max_cc = max(counts.keys()) if counts else 0
            xs = list(range(1, max_cc + 1))
            ys = [counts.get(x, 0) for x in xs]
            ax2.bar([x + idx * 0.2 - 0.3 for x in xs], ys, width=0.18,
                   label=f'n={n}', color=colors[idx], alpha=0.8)

    ax2.set_xlabel('Number of Overlap Classes')
    ax2.set_ylabel('Count')
    ax2.legend(fontsize=9)
    ax2.grid(axis='y', alpha=0.3)

    # ---- Panel 3: Degree vs Class Count Scatter ----
    ax3 = axes[1, 0]
    ax3.set_title('Overlap Degree vs Class Count', fontweight='bold')

    for idx, n in enumerate([4, 5, 6]):
        if all_data[n]['degrees']:
            ax3.scatter(all_data[n]['degrees'], all_data[n]['class_counts'],
                       alpha=0.4, s=20, color=colors[idx + 1], label=f'n={n}')

    ax3.set_xlabel('Overlap Degree')
    ax3.set_ylabel('Overlap Class Count')
    ax3.legend(fontsize=9)
    ax3.grid(alpha=0.3)

    # ---- Panel 4: Summary Statistics ----
    ax4 = axes[1, 1]
    ax4.set_title('Summary Statistics', fontweight='bold')
    ax4.axis('off')

    rows = ['n', 'Graphs', 'Instances', 'Mean Degree', 'Max Degree',
            'Mean Classes']
    cell_data = []
    for n in [3, 4, 5, 6]:
        d = all_data[n]
        if d['degrees']:
            cell_data.append([
                str(n),
                str(d['num_graphs']),
                str(len(d['degrees'])),
                f"{np.mean(d['degrees']):.2f}",
                str(max(d['degrees'])),
                f"{np.mean(d['class_counts']):.2f}",
            ])
        else:
            cell_data.append([str(n), str(d['num_graphs']), '0',
                            '-', '-', '-'])

    table = ax4.table(cellText=list(zip(*cell_data)),
                     rowLabels=rows,
                     colLabels=[f'n={n}' for n in [3, 4, 5, 6]],
                     cellLoc='center',
                     loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 1.4)

    # Color header row
    for j in range(4):
        table[0, j].set_facecolor(colors[j])
        table[0, j].set_text_props(color='white', fontweight='bold')

    plt.tight_layout()
    plt.savefig('overlap_degree_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: overlap_degree_spectrum.png")


if __name__ == "__main__":
    visualize_degree_spectrum()


"""
Overlap Class Visualization — Support Interaction Graph

Visualizes the core mathematical concept: how overlapping supports
decompose into independent interaction sectors (overlap classes).
Shows a family of supports, their overlap graph, and the resulting
class decomposition with color-coding.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict, deque
from itertools import combinations
from typing import List, Set, Dict, FrozenSet


# ============================================================
# Self-contained implementations
# ============================================================

class SupportFamily:
    def __init__(self, supports):
        self.supports = list(supports)
        self.n = len(supports)


def compute_overlap_classes(family):
    adj = defaultdict(set)
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(family.n):
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            component.append(v)
            for w in adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        classes.append(sorted(component))
    return classes


def overlap_degree(family):
    count = 0
    for i, j in combinations(range(family.n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            count += 1
    return count


# ============================================================
# Visualization
# ============================================================

def visualize_overlap_classes():
    """Create a comprehensive visualization of overlap class theory."""

    # Define a rich support family
    family = SupportFamily([
        frozenset({0, 1, 2, 3}),       # S₀
        frozenset({2, 3, 4, 5}),       # S₁ (overlaps S₀)
        frozenset({4, 5, 6}),          # S₂ (overlaps S₁)
        frozenset({10, 11, 12}),       # S₃ (isolated cluster)
        frozenset({12, 13, 14}),       # S₄ (overlaps S₃)
        frozenset({20, 21}),           # S₅ (singleton class)
    ])

    classes = compute_overlap_classes(family)

    # Color scheme for classes
    class_colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']
    idx_to_class = {}
    for ci, cls in enumerate(classes):
        for idx in cls:
            idx_to_class[idx] = ci

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Overlap Class Decomposition of Support Families',
                 fontsize=16, fontweight='bold', y=0.98)

    # ---- Panel 1: Support Sets as Intervals ----
    ax1 = axes[0]
    ax1.set_title('Support Family', fontsize=13, fontweight='bold')

    all_elements = set()
    for s in family.supports:
        all_elements |= s
    elem_list = sorted(all_elements)
    elem_to_x = {e: i for i, e in enumerate(elem_list)}

    for i in range(family.n):
        color = class_colors[idx_to_class[i] % len(class_colors)]
        y = family.n - 1 - i
        elements = sorted(family.supports[i])
        xs = [elem_to_x[e] for e in elements]
        ax1.scatter(xs, [y] * len(xs), color=color, s=80, zorder=5,
                   edgecolors='black', linewidths=0.5)
        # Connect elements with a line
        if len(xs) > 1:
            ax1.plot([min(xs) - 0.2, max(xs) + 0.2], [y, y],
                    color=color, linewidth=3, alpha=0.3)
        ax1.text(-1.5, y, f'S{i}', fontsize=11, ha='right', va='center',
                fontweight='bold', color=color)

    ax1.set_xlim(-2.5, len(elem_list))
    ax1.set_ylim(-0.5, family.n - 0.5)
    ax1.set_xlabel('Ground Set Elements', fontsize=10)
    ax1.set_xticks(range(len(elem_list)))
    ax1.set_xticklabels(elem_list, fontsize=8)
    ax1.set_yticks([])
    ax1.spines['top'].set_visible(False)
    ax1.spines['right'].set_visible(False)
    ax1.spines['left'].set_visible(False)

    # ---- Panel 2: Overlap Graph ----
    ax2 = axes[1]
    ax2.set_title('Support Overlap Graph', fontsize=13, fontweight='bold')

    # Position nodes in a circle
    n = family.n
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) - np.pi/2
    radius = 1.5
    positions = [(radius * np.cos(a), radius * np.sin(a)) for a in angles]

    # Draw edges
    for i, j in combinations(range(n), 2):
        if len(family.supports[i] & family.supports[j]) > 0:
            isect_size = len(family.supports[i] & family.supports[j])
            x1, y1 = positions[i]
            x2, y2 = positions[j]
            ax2.plot([x1, x2], [y1, y2], 'k-', linewidth=1 + isect_size,
                    alpha=0.3, zorder=1)
            # Label edge with intersection size
            mx, my = (x1+x2)/2, (y1+y2)/2
            ax2.text(mx, my + 0.15, f'{isect_size}', fontsize=8,
                    ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                            edgecolor='gray', alpha=0.8))

    # Draw nodes
    for i in range(n):
        color = class_colors[idx_to_class[i] % len(class_colors)]
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.25, color=color, ec='black',
                           linewidth=1.5, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x, y, f'S{i}', fontsize=10, ha='center', va='center',
                fontweight='bold', color='white', zorder=6)

    ax2.set_xlim(-2.5, 2.5)
    ax2.set_ylim(-2.5, 2.5)
    ax2.set_aspect('equal')
    ax2.axis('off')

    # ---- Panel 3: Class Decomposition ----
    ax3 = axes[2]
    ax3.set_title('Overlap Classes', fontsize=13, fontweight='bold')

    for ci, cls in enumerate(classes):
        color = class_colors[ci % len(class_colors)]
        y_base = len(classes) - 1 - ci

        # Draw class box
        rect = mpatches.FancyBboxPatch(
            (0.1, y_base - 0.35), 3.8, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=color, alpha=0.15, edgecolor=color, linewidth=2
        )
        ax3.add_patch(rect)

        # Class label
        ax3.text(0.3, y_base + 0.15, f'Class {ci+1}',
                fontsize=11, fontweight='bold', color=color)

        # Members
        members = ', '.join(f'S{j}' for j in cls)
        ax3.text(0.3, y_base - 0.15, members,
                fontsize=10, color='black')

        # Union of supports
        union = set()
        for idx in cls:
            union |= family.supports[idx]
        ax3.text(2.5, y_base, f'∪ = {sorted(union)}',
                fontsize=8, color='gray', va='center')

    ax3.set_xlim(0, 4)
    ax3.set_ylim(-0.5, len(classes) - 0.5)
    ax3.axis('off')

    # Add summary text
    od = overlap_degree(family)
    fig.text(0.5, 0.02,
            f'Family size: {n} supports | Overlap degree: {od} | '
            f'Overlap classes: {len(classes)} | '
            f'Key theorem: supports across classes are disjoint',
            ha='center', fontsize=10, style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow',
                     edgecolor='orange', alpha=0.8))

    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig('overlap_classes_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: overlap_classes_visualization.png")


if __name__ == "__main__":
    visualize_overlap_classes()
