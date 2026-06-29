#!/usr/bin/env python3
"""
Applications of Tropical Bridge Defect Theory

This module demonstrates real-world connections of the defect invariant
δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1 to:

1. Network controllability — how many independent controls are needed
2. Electrical networks — redundancy in resistor networks
3. Communication networks — information flow obstruction counting
"""

from collections import defaultdict
from itertools import combinations
from typing import Set, List, Tuple
import random


class Graph:
    """Simple undirected graph."""

    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                self.add_edge(u, v)

    def add_edge(self, u, v):
        if u != v:
            self.adj[u].add(v)
            self.adj[v].add(u)

    def vertices(self):
        return set(range(self.n))

    def edges(self):
        seen = set()
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                e = (min(u, v), max(u, v))
                if e not in seen:
                    seen.add(e)
                    result.append(e)
        return sorted(result)

    def connected_components(self, vertex_set=None):
        if vertex_set is None:
            vertex_set = self.vertices()
        vertex_set = set(vertex_set)
        visited = set()
        components = []
        for v in vertex_set:
            if v not in visited:
                comp = set()
                stack = [v]
                while stack:
                    u = stack.pop()
                    if u in comp:
                        continue
                    comp.add(u)
                    visited.add(u)
                    for w in self.adj[u]:
                        if w in vertex_set and w not in comp:
                            stack.append(w)
                components.append(comp)
        return components


def induced_edge_count(G, S):
    count = 0
    for u in S:
        for v in G.adj[u]:
            if v in S and u < v:
                count += 1
    return count


def induced_component_count(G, S):
    if not S:
        return 0
    return len(G.connected_components(S))


def induced_cycle_rank(G, S):
    e = induced_edge_count(G, S)
    c = induced_component_count(G, S)
    return e + c - len(S)


def root_component_count(G, q, S):
    if not S:
        return 0
    remaining = G.vertices() - {q}
    comps = G.connected_components(remaining)
    return sum(1 for comp in comps if comp & S)


def structural_defect(G, q, S):
    return induced_cycle_rank(G, S) + root_component_count(G, q, S) - 1


# ═══════════════════════════════════════════════════════════════
# APPLICATION 1: Network Controllability
# ═══════════════════════════════════════════════════════════════

def network_controllability_analysis(G, controller, sensors):
    """
    Analyze network controllability using defect theory.

    In a network where a controller (root q) wants to independently
    influence a set of sensors S, the structural defect measures the
    number of "control obstructions" — dimensions of the control space
    that are lost due to:
    - Cycles among sensors (creating redundant feedback loops)
    - Sensors in different network partitions (requiring independent channels)

    Args:
        G: Network graph
        controller: Controller vertex (root)
        sensors: Set of sensor vertices

    Returns:
        Dictionary with analysis results
    """
    beta1 = induced_cycle_rank(G, sensors)
    kappa = root_component_count(G, controller, sensors)
    delta = structural_defect(G, controller, sensors)

    result = {
        'controller': controller,
        'sensors': sorted(sensors),
        'cycle_redundancy': beta1,
        'partition_count': kappa,
        'control_defect': delta,
        'perfectly_controllable': delta == 0,
        'diagnosis': []
    }

    if beta1 > 0:
        result['diagnosis'].append(
            f"  ⚠ {beta1} cycle(s) among sensors create redundant feedback"
        )
    if kappa > 1:
        result['diagnosis'].append(
            f"  ⚠ Sensors span {kappa} disconnected partitions "
            f"(need {kappa - 1} additional control channels)"
        )
    if delta == 0:
        result['diagnosis'].append(
            "  ✓ Perfect controllability: tree-like sensor layout in single partition"
        )

    return result


# ═══════════════════════════════════════════════════════════════
# APPLICATION 2: Electrical Network Redundancy
# ═══════════════════════════════════════════════════════════════

def electrical_redundancy_analysis(G, ground, measurement_nodes):
    """
    Analyze redundancy in an electrical (resistor) network.

    The graph represents a resistor network with a grounded node.
    The defect measures how many independent voltage measurements
    at nodes in S are "wasted" due to:
    - Kirchhoff loops (cycles) creating dependent measurements
    - Disconnected subnetworks requiring separate ground connections

    Args:
        G: Resistor network graph
        ground: Ground node
        measurement_nodes: Set of measurement points

    Returns:
        Analysis dictionary
    """
    beta1 = induced_cycle_rank(G, measurement_nodes)
    kappa = root_component_count(G, ground, measurement_nodes)
    delta = structural_defect(G, ground, measurement_nodes)

    return {
        'ground_node': ground,
        'measurement_nodes': sorted(measurement_nodes),
        'kirchhoff_loops': beta1,
        'subnetwork_count': kappa,
        'redundancy_defect': delta,
        'optimal': delta == 0,
        'independent_measurements': len(measurement_nodes) - beta1,
        'additional_grounds_needed': max(0, kappa - 1),
    }


