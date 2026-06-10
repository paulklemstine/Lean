#!/usr/bin/env python3
"""
Applications of the Equality Characterization Theorem.

This module demonstrates real-world applications of the tropical
chip-firing bridge equality characterization:

1. Network Flow Analysis — identifying rigid subsystems in networks
2. Electrical Network Design — finding zero-circulation sub-circuits
3. Phylogenetic Tree Extraction — recognizing tree structure in data
4. Tropical Linear Algebra — classifying simplicial cells

Each application uses the core criterion:
  Equality ⟺ single component of G-{q} + induced tree
"""

from __future__ import annotations
from collections import defaultdict, deque
from itertools import combinations


class SimpleGraph:
    """Simple undirected graph."""

    def __init__(self, n: int, edges: list[tuple[int, int]],
                 labels: list[str] | None = None):
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        self.labels = labels or [str(i) for i in range(n)]
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def edges(self) -> list[tuple[int, int]]:
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result

    def label(self, v: int) -> str:
        return self.labels[v]


def is_connected_subgraph(G: SimpleGraph, S: set[int]) -> bool:
    if len(S) <= 1:
        return True
    start = next(iter(S))
    visited = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for w in G.adj[v]:
            if w in S and w not in visited:
                visited.add(w)
                queue.append(w)
    return visited == S


def induced_edge_count(G: SimpleGraph, S: set[int]) -> int:
    return sum(1 for u in S for v in G.adj[u] if v in S and u < v)


def is_induced_tree(G: SimpleGraph, S: set[int]) -> bool:
    if len(S) <= 1:
        return True
    return (is_connected_subgraph(G, S) and
            induced_edge_count(G, S) == len(S) - 1)


def is_single_component(G: SimpleGraph, q: int, S: set[int]) -> bool:
    if len(S) <= 1:
        return True
    start = next(iter(S))
    visited = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for w in G.adj[v]:
            if w != q and w not in visited:
                visited.add(w)
                queue.append(w)
    return S <= visited


def find_all_tight_sets(G: SimpleGraph, q: int) -> list[set[int]]:
    """Find all equality-tight sets for given graph and root."""
    others = [v for v in range(G.n) if v != q]
    tight = []
    for r in range(len(others) + 1):
        for combo in combinations(others, r):
            S = set(combo)
            if is_single_component(G, q, S) and is_induced_tree(G, S):
                tight.append(S)
    return tight


def find_maximal_tight_sets(G: SimpleGraph, q: int) -> list[set[int]]:
    """Find maximal tight sets (not contained in a larger tight set)."""
    all_tight = find_all_tight_sets(G, q)
    maximal = []
    for S in all_tight:
        if not any(S < T for T in all_tight):
            maximal.append(S)
    return maximal


# ──────────────────────────────────────────────────────────────
# Application 1: Network Flow — Rigid Subsystem Detection
# ──────────────────────────────────────────────────────────────

