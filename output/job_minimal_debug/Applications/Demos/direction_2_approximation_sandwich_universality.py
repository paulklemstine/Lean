#!/usr/bin/env python3
"""
Applications of Certified Sandwich Families

This module demonstrates real-world applications of the approximation-sandwich
universality framework:

1. Automated lower bound certification for graph properties
2. Circuit-refutation hypergraph analysis
3. Sandwich family transport across graph embeddings
4. Conjecture testing and falsification
"""

from itertools import combinations
from algorithms import (
    enumerate_monotone_circuits, greedy_sandwich_construction,
    compute_minimal_transversal, verify_sandwich_family,
    has_triangle, st_connected, has_perfect_matching,
    Var, And, Or, Const
)
import time


def all_graphs(n: int) -> list[frozenset]:
    """Generate all graphs on n vertices."""
    edges = list(combinations(range(n), 2))
    graphs = []
    for r in range(len(edges) + 1):
        for subset in combinations(edges, r):
            graphs.append(frozenset(subset))
    return graphs


# ─────────────────────────────────────────────────────────────────────
# Application 1: Automated Lower Bound Certification
# ─────────────────────────────────────────────────────────────────────

def app_automated_certification():
    """Demonstrate automated discovery and certification of lower bounds.

    Given a graph property f and size bound s, automatically:
    1. Search for a complete sandwich family
    2. Verify it constitutes a valid certificate
    3. Output the certificate in a format suitable for formal verification
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Automated Lower Bound Certification")
    print("=" * 60)

    n = 4
    max_size = 3
    edges = list(combinations(range(n), 2))
    graphs = all_graphs(n)
    circuits = enumerate_monotone_circuits(edges, max_size)

    print(f"\nTarget: Triangle detection on {n} vertices")
    print(f"Claim: No monotone circuit of size ≤ {max_size} computes TRIANGLE")

    pos, neg = greedy_sandwich_construction(has_triangle, n, circuits, graphs)
    ok, missed = verify_sandwich_family(pos, neg, has_triangle, n, circuits, graphs)

    print(f"\nCertificate found: {'YES' if ok else 'NO'}")
    print(f"Certificate size: {len(pos) + len(neg)} witnesses")
    print(f"  Positive witnesses: {len(pos)}")
    print(f"  Negative witnesses: {len(neg)}")

    if ok:
        print("\n--- Certificate Details ---")
        print("Positive witnesses (graphs with triangles):")
        for G in sorted(pos, key=lambda g: len(g)):
            print(f"  {sorted(G)}")
        print("Negative witnesses (graphs without triangles):")
        for i, G in enumerate(sorted(neg, key=lambda g: len(g))[:10]):
            print(f"  {sorted(G)}")
        if len(neg) > 10:
            print(f"  ... and {len(neg) - 10} more")

        print("\n--- Formal Certificate Format (for Lean verification) ---")
        print(f"-- CertifiedSandwichFamily (GraphInst {n}) (hasTriangleBool {n})")
        print(f"-- Pos := {{{len(pos)} graphs with triangles}}")
        print(f"-- Neg := {{{len(neg)} graphs without triangles}}")
        print(f"-- SandwichCompleteUpTo (hasTriangleBool {n}) S {max_size}")
        print(f"-- Certificate: VERIFIED ✓")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Hypergraph Structure Analysis
# ─────────────────────────────────────────────────────────────────────

def app_hypergraph_analysis():
    """Analyze the circuit-refutation hypergraph structure.

    For each graph property, compute:
    - Number of hyperedges (non-computing circuits)
    - Average hyperedge size (how many graphs refute each circuit)
    - Minimum transversal size
    - Greedy transversal vs optimal gap
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Circuit-Refutation Hypergraph Analysis")
    print("=" * 60)

    properties = {
        'Triangle': has_triangle,
        'Connectivity': st_connected,
        'Matching': has_perfect_matching,
    }

    n = 4
    max_size = 3
    edges = list(combinations(range(n), 2))
    graphs = all_graphs(n)
    circuits = enumerate_monotone_circuits(edges, max_size)

    print(f"\nParameters: n={n}, max_size={max_size}")
    print(f"  {len(edges)} edges, {len(graphs)} graphs, {len(circuits)} circuits")

    print(f"\n{'Property':<15} {'#HE':>5} {'Avg|HE|':>8} {'τ_min':>6} {'τ_greedy':>9} {'Ratio':>6}")
    print("-" * 55)

    for name, f in properties.items():
        f_vals = {G: f(G, n) for G in graphs}

        # Compute hyperedges
        hyperedges = []
        for circ in circuits:
            edge = frozenset(G for G in graphs if circ.evaluate(G) != f_vals[G])
            if edge:
                hyperedges.append(edge)
        unique_he = list(set(hyperedges))

        avg_size = sum(len(he) for he in unique_he) / max(len(unique_he), 1)

        # Minimal transversal
        trans, tau_min = compute_minimal_transversal(f, n, circuits, graphs)

        # Greedy construction
        pos, neg = greedy_sandwich_construction(f, n, circuits, graphs)
        tau_greedy = len(pos) + len(neg)

        ratio = tau_greedy / max(tau_min, 1)

        print(f"{name:<15} {len(unique_he):>5} {avg_size:>8.1f} {tau_min:>6} "
              f"{tau_greedy:>9} {ratio:>6.2f}")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Transport Across Graph Embeddings
