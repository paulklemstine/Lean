"""
Applications of Overlap Class Theory

Demonstrates real-world applications of overlap class analysis to:
1. Network analysis — partitioning feedback loops
2. Coding theory — analyzing support overlap of codewords
3. Social network clustering — community detection via shared members
"""

from typing import List, Set, Dict, FrozenSet, Tuple
from collections import defaultdict
from itertools import combinations


# ========== Core algorithms (inlined) ==========

def supports_overlap(a: FrozenSet[int], b: FrozenSet[int]) -> bool:
    return len(a & b) > 0

def find_overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    n = len(family)
    if n == 0:
        return []
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                union(i, j)
    classes: Dict[int, List[int]] = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())

def max_intersection_size(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return max((len(family[i] & family[j]) for i in range(n) for j in range(i+1,n)), default=0)

def total_overlap_complexity(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(len(family[i] & family[j]) for i in range(n) for j in range(i+1,n))

def element_nerve(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    nerve: Dict[int, Set[int]] = defaultdict(set)
    for i, s in enumerate(family):
        for x in s:
            nerve[x].add(i)
    return dict(nerve)


# ========== Application 1: Network Feedback Loop Analysis ==========

def analyze_network_feedback():
    """Analyze feedback loops in a small network (e.g., metabolic or signaling).

    Each cycle in the network represents a feedback loop.
    Loops sharing nodes are functionally coupled.
    Overlap classes identify independent interaction sectors.
    """
    print("=" * 60)
    print("Application 1: Network Feedback Loop Analysis")
    print("=" * 60)

    # Model: A simplified metabolic network
    # Nodes represent metabolites, edges represent reactions
    metabolite_names = {
        0: "Glucose", 1: "Pyruvate", 2: "Acetyl-CoA", 3: "Citrate",
        4: "Oxaloacetate", 5: "Succinate", 6: "Fumarate",
        7: "Lactate", 8: "Ethanol"
    }

    # Feedback loops (cycle supports)
    loops = [
        frozenset({0, 1, 7}),          # Glycolysis-Lactate cycle
        frozenset({1, 2, 3, 4}),       # TCA entry cycle
        frozenset({3, 4, 5, 6}),       # TCA main cycle
        frozenset({0, 1, 8}),          # Fermentation cycle
    ]

    loop_names = [
        "Glycolysis-Lactate", "TCA Entry", "TCA Main", "Fermentation"
    ]

    print("\nFeedback loops in the metabolic network:")
    for i, (name, loop) in enumerate(zip(loop_names, loops)):
        metabs = [metabolite_names[m] for m in sorted(loop)]
        print(f"  Loop {i} ({name}): {metabs}")

    classes = find_overlap_classes(loops)
    print(f"\nOverlap class count: {len(classes)}")
    print("Interaction sectors:")
    for i, cls in enumerate(classes):
        names = [loop_names[j] for j in cls]
        print(f"  Sector {i}: {names}")
        shared = set()
        for a, b in combinations(cls, 2):
            shared |= loops[a] & loops[b]
        if shared:
            shared_names = [metabolite_names[m] for m in sorted(shared)]
            print(f"    Coupled through: {shared_names}")

    print(f"\nMax intersection size: {max_intersection_size(loops)}")
    print(f"Total overlap complexity: {total_overlap_complexity(loops)}")

    nerve = element_nerve(loops)
    print("\nMetabolite participation (element nerve):")
    for node in sorted(nerve.keys()):
        if len(nerve[node]) > 1:
            name = metabolite_names[node]
            loop_list = [loop_names[j] for j in sorted(nerve[node])]
            print(f"  {name}: participates in {loop_list}")


# ========== Application 2: Coding Theory ==========

def analyze_code_supports():
    """Analyze overlap structure of minimum-weight codeword supports.

    In a linear code, the support of a codeword is the set of nonzero positions.
    Overlap among minimum-weight codeword supports reveals redundancy structure.
    """
    print("\n" + "=" * 60)
    print("Application 2: Coding Theory — Codeword Support Analysis")
    print("=" * 60)

    # Example: [7,4,3] Hamming code minimum-weight codewords
    # The minimum weight is 3; there are 7 minimum-weight codewords
    # (up to sign), corresponding to the 7 rows of the parity check matrix
    codeword_supports = [
        frozenset({0, 1, 3}),  # codeword 1
        frozenset({1, 2, 4}),  # codeword 2
        frozenset({2, 3, 5}),  # codeword 3
        frozenset({3, 4, 6}),  # codeword 4
        frozenset({0, 4, 5}),  # codeword 5
        frozenset({1, 5, 6}),  # codeword 6
        frozenset({0, 2, 6}),  # codeword 7
    ]

    print("\n[7,4,3] Hamming code minimum-weight codeword supports:")
    for i, s in enumerate(codeword_supports):
        print(f"  Codeword {i}: positions {set(s)}")

    classes = find_overlap_classes(codeword_supports)
    print(f"\nOverlap class count: {len(classes)}")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: codewords {cls}")

    print(f"\nMax intersection size: {max_intersection_size(codeword_supports)}")
    print(f"Total overlap complexity: {total_overlap_complexity(codeword_supports)}")

    nerve = element_nerve(codeword_supports)
    print("\nPosition participation (element nerve):")
    for pos in sorted(nerve.keys()):
        print(f"  Position {pos}: appears in codewords {sorted(nerve[pos])}")

    print("\nInterpretation:")
    print("  All codeword supports are in one overlap class — the code")
    print("  has a single 'interaction sector'. This reflects the fact")
    print("  that the Hamming code is 'tight': every pair of positions")
    print("  appears together in exactly one minimum-weight codeword.")


# ========== Application 3: Social Network Community Detection ==========

def analyze_social_communities():
    """Detect communities using overlap of group memberships.

    Each 'support' is the set of groups a person belongs to.
    People whose group memberships overlap are connected.
    Overlap classes identify social clusters.
    """
    print("\n" + "=" * 60)
    print("Application 3: Social Network — Community Detection via Overlap")
    print("=" * 60)

    # Groups in a university department
    group_names = {
        0: "Faculty Council", 1: "Grad Committee", 2: "Seminar Series",
        3: "Lab Group A", 4: "Lab Group B", 5: "Teaching Team",
        6: "External Collab X", 7: "External Collab Y"
    }

    # Each person's set of group memberships
    people = {
        "Alice":   frozenset({0, 1, 2}),
        "Bob":     frozenset({1, 3}),
        "Carol":   frozenset({2, 3, 5}),
        "Dave":    frozenset({4, 5}),
        "Eve":     frozenset({6, 7}),
        "Frank":   frozenset({7}),
    }

    print("\nGroup memberships:")
    for name, groups in people.items():
        group_list = [group_names[g] for g in sorted(groups)]
        print(f"  {name}: {group_list}")

    family = list(people.values())
    names = list(people.keys())

    classes = find_overlap_classes(family)
    print(f"\nOverlap class count: {len(classes)} (= number of social clusters)")
    for i, cls in enumerate(classes):
        cluster_names = [names[j] for j in cls]
        print(f"  Cluster {i}: {cluster_names}")
        # Find shared groups
        shared_groups: Set[int] = set()
        for a, b in combinations(cls, 2):
            shared_groups |= family[a] & family[b]
        if shared_groups:
            group_list = [group_names[g] for g in sorted(shared_groups)]
            print(f"    Connected through groups: {group_list}")

    print(f"\nMax intersection size: {max_intersection_size(family)}")
    print(f"  (Maximum shared group count between any two people)")

    nerve = element_nerve(family)
    print("\nGroup participation (element nerve):")
    for g in sorted(nerve.keys()):
        members = [names[j] for j in sorted(nerve[g])]
        print(f"  {group_names[g]}: members {members}")


if __name__ == "__main__":
    analyze_network_feedback()
    analyze_code_supports()
    analyze_social_communities()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Interactive Demo: Overlap Class Theory for Cycle Support Families

This script demonstrates the overlap class framework by:
1. Generating example graphs and computing their cycle supports
2. Building support overlap graphs and identifying overlap classes
3. Computing all overlap complexity measures
4. Testing the conjectured relationship between overlap classes and
   tropical projective equivalence classes
5. Running batch searches over small graphs

Usage:
    python demo.py              # Run all demonstrations
    python demo.py --interactive  # Interactive mode (enter your own graphs)
"""

import sys
from itertools import combinations
from collections import defaultdict
from typing import List, Set, Dict, Tuple, FrozenSet, Optional


# ========== Core algorithms (self-contained) ==========

def supports_overlap(a: FrozenSet[int], b: FrozenSet[int]) -> bool:
    """Check if two supports overlap."""
    return len(a & b) > 0


def build_overlap_graph(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    """Build the overlap graph adjacency list."""
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    return adj


def find_overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    """Find connected components of the overlap graph."""
    n = len(family)
    if n == 0:
        return []
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                union(i, j)

    classes: Dict[int, List[int]] = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


def overlap_class_count(family: List[FrozenSet[int]]) -> int:
    return len(find_overlap_classes(family))


def max_intersection_size(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return max((len(family[i] & family[j])
                for i in range(n) for j in range(i+1, n)), default=0)


def total_overlap_complexity(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(len(family[i] & family[j])
               for i in range(n) for j in range(i+1, n))


def overlap_pair_count(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1, n)
               if supports_overlap(family[i], family[j]))


def element_nerve(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    nerve: Dict[int, Set[int]] = defaultdict(set)
    for i, s in enumerate(family):
        for x in s:
            nerve[x].add(i)
    return dict(nerve)


def pairwise_disjoint(family: List[FrozenSet[int]]) -> bool:
    n = len(family)
    return all(not supports_overlap(family[i], family[j])
               for i in range(n) for j in range(i+1, n))


# ========== Graph utilities ==========

def find_all_cycles(adj: Dict[int, Set[int]], vertices: Set[int]) -> List[FrozenSet[int]]:
    """Find all simple cycles in a graph and return their vertex supports.

    Uses DFS-based cycle detection.
    """
    cycles: List[FrozenSet[int]] = []
    vertex_list = sorted(vertices)

    def dfs(start, current, visited, path):
        for neighbor in sorted(adj.get(current, set())):
            if neighbor == start and len(path) >= 3:
                cycle = frozenset(path)
                if cycle not in cycles:
                    cycles.append(cycle)
            elif neighbor not in visited and neighbor > start:
                visited.add(neighbor)
                path.append(neighbor)
                dfs(start, neighbor, visited, path)
                path.pop()
                visited.discard(neighbor)

    for v in vertex_list:
        dfs(v, v, {v}, [v])
    return cycles


def make_complete_graph(n: int) -> Tuple[Set[int], Dict[int, Set[int]]]:
    """Create a complete graph K_n."""
    vertices = set(range(n))
    adj: Dict[int, Set[int]] = {v: set() for v in vertices}
    for i in range(n):
        for j in range(i+1, n):
            adj[i].add(j)
            adj[j].add(i)
    return vertices, adj


def make_cycle_graph(n: int) -> Tuple[Set[int], Dict[int, Set[int]]]:
    """Create a cycle graph C_n."""
    vertices = set(range(n))
    adj: Dict[int, Set[int]] = {v: set() for v in vertices}
    for i in range(n):
        j = (i + 1) % n
        adj[i].add(j)
        adj[j].add(i)
    return vertices, adj


def make_two_triangles_shared_vertex() -> Tuple[Set[int], Dict[int, Set[int]]]:
    """Two triangles sharing one vertex (bowtie/hourglass graph)."""
    vertices = {0, 1, 2, 3, 4}
    adj: Dict[int, Set[int]] = {v: set() for v in vertices}
    edges = [(0,1), (1,2), (0,2), (2,3), (3,4), (2,4)]
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return vertices, adj


def make_two_triangles_shared_edge() -> Tuple[Set[int], Dict[int, Set[int]]]:
    """Two triangles sharing an edge (diamond/K4-e graph)."""
    vertices = {0, 1, 2, 3}
    adj: Dict[int, Set[int]] = {v: set() for v in vertices}
    edges = [(0,1), (1,2), (0,2), (1,3), (2,3)]
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return vertices, adj


def make_two_disjoint_triangles_with_bridge() -> Tuple[Set[int], Dict[int, Set[int]]]:
    """Two disjoint triangles connected by a bridge edge."""
    vertices = {0, 1, 2, 3, 4, 5}
    adj: Dict[int, Set[int]] = {v: set() for v in vertices}
    edges = [(0,1), (1,2), (0,2), (2,3), (3,4), (4,5), (3,5)]
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return vertices, adj


# ========== Demo functions ==========

def analyze_graph(name: str, vertices: Set[int], adj: Dict[int, Set[int]]):
    """Analyze a graph's cycle supports and overlap structure."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")

    print(f"  Vertices: {sorted(vertices)}")
    edge_count = sum(len(v) for v in adj.values()) // 2
    print(f"  Edges: {edge_count}")
    edge_list = []
    for u in sorted(adj):
        for v in sorted(adj[u]):
            if u < v:
                edge_list.append((u, v))
    print(f"  Edge list: {edge_list}")

    cycles = find_all_cycles(adj, vertices)
    print(f"\n  Cycle supports ({len(cycles)} cycles found):")
    for i, c in enumerate(cycles):
        print(f"    C{i}: {set(c)}")

    if not cycles:
        print("  No cycles — overlap analysis not applicable (tree or forest)")
        return

    print(f"\n  Overlap Analysis:")
    print(f"    Pairwise disjoint: {pairwise_disjoint(cycles)}")
    print(f"    Overlap pair count: {overlap_pair_count(cycles)}")
    print(f"    Max intersection size: {max_intersection_size(cycles)}")
    print(f"    Total overlap complexity: {total_overlap_complexity(cycles)}")

    classes = find_overlap_classes(cycles)
    print(f"    Overlap class count: {len(classes)}")
    for i, cls in enumerate(classes):
        supports = [set(cycles[j]) for j in cls]
        print(f"      Class {i}: indices {cls}, supports {supports}")

    nerve = element_nerve(cycles)
    print(f"\n  Element Nerve:")
    for x in sorted(nerve.keys()):
        if len(nerve[x]) > 1:
            print(f"    Vertex {x} appears in supports: {nerve[x]}")
        else:
            print(f"    Vertex {x} appears in support: {nerve[x]}")

    # Verify theorems
    print(f"\n  Theorem Verification:")
    is_disjoint = pairwise_disjoint(cycles)
    mis = max_intersection_size(cycles)
    toc = total_overlap_complexity(cycles)
    opc = overlap_pair_count(cycles)

    # maxIntersectionSize = 0 iff pairwise disjoint
    assert (mis == 0) == is_disjoint, "THEOREM VIOLATION: maxIntersectionSize_eq_zero_iff"
    print(f"    ✓ maxIntersectionSize = 0 ↔ pairwiseDisjoint: {mis == 0} ↔ {is_disjoint}")

    # totalOverlapComplexity = 0 iff pairwise disjoint
    assert (toc == 0) == is_disjoint, "THEOREM VIOLATION: totalOverlapComplexity_eq_zero_iff"
    print(f"    ✓ totalOverlapComplexity = 0 ↔ pairwiseDisjoint: {toc == 0} ↔ {is_disjoint}")

    # overlapClassCount <= len(family)
    assert len(classes) <= len(cycles), "THEOREM VIOLATION: overlapClassCount_le_card"
    print(f"    ✓ overlapClassCount ≤ |family|: {len(classes)} ≤ {len(cycles)}")

    # If pairwise disjoint, class count = family size
    if is_disjoint:
        assert len(classes) == len(cycles), "THEOREM VIOLATION: overlapClassCount_eq_card_of_pairwiseDisjoint"
        print(f"    ✓ Pairwise disjoint ⟹ classCount = |family|: {len(classes)} = {len(cycles)}")

    # overlapPairCount = 0 when pairwise disjoint
    if is_disjoint:
        assert opc == 0, "THEOREM VIOLATION: overlapPairCount_eq_zero_of_pairwiseDisjoint"
        print(f"    ✓ Pairwise disjoint ⟹ overlapPairCount = 0: {opc}")


def demo_basic_examples():
    """Run demonstrations on basic graph examples."""
    print("\n" + "=" * 60)
    print("  DEMO: Overlap Class Theory — Basic Examples")
    print("=" * 60)

    # Single cycle
    analyze_graph("C₅ (5-cycle)", *make_cycle_graph(5))

    # Complete graph K4
    analyze_graph("K₄ (complete graph on 4 vertices)", *make_complete_graph(4))

    # Bowtie graph
    analyze_graph("Bowtie (two triangles sharing a vertex)", *make_two_triangles_shared_vertex())

    # Diamond graph
    analyze_graph("Diamond (two triangles sharing an edge)", *make_two_triangles_shared_edge())

    # Two disjoint triangles with bridge
    analyze_graph("Bridge (two triangles + bridge)", *make_two_disjoint_triangles_with_bridge())


def demo_abstract_families():
    """Demonstrate with abstract support families (not from graphs)."""
    print("\n\n" + "=" * 60)
    print("  DEMO: Abstract Support Families")
    print("=" * 60)

    families = {
        "Pairwise disjoint": [
            frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})
        ],
        "Chain overlap": [
            frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4}), frozenset({4, 5})
        ],
        "Star overlap (shared center)": [
            frozenset({0, 1}), frozenset({0, 2}), frozenset({0, 3}), frozenset({0, 4})
        ],
        "Two clusters": [
            frozenset({1, 2}), frozenset({2, 3}), frozenset({5, 6}), frozenset({6, 7})
        ],
        "Dense overlap": [
            frozenset({1, 2, 3}), frozenset({2, 3, 4}), frozenset({3, 4, 5})
        ],
    }

    for name, family in families.items():
        print(f"\n  --- {name} ---")
        print(f"  Family: {[set(s) for s in family]}")
        print(f"  Pairwise disjoint: {pairwise_disjoint(family)}")
        classes = find_overlap_classes(family)
        print(f"  Overlap classes: {classes}")
        print(f"  Class count: {len(classes)}")
        print(f"  Max intersection size: {max_intersection_size(family)}")
        print(f"  Total overlap complexity: {total_overlap_complexity(family)}")
        print(f"  Overlap pair count: {overlap_pair_count(family)}")

        nerve = element_nerve(family)
        shared = {k: v for k, v in nerve.items() if len(v) > 1}
        if shared:
            print(f"  Shared elements (nerve): {shared}")


