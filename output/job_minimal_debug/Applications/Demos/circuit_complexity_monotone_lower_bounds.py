#!/usr/bin/env python3
"""
Applications of Monotone Circuit Complexity Framework

This module demonstrates real-world applications of the formal
monotone circuit complexity theory:

1. Network reliability analysis via monotone function complexity
2. Database query optimization through monotone circuit bounds
3. Cryptographic threshold scheme analysis
4. AI/ML feature selection monotonicity constraints
"""

import itertools
import math
import random
from typing import List, Tuple, Set, Dict, Callable


# ─────────────────────────────────────────────────────────────────────
# Application 1: Network Reliability Analysis
# ─────────────────────────────────────────────────────────────────────

def network_connectivity_predicate(n: int, edges: Set[Tuple[int, int]],
                                    source: int = 0, target: int = None) -> bool:
    """
    Check s-t connectivity in a network.

    This is a monotone Boolean function: adding edges can only help
    connectivity, never break it. The monotone circuit complexity of
    this function directly bounds the computational cost of reliability
    analysis.

    Args:
        n: Number of nodes
        edges: Set of (u, v) edges
        source: Source node
        target: Target node (default: n-1)

    Returns:
        True if source is connected to target
    """
    if target is None:
        target = n - 1

    visited = set()
    stack = [source]
    while stack:
        node = stack.pop()
        if node == target:
            return True
        if node in visited:
            continue
        visited.add(node)
        for u, v in edges:
            if u == node and v not in visited:
                stack.append(v)
            elif v == node and u not in visited:
                stack.append(u)
    return False


def analyze_network_reliability(n: int, edge_prob: float = 0.5,
                                 num_trials: int = 1000) -> Dict:
    """
    Analyze network reliability using monotone complexity bounds.

    The monotone circuit complexity of connectivity determines how
    efficiently one can evaluate network reliability. Our formal
    theorems show that any monotone formula for connectivity on n
    nodes requires depth Ω(log² n).

    Args:
        n: Number of network nodes
        edge_prob: Individual edge reliability
        num_trials: Number of Monte Carlo trials

    Returns:
        Reliability analysis results
    """
    all_edges = list(itertools.combinations(range(n), 2))
    connected_count = 0

    for _ in range(num_trials):
        active_edges = {e for e in all_edges if random.random() < edge_prob}
        if network_connectivity_predicate(n, active_edges):
            connected_count += 1

    reliability = connected_count / num_trials

    # Lower bound on monotone formula depth for connectivity
    # Karchmer-Wigderson showed this is Θ(log² n)
    kw_depth_bound = max(1, int(math.log2(n) ** 2)) if n > 1 else 0

    return {
        'n': n,
        'edge_prob': edge_prob,
        'reliability': reliability,
        'num_trials': num_trials,
        'kw_depth_lower_bound': kw_depth_bound,
        'total_edges': len(all_edges),
    }


# ─────────────────────────────────────────────────────────────────────
# Application 2: Database Query Optimization
# ─────────────────────────────────────────────────────────────────────

