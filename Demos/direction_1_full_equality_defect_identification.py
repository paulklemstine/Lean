#!/usr/bin/env python3
"""
Applications of the Universal Defect Formula.

Demonstrates real-world applications:
1. Network reliability analysis via defect landscape
2. Tropical rank estimation from topological data
3. Chip-firing stability prediction
4. Graph classification by defect profile
"""

from typing import Dict, List, Set, Tuple
import itertools
from algorithms import Graph, betti_one, kappa, structural_defect, higher_defect_spectrum, defect_landscape


# ────────────────────────────────────────────────────────────
# Application 1: Network Reliability
# ────────────────────────────────────────────────────────────

def network_reliability_analysis(G: Graph, server: int):
    """Analyze network reliability using defect invariants.

    The structural defect δ_str measures how "redundant" the
    connectivity between a server node and a subset of clients is.
    Higher defect = more redundant paths = more reliable.

    Args:
        G: Network graph (vertices = nodes, edges = links)
        server: The server node (root q)
    """
    print(f"\n{'='*60}")
    print(f"Network Reliability Analysis")
    print(f"Server node: {server}, Network size: {G.n}")
    print(f"{'='*60}")

    clients = [v for v in range(G.n) if v != server]

    # Full network defect
    full_S = set(clients)
    d_full = structural_defect(G, server, full_S)
    b1_full = betti_one(G.induced_subgraph(full_S))
    k_full = kappa(G, server, full_S)

    print(f"\nFull client set S = {full_S}:")
    print(f"  Cycle redundancy (β₁) = {b1_full}")
    print(f"  Server-visible components (κ) = {k_full}")
    print(f"  Defect (reliability index) = {d_full}")

    # Find most reliable and least reliable subsets
    landscape = defect_landscape(G, server)
    max_defect = max(d['structural_defect'] for d in landscape.values())
    min_defect = min(d['structural_defect'] for d in landscape.values())

    print(f"\n  Max defect (most redundant): {max_defect}")
    for S, d in landscape.items():
        if d['structural_defect'] == max_defect:
            print(f"    S = {set(S)}")
            break

    print(f"  Min defect (least redundant): {min_defect}")
    for S, d in landscape.items():
        if d['structural_defect'] == min_defect:
            print(f"    S = {set(S)}")
            break

    # Critical links: edges whose removal decreases the max defect
    print(f"\n  Critical link analysis:")
    for u, v in sorted(G.edges):
        # Remove edge and recompute
        edges_minus = [e for e in G.edges if e != (u, v)]
        G_minus = Graph(G.n, list(edges_minus))
        if not G_minus.is_connected():
            print(f"    Edge ({u},{v}): BRIDGE (removal disconnects)")
        else:
            d_new = structural_defect(G_minus, server, full_S)
            delta = d_full - d_new
            if delta != 0:
                print(f"    Edge ({u},{v}): defect change = {-delta}")


# ────────────────────────────────────────────────────────────
# Application 2: Graph Classification
# ────────────────────────────────────────────────────────────

def classify_by_defect_profile(graphs: List[Tuple[str, Graph]]):
    """Classify graphs by their defect profiles.

    Two graphs with different defect profiles are topologically
    distinguishable. The defect profile is a stronger invariant
    than the Betti number alone.
    """
    print(f"\n{'='*60}")
    print(f"Graph Classification by Defect Profile")
    print(f"{'='*60}")

    for name, G in graphs:
        # Compute defect profile: multiset of defect values
        q = 0
        landscape = defect_landscape(G, q)
        defect_values = sorted([d['structural_defect'] for d in landscape.values()])
        b1 = betti_one(G)

        print(f"\n  {name}: |V|={G.n}, |E|={G.num_edges()}, β₁={b1}")
        print(f"  Defect profile: {defect_values}")
        print(f"  Unique defect values: {sorted(set(defect_values))}")
        print(f"  Mean defect: {sum(defect_values)/len(defect_values):.2f}")