def demo_theorem_verification():
    """Systematically verify the formalized theorems on many examples."""
    print("\n\n" + "=" * 60)
    print("  DEMO: Systematic Theorem Verification")
    print("=" * 60)

    import random
    random.seed(42)

    n_tests = 100
    passed = 0

    for test_num in range(n_tests):
        # Generate random families
        n_supports = random.randint(1, 6)
        ground_size = random.randint(2, 10)
        family = []
        for _ in range(n_supports):
            size = random.randint(1, min(4, ground_size))
            support = frozenset(random.sample(range(ground_size), size))
            family.append(support)

        # Test all theorem equivalences
        is_disj = pairwise_disjoint(family)
        mis = max_intersection_size(family)
        toc = total_overlap_complexity(family)
        cc = overlap_class_count(family)
        opc = overlap_pair_count(family)

        try:
            assert (mis == 0) == is_disj, f"maxIntersectionSize_eq_zero_iff failed"
            assert (toc == 0) == is_disj, f"totalOverlapComplexity_eq_zero_iff failed"
            assert cc <= len(family), f"overlapClassCount_le_card failed"
            if is_disj:
                assert cc == len(family), f"overlapClassCount_eq_card_of_pairwiseDisjoint failed (cc={cc}, n={len(family)})"
                assert opc == 0, f"overlapPairCount_eq_zero_of_pairwiseDisjoint failed"

            # Check intersection_card_le_maxIntersectionSize
            for i in range(len(family)):
                for j in range(i + 1, len(family)):
                    assert len(family[i] & family[j]) <= mis

            # Check support_subset_overlapClassSupport
            classes = find_overlap_classes(family)
            for cls in classes:
                class_support = set()
                for idx in cls:
                    class_support |= family[idx]
                for idx in cls:
                    assert family[idx] <= class_support

            passed += 1
        except AssertionError as e:
            print(f"  FAILED test {test_num}: {e}")
            print(f"    Family: {[set(s) for s in family]}")

    print(f"\n  Passed {passed}/{n_tests} random tests")
    print(f"  All formalized theorems verified ✓" if passed == n_tests else "  SOME TESTS FAILED ✗")


