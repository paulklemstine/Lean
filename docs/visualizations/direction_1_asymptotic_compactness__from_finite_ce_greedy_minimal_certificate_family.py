"""
Algorithms for Monotone Circuit Lower Bound Certificate Search

This module implements the core algorithms for constructing and analyzing
certified sandwich families — the combinatorial objects that witness
monotone circuit lower bounds.

Key algorithms:
1. Sandwich family enumeration for small graph properties
2. Completeness testing against monotone circuits
3. Certificate minimization (finding minimal complete families)
4. Polynomial growth estimation
"""

from itertools import combinations, product
from typing import List, Tuple, Dict, Set, Optional, Callable
from dataclasses import dataclass
import math


@dataclass
class Graph:
    """A simple undirected graph on n vertices, represented as an edge set."""
    n: int
    edges: frozenset  # frozenset of (i, j) pairs with i < j

    @staticmethod
    def from_adj(n: int, adj: List[Tuple[int, int]]) -> 'Graph':
        edges = frozenset((min(i, j), max(i, j)) for i, j in adj if i != j)
        return Graph(n=n, edges=edges)

    def has_edge(self, i: int, j: int) -> bool:
        return (min(i, j), max(i, j)) in self.edges

    def is_subgraph_of(self, other: 'Graph') -> bool:
        return self.n == other.n and self.edges.issubset(other.edges)

    def __hash__(self):
        return hash((self.n, self.edges))

    def __eq__(self, other):
        return self.n == other.n and self.edges == other.edges


def has_triangle(G: Graph) -> bool:
    """Check if graph G contains a triangle (3-clique).

    Time complexity: O(n^3) brute force.

    >>> G = Graph.from_adj(4, [(0,1), (1,2), (0,2)])
    >>> has_triangle(G)
    True
    >>> G2 = Graph.from_adj(4, [(0,1), (1,2)])
    >>> has_triangle(G2)
    False
    """
    for i in range(G.n):
        for j in range(i + 1, G.n):
            for k in range(j + 1, G.n):
                if G.has_edge(i, j) and G.has_edge(j, k) and G.has_edge(i, k):
                    return True
    return False


def has_clique(G: Graph, k: int) -> bool:
    """Check if graph G contains a k-clique.

    Time complexity: O(n^k).

    >>> G = Graph.from_adj(4, [(0,1), (1,2), (0,2), (2,3), (0,3), (1,3)])
    >>> has_clique(G, 4)
    True
    """
    for subset in combinations(range(G.n), k):
        if all(G.has_edge(subset[a], subset[b])
               for a in range(k) for b in range(a + 1, k)):
            return True
    return False


@dataclass
class MonotoneCircuit:
    """A monotone Boolean circuit on graph edge-sets.

    Represented as a truth table for simplicity at small sizes.
    eval_fn maps a frozenset of edges to True/False.
    """
    size: int
    eval_fn: Callable[[frozenset], bool]

    def eval(self, G: Graph) -> bool:
        return self.eval_fn(G.edges)


@dataclass
class CertifiedSandwichFamily:
    """A certified sandwich family for a monotone graph property.

    pos: set of positive witnesses (graphs where property holds)
    neg: set of negative witnesses (graphs where property fails)
    """
    pos: List[Graph]
    neg: List[Graph]
    property_fn: Callable[[Graph], bool]

    def family_size(self) -> int:
        """Total number of witnesses."""
        return len(self.pos) + len(self.neg)

    def hits_circuit(self, circuit: MonotoneCircuit) -> bool:
        """Check if this family hits (refutes) a given circuit."""
        for g in self.pos:
            if not circuit.eval(g) and self.property_fn(g):
                return True
        for g in self.neg:
            if circuit.eval(g) and not self.property_fn(g):
                return True
        return False

    def is_valid(self) -> bool:
        """Verify that positive/negative witnesses are correctly classified."""
        return (all(self.property_fn(g) for g in self.pos) and
                all(not self.property_fn(g) for g in self.neg))


def enumerate_all_graphs(n: int) -> List[Graph]:
    """Enumerate all simple undirected graphs on n vertices.

    Returns 2^(n choose 2) graphs.

    >>> len(enumerate_all_graphs(3))
    8
    >>> len(enumerate_all_graphs(4))
    64
    """
    possible_edges = list(combinations(range(n), 2))
    graphs = []
    for r in range(len(possible_edges) + 1):
        for edge_subset in combinations(possible_edges, r):
            g = Graph(n=n, edges=frozenset(edge_subset))
            graphs.append(g)
    return graphs