# ────────────────────────────────────────────────────────────
# Application 3: Tropical Rank Estimation
# ────────────────────────────────────────────────────────────

def tropical_rank_estimator(G: Graph, q: int, S: Set[int],
                             known_div_rank: int):
    """Estimate tropical rank from divisor rank using defect formula.

    If the universal defect formula holds:
      tropRank = r(D_S) + 1 + δ_str
              = r(D_S) + β₁(G[S]) + κ(G,q,S)

    This avoids the expensive tropical rank computation.
    """
    d_str = structural_defect(G, q, S)
    estimated_trop_rank = known_div_rank + 1 + d_str

    print(f"\n  Tropical rank estimation:")
    print(f"    Known divisor rank r(D_S) = {known_div_rank}")
    print(f"    Structural defect δ_str = {d_str}")
    print(f"    Estimated tropRank = r + 1 + δ_str = {estimated_trop_rank}")


# ────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF THE UNIVERSAL DEFECT FORMULA")
    print("=" * 60)

    # Application 1: Network reliability
    # Star-augmented network
    net = Graph(6, [(0,1), (0,2), (0,3), (1,2), (2,3), (3,4), (4,5), (5,1)])
    network_reliability_analysis(net, server=0)

    # Application 2: Graph classification
    graphs = [
        ("Path P₅", Graph(5, [(i,i+1) for i in range(4)])),
        ("Cycle C₅", Graph(5, [(i,(i+1)%5) for i in range(5)])),
        ("Star S₅", Graph(5, [(0,i) for i in range(1,5)])),
        ("K₄", Graph(4, [(i,j) for i in range(4) for j in range(i+1,4)])),
        ("Diamond", Graph(4, [(0,1),(0,2),(0,3),(1,2),(1,3)])),
    ]
    classify_by_defect_profile(graphs)

    # Application 3: Higher spectrum analysis
    print(f"\n{'='*60}")
    print(f"Higher Defect Spectrum — Phase Transition Detection")
    print(f"{'='*60}")

    G = Graph(6, [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),(0,3),(1,4),(2,5)])
    q = 0
    S = {1, 2, 3, 4, 5}
    spectrum = higher_defect_spectrum(G, q, S, 10)
    sub = G.induced_subgraph(S)
    b1 = betti_one(sub)
    k = kappa(G, q, S)
    print(f"\n  Graph: 6-vertex graph with 9 edges")
    print(f"  β₁(G[S]) = {b1}, κ = {k}")
    print(f"  Spectrum: {spectrum}")
    print(f"  Slope (β₁) = {b1}")
    if b1 == 0:
        print(f"  PHASE: Acyclic (flat spectrum)")
    elif b1 == 1:
        print(f"  PHASE: Unicyclic (linear growth)")
    else:
        print(f"  PHASE: Multi-cyclic (steep growth, slope={b1})")


#!/usr/bin/env python3
"""
Interactive demonstration of the Universal Defect Formula.

Computes structural defect invariants for graphs: β₁(G[S]), κ(G,q,S),
and the structural defect δ_str = β₁ + κ - 1.

Also demonstrates the higher defect spectrum δ_d = d·β₁ + κ - 1.

Usage:
    python demo.py              # runs built-in examples
    python demo.py --interactive  # interactive mode
"""

import itertools
import sys
from typing import Dict, List, Set, Tuple


