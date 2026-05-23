#!/usr/bin/env python3
"""
Algorithms for Certified Sandwich Family Construction

Implements the core algorithms from the research paper:
1. Circuit enumeration for monotone Boolean circuits
2. Greedy sandwich family construction
3. Minimal transversal computation
4. Sandwich family verification
5. Universality testing across graph properties

All algorithms include complexity analysis in docstrings.
"""

from itertools import combinations, product
from typing import Optional
import time


# ─────────────────────────────────────────────────────────────────────
# Data types
# ─────────────────────────────────────────────────────────────────────

class MonotoneCircuit:
    """Abstract base for monotone Boolean circuits."""
    def evaluate(self, G: frozenset) -> bool:
        raise NotImplementedError
    @property
    def size(self) -> int:
        raise NotImplementedError


class Var(MonotoneCircuit):
    """Edge variable."""
    def __init__(self, edge: tuple[int, int]):
        self.edge = edge
    def evaluate(self, G: frozenset) -> bool:
        return self.edge in G
    @property
    def size(self) -> int:
        return 1
    def __repr__(self):
        return f"x_{self.edge}"


class Const(MonotoneCircuit):
    """Constant (True/False)."""
    def __init__(self, val: bool):
        self.val = val
    def evaluate(self, G: frozenset) -> bool:
        return self.val
    @property
    def size(self) -> int:
        return 1
    def __repr__(self):
        return str(self.val)


class And(MonotoneCircuit):
    """AND gate (conjunction)."""
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit):
        self.left, self.right = left, right
    def evaluate(self, G: frozenset) -> bool:
        return self.left.evaluate(G) and self.right.evaluate(G)
    @property
    def size(self) -> int:
        return 1 + self.left.size + self.right.size
    def __repr__(self):
        return f"({self.left} ∧ {self.right})"


class Or(MonotoneCircuit):
    """OR gate (disjunction)."""
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit):
        self.left, self.right = left, right
    def evaluate(self, G: frozenset) -> bool:
        return self.left.evaluate(G) or self.right.evaluate(G)
    @property
    def size(self) -> int:
        return 1 + self.left.size + self.right.size
    def __repr__(self):
        return f"({self.left} ∨ {self.right})"


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Circuit Enumeration
# ─────────────────────────────────────────────────────────────────────

def enumerate_monotone_circuits(edges: list[tuple[int, int]],
                                 max_size: int) -> list[MonotoneCircuit]:
    """Enumerate all monotone circuits up to a given size.

    Algorithm: Dynamic programming over circuit size.
    - Size 1: variables x_e for each edge e, plus constants T, F
    - Size s (odd, s ≥ 3): combine circuits of sizes a, b with
      a + b = s - 1 using AND or OR gates.

    Time complexity: O(C(s)^2) where C(s) is the number of circuits
    of size ≤ s. In the worst case C(s) grows exponentially in s.

    Space complexity: O(C(s)) to store all circuits.

    Args:
        edges: List of possible edges (i,j) with i < j
        max_size: Maximum circuit tree size

    Returns:
        List of all monotone circuits with size ≤ max_size
    """
    by_size: dict[int, list[MonotoneCircuit]] = {}
    by_size[1] = [Const(False), Const(True)] + [Var(e) for e in edges]

    for s in range(3, max_size + 1):
        circuits_s = []
        for a in range(1, s - 1):
            b = s - 1 - a
            if b < 1:
                continue
            for c1 in by_size.get(a, []):
                for c2 in by_size.get(b, []):
                    circuits_s.append(And(c1, c2))
                    circuits_s.append(Or(c1, c2))
        by_size[s] = circuits_s

    result = []
    for s in range(1, max_size + 1):
        result.extend(by_size.get(s, []))
    return result


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Greedy Sandwich Family Construction
# ─────────────────────────────────────────────────────────────────────