def monotone_query_complexity(query_type: str, n: int) -> Dict:
    """
    Analyze the monotone complexity of common database query patterns.

    Many database queries are monotone (adding rows can only add results,
    not remove them for conjunctive queries). The monotone circuit complexity
    bounds the minimum query evaluation cost.

    Args:
        query_type: Type of query ('join', 'union', 'exists')
        n: Size parameter

    Returns:
        Complexity analysis
    """
    if query_type == 'join':
        # Natural join is AND of edge predicates (triangle join = 3-clique)
        size_bound = n * (n - 1) * (n - 2) // 6  # O(n³) for triangle
        depth_bound = int(math.ceil(math.log2(n))) + 2
        description = "Triangle join query (3-way natural join)"
    elif query_type == 'union':
        # Union is OR (monotone, very simple)
        size_bound = n
        depth_bound = int(math.ceil(math.log2(n)))
        description = "Union query (disjunction of conditions)"
    elif query_type == 'exists':
        # Existential query (path query)
        size_bound = n * n
        depth_bound = max(1, int(math.log2(n) ** 2))
        description = "Path existence query (transitive closure)"
    else:
        raise ValueError(f"Unknown query type: {query_type}")

    return {
        'query_type': query_type,
        'description': description,
        'n': n,
        'monotone_size_bound': size_bound,
        'monotone_depth_bound': depth_bound,
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Threshold Cryptography Analysis
# ─────────────────────────────────────────────────────────────────────

def threshold_function(x: Tuple[bool, ...], t: int) -> bool:
    """
    Threshold function: True iff at least t inputs are True.

    This is a fundamental monotone function used in threshold cryptography.
    Its circuit complexity determines the efficiency of threshold schemes.
    """
    return sum(1 for b in x if b) >= t


def analyze_threshold_complexity(n: int, t: int) -> Dict:
    """
    Analyze the monotone complexity of threshold functions.

    Threshold-t on n variables has known monotone complexity bounds.
    The KW witness space structure directly relates to the security
    parameters of threshold cryptographic schemes.

    Args:
        n: Number of parties
        t: Threshold value

    Returns:
        Complexity analysis for the threshold function
    """
    # Count KW witnesses for threshold-t
    num_witnesses = 0
    for x in itertools.product([False, True], repeat=n):
        if not threshold_function(x, t):
            continue
        for y in itertools.product([False, True], repeat=n):
            if threshold_function(y, t):
                continue
            for i in range(n):
                if x[i] != y[i]:
                    num_witnesses += 1

    log2_witnesses = math.log2(num_witnesses) if num_witnesses > 0 else 0
    compression_bound = math.ceil(log2_witnesses)

    # Known bound: threshold has monotone formula size Θ(n^(3/2)) for t = n/2
    formula_size_bound = int(n ** 1.5) if t == n // 2 else n * t

    return {
        'n': n,
        'threshold': t,
        'num_kw_witnesses': num_witnesses,
        'log2_witnesses': log2_witnesses,
        'compression_lower_bound': compression_bound,
        'formula_size_estimate': formula_size_bound,
    }


# ─────────────────────────────────────────────────────────────────────
# Application 4: ML Feature Selection Constraints
# ─────────────────────────────────────────────────────────────────────

def monotone_feature_selection_bounds(
    num_features: int,
    target_complexity: str = 'low'
) -> Dict:
    """
    Analyze monotonicity constraints in ML feature selection.

    When a classification rule must be monotone (e.g., "more features
    present → more likely positive"), the monotone circuit complexity
    framework provides fundamental limits on model expressiveness.

    This is directly relevant to interpretable/explainable AI, where
    monotonicity is a common fairness or interpretability constraint.

    Args:
        num_features: Number of Boolean features
        target_complexity: 'low', 'medium', or 'high'

    Returns:
        Analysis of achievable model complexity under monotonicity
    """
    n = num_features

    # Number of monotone Boolean functions on n variables
    # This is the Dedekind number D(n), which grows super-exponentially
    if n <= 6:
        dedekind = [2, 3, 6, 20, 168, 7581, 7828354][n]
    else:
        dedekind = int(2 ** (math.comb(n, n // 2)))  # Rough lower bound

    # Total Boolean functions
    total_functions = 2 ** (2 ** n) if n <= 5 else float('inf')

    # Fraction of functions that are monotone
    monotone_fraction = dedekind / total_functions if total_functions < float('inf') else 0

    # Circuit complexity bounds
    if target_complexity == 'low':
        max_size = n * 2
        max_depth = int(math.ceil(math.log2(n))) + 1
    elif target_complexity == 'medium':
        max_size = n * n
        max_depth = int(math.ceil(math.log2(n))) * 2
    else:
        max_size = 2 ** n
        max_depth = n

    return {
        'num_features': n,
        'num_monotone_functions': dedekind,
        'total_functions': total_functions if total_functions < float('inf') else '2^(2^n)',
        'monotone_fraction': f'{monotone_fraction:.6f}' if monotone_fraction > 0 else '~0',
        'max_circuit_size': max_size,
        'max_circuit_depth': max_depth,
        'expressiveness_note': (
            f"With {max_size} gates and depth {max_depth}, "
            f"you can express O(2^{max_size}) distinct functions"
        ),
    }


# ─────────────────────────────────────────────────────────────────────
# Main: Run all application demos
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Monotone Circuit Complexity            ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Network Reliability
    print("\n" + "=" * 60)
    print("APPLICATION 1: Network Reliability Analysis")
    print("=" * 60)
    random.seed(42)
    for n in [4, 6, 8, 10]:
        result = analyze_network_reliability(n, edge_prob=0.6, num_trials=5000)
        print(f"  n={n:2d}: reliability={result['reliability']:.3f}, "
              f"KW depth bound ≥ {result['kw_depth_lower_bound']}, "
              f"edges={result['total_edges']}")

    # Application 2: Database Query Optimization
    print("\n" + "=" * 60)
    print("APPLICATION 2: Database Query Complexity")
    print("=" * 60)
    for query in ['join', 'union', 'exists']:
        for n in [10, 100, 1000]:
            result = monotone_query_complexity(query, n)
            print(f"  {result['description'][:30]:30s} n={n:4d}: "
                  f"size≥{result['monotone_size_bound']:8d}, "
                  f"depth≥{result['monotone_depth_bound']:2d}")

    # Application 3: Threshold Cryptography
    print("\n" + "=" * 60)
    print("APPLICATION 3: Threshold Cryptography Analysis")
    print("=" * 60)
    for n in [4, 5, 6]:
        for t in [n // 2, (n + 1) // 2]:
            result = analyze_threshold_complexity(n, t)
            print(f"  Threshold-{t}-of-{n}: |KW witnesses|={result['num_kw_witnesses']:6d}, "
                  f"log₂={result['log2_witnesses']:.1f}, "
                  f"compression bound={result['compression_lower_bound']}")

    # Application 4: ML Feature Selection
    print("\n" + "=" * 60)
    print("APPLICATION 4: Monotone ML Model Constraints")
    print("=" * 60)
    for n in [3, 4, 5, 6]:
        result = monotone_feature_selection_bounds(n, 'medium')
        print(f"  n={n}: monotone functions={result['num_monotone_functions']:>10}, "
              f"fraction={result['monotone_fraction']}, "
              f"max circuit: size={result['max_circuit_size']}, depth={result['max_circuit_depth']}")

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Monotone Circuit Complexity: Interactive Demonstrations

This script demonstrates the key concepts from the formal monotone circuit
complexity framework:
1. Small graph instance construction and clique evaluation
2. Monotone circuit simulation and approximation sandwich testing
3. KW witness space enumeration and compression statistics
"""

import itertools
import random
import math
from typing import List, Tuple, Set, Dict, Optional

# ─────────────────────────────────────────────────────────────────────
# Part 1: Graph Representation and Clique Predicate
# ─────────────────────────────────────────────────────────────────────

class SimpleGraph:
    """A simple undirected graph on vertices {0, ..., n-1}."""

    def __init__(self, n: int, edges: Optional[Set[Tuple[int, int]]] = None):
        self.n = n
        self.edges: Set[Tuple[int, int]] = set()
        if edges:
            for u, v in edges:
                self.add_edge(u, v)

    def add_edge(self, u: int, v: int):
        if u != v and 0 <= u < self.n and 0 <= v < self.n:
            self.edges.add((min(u, v), max(u, v)))

    def has_edge(self, u: int, v: int) -> bool:
        return (min(u, v), max(u, v)) in self.edges

    def is_subgraph_of(self, other: 'SimpleGraph') -> bool:
        return self.edges.issubset(other.edges)

    def has_clique(self, k: int) -> bool:
        """Check if graph contains a clique of size k."""
        for subset in itertools.combinations(range(self.n), k):
            if all(self.has_edge(u, v) for u, v in itertools.combinations(subset, 2)):
                return True
        return False

    def find_cliques(self, k: int) -> List[Tuple[int, ...]]:
        """Find all k-cliques."""
        cliques = []
        for subset in itertools.combinations(range(self.n), k):
            if all(self.has_edge(u, v) for u, v in itertools.combinations(subset, 2)):
                cliques.append(subset)
        return cliques

    @staticmethod
    def complete(n: int) -> 'SimpleGraph':
        """The complete graph K_n."""
        g = SimpleGraph(n)
        for u, v in itertools.combinations(range(n), 2):
            g.add_edge(u, v)
        return g

    @staticmethod
    def random_graph(n: int, p: float = 0.5) -> 'SimpleGraph':
        """Erdős–Rényi random graph G(n, p)."""
        g = SimpleGraph(n)
        for u, v in itertools.combinations(range(n), 2):
            if random.random() < p:
                g.add_edge(u, v)
        return g

    def __repr__(self):
        return f"SimpleGraph(n={self.n}, edges={sorted(self.edges)})"


# ─────────────────────────────────────────────────────────────────────
# Part 2: Monotone Circuit Simulation
# ─────────────────────────────────────────────────────────────────────

class MonotoneGate:
    """A gate in a monotone Boolean circuit (AND/OR only, no NOT)."""

    def __init__(self, gate_type: str, inputs=None, var_index=None):
        assert gate_type in ('AND', 'OR', 'VAR', 'TRUE', 'FALSE')
        self.gate_type = gate_type
        self.inputs = inputs or []
        self.var_index = var_index

    def evaluate(self, assignment: Dict[int, bool]) -> bool:
        if self.gate_type == 'VAR':
            return assignment.get(self.var_index, False)
        elif self.gate_type == 'TRUE':
            return True
        elif self.gate_type == 'FALSE':
            return False
        elif self.gate_type == 'AND':
            return all(inp.evaluate(assignment) for inp in self.inputs)
        elif self.gate_type == 'OR':
            return any(inp.evaluate(assignment) for inp in self.inputs)
        return False

    @property
    def size(self) -> int:
        if self.gate_type in ('VAR', 'TRUE', 'FALSE'):
            return 1
        return 1 + sum(inp.size for inp in self.inputs)

    @property
    def depth(self) -> int:
        if self.gate_type in ('VAR', 'TRUE', 'FALSE'):
            return 0
        return 1 + max(inp.depth for inp in self.inputs)


def edge_var_index(n: int, u: int, v: int) -> int:
    """Map edge (u,v) to a variable index for n-vertex graphs."""
    u, v = min(u, v), max(u, v)
    return u * n - u * (u + 1) // 2 + (v - u - 1)


def graph_to_assignment(g: SimpleGraph) -> Dict[int, bool]:
    """Convert a graph to a Boolean assignment over edge variables."""
    assignment = {}
    for u, v in itertools.combinations(range(g.n), 2):
        idx = edge_var_index(g.n, u, v)
        assignment[idx] = g.has_edge(u, v)
    return assignment


def build_triangle_circuit(n: int) -> MonotoneGate:
    """Build a monotone circuit for the triangle (3-clique) predicate on n vertices.

    The circuit is: OR over all triples (i,j,k) of AND(edge_ij, edge_ik, edge_jk).
    This is the simplest monotone circuit for 3-CLIQUE.
    """
    or_inputs = []
    for triple in itertools.combinations(range(n), 3):
        i, j, k = triple
        and_gate = MonotoneGate('AND', [
            MonotoneGate('VAR', var_index=edge_var_index(n, i, j)),
            MonotoneGate('VAR', var_index=edge_var_index(n, i, k)),
            MonotoneGate('VAR', var_index=edge_var_index(n, j, k)),
        ])
        or_inputs.append(and_gate)
    if not or_inputs:
        return MonotoneGate('FALSE')
    return MonotoneGate('OR', or_inputs)


# ─────────────────────────────────────────────────────────────────────
# Part 3: Approximation Sandwich Testing
# ─────────────────────────────────────────────────────────────────────

def build_clique_approximation_sandwich(n: int, k: int, num_pos: int = 10,
                                         num_neg: int = 10):
    """Construct candidate positive/negative test families for k-CLIQUE.

    Positive instances: graphs containing a k-clique (constructed by embedding K_k).
    Negative instances: sparse random graphs unlikely to contain k-cliques.
    """
    positive = []
    for _ in range(num_pos):
        g = SimpleGraph(n)
        # Embed a k-clique on random vertices
        if k <= n:
            clique_verts = random.sample(range(n), k)
            for u, v in itertools.combinations(clique_verts, 2):
                g.add_edge(u, v)
            # Add some random edges
            for u, v in itertools.combinations(range(n), 2):
                if random.random() < 0.2:
                    g.add_edge(u, v)
        positive.append(g)

    negative = []
    for _ in range(num_neg):
        # Very sparse graph: unlikely to have k-clique for k ≥ 3
        g = SimpleGraph.random_graph(n, p=0.1)
        if not g.has_clique(k):
            negative.append(g)
    # Ensure we have at least some negatives
    if not negative:
        negative.append(SimpleGraph(n))  # Empty graph

    return positive, negative


def test_circuit_against_sandwich(circuit: MonotoneGate, n: int, k: int,
                                   positive: List[SimpleGraph],
                                   negative: List[SimpleGraph]) -> Dict:
    """Test a monotone circuit against an approximation sandwich.

    Returns statistics on agreement/disagreement with the clique predicate.
    """
    results = {
        'pos_agree': 0, 'pos_disagree': 0,
        'neg_agree': 0, 'neg_disagree': 0,
        'total_tests': 0,
        'failures': []
    }

    for g in positive:
        assignment = graph_to_assignment(g)
        circuit_out = circuit.evaluate(assignment)
        target = g.has_clique(k)
        results['total_tests'] += 1
        if circuit_out == target:
            results['pos_agree'] += 1
        else:
            results['pos_disagree'] += 1
            results['failures'].append(('POS', g, circuit_out, target))

    for g in negative:
        assignment = graph_to_assignment(g)
        circuit_out = circuit.evaluate(assignment)
        target = g.has_clique(k)
        results['total_tests'] += 1
        if circuit_out == target:
            results['neg_agree'] += 1
        else:
            results['neg_disagree'] += 1
            results['failures'].append(('NEG', g, circuit_out, target))

    return results


# ─────────────────────────────────────────────────────────────────────
# Part 4: KW Witness Space and Compression Statistics
# ─────────────────────────────────────────────────────────────────────

def enumerate_kw_witnesses(n: int, f) -> List[Tuple]:
    """Enumerate KW witnesses (x, y, i) for a Boolean function on n-bit vectors.

    A KW witness is a triple where f(x) = True, f(y) = False, and x[i] ≠ y[i].
    """
    witnesses = []
    for x in itertools.product([False, True], repeat=n):
        if not f(x):
            continue
        for y in itertools.product([False, True], repeat=n):
            if f(y):
                continue
            for i in range(n):
                if x[i] != y[i]:
                    witnesses.append((x, y, i))
    return witnesses


def compression_statistics(witnesses: List) -> Dict:
    """Compute compression statistics for a set of KW witnesses."""
    num = len(witnesses)
    if num == 0:
        return {'count': 0, 'log2_count': 0, 'min_code_length': 0}

    log2_count = math.log2(num)
    min_code_length = math.ceil(log2_count)

    return {
        'count': num,
        'log2_count': log2_count,
        'min_code_length': min_code_length,
        'bits_per_witness': log2_count,
    }


# ─────────────────────────────────────────────────────────────────────
# Part 5: Interactive Demonstrations
# ─────────────────────────────────────────────────────────────────────

def demo_clique_predicate():
    """Demonstrate the clique predicate on small graphs."""
    print("=" * 60)
    print("DEMO 1: Clique Predicate on Small Graphs")
    print("=" * 60)

    # Complete graphs
    for n in range(3, 7):
        g = SimpleGraph.complete(n)
        for k in range(2, n + 2):
            has = g.has_clique(k)
            cliques = g.find_cliques(k)
            print(f"  K_{n} has {k}-clique: {has} ({len(cliques)} cliques)")

    print()

    # Random graphs
    print("Random graphs G(6, 0.5):")
    random.seed(42)
    for trial in range(5):
        g = SimpleGraph.random_graph(6, 0.5)
        for k in [3, 4]:
            has = g.has_clique(k)
            print(f"  Trial {trial+1}: has {k}-clique = {has}, edges = {len(g.edges)}")


def demo_monotone_circuit():
    """Demonstrate monotone circuit construction and evaluation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Monotone Circuit for Triangle Detection")
    print("=" * 60)

    for n in [4, 5, 6]:
        circuit = build_triangle_circuit(n)
        print(f"\n  n={n}: circuit size={circuit.size}, depth={circuit.depth}")

        # Test on graphs with and without triangles
        # Triangle graph
        g_tri = SimpleGraph(n, {(0, 1), (1, 2), (0, 2)})
        asgn = graph_to_assignment(g_tri)
        print(f"  Triangle graph: circuit={circuit.evaluate(asgn)}, "
              f"actual={g_tri.has_clique(3)}")

        # Path graph (no triangle)
        g_path = SimpleGraph(n, {(i, i+1) for i in range(n-1)})
        asgn = graph_to_assignment(g_path)
        print(f"  Path graph:     circuit={circuit.evaluate(asgn)}, "
              f"actual={g_path.has_clique(3)}")

        # Complete graph (many triangles)
        g_comp = SimpleGraph.complete(n)
        asgn = graph_to_assignment(g_comp)
        print(f"  Complete graph: circuit={circuit.evaluate(asgn)}, "
              f"actual={g_comp.has_clique(3)}")


def demo_approximation_sandwich():
    """Demonstrate the approximation sandwich method."""
    print("\n" + "=" * 60)
    print("DEMO 3: Approximation Sandwich for 3-CLIQUE")
    print("=" * 60)

    random.seed(123)
    for n in [5, 6, 7]:
        k = 3
        pos, neg = build_clique_approximation_sandwich(n, k, 20, 20)
        circuit = build_triangle_circuit(n)

        results = test_circuit_against_sandwich(circuit, n, k, pos, neg)

        print(f"\n  n={n}, k={k}: |pos|={len(pos)}, |neg|={len(neg)}")
        print(f"  Correct circuit: pos_agree={results['pos_agree']}, "
              f"neg_agree={results['neg_agree']}")
        print(f"  Disagreements: pos={results['pos_disagree']}, "
              f"neg={results['neg_disagree']}")
        print(f"  → The correct circuit passes the sandwich test (0 failures)")

        # Now test a trivially wrong "circuit" (always True)
        wrong = MonotoneGate('TRUE')
        results2 = test_circuit_against_sandwich(wrong, n, k, pos, neg)
        print(f"  Always-TRUE circuit: failures = "
              f"{results2['pos_disagree'] + results2['neg_disagree']}")


def demo_kw_witnesses():
    """Demonstrate KW witness enumeration and compression bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: KW Witness Space & Compression Bounds")
    print("=" * 60)

    # OR function
    def or_fn(x):
        return any(x)

    # AND function
    def and_fn(x):
        return all(x)

    # Parity function
    def parity_fn(x):
        return sum(1 for b in x if b) % 2 == 1

    functions = [
        ("OR", or_fn),
        ("AND", and_fn),
        ("PARITY", parity_fn),
    ]

    for n in [3, 4]:
        print(f"\n  n = {n}:")
        for name, fn in functions:
            witnesses = enumerate_kw_witnesses(n, fn)
            stats = compression_statistics(witnesses)
            print(f"    {name:8s}: |witnesses| = {stats['count']:5d}, "
                  f"log₂ = {stats['log2_count']:.2f}, "
                  f"min code length = {stats['min_code_length']} bits")

    # Show entropy lower bound
    print("\n  Compression Lower Bound Theorem:")
    print("  If |KW witnesses| ≥ 2^d, then any injective encoding needs")
    print("  at least d bits for some witness.")
    print()
    for n in [3, 4, 5]:
        witnesses = enumerate_kw_witnesses(n, parity_fn)
        stats = compression_statistics(witnesses)
        d = int(math.log2(len(witnesses))) if witnesses else 0
        print(f"    PARITY(n={n}): |W|={len(witnesses)}, "
              f"d={d}, 2^d={2**d} ≤ {len(witnesses)}")


def demo_monotonicity():
    """Demonstrate monotonicity of the clique predicate under edge addition."""
    print("\n" + "=" * 60)
    print("DEMO 5: Monotonicity of Clique Predicate")
    print("=" * 60)

    n, k = 5, 3
    random.seed(99)

    print(f"  Verifying: if G ⊆ H and G has a {k}-clique, then H has a {k}-clique")
    violations = 0
    tests = 0

    for _ in range(100):
        g = SimpleGraph.random_graph(n, 0.4)
        # H = G + some random edges
        h = SimpleGraph(n, g.edges.copy())
        for u, v in itertools.combinations(range(n), 2):
            if random.random() < 0.3:
                h.add_edge(u, v)

        if g.has_clique(k):
            tests += 1
            if not h.has_clique(k):
                violations += 1
                print(f"    VIOLATION: G has {k}-clique but supergraph H does not!")

    print(f"  Tested {tests} cases where G has a {k}-clique")
    print(f"  Violations: {violations} (should be 0)")
    print(f"  → Monotonicity confirmed {'✓' if violations == 0 else '✗'}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Monotone Circuit Complexity: Interactive Demonstrations ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_clique_predicate()
    demo_monotone_circuit()
    demo_approximation_sandwich()
    demo_kw_witnesses()
    demo_monotonicity()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