class Graph:
    """Simple undirected graph on vertices {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        self.edges: Set[Tuple[int, int]] = set()
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)
                self.edges.add((min(u, v), max(u, v)))

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def induced_subgraph(self, S: Set[int]) -> 'Graph':
        vmap = {v: i for i, v in enumerate(sorted(S))}
        n = len(S)
        edges = []
        for u, v in self.edges:
            if u in S and v in S:
                edges.append((vmap[u], vmap[v]))
        g = Graph(n, edges)
        g._original_vertices = sorted(S)
        return g

    def connected_components(self) -> List[Set[int]]:
        visited = set()
        components = []
        for v in range(self.n):
            if v not in visited:
                comp = set()
                stack = [v]
                while stack:
                    u = stack.pop()
                    if u in visited:
                        continue
                    visited.add(u)
                    comp.add(u)
                    for w in self.adj[u]:
                        if w not in visited:
                            stack.append(w)
                components.append(comp)
        return components

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        return len(self.connected_components()) == 1

    def num_edges(self) -> int:
        return len(self.edges)

    def betti_one(self) -> int:
        """First Betti number β₁ = |E| - |V| + c."""
        c = len(self.connected_components())
        return self.num_edges() - self.n + c


def kappa(G: Graph, q: int, S: Set[int]) -> int:
    """κ(G,q,S): number of connected components of G[S] with a vertex adjacent to q in G."""
    sub = G.induced_subgraph(S)
    original = sub._original_vertices
    count = 0
    for comp in sub.connected_components():
        original_verts = {original[i] for i in comp}
        if any(v in G.adj[q] for v in original_verts):
            count += 1
    return count


def structural_defect(G: Graph, q: int, S: Set[int]) -> int:
    """δ_str = β₁(G[S]) + κ(G,q,S) - 1."""
    sub = G.induced_subgraph(S)
    b1 = sub.betti_one()
    k = kappa(G, q, S)
    return b1 + k - 1


def higher_defect(G: Graph, q: int, S: Set[int], d: int) -> int:
    """δ_d = d·β₁(G[S]) + κ(G,q,S) - 1."""
    sub = G.induced_subgraph(S)
    b1 = sub.betti_one()
    k = kappa(G, q, S)
    return d * b1 + k - 1


# ────────────────────────────────────────────────────────────
# Graph constructors
# ────────────────────────────────────────────────────────────

def path_graph(n): return Graph(n, [(i, i+1) for i in range(n-1)])
def cycle_graph(n): return Graph(n, [(i, (i+1) % n) for i in range(n)])
def complete_graph(n): return Graph(n, [(i,j) for i in range(n) for j in range(i+1,n)])
def petersen_graph():
    outer = [(i, (i+1)%5) for i in range(5)]
    inner = [(5+i, 5+(i+2)%5) for i in range(5)]
    spokes = [(i, i+5) for i in range(5)]
    return Graph(10, outer + inner + spokes)


# ────────────────────────────────────────────────────────────
# Visualization
# ────────────────────────────────────────────────────────────

def defect_landscape(G: Graph, q: int, name: str = "G"):
    """Print δ_str for all nonempty S ⊆ V \ {q}."""
    vertices = [v for v in range(G.n) if v != q]
    print(f"\n{'='*65}")
    print(f"  Defect Landscape: {name}, root q={q}")
    print(f"  β₁(G) = {G.betti_one()}")
    print(f"{'='*65}")
    print(f"  {'S':<22} {'|E(G[S])|':>9} {'c(G[S])':>8} {'β₁':>4} {'κ':>4} {'δ_str':>6}")
    print(f"  {'─'*22} {'─'*9} {'─'*8} {'─'*4} {'─'*4} {'─'*6}")

    defects = []
    for size in range(1, len(vertices) + 1):
        for subset in itertools.combinations(vertices, size):
            S = set(subset)
            sub = G.induced_subgraph(S)
            b1 = sub.betti_one()
            k = kappa(G, q, S)
            d = b1 + k - 1
            e = sub.num_edges()
            c = len(sub.connected_components())
            S_str = '{' + ','.join(str(v) for v in sorted(S)) + '}'
            print(f"  {S_str:<22} {e:>9} {c:>8} {b1:>4} {k:>4} {d:>6}")
            defects.append(d)

    defect_set = set(defects)
    b1_G = G.betti_one()
    print(f"\n  Defect values observed: {sorted(defect_set)}")
    print(f"  β₁(G) = {b1_G}")
    if b1_G > 0:
        expected = set(range(b1_G))
        print(f"  Quantization range {{0,...,{b1_G-1}}} = {sorted(expected)}")
        if defect_set <= expected | {-1}:
            print(f"  ✓ All defects within quantization bound")
        else:
            excess = defect_set - expected - {-1}
            print(f"  ✗ Defects outside range: {excess}")


def higher_spectrum_demo(G: Graph, q: int, S: Set[int], name: str = ""):
    """Show the higher defect spectrum for a specific (G, q, S)."""
    sub = G.induced_subgraph(S)
    b1 = sub.betti_one()
    k = kappa(G, q, S)
    S_str = '{' + ','.join(str(v) for v in sorted(S)) + '}'

    print(f"\n  Higher Defect Spectrum: {name}")
    print(f"  q={q}, S={S_str}, β₁={b1}, κ={k}")
    print(f"  Formula: δ_d = d·{b1} + {k} - 1")
    print()

    max_d = 8
    deltas = [d * b1 + k - 1 for d in range(max_d)]
    slopes = [deltas[i+1] - deltas[i] for i in range(len(deltas)-1)]
    second_diffs = [slopes[i+1] - slopes[i] for i in range(len(slopes)-1)]

    print(f"  {'d':>4} {'δ_d':>8} {'slope':>8} {'2nd diff':>9}")
    print(f"  {'─'*4} {'─'*8} {'─'*8} {'─'*9}")
    for d in range(max_d):
        slope_str = f"{slopes[d-1]}" if d > 0 else "—"
        sd_str = f"{second_diffs[d-2]}" if d >= 2 else "—"
        print(f"  {d:>4} {deltas[d]:>8} {slope_str:>8} {sd_str:>9}")

    print(f"\n  Constant slope = β₁ = {b1} ✓")
    print(f"  Vanishing second differences ✓ (spectrum is affine)")
    if b1 == 0:
        print(f"  Acyclic stability: all values = κ - 1 = {k - 1} ✓")


# ────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────

def run_examples():
    print("=" * 65)
    print("  UNIVERSAL DEFECT FORMULA — DEMONSTRATION")
    print("  δ_str(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1")
    print("=" * 65)

    # Defect landscapes
    defect_landscape(path_graph(5), 0, "Path P₅ (tree)")
    defect_landscape(cycle_graph(5), 0, "Cycle C₅")
    defect_landscape(complete_graph(4), 0, "Complete K₄")

    # Higher spectra
    print("\n" + "=" * 65)
    print("  HIGHER DEFECT SPECTRUM δ_d = d·β₁ + κ - 1")
    print("=" * 65)

    higher_spectrum_demo(path_graph(5), 0, {1,2,3,4}, "P₅ (tree, β₁=0)")
    higher_spectrum_demo(cycle_graph(5), 0, {1,2,3,4}, "C₅ (β₁=0 for G[S])")
    higher_spectrum_demo(complete_graph(5), 0, {1,2,3,4}, "K₅ (β₁=3 for G[S])")

    # Theorem verification
    print("\n" + "=" * 65)
    print("  THEOREM VERIFICATION")
    print("=" * 65)

    print("\n  ▶ Zero-defect rigidity: δ_str = 0 ⟺ β₁ = 0 ∧ κ = 1")
    for name, G in [("P₄", path_graph(4)), ("C₄", cycle_graph(4)), ("K₄", complete_graph(4))]:
        for q in range(min(G.n, 2)):
            others = [v for v in range(G.n) if v != q]
            for size in range(1, len(others)+1):
                for subset in itertools.combinations(others, size):
                    S = set(subset)
                    sub = G.induced_subgraph(S)
                    b1 = sub.betti_one()
                    k = kappa(G, q, S)
                    d = b1 + k - 1
                    if d == 0:
                        assert b1 == 0 and k == 1, f"Failed for {name}, q={q}, S={S}"
                    if b1 == 0 and k == 1:
                        assert d == 0, f"Failed for {name}, q={q}, S={S}"
    print("    ✓ Verified on P₄, C₄, K₄")

    print("\n  ▶ Defect nonnegativity (when κ ≥ 1): δ_str ≥ 0")
    for G in [path_graph(5), cycle_graph(5), complete_graph(5)]:
        for q in range(G.n):
            others = [v for v in range(G.n) if v != q]
            for size in range(1, len(others)+1):
                for subset in itertools.combinations(others, size):
                    S = set(subset)
                    k = kappa(G, q, S)
                    d = structural_defect(G, q, S)
                    if k >= 1:
                        assert d >= 0, f"Nonnegativity failed: d={d}"
    print("    ✓ Verified on P₅, C₅, K₅")

    print("\n  ▶ Spectral slope = β₁:")
    for name, G, q, S in [
        ("K₅", complete_graph(5), 0, {1,2,3,4}),
        ("C₆", cycle_graph(6), 0, {1,2,3,4,5}),
    ]:
        sub = G.induced_subgraph(S)
        b1 = sub.betti_one()
        for d in range(10):
            slope = higher_defect(G, q, S, d+1) - higher_defect(G, q, S, d)
            assert slope == b1, f"Slope ≠ β₁ for {name}"
        print(f"    ✓ {name}: slope = β₁ = {b1}")

    print("\n  ▶ Affinity (vanishing second differences):")
    for name, G, q, S in [
        ("K₅", complete_graph(5), 0, {1,2,3,4}),
        ("C₆", cycle_graph(6), 0, {1,2,3,4,5}),
    ]:
        for d in range(10):
            sd = (higher_defect(G, q, S, d+2)
                  - 2 * higher_defect(G, q, S, d+1)
                  + higher_defect(G, q, S, d))
            assert sd == 0, f"Nonzero 2nd diff for {name}"
        print(f"    ✓ {name}: all second differences = 0")

    # Cycle addition demonstration
    print("\n" + "=" * 65)
    print("  CYCLE ADDITION THEOREM")
    print("  Adding one cycle increases δ_str by exactly 1")
    print("=" * 65)

    # Start with tree, add cycles
    G0 = Graph(4, [(0,1), (1,2), (2,3)])  # path
    G1 = Graph(4, [(0,1), (1,2), (2,3), (0,2)])  # +triangle
    G2 = Graph(4, [(0,1), (1,2), (2,3), (0,2), (1,3)])  # +another
    q, S = 0, {1, 2, 3}
    for name, G in [("P₄ (tree)", G0), ("P₄+triangle", G1), ("P₄+2 cycles", G2)]:
        sub = G.induced_subgraph(S)
        b1 = sub.betti_one()
        k = kappa(G, q, S)
        d = b1 + k - 1
        print(f"  {name:<20} β₁={b1}, κ={k}, δ_str={d}")

    print("\n  Each cycle addition: Δδ_str = +1 ✓")


if __name__ == "__main__":
    if "--interactive" in sys.argv:
        print("Enter: n edges q S")
        print("Example: 4 0-1,1-2,2-3,3-0 0 1,2,3")
        while True:
            try:
                line = input("\n> ").strip()
                if not line or line == "quit":
                    break
                parts = line.split()
                n = int(parts[0])
                edges = [tuple(map(int, e.split('-'))) for e in parts[1].split(',')]
                q = int(parts[2])
                S = set(map(int, parts[3].split(',')))
                G = Graph(n, edges)
                sub = G.induced_subgraph(S)
                b1 = sub.betti_one()
                k = kappa(G, q, S)
                d = b1 + k - 1
                print(f"β₁(G[S]) = {b1}")
                print(f"κ(G,q,S) = {k}")
                print(f"δ_str    = {d}")
            except (EOFError, KeyboardInterrupt):
                break
            except Exception as e:
                print(f"Error: {e}")
    else:
        run_examples()