def build_universal_sandwich(n: int, prop_fn: Callable[[Graph], bool]) -> CertifiedSandwichFamily:
    """Build the universal (maximal) sandwich family: all true-inputs as Pos,
    all false-inputs as Neg.

    This is always valid and complete against all circuits that don't compute
    the property. It's the construction used in the finite duality theorem.

    >>> family = build_universal_sandwich(3, has_triangle)
    >>> family.is_valid()
    True
    """
    all_graphs = enumerate_all_graphs(n)
    pos = [g for g in all_graphs if prop_fn(g)]
    neg = [g for g in all_graphs if not prop_fn(g)]
    return CertifiedSandwichFamily(pos=pos, neg=neg, property_fn=prop_fn)


def build_monotone_threshold_circuits(n: int, max_size: int) -> List[MonotoneCircuit]:
    """Build simple monotone threshold circuits on n-vertex graphs.

    These are circuits that check if the number of edges exceeds a threshold.
    They are monotone and have size proportional to the number of edges.

    This is a heuristic sample — exhaustive enumeration of all monotone circuits
    is computationally infeasible.

    >>> circuits = build_monotone_threshold_circuits(3, 5)
    >>> len(circuits) > 0
    True
    """
    possible_edges = list(combinations(range(n), 2))
    m = len(possible_edges)
    circuits = []

    # Threshold circuits: output true iff |edges| >= t
    for t in range(m + 1):
        def make_fn(threshold):
            return lambda edges: len(edges) >= threshold
        if t <= max_size:  # crude size bound
            circuits.append(MonotoneCircuit(size=min(t, max_size), eval_fn=make_fn(t)))

    # Edge-check circuits: output true iff specific edge present
    for edge in possible_edges:
        def make_edge_fn(e):
            return lambda edges: e in edges
        circuits.append(MonotoneCircuit(size=1, eval_fn=make_edge_fn(edge)))

    return circuits


def find_minimal_sandwich(
    n: int,
    prop_fn: Callable[[Graph], bool],
    circuits: List[MonotoneCircuit]
) -> CertifiedSandwichFamily:
    """Find a minimal sandwich family that hits all given circuits.

    Uses a greedy algorithm: iteratively add the witness that hits
    the most remaining unhit circuits.

    Time complexity: O(|witnesses| * |circuits|) per round, O(|family| rounds).

    >>> circuits = build_monotone_threshold_circuits(3, 3)
    >>> family = find_minimal_sandwich(3, has_triangle, circuits)
    >>> family.is_valid()
    True
    """
    all_graphs = enumerate_all_graphs(n)
    pos_candidates = [g for g in all_graphs if prop_fn(g)]
    neg_candidates = [g for g in all_graphs if not prop_fn(g)]

    # Determine which circuits don't compute the property
    bad_circuits = []
    for c in circuits:
        if any(c.eval(g) != prop_fn(g) for g in all_graphs):
            bad_circuits.append(c)

    if not bad_circuits:
        return CertifiedSandwichFamily(pos=[], neg=[], property_fn=prop_fn)

    # Greedy cover
    pos_selected = []
    neg_selected = []
    unhit = set(range(len(bad_circuits)))

    while unhit:
        best_witness = None
        best_count = 0
        best_is_pos = True

        for g in pos_candidates:
            count = sum(1 for idx in unhit
                       if not bad_circuits[idx].eval(g) and prop_fn(g))
            if count > best_count:
                best_count = count
                best_witness = g
                best_is_pos = True

        for g in neg_candidates:
            count = sum(1 for idx in unhit
                       if bad_circuits[idx].eval(g) and not prop_fn(g))
            if count > best_count:
                best_count = count
                best_witness = g
                best_is_pos = False

        if best_witness is None:
            break

        if best_is_pos:
            pos_selected.append(best_witness)
            unhit -= {idx for idx in unhit
                     if not bad_circuits[idx].eval(best_witness) and prop_fn(best_witness)}
        else:
            neg_selected.append(best_witness)
            unhit -= {idx for idx in unhit
                     if bad_circuits[idx].eval(best_witness) and not prop_fn(best_witness)}

    return CertifiedSandwichFamily(pos=pos_selected, neg=neg_selected, property_fn=prop_fn)