if __name__ == "__main__":
    demo_basic_examples()
    demo_abstract_families()
    demo_theorem_verification()

    print("\n\n" + "=" * 60)
    print("  All demonstrations complete.")
    print("=" * 60)


"""
Visualization: Overlap Complexity Measures

Plots how the three overlap complexity measures (max intersection size,
total overlap complexity, overlap pair count) vary as supports are
systematically shifted from disjoint to maximally overlapping.

Demonstrates the key theorem: all three measures are zero iff the
family is pairwise disjoint.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, FrozenSet


def max_intersection_size(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return max((len(family[i] & family[j]) for i in range(n) for j in range(i+1,n)), default=0)

def total_overlap_complexity(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(len(family[i] & family[j]) for i in range(n) for j in range(i+1,n))

def overlap_pair_count(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1,n) if len(family[i] & family[j]) > 0)

def pairwise_disjoint(family: List[FrozenSet[int]]) -> bool:
    n = len(family)
    return all(len(family[i] & family[j]) == 0 for i in range(n) for j in range(i+1,n))

from collections import defaultdict
def find_overlap_classes(family):
    n = len(family)
    if n == 0: return []
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


# ====== Experiment: Sliding overlap ======
# Start with 4 disjoint supports of size 3, then progressively shift
# the second support to overlap with the first.

ground = list(range(20))
base_supports = [
    frozenset({0, 1, 2}),
    frozenset({3, 4, 5}),
    frozenset({6, 7, 8}),
    frozenset({9, 10, 11}),
]

# Shift amounts for support 1: replace elements from {3,4,5} with {0,1,2}
shift_steps = []
for shift in range(4):  # 0, 1, 2, 3 elements shifted
    new_s1 = frozenset(list(range(shift)) + list(range(3, 6 - shift)))
    family = [base_supports[0], new_s1, base_supports[2], base_supports[3]]
    shift_steps.append((shift, family))

# Also shift support 2 toward support 1
for shift in range(1, 4):
    new_s2 = frozenset(list(range(shift)) + list(range(6, 9 - shift)))
    family = [base_supports[0], frozenset({0, 1, 2}), new_s2, base_supports[3]]
    shift_steps.append((3 + shift, family))

shifts = [s[0] for s in shift_steps]
mis_vals = [max_intersection_size(s[1]) for s in shift_steps]
toc_vals = [total_overlap_complexity(s[1]) for s in shift_steps]
opc_vals = [overlap_pair_count(s[1]) for s in shift_steps]
cc_vals = [len(find_overlap_classes(s[1])) for s in shift_steps]
disj_vals = [pairwise_disjoint(s[1]) for s in shift_steps]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Overlap Complexity Measures vs. Overlap Degree', fontsize=15, fontweight='bold')

# Plot 1: Max Intersection Size
ax = axes[0][0]
ax.bar(shifts, mis_vals, color=['#2ecc71' if d else '#e74c3c' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Max Intersection Size')
ax.set_title('maxIntersectionSize(F)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xticks(shifts)

# Plot 2: Total Overlap Complexity
ax = axes[0][1]
ax.bar(shifts, toc_vals, color=['#2ecc71' if d else '#e74c3c' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Total Overlap Complexity')
ax.set_title('totalOverlapComplexity(F)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xticks(shifts)

# Plot 3: Overlap Pair Count
ax = axes[1][0]
ax.bar(shifts, opc_vals, color=['#2ecc71' if d else '#e74c3c' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Overlap Pair Count')
ax.set_title('overlapPairCount(F)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xticks(shifts)

# Plot 4: Overlap Class Count
ax = axes[1][1]
ax.bar(shifts, cc_vals, color=['#2ecc71' if d else '#3498db' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Overlap Class Count')
ax.set_title('overlapClassCount(F)')
ax.axhline(y=len(base_supports), color='gray', linestyle='--', alpha=0.5,
           label=f'|family| = {len(base_supports)}')
ax.legend(fontsize=9)
ax.set_xticks(shifts)

# Add green/red legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2ecc71', label='Pairwise Disjoint'),
                   Patch(facecolor='#e74c3c', label='Has Overlap')]
fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig('viz_complexity_measures.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_measures.png")


"""
Visualization: Element Nerve Heatmap

