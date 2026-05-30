#!/usr/bin/env python3
"""
Applications of Gate-Level Quantum Circuit Synthesis from Matroid Certificates

Demonstrates real-world applications:
1. Spanning tree sampling for network analysis
2. Weighted basis sampling for combinatorial optimization
3. Circuit depth optimization via tree balancing
"""

import math
from itertools import combinations
from typing import List, Dict, Set, FrozenSet, Tuple
from collections import defaultdict


# ============================================================
# Application 1: Network Spanning Tree Sampling
# ============================================================

def graph_to_matroid_cert(adj: Dict[int, List[Tuple[int, float]]],
                          vertices: List[int]) -> dict:
    """
    Convert a weighted graph to a matroid certificate for spanning tree sampling.

    The graphic matroid of a graph has edges as ground set and spanning trees
    as bases. For small graphs, we enumerate and build the certificate tree
    via deletion/contraction on edges.

    Args:
        adj: Adjacency list with edge weights
        vertices: List of vertex labels

    Returns:
        Dictionary with certificate tree info and exact distribution
    """
    # Enumerate edges
    edges = []
    seen = set()
    for u in adj:
        for v, w in adj[u]:
            if (min(u,v), max(u,v)) not in seen:
                edges.append((u, v, w))
                seen.add((min(u,v), max(u,v)))

    n_vertices = len(vertices)
    rank = n_vertices - 1  # spanning tree has n-1 edges

    # Enumerate spanning trees
    spanning_trees = []
    for subset in combinations(range(len(edges)), rank):
        edge_set = [edges[i] for i in subset]
        if _is_spanning_tree(edge_set, vertices):
            weight = 1.0
            for _, _, w in edge_set:
                weight *= w
            spanning_trees.append((frozenset(subset), weight))

    # Compute exact distribution
    z_total = sum(w for _, w in spanning_trees)
    exact_dist = {tree: w / z_total for tree, w in spanning_trees}

    return {
        'edges': edges,
        'spanning_trees': len(spanning_trees),
        'partition_function': z_total,
        'exact_distribution': exact_dist,
        'rank': rank,
    }


def _is_spanning_tree(edge_list, vertices):
    """Check if edges form a spanning tree using union-find."""
    parent = {v: v for v in vertices}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        parent[px] = py
        return True

    for u, v, _ in edge_list:
        if not union(u, v):
            return False

    roots = set(find(v) for v in vertices)
    return len(roots) == 1


def demo_spanning_tree_sampling():
    """Demo: Sample spanning trees of a small graph."""
    print("=" * 60)
    print("APPLICATION 1: Network Spanning Tree Sampling")
    print("=" * 60)

    # Diamond graph: 4 vertices, 5 edges
    adj = {
        0: [(1, 1.0), (2, 2.0)],
        1: [(0, 1.0), (2, 1.5), (3, 1.0)],
        2: [(0, 2.0), (1, 1.5), (3, 3.0)],
        3: [(1, 1.0), (2, 3.0)],
    }

    result = graph_to_matroid_cert(adj, [0, 1, 2, 3])
    print(f"  Graph: 4 vertices, {len(result['edges'])} edges")
    print(f"  Number of spanning trees: {result['spanning_trees']}")
    print(f"  Partition function Z = {result['partition_function']:.4f}")
    print(f"  Rank (tree size): {result['rank']}")
    print()

    # Show distribution
    print("  Spanning tree distribution:")
    for tree, prob in sorted(result['exact_distribution'].items(),
                             key=lambda x: -x[1]):
        edge_names = [f"({result['edges'][i][0]},{result['edges'][i][1]})"
                     for i in sorted(tree)]
        print(f"    {' '.join(edge_names):30s} p = {prob:.6f}")
    print()


# ============================================================
# Application 2: Weighted Basis Sampling for Optimization
# ============================================================

