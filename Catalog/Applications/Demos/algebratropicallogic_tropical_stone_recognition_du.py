#!/usr/bin/env python3
"""
Applications of Tropical Stone Recognition Duality

Demonstrates real-world applications:
1. Shortest path compression via spectral duality
2. ReLU network state space analysis
3. Tropical language recognition examples
"""

from typing import List, Dict, Tuple, Set, FrozenSet
from itertools import product


INF = float('inf')


# ============================================================
# §1. Shortest Path Algebras and Spectral Compression
# ============================================================

def shortest_paths(adj: List[List[float]]) -> List[List[float]]:
    """Compute all-pairs shortest paths (Floyd-Warshall = tropical matrix power)."""
    n = len(adj)
    dist = [row[:] for row in adj]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    return dist


def identify_redundant_vertices(adj: List[List[float]]) -> List[Set[int]]:
    """Identify vertices that are "tropically equivalent" — they have
    identical shortest-path profiles to all other vertices.

    Two vertices u, v are equivalent if:
      d(u, w) = d(v, w) and d(w, u) = d(w, v) for all vertices w.

    This is the congruence induced by the shortest-path algebra.
    """
    n = len(adj)
    dist = shortest_paths(adj)

    # Compute profile for each vertex
    profiles: Dict[tuple, Set[int]] = {}
    for v in range(n):
        profile = tuple(dist[v]) + tuple(dist[w][v] for w in range(n))
        if profile not in profiles:
            profiles[profile] = set()
        profiles[profile].add(v)

    return [group for group in profiles.values() if len(group) > 1]


def demo_shortest_path():
    """Demo: shortest path compression."""
    print("="*60)
    print("  SHORTEST PATH SPECTRAL COMPRESSION")
    print("="*60)

    # Graph with redundant vertices (symmetric paths)
    # Vertices: 0, 1, 2, 3, 4
    # Edges: 0-1(1), 0-2(1), 1-3(2), 2-3(2), 3-4(1)
    # Vertices 1 and 2 are symmetric
    adj = [
        [0,   1,   1,   INF, INF],
        [1,   0,   INF, 2,   INF],
        [1,   INF, 0,   2,   INF],
        [INF, 2,   2,   0,   1  ],
        [INF, INF, INF, 1,   0  ],
    ]

    print("\n  Graph (5 vertices, undirected):")
    print("    0 --1-- 1 --2-- 3 --1-- 4")
    print("    |               |")
    print("    1               2")
    print("    |               |")
    print("    +------ 2 ------+")

    dist = shortest_paths(adj)
    print("\n  All-pairs shortest distances:")
    header = "     " + "  ".join(f"{j:3d}" for j in range(5))
    print(f"    {header}")
    for i in range(5):
        row = "  ".join(f"{dist[i][j]:3.0f}" if dist[i][j] < INF else "inf"
                       for j in range(5))
        print(f"    {i}:  {row}")

    equiv = identify_redundant_vertices(adj)
    if equiv:
        print(f"\n  Equivalent vertex groups (same shortest-path profile):")
        for group in equiv:
            print(f"    {group}")
        print(f"  → Can compress graph from 5 to {5 - sum(len(g)-1 for g in equiv)} vertices")
    else:
        print("\n  No equivalent vertices found (graph is already minimal).")


# ============================================================
# §2. ReLU Network State Space Analysis
# ============================================================

def relu(x: float) -> float:
    """ReLU activation: max(0, x) = tropical addition with 0."""
    return max(0.0, x)


def analyze_relu_patterns(weights: List[List[float]],
                          biases: List[float],
                          inputs: List[List[float]]) -> Dict[tuple, List[int]]:
    """Analyze activation patterns of a ReLU layer.

    For each input, compute which neurons are active (output > 0).
    Group inputs by their activation pattern.

    The number of distinct patterns is the "tropical state count"
    of the network layer.
    """
    patterns: Dict[tuple, List[int]] = {}
    n_neurons = len(weights)

    for idx, x in enumerate(inputs):
        # Compute pre-activation
        pre = [sum(w * xi for w, xi in zip(weights[j], x)) + biases[j]
               for j in range(n_neurons)]
        # Activation pattern: which neurons fire?
        pattern = tuple(1 if p > 0 else 0 for p in pre)
        if pattern not in patterns:
            patterns[pattern] = []
        patterns[pattern].append(idx)

    return patterns