Shows the element nerve as a heatmap: rows are supports (indexed by i),
columns are elements of the ground set, and cells are colored if element x
belongs to support F(i). Highlights shared elements that create overlap.

Demonstrates the theorem: F(i) ∩ F(j) is nonempty iff there exists x
with both i and j in the nerve of x.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, FrozenSet, Dict, Set
from collections import defaultdict


def element_nerve(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    nerve: Dict[int, Set[int]] = defaultdict(set)
    for i, s in enumerate(family):
        for x in s:
            nerve[x].add(i)
    return dict(nerve)

def find_overlap_classes(family):
    n = len(family)
    if n == 0: return []
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


# ====== Example family ======
family = [
    frozenset({0, 1, 2}),       # S₀
    frozenset({2, 3, 4}),       # S₁ (overlaps S₀ at 2)
    frozenset({4, 5, 6}),       # S₂ (overlaps S₁ at 4)
    frozenset({8, 9, 10}),      # S₃ (isolated)
    frozenset({10, 11, 12}),    # S₄ (overlaps S₃ at 10)
    frozenset({15, 16, 17}),    # S₅ (isolated singleton class)
]

support_labels = [f'S{i} = {{{",".join(map(str,sorted(s)))}}}' for i, s in enumerate(family)]

# Ground set elements
all_elements = sorted(set().union(*family))
n_supports = len(family)
n_elements = len(all_elements)
elem_to_col = {e: i for i, e in enumerate(all_elements)}

# Build membership matrix
matrix = np.zeros((n_supports, n_elements))
for i, s in enumerate(family):
    for x in s:
        matrix[i, elem_to_col[x]] = 1

# Identify shared elements (those in 2+ supports)
nerve = element_nerve(family)
shared_elements = {x for x, idxs in nerve.items() if len(idxs) > 1}

# Build color matrix: 0=empty, 1=exclusive, 2=shared
color_matrix = np.zeros((n_supports, n_elements))
for i, s in enumerate(family):
    for x in s:
        col = elem_to_col[x]
        if x in shared_elements:
            color_matrix[i, col] = 2  # shared
        else:
            color_matrix[i, col] = 1  # exclusive

# Find overlap classes for coloring
classes = find_overlap_classes(family)
class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
class_map = {}
for ci, cls in enumerate(classes):
    for idx in cls:
        class_map[idx] = ci

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6),
                                 gridspec_kw={'width_ratios': [3, 1]})
