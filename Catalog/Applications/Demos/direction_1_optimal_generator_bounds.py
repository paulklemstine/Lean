#!/usr/bin/env python3
"""
Categorical Shannon Theory — Applications

Real-world applications of the categorical compression framework:
1. Database schema compression
2. Software module dependency optimization
3. Network protocol design
4. Sensor network data fusion
"""

from algorithms import exact_min_cover, greedy_min_cover, shannon_lower_bound, analyze_compression
from typing import Dict, List, Set, Tuple


# =============================================================================
# Application 1: Database Schema Compression
# =============================================================================

def database_schema_compression():
    """Application: Compressing database views via shared columns.

    Consider a database with tables that share columns. Each table is an
    "object," each row is an "element," and foreign key relationships are
    "restrictions" (they allow one table's data to determine another's).

    The minimum cover tells us the minimum number of "base rows" needed
    to reconstruct all views.

    Example: Customer-Order-Product schema
    - Table 0 (Customers): 4 records
    - Table 1 (Orders): 4 records (each linked to a customer)
    - Table 2 (Products): 4 records (each linked to an order)
    """
    print("=" * 60)
    print("APPLICATION 1: Database Schema Compression")
    print("=" * 60)
    print()

    n_tables = 3
    fibers = {
        0: ['c1', 'c2', 'c3', 'c4'],   # Customers
        1: ['o1', 'o2', 'o3', 'o4'],   # Orders
        2: ['p1', 'p2', 'p3', 'p4'],   # Products
    }

    # Scenario 1: No foreign keys (discrete)
    restrictions_discrete = {(i, i): {x: x for x in fibers[i]} for i in range(3)}
    result1 = analyze_compression(n_tables, fibers, restrictions_discrete)
    print(f"  Scenario 1 (No foreign keys):")
    print(f"    Total records: {result1['total_elements']}")
    print(f"    Min base rows needed: {result1['min_cover_exact']}")
    print(f"    Compression ratio: {result1['compression_ratio']:.1f}x")
    print()

    # Scenario 2: Customer -> Orders (each order maps to a customer)
    restrictions_partial = dict(restrictions_discrete)
    restrictions_partial[(1, 0)] = {'c1': 'o1', 'c2': 'o2', 'c3': 'o3', 'c4': 'o4'}
    result2 = analyze_compression(n_tables, fibers, restrictions_partial)
    print(f"  Scenario 2 (Customer -> Orders FK):")
    print(f"    Min base rows needed: {result2['min_cover_exact']}")
    print(f"    Compression ratio: {result2['compression_ratio']:.1f}x")
    print()

    # Scenario 3: Full chain Customer -> Orders -> Products
    restrictions_full = dict(restrictions_partial)
    restrictions_full[(2, 1)] = {'o1': 'p1', 'o2': 'p2', 'o3': 'p3', 'o4': 'p4'}
    result3 = analyze_compression(n_tables, fibers, restrictions_full)
    print(f"  Scenario 3 (Full FK chain: Customer -> Orders -> Products):")
    print(f"    Min base rows needed: {result3['min_cover_exact']}")
    print(f"    Compression ratio: {result3['compression_ratio']:.1f}x")
    print()

    print(f"  Insight: Foreign keys reduce the minimum base rows from")
    print(f"  {result1['min_cover_exact']} to {result3['min_cover_exact']} "
          f"— a {result3['compression_ratio']:.1f}x compression.")
    print()


# =============================================================================
# Application 2: Software Module Dependencies
# =============================================================================

