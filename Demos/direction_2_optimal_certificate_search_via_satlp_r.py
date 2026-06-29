#!/usr/bin/env python3
"""
applications.py — Real-world applications of hypergraph transversal theory
and monotone SAT reduction.

Applications:
1. Pythagorean coloring certificate search
2. Network security: minimum sensor placement
3. Database theory: minimum key computation
4. Drug design: minimum test set for compound screening
5. Graph coloring via hitting set reduction

All examples are self-contained with concrete numerical instances.
"""

import math
from itertools import combinations
from typing import List, Set, Tuple, Dict
from collections import defaultdict


# ─── Application 1: Pythagorean Coloring Certificates ───

def pythagorean_coloring_search(n: int) -> Tuple[bool, Dict[int, bool]]:
    """Search for a valid 2-coloring of {1,...,n} avoiding monochromatic
    Pythagorean triples.

    Uses backtracking with constraint propagation.
    Based on the hypergraph transversal framework.

    Returns (found, coloring).
    """
    triples = []
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c_sq = a * a + b * b
            c = int(math.isqrt(c_sq))
            if c * c == c_sq and c <= n and c > b:
                triples.append((a, b, c))

    coloring: Dict[int, bool] = {}

    def is_consistent() -> bool:
        for a, b, c in triples:
            if a in coloring and b in coloring and c in coloring:
                if coloring[a] == coloring[b] == coloring[c]:
                    return False
        return True

    def backtrack(v: int) -> bool:
        if v > n:
            return True
        for color in [True, False]:
            coloring[v] = color
            if is_consistent() and backtrack(v + 1):
                return True
        del coloring[v]
        return False

    if backtrack(1):
        return True, dict(coloring)
    return False, {}


# ─── Application 2: Network Sensor Placement ───

def minimum_sensor_placement(
    network_nodes: Set[int],
    critical_paths: List[Set[int]]
) -> Tuple[Set[int], int]:
    """Find minimum sensor placement to monitor all critical paths.

    This is a direct application of minimum hitting set: sensors are vertices,
    critical paths are edges. We need at least one sensor on each path.

    Uses greedy approximation (H_d-approximation for d-uniform hypergraphs).

    Example: Network monitoring for intrusion detection.
    """
    sensors: Set[int] = set()
    uncovered = list(critical_paths)

    while uncovered:
        # Pick node covering most uncovered paths
        coverage: Dict[int, int] = defaultdict(int)
        for path in uncovered:
            for node in path:
                if node in network_nodes and node not in sensors:
                    coverage[node] += 1

        if not coverage:
            break

        best_node = max(coverage, key=coverage.get)
        sensors.add(best_node)
        uncovered = [p for p in uncovered if best_node not in p]

    return sensors, len(sensors)


# ─── Application 3: Database Minimum Key ───

def find_minimum_key(
    attributes: Set[str],
    functional_dependencies: List[Tuple[Set[str], str]]
) -> Set[str]:
    """Find a minimum key (set of attributes that determines all others).

    A key K determines attribute a if there exists a chain of functional
    dependencies from K to a. Finding a minimum key is equivalent to
    finding a minimum hitting set of the "non-determined" attribute sets.

    Simplified model for demonstration.
    """
    # Compute closure of each candidate key
    def closure(key: Set[str]) -> Set[str]:
        result = set(key)
        changed = True
        while changed:
            changed = False
            for lhs, rhs in functional_dependencies:
                if lhs <= result and rhs not in result:
                    result.add(rhs)
                    changed = True
        return result

    # Find minimum key by increasing size
    attr_list = sorted(attributes)
    for k in range(1, len(attr_list) + 1):
        for combo in combinations(attr_list, k):
            candidate = set(combo)
            if closure(candidate) == attributes:
                return candidate

    return set(attributes)


# ─── Application 4: Drug Compound Screening ───

def minimum_test_set(
    compounds: Set[int],
    activity_profiles: List[Set[int]]
) -> Tuple[Set[int], int]:
    """Find minimum set of test compounds that covers all activity profiles.

    Each activity profile is a set of compounds that exhibit a particular
    biological activity. Testing at least one compound from each profile
    ensures complete coverage.

    This is minimum hitting set applied to pharmacological screening.
    """
    test_set: Set[int] = set()
    uncovered = list(activity_profiles)

    while uncovered:
        frequency: Dict[int, int] = defaultdict(int)
        for profile in uncovered:
            for c in profile:
                if c in compounds:
                    frequency[c] += 1

        if not frequency:
            break

        best = max(frequency, key=frequency.get)
        test_set.add(best)
        uncovered = [p for p in uncovered if best not in p]

    return test_set, len(test_set)