def demo_relu():
    """Demo: ReLU activation pattern analysis."""
    print("\n" + "="*60)
    print("  ReLU NETWORK TROPICAL STATE SPACE ANALYSIS")
    print("="*60)

    # Simple 2-input, 4-neuron ReLU layer
    weights = [
        [1.0, 0.0],   # neuron 0: responds to x₁
        [0.0, 1.0],   # neuron 1: responds to x₂
        [1.0, -1.0],  # neuron 2: responds to x₁ - x₂
        [-1.0, 1.0],  # neuron 3: responds to x₂ - x₁
    ]
    biases = [0.0, 0.0, 0.0, 0.0]

    print(f"\n  ReLU layer: 2 inputs, {len(weights)} neurons")
    print("  Neuron 0: ReLU(x₁)")
    print("  Neuron 1: ReLU(x₂)")
    print("  Neuron 2: ReLU(x₁ - x₂)")
    print("  Neuron 3: ReLU(x₂ - x₁)")

    # Sample inputs on a grid
    grid = []
    for x1 in [-2, -1, 0, 1, 2]:
        for x2 in [-2, -1, 0, 1, 2]:
            grid.append([float(x1), float(x2)])

    patterns = analyze_relu_patterns(weights, biases, grid)

    print(f"\n  {len(grid)} sample inputs → {len(patterns)} distinct activation patterns")
    print(f"  Maximum possible patterns: 2^{len(weights)} = {2**len(weights)}")
    print(f"\n  Activation patterns (which neurons fire):")
    for pattern, inputs_list in sorted(patterns.items()):
        active = [i for i, p in enumerate(pattern) if p == 1]
        n_inputs = len(inputs_list)
        sample = grid[inputs_list[0]]
        print(f"    Pattern {pattern}: {n_inputs} inputs, "
              f"active neurons: {active}, e.g. ({sample[0]}, {sample[1]})")

    # The tropical state space size
    print(f"\n  Tropical state space size: {len(patterns)}")
    print(f"  This is the number of linear regions of the piecewise-linear function.")
    print(f"  The spectral duality identifies the minimal representation:")
    print(f"  equivalent patterns (same tropical congruence class) can be merged.")

    # Check for equivalent patterns
    # Two patterns are equivalent if they give the same output mapping
    output_groups: Dict[tuple, List[tuple]] = {}
    for pattern in patterns:
        # The output of this region is determined by the active neurons
        # For our simple network, the output function in each region is linear
        active = tuple(i for i, p in enumerate(pattern) if p == 1)
        if active not in output_groups:
            output_groups[active] = []
        output_groups[active].append(pattern)

    if any(len(v) > 1 for v in output_groups.values()):
        print(f"\n  Equivalent pattern groups found! Compression possible.")
    else:
        print(f"\n  All patterns produce distinct outputs. Network is already minimal.")


# ============================================================
# §3. Tropical Language Recognition
# ============================================================

def demo_tropical_language():
    """Demo: tropical language recognition with idempotent semirings."""
    print("\n" + "="*60)
    print("  TROPICAL LANGUAGE RECOGNITION")
    print("="*60)

    # Define a simple tropical recognizer over alphabet {a, b}
    # States: {0, 1, 2} with max as addition, min as multiplication
    # This recognizes the "shortest distance" of a word from a pattern

    print("\n  Alphabet: {a, b}")
    print("  Semiring: ({0, 1, 2, ∞}, min, +)")
    print("  Interpretation: a ↦ 1, b ↦ 2")
    print("  Accept: weight ≤ 3")
    print()

    # Word weight = sum of letter weights (tropical product)
    def word_weight(word: str) -> int:
        return sum(1 if c == 'a' else 2 for c in word)

    print("  Word weights and acceptance:")
    test_words = ['', 'a', 'b', 'aa', 'ab', 'ba', 'bb', 'aaa', 'aab', 'aba', 'baa', 'abb']
    for w in test_words:
        wt = word_weight(w) if w else 0
        accepted = wt <= 3
        print(f"    '{w}' → weight {wt}, {'accepted ✓' if accepted else 'rejected ✗'}")

    # The syntactic congruence: u ~ v iff for all contexts (l, r),
    # weight(lur) ≤ 3 iff weight(lvr) ≤ 3
    # Since weight is additive, u ~ v iff weight(u) = weight(v)
    print(f"\n  Syntactic congruence classes (by weight):")
    from collections import defaultdict
    classes = defaultdict(list)
    all_words = [''] + [c1 + c2 for c1 in 'ab' for c2 in ['', 'a', 'b']] + \
                ['aaa', 'aab', 'aba', 'baa']
    for w in sorted(set(all_words), key=lambda x: (len(x), x)):
        wt = word_weight(w) if w else 0
        classes[wt].append(w)

    for wt in sorted(classes.keys()):
        words = classes[wt]
        print(f"    Weight {wt}: {words}")

    print(f"\n  Number of congruence classes: {len(classes)}")
    print(f"  This is the size of the minimal tropical recognizer.")
    print(f"  The spectral duality tells us this is also the number of")
    print(f"  prime congruences in the upper-set algebra of the spectrum.")