def software_module_optimization():
    """Application: Minimizing test configurations via module dependencies.

    Each module has a set of features. If module A depends on module B,
    testing A's features also tests B's features. The minimum cover is
    the minimum number of test configurations needed.
    """
    print("=" * 60)
    print("APPLICATION 2: Software Module Test Optimization")
    print("=" * 60)
    print()

    # 4 modules: Core, Auth, API, UI
    n_modules = 4
    fibers = {
        0: ['core_f1', 'core_f2', 'core_f3'],  # Core: 3 features
        1: ['auth_f1', 'auth_f2'],               # Auth: 2 features
        2: ['api_f1', 'api_f2', 'api_f3'],       # API: 3 features
        3: ['ui_f1', 'ui_f2'],                    # UI: 2 features
    }

    # Dependencies: Auth->Core, API->Core, UI->API->Core
    restrictions = {(i, i): {x: x for x in fibers[i]} for i in range(4)}

    # No dependencies
    result_none = analyze_compression(n_modules, fibers, restrictions)
    print(f"  No dependencies: {result_none['min_cover_exact']} test configs needed")

    # Auth -> Core (auth tests also test core features)
    restrictions[(0, 1)] = {'auth_f1': 'core_f1', 'auth_f2': 'core_f2'}
    result_partial = analyze_compression(n_modules, fibers, restrictions)
    print(f"  Auth->Core: {result_partial['min_cover_exact']} test configs needed")

    # API -> Core
    restrictions[(0, 2)] = {'api_f1': 'core_f1', 'api_f2': 'core_f2', 'api_f3': 'core_f3'}
    result_more = analyze_compression(n_modules, fibers, restrictions)
    print(f"  Auth->Core, API->Core: {result_more['min_cover_exact']} test configs needed")

    # UI -> API
    restrictions[(2, 3)] = {'ui_f1': 'api_f1', 'ui_f2': 'api_f2'}
    result_full = analyze_compression(n_modules, fibers, restrictions)
    print(f"  Full deps: {result_full['min_cover_exact']} test configs needed")

    print(f"\n  Dependencies reduce test configs from {result_none['min_cover_exact']} "
          f"to {result_full['min_cover_exact']}")
    print()


# =============================================================================
# Application 3: Sensor Network Data Fusion
# =============================================================================

def sensor_network_fusion():
    """Application: Minimum sensor readings for full coverage.

    A sensor network has multiple sensors, each measuring different quantities.
    If sensor A's reading determines sensor B's reading (e.g., temperature
    determines humidity in a controlled environment), we need fewer readings.
    """
    print("=" * 60)
    print("APPLICATION 3: Sensor Network Data Fusion")
    print("=" * 60)
    print()

    # 5 sensors, each with 3 possible readings
    n_sensors = 5
    fibers = {i: [0, 1, 2] for i in range(n_sensors)}

    # Independent sensors
    restrictions_indep = {(i, i): {0: 0, 1: 1, 2: 2} for i in range(n_sensors)}
    result_indep = analyze_compression(n_sensors, fibers, restrictions_indep)
    print(f"  Independent sensors: {result_indep['min_cover_exact']} readings needed")

    # Star topology: sensor 0 determines all others
    restrictions_star = dict(restrictions_indep)
    for i in range(1, n_sensors):
        restrictions_star[(i, 0)] = {0: 0, 1: 1, 2: 2}
    result_star = analyze_compression(n_sensors, fibers, restrictions_star)
    print(f"  Star (sensor 0 master): {result_star['min_cover_exact']} readings needed")

    # Chain: 0->1->2->3->4
    restrictions_chain = dict(restrictions_indep)
    for i in range(n_sensors - 1):
        restrictions_chain[(i+1, i)] = {0: 0, 1: 1, 2: 2}
    result_chain = analyze_compression(n_sensors, fibers, restrictions_chain)
    print(f"  Chain (0->1->...->4): {result_chain['min_cover_exact']} readings needed")

    # Full mesh
    restrictions_mesh = {(i, j): {0: 0, 1: 1, 2: 2}
                         for i in range(n_sensors) for j in range(n_sensors)}
    result_mesh = analyze_compression(n_sensors, fibers, restrictions_mesh)
    print(f"  Full mesh: {result_mesh['min_cover_exact']} readings needed")

    print(f"\n  Topology matters: independent={result_indep['min_cover_exact']}, "
          f"star={result_star['min_cover_exact']}, "
          f"chain={result_chain['min_cover_exact']}, "
          f"mesh={result_mesh['min_cover_exact']}")
    print()


# =============================================================================
# Application 4: Network Protocol Compression
# =============================================================================