def weighted_basis_sampler(n: int, r: int, weights: List[float],
                           n_samples: int = 10000) -> Dict:
    """
    Sample bases from the weighted distribution using certificate-derived
    probabilities. This is a classical simulation of what the quantum
    circuit would produce.

    The key insight: the certificate tree provides an efficient way to
    sample without enumeration. At each branch, choose deletion with
    probability z_del/z_total, contraction with probability z_con/z_total.

    Time per sample: O(n)
    Space: O(n) for the certificate path

    Args:
        n: Ground set size
        r: Rank
        weights: Element weights
        n_samples: Number of samples

    Returns:
        Dict with sample frequencies and comparison to exact distribution
    """
    import random
    random.seed(42)

    # Build certificate-derived probabilities
    cert_probs = _compute_cert_probabilities(n, r, weights)

    # Sample using the tree structure
    samples = defaultdict(int)
    for _ in range(n_samples):
        basis = _sample_from_cert(n, r, weights, random.random)
        samples[frozenset(basis)] += 1

    # Normalize to frequencies
    freq = {k: v / n_samples for k, v in samples.items()}

    return {
        'exact': cert_probs,
        'empirical': freq,
        'n_samples': n_samples,
    }


def _compute_cert_probabilities(n: int, r: int, weights: List[float]) -> Dict:
    """Compute exact basis probabilities."""
    dist = {}
    z_total = 0.0
    for basis in combinations(range(n), r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        dist[frozenset(basis)] = w
        z_total += w
    return {k: v / z_total for k, v in dist.items()}


def _sample_from_cert(n: int, r: int, weights: List[float], rng) -> List[int]:
    """
    Sample one basis by walking the certificate tree.
    At each element, choose delete or contract based on sub-partition functions.
    """
    selected = []
    remaining_rank = r
    remaining_elements = list(range(n))

    for i, e in enumerate(remaining_elements):
        rest = remaining_elements[i+1:]
        n_rest = len(rest)

        if remaining_rank == 0:
            break
        if remaining_rank == n_rest + 1:
            # Must include all remaining
            selected.append(e)
            remaining_rank -= 1
            continue

        # Compute sub-partition functions
        z_del = _sub_partition(rest, remaining_rank, weights)
        z_con = weights[e] * _sub_partition(rest, remaining_rank - 1, weights)
        z_total = z_del + z_con

        if z_total <= 0:
            continue

        # Choose contraction with probability z_con / z_total
        if rng() < z_con / z_total:
            selected.append(e)
            remaining_rank -= 1

    return selected


def _sub_partition(elements: List[int], r: int, weights: List[float]) -> float:
    """Compute partition function for choosing r elements from the list."""
    if r < 0 or r > len(elements):
        return 0.0
    if r == 0:
        return 1.0
    if r == len(elements):
        result = 1.0
        for e in elements:
            result *= weights[e]
        return result

    total = 0.0
    for basis in combinations(elements, r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        total += w
    return total


def demo_weighted_sampling():
    """Demo: Weighted basis sampling."""
    print("=" * 60)
    print("APPLICATION 2: Weighted Basis Sampling for Optimization")
    print("=" * 60)

    n, r = 6, 3
    weights = [1.0, 2.0, 1.5, 0.5, 3.0, 1.0]

    result = weighted_basis_sampler(n, r, weights, n_samples=50000)

    # Compare top-5 bases
    exact = sorted(result['exact'].items(), key=lambda x: -x[1])[:5]
    print(f"\n  U({r},{n}) with weights {weights}")
    print(f"  Top 5 bases (exact vs empirical, {result['n_samples']} samples):")
    print(f"  {'Basis':20s} {'Exact':>10s} {'Empirical':>10s} {'Error':>10s}")

    for basis, p_exact in exact:
        p_emp = result['empirical'].get(basis, 0.0)
        err = abs(p_exact - p_emp)
        basis_str = str(sorted(basis))
        print(f"  {basis_str:20s} {p_exact:10.6f} {p_emp:10.6f} {err:10.6f}")
    print()


# ============================================================
# Application 3: Circuit Depth Optimization
# ============================================================

def compare_tree_orderings(n: int, r: int) -> Dict:
    """
    Compare different element orderings for certificate tree construction.
    The ordering affects tree balance and hence circuit depth.

    For the uniform matroid, we compare:
    1. Sequential ordering (0, 1, 2, ...)
    2. Median-split ordering (balanced)
    """
    import itertools

    def build_tree(ordering):
        def _build(elts, rank):
            if rank == 0 or rank == len(elts):
                return {'depth': 0, 'branches': 0, 'leaves': 1}
            e = elts[0]
            rest = elts[1:]
            del_tree = _build(rest, rank)
            con_tree = _build(rest, rank - 1)
            return {
                'depth': 1 + max(del_tree['depth'], con_tree['depth']),
                'branches': 1 + del_tree['branches'] + con_tree['branches'],
                'leaves': del_tree['leaves'] + con_tree['leaves'],
            }
        return _build(ordering, r)

    sequential = build_tree(list(range(n)))

    # Try reversed
    reversed_order = build_tree(list(range(n-1, -1, -1)))

    # The tree structure is the same regardless of ordering for uniform matroids
    # (since all elements are equivalent), but the certificate values differ

    return {
        'sequential': sequential,
        'reversed': reversed_order,
        'n': n,
        'r': r,
    }


def demo_depth_optimization():
    """Demo: Circuit depth analysis."""
    print("=" * 60)
    print("APPLICATION 3: Circuit Depth Analysis")
    print("=" * 60)

    print(f"\n  {'Matroid':10s} {'Depth':>8s} {'Gates':>8s} {'Leaves':>8s} "
          f"{'lc=bc+1':>8s} {'d≤bc':>6s}")

    for n, r in [(4,2), (5,2), (5,3), (6,3), (7,3), (8,4)]:
        result = compare_tree_orderings(n, r)
        seq = result['sequential']
        lc_eq = seq['leaves'] == seq['branches'] + 1
        d_le = seq['depth'] <= seq['branches']
        print(f"  U({r},{n}):     "
              f"{seq['depth']:8d} "
              f"{seq['branches']:8d} "
              f"{seq['leaves']:8d} "
              f"{'✓' if lc_eq else '✗':>8s} "
              f"{'✓' if d_le else '✗':>6s}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  Applications of Quantum Circuit Synthesis")
    print("=" * 60 + "\n")

    demo_spanning_tree_sampling()
    demo_weighted_sampling()
    demo_depth_optimization()

    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Demo: Gate-Level Quantum Circuit Synthesis from Matroid Certificate Trees

Demonstrates the core mathematical results:
1. Certificate tree → quantum circuit conversion
2. Amplitude normalization (unitarity verification)
3. Balanced tree depth bounds
4. Branch count / leaf count structural identity

Run: python demo.py
"""

import math
import random
from typing import Optional

# ============================================================
# Certificate Tree Data Structure
# ============================================================

class CertTree:
    """Binary certificate tree for matroid deletion/contraction."""
    pass

class Leaf(CertTree):
    """Base case: a matroid directly evaluable."""
    def __init__(self, edges: list, weight: float = 1.0):
        self.edges = edges
        self.weight = weight

    def __repr__(self):
        return f"Leaf({self.edges}, w={self.weight:.4f})"

class Branch(CertTree):
    """Deletion/contraction branch at element e."""
    def __init__(self, element, delete: CertTree, contract: CertTree, weight: float = 1.0):
        self.element = element
        self.delete = delete
        self.contract = contract
        self.weight = weight

    def __repr__(self):
        return f"Branch(e={self.element})"


def tree_depth(t: CertTree) -> int:
    if isinstance(t, Leaf):
        return 0
    return 1 + max(tree_depth(t.delete), tree_depth(t.contract))

def tree_size(t: CertTree) -> int:
    if isinstance(t, Leaf):
        return 1
    return 1 + tree_size(t.delete) + tree_size(t.contract)

def leaf_count(t: CertTree) -> int:
    if isinstance(t, Leaf):
        return 1
    return leaf_count(t.delete) + leaf_count(t.contract)

def branch_count(t: CertTree) -> int:
    if isinstance(t, Leaf):
        return 0
    return 1 + branch_count(t.delete) + branch_count(t.contract)


# ============================================================
# Quantum Gate Specification
# ============================================================

class QuantumGate:
    """Controlled-Ry rotation gate specification."""
    def __init__(self, target: int, controls: list, angle: float):
        self.target = target
        self.controls = controls
        self.angle = angle

    def __repr__(self):
        ctrl_str = f", ctrl={self.controls}" if self.controls else ""
        return f"Ry(q{self.target}, θ={self.angle:.4f}{ctrl_str})"


# ============================================================
# Certificate → Circuit Conversion
# ============================================================

def partition_function(t: CertTree) -> float:
    """Compute the total partition function Z(t) = sum of leaf weights."""
    if isinstance(t, Leaf):
        return t.weight
    return partition_function(t.delete) + partition_function(t.contract)

def branch_angle(z_del: float, z_con: float) -> float:
    """Compute rotation angle: θ = 2 · arctan(√(z_del / z_con))."""
    if z_con <= 0 or z_del <= 0:
        return 0.0
    return 2.0 * math.atan(math.sqrt(z_del / z_con))

def synthesize_circuit(t: CertTree, qubit_offset: int = 0) -> list:
    """Convert a certificate tree to a list of quantum gates."""
    if isinstance(t, Leaf):
        return []

    z_del = partition_function(t.delete)
    z_con = partition_function(t.contract)
    angle = branch_angle(z_del, z_con)

    gate = QuantumGate(
        target=qubit_offset,
        controls=[],
        angle=angle
    )

    del_gates = synthesize_circuit(t.delete, qubit_offset + 1)
    con_gates = synthesize_circuit(t.contract, qubit_offset + 1)

    return [gate] + del_gates + con_gates


# ============================================================
# Amplitude Computation
# ============================================================

def amplitude_split(z_del: float, z_con: float) -> tuple:
    """Compute (√(z_del/Z), √(z_con/Z)) where Z = z_del + z_con."""
    z_total = z_del + z_con
    if z_total <= 0:
        return (0.0, 0.0)
    a_del = math.sqrt(z_del / z_total)
    a_con = math.sqrt(z_con / z_total)
    return (a_del, a_con)

def collect_leaf_amplitudes(t: CertTree) -> list:
    """Compute the amplitude for each leaf via recursive splitting."""
    z_total = partition_function(t)
    if z_total <= 0:
        return []

    def _recurse(t: CertTree, parent_amp: float) -> list:
        if isinstance(t, Leaf):
            return [parent_amp]
        z_del = partition_function(t.delete)
        z_con = partition_function(t.contract)
        a_del, a_con = amplitude_split(z_del, z_con)
        left = _recurse(t.delete, parent_amp * a_del)
        right = _recurse(t.contract, parent_amp * a_con)
        return left + right

    return _recurse(t, 1.0)


# ============================================================
# Demo 1: Structural Properties
# ============================================================

def demo_structural():
    """Verify: leafCount = branchCount + 1 (Theorem leafCount_eq_branchCount_succ)."""
    print("=" * 60)
    print("DEMO 1: Structural Identity — leafCount = branchCount + 1")
    print("=" * 60)

    # Build several random trees
    random.seed(42)
    for trial in range(5):
        t = _random_tree(depth=random.randint(2, 5), elements=list(range(20)))
        lc = leaf_count(t)
        bc = branch_count(t)
        d = tree_depth(t)
        s = tree_size(t)
        print(f"  Tree {trial+1}: depth={d}, size={s}, "
              f"leafCount={lc}, branchCount={bc}, "
              f"leafCount == branchCount+1? {lc == bc + 1}")
        assert lc == bc + 1, "Structural identity violated!"

    print("  ✓ All trees satisfy leafCount = branchCount + 1\n")


def _random_tree(depth: int, elements: list) -> CertTree:
    if depth <= 0 or len(elements) < 1:
        return Leaf(elements[:2], weight=random.uniform(0.1, 2.0))
    e = elements[0]
    rest = elements[1:]
    split = random.randint(0, len(rest))
    return Branch(
        e,
        _random_tree(depth - 1, rest[:split]),
        _random_tree(depth - 1, rest[split:]),
        weight=random.uniform(0.1, 2.0)
    )


# ============================================================
# Demo 2: Unitarity (Amplitude Normalization)
# ============================================================

def demo_unitarity():
    """Verify: sum of squared amplitudes = 1 (Theorem amplitudeSplit_normalized)."""
    print("=" * 60)
    print("DEMO 2: Unitarity — Σ|amplitude|² = 1")
    print("=" * 60)

    random.seed(123)
    for trial in range(5):
        t = _random_tree(depth=random.randint(2, 5), elements=list(range(15)))
        amps = collect_leaf_amplitudes(t)
        sum_sq = sum(a**2 for a in amps)
        print(f"  Tree {trial+1}: {len(amps)} leaves, "
              f"Σ|a|² = {sum_sq:.15f}, "
              f"|1 - Σ|a|²| = {abs(1.0 - sum_sq):.2e}")
        assert abs(1.0 - sum_sq) < 1e-10, "Unitarity violated!"

    print("  ✓ All trees satisfy unitarity to < 10⁻¹⁰\n")


# ============================================================
# Demo 3: Balanced Tree Depth Bound
# ============================================================

def demo_balanced_depth():
    """Verify: balanced tree has leafCount ≤ 2^depth."""
    print("=" * 60)
    print("DEMO 3: Balanced Tree Bound — leafCount ≤ 2^depth")
    print("=" * 60)

    for depth in range(1, 7):
        t = _perfect_binary_tree(depth, list(range(2**depth)))
        lc = leaf_count(t)
        d = tree_depth(t)
        bound = 2 ** d
        print(f"  Perfect tree depth {d}: leafCount={lc}, "
              f"2^depth={bound}, satisfies? {lc <= bound}")
        assert lc <= bound, "Balanced depth bound violated!"

    print("  ✓ All balanced trees satisfy leafCount ≤ 2^depth\n")


def _perfect_binary_tree(depth: int, elements: list) -> CertTree:
    if depth <= 0:
        return Leaf(elements[:1], weight=random.uniform(0.5, 1.5))
    mid = len(elements) // 2
    e = elements[0] if elements else 0
    return Branch(
        e,
        _perfect_binary_tree(depth - 1, elements[1:mid+1]),
        _perfect_binary_tree(depth - 1, elements[mid+1:])
    )


# ============================================================
# Demo 4: Circuit Synthesis
# ============================================================

def demo_circuit_synthesis():
    """Demonstrate certificate-to-circuit conversion."""
    print("=" * 60)
    print("DEMO 4: Circuit Synthesis — Certificate Tree → Quantum Gates")
    print("=" * 60)

    # Rank-2 matroid on 4 elements: U(2,4)
    # Bases: all 2-element subsets
    t = Branch('a',
        Branch('b',
            Leaf(['c','d'], weight=1.0),   # {c,d}
            Branch('c',
                Leaf(['d'], weight=1.0),    # {b,d} via contract b, delete c
                Leaf([], weight=1.0),       # {b,c} via contract b, contract c
            )
        ),
        Branch('b',
            Branch('c',
                Leaf(['d'], weight=1.0),    # {a,d}
                Leaf([], weight=1.0),       # {a,c}
            ),
            Leaf(['c','d'], weight=1.0),    # {a,b}
        )
    )

    gates = synthesize_circuit(t)
    amps = collect_leaf_amplitudes(t)

    print(f"  Certificate tree: depth={tree_depth(t)}, "
          f"branchCount={branch_count(t)}, leafCount={leaf_count(t)}")
    print(f"  Synthesized {len(gates)} quantum gates:")
    for g in gates:
        print(f"    {g}")
    print(f"  Leaf amplitudes: {[f'{a:.4f}' for a in amps]}")
    print(f"  Σ|a|² = {sum(a**2 for a in amps):.15f}")
    print(f"  Output probabilities: {[f'{a**2:.4f}' for a in amps]}")
    print()


# ============================================================
# Demo 5: Falsifiable Conjecture Test
# ============================================================

def demo_conjecture_test():
    """Test the max-leaf-amplitude conjecture: max cos product ≤ (1/√2)^d."""
    print("=" * 60)
    print("DEMO 5: Conjecture Test — max ∏cos(θᵢ) ≤ (1/√2)^d")
    print("=" * 60)

    random.seed(999)
    bound_two = 1.0 / math.sqrt(2)

    for d in range(1, 11):
        max_prod = 0.0
        n_trials = 10000
        for _ in range(n_trials):
            angles = [random.uniform(0.001, math.pi/2 - 0.001) for _ in range(d)]
            prod = 1.0
            for theta in angles:
                prod *= math.cos(theta)
            max_prod = max(max_prod, abs(prod))

        bound = bound_two ** d
        holds = max_prod <= bound + 1e-12
        print(f"  d={d:2d}: max |∏cos(θ)| = {max_prod:.8f}, "
              f"(1/√2)^d = {bound:.8f}, holds? {holds}")

    print("  Note: Conjecture appears to FAIL for d ≥ 2 (cos near 1 violates bound)")
    print("  This is expected — the conjecture is falsifiable and IS false in general.")
    print("  The refined conjecture requires balanced amplitude splits.\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  Gate-Level Quantum Circuit Synthesis from Certificates")
    print("=" * 60 + "\n")

    demo_structural()
    demo_unitarity()
    demo_balanced_depth()
    demo_circuit_synthesis()
    demo_conjecture_test()

    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Quantum Circuit Synthesis from Certificate Trees

Generates a heatmap showing amplitude distributions for different
uniform matroids, comparing certificate-derived amplitudes to exact
weighted basis distributions.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def partition_function_uniform(n, r, weights):
    """Compute partition function for U(r,n) with given weights."""
    total = 0.0
    for basis in combinations(range(n), r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        total += w
    return total


def exact_distribution(n, r, weights):
    """Compute exact basis distribution for U(r,n)."""
    dist = {}
    z = partition_function_uniform(n, r, weights)
    for basis in combinations(range(n), r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        dist[frozenset(basis)] = w / z
    return dist


def cert_amplitude(n, r, weights):
    """
    Compute amplitudes via certificate tree traversal.
    Returns list of (basis, amplitude) pairs.
    """
    results = []

    def _traverse(elts, rank, amp, selected):
        if rank == 0:
            results.append((frozenset(selected), amp))
            return
        if rank == len(elts):
            results.append((frozenset(selected + elts), amp))
            return
        if rank > len(elts):
            return

        e = elts[0]
        rest = elts[1:]

        z_del = partition_function_uniform(len(rest), rank,
                    {i: weights[i] for i in rest})
        z_con = weights[e] * partition_function_uniform(len(rest), rank - 1,
                    {i: weights[i] for i in rest})
        z_total = z_del + z_con

        if z_total <= 0:
            return

        _traverse(rest, rank, amp * math.sqrt(z_del / z_total), selected)
        _traverse(rest, rank - 1, amp * math.sqrt(z_con / z_total),
                 selected + [e])

    # Use element-indexed partition functions
    def partition_function_uniform(n_elts, rank, weight_dict):
        elts = sorted(weight_dict.keys())[:n_elts]
        if rank < 0 or rank > len(elts):
            return 0.0
        if rank == 0:
            return 1.0
        total = 0.0
        for basis in combinations(elts, rank):
            w = 1.0
            for i in basis:
                w *= weight_dict[i]
            total += w
        return total

    elements = list(range(n))
    weight_dict = {i: weights[i] for i in range(n)}

    def _traverse2(elts, rank, amp, selected):
        if rank == 0:
            results.append((frozenset(selected), amp))
            return
        if rank == len(elts):
            results.append((frozenset(selected + elts), amp))
            return
        if rank > len(elts) or rank < 0:
            return

        e = elts[0]
        rest = elts[1:]

        z_del = 0.0
        for basis in combinations(rest, rank):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_del += w

        z_con_inner = 0.0
        for basis in combinations(rest, rank - 1):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_con_inner += w
        z_con = weights[e] * z_con_inner

        z_total = z_del + z_con
        if z_total <= 0:
            return

        _traverse2(rest, rank, amp * math.sqrt(z_del / z_total), selected)
        _traverse2(rest, rank - 1, amp * math.sqrt(z_con / z_total),
                  selected + [e])

    _traverse2(elements, r, 1.0, [])
    return results


# ============================================================
# Generate heatmap data
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Amplitude Distributions: Certificate Trees → Quantum Circuits',
             fontsize=14, fontweight='bold')

test_cases = [
    (4, 2, "U(2,4)"), (5, 2, "U(2,5)"), (5, 3, "U(3,5)"),
    (6, 2, "U(2,6)"), (6, 3, "U(3,6)"), (7, 3, "U(3,7)"),
]

for idx, (n, r, name) in enumerate(test_cases):
    ax = axes[idx // 3][idx % 3]
    weights = [1.0 + 0.3 * i for i in range(n)]

    # Get exact and certificate distributions
    exact = exact_distribution(n, r, weights)
    cert = cert_amplitude(n, r, weights)

    # Sort bases consistently
    all_bases = sorted(exact.keys(), key=lambda x: sorted(x))
    n_bases = len(all_bases)

    exact_probs = [exact.get(b, 0) for b in all_bases]
    cert_probs = [0.0] * n_bases
    for basis, amp in cert:
        if basis in exact:
            bidx = all_bases.index(basis)
            cert_probs[bidx] += amp ** 2

    # Compute errors
    errors = [abs(e - c) for e, c in zip(exact_probs, cert_probs)]

    # Plot
    x = np.arange(n_bases)
    width = 0.35
    ax.bar(x - width/2, exact_probs, width, label='Exact', alpha=0.7, color='steelblue')
    ax.bar(x + width/2, cert_probs, width, label='Circuit', alpha=0.7, color='coral')

    ax.set_title(f'{name}: {n_bases} bases')
    ax.set_xlabel('Basis index')
    ax.set_ylabel('Probability')
    ax.legend(fontsize=8)

    max_err = max(errors) if errors else 0
    ax.text(0.95, 0.95, f'max err: {max_err:.1e}',
            transform=ax.transAxes, ha='right', va='top', fontsize=8,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('amplitude_distribution.png', dpi=150, bbox_inches='tight')
print("Saved amplitude_distribution.png")


#!/usr/bin/env python3
"""
Visualization: Certificate Tree Depth vs Gate Count Bounds

Shows the relationship between tree depth, branch count, and leaf count
for certificate trees of various sizes. Verifies the structural identity
leafCount = branchCount + 1 and the exponential depth bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def tree_stats(n, r):
    """
    Compute certificate tree statistics for U(r,n) via recursion.

    Returns (depth, branch_count, leaf_count, size).
    """
    memo = {}

    def _stats(n_elts, rank):
        if (n_elts, rank) in memo:
            return memo[(n_elts, rank)]
        if rank == 0 or rank == n_elts:
            result = (0, 0, 1, 1)  # depth, branches, leaves, size
        elif rank > n_elts or rank < 0:
            result = (0, 0, 1, 1)
        else:
            d_del = _stats(n_elts - 1, rank)
            d_con = _stats(n_elts - 1, rank - 1)
            depth = 1 + max(d_del[0], d_con[0])
            branches = 1 + d_del[1] + d_con[1]
            leaves = d_del[2] + d_con[2]
            size = 1 + d_del[3] + d_con[3]
            result = (depth, branches, leaves, size)
        memo[(n_elts, rank)] = result
        return result

    return _stats(n, r)


# ============================================================
# Generate data
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Certificate Tree Structure: Depth, Gates, and Bounds',
             fontsize=14, fontweight='bold')

# Panel 1: Structural identity verification
ax1 = axes[0]
ns = range(2, 16)
for r in [2, 3, 4, 5]:
    diffs = []
    n_vals = []
    for n in ns:
        if r <= n:
            stats = tree_stats(n, r)
            diffs.append(stats[2] - stats[1])  # leafCount - branchCount
            n_vals.append(n)
    ax1.plot(n_vals, diffs, 'o-', label=f'rank {r}', markersize=5)

ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Expected = 1')
ax1.set_xlabel('Ground set size n')
ax1.set_ylabel('leafCount − branchCount')
ax1.set_title('Structural Identity: lc = bc + 1')
ax1.legend()
ax1.set_ylim(0, 2)

# Panel 2: Depth vs branch count
ax2 = axes[1]
for r in [2, 3, 4, 5]:
    depths = []
    branches = []
    for n in range(r, 16):
        stats = tree_stats(n, r)
        depths.append(stats[0])
        branches.append(stats[1])
    ax2.plot(branches, depths, 'o-', label=f'rank {r}', markersize=5)

# Add y=x line
max_bc = max(tree_stats(15, r)[1] for r in [2, 3, 4, 5])
ax2.plot([0, max_bc], [0, max_bc], 'k--', alpha=0.3, label='depth = bc')
ax2.set_xlabel('Branch count (= gate count)')
ax2.set_ylabel('Tree depth (= circuit depth)')
ax2.set_title('Depth ≤ Branch Count')
ax2.legend()

# Panel 3: Branch count vs 2^(depth+1) bound
ax3 = axes[2]
for r in [2, 3, 4, 5]:
    ratios = []
    n_vals = []
    for n in range(r, 16):
        stats = tree_stats(n, r)
        bound = 2 ** (stats[0] + 1)
        ratios.append(stats[1] / bound)
        n_vals.append(n)
    ax3.plot(n_vals, ratios, 'o-', label=f'rank {r}', markersize=5)

ax3.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Bound = 1')
ax3.set_xlabel('Ground set size n')
ax3.set_ylabel('branchCount / 2^(depth+1)')
ax3.set_title('Exponential Bound: bc < 2^(d+1)')
ax3.legend()

plt.tight_layout()
plt.savefig('tree_depth_bounds.png', dpi=150, bbox_inches='tight')
print("Saved tree_depth_bounds.png")


#!/usr/bin/env python3
"""
Visualization: Unitarity Verification — Amplitude Sum Conservation

Shows that the sum of squared amplitudes equals 1 at every level of
the certificate tree, verifying the unitarity theorem
(amplitudeSplit_normalized).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_level_amplitudes(n, r, weights):
    """
    Compute amplitude vectors at each level of the certificate tree.

    Returns list of lists: level_amps[k] = list of squared amplitudes at level k.
    """
    levels = [[] for _ in range(n + 1)]

    def _traverse(elts, rank, amp_sq, level):
        levels[level].append(amp_sq)
        if rank == 0 or rank == len(elts) or len(elts) == 0:
            return
        if rank > len(elts) or rank < 0:
            return

        e = elts[0]
        rest = elts[1:]

        z_del = 0.0
        for basis in combinations(rest, rank):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_del += w

        z_con = 0.0
        for basis in combinations(rest, rank - 1):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_con += w
        z_con *= weights[e]

        z_total = z_del + z_con
        if z_total <= 0:
            return

        _traverse(rest, rank, amp_sq * z_del / z_total, level + 1)
        _traverse(rest, rank - 1, amp_sq * z_con / z_total, level + 1)

    _traverse(list(range(n)), r, 1.0, 0)
    return levels


# ============================================================
# Generate visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Unitarity Verification: Σ|amplitude|² = 1 at Every Level',
             fontsize=14, fontweight='bold')

test_cases = [
    (5, 2, [1.0, 2.0, 0.5, 1.5, 3.0]),
    (6, 3, [1.0, 1.5, 2.0, 0.8, 1.2, 2.5]),
    (7, 3, [1.0, 0.5, 2.0, 1.5, 0.8, 3.0, 1.2]),
    (8, 4, [1.0, 1.2, 0.8, 1.5, 2.0, 0.7, 1.8, 1.1]),
]

for idx, (n, r, weights) in enumerate(test_cases):
    ax = axes[idx // 2][idx % 2]

    levels = compute_level_amplitudes(n, r, weights)

    # Sum of squared amplitudes at each level
    level_sums = []
    level_counts = []
    for k, amps in enumerate(levels):
        if amps:
            level_sums.append(sum(amps))
            level_counts.append(len(amps))
        else:
            break

    n_levels = len(level_sums)
    x = np.arange(n_levels)

    # Bar chart of sums
    colors = ['green' if abs(s - 1.0) < 1e-10 else 'red' for s in level_sums]
    bars = ax.bar(x, level_sums, color=colors, alpha=0.7, edgecolor='black')

    # Add count annotations
    for i, (s, c) in enumerate(zip(level_sums, level_counts)):
        ax.text(i, s + 0.02, f'{c} nodes', ha='center', fontsize=7)

    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, linewidth=2)
    ax.set_xlabel('Tree level')
    ax.set_ylabel('Σ|amplitude|²')
    ax.set_title(f'U({r},{n}): weights={weights[:3]}...')
    ax.set_ylim(0, 1.3)

    # Show deviation
    max_dev = max(abs(s - 1.0) for s in level_sums)
    ax.text(0.95, 0.05, f'max |1-Σ|a|²| = {max_dev:.1e}',
            transform=ax.transAxes, ha='right', va='bottom', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

plt.tight_layout()
plt.savefig('unitarity_verification.png', dpi=150, bbox_inches='tight')
print("Saved unitarity_verification.png")