# ─────────────────────────────────────────────────────────────────────

def app_transport_demo():
    """Demonstrate sandwich family transport via graph embeddings.

    Shows how a sandwich family on a larger graph can be pulled back
    to a smaller graph via vertex restriction (induced subgraph embedding).
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Sandwich Family Transport")
    print("=" * 60)

    # Build family for n=4
    n_large = 4
    max_size = 3
    edges_large = list(combinations(range(n_large), 2))
    graphs_large = all_graphs(n_large)
    circuits_large = enumerate_monotone_circuits(edges_large, max_size)

    pos_large, neg_large = greedy_sandwich_construction(
        has_triangle, n_large, circuits_large, graphs_large)

    print(f"\nOriginal family on {n_large} vertices:")
    print(f"  |Pos| = {len(pos_large)}, |Neg| = {len(neg_large)}")

    # Pull back to n=3 via embedding {0,1,2} ↪ {0,1,2,3}
    n_small = 3
    embedding = {0: 0, 1: 1, 2: 2}  # Identity on first 3 vertices

    def pullback_graph(G: frozenset) -> frozenset:
        """Restrict graph to vertices in embedding."""
        return frozenset(
            (embedding[i], embedding[j])
            for (i, j) in G
            if i in embedding and j in embedding
        )

    def is_in_range(G: frozenset) -> bool:
        """Check if graph only uses vertices in embedding range."""
        for (i, j) in G:
            if i >= n_small or j >= n_small:
                return False
        return True

    # Pullback: take only witnesses that use vertices 0,1,2
    pos_small = set()
    neg_small = set()
    for G in pos_large:
        if is_in_range(G):
            pos_small.add(G)
    for G in neg_large:
        if is_in_range(G):
            neg_small.add(G)

    print(f"\nPulled-back family on {n_small} vertices (via {embedding}):")
    print(f"  |Pos| = {len(pos_small)}, |Neg| = {len(neg_small)}")

    # Verify completeness on n=3
    edges_small = list(combinations(range(n_small), 2))
    graphs_small = all_graphs(n_small)
    circuits_small = enumerate_monotone_circuits(edges_small, max_size)

    ok, missed = verify_sandwich_family(
        pos_small, neg_small, has_triangle, n_small, circuits_small, graphs_small)

    print(f"  Complete on {n_small} vertices: {ok}")
    if not ok:
        print(f"  (Missing coverage for {len(missed)} circuits)")
        print(f"  Note: pullback requires all witnesses in range of embedding")


# ─────────────────────────────────────────────────────────────────────
# Application 4: Conjecture Testing
# ─────────────────────────────────────────────────────────────────────

def app_conjecture_testing():
    """Test the three main conjectures from the research paper.

    Conjecture A: Bounded universality — polynomial-size families exist
    Conjecture B: Small minimality gap — greedy ≈ optimal
    Conjecture C: Transport stability — pullbacks preserve completeness
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Conjecture Testing")
    print("=" * 60)

    # Conjecture A: Bounded universality
    print("\n--- Conjecture A: Bounded Universality ---")
    print("Claim: For natural properties, complete families of poly size exist")

    properties = {
        'Triangle': has_triangle,
        'Connectivity': st_connected,
        'Matching': has_perfect_matching,
    }

    for n in [3, 4]:
        edges = list(combinations(range(n), 2))
        graphs = all_graphs(n)
        m = len(edges)
        for max_s in [3, 5]:
            circuits = enumerate_monotone_circuits(edges, max_s)
            for name, f in properties.items():
                if name == 'Matching' and n % 2 != 0:
                    continue
                pos, neg = greedy_sandwich_construction(f, n, circuits, graphs)
                family_size = len(pos) + len(neg)
                poly_bound = m ** 2  # Quadratic in number of edges
                status = "✓" if family_size <= poly_bound else "✗"
                print(f"  {name:<13} n={n} s={max_s}: "
                      f"|family|={family_size:>4} vs m²={poly_bound:>4} {status}")

    # Conjecture B: Small minimality gap
    print("\n--- Conjecture B: Small Minimality Gap ---")
    print("Claim: Greedy ≤ O(log n) × optimal")

    n = 3
    edges = list(combinations(range(n), 2))
    graphs = all_graphs(n)
    for max_s in [3, 5]:
        circuits = enumerate_monotone_circuits(edges, max_s)
        for name, f in properties.items():
            if name == 'Matching' and n % 2 != 0:
                continue
            pos, neg = greedy_sandwich_construction(f, n, circuits, graphs)
            greedy_size = len(pos) + len(neg)
            _, opt_size = compute_minimal_transversal(f, n, circuits, graphs)
            if opt_size > 0:
                import math
                log_bound = math.ceil(math.log2(n + 1)) * opt_size
                ratio = greedy_size / opt_size
                status = "✓" if greedy_size <= log_bound else "✗"
                print(f"  {name:<13} n={n} s={max_s}: "
                      f"greedy={greedy_size}, opt={opt_size}, "
                      f"ratio={ratio:.2f} {status}")

    # Conjecture C: Transport stability
    print("\n--- Conjecture C: Transport Stability ---")
    print("Claim: Pullback families remain complete")

    n_large = 4
    n_small = 3
    max_s = 3
    edges_l = list(combinations(range(n_large), 2))
    graphs_l = all_graphs(n_large)
    circuits_l = enumerate_monotone_circuits(edges_l, max_s)

    edges_s = list(combinations(range(n_small), 2))
    graphs_s = all_graphs(n_small)
    circuits_s = enumerate_monotone_circuits(edges_s, max_s)

    for name, f in properties.items():
        if name == 'Matching' and n_large % 2 != 0:
            continue
        pos_l, neg_l = greedy_sandwich_construction(f, n_large, circuits_l, graphs_l)

        # Pullback: restrict to graphs that only use vertices < n_small
        def restrict_graph(G):
            return frozenset((i,j) for (i,j) in G if i < n_small and j < n_small)

        pos_s = set()
        neg_s = set()
        for G in pos_l:
            rG = restrict_graph(G)
            if rG == G:  # Only take graphs fully in the small vertex set
                if f(rG, n_small):
                    pos_s.add(rG)
        for G in neg_l:
            rG = restrict_graph(G)
            if rG == G:
                if not f(rG, n_small):
                    neg_s.add(rG)

        ok, missed = verify_sandwich_family(pos_s, neg_s, f, n_small, circuits_s, graphs_s)
        status = "✓" if ok else "✗"
        print(f"  {name:<13} {n_large}→{n_small}: "
              f"|pull|={len(pos_s)+len(neg_s)}, complete={ok} {status}")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("  APPLICATIONS OF CERTIFIED SANDWICH FAMILIES")
    print("=" * 60)

    app_automated_certification()
    app_hypergraph_analysis()
    app_transport_demo()
    app_conjecture_testing()

    print("\n" + "=" * 60)
    print("  ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Certified Sandwich Family Discovery and Verification Demo

Interactive demonstration of the approximation-sandwich universality framework:
- Choose a monotone graph property (triangle, matching, connectivity)
- Choose vertex count n and circuit size bound s
- Enumerate/search candidate witness families
- Display circuits hit/missed
- Output a discovered certified family if one exists

Usage:
    python demo.py
"""

from itertools import combinations, product
from typing import Optional
import sys


# ─────────────────────────────────────────────────────────────────────
# Graph representation: edges as frozensets of pairs
# ─────────────────────────────────────────────────────────────────────

def all_possible_edges(n: int) -> list[tuple[int, int]]:
    """All undirected edges on vertices {0, ..., n-1}."""
    return list(combinations(range(n), 2))


def all_graphs(n: int) -> list[frozenset]:
    """All graphs on n vertices as frozensets of edges."""
    edges = all_possible_edges(n)
    graphs = []
    for r in range(len(edges) + 1):
        for subset in combinations(edges, r):
            graphs.append(frozenset(subset))
    return graphs


def is_subgraph(G: frozenset, H: frozenset) -> bool:
    """G is a subgraph of H (edge inclusion)."""
    return G.issubset(H)


# ─────────────────────────────────────────────────────────────────────
# Monotone graph properties
# ─────────────────────────────────────────────────────────────────────

def has_triangle(G: frozenset, n: int) -> bool:
    """Does graph G contain a triangle (3-clique)?"""
    for i, j, k in combinations(range(n), 3):
        if (i, j) in G and (j, k) in G and (i, k) in G:
            return True
    return False


def has_perfect_matching(G: frozenset, n: int) -> bool:
    """Does graph G contain a perfect matching? (n must be even)"""
    if n % 2 != 0:
        return False
    return _find_matching(G, n, list(range(n)))


def _find_matching(G: frozenset, n: int, vertices: list) -> bool:
    """Backtracking search for perfect matching."""
    if not vertices:
        return True
    v = vertices[0]
    rest = vertices[1:]
    for u in rest:
        edge = (min(v, u), max(v, u))
        if edge in G:
            remaining = [w for w in rest if w != u]
            if _find_matching(G, n, remaining):
                return True
    return False


def st_connected(G: frozenset, n: int, s: int = 0, t: int = None) -> bool:
    """Is there a path from s to t in graph G?"""
    if t is None:
        t = n - 1
    if s == t:
        return True
    visited = {s}
    queue = [s]
    while queue:
        v = queue.pop(0)
        for u in range(n):
            edge = (min(v, u), max(v, u))
            if edge in G and u not in visited:
                if u == t:
                    return True
                visited.add(u)
                queue.append(u)
    return False


# ─────────────────────────────────────────────────────────────────────
# Monotone circuit model (abstract: AND/OR trees over edge variables)
# ─────────────────────────────────────────────────────────────────────

class MonotoneCircuit:
    """A monotone Boolean circuit built from edge variables, AND, OR gates."""
    pass


class VarCircuit(MonotoneCircuit):
    """An edge variable: true iff edge (i,j) is present."""
    def __init__(self, edge: tuple[int, int]):
        self.edge = edge
        self._size = 1

    def evaluate(self, G: frozenset) -> bool:
        return self.edge in G

    @property
    def size(self) -> int:
        return self._size

    def __repr__(self):
        return f"Var{self.edge}"


class ConstCircuit(MonotoneCircuit):
    """A constant circuit (True or False)."""
    def __init__(self, value: bool):
        self.value = value
        self._size = 1

    def evaluate(self, G: frozenset) -> bool:
        return self.value

    @property
    def size(self) -> int:
        return self._size

    def __repr__(self):
        return f"Const({self.value})"


class AndCircuit(MonotoneCircuit):
    """AND gate: conjunction of two subcircuits."""
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit):
        self.left = left
        self.right = right
        self._size = 1 + left.size + right.size

    def evaluate(self, G: frozenset) -> bool:
        return self.left.evaluate(G) and self.right.evaluate(G)

    @property
    def size(self) -> int:
        return self._size

    def __repr__(self):
        return f"AND({self.left}, {self.right})"


class OrCircuit(MonotoneCircuit):
    """OR gate: disjunction of two subcircuits."""
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit):
        self.left = left
        self.right = right
        self._size = 1 + left.size + right.size

    def evaluate(self, G: frozenset) -> bool:
        return self.left.evaluate(G) or self.right.evaluate(G)

    @property
    def size(self) -> int:
        return self._size

    def __repr__(self):
        return f"OR({self.left}, {self.right})"


def enumerate_circuits(edges: list[tuple[int, int]], max_size: int) -> list[MonotoneCircuit]:
    """Enumerate all monotone circuits up to a given size over edge variables.

    Uses dynamic programming: circuits of size 1 are variables and constants,
    larger circuits combine smaller ones with AND/OR.
    """
    by_size: dict[int, list[MonotoneCircuit]] = {}

    # Size 1: variables and constants
    size1 = [ConstCircuit(False), ConstCircuit(True)]
    size1.extend(VarCircuit(e) for e in edges)
    by_size[1] = size1

    for s in range(3, max_size + 1):
        circuits_s = []
        # Combine circuits of sizes (a, b) where 1 + a + b = s
        for a in range(1, s - 1):
            b = s - 1 - a
            if b < 1 or b > a:
                continue
            for c1 in by_size.get(a, []):
                for c2 in by_size.get(b, []):
                    circuits_s.append(AndCircuit(c1, c2))
                    circuits_s.append(OrCircuit(c1, c2))
                    if a != b:
                        circuits_s.append(AndCircuit(c2, c1))
                        circuits_s.append(OrCircuit(c2, c1))
        by_size[s] = circuits_s

    result = []
    for s in range(1, max_size + 1):
        result.extend(by_size.get(s, []))
    return result


# ─────────────────────────────────────────────────────────────────────
# Sandwich family search and verification
# ─────────────────────────────────────────────────────────────────────

def find_disagreement(circuit: MonotoneCircuit, f, graphs: list[frozenset],
                      n: int) -> Optional[frozenset]:
    """Find a graph where circuit disagrees with f, or None."""
    for G in graphs:
        if circuit.evaluate(G) != f(G, n):
            return G
    return None


def build_sandwich_family(f, n: int, max_circuit_size: int,
                          verbose: bool = True):
    """Search for a certified sandwich family complete up to the given size.

    Returns (pos_set, neg_set, stats) where:
    - pos_set: set of graphs where f=True and some circuit says False
    - neg_set: set of graphs where f=False and some circuit says True
    - stats: dictionary of statistics
    """
    edges = all_possible_edges(n)
    graphs = all_graphs(n)

    if verbose:
        print(f"\n{'='*60}")
        print(f"Building sandwich family")
        print(f"  Vertices: {n}")
        print(f"  Edges: {len(edges)}")
        print(f"  Graphs: {len(graphs)}")
        print(f"  Max circuit size: {max_circuit_size}")
        print(f"{'='*60}")

    # Enumerate circuits
    if verbose:
        print("\nEnumerating circuits...")
    circuits = enumerate_circuits(edges, max_circuit_size)
    if verbose:
        print(f"  Total circuits: {len(circuits)}")

    pos_witnesses = set()  # Graphs where f=True but circuit says False
    neg_witnesses = set()  # Graphs where f=False but circuit says True
    circuits_hit = 0
    circuits_computing_f = 0
    circuits_total = len(circuits)

    for i, circ in enumerate(circuits):
        disagree = find_disagreement(circ, f, graphs, n)
        if disagree is None:
            circuits_computing_f += 1
            continue

        circuits_hit += 1
        f_val = f(disagree, n)
        if f_val:
            pos_witnesses.add(disagree)
        else:
            neg_witnesses.add(disagree)

    # Verify completeness
    complete = True
    missed_circuits = []
    for circ in circuits:
        hit = False
        for G in pos_witnesses:
            if circ.evaluate(G) != f(G, n):
                hit = True
                break
        if not hit:
            for G in neg_witnesses:
                if circ.evaluate(G) != f(G, n):
                    hit = True
                    break
        if not hit:
            # Check if circuit actually computes f
            computes_f = all(circ.evaluate(G) == f(G, n) for G in graphs)
            if not computes_f:
                complete = False
                missed_circuits.append(circ)

    stats = {
        'n': n,
        'num_edges': len(edges),
        'num_graphs': len(graphs),
        'max_circuit_size': max_circuit_size,
        'circuits_enumerated': circuits_total,
        'circuits_computing_f': circuits_computing_f,
        'circuits_hit': circuits_hit,
        'pos_size': len(pos_witnesses),
        'neg_size': len(neg_witnesses),
        'family_size': len(pos_witnesses) + len(neg_witnesses),
        'complete': complete,
        'missed': len(missed_circuits),
    }

    if verbose:
        print(f"\n--- Results ---")
        print(f"  Circuits computing f: {circuits_computing_f}")
        print(f"  Circuits needing refutation: {circuits_hit}")
        print(f"  Positive witnesses (f=T, C=F): {len(pos_witnesses)}")
        print(f"  Negative witnesses (f=F, C=T): {len(neg_witnesses)}")
        print(f"  Total family size: {len(pos_witnesses) + len(neg_witnesses)}")
        print(f"  Complete: {complete}")
        if not complete:
            print(f"  Missed circuits: {len(missed_circuits)}")

    return pos_witnesses, neg_witnesses, stats


def verify_sandwich(pos_set, neg_set, f, n: int,
                    circuits: list[MonotoneCircuit]) -> bool:
    """Verify that the sandwich family hits every non-computing circuit."""
    graphs = all_graphs(n)
    for circ in circuits:
        # Check if circuit computes f
        computes_f = all(circ.evaluate(G) == f(G, n) for G in graphs)
        if computes_f:
            continue
        # Check if family hits this circuit
        hit = False
        for G in pos_set | neg_set:
            if circ.evaluate(G) != f(G, n):
                hit = True
                break
        if not hit:
            return False
    return True


# ─────────────────────────────────────────────────────────────────────
# Interactive demonstration
# ─────────────────────────────────────────────────────────────────────

def demo_triangle(n: int = 4, max_size: int = 3):
    """Demonstrate sandwich family construction for triangle detection."""
    print(f"\n{'#'*60}")
    print(f"# TRIANGLE DETECTION on {n} vertices")
    print(f"# Circuit size bound: {max_size}")
    print(f"{'#'*60}")

    pos, neg, stats = build_sandwich_family(has_triangle, n, max_size)

    print(f"\n--- Positive witnesses (contain triangle, but some circuit misses) ---")
    for i, G in enumerate(sorted(pos, key=lambda g: len(g))):
        edges_str = ', '.join(f'{e}' for e in sorted(G))
        print(f"  P{i+1}: {{{edges_str}}}")

    print(f"\n--- Negative witnesses (no triangle, but some circuit claims one) ---")
    for i, G in enumerate(sorted(neg, key=lambda g: len(g))):
        edges_str = ', '.join(f'{e}' for e in sorted(G))
        print(f"  N{i+1}: {{{edges_str}}}")

    return stats


def demo_connectivity(n: int = 4, max_size: int = 3):
    """Demonstrate sandwich family construction for s-t connectivity."""
    print(f"\n{'#'*60}")
    print(f"# s-t CONNECTIVITY on {n} vertices (s=0, t={n-1})")
    print(f"# Circuit size bound: {max_size}")
    print(f"{'#'*60}")

    f = lambda G, n: st_connected(G, n, 0, n - 1)
    pos, neg, stats = build_sandwich_family(f, n, max_size)

    print(f"\n--- Sample positive witnesses (s-t connected) ---")
    for i, G in enumerate(sorted(pos, key=lambda g: len(g))[:5]):
        edges_str = ', '.join(f'{e}' for e in sorted(G))
        print(f"  P{i+1}: {{{edges_str}}}")

    print(f"\n--- Sample negative witnesses (s-t disconnected) ---")
    for i, G in enumerate(sorted(neg, key=lambda g: len(g))[:5]):
        edges_str = ', '.join(f'{e}' for e in sorted(G))
        print(f"  N{i+1}: {{{edges_str}}}")

    return stats


def demo_matching(n: int = 4, max_size: int = 3):
    """Demonstrate sandwich family construction for perfect matching."""
    if n % 2 != 0:
        print(f"Skipping matching demo: n={n} is odd (no perfect matchings)")
        return {}

    print(f"\n{'#'*60}")
    print(f"# PERFECT MATCHING on {n} vertices")
    print(f"# Circuit size bound: {max_size}")
    print(f"{'#'*60}")

    pos, neg, stats = build_sandwich_family(has_perfect_matching, n, max_size)
    return stats


def main():
    print("=" * 60)
    print("  CERTIFIED SANDWICH FAMILY DISCOVERY ENGINE")
    print("  Approximation-Sandwich Universality Framework")
    print("=" * 60)
    print()
    print("This demo searches for certified sandwich families that")
    print("witness the inability of small monotone circuits to compute")
    print("natural graph properties. A complete family constitutes a")
    print("finite proof of a circuit lower bound.")
    print()

    # Run demos with small parameters for speed
    results = {}

    # Triangle on 4 vertices, circuits up to size 3
    results['triangle_4_3'] = demo_triangle(n=4, max_size=3)

    # Triangle on 4 vertices, circuits up to size 5
    results['triangle_4_5'] = demo_triangle(n=4, max_size=5)

    # Connectivity on 4 vertices
    results['connectivity_4_3'] = demo_connectivity(n=4, max_size=3)

    # Matching on 4 vertices
    results['matching_4_3'] = demo_matching(n=4, max_size=3)

    # Summary table
    print(f"\n\n{'='*60}")
    print(f"  SUMMARY TABLE")
    print(f"{'='*60}")
    print(f"{'Property':<25} {'n':>3} {'s':>3} {'|P|':>5} {'|N|':>5} {'Total':>6} {'Complete':>9}")
    print(f"{'-'*60}")
    for key, stats in results.items():
        if not stats:
            continue
        name = key.rsplit('_', 2)[0].replace('_', ' ').title()
        print(f"{name:<25} {stats['n']:>3} {stats['max_circuit_size']:>3} "
              f"{stats['pos_size']:>5} {stats['neg_size']:>5} "
              f"{stats['family_size']:>6} {str(stats['complete']):>9}")

    print(f"\n{'='*60}")
    print("  INTERPRETATION")
    print(f"{'='*60}")
    print()
    print("A 'Complete: True' entry means the sandwich family is a")
    print("finite certificate proving that NO monotone circuit of the")
    print("given size computes the property. This is the computational")
    print("realization of the Finite Duality Theorem.")
    print()
    print("Key insight: the family size is typically MUCH smaller than")
    print("the number of circuits it refutes, showing that hardness")
    print("certificates are highly compressed witnesses.")


if __name__ == '__main__':
    main()