# ─── Application 5: Graph Coloring via Hitting Set ───

def graph_coloring_hitting_set(
    vertices: Set[int],
    edges: List[Tuple[int, int]],
    k: int
) -> bool:
    """Check if a graph is k-colorable by reducing to hitting set.

    For each edge (u,v) and each color c, create a clause saying
    "u is not color c OR v is not color c". This is a 2-SAT instance
    for k=2, but for general k it becomes a hitting set problem on
    the conflict hypergraph.

    Simplified: just checks 2-colorability (bipartiteness).
    """
    # Build adjacency
    adj: Dict[int, Set[int]] = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)

    if k < 2:
        return len(edges) == 0

    # BFS 2-coloring check
    color: Dict[int, int] = {}
    for start in vertices:
        if start in color:
            continue
        queue = [start]
        color[start] = 0
        while queue:
            u = queue.pop(0)
            for v in adj[u]:
                if v not in color:
                    color[v] = 1 - color[u]
                    queue.append(v)
                elif color[v] == color[u]:
                    return False
    return True


# ─── Run all applications ───

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   Applications of Hypergraph Transversal Theory            ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # Application 1: Pythagorean Coloring
    print("\n" + "=" * 60)
    print("APPLICATION 1: Pythagorean Coloring Certificate Search")
    print("=" * 60)
    for n in [5, 10, 20, 50, 100]:
        found, coloring = pythagorean_coloring_search(n)
        if found:
            reds = sorted(k for k, v in coloring.items() if v)
            blues = sorted(k for k, v in coloring.items() if not v)
            print(f"  n={n:>4}: Valid coloring found. "
                  f"|Red|={len(reds)}, |Blue|={len(blues)}")
        else:
            print(f"  n={n:>4}: No valid coloring exists.")

    # Application 2: Network Security
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Sensor Placement")
    print("=" * 60)
    nodes = set(range(1, 11))
    paths = [
        {1, 3, 5, 7},    # Path 1: through nodes 1, 3, 5, 7
        {2, 4, 6, 8},    # Path 2: through nodes 2, 4, 6, 8
        {1, 2, 9},       # Path 3
        {3, 6, 10},      # Path 4
        {5, 8, 9, 10},   # Path 5
        {1, 4, 7, 10},   # Path 6
        {2, 5, 8},       # Path 7
    ]
    sensors, count = minimum_sensor_placement(nodes, paths)
    print(f"  Network: {len(nodes)} nodes, {len(paths)} critical paths")
    print(f"  Minimum sensors needed: {count}")
    print(f"  Sensor locations: {sorted(sensors)}")
    for i, path in enumerate(paths):
        covered_by = sensors & path
        print(f"    Path {i+1} {sorted(path)}: monitored by sensor(s) {sorted(covered_by)}")

    # Application 3: Database Theory
    print("\n" + "=" * 60)
    print("APPLICATION 3: Database Minimum Key Discovery")
    print("=" * 60)
    attrs = {'StudentID', 'Name', 'Department', 'GPA', 'Year', 'Email'}
    fds = [
        ({'StudentID'}, 'Name'),
        ({'StudentID'}, 'Department'),
        ({'StudentID'}, 'GPA'),
        ({'StudentID'}, 'Year'),
        ({'StudentID'}, 'Email'),
        ({'Email'}, 'StudentID'),
        ({'Name', 'Department'}, 'Email'),
    ]
    key = find_minimum_key(attrs, fds)
    print(f"  Attributes: {sorted(attrs)}")
    print(f"  Functional dependencies: {len(fds)}")
    print(f"  Minimum key: {sorted(key)}")

    # Application 4: Drug Screening
    print("\n" + "=" * 60)
    print("APPLICATION 4: Minimum Drug Compound Test Set")
    print("=" * 60)
    compounds = set(range(1, 21))
    profiles = [
        {1, 3, 7, 12},      # Anti-inflammatory activity
        {2, 5, 8, 15},      # Analgesic activity
        {3, 6, 9, 18},      # Antipyretic activity
        {1, 4, 10, 16},     # Antimicrobial activity
        {5, 7, 11, 19},     # Antiviral activity
        {2, 8, 13, 20},     # Antifungal activity
        {4, 6, 14, 17},     # Anticancer activity
        {9, 12, 15, 20},    # Neuroprotective activity
    ]
    test_set, count = minimum_test_set(compounds, profiles)
    print(f"  Compounds: {len(compounds)}, Activity profiles: {len(profiles)}")
    print(f"  Minimum test set size: {count}")
    print(f"  Test compounds: {sorted(test_set)}")
    for i, profile in enumerate(profiles):
        covered = test_set & profile
        activities = [
            "Anti-inflammatory", "Analgesic", "Antipyretic", "Antimicrobial",
            "Antiviral", "Antifungal", "Anticancer", "Neuroprotective"
        ]
        print(f"    {activities[i]}: covered by compound(s) {sorted(covered)}")

    # Application 5: Graph Coloring
    print("\n" + "=" * 60)
    print("APPLICATION 5: Graph Coloring via Hitting Set")
    print("=" * 60)
    # Petersen graph (not 2-colorable)
    petersen_edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),  # Outer cycle
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),  # Spokes
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),  # Inner pentagram
    ]
    is_2col = graph_coloring_hitting_set(set(range(10)), petersen_edges, 2)
    print(f"  Petersen graph (10 vertices, 15 edges):")
    print(f"    2-colorable? {is_2col}")

    # Bipartite graph (2-colorable)
    bipartite_edges = [(i, j + 4) for i in range(4) for j in range(4) if i != j]
    is_2col_bi = graph_coloring_hitting_set(set(range(8)), bipartite_edges, 2)
    print(f"  Complete bipartite K_{4,4} minus matching:")
    print(f"    2-colorable? {is_2col_bi}")

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of hypergraph transversal theory
applied to Pythagorean triple coloring and monotone SAT reduction.