# ============================================================
# §4. Main
# ============================================================

if __name__ == "__main__":
    demo_shortest_path()
    demo_relu()
    demo_tropical_language()


#!/usr/bin/env python3
"""
Tropical Stone Recognition Duality — Interactive Demo

Demonstrates the core constructions of the tropical Stone recognition duality:
1. Upper-set computation for finite posets
2. Principal upper set embedding (Stone representation)
3. Idempotent semiring verification
4. Spectral reconstruction and minimization
5. Concrete examples on small posets

All computations are exact (no floating point).
"""

from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict
import json


# ============================================================
# §1. Finite Posets
# ============================================================

class FinitePoset:
    """A finite partially ordered set, represented by elements and a relation."""

    def __init__(self, elements: List[str], le_pairs: List[Tuple[str, str]]):
        """
        Args:
            elements: list of element names
            le_pairs: list of (a, b) meaning a ≤ b
        """
        self.elements = list(elements)
        self.n = len(self.elements)
        # Build the partial order relation (reflexive, transitive closure)
        self._le = set()
        for x in self.elements:
            self._le.add((x, x))  # reflexive
        for a, b in le_pairs:
            self._le.add((a, b))
        # Transitive closure
        changed = True
        while changed:
            changed = False
            for a, b in list(self._le):
                for c, d in list(self._le):
                    if b == c and (a, d) not in self._le:
                        self._le.add((a, d))
                        changed = True

    def le(self, a: str, b: str) -> bool:
        return (a, b) in self._le

    def __repr__(self):
        covers = [(a, b) for a, b in self._le
                  if a != b and not any(
                      self.le(a, c) and self.le(c, b) and c != a and c != b
                      for c in self.elements)]
        return f"Poset({self.elements}, covers={covers})"


# ============================================================
# §2. Upper Sets
# ============================================================

def compute_upper_sets(poset: FinitePoset) -> List[FrozenSet[str]]:
    """Compute all upper sets (upward-closed subsets) of a finite poset."""
    upper_sets = []
    for r in range(len(poset.elements) + 1):
        for subset in combinations(poset.elements, r):
            s = set(subset)
            # Check upper-closure: if x in s and x ≤ y, then y in s
            is_upper = True
            for x in s:
                for y in poset.elements:
                    if poset.le(x, y) and y not in s:
                        is_upper = False
                        break
                if not is_upper:
                    break
            if is_upper:
                upper_sets.append(frozenset(s))
    return sorted(upper_sets, key=lambda s: (len(s), sorted(s)))


def principal_upper_set(poset: FinitePoset, x: str) -> FrozenSet[str]:
    """Compute the principal upper set ↑x = {y | x ≤ y}."""
    return frozenset(y for y in poset.elements if poset.le(x, y))


# ============================================================
# §3. Idempotent Semiring Operations
# ============================================================