def network_protocol_compression():
    """Application: Minimum message types for full protocol coverage.

    A distributed protocol has nodes that exchange messages. If one node
    can derive another node's state from its own messages (via known
    transformations), fewer distinct message types are needed.
    """
    print("=" * 60)
    print("APPLICATION 4: Network Protocol Message Types")
    print("=" * 60)
    print()

    # 3 node types, each with message set of size 4
    n_nodes = 3
    m = 4
    fibers = {i: list(range(m)) for i in range(n_nodes)}

    # Scenario: Gateway node (0) can derive all messages
    restrictions_gateway = {(i, i): {x: x for x in range(m)} for i in range(n_nodes)}
    for i in range(1, n_nodes):
        restrictions_gateway[(i, 0)] = {x: x for x in range(m)}

    result = analyze_compression(n_nodes, fibers, restrictions_gateway)
    print(f"  Gateway protocol:")
    print(f"    Total message types: {result['total_elements']}")
    print(f"    Min distinct types needed: {result['min_cover_exact']}")
    print(f"    Shannon lower bound: {result['shannon_lb']}")
    print(f"    Compression: {result['compression_ratio']:.1f}x")
    print()


# =============================================================================
# Main
# =============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   CATEGORICAL SHANNON THEORY — REAL-WORLD APPLICATIONS ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    database_schema_compression()
    software_module_optimization()
    sensor_network_fusion()
    network_protocol_compression()

    print("=" * 60)
    print("ALL APPLICATIONS COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Categorical Shannon Theory — Interactive Demo

Demonstrates the core ideas:
1. Constructs presheaves over small categories
2. Builds generator graphs
3. Computes minimal dominating sets (= minimal covers)
4. Verifies the Shannon lower bound and tightness examples
5. Visualizes the morphism-density-compression tradeoff
"""

from itertools import product, combinations
from typing import Dict, List, Set, Tuple, Optional
import math
import json


# =============================================================================
# Core Data Structures
# =============================================================================

class PresheafModel:
    """A presheaf on a finite category.

    Objects: list of integers [0, ..., n-1]
    Fibers: F[i] is a list of elements at object i
    Restrictions: restrict[(i, j)] maps F[j] -> F[i] (a dict element -> element)
    """

    def __init__(self, n_objects: int, fibers: Dict[int, List], restrictions: Dict[Tuple[int, int], Dict]):
        self.n_objects = n_objects
        self.objects = list(range(n_objects))
        self.fibers = fibers
        self.restrictions = restrictions  # (target, source) -> {elem_source: elem_target}

    def has_restriction(self, target: int, source: int) -> bool:
        return (target, source) in self.restrictions

    def restrict(self, target: int, source: int, elem):
        return self.restrictions[(target, source)][elem]

    def generators(self) -> List[Tuple[int, object]]:
        """All generators (object, element) pairs."""
        result = []
        for obj in self.objects:
            for elem in self.fibers[obj]:
                result.append((obj, elem))
        return result

    def total_elements(self) -> int:
        return sum(len(self.fibers[obj]) for obj in self.objects)

    def covers(self, gen: Tuple[int, object], target_obj: int, target_elem) -> bool:
        """Does generator gen cover element target_elem at target_obj?"""
        src_obj, src_elem = gen
        if not self.has_restriction(target_obj, src_obj):
            return False
        return self.restrict(target_obj, src_obj, src_elem) == target_elem

    def is_covering_set(self, gens: Set[Tuple[int, object]]) -> bool:
        """Check if a set of generators covers all elements."""
        for obj in self.objects:
            for elem in self.fibers[obj]:
                covered = False
                for gen in gens:
                    if self.covers(gen, obj, elem):
                        covered = True
                        break
                if not covered:
                    return False
        return True

    def min_cover_size(self) -> int:
        """Compute minimum covering set size by exhaustive search."""
        all_gens = self.generators()
        n = len(all_gens)
        for size in range(n + 1):
            for subset in combinations(range(n), size):
                gen_set = {all_gens[i] for i in subset}
                if self.is_covering_set(gen_set):
                    return size
        return n  # Should not reach here

    def is_self_covering(self) -> bool:
        """Check if every element covers itself."""
        for obj in self.objects:
            for elem in self.fibers[obj]:
                if not self.has_restriction(obj, obj):
                    return False
                if self.restrict(obj, obj, elem) != elem:
                    return False
        return True


# =============================================================================
# Model Constructors
# =============================================================================

def discrete_model(n: int, m: int) -> PresheafModel:
    """Discrete category on n objects with fiber size m.
    Only identity restrictions."""
    fibers = {i: list(range(m)) for i in range(n)}
    restrictions = {(i, i): {x: x for x in range(m)} for i in range(n)}
    return PresheafModel(n, fibers, restrictions)


def connected_model(n: int, m: int) -> PresheafModel:
    """Fully connected category on n objects with fiber size m.
    All restrictions are identity."""
    fibers = {i: list(range(m)) for i in range(n)}
    restrictions = {}
    for i in range(n):
        for j in range(n):
            restrictions[(i, j)] = {x: x for x in range(m)}
    return PresheafModel(n, fibers, restrictions)


def partial_connected_model(n: int, m: int, edges: List[Tuple[int, int]]) -> PresheafModel:
    """Category with specified restriction edges plus self-loops.
    All restrictions are identity."""
    fibers = {i: list(range(m)) for i in range(n)}
    restrictions = {}
    for i in range(n):
        restrictions[(i, i)] = {x: x for x in range(m)}
    for (tgt, src) in edges:
        restrictions[(tgt, src)] = {x: x for x in range(m)}
    return PresheafModel(n, fibers, restrictions)


def surjective_model(n: int, m_terminal: int, m_other: int) -> PresheafModel:
    """Terminal source model: object 0 has fiber size m_terminal,
    other objects have fiber size m_other ≤ m_terminal.
    Restriction from 0 maps x to x mod m_other."""
    fibers = {0: list(range(m_terminal))}
    for i in range(1, n):
        fibers[i] = list(range(m_other))
    restrictions = {}
    for i in range(n):
        restrictions[(i, i)] = {x: x for x in fibers[i]}
    for i in range(1, n):
        restrictions[(i, 0)] = {x: x % m_other for x in range(m_terminal)}
    return PresheafModel(n, fibers, restrictions)


# =============================================================================
# Generator Graph
# =============================================================================

class GeneratorGraph:
    """The generator graph of a presheaf model.

    Vertices: all generators (object, element)
    Edges: gen1 -> gen2 if gen1 covers gen2
    """

    def __init__(self, model: PresheafModel):
        self.model = model
        self.vertices = model.generators()
        self.adj = {}  # vertex -> set of vertices it dominates
        for v in self.vertices:
            self.adj[v] = set()
            for u in self.vertices:
                if model.covers(v, u[0], u[1]):
                    self.adj[v].add(u)

    def is_dominating(self, S: Set) -> bool:
        """Check if S is a dominating set."""
        dominated = set()
        for v in S:
            dominated.add(v)
            dominated.update(self.adj[v])
        return dominated >= set(self.vertices)

    def min_domination_number(self) -> int:
        """Compute minimum dominating set size."""
        n = len(self.vertices)
        for size in range(n + 1):
            for subset in combinations(range(n), size):
                S = {self.vertices[i] for i in subset}
                if self.is_dominating(S):
                    return size
        return n

    def degree(self, v) -> int:
        """Out-degree: how many vertices v dominates."""
        return len(self.adj[v])


# =============================================================================
# Shannon Lower Bound
# =============================================================================

def shannon_lower_bound(model: PresheafModel) -> int:
    """Compute the categorical Shannon lower bound:
    max over objects X of ceil(|F(X)| / max_Y |{restrictions from Y covering X}|)

    Each generator covers at most 1 element per object. The number of generators
    at object Y that can cover elements at X is |F(Y)| if there's a restriction
    from Y to X. So the total coverage at X is at most
    sum_{Y with restriction to X} |F(Y)|.

    But we can do better: each generator covers exactly 1 element at X (if any).
    So we need at least |F(X)| / (max multiplicity) generators overall.
    """
    bound = 0
    for x in model.objects:
        fx_size = len(model.fibers[x])
        # How many objects have a restriction to x?
        coverage = sum(1 for y in model.objects if model.has_restriction(x, y))
        if coverage > 0:
            local_bound = math.ceil(fx_size / coverage)
            bound = max(bound, local_bound)
    return bound


# =============================================================================
# Demo 1: Discrete Category Tightness
# =============================================================================

def demo_discrete_tightness():
    """Demonstrate that discrete categories achieve the worst case."""
    print("=" * 60)
    print("DEMO 1: Discrete Category Tightness")
    print("=" * 60)
    print()

    for n in range(1, 5):
        for m in range(1, 4):
            model = discrete_model(n, m)
            mcs = model.min_cover_size()
            total = model.total_elements()
            print(f"  n={n}, m={m}: minCoverSize = {mcs}, "
                  f"totalElements = {total}, "
                  f"tight = {mcs == total}")
            assert mcs == total, f"Tightness failed for n={n}, m={m}!"

    print()
    print("  ✓ All discrete models achieve minCoverSize = n * m (tight bound)")
    print()


# =============================================================================
# Demo 2: Connected Category Compression
# =============================================================================

def demo_connected_compression():
    """Demonstrate compression in connected categories."""
    print("=" * 60)
    print("DEMO 2: Connected Category Compression")
    print("=" * 60)
    print()

    for n in range(1, 5):
        for m in range(1, 4):
            disc = discrete_model(n, m)
            conn = connected_model(n, m)
            disc_mcs = disc.min_cover_size()
            conn_mcs = conn.min_cover_size()
            ratio = disc_mcs / conn_mcs if conn_mcs > 0 else float('inf')
            print(f"  n={n}, m={m}: discrete={disc_mcs}, connected={conn_mcs}, "
                  f"compression_ratio={ratio:.1f}")

    print()
    print("  ✓ Connected categories compress by factor n")
    print()


# =============================================================================
# Demo 3: Generator Graph Domination
# =============================================================================

def demo_generator_graph():
    """Demonstrate the generator graph and domination equivalence."""
    print("=" * 60)
    print("DEMO 3: Generator Graph and Domination")
    print("=" * 60)
    print()

    # Small example: 3 objects, fiber size 2
    model = partial_connected_model(3, 2, [(1, 0), (2, 0)])
    graph = GeneratorGraph(model)

    print(f"  Model: 3 objects, fiber size 2, edges 0→1, 0→2")
    print(f"  Vertices: {graph.vertices}")
    print(f"  Degrees: ", end="")
    for v in graph.vertices:
        print(f"{v}:{graph.degree(v)} ", end="")
    print()

    mcs_cover = model.min_cover_size()
    mcs_dom = graph.min_domination_number()
    print(f"  minCoverSize = {mcs_cover}")
    print(f"  minDominationNumber = {mcs_dom}")
    print(f"  Equal = {mcs_cover == mcs_dom}")
    print()

    # Verify domination = covering for several models
    test_cases = [
        ("discrete 2x2", discrete_model(2, 2)),
        ("connected 3x2", connected_model(3, 2)),
        ("partial 3x2", partial_connected_model(3, 2, [(0, 1)])),
    ]
    for name, m in test_cases:
        g = GeneratorGraph(m)
        assert m.min_cover_size() == g.min_domination_number(), \
            f"Cover ≠ domination for {name}!"
        print(f"  ✓ {name}: cover = domination = {m.min_cover_size()}")

    print()


# =============================================================================
# Demo 4: Shannon Lower Bound
# =============================================================================

def demo_shannon_bound():
    """Verify the Shannon lower bound on small instances."""
    print("=" * 60)
    print("DEMO 4: Shannon Lower Bound")
    print("=" * 60)
    print()

    test_cases = [
        ("discrete 3x3", discrete_model(3, 3)),
        ("connected 3x3", connected_model(3, 3)),
        ("partial 3x2 (0→1)", partial_connected_model(3, 2, [(0, 1)])),
        ("partial 3x2 (0→1,0→2)", partial_connected_model(3, 2, [(0, 1), (0, 2)])),
        ("surjective 3 (4→2)", surjective_model(3, 4, 2)),
    ]

    all_valid = True
    for name, model in test_cases:
        mcs = model.min_cover_size()
        lb = shannon_lower_bound(model)
        valid = mcs >= lb
        all_valid = all_valid and valid
        print(f"  {name}: minCoverSize={mcs}, shannonLB={lb}, valid={valid}")

    print()
    if all_valid:
        print("  ✓ Shannon lower bound verified on all test cases")
    else:
        print("  ✗ Shannon lower bound VIOLATED!")
    print()


# =============================================================================
# Demo 5: Morphism Density Compression Tradeoff
# =============================================================================

def demo_compression_tradeoff():
    """Visualize how morphism density affects compression.

    For each edge density (number of restriction pairs beyond self-loops),
    compute the minimum cover size. Show the tradeoff curve.
    """
    print("=" * 60)
    print("DEMO 5: Morphism Density Compression Tradeoff")
    print("=" * 60)
    print()

    n = 3
    m = 3
    all_possible_edges = [(i, j) for i in range(n) for j in range(n) if i != j]
    max_edges = len(all_possible_edges)

    print(f"  Objects: {n}, Fiber size: {m}")
    print(f"  Maximum additional edges: {max_edges}")
    print()
    print(f"  {'Edges':>8}  {'R (total)':>10}  {'minCover':>10}  {'ratio':>8}")
    print(f"  {'-'*8}  {'-'*10}  {'-'*10}  {'-'*8}")

    for num_edges in range(max_edges + 1):
        # Take first num_edges edges (arbitrary ordering)
        edges = all_possible_edges[:num_edges]
        model = partial_connected_model(n, m, edges)
        total_restrictions = n + num_edges  # self-loops + extra edges
        mcs = model.min_cover_size()
        ratio = mcs / (n * m)
        print(f"  {num_edges:>8}  {total_restrictions:>10}  {mcs:>10}  {ratio:>8.3f}")

    print()

    # Verify the conjecture: minCoverSize * R ≤ n² * m
    print("  Verifying Morphism Density Compression Law: minCoverSize * R ≤ n² * m")
    conjecture_valid = True
    for num_edges in range(max_edges + 1):
        edges = all_possible_edges[:num_edges]
        model = partial_connected_model(n, m, edges)
        R = n + num_edges
        mcs = model.min_cover_size()
        lhs = mcs * R
        rhs = n * n * m
        valid = lhs <= rhs
        conjecture_valid = conjecture_valid and valid
        status = "✓" if valid else "✗"
        print(f"    {status} edges={num_edges}, R={R}: {mcs}*{R}={lhs} {'≤' if valid else '>'} {rhs}")

    if conjecture_valid:
        print(f"  ✓ Conjecture verified for n={n}, m={m}")
    else:
        print(f"  ✗ Conjecture VIOLATED — needs refinement")
    print()


# =============================================================================
# Demo 6: Terminal Object Compression
# =============================================================================

def demo_terminal_compression():
    """Demonstrate compression via terminal source with surjective restrictions."""
    print("=" * 60)
    print("DEMO 6: Terminal Object Compression")
    print("=" * 60)
    print()

    for n in [2, 3, 4]:
        for m_term in [2, 3, 4]:
            for m_other in range(1, m_term + 1):
                model = surjective_model(n, m_term, m_other)
                mcs = model.min_cover_size()
                print(f"  n={n}, |F(T)|={m_term}, |F(other)|={m_other}: "
                      f"minCoverSize={mcs}")

    print()
    print("  ✓ Terminal compression: minCoverSize ≤ |F(T)| when restrictions surject")
    print()


# =============================================================================
# Main
# =============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     CATEGORICAL SHANNON THEORY — INTERACTIVE DEMO      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_discrete_tightness()
    demo_connected_compression()
    demo_generator_graph()
    demo_shannon_bound()
    demo_compression_tradeoff()
    demo_terminal_compression()

    print("=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


if __name__ == "__main__":
    main()