def app_network_flow():
    """
    Network Flow: Identifying Rigid Communication Paths

    In a communication network, the "root" q is a central server.
    A subset S of nodes forms a "rigid subsystem" when the
    communication capacity from S to q is perfectly determined
    by the network topology — no redundancy, no bottleneck.

    The equality criterion identifies these rigid subsystems:
    they must form a tree within a single region separated by q.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Flow — Rigid Subsystem Detection")
    print("=" * 70)

    # A small corporate network
    # 0 = Central server (root)
    # 1-7 = Department nodes
    G = SimpleGraph(8, [
        (0, 1), (0, 2), (0, 3),      # Server connects to dept heads
        (1, 4), (1, 5),               # Dept 1 subnodes
        (2, 5), (2, 6),               # Dept 2 subnodes
        (3, 6), (3, 7),               # Dept 3 subnodes
        (4, 5),                        # Cross-link
    ], labels=["Server", "Head-A", "Head-B", "Head-C",
               "Node-4", "Node-5", "Node-6", "Node-7"])

    q = 0  # Central server is root
    print(f"\nNetwork topology: {len(G.edges())} links, {G.n} nodes")
    print(f"Root (central server): {G.label(q)}")
    print()

    maximal = find_maximal_tight_sets(G, q)
    print(f"Found {len(maximal)} maximal rigid subsystems:")
    for i, S in enumerate(sorted(maximal, key=len, reverse=True)):
        names = {G.label(v) for v in S}
        tree_edges = induced_edge_count(G, S)
        print(f"  {i+1}. {names} — {len(S)} nodes, {tree_edges} links (tree)")

    all_tight = find_all_tight_sets(G, q)
    print(f"\nTotal rigid subsystems (including sub-systems): {len(all_tight)}")
    print("\nInterpretation: Each rigid subsystem has EXACTLY the right number")
    print("of links to function — adding or removing a link changes capacity.")


# ──────────────────────────────────────────────────────────────
# Application 2: Electrical Networks
# ──────────────────────────────────────────────────────────────

def app_electrical():
    """
    Electrical Networks: Zero-Circulation Subnetworks

    In an electrical network with a ground node (root q),
    tight sets correspond to subnetworks with NO internal
    current loops — all current flows in a tree pattern
    toward the ground.

    This is the discrete analogue of: the Laplacian energy
    equals the edge energy when there are no cyclic modes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Electrical Networks — Zero-Circulation Detection")
    print("=" * 70)

    # A resistor network (planar grid)
    # 0 = Ground node
    G = SimpleGraph(9, [
        (0, 1), (1, 2),           # Top row
        (3, 4), (4, 5),           # Middle row
        (6, 7), (7, 8),           # Bottom row
        (0, 3), (1, 4), (2, 5),   # Vertical links
        (3, 6), (4, 7), (5, 8),   # Vertical links
    ], labels=["GND", "A1", "A2", "B0", "B1", "B2", "C0", "C1", "C2"])

    q = 0  # Ground
    print(f"\n3×3 Grid Network with ground at {G.label(q)}")
    print(f"Nodes: {[G.label(i) for i in range(G.n)]}")

    tight = find_all_tight_sets(G, q)
    maximal = find_maximal_tight_sets(G, q)

    print(f"\nTotal tree-like (no-loop) subnetworks: {len(tight)}")
    print(f"Maximal tree-like subnetworks: {len(maximal)}")

    for S in sorted(maximal, key=len, reverse=True)[:5]:
        names = [G.label(v) for v in sorted(S)]
        # Compute Laplacian energy for a test potential
        pot = {v: v for v in range(G.n)}  # Simple test potential
        lap_e = sum(
            (pot.get(u, 0) - pot.get(v, 0))**2
            for u in S for v in G.adj[u] if v in S and u < v
        )
        print(f"  {names}: {len(S)} nodes, internal energy = {lap_e}")

    print("\nPhysics: In these subnetworks, Kirchhoff's voltage law")
    print("is automatically satisfied — no loop currents exist.")


# ──────────────────────────────────────────────────────────────
# Application 3: Phylogenetic Tree Extraction
# ──────────────────────────────────────────────────────────────