fig.suptitle('Element Nerve: Support Membership Heatmap', fontsize=14, fontweight='bold')

# ---- Left: Heatmap ----
from matplotlib.colors import ListedColormap
cmap = ListedColormap(['white', '#a8d8ea', '#ff6f61'])

im = ax1.imshow(color_matrix, cmap=cmap, aspect='auto', interpolation='nearest')

ax1.set_xticks(range(n_elements))
ax1.set_xticklabels([str(e) for e in all_elements], fontsize=9)
ax1.set_yticks(range(n_supports))
ax1.set_yticklabels(support_labels, fontsize=9)
ax1.set_xlabel('Ground Set Elements', fontsize=11)
ax1.set_ylabel('Supports', fontsize=11)

# Highlight shared columns
for x in shared_elements:
    col = elem_to_col[x]
    ax1.axvline(x=col - 0.5, color='red', linewidth=0.5, alpha=0.3)
    ax1.axvline(x=col + 0.5, color='red', linewidth=0.5, alpha=0.3)

# Color the y-axis labels by class
for i, label in enumerate(ax1.get_yticklabels()):
    label.set_color(class_colors[class_map[i] % len(class_colors)])
    label.set_fontweight('bold')

# Add grid
ax1.set_xticks(np.arange(-0.5, n_elements, 1), minor=True)
ax1.set_yticks(np.arange(-0.5, n_supports, 1), minor=True)
ax1.grid(which='minor', color='gray', linewidth=0.3)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='white', edgecolor='gray', label='Not in support'),
    Patch(facecolor='#a8d8ea', label='Exclusive to one support'),
    Patch(facecolor='#ff6f61', label='Shared (creates overlap)'),
]
ax1.legend(handles=legend_elements, loc='upper right', fontsize=8)