class UpperSetSemiring:
    """The idempotent semiring of upper sets of a finite poset."""

    def __init__(self, poset: FinitePoset):
        self.poset = poset
        self.upper_sets = compute_upper_sets(poset)
        self.zero = frozenset()  # empty set
        self.one = frozenset(poset.elements)  # full set

    def add(self, u: FrozenSet, v: FrozenSet) -> FrozenSet:
        """Addition = union."""
        return u | v

    def mul(self, u: FrozenSet, v: FrozenSet) -> FrozenSet:
        """Multiplication = intersection."""
        return u & v

    def verify_idempotent_semiring(self) -> Dict[str, bool]:
        """Verify all idempotent semiring axioms."""
        us = self.upper_sets
        results = {}

        # Additive idempotence
        results['add_idempotent'] = all(self.add(u, u) == u for u in us)

        # Multiplicative idempotence
        results['mul_idempotent'] = all(self.mul(u, u) == u for u in us)

        # Commutativity
        results['add_commutative'] = all(
            self.add(u, v) == self.add(v, u) for u in us for v in us)
        results['mul_commutative'] = all(
            self.mul(u, v) == self.mul(v, u) for u in us for v in us)

        # Associativity
        results['add_associative'] = all(
            self.add(self.add(u, v), w) == self.add(u, self.add(v, w))
            for u in us for v in us for w in us)
        results['mul_associative'] = all(
            self.mul(self.mul(u, v), w) == self.mul(u, self.mul(v, w))
            for u in us for v in us for w in us)

        # Distributivity
        results['left_distributive'] = all(
            self.mul(u, self.add(v, w)) == self.add(self.mul(u, v), self.mul(u, w))
            for u in us for v in us for w in us)

        # Identity elements
        results['zero_identity'] = all(self.add(self.zero, u) == u for u in us)
        results['one_identity'] = all(self.mul(self.one, u) == u for u in us)

        # Zero annihilation
        results['zero_annihilates'] = all(self.mul(self.zero, u) == self.zero for u in us)

        # Absorption
        results['absorption'] = all(
            self.mul(u, self.add(u, v)) == u for u in us for v in us)
        results['dual_absorption'] = all(
            self.add(u, self.mul(u, v)) == u for u in us for v in us)

        return results

    def verify_stone_embedding(self) -> Dict[str, bool]:
        """Verify the Stone embedding properties."""
        elems = self.poset.elements
        results = {}

        # Compute principal upper sets
        principals = {x: principal_upper_set(self.poset, x) for x in elems}

        # Injectivity
        results['injective'] = len(set(principals.values())) == len(elems)

        # Contravariant order
        order_correct = True
        for x in elems:
            for y in elems:
                xy_le = self.poset.le(x, y)
                py_subset_px = principals[y].issubset(principals[x])
                if xy_le != py_subset_px:
                    order_correct = False
                    break
        results['contravariant_order'] = order_correct

        # Basis decomposition: every upper set is a union of principal upper sets
        basis_ok = True
        for u in self.upper_sets:
            reconstructed = frozenset().union(*(principals[x] for x in u)) if u else frozenset()
            if reconstructed != u:
                basis_ok = False
                break
        results['basis_decomposition'] = basis_ok

        return results


# ============================================================
# §4. Concrete Examples
# ============================================================