def analyze_certificate_growth(
    max_n: int,
    prop_fn_family: Callable[[int], Callable[[Graph], bool]],
    prop_name: str = "property"
) -> Dict[int, Dict]:
    """Analyze the growth of minimal certificate family size across input sizes.

    For each n from 3 to max_n:
    - Build the universal sandwich family
    - Build sample monotone circuits
    - Find a minimal sandwich family
    - Record family sizes

    Returns a dictionary mapping n to analysis results.

    >>> results = analyze_certificate_growth(5, lambda n: has_triangle)
    >>> all(r['universal_size'] > 0 for r in results.values())
    True
    """
    results = {}
    for n in range(3, max_n + 1):
        prop_fn = prop_fn_family(n)
        universal = build_universal_sandwich(n, prop_fn)
        circuits = build_monotone_threshold_circuits(n, n * n)
        minimal = find_minimal_sandwich(n, prop_fn, circuits)

        num_edges = n * (n - 1) // 2
        total_graphs = 2 ** num_edges

        results[n] = {
            'n': n,
            'num_edges': num_edges,
            'total_graphs': total_graphs,
            'universal_size': universal.family_size(),
            'pos_count': len(universal.pos),
            'neg_count': len(universal.neg),
            'minimal_size': minimal.family_size(),
            'minimal_pos': len(minimal.pos),
            'minimal_neg': len(minimal.neg),
            'ratio': minimal.family_size() / max(1, universal.family_size()),
        }

    return results


def estimate_polynomial_bound(sizes: Dict[int, int]) -> Tuple[float, float]:
    """Estimate polynomial bound C * n^d from data points.

    Uses least-squares fit in log-log space.

    Returns (C, d) where family_size ≈ C * n^d.

    >>> C, d = estimate_polynomial_bound({3: 8, 4: 16, 5: 32})
    >>> d > 0
    True
    """
    import math
    ns = sorted(sizes.keys())
    if len(ns) < 2:
        return (1.0, 0.0)

    log_ns = [math.log(n) for n in ns]
    log_ss = [math.log(max(1, sizes[n])) for n in ns]

    # Least squares in log-log space: log(s) = log(C) + d * log(n)
    n_pts = len(ns)
    sum_x = sum(log_ns)
    sum_y = sum(log_ss)
    sum_xy = sum(x * y for x, y in zip(log_ns, log_ss))
    sum_x2 = sum(x ** 2 for x in log_ns)

    denom = n_pts * sum_x2 - sum_x ** 2
    if abs(denom) < 1e-10:
        return (1.0, 0.0)

    d = (n_pts * sum_xy - sum_x * sum_y) / denom
    log_C = (sum_y - d * sum_x) / n_pts
    C = math.exp(log_C)

    return (C, d)


if __name__ == "__main__":
    print("=== Monotone Circuit Certificate Algorithms ===\n")

    # Test with triangle property
    print("Testing triangle property on small graphs:")
    for n in range(3, 7):
        all_g = enumerate_all_graphs(n)
        tri_count = sum(1 for g in all_g if has_triangle(g))
        print(f"  n={n}: {len(all_g)} graphs, {tri_count} contain a triangle")

    print("\nBuilding universal sandwich families:")
    for n in range(3, 6):
        family = build_universal_sandwich(n, has_triangle)
        print(f"  n={n}: |Pos|={len(family.pos)}, |Neg|={len(family.neg)}, "
              f"total={family.family_size()}, valid={family.is_valid()}")

    print("\nCertificate growth analysis:")
    results = analyze_certificate_growth(6, lambda n: has_triangle, "triangle")
    for n, r in sorted(results.items()):
        print(f"  n={n}: universal={r['universal_size']}, "
              f"minimal={r['minimal_size']}, ratio={r['ratio']:.3f}")

    # Polynomial fit
    sizes = {n: r['universal_size'] for n, r in results.items()}
    C, d = estimate_polynomial_bound(sizes)
    print(f"\nPolynomial fit: family_size ≈ {C:.2f} * n^{d:.2f}")