# ---- Right: Overlap class summary ----
ax2.axis('off')
ax2.set_title('Overlap Classes', fontsize=12, fontweight='bold')

y = 0.9
for ci, cls in enumerate(classes):
    color = class_colors[ci % len(class_colors)]
    members = [f'S{i}' for i in cls]
    ax2.text(0.1, y, f'Class {ci}:', fontsize=11, fontweight='bold',
             color=color, transform=ax2.transAxes)
    ax2.text(0.1, y - 0.06, f'  {", ".join(members)}', fontsize=10,
             color=color, transform=ax2.transAxes)

    # Find shared elements within class
    shared_in_class = set()
    for a in cls:
        for b in cls:
            if a < b:
                shared_in_class |= family[a] & family[b]
    if shared_in_class:
        ax2.text(0.1, y - 0.12, f'  Shared: {sorted(shared_in_class)}',
                 fontsize=9, color='gray', transform=ax2.transAxes)
        y -= 0.22
    else:
        y -= 0.16

ax2.text(0.1, y - 0.05, f'Total classes: {len(classes)}',
         fontsize=11, fontweight='bold', transform=ax2.transAxes)
ax2.text(0.1, y - 0.12, f'Total supports: {n_supports}',
         fontsize=10, transform=ax2.transAxes)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_element_nerve.png', dpi=150, bbox_inches='tight')