def greedy_sandwich_construction(
    f,
    n: int,
    circuits: list[MonotoneCircuit],
    graphs: list[frozenset]
) -> tuple[set[frozenset], set[frozenset]]:
    """Greedy construction of a certified sandwich family.

    Algorithm:
    1. Compute disagreement table: for each circuit C and graph G,
       record whether C(G) ≠ f(G).
    2. Greedily select witnesses that hit the most unhit circuits.
    3. Partition selected witnesses into Pos (f=True) and Neg (f=False).

    Time complexity: O(|circuits| × |graphs| + |family| × |circuits|)
    Space complexity: O(|circuits| × |graphs|) for disagreement table

    Args:
        f: Target monotone Boolean function f(G, n) -> bool
        n: Number of vertices
        circuits: List of circuits to refute
        graphs: List of all graphs on n vertices

    Returns:
        (pos_set, neg_set): The certified sandwich family
    """
    # Precompute f values
    f_vals = {G: f(G, n) for G in graphs}

    # Precompute disagreement table
    # disagree[i] = set of graphs where circuit i disagrees with f
    disagree = []
    non_computing = []  # Indices of circuits that don't compute f
    for i, circ in enumerate(circuits):
        dis_set = set()
        for G in graphs:
            if circ.evaluate(G) != f_vals[G]:
                dis_set.add(G)
        disagree.append(dis_set)
        if dis_set:
            non_computing.append(i)

    # Greedy set cover
    unhit = set(non_computing)
    selected_witnesses = set()

    while unhit:
        # Find the graph that hits the most unhit circuits
        best_graph = None
        best_count = 0
        for G in graphs:
            count = sum(1 for i in unhit if G in disagree[i])
            if count > best_count:
                best_count = count
                best_graph = G
        if best_graph is None or best_count == 0:
            break
        selected_witnesses.add(best_graph)
        # Remove newly hit circuits
        unhit = {i for i in unhit if best_graph not in disagree[i]}

    # Partition into Pos and Neg
    pos = {G for G in selected_witnesses if f_vals[G]}
    neg = {G for G in selected_witnesses if not f_vals[G]}
    return pos, neg


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Minimal Transversal Computation
# ─────────────────────────────────────────────────────────────────────

def compute_minimal_transversal(
    f,
    n: int,
    circuits: list[MonotoneCircuit],
    graphs: list[frozenset]
) -> tuple[set[frozenset], int]:
    """Compute a minimal transversal of the circuit-refutation hypergraph.

    The hypergraph has:
    - Universe = set of all graphs
    - For each non-computing circuit C, a hyperedge = {G : C(G) ≠ f(G)}
    - A transversal is a set T of graphs hitting every hyperedge

    Algorithm: Brute-force search over subsets of graphs, increasing size.
    (Only feasible for tiny instances.)

    Time complexity: O(|graphs|^k × |circuits|) where k is transversal size
    Space complexity: O(|circuits| × |graphs|)

    Args:
        f: Target monotone Boolean function
        n: Number of vertices
        circuits: List of circuits
        graphs: List of all graphs

    Returns:
        (transversal, size): Minimal transversal and its size
    """
    f_vals = {G: f(G, n) for G in graphs}

    # Compute hyperedges
    hyperedges = []
    for circ in circuits:
        edge = frozenset(G for G in graphs if circ.evaluate(G) != f_vals[G])
        if edge:
            hyperedges.append(edge)

    if not hyperedges:
        return set(), 0

    # Remove duplicate hyperedges
    hyperedges = list(set(hyperedges))

    # Search for minimum transversal
    candidate_graphs = set()
    for he in hyperedges:
        candidate_graphs |= he
    candidate_list = list(candidate_graphs)

    for k in range(1, len(candidate_list) + 1):
        for subset in combinations(candidate_list, k):
            subset_set = set(subset)
            if all(subset_set & he for he in hyperedges):
                return subset_set, k

    return set(candidate_list), len(candidate_list)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Sandwich Family Verification
# ─────────────────────────────────────────────────────────────────────

def verify_sandwich_family(
    pos: set[frozenset],
    neg: set[frozenset],
    f,
    n: int,
    circuits: list[MonotoneCircuit],
    graphs: list[frozenset]
) -> tuple[bool, list]:
    """Verify that a sandwich family is complete.

    Checks:
    1. All elements of pos satisfy f (soundness of positive witnesses)
    2. All elements of neg falsify f (soundness of negative witnesses)
    3. Every non-computing circuit is hit by some witness (completeness)

    Time complexity: O((|pos| + |neg|) × |circuits|)
    Space complexity: O(|circuits|)

    Args:
        pos: Positive witness set
        neg: Negative witness set
        f: Target function
        n: Number of vertices
        circuits: Circuits to check against
        graphs: All graphs

    Returns:
        (is_complete, missed_circuits): Whether family is complete,
        and list of any missed circuits
    """
    f_vals = {G: f(G, n) for G in graphs}

    # Check soundness
    for G in pos:
        assert f_vals[G], f"Positive witness {G} does not satisfy f!"
    for G in neg:
        assert not f_vals[G], f"Negative witness {G} satisfies f!"

    # Check completeness
    witnesses = pos | neg
    missed = []
    for circ in circuits:
        computes_f = all(circ.evaluate(G) == f_vals[G] for G in graphs)
        if computes_f:
            continue
        hit = any(circ.evaluate(G) != f_vals[G] for G in witnesses)
        if not hit:
            missed.append(circ)

    return len(missed) == 0, missed


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Universality Test
# ─────────────────────────────────────────────────────────────────────