def demo_poset(name: str, poset: FinitePoset):
    """Run full demo on a poset."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    print(f"  Poset: {poset}")
    print(f"  Elements: {poset.elements}")

    semiring = UpperSetSemiring(poset)
    print(f"\n  Upper sets ({len(semiring.upper_sets)} total):")
    for i, u in enumerate(semiring.upper_sets):
        print(f"    U{i}: {set(u) if u else '∅'}")

    # Principal upper sets
    print(f"\n  Principal upper sets (Stone embedding):")
    for x in poset.elements:
        pu = principal_upper_set(poset, x)
        print(f"    ↑{x} = {set(pu)}")

    # Verify axioms
    axioms = semiring.verify_idempotent_semiring()
    print(f"\n  Semiring axiom verification:")
    for name_ax, ok in axioms.items():
        print(f"    {name_ax}: {'✓' if ok else '✗'}")

    # Verify Stone embedding
    stone = semiring.verify_stone_embedding()
    print(f"\n  Stone embedding verification:")
    for name_st, ok in stone.items():
        print(f"    {name_st}: {'✓' if ok else '✗'}")

    return semiring


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL STONE RECOGNITION DUALITY — INTERACTIVE DEMO ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Example 1: Singleton poset
    singleton = FinitePoset(['a'], [])
    demo_poset("Singleton Poset (1 element)", singleton)

    # Example 2: Two-element chain
    chain2 = FinitePoset(['0', '1'], [('0', '1')])
    demo_poset("2-Element Chain (0 ≤ 1)", chain2)

    # Example 3: Two-element antichain
    anti2 = FinitePoset(['a', 'b'], [])
    demo_poset("2-Element Antichain", anti2)

    # Example 4: Three-element chain
    chain3 = FinitePoset(['0', '1', '2'], [('0', '1'), ('1', '2')])
    demo_poset("3-Element Chain (0 ≤ 1 ≤ 2)", chain3)

    # Example 5: Diamond lattice
    diamond = FinitePoset(['bot', 'a', 'b', 'top'],
                          [('bot', 'a'), ('bot', 'b'), ('a', 'top'), ('b', 'top')])
    demo_poset("Diamond Lattice (4 elements)", diamond)

    # Example 6: Pentagon (non-modular)
    pentagon = FinitePoset(['0', 'a', 'b', 'c', '1'],
                           [('0', 'a'), ('0', 'b'), ('a', 'c'), ('c', '1'), ('b', '1')])
    demo_poset("Pentagon (N₅, 5 elements)", pentagon)

    # Summary
    print("\n" + "="*60)
    print("  SUMMARY: Upper-set counts for small posets")
    print("="*60)

    test_cases = [
        ("Empty", FinitePoset([], []), 1),
        ("Singleton", singleton, 2),
        ("2-chain", chain2, 3),
        ("2-antichain", anti2, 4),
        ("3-chain", chain3, 4),
        ("3-antichain", FinitePoset(['a', 'b', 'c'], []), 8),
        ("Diamond", diamond, 6),
        ("Pentagon", pentagon, 8),
    ]

    print(f"  {'Poset':<15} {'|X|':>4} {'|UpperSets|':>12} {'Expected':>10} {'Match':>6}")
    print(f"  {'-'*50}")
    for name, poset, expected in test_cases:
        us = compute_upper_sets(poset)
        match = "✓" if len(us) == expected else "✗"
        print(f"  {name:<15} {poset.n:>4} {len(us):>12} {expected:>10} {match:>6}")

    # Tropical arithmetic demo
    print("\n" + "="*60)
    print("  TROPICAL ARITHMETIC DEMO")
    print("="*60)
    print("  In tropical arithmetic: a ⊕ b = min(a,b), a ⊗ b = a + b")
    print("  Key property: a ⊕ a = min(a,a) = a (idempotent!)")
    print()
    for a in [1, 3, 5]:
        for b in [2, 4, 6]:
            trop_add = min(a, b)
            trop_mul = a + b
            print(f"  {a} ⊕ {b} = min({a},{b}) = {trop_add}    "
                  f"{a} ⊗ {b} = {a}+{b} = {trop_mul}")

    print("\n  Idempotence check:")
    for a in [1, 3, 7, 42]:
        print(f"    {a} ⊕ {a} = min({a},{a}) = {min(a,a)} = {a} ✓")

    print("\n  Tropical distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)")
    for a, b, c in [(2, 3, 5), (1, 4, 2), (3, 1, 7)]:
        lhs = a + min(b, c)
        rhs = min(a + b, a + c)
        ok = "✓" if lhs == rhs else "✗"
        print(f"    {a} ⊗ ({b} ⊕ {c}) = {a}+min({b},{c}) = {lhs}  |  "
              f"({a}⊗{b}) ⊕ ({a}⊗{c}) = min({a+b},{a+c}) = {rhs}  {ok}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import main as gen_viz

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Generate visualizations
    viz_data = gen_viz()

    # Read all text files
    article = read_file('ARTICLE.md')
    paper = read_file('RESEARCH_PAPER.md')
    future = read_file('FUTURE_DIRECTIONS.md')
    lean_code = read_file('Bridges/AlgebraTropicalLogic/TropicalStoneRecognitionDuality.lean')
    demo_code = read_file('demo.py')
    algo_code = read_file('algorithms.py')
    app_code = read_file('applications.py')

    package = {
        "title": "Tropical Stone Recognition Duality via Idempotent Congruence Spectra",
        "domain": "Algebra–Tropical–Logic Bridge",
        "article": article,
        "research_paper": paper,
        "future_directions": future,
        "demos": [
            {
                "name": "Tropical Stone Duality Demo",
                "code": demo_code
            },
            {
                "name": "Applications: Shortest Paths, ReLU Networks, Language Recognition",
                "code": app_code
            }
        ],
        "algorithms": [
            {
                "name": "Upper-Set Enumeration",
                "pseudocode": (
                    "Algorithm: UpperSetEnumeration(X, ≤)\n"
                    "Input: Finite poset (X, ≤)\n"
                    "Output: Set of all upper sets\n\n"
                    "1. For each subset S ⊆ X:\n"
                    "2.   If ∀x ∈ S, ∀y ∈ X: x ≤ y → y ∈ S:\n"
                    "3.     Add S to output\n"
                    "4. Return output\n\n"
                    "Time: O(2^n · n²)  Space: O(2^n · n)"
                ),
                "code": algo_code
            },
            {
                "name": "Partition Refinement Minimization",
                "pseudocode": (
                    "Algorithm: PartitionRefinement(A)\n"
                    "Input: Tropical automaton A with n states\n"
                    "Output: Minimal equivalent automaton\n\n"
                    "1. Initialize partition Π by final weights\n"
                    "2. Repeat:\n"
                    "3.   For each block B in Π:\n"
                    "4.     Compute transition signature for each state\n"
                    "5.     Split B into sub-blocks by signature\n"
                    "6.   Until no splits occur\n"
                    "7. Build quotient automaton from Π\n\n"
                    "Time: O(n² |Σ| log n)  Space: O(n² |Σ|)"
                ),
                "code": algo_code
            }
        ],
        "visualizations": [
            {
                "name": "Upper-Set Lattice for 2-Chain",
                "data": viz_data['upper_set_lattice']
            },
            {
                "name": "Stone Embedding (Diamond Poset)",
                "data": viz_data['stone_embedding']
            },
            {
                "name": "Duality Diagram",
                "data": viz_data['duality_diagram']
            },
            {
                "name": "Upper-Set Counts for Small Posets",
                "data": viz_data['upper_set_counts']
            }
        ],
        "lean_proofs": lean_code
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, ensure_ascii=False)

    print(f"PACKAGE.json generated ({len(json.dumps(package))//1024} KB)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Tropical Stone Recognition Duality.
Generates base64-encoded PNG images for the PACKAGE.json.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_upper_set_lattice():
    """Visualize the lattice of upper sets for the 2-element chain."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: The poset (2-chain)
    ax = axes[0]
    ax.set_title("Poset: 2-Chain", fontsize=14, fontweight='bold')
    ax.plot([0.5], [0.2], 'o', color='#2196F3', markersize=20, zorder=5)
    ax.plot([0.5], [0.8], 'o', color='#2196F3', markersize=20, zorder=5)
    ax.annotate('', xy=(0.5, 0.73), xytext=(0.5, 0.27),
                arrowprops=dict(arrowstyle='->', lw=2, color='#333'))
    ax.text(0.5, 0.2, '0', ha='center', va='center', fontsize=12,
            fontweight='bold', color='white')
    ax.text(0.5, 0.8, '1', ha='center', va='center', fontsize=12,
            fontweight='bold', color='white')
    ax.text(0.75, 0.5, '0 ≤ 1', ha='left', va='center', fontsize=11)
    ax.set_xlim(0, 1.5)
    ax.set_ylim(0, 1)
    ax.axis('off')

    # Panel 2: Upper sets
    ax = axes[1]
    ax.set_title("Upper Sets (= Spectral Opens)", fontsize=14, fontweight='bold')
    # Draw the three upper sets as a lattice
    positions = {
        '∅': (0.5, 0.1),
        '{1}': (0.5, 0.5),
        '{0,1}': (0.5, 0.9),
    }
    colors = ['#FF9800', '#4CAF50', '#2196F3']
    for i, (label, (x, y)) in enumerate(positions.items()):
        ax.plot([x], [y], 'o', color=colors[i], markersize=25, zorder=5)
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
                fontweight='bold', color='white' if i > 0 else 'black')
    # Arrows
    ax.annotate('', xy=(0.5, 0.43), xytext=(0.5, 0.17),
                arrowprops=dict(arrowstyle='->', lw=2, color='#333'))
    ax.annotate('', xy=(0.5, 0.83), xytext=(0.5, 0.57),
                arrowprops=dict(arrowstyle='->', lw=2, color='#333'))
    ax.text(0.75, 0.3, '⊆', ha='left', va='center', fontsize=14)
    ax.text(0.75, 0.7, '⊆', ha='left', va='center', fontsize=14)
    ax.set_xlim(0, 1.5)
    ax.set_ylim(0, 1)
    ax.axis('off')

    # Panel 3: Semiring operations
    ax = axes[2]
    ax.set_title("Idempotent Semiring Operations", fontsize=14, fontweight='bold')
    ops = [
        ("∅ + {1} = {1}", 0.85),
        ("{1} + {0,1} = {0,1}", 0.75),
        ("{1} + {1} = {1}  (idem!)", 0.65),
        ("", 0.55),
        ("∅ × {1} = ∅", 0.45),
        ("{1} × {0,1} = {1}", 0.35),
        ("{0,1} × {0,1} = {0,1}  (idem!)", 0.25),
    ]
    for text, y in ops:
        ax.text(0.1, y, text, ha='left', va='center', fontsize=11,
                fontfamily='monospace')
    ax.text(0.1, 0.95, "+ = union,  × = intersection", ha='left', va='center',
            fontsize=11, fontweight='bold', color='#666')
    ax.set_xlim(0, 1.5)
    ax.set_ylim(0.1, 1)
    ax.axis('off')

    fig.suptitle("Tropical Stone Duality: 2-Chain Example", fontsize=16,
                 fontweight='bold', y=1.02)
    return fig