print("Saved viz_element_nerve.png")


"""
Visualization: Support Overlap Graph and Overlap Classes

Visualizes a family of finite sets and their overlap graph. Each support is
shown as a node colored by its overlap class. Edges indicate nonempty
intersection, with edge width proportional to intersection size.

This visualizes the core mathematical objects defined in
OverlapClassRigidity.lean: SupportOverlapGraph and overlapClassCount.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
from typing import List, FrozenSet, Dict, Set, Tuple


def supports_overlap(a: FrozenSet[int], b: FrozenSet[int]) -> bool:
    return len(a & b) > 0

def find_overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    n = len(family)
    if n == 0: return []
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                union(i, j)
    classes: Dict[int, List[int]] = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())

def spring_layout(adj: Dict[int, Set[int]], n: int, iterations: int = 50) -> Dict[int, Tuple[float, float]]:
    """Simple spring layout."""
    np.random.seed(42)
    pos = {i: np.random.randn(2) for i in range(n)}
    for _ in range(iterations):
        forces = {i: np.zeros(2) for i in range(n)}
        for i in range(n):
            for j in range(n):
                if i == j: continue
                d = pos[j] - pos[i]
                dist = max(np.linalg.norm(d), 0.01)
                forces[i] -= d / (dist ** 2) * 0.5  # repulsion
                if j in adj.get(i, set()):
                    forces[i] += d * 0.1  # attraction
        for i in range(n):
            pos[i] += forces[i] * 0.1
    return pos


# ====== Example families ======
families = {
    "Pairwise Disjoint\n(3 classes)": [
        frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})
    ],
    "Chain Overlap\n(1 class)": [
        frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4}), frozenset({4, 5})
    ],
    "Two Clusters\n(2 classes)": [
        frozenset({1, 2}), frozenset({2, 3}), frozenset({5, 6}), frozenset({6, 7})
    ],
    "Star Overlap\n(1 class)": [
        frozenset({0, 1}), frozenset({0, 2}), frozenset({0, 3}), frozenset({0, 4})
    ],
}

colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Support Overlap Graphs and Overlap Classes', fontsize=16, fontweight='bold')

for idx, (name, family) in enumerate(families.items()):
    ax = axes[idx // 2][idx % 2]
    n = len(family)

    # Build overlap graph
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)

    # Find classes
    classes = find_overlap_classes(family)
    class_map = {}
    for ci, cls in enumerate(classes):
        for idx_in_cls in cls:
            class_map[idx_in_cls] = ci

    # Layout
    pos = spring_layout(adj, n)

    # Normalize positions
    all_x = [p[0] for p in pos.values()]
    all_y = [p[1] for p in pos.values()]
    cx, cy = np.mean(all_x), np.mean(all_y)
    scale = max(max(abs(x - cx) for x in all_x), max(abs(y - cy) for y in all_y), 0.1)
    pos = {k: ((v[0] - cx) / scale * 0.35 + 0.5, (v[1] - cy) / scale * 0.35 + 0.5) for k, v in pos.items()}

    # Draw edges
    for i in range(n):
        for j in adj[i]:
            if i < j:
                xi, yi = pos[i]
                xj, yj = pos[j]
                isect_size = len(family[i] & family[j])
                ax.plot([xi, xj], [yi, yj], '-', color='gray',
                        linewidth=1 + isect_size, alpha=0.5)
                mid_x, mid_y = (xi + xj) / 2, (yi + yj) / 2
                ax.text(mid_x, mid_y + 0.03, f"|∩|={isect_size}",
                        ha='center', va='center', fontsize=7, color='gray')

    # Draw nodes
    for i in range(n):
        x, y = pos[i]
        color = colors[class_map[i] % len(colors)]
        ax.scatter(x, y, s=800, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        label = '{' + ','.join(map(str, sorted(family[i]))) + '}'
        ax.text(x, y, label, ha='center', va='center', fontsize=7, fontweight='bold')

    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.1, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    unique_classes = sorted(set(class_map.values()))
    patches = [mpatches.Patch(color=colors[c % len(colors)],
               label=f'Class {c}') for c in unique_classes]
    ax.legend(handles=patches, loc='lower right', fontsize=8)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_overlap_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")