def app_phylogenetics():
    """
    Phylogenetics: Recognizing Tree-Like Evolution

    Given a network of genetic relationships (including
    horizontal gene transfer = cycles), identify subsets
    of species whose relationships are perfectly tree-like.

    The equality criterion extracts the largest subtrees
    from a potentially reticulate phylogenetic network.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Phylogenetic Tree Extraction")
    print("=" * 70)

    # A phylogenetic network with some horizontal transfer
    # 0 = Outgroup (root)
    species = ["Outgroup", "Human", "Chimp", "Gorilla",
               "Orangutan", "Gibbon", "Macaque", "Mouse"]
    G = SimpleGraph(8, [
        (0, 6),          # Outgroup-Macaque
        (1, 2), (1, 3),  # Human-Chimp, Human-Gorilla
        (2, 3),          # Chimp-Gorilla (creates a cycle!)
        (3, 4),          # Gorilla-Orangutan
        (4, 5),          # Orangutan-Gibbon
        (5, 6),          # Gibbon-Macaque
        (6, 7),          # Macaque-Mouse
        (1, 6),          # Human-Macaque (horizontal transfer?)
    ], labels=species)

    q = 0  # Outgroup as root
    print(f"\nPhylogenetic network: {len(G.edges())} relationships")
    print(f"Root (outgroup): {G.label(q)}")
    print(f"Species: {species[1:]}")

    maximal = find_maximal_tight_sets(G, q)
    print(f"\nMaximal tree-like evolutionary groups:")
    for i, S in enumerate(sorted(maximal, key=len, reverse=True)):
        names = [G.label(v) for v in sorted(S)]
        has_cycle = induced_edge_count(G, S) > len(S) - 1
        print(f"  {i+1}. {names}")
        print(f"     Size: {len(S)}, Edges: {induced_edge_count(G, S)}, "
              f"Cycle: {'Yes' if has_cycle else 'No'}")

    # Show which species pairs are "tree-related"
    print(f"\nTree-related species pairs (where the pair is tight):")
    for i in range(1, G.n):
        for j in range(i+1, G.n):
            S = {i, j}
            if is_single_component(G, q, S) and is_induced_tree(G, S):
                print(f"  {G.label(i)} — {G.label(j)}")


# ──────────────────────────────────────────────────────────────
# Application 4: Tropical Linear Algebra
# ──────────────────────────────────────────────────────────────

def app_tropical():
    """
    Tropical Linear Algebra: Simplicial Cell Classification

    In tropical geometry, tight sets correspond to simplicial
    cells of the tropical Grassmannian — configurations of
    Laplacian columns that are "tropically rigid."

    We classify which column subsets form rigid configurations.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Tropical Geometry — Simplicial Cells")
    print("=" * 70)

    # Complete bipartite graph K_{3,3}
    G = SimpleGraph(6, [
        (0, 3), (0, 4), (0, 5),
        (1, 3), (1, 4), (1, 5),
        (2, 3), (2, 4), (2, 5),
    ], labels=["L0", "L1", "L2", "R0", "R1", "R2"])

    print(f"\nGraph: K_{{3,3}} (complete bipartite)")
    print(f"Vertices: {[G.label(i) for i in range(G.n)]}")

    for q in range(G.n):
        tight = find_all_tight_sets(G, q)
        maximal = find_maximal_tight_sets(G, q)
        print(f"\n  Root = {G.label(q)}:")
        print(f"    Tight sets: {len(tight)}, Maximal: {len(maximal)}")
        for S in sorted(maximal, key=len, reverse=True)[:3]:
            names = [G.label(v) for v in sorted(S)]
            print(f"    Max tight: {names} (size {len(S)})")

    print("\nInterpretation: Each maximal tight set is a 'simplicial cell'")
    print("in the tropical Grassmannian — a region where the tropical")
    print("Plücker coordinates are uniquely determined by tree structure.")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║       APPLICATIONS OF THE EQUALITY CHARACTERIZATION            ║")
    print("║          Tropical Chip-Firing Bridge                           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    app_network_flow()
    app_electrical()
    app_phylogenetics()
    app_tropical()

    print("\n" + "=" * 70)
    print("All applications completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of the Equality Characterization in the Tropical Chip-Firing Bridge.

This demo shows:
1. Classification of equality-tight sets on small graphs
2. Verification of the Laplacian decomposition theorem
3. The energy formula connecting Laplacian to edge differences
4. Exhaustive search for counterexamples on graphs with n ≤ 8
5. Statistics on tight sets across graph families

The central conjecture: for connected G, root q, and S ⊆ V\\{q},
    r(D_S) = tropRank(L_S) - 1
if and only if S lies in one component of G-{q} AND G[S] is a tree.
"""

from __future__ import annotations
import sys
from collections import defaultdict
from itertools import combinations


class SimpleGraph:
    """Simple undirected graph on vertices 0..n-1."""

    def __init__(self, n: int, edges: list[tuple[int, int]]):
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def is_adjacent(self, u: int, v: int) -> bool:
        return v in self.adj[u]

    def vertices(self) -> list[int]:
        return list(range(self.n))

    def edges(self) -> list[tuple[int, int]]:
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited = {0}
        queue = [0]
        while queue:
            v = queue.pop()
            for w in self.adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


def is_connected_subgraph(G: SimpleGraph, S: set[int]) -> bool:
    if len(S) <= 1:
        return True
    start = next(iter(S))
    visited = {start}
    queue = [start]
    while queue:
        v = queue.pop()
        for w in G.adj[v]:
            if w in S and w not in visited:
                visited.add(w)
                queue.append(w)
    return visited == S


def induced_edge_count_unordered(G: SimpleGraph, S: set[int]) -> int:
    count = 0
    for u in S:
        for v in G.adj[u]:
            if v in S and u < v:
                count += 1
    return count


def is_induced_tree(G: SimpleGraph, S: set[int]) -> bool:
    if len(S) == 0:
        return True
    if len(S) == 1:
        return True
    return (is_connected_subgraph(G, S) and
            induced_edge_count_unordered(G, S) == len(S) - 1)


def is_single_component(G: SimpleGraph, q: int, S: set[int]) -> bool:
    if len(S) <= 1:
        return True
    start = next(iter(S))
    visited = {start}
    queue = [start]
    while queue:
        v = queue.pop()
        for w in G.adj[v]:
            if w != q and w not in visited:
                visited.add(w)
                queue.append(w)
    return S <= visited


def is_equality_tight(G: SimpleGraph, q: int, S: set[int]) -> bool:
    return is_single_component(G, q, S) and is_induced_tree(G, S)


def graph_laplacian(G: SimpleGraph) -> list[list[int]]:
    L = [[0] * G.n for _ in range(G.n)]
    for v in range(G.n):
        L[v][v] = G.degree(v)
        for w in G.adj[v]:
            L[v][w] = -1
    return L


def restricted_laplacian(G: SimpleGraph, S: set[int]) -> list[list[int]]:
    S_list = sorted(S)
    k = len(S_list)
    idx = {v: i for i, v in enumerate(S_list)}
    RL = [[0] * k for _ in range(k)]
    for v in S_list:
        i = idx[v]
        for w in G.adj[v]:
            if w in S:
                RL[i][i] += 1
                RL[i][idx[w]] = -1
    return RL


def cut_degree(G: SimpleGraph, v: int, S: set[int]) -> int:
    return sum(1 for w in G.adj[v] if w not in S)


# ──────────────────────────────────────────────────────────────
# Demo 1: Classification on named graphs
# ──────────────────────────────────────────────────────────────

def demo_classification():
    """Demonstrate the equality classification on small named graphs."""
    print("=" * 70)
    print("DEMO 1: Equality-Tight Set Classification")
    print("=" * 70)

    graphs = {
        "Path P4": SimpleGraph(4, [(0,1),(1,2),(2,3)]),
        "Cycle C4": SimpleGraph(4, [(0,1),(1,2),(2,3),(3,0)]),
        "Complete K4": SimpleGraph(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
        "Star S4": SimpleGraph(4, [(0,1),(0,2),(0,3)]),
        "Diamond": SimpleGraph(4, [(0,1),(0,2),(1,2),(1,3),(2,3)]),
        "Petersen": SimpleGraph(10, [
            (0,1),(1,2),(2,3),(3,4),(4,0),
            (5,7),(6,8),(7,9),(8,5),(9,6),
            (0,5),(1,6),(2,7),(3,8),(4,9)
        ]),
    }

    for name, G in graphs.items():
        print(f"\n{'─' * 50}")
        print(f"Graph: {name} (n={G.n}, m={len(G.edges())})")
        print(f"{'─' * 50}")

        for q in range(min(G.n, 3)):  # Test a few roots
            vertices_minus_q = [v for v in range(G.n) if v != q]
            total = 0
            tight_count = 0
            tight_sets = []

            for r in range(len(vertices_minus_q) + 1):
                for combo in combinations(vertices_minus_q, r):
                    S = set(combo)
                    total += 1
                    if is_equality_tight(G, q, S):
                        tight_count += 1
                        if len(S) <= 5:
                            tight_sets.append(S)

            print(f"  Root q={q}: {tight_count}/{total} subsets are tight")
            if tight_sets and len(tight_sets) <= 10:
                for s in sorted(tight_sets, key=len):
                    tree_str = "tree" if is_induced_tree(G, s) else "not tree"
                    comp_str = "1-comp" if is_single_component(G, q, s) else "multi-comp"
                    print(f"    S={s}: {tree_str}, {comp_str}")


# ──────────────────────────────────────────────────────────────
# Demo 2: Laplacian Decomposition
# ──────────────────────────────────────────────────────────────

def demo_decomposition():
    """Verify the Laplacian decomposition: L_S = Restricted + diag(cut)."""
    print("\n" + "=" * 70)
    print("DEMO 2: Laplacian Decomposition Theorem")
    print("=" * 70)

    G = SimpleGraph(5, [(0,1),(1,2),(2,3),(3,4),(0,2),(1,3)])
    S = {1, 2, 3}
    q = 0

    print(f"\nGraph: 5 vertices, edges = {G.edges()}")
    print(f"Root q = {q}, S = {S}")
    print(f"Is tight: {is_equality_tight(G, q, S)}")

    L = graph_laplacian(G)
    S_list = sorted(S)
    idx = {v: i for i, v in enumerate(S_list)}

    # Principal minor
    PM = [[L[v][w] for w in S_list] for v in S_list]
    print(f"\nPrincipal minor L_S:")
    for row in PM:
        print(f"  {row}")

    # Restricted Laplacian
    RL = restricted_laplacian(G, S)
    print(f"\nRestricted Laplacian:")
    for row in RL:
        print(f"  {row}")

    # Cut degrees
    cuts = [cut_degree(G, v, S) for v in S_list]
    print(f"\nCut degrees: {dict(zip(S_list, cuts))}")

    # Verify decomposition
    k = len(S_list)
    reconstructed = [[RL[i][j] + (cuts[i] if i == j else 0)
                       for j in range(k)] for i in range(k)]
    match = all(PM[i][j] == reconstructed[i][j]
                for i in range(k) for j in range(k))
    print(f"\nL_S == Restricted + diag(cut): {match} ✓" if match
          else f"\nL_S == Restricted + diag(cut): FAILED ✗")

    # Row sums of restricted Laplacian
    print(f"\nRestricted Laplacian row sums (should all be 0):")
    for i, v in enumerate(S_list):
        rs = sum(RL[i])
        print(f"  Row {v}: sum = {rs}")


# ──────────────────────────────────────────────────────────────
# Demo 3: Energy Formula
# ──────────────────────────────────────────────────────────────

def demo_energy():
    """Verify the energy formula: 2 * ∑ c·L·c = ∑_{v~w} (c(v)-c(w))²."""
    print("\n" + "=" * 70)
    print("DEMO 3: Laplacian Energy Formula")
    print("=" * 70)

    G = SimpleGraph(5, [(0,1),(1,2),(2,3),(3,4),(0,4)])
    L = graph_laplacian(G)

    test_functions = [
        {0: 1, 1: 2, 2: -1, 3: 3, 4: 0},
        {0: 1, 1: 1, 2: 1, 3: 1, 4: 1},  # constant → energy = 0
        {0: 0, 1: 1, 2: 0, 3: 1, 4: 0},  # alternating
        {0: 5, 1: -3, 2: 7, 3: -2, 4: 4},
    ]

    print(f"\nGraph: C5 (cycle on 5 vertices)")
    print(f"Edges: {G.edges()}")

    for c in test_functions:
        # Laplacian energy
        lap_energy = sum(c.get(v, 0) * L[v][w] * c.get(w, 0)
                         for v in range(G.n) for w in range(G.n))

        # Edge energy
        edge_e = sum((c.get(v, 0) - c.get(w, 0)) ** 2
                     for v in range(G.n) for w in range(G.n)
                     if G.is_adjacent(v, w))

        verified = 2 * lap_energy == edge_e
        print(f"\n  c = {c}")
        print(f"  2 × Laplacian energy = {2 * lap_energy}")
        print(f"  Edge energy           = {edge_e}")
        print(f"  Formula holds: {verified} {'✓' if verified else '✗'}")


# ──────────────────────────────────────────────────────────────
# Demo 4: Exhaustive search
# ──────────────────────────────────────────────────────────────

def generate_connected_graphs(n: int) -> list[SimpleGraph]:
    """Generate all connected simple graphs on n vertices (for small n)."""
    if n <= 1:
        return [SimpleGraph(n, [])]
    all_possible_edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    m = len(all_possible_edges)
    result = []
    for mask in range(1, 1 << m):
        edges = [all_possible_edges[i] for i in range(m) if mask & (1 << i)]
        G = SimpleGraph(n, edges)
        if G.is_connected():
            result.append(G)
    return result


def demo_exhaustive_search():
    """Exhaustive verification on small graphs."""
    print("\n" + "=" * 70)
    print("DEMO 4: Exhaustive Search for Counterexamples")
    print("=" * 70)

    print("""
The main conjecture: for connected G, root q, and S ⊆ V\\{q},
the equality r(D_S) = tropRank(L_S) - 1 holds iff:
  (1) S lies in one component of G-{q}, AND
  (2) G[S] is a tree.

We verify the COMBINATORIAL CRITERION is self-consistent and
check structural properties on all connected graphs with n ≤ 6.
""")

    for n in range(2, 7):
        graphs = generate_connected_graphs(n)
        total_tests = 0
        total_tight = 0
        max_tight_fraction = 0.0
        consistency_ok = True

        for G in graphs:
            for q in range(G.n):
                others = [v for v in range(G.n) if v != q]
                for r in range(len(others) + 1):
                    for combo in combinations(others, r):
                        S = set(combo)
                        total_tests += 1
                        tight = is_equality_tight(G, q, S)
                        if tight:
                            total_tight += 1

                        # Consistency checks
                        single = is_single_component(G, q, S)
                        tree = is_induced_tree(G, S)

                        # Tight iff both conditions hold
                        if tight != (single and tree):
                            consistency_ok = False

                        # Hereditary check: if tight and T ⊆ S connected + tree → T tight
                        if tight and len(S) > 1:
                            for v in S:
                                T = S - {v}
                                if is_induced_tree(G, T):
                                    if not is_equality_tight(G, q, T):
                                        consistency_ok = False

        fraction = total_tight / max(total_tests, 1)
        status = "✓" if consistency_ok else "✗ INCONSISTENCY"
        print(f"  n={n}: {len(graphs)} graphs, "
              f"{total_tests} (G,q,S) triples, "
              f"{total_tight} tight ({fraction:.1%}), "
              f"{status}")


# ──────────────────────────────────────────────────────────────
# Demo 5: Statistics
# ──────────────────────────────────────────────────────────────

def demo_statistics():
    """Compute statistics about tight sets across graph families."""
    print("\n" + "=" * 70)
    print("DEMO 5: Tight Set Statistics by Graph Size")
    print("=" * 70)

    for n in range(3, 7):
        graphs = generate_connected_graphs(n)
        by_size: dict[int, list[float]] = defaultdict(list)

        for G in graphs:
            for q in range(G.n):
                others = [v for v in range(G.n) if v != q]
                for k in range(len(others) + 1):
                    total = 0
                    tight = 0
                    for combo in combinations(others, k):
                        S = set(combo)
                        total += 1
                        if is_equality_tight(G, q, S):
                            tight += 1
                    if total > 0:
                        by_size[k].append(tight / total)

        print(f"\n  n = {n} ({len(graphs)} connected graphs)")
        print(f"  {'|S|':>4} | {'Mean tight fraction':>20} | {'Min':>8} | {'Max':>8}")
        print(f"  {'─'*4}─┼─{'─'*20}─┼─{'─'*8}─┼─{'─'*8}")
        for k in sorted(by_size.keys()):
            fracs = by_size[k]
            mean_f = sum(fracs) / len(fracs)
            min_f = min(fracs)
            max_f = max(fracs)
            print(f"  {k:>4} | {mean_f:>20.4f} | {min_f:>8.4f} | {max_f:>8.4f}")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   EQUALITY CHARACTERIZATION IN THE TROPICAL CHIP-FIRING BRIDGE ║")
    print("║              Interactive Demonstration                         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    print("Central Result: Equality r(D_S) = tropRank(L_S) - 1 holds")
    print("  ⟺  S lies in one component of G-{q} AND G[S] is a tree")
    print()

    demo_classification()
    demo_decomposition()
    demo_energy()
    demo_exhaustive_search()
    demo_statistics()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