def plot_stone_embedding():
    """Visualize the Stone embedding (principal upper sets)."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: Diamond poset
    ax = axes[0]
    ax.set_title("Diamond Poset", fontsize=14, fontweight='bold')
    positions = {
        'bot': (0.5, 0.1),
        'a': (0.2, 0.5),
        'b': (0.8, 0.5),
        'top': (0.5, 0.9),
    }
    for label, (x, y) in positions.items():
        ax.plot([x], [y], 'o', color='#2196F3', markersize=20, zorder=5)
        ax.text(x, y, label, ha='center', va='center', fontsize=10,
                fontweight='bold', color='white')
    # Hasse diagram edges
    edges = [('bot', 'a'), ('bot', 'b'), ('a', 'top'), ('b', 'top')]
    for s, t in edges:
        x1, y1 = positions[s]
        x2, y2 = positions[t]
        ax.annotate('', xy=(x2, y2-0.06), xytext=(x1, y1+0.06),
                    arrowprops=dict(arrowstyle='->', lw=1.5, color='#333'))
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(0, 1)
    ax.axis('off')

    # Panel 2: Principal upper sets (Stone embedding)
    ax = axes[1]
    ax.set_title("Principal Upper Sets (Stone Embedding)", fontsize=14, fontweight='bold')

    data = [
        ("↑bot = {bot, a, b, top}", 0.85, '#F44336'),
        ("↑a = {a, top}", 0.70, '#FF9800'),
        ("↑b = {b, top}", 0.55, '#4CAF50'),
        ("↑top = {top}", 0.40, '#2196F3'),
    ]
    for text, y, color in data:
        ax.add_patch(mpatches.FancyBboxPatch(
            (0.05, y-0.05), 0.9, 0.1,
            boxstyle="round,pad=0.02",
            facecolor=color, alpha=0.2, edgecolor=color, linewidth=2))
        ax.text(0.5, y, text, ha='center', va='center', fontsize=12,
                fontweight='bold', color=color)

    ax.text(0.5, 0.2, "bot ≤ a  ⟹  ↑a ⊆ ↑bot  (contravariant!)",
            ha='center', va='center', fontsize=11, color='#666', style='italic')
    ax.text(0.5, 0.1, "Injective: distinct points → distinct upper sets",
            ha='center', va='center', fontsize=11, color='#666', style='italic')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')

    fig.suptitle("Stone Embedding: Poset → Upper-Set Algebra", fontsize=16,
                 fontweight='bold', y=1.02)
    return fig


def plot_duality_diagram():
    """Visualize the duality correspondence as a diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    ax.set_title("Finite Tropical Stone Recognition Duality", fontsize=16,
                 fontweight='bold')

    # Left box: Finite Posets
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.05, 0.2), 0.35, 0.6,
        boxstyle="round,pad=0.03",
        facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2))
    ax.text(0.225, 0.75, "Finite T₀ Posets", ha='center', fontsize=14,
            fontweight='bold', color='#1565C0')
    ax.text(0.225, 0.65, "(Spectral Spaces)", ha='center', fontsize=11,
            color='#666')
    ax.text(0.225, 0.5, "• Finite partial orders\n• Upper sets = opens\n"
            "• Compact = open\n• Alexandroff topology",
            ha='center', va='center', fontsize=10, color='#333')

    # Right box: Idempotent Semirings
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.6, 0.2), 0.35, 0.6,
        boxstyle="round,pad=0.03",
        facecolor='#FFF3E0', edgecolor='#E65100', linewidth=2))
    ax.text(0.775, 0.75, "Finite Idempotent", ha='center', fontsize=14,
            fontweight='bold', color='#E65100')
    ax.text(0.775, 0.65, "Semirings", ha='center', fontsize=14,
            fontweight='bold', color='#E65100')
    ax.text(0.775, 0.5, "• a + a = a (tropical)\n• a × a = a (doubly idem)\n"
            "• Absorption: a(a+b)=a\n• Recognition algebras",
            ha='center', va='center', fontsize=10, color='#333')

    # Arrows
    ax.annotate('Upper-Set Algebra', xy=(0.58, 0.58), xytext=(0.42, 0.58),
                fontsize=11, fontweight='bold', color='#4CAF50',
                ha='center', va='bottom',
                arrowprops=dict(arrowstyle='->', lw=2.5, color='#4CAF50'))
    ax.annotate('Congruence Spectrum', xy=(0.42, 0.42), xytext=(0.58, 0.42),
                fontsize=11, fontweight='bold', color='#F44336',
                ha='center', va='top',
                arrowprops=dict(arrowstyle='->', lw=2.5, color='#F44336'))

    # Bottom: Consequence
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.15, 0.02), 0.7, 0.12,
        boxstyle="round,pad=0.02",
        facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2))
    ax.text(0.5, 0.08, "⟹ Unique Minimal Tropical Recognizer (certified reconstruction)",
            ha='center', va='center', fontsize=12, fontweight='bold', color='#2E7D32')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 0.85)
    ax.axis('off')
    return fig