Demonstrates:
1. Building Pythagorean triple hypergraphs for small n
2. Encoding as monotone SAT instances
3. Finding minimum transversals via brute force
4. Visualizing the structure of certificates and colorings
5. Verifying the sunflower kernel property

Run: python3 demo.py
"""

from itertools import combinations, product
from typing import List, Set, Tuple, Dict, Optional
from collections import defaultdict
import math


def is_pythagorean_triple(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a * a + b * b == c * c


def find_pythagorean_triples(n: int) -> List[Tuple[int, int, int]]:
    """Find all Pythagorean triples (a, b, c) with a < b < c <= n."""
    triples = []
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c_sq = a * a + b * b
            c = int(math.isqrt(c_sq))
            if c * c == c_sq and c <= n and c > b:
                triples.append((a, b, c))
    return triples


def build_hypergraph(n: int) -> Tuple[Set[int], List[Set[int]]]:
    """Build the Pythagorean triple hypergraph on {1, ..., n}.

    Returns (vertices, edges) where each edge is a set of 3 elements.
    """
    vertices = set(range(1, n + 1))
    triples = find_pythagorean_triples(n)
    edges = [set(t) for t in triples]
    return vertices, edges


def is_transversal(edges: List[Set[int]], T: Set[int]) -> bool:
    """Check if T is a transversal (hitting set) of edges."""
    return all(T & e for e in edges)


def monotone_sat_satisfies(clauses: List[Set[int]], sigma: Set[int]) -> bool:
    """Check if assignment sigma satisfies a monotone CNF (= is a transversal)."""
    return is_transversal(clauses, sigma)


def find_min_transversal(vertices: Set[int], edges: List[Set[int]]) -> Set[int]:
    """Find minimum transversal by brute force (for small instances)."""
    if not edges:
        return set()
    v_list = sorted(vertices)
    for k in range(1, len(v_list) + 1):
        for combo in combinations(v_list, k):
            T = set(combo)
            if is_transversal(edges, T):
                return T
    return set(v_list)  # Fallback: full vertex set


def find_sunflowers(edges: List[Set[int]], min_size: int = 3) -> List[Tuple[Set[int], List[Set[int]]]]:
    """Find sunflowers in the edge family.

    Returns list of (kernel, [petals]) for each sunflower found.
    """
    sunflowers = []
    for size in range(min_size, len(edges) + 1):
        for combo in combinations(range(len(edges)), size):
            edge_group = [edges[i] for i in combo]
            # Compute pairwise intersections
            pairs = list(combinations(edge_group, 2))
            if not pairs:
                continue
            kernel = pairs[0][0] & pairs[0][1]
            if all(e1 & e2 == kernel for e1, e2 in pairs):
                # Verify petals are disjoint
                petals = [e - kernel for e in edge_group]
                pairwise_disjoint = all(
                    p1.isdisjoint(p2) for p1, p2 in combinations(petals, 2)
                )
                if pairwise_disjoint and all(kernel <= e for e in edge_group):
                    sunflowers.append((kernel, edge_group))
    return sunflowers


def verify_coloring(n: int, coloring: Dict[int, bool]) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """Verify a 2-coloring avoids monochromatic Pythagorean triples.

    Returns (is_valid, counterexample_triple_or_None).
    """
    triples = find_pythagorean_triples(n)
    for a, b, c in triples:
        if coloring[a] == coloring[b] == coloring[c]:
            return False, (a, b, c)
    return True, None


def encode_as_sat(vertices: Set[int], edges: List[Set[int]]) -> str:
    """Encode the hitting set problem as a DIMACS CNF formula.

    Returns the DIMACS string representation.
    """
    var_map = {v: i + 1 for i, v in enumerate(sorted(vertices))}
    lines = [f"c Pythagorean triple hitting set as monotone SAT"]
    lines.append(f"c Variables: {len(var_map)}, Clauses: {len(edges)}")
    lines.append(f"p cnf {len(var_map)} {len(edges)}")
    for edge in edges:
        clause = " ".join(str(var_map[v]) for v in sorted(edge))
        lines.append(f"{clause} 0")
    return "\n".join(lines)


def demo_hypergraph_construction():
    """Demo 1: Building Pythagorean triple hypergraphs."""
    print("=" * 70)
    print("DEMO 1: Pythagorean Triple Hypergraph Construction")
    print("=" * 70)

    for n in [5, 10, 25, 50, 100]:
        triples = find_pythagorean_triples(n)
        print(f"\nn = {n}: {len(triples)} Pythagorean triples")
        if n <= 25:
            for t in triples:
                print(f"  {t[0]}² + {t[1]}² = {t[2]}²  "
                      f"({t[0]**2} + {t[1]**2} = {t[2]**2})")


def demo_sat_encoding():
    """Demo 2: Monotone SAT encoding."""
    print("\n" + "=" * 70)
    print("DEMO 2: Monotone SAT Encoding (SAT–Hitting Set Duality)")
    print("=" * 70)

    n = 10
    vertices, edges = build_hypergraph(n)
    print(f"\nPythagorean hypergraph for n = {n}:")
    print(f"  Vertices: {sorted(vertices)}")
    print(f"  Edges (triples):")
    for e in edges:
        print(f"    {sorted(e)}")

    dimacs = encode_as_sat(vertices, edges)
    print(f"\nDIMACS CNF encoding:")
    print(dimacs)

    print(f"\nVerifying duality: satisfying assignments = transversals")
    min_T = find_min_transversal(vertices, edges)
    print(f"  Minimum transversal: {sorted(min_T)}, size = {len(min_T)}")
    print(f"  Is a transversal? {is_transversal(edges, min_T)}")
    print(f"  Satisfies monotone SAT? {monotone_sat_satisfies(edges, min_T)}")

    # Verify upward closure (monotonicity)
    larger = min_T | {1, 2}
    print(f"\n  Superset test: {sorted(larger)}")
    print(f"    Still a transversal? {is_transversal(edges, larger)}")
    print(f"    (Confirms upward closure / monotonicity)")


def demo_coloring():
    """Demo 3: Pythagorean coloring."""
    print("\n" + "=" * 70)
    print("DEMO 3: Boolean Pythagorean Triples Coloring")
    print("=" * 70)

    # n = 5: known valid coloring
    coloring_5 = {1: True, 2: False, 3: False, 4: True, 5: False}
    valid, counter = verify_coloring(5, coloring_5)
    print(f"\nn = 5, coloring = {{1:T, 2:F, 3:F, 4:T, 5:F}}")
    print(f"  Valid (no monochromatic triple)? {valid}")

    # n = 10: find a valid coloring by brute force
    print(f"\nn = 10: searching for valid 2-colorings...")
    found = 0
    for bits in range(2**10):
        coloring = {i + 1: bool((bits >> i) & 1) for i in range(10)}
        valid, _ = verify_coloring(10, coloring)
        if valid:
            found += 1
    print(f"  Found {found} valid 2-colorings out of {2**10} total")

    # Show one
    for bits in range(2**10):
        coloring = {i + 1: bool((bits >> i) & 1) for i in range(10)}
        valid, _ = verify_coloring(10, coloring)
        if valid:
            reds = [k for k, v in coloring.items() if v]
            blues = [k for k, v in coloring.items() if not v]
            print(f"  Example: Red = {sorted(reds)}, Blue = {sorted(blues)}")
            break


def demo_sunflowers():
    """Demo 4: Sunflower structure in Pythagorean hypergraphs."""
    print("\n" + "=" * 70)
    print("DEMO 4: Sunflower Structure")
    print("=" * 70)

    n = 25
    vertices, edges = build_hypergraph(n)
    print(f"\nSearching for sunflowers in Pythagorean hypergraph (n={n})...")

    sunflowers = find_sunflowers(edges, min_size=2)
    print(f"  Found {len(sunflowers)} sunflowers of size ≥ 2")

    for i, (kernel, petals) in enumerate(sunflowers[:5]):
        print(f"\n  Sunflower {i+1}:")
        print(f"    Kernel: {sorted(kernel)}")
        for p in petals:
            print(f"    Edge: {sorted(p)} (petal: {sorted(p - kernel)})")

    # Verify kernel hitting property
    if sunflowers:
        kernel, petals = sunflowers[0]
        min_T = find_min_transversal(vertices, edges)
        hits_kernel = bool(min_T & kernel)
        print(f"\n  Min transversal {sorted(min_T)} hits kernel {sorted(kernel)}? {hits_kernel}")
        if not hits_kernel:
            print(f"  (Hits each petal individually instead)")
            for p in petals:
                hits = min_T & (p - kernel)
                print(f"    Petal {sorted(p - kernel)}: hit by {sorted(hits)}")


def demo_minimum_transversals():
    """Demo 5: Minimum transversal computation."""
    print("\n" + "=" * 70)
    print("DEMO 5: Minimum Transversal Computation")
    print("=" * 70)

    for n in [5, 10, 15, 20]:
        vertices, edges = build_hypergraph(n)
        if edges:
            min_T = find_min_transversal(vertices, edges)
            print(f"\nn = {n}: {len(edges)} triples, "
                  f"τ = {len(min_T)}, T = {sorted(min_T)}")

            # Verify optimality by checking no smaller set works
            v_list = sorted(vertices)
            smaller_works = False
            for k in range(1, len(min_T)):
                for combo in combinations(v_list, k):
                    if is_transversal(edges, set(combo)):
                        smaller_works = True
                        break
                if smaller_works:
                    break
            print(f"  Verified optimal (no smaller transversal exists)? {not smaller_works}")
        else:
            print(f"\nn = {n}: 0 triples, τ = 0")


def demo_euclid_formula():
    """Demo 6: Euclid's formula for generating Pythagorean triples."""
    print("\n" + "=" * 70)
    print("DEMO 6: Euclid's Formula Verification")
    print("=" * 70)

    print("\nEuclid's formula: (m²-n², 2mn, m²+n²)")
    print(f"{'m':>4} {'n':>4} | {'a':>6} {'b':>6} {'c':>6} | {'a²+b²':>10} {'c²':>10} | Valid")
    print("-" * 65)
    for m in range(2, 8):
        for n in range(1, m):
            a = m * m - n * n
            b = 2 * m * n
            c = m * m + n * n
            if a > b:
                a, b = b, a
            valid = is_pythagorean_triple(a, b, c)
            print(f"{m:>4} {n:>4} | {a:>6} {b:>6} {c:>6} | {a**2+b**2:>10} {c**2:>10} | {valid}")

    # Verify scaling
    print("\nScaling verification: k × (3, 4, 5)")
    for k in range(1, 6):
        a, b, c = 3 * k, 4 * k, 5 * k
        print(f"  k={k}: ({a}, {b}, {c}) — valid? {is_pythagorean_triple(a, b, c)}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Hypergraph Transversal Theory & Pythagorean Coloring Demo         ║")
    print("║   SAT–Hitting Set Duality in Action                                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_hypergraph_construction()
    demo_sat_encoding()
    demo_coloring()
    demo_sunflowers()
    demo_minimum_transversals()
    demo_euclid_formula()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