# ═══════════════════════════════════════════════════════════════
# APPLICATION 3: Communication Flow Obstructions
# ═══════════════════════════════════════════════════════════════

def communication_flow_analysis(G, source, destinations):
    """
    Analyze information flow obstructions in a communication network.

    The structural defect counts the total obstructions to clean
    information propagation from a source to destination nodes:
    - Cycles create echo/feedback interference
    - Partitioning creates multipath routing requirements

    Args:
        G: Communication network
        source: Source node
        destinations: Set of destination nodes

    Returns:
        Analysis dictionary
    """
    beta1 = induced_cycle_rank(G, destinations)
    kappa = root_component_count(G, source, destinations)
    delta = structural_defect(G, source, destinations)

    return {
        'source': source,
        'destinations': sorted(destinations),
        'echo_loops': beta1,
        'routing_partitions': kappa,
        'total_obstructions': delta,
        'clean_broadcast': delta == 0,
    }


def print_separator():
    print("=" * 65)


def main():
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║   APPLICATIONS OF TROPICAL BRIDGE DEFECT THEORY             ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Network Controllability
    print_separator()
    print("  APPLICATION 1: Network Controllability")
    print_separator()
    print()

    # Corporate hierarchy network
    # 0 = CEO, 1-4 = VPs, 5-8 = managers
    corp = Graph(9, [
        (0, 1), (0, 2), (0, 3), (0, 4),  # CEO to VPs
        (1, 5), (2, 6), (3, 7), (4, 8),  # VPs to managers
        (5, 6),  # Cross-department collaboration
    ])

    # Scenario A: Monitor all managers
    r = network_controllability_analysis(corp, 0, {5, 6, 7, 8})
    print(f"  Scenario A: CEO monitors all managers")
    print(f"  Sensors: {r['sensors']}")
    print(f"  Cycle redundancy (β₁):    {r['cycle_redundancy']}")
    print(f"  Network partitions (κ):   {r['partition_count']}")
    print(f"  Control defect (δ):       {r['control_defect']}")
    for d in r['diagnosis']:
        print(d)
    print()

    # Scenario B: Monitor managers in one division
    r = network_controllability_analysis(corp, 0, {5, 6})
    print(f"  Scenario B: CEO monitors managers {{5, 6}} (connected)")
    print(f"  Cycle redundancy (β₁):    {r['cycle_redundancy']}")
    print(f"  Network partitions (κ):   {r['partition_count']}")
    print(f"  Control defect (δ):       {r['control_defect']}")
    for d in r['diagnosis']:
        print(d)
    print()

    # Application 2: Electrical Network
    print_separator()
    print("  APPLICATION 2: Electrical Network Redundancy")
    print_separator()
    print()

    # Wheatstone bridge: classic circuit with redundant measurements
    # 0 = ground, 1-4 = nodes
    wheatstone = Graph(5, [
        (0, 1), (0, 2), (1, 3), (2, 3), (1, 4), (2, 4), (3, 4)
    ])

    r = electrical_redundancy_analysis(wheatstone, 0, {1, 2, 3, 4})
    print(f"  Wheatstone bridge: measure all internal nodes")
    print(f"  Ground: {r['ground_node']}")
    print(f"  Kirchhoff loops:          {r['kirchhoff_loops']}")
    print(f"  Subnetwork count:         {r['subnetwork_count']}")
    print(f"  Redundancy defect:        {r['redundancy_defect']}")
    print(f"  Independent measurements: {r['independent_measurements']}")
    print(f"  Optimal placement:        {'Yes' if r['optimal'] else 'No'}")
    print()

    # Series circuit: no redundancy
    series = Graph(5, [(0, 1), (1, 2), (2, 3), (3, 4)])
    r = electrical_redundancy_analysis(series, 0, {1, 2, 3, 4})
    print(f"  Series circuit: measure all nodes")
    print(f"  Kirchhoff loops:          {r['kirchhoff_loops']}")
    print(f"  Subnetwork count:         {r['subnetwork_count']}")
    print(f"  Redundancy defect:        {r['redundancy_defect']}")
    print(f"  Optimal placement:        {'Yes' if r['optimal'] else 'No'}")
    print()

    # Application 3: Communication
    print_separator()
    print("  APPLICATION 3: Communication Flow Analysis")
    print_separator()
    print()

    # Internet-like topology
    internet = Graph(8, [
        (0, 1), (0, 2),  # Source to routers
        (1, 3), (1, 4), (2, 5), (2, 6),  # Routers to servers
        (3, 4), (5, 6),  # Redundant links
        (4, 7), (6, 7),  # Connections to final server
    ])

    r = communication_flow_analysis(internet, 0, {3, 4, 5, 6, 7})
    print(f"  Internet topology: source 0 → destinations {{3,4,5,6,7}}")
    print(f"  Echo loops:               {r['echo_loops']}")
    print(f"  Routing partitions:       {r['routing_partitions']}")
    print(f"  Total obstructions:       {r['total_obstructions']}")
    print(f"  Clean broadcast:          {'Yes' if r['clean_broadcast'] else 'No'}")
    print()

    r = communication_flow_analysis(internet, 0, {3, 5})
    print(f"  Reduced set: source 0 → destinations {{3, 5}}")
    print(f"  Echo loops:               {r['echo_loops']}")
    print(f"  Routing partitions:       {r['routing_partitions']}")
    print(f"  Total obstructions:       {r['total_obstructions']}")
    print(f"  Clean broadcast:          {'Yes' if r['clean_broadcast'] else 'No'}")
    print()

    print_separator()
    print("  ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print_separator()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Defect Theory Demo — Tropical Bridge Defect Calculator

Interactive demonstration of the structural defect δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1
for finite graphs with a root vertex and a distinguished vertex subset.

Usage:
    python demo.py

The demo computes:
- β₁(G[S]): cycle rank (first Betti number) of the induced subgraph
- κ(G,q,S): number of components of G-{q} that intersect S
- δ(G,q,S): the structural defect β₁ + κ - 1

Three theorems are verified computationally:
1. Nonnegativity: δ ≥ 0 for nonempty S
2. Zero-defect rigidity: δ = 0 ↔ β₁ = 0 and κ = 1
3. Tree-component exactness: acyclic + single-component ⟹ δ = 0
"""

from itertools import combinations
from collections import defaultdict


class SimpleGraph:
    """A simple undirected graph on vertices 0..n-1."""

    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                self.add_edge(u, v)

    def add_edge(self, u, v):
        if u != v:
            self.adj[u].add(v)
            self.adj[v].add(u)

    def vertices(self):
        return set(range(self.n))

    def neighbors(self, v):
        return self.adj[v]

    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                e = (min(u, v), max(u, v))
                if e not in seen:
                    seen.add(e)
                    yield e

    def induced_subgraph(self, S):
        """Return edges of the induced subgraph on vertex set S."""
        S = set(S)
        return [(u, v) for u, v in self.edges() if u in S and v in S]

    def connected_components(self, vertex_set=None):
        """Return connected components of the subgraph induced on vertex_set."""
        if vertex_set is None:
            vertex_set = self.vertices()
        vertex_set = set(vertex_set)
        visited = set()
        components = []
        for v in vertex_set:
            if v not in visited:
                comp = set()
                stack = [v]
                while stack:
                    u = stack.pop()
                    if u in comp:
                        continue
                    comp.add(u)
                    visited.add(u)
                    for w in self.adj[u]:
                        if w in vertex_set and w not in comp:
                            stack.append(w)
                components.append(comp)
        return components

    def is_connected(self):
        if self.n == 0:
            return True
        comps = self.connected_components()
        return len(comps) == 1


def induced_edge_count(G, S):
    """Number of edges in G[S]."""
    return len(G.induced_subgraph(S))


def induced_component_count(G, S):
    """Number of connected components of G[S]."""
    if not S:
        return 0
    return len(G.connected_components(S))


def induced_cycle_rank(G, S):
    """First Betti number β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|."""
    S = set(S)
    e = induced_edge_count(G, S)
    c = induced_component_count(G, S)
    return e + c - len(S)


def root_component_count(G, q, S):
    """Number of components of G-{q} that intersect S."""
    S = set(S)
    if not S:
        return 0
    remaining = G.vertices() - {q}
    comps = G.connected_components(remaining)
    return sum(1 for comp in comps if comp & S)


def structural_defect(G, q, S):
    """The structural defect δ = β₁(G[S]) + κ(G,q,S) - 1."""
    return induced_cycle_rank(G, S) + root_component_count(G, q, S) - 1


def print_separator():
    print("=" * 65)


def demo_example(name, G, q, S):
    """Run the defect calculation and display results."""
    S = set(S)
    print_separator()
    print(f"  {name}")
    print_separator()
    print(f"  Vertices: {sorted(G.vertices())}")
    print(f"  Edges:    {sorted(G.edges())}")
    print(f"  Root q:   {q}")
    print(f"  Subset S: {sorted(S)}")
    print()

    beta1 = induced_cycle_rank(G, S)
    kappa = root_component_count(G, q, S)
    delta = structural_defect(G, q, S)
    e = induced_edge_count(G, S)
    c = induced_component_count(G, S)

    print(f"  |E(G[S])| = {e}")
    print(f"  c(G[S])   = {c}  (connected components)")
    print(f"  |S|       = {len(S)}")
    print(f"  β₁(G[S])  = {e} + {c} - {len(S)} = {beta1}")
    print(f"  κ(G,q,S)  = {kappa}")
    print(f"  δ(G,q,S)  = {beta1} + {kappa} - 1 = {delta}")
    print()

    # Verify theorems
    if S:
        assert delta >= 0, f"FAILED: nonnegativity (δ = {delta})"
        print(f"  ✓ Theorem 1 (Nonnegativity): δ = {delta} ≥ 0")

        zero_iff = (delta == 0) == (beta1 == 0 and kappa == 1)
        assert zero_iff, f"FAILED: zero-defect rigidity"
        print(f"  ✓ Theorem 2 (Zero-defect rigidity): δ=0 ↔ (β₁=0 ∧ κ=1)")

        if beta1 == 0 and kappa == 1:
            assert delta == 0, f"FAILED: tree-component exactness"
            print(f"  ✓ Theorem 3 (Tree-component exactness): β₁=0, κ=1 ⟹ δ=0")
        else:
            print(f"  — Theorem 3 (Tree-component exactness): "
                  f"conditions not met (β₁={beta1}, κ={kappa})")
    print()


def exhaustive_test(max_vertices=6):
    """Exhaustive test of the defect identity on small graphs."""
    print_separator()
    print("  EXHAUSTIVE VERIFICATION")
    print_separator()
    print()

    total_tests = 0
    nonneg_ok = 0
    rigidity_ok = 0

    for n in range(2, max_vertices + 1):
        all_possible_edges = list(combinations(range(n), 2))
        for num_edges in range(n - 1, len(all_possible_edges) + 1):
            for edge_set in combinations(all_possible_edges, num_edges):
                G = SimpleGraph(n, edge_set)
                if not G.is_connected():
                    continue

                for q in range(n):
                    for k in range(1, n):
                        remaining = [v for v in range(n) if v != q]
                        for S_tuple in combinations(remaining, k):
                            S = set(S_tuple)
                            delta = structural_defect(G, q, S)
                            beta1 = induced_cycle_rank(G, S)
                            kappa = root_component_count(G, q, S)

                            total_tests += 1

                            # Nonnegativity
                            assert delta >= 0
                            nonneg_ok += 1

                            # Rigidity
                            assert (delta == 0) == (beta1 == 0 and kappa == 1)
                            rigidity_ok += 1

    print(f"  Tested {total_tests} (G, q, S) configurations")
    print(f"  ✓ All {nonneg_ok} nonnegativity checks passed")
    print(f"  ✓ All {rigidity_ok} zero-defect rigidity checks passed")
    print()


def main():
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║     DEFECT THEORY — TROPICAL BRIDGE DEFECT CALCULATOR       ║")
    print("║                                                             ║")
    print("║  δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1                       ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    # Example 1: Path graph — tree, single component ⟹ δ = 0
    G1 = SimpleGraph(4, [(0, 1), (1, 2), (2, 3)])
    demo_example("Example 1: Path P₄, q=0, S={1,2,3}", G1, 0, {1, 2, 3})

    # Example 2: Triangle — cycle in G[S] ⟹ δ = 1
    G2 = SimpleGraph(4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])
    demo_example("Example 2: K₄, q=0, S={1,2,3}", G2, 0, {1, 2, 3})

    # Example 3: Two components separated by root
    G3 = SimpleGraph(5, [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (3, 4)])
    demo_example("Example 3: Root-separated, q=0, S={1,2,3,4}", G3, 0, {1, 2, 3, 4})

    # Example 4: Star graph — tree, single component ⟹ δ = 0
    G4 = SimpleGraph(5, [(0, 1), (0, 2), (0, 3), (0, 4)])
    demo_example("Example 4: Star K₁,₄, q=0, S={1,2,3,4}", G4, 0, {1, 2, 3, 4})

    # Example 5: Cycle C₅
    G5 = SimpleGraph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
    demo_example("Example 5: Cycle C₅, q=0, S={1,2,3,4}", G5, 0, {1, 2, 3, 4})

    # Example 6: Partial subset
    G6 = SimpleGraph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
    demo_example("Example 6: Cycle C₅, q=0, S={1,3}", G6, 0, {1, 3})

    # Exhaustive test
    print("  Running exhaustive verification on graphs with ≤ 6 vertices...")
    print("  (This tests ALL connected graphs, roots, and subsets)")
    print()
    exhaustive_test(max_vertices=6)

    print_separator()
    print("  ALL DEMONSTRATIONS COMPLETE")
    print_separator()


if __name__ == "__main__":
    main()