def plot_upper_set_counts():
    """Bar chart of upper-set counts for various posets."""
    fig, ax = plt.subplots(figsize=(10, 5))

    posets = ['Empty\n(0)', 'Point\n(1)', '2-chain\n(2)', '2-anti\n(2)',
              '3-chain\n(3)', '3-anti\n(3)', 'Diamond\n(4)', 'Pentagon\n(5)']
    counts = [1, 2, 3, 4, 4, 8, 6, 8]
    sizes = [0, 1, 2, 2, 3, 3, 4, 5]

    colors = ['#90CAF9' if s <= 2 else '#FFB74D' if s <= 3 else '#EF9A9A'
              for s in sizes]

    bars = ax.bar(posets, counts, color=colors, edgecolor='#333', linewidth=1.5)

    # Add count labels
    for bar, count in zip(bars, counts):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.15,
                str(count), ha='center', va='bottom', fontweight='bold', fontsize=12)

    ax.set_ylabel("Number of Upper Sets", fontsize=13)
    ax.set_title("Upper-Set Counts for Small Posets\n(verified in Lean 4 for chain-2 and singleton)",
                 fontsize=14, fontweight='bold')
    ax.set_ylim(0, max(counts) + 1.5)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#90CAF9', edgecolor='#333', label='≤ 2 elements'),
        mpatches.Patch(facecolor='#FFB74D', edgecolor='#333', label='3 elements'),
        mpatches.Patch(facecolor='#EF9A9A', edgecolor='#333', label='≥ 4 elements'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)

    return fig


def main():
    """Generate all visualizations and save as base64."""
    figs = {}

    print("Generating visualizations...")

    fig1 = plot_upper_set_lattice()
    figs['upper_set_lattice'] = fig_to_base64(fig1)
    print("  ✓ Upper set lattice")

    fig2 = plot_stone_embedding()
    figs['stone_embedding'] = fig_to_base64(fig2)
    print("  ✓ Stone embedding")

    fig3 = plot_duality_diagram()
    figs['duality_diagram'] = fig_to_base64(fig3)
    print("  ✓ Duality diagram")

    fig4 = plot_upper_set_counts()
    figs['upper_set_counts'] = fig_to_base64(fig4)
    print("  ✓ Upper set counts")

    return figs


if __name__ == "__main__":
    figs = main()
    # Save to file for inspection
    for name, data in figs.items():
        print(f"  {name}: {len(data)} chars")