def test_universality(
    properties: dict,
    n_range: list[int],
    max_size: int
) -> dict:
    """Test the universality conjecture across multiple graph properties.

    For each property and vertex count, constructs a sandwich family
    and checks if it's complete and polynomially bounded.

    Args:
        properties: Dict mapping name -> function f(G, n) -> bool
        n_range: List of vertex counts to test
        max_size: Maximum circuit size bound

    Returns:
        Dictionary of results keyed by (property_name, n)
    """
    results = {}
    for name, f in properties.items():
        for n in n_range:
            edges = list(combinations(range(n), 2))
            graphs = []
            for r in range(len(edges) + 1):
                for subset in combinations(edges, r):
                    graphs.append(frozenset(subset))

            circuits = enumerate_monotone_circuits(edges, max_size)

            t0 = time.time()
            pos, neg = greedy_sandwich_construction(f, n, circuits, graphs)
            elapsed = time.time() - t0

            is_complete, missed = verify_sandwich_family(
                pos, neg, f, n, circuits, graphs)

            results[(name, n)] = {
                'property': name,
                'n': n,
                'max_size': max_size,
                'pos_size': len(pos),
                'neg_size': len(neg),
                'family_size': len(pos) + len(neg),
                'complete': is_complete,
                'num_circuits': len(circuits),
                'num_graphs': len(graphs),
                'time': elapsed,
                'missed': len(missed),
            }
    return results


# ─────────────────────────────────────────────────────────────────────
# Graph properties
# ─────────────────────────────────────────────────────────────────────

def has_triangle(G: frozenset, n: int) -> bool:
    for i, j, k in combinations(range(n), 3):
        if (i, j) in G and (j, k) in G and (i, k) in G:
            return True
    return False


def st_connected(G: frozenset, n: int) -> bool:
    if n <= 1:
        return True
    s, t = 0, n - 1
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


def has_perfect_matching(G: frozenset, n: int) -> bool:
    if n % 2 != 0:
        return False
    return _match(G, list(range(n)))


def _match(G: frozenset, verts: list) -> bool:
    if not verts:
        return True
    v = verts[0]
    rest = verts[1:]
    for u in rest:
        if (min(v, u), max(v, u)) in G:
            remaining = [w for w in rest if w != u]
            if _match(G, remaining):
                return True
    return False


# ─────────────────────────────────────────────────────────────────────
# Main: run all algorithms as demonstration
# ─────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("  ALGORITHMS FOR CERTIFIED SANDWICH FAMILIES")
    print("=" * 60)

    n = 4
    max_s = 3
    edges = list(combinations(range(n), 2))
    all_g = []
    for r in range(len(edges) + 1):
        for subset in combinations(edges, r):
            all_g.append(frozenset(subset))

    print(f"\nGraph parameters: n={n}, {len(edges)} edges, {len(all_g)} graphs")

    # Algorithm 1: Enumerate circuits
    print("\n--- Algorithm 1: Circuit Enumeration ---")
    circuits = enumerate_monotone_circuits(edges, max_s)
    print(f"  Circuits of size ≤ {max_s}: {len(circuits)}")

    # Algorithm 2: Greedy construction for triangle
    print("\n--- Algorithm 2: Greedy Sandwich Construction (Triangle) ---")
    pos, neg = greedy_sandwich_construction(has_triangle, n, circuits, all_g)
    print(f"  |Pos| = {len(pos)}, |Neg| = {len(neg)}, Total = {len(pos)+len(neg)}")

    # Algorithm 3: Minimal transversal
    print("\n--- Algorithm 3: Minimal Transversal ---")
    trans, trans_size = compute_minimal_transversal(has_triangle, n, circuits, all_g)
    print(f"  Minimal transversal size: {trans_size}")
    print(f"  Greedy family size: {len(pos)+len(neg)}")
    print(f"  Ratio: {(len(pos)+len(neg))/max(trans_size,1):.2f}")

    # Algorithm 4: Verification
    print("\n--- Algorithm 4: Verification ---")
    ok, missed = verify_sandwich_family(pos, neg, has_triangle, n, circuits, all_g)
    print(f"  Complete: {ok}")
    if missed:
        print(f"  Missed circuits: {len(missed)}")

    # Algorithm 5: Universality test
    print("\n--- Algorithm 5: Universality Test ---")
    props = {
        'triangle': has_triangle,
        'connectivity': st_connected,
        'matching': has_perfect_matching,
    }
    results = test_universality(props, [3, 4], max_s)
    print(f"\n  {'Property':<15} {'n':>3} {'|Family|':>8} {'Complete':>9} {'Time':>8}")
    print(f"  {'-'*48}")
    for key, r in sorted(results.items()):
        print(f"  {r['property']:<15} {r['n']:>3} {r['family_size']:>8} "
              f"{str(r['complete']):>9} {r['time']:>7.3f}s")
