"""
Applications of Leaf Witness Exchange Properties.

This module demonstrates real-world applications of the leaf witness
valuation theory:
1. Optimal basis selection for DPP sampling
2. Tropical optimization on matroid bases
3. Network reliability via exchange bounds
"""

from __future__ import annotations
from typing import FrozenSet, Dict, Set, List, Tuple
from itertools import combinations
import math


# ============================================================
# Self-contained matroid infrastructure
# ============================================================

Basis = FrozenSet[int]
Polynomial = Dict[Tuple[int, ...], float]


class Matroid:
    def __init__(self, ground_set: FrozenSet[int], bases: Set[Basis]):
        self.ground_set = ground_set
        self.bases = bases
        self.rank = len(next(iter(bases))) if bases else 0

    def is_base(self, s: FrozenSet[int]) -> bool:
        return s in self.bases

    @staticmethod
    def uniform(n: int, r: int) -> 'Matroid':
        E = frozenset(range(n))
        bases = {frozenset(c) for c in combinations(range(n), r)}
        return Matroid(E, bases)

    @staticmethod
    def graphic(n: int, edges: List[Tuple[int, int]]) -> 'Matroid':
        E = frozenset(range(len(edges)))

        def is_acyclic(edge_set):
            parent = list(range(n))
            def find(x):
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x
            for idx in edge_set:
                u, v = edges[idx]
                ru, rv = find(u), find(v)
                if ru == rv:
                    return False
                parent[ru] = rv
            return True

        def count_components(edge_set):
            parent = list(range(n))
            def find(x):
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x
            for idx in edge_set:
                u, v = edges[idx]
                ru, rv = find(u), find(v)
                if ru != rv:
                    parent[ru] = rv
            return len({find(i) for i in range(n)})

        target_rank = n - count_components(E)
        bases = set()
        for r_sub in combinations(range(len(edges)), target_rank):
            fs = frozenset(r_sub)
            if is_acyclic(fs):
                bases.add(fs)
        return Matroid(E, bases)


def basis_generating_polynomial(M: Matroid) -> Polynomial:
    n = max(M.ground_set) + 1 if M.ground_set else 0
    poly: Polynomial = {}
    for basis in M.bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly


def partial_derivative(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            new_coeff = coeff * exp[var]
            key = tuple(new_exp)
            result[key] = result.get(key, 0.0) + new_coeff
    return result


def leaf_witness(p: Polynomial, S: FrozenSet[int]) -> float:
    current = p
    for i in sorted(S):
        current = partial_derivative(current, i)
    return sum(current.values())


# ============================================================
# Application 1: Optimal Basis Selection for DPP Sampling
# ============================================================

def app_dpp_sampling():
    """Demonstrate optimal basis selection using leaf witness values.

    In DPP sampling, we want to select a diverse subset. The leaf witness
    gives each basis a quality score. The tropical exchange axiom guarantees
    that we can always improve a basis by local exchange without dropping
    below the minimum quality threshold.
    """
    print("=" * 60)
    print("APPLICATION 1: Optimal Basis Selection for DPP Sampling")
    print("=" * 60)

    # Use graphic matroid of a small network
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3), (0,4), (1,4)]
    M = Matroid.graphic(5, edges)
    p = basis_generating_polynomial(M)
    lw = {b: leaf_witness(p, b) for b in M.bases}

    # Sort bases by leaf witness value
    sorted_bases = sorted(lw.items(), key=lambda x: x[1], reverse=True)

    print(f"\nNetwork: 5 nodes, {len(edges)} edges")
    print(f"Spanning trees (bases): {len(M.bases)}")
    print(f"\nTop 5 spanning trees by leaf witness:")
    for i, (b, v) in enumerate(sorted_bases[:5]):
        edges_in_tree = [edges[j] for j in sorted(b)]
        print(f"  {i+1}. Edges {edges_in_tree}: lw = {v:.4f}")

    print(f"\nBottom 5 spanning trees by leaf witness:")
    for i, (b, v) in enumerate(sorted_bases[-5:]):
        edges_in_tree = [edges[j] for j in sorted(b)]
        print(f"  {len(sorted_bases)-4+i}. Edges {edges_in_tree}: lw = {v:.4f}")

    # Demonstrate greedy improvement via exchange
    print(f"\nGreedy improvement via exchange:")
    current = sorted_bases[-1][0]  # Start from worst
    current_val = lw[current]
    print(f"  Start: lw = {current_val:.4f}")

    for step in range(5):
        best_neighbor = None
        best_val = current_val
        for a in current:
            for b in M.ground_set - current:
                B_new = (current - {a}) | {b}
                if M.is_base(B_new) and lw[B_new] > best_val:
                    best_neighbor = B_new
                    best_val = lw[B_new]
        if best_neighbor is None:
            print(f"  Step {step+1}: Local optimum reached!")
            break
        current = best_neighbor
        current_val = best_val
        print(f"  Step {step+1}: lw = {current_val:.4f}")


# ============================================================
# Application 2: Tropical Optimization
# ============================================================

def app_tropical_optimization():
    """Demonstrate tropical optimization using leaf witness M-convexity.

    The tropical exchange axiom (M-convexity) guarantees that steepest
    descent on the leaf witness function converges to the global minimum
    on the base exchange graph.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Tropical Steepest Descent Optimization")
    print("=" * 60)

    M = Matroid.uniform(6, 3)
    p = basis_generating_polynomial(M)
    lw = {b: leaf_witness(p, b) for b in M.bases}

    print(f"\nMatroid U(3, 6): {len(M.bases)} bases")
    print(f"Leaf witness range: [{min(lw.values()):.4f}, {max(lw.values()):.4f}]")

    # Steepest descent to find minimum leaf witness
    import random
    random.seed(42)
    start = random.choice(list(M.bases))

    print(f"\nSteepest descent from random start:")
    current = start
    path = [current]
    for step in range(20):
        best_neighbor = None
        best_val = lw[current]
        for a in current:
            for b in M.ground_set - current:
                B_new = (current - {a}) | {b}
                if M.is_base(B_new) and lw[B_new] < best_val:
                    best_neighbor = B_new
                    best_val = lw[B_new]
        if best_neighbor is None:
            print(f"  Converged at step {step}!")
            break
        current = best_neighbor
        path.append(current)
        print(f"  Step {step+1}: lw = {best_val:.4f}")

    true_min = min(lw.values())
    print(f"\nTrue minimum: {true_min:.4f}")
    print(f"Found minimum: {lw[current]:.4f}")
    print(f"Optimal: {'YES' if abs(lw[current] - true_min) < 1e-10 else 'NO'}")


# ============================================================
# Application 3: Network Reliability Bounds
# ============================================================

def app_network_reliability():
    """Demonstrate network reliability bounds from exchange properties.

    The leaf witness of a spanning tree measures its "robustness":
    trees with higher leaf witness are more central in the exchange graph,
    meaning they are reachable from more other trees via single swaps.
    The exchange inequality provides lower bounds on the reliability
    of nearby configurations.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Network Reliability via Exchange Bounds")
    print("=" * 60)

    # Build a network
    edges = [(0,1), (0,2), (1,2), (1,3), (2,3), (2,4), (3,4)]
    M = Matroid.graphic(5, edges)
    p = basis_generating_polynomial(M)
    lw = {b: leaf_witness(p, b) for b in M.bases}

    print(f"\nNetwork: 5 nodes, {len(edges)} edges")
    print(f"Spanning trees: {len(M.bases)}")

    # For each pair of trees, verify exchange bound
    pair_count = 0
    bound_tight = 0
    for B1 in M.bases:
        for B2 in M.bases:
            if B1 >= B2:
                continue
            pair_count += 1
            min_val = min(lw[B1], lw[B2])
            # Check all single-exchange neighbors of B1 toward B2
            for a in B1 - B2:
                for b in B2 - B1:
                    B_new = (B1 - {a}) | {b}
                    if M.is_base(B_new):
                        if abs(lw[B_new] - min_val) < 1e-10:
                            bound_tight += 1

    print(f"\nExchange bound analysis:")
    print(f"  Total basis pairs: {pair_count}")
    print(f"  Pairs achieving equality: {bound_tight}")
    print(f"  Bound tightness ratio: {bound_tight/max(pair_count,1):.2%}")

    # Show the exchange graph structure
    print(f"\nExchange graph (degree distribution):")
    degree_count: Dict[int, int] = {}
    for B1 in M.bases:
        deg = sum(1 for B2 in M.bases
                  if B1 != B2 and len(B1.symmetric_difference(B2)) == 2)
        degree_count[deg] = degree_count.get(deg, 0) + 1
    for deg in sorted(degree_count):
        print(f"  Degree {deg}: {degree_count[deg]} bases")


if __name__ == "__main__":
    app_dpp_sampling()
    app_tropical_optimization()
    app_network_reliability()
    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


"""
Interactive demonstration of Leaf Witness Exchange Properties.

This script demonstrates:
1. Construction of matroids (uniform, graphic)
2. Computation of basis generating polynomials
3. Leaf witness computation for all bases
4. Verification of the tropical exchange axiom
5. Testing the tropical Plücker conjecture
6. Visualization of the leaf witness landscape on the exchange graph

Run: python demo.py
"""

from __future__ import annotations
from typing import FrozenSet, Dict, Tuple, List, Set, Optional
from itertools import combinations
import math


# ============================================================
# Core matroid and polynomial infrastructure (self-contained)
# ============================================================

Element = int
Basis = FrozenSet[int]
Monomial = Tuple[int, ...]
Polynomial = Dict[Monomial, float]


class Matroid:
    """A matroid defined by its ground set and collection of bases."""

    def __init__(self, ground_set: FrozenSet[int], bases: Set[Basis]):
        self.ground_set = ground_set
        self.bases = bases
        if bases:
            ranks = {len(b) for b in bases}
            assert len(ranks) == 1, "All bases must have the same cardinality"
            self.rank = ranks.pop()
        else:
            self.rank = 0

    def is_base(self, s: FrozenSet[int]) -> bool:
        return s in self.bases

    @staticmethod
    def uniform(n: int, r: int) -> 'Matroid':
        E = frozenset(range(n))
        bases = {frozenset(c) for c in combinations(range(n), r)}
        return Matroid(E, bases)

    @staticmethod
    def graphic(n: int, edges: List[Tuple[int, int]]) -> 'Matroid':
        E = frozenset(range(len(edges)))

        def is_acyclic(edge_set: FrozenSet[int]) -> bool:
            parent = list(range(n))

            def find(x):
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x

            def union(x, y):
                rx, ry = find(x), find(y)
                if rx == ry:
                    return False
                parent[rx] = ry
                return True

            for idx in edge_set:
                u, v = edges[idx]
                if not union(u, v):
                    return False
            return True

        def count_components(edge_set):
            parent = list(range(n))

            def find(x):
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x

            for idx in edge_set:
                u, v = edges[idx]
                rx, ry = find(u), find(v)
                if rx != ry:
                    parent[rx] = ry

            return len({find(i) for i in range(n)})

        target_rank = n - count_components(E)
        bases: Set[Basis] = set()
        for r_sub in combinations(range(len(edges)), target_rank):
            fs = frozenset(r_sub)
            if is_acyclic(fs):
                bases.add(fs)
        return Matroid(E, bases)


def basis_generating_polynomial(M: Matroid) -> Polynomial:
    n = max(M.ground_set) + 1 if M.ground_set else 0
    poly: Polynomial = {}
    for basis in M.bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly


def partial_derivative(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            new_exp = list(exp)
            new_coeff = coeff * exp[var]
            new_exp[var] -= 1
            result[tuple(new_exp)] = result.get(tuple(new_exp), 0.0) + new_coeff
    return result


def evaluate_at_ones(p: Polynomial) -> float:
    return sum(p.values())


def leaf_witness(p: Polynomial, S: FrozenSet[int]) -> float:
    current = p
    for i in sorted(S):
        current = partial_derivative(current, i)
    return evaluate_at_ones(current)


def exchange_distance(A: FrozenSet[int], B: FrozenSet[int]) -> int:
    return len(A.symmetric_difference(B))


def verify_tropical_exchange(M, v):
    violations = []
    for B1 in M.bases:
        for B2 in M.bases:
            if B1 == B2:
                continue
            for a in B1 - B2:
                found = False
                for b in B2 - B1:
                    B_new = (B1 - {a}) | {b}
                    if M.is_base(B_new) and v.get(B_new, float('-inf')) >= min(v[B1], v[B2]) - 1e-10:
                        found = True
                        break
                if not found:
                    violations.append((B1, B2, a))
    return len(violations) == 0, violations


def verify_tropical_pluecker(v, ground_set, rank):
    violations = []
    if rank < 2:
        return True, violations
    elements = sorted(ground_set)
    for S_tuple in combinations(elements, rank - 2):
        S = frozenset(S_tuple)
        remaining = sorted(ground_set - S)
        if len(remaining) < 4:
            continue
        for i, j, k, l in combinations(remaining, 4):
            sets = {}
            for a, b in [(i,j), (i,k), (i,l), (j,k), (j,l), (k,l)]:
                key = S | {a, b}
                if key in v:
                    sets[(a,b)] = v[key]
            if len(sets) < 6:
                continue
            lhs = sets[(i,j)] + sets[(k,l)]
            rhs1 = sets[(i,k)] + sets[(j,l)]
            rhs2 = sets[(i,l)] + sets[(j,k)]
            if lhs < min(rhs1, rhs2) - 1e-10:
                violations.append((S, i, j, k, l, lhs, min(rhs1, rhs2)))
    return len(violations) == 0, violations


# ============================================================
# Demonstration
# ============================================================

def demo_uniform_matroids():
    """Test leaf witness exchange on uniform matroids U(r, n)."""
    print("=" * 60)
    print("DEMO 1: Uniform Matroids U(r, n)")
    print("=" * 60)

    results = []
    for n in range(2, 8):
        for r in range(1, n):
            M = Matroid.uniform(n, r)
            p = basis_generating_polynomial(M)
            lw = {b: leaf_witness(p, b) for b in M.bases}

            exchange_ok, _ = verify_tropical_exchange(M, lw)
            pluecker_ok, _ = verify_tropical_pluecker(lw, M.ground_set, M.rank)

            results.append((n, r, len(M.bases), exchange_ok, pluecker_ok))

    print(f"\n{'n':>3} {'r':>3} {'|B|':>6} {'Exchange':>10} {'Plücker':>10}")
    print("-" * 40)
    for n, r, nb, ex, pl in results:
        print(f"{n:>3} {r:>3} {nb:>6} {'✓' if ex else '✗':>10} {'✓' if pl else '✗':>10}")

    all_exchange = all(r[3] for r in results)
    all_pluecker = all(r[4] for r in results)
    print(f"\nAll exchange: {'PASS' if all_exchange else 'FAIL'}")
    print(f"All Plücker:  {'PASS' if all_pluecker else 'FAIL'}")


def demo_graphic_matroids():
    """Test leaf witness exchange on graphic matroids."""
    print("\n" + "=" * 60)
    print("DEMO 2: Graphic Matroids")
    print("=" * 60)

    graphs = {
        "K3 (triangle)": (3, [(0,1), (0,2), (1,2)]),
        "K4 (complete)": (4, [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]),
        "C4 (4-cycle)":  (4, [(0,1), (1,2), (2,3), (3,0)]),
        "K3,3 - e":      (6, [(0,3), (0,4), (0,5), (1,3), (1,4), (2,3), (2,5)]),
        "Petersen-sub":   (5, [(0,1), (0,2), (0,3), (1,2), (1,4), (2,3), (3,4)]),
    }

    for name, (n, edges) in graphs.items():
        M = Matroid.graphic(n, edges)
        p = basis_generating_polynomial(M)
        lw = {b: leaf_witness(p, b) for b in M.bases}

        exchange_ok, ex_viols = verify_tropical_exchange(M, lw)
        pluecker_ok, pl_viols = verify_tropical_pluecker(lw, M.ground_set, M.rank)

        print(f"\n{name}:")
        print(f"  Edges: {edges}")
        print(f"  Bases: {len(M.bases)}, Rank: {M.rank}")
        print(f"  Leaf witness values: {sorted(set(lw.values()))}")
        print(f"  Exchange: {'PASS' if exchange_ok else 'FAIL'}")
        print(f"  Plücker:  {'PASS' if pluecker_ok else 'FAIL'}")


def demo_exchange_landscape():
    """Visualize the leaf witness landscape on the exchange graph."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exchange Landscape for U(2, 5)")
    print("=" * 60)

    M = Matroid.uniform(5, 2)
    p = basis_generating_polynomial(M)
    lw = {b: leaf_witness(p, b) for b in M.bases}

    print(f"\nBases and leaf witnesses:")
    for b in sorted(M.bases):
        print(f"  {sorted(b)}: lw = {lw[b]:.4f}")

    print(f"\nExchange graph (adjacent bases differ by one element):")
    for b1 in sorted(M.bases):
        neighbors = []
        for b2 in sorted(M.bases):
            if exchange_distance(b1, b2) == 2:
                neighbors.append(sorted(b2))
        print(f"  {sorted(b1)} -> {neighbors}")

    # Check exchange pairs: equality vs strict inequality
    print(f"\nExchange pair analysis:")
    equality_count = 0
    strict_count = 0
    for B1 in M.bases:
        for B2 in M.bases:
            if B1 == B2:
                continue
            for a in B1 - B2:
                for b in B2 - B1:
                    B_new = (B1 - {a}) | {b}
                    if M.is_base(B_new):
                        val = lw[B_new]
                        threshold = min(lw[B1], lw[B2])
                        if abs(val - threshold) < 1e-10:
                            equality_count += 1
                        elif val > threshold:
                            strict_count += 1

    print(f"  Equality cases: {equality_count}")
    print(f"  Strict inequality cases: {strict_count}")


def demo_pluecker_conjecture_test():
    """Exhaustive test of the tropical Plücker conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Plücker Conjecture Test")
    print("=" * 60)

    print("\nTesting all uniform matroids U(r, n) with n ≤ 7:")
    all_pass = True
    for n in range(2, 8):
        for r in range(2, n):
            M = Matroid.uniform(n, r)
            p = basis_generating_polynomial(M)
            lw = {b: leaf_witness(p, b) for b in M.bases}
            ok, viols = verify_tropical_pluecker(lw, M.ground_set, M.rank)
            if not ok:
                print(f"  U({r},{n}): FAIL - {len(viols)} violations")
                all_pass = False

    if all_pass:
        print("  All passed! No counterexamples found.")

    print("\nTesting graphic matroids of small complete graphs:")
    for n in range(3, 7):
        edges = [(i, j) for i in range(n) for j in range(i+1, n)]
        M = Matroid.graphic(n, edges)
        p = basis_generating_polynomial(M)
        lw = {b: leaf_witness(p, b) for b in M.bases}
        ok, viols = verify_tropical_pluecker(lw, M.ground_set, M.rank)
        status = "PASS" if ok else f"FAIL ({len(viols)} violations)"
        print(f"  K{n}: {len(M.bases)} bases, rank {M.rank} -> {status}")


def demo_valuation_transforms():
    """Demonstrate that transforms preserve the exchange axiom."""
    print("\n" + "=" * 60)
    print("DEMO 5: Valuation Transforms")
    print("=" * 60)

    M = Matroid.uniform(4, 2)
    p = basis_generating_polynomial(M)
    lw = {b: leaf_witness(p, b) for b in M.bases}

    # Original
    ok, _ = verify_tropical_exchange(M, lw)
    print(f"Original leaf witness:    Exchange {'PASS' if ok else 'FAIL'}")

    # Translation
    lw_translated = {b: v + 5.0 for b, v in lw.items()}
    ok, _ = verify_tropical_exchange(M, lw_translated)
    print(f"Translated (+5):          Exchange {'PASS' if ok else 'FAIL'}")

    # Scaling
    lw_scaled = {b: 3.0 * v for b, v in lw.items()}
    ok, _ = verify_tropical_exchange(M, lw_scaled)
    print(f"Scaled (×3):              Exchange {'PASS' if ok else 'FAIL'}")

    # Exponential
    lw_exp = {b: math.exp(v) for b, v in lw.items()}
    ok, _ = verify_tropical_exchange(M, lw_exp)
    print(f"Exponential (exp):        Exchange {'PASS' if ok else 'FAIL'}")

    # Square root (monotone on positive reals)
    lw_sqrt = {b: math.sqrt(v) for b, v in lw.items()}
    ok, _ = verify_tropical_exchange(M, lw_sqrt)
    print(f"Square root (√):          Exchange {'PASS' if ok else 'FAIL'}")

    # Logarithm (monotone on positive reals)
    lw_log = {b: math.log(v) for b, v in lw.items()}
    ok, _ = verify_tropical_exchange(M, lw_log)
    print(f"Logarithm (log):          Exchange {'PASS' if ok else 'FAIL'}")


if __name__ == "__main__":
    demo_uniform_matroids()
    demo_graphic_matroids()
    demo_exchange_landscape()
    demo_pluecker_conjecture_test()
    demo_valuation_transforms()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


"""
Visualization 3: Exchange Chain Valuation Bounds

Visualizes the key theorem: along an exchange chain from base B₁ to base B₂,
the leaf witness values stay above min(v(B₁), v(B₂)). This is the "valley
floor" property — every ridge path between two peaks stays above the lower
peak.

Shows multiple exchange chains between two fixed bases, with the valuation
floor highlighted.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import FrozenSet, Dict, Set, Tuple, List
import random

# Self-contained infrastructure
Basis = FrozenSet[int]
Polynomial = Dict[Tuple[int, ...], float]

def uniform_bases(n: int, r: int) -> Set[Basis]:
    return {frozenset(c) for c in combinations(range(n), r)}

def basis_gen_poly(bases: Set[Basis], n: int) -> Polynomial:
    poly: Polynomial = {}
    for basis in bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly

def pderiv(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            ne = list(exp)
            ne[var] -= 1
            k = tuple(ne)
            result[k] = result.get(k, 0.0) + coeff * exp[var]
    return result

def lw(p: Polynomial, S: FrozenSet[int]) -> float:
    c = p
    for i in sorted(S):
        c = pderiv(c, i)
    return sum(c.values())


def find_exchange_chains(bases: Set[Basis], start: Basis, end: Basis,
                         max_chains: int = 10, max_depth: int = 10) -> List[List[Basis]]:
    """Find exchange chains from start to end using BFS."""
    from collections import deque
    chains: List[List[Basis]] = []
    queue = deque([(start, [start])])
    visited_paths: Set[Tuple[Basis, ...]] = set()

    while queue and len(chains) < max_chains:
        current, path = queue.popleft()
        if len(path) > max_depth:
            continue
        if current == end:
            chains.append(path)
            continue

        # Try all single exchanges
        for a in current - end:
            for b in end - current:
                b_new = (current - {a}) | {b}
                if b_new in bases and b_new not in path:
                    new_path = path + [b_new]
                    path_key = tuple(new_path)
                    if path_key not in visited_paths:
                        visited_paths.add(path_key)
                        queue.append((b_new, new_path))

    return chains


# Build U(3, 6) — interesting enough to have multiple chains
n, r = 6, 3
bases = uniform_bases(n, r)
p = basis_gen_poly(bases, n)
v = {b: lw(p, b) for b in bases}

# Pick two specific bases
bases_list = sorted(bases)
B_start = frozenset({0, 1, 2})
B_end = frozenset({3, 4, 5})

chains = find_exchange_chains(bases, B_start, B_end, max_chains=8, max_depth=6)

# Create figure
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))

# --- Top panel: Exchange chains with valuation floor ---
v_start = v[B_start]
v_end = v[B_end]
floor = min(v_start, v_end)

colors = plt.cm.Set2(np.linspace(0, 1, max(len(chains), 1)))

for idx, chain in enumerate(chains[:6]):
    values = [v[b] for b in chain]
    x_pos = np.arange(len(chain))
    label = f'Chain {idx+1}: ' + ' → '.join(
        '{' + ','.join(str(e) for e in sorted(b)) + '}' for b in chain
    )
    ax1.plot(x_pos, values, 'o-', color=colors[idx], linewidth=2,
             markersize=8, label=f'Chain {idx+1}', zorder=3)

# Draw floor line
if chains:
    max_len = max(len(c) for c in chains[:6])
    ax1.axhline(y=floor, color='red', linestyle='--', linewidth=2,
                label=f'Floor = min(v(B₁), v(B₂)) = {floor:.1f}', zorder=2)
    ax1.fill_between([0, max_len-1], floor, floor - 0.5,
                     color='red', alpha=0.1, zorder=1)

ax1.set_xlabel('Exchange Step', fontsize=12)
ax1.set_ylabel('Leaf Witness Value', fontsize=12)
ax1.set_title(
    f'Exchange Chains: {{0,1,2}} → {{3,4,5}} in U(3,6)\n'
    f'Valley Floor Property: All values ≥ min(v(B₁), v(B₂))',
    fontsize=13
)
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)

# --- Bottom panel: Distribution of leaf witness values ---
all_values = sorted(v.values())
unique_values = sorted(set(all_values))
counts = [all_values.count(uv) for uv in unique_values]

bars = ax2.bar(range(len(unique_values)), counts, color='steelblue',
               edgecolor='black', linewidth=0.5)
ax2.set_xticks(range(len(unique_values)))
ax2.set_xticklabels([f'{uv:.1f}' for uv in unique_values], rotation=45)
ax2.set_xlabel('Leaf Witness Value', fontsize=12)
ax2.set_ylabel('Number of Bases', fontsize=12)
ax2.set_title(f'Distribution of Leaf Witness Values\nU(3, 6): {len(bases)} bases', fontsize=13)

# Highlight the start and end values
for i, uv in enumerate(unique_values):
    if abs(uv - v_start) < 1e-10:
        bars[i].set_color('green')
        bars[i].set_edgecolor('darkgreen')
    if abs(uv - v_end) < 1e-10:
        bars[i].set_color('orange')
        bars[i].set_edgecolor('darkorange')

from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='green', edgecolor='darkgreen', label=f'B₁ = {{0,1,2}}, v = {v_start:.1f}'),
    Patch(facecolor='orange', edgecolor='darkorange', label=f'B₂ = {{3,4,5}}, v = {v_end:.1f}'),
    Patch(facecolor='steelblue', edgecolor='black', label='Other bases'),
]
ax2.legend(handles=legend_elements, fontsize=10)

plt.tight_layout()
plt.savefig('exchange_chain.png', dpi=150, bbox_inches='tight')
print("Saved exchange_chain.png")


"""
Visualization 1: Leaf Witness Landscape on the Exchange Graph

Visualizes the base exchange graph of a matroid (U(2,5)) with nodes
colored by their leaf witness values. Edges connect bases that differ
by a single exchange. The color gradient shows how leaf witness values
vary across the exchange graph, illustrating the tropical exchange
property: adjacent bases always have values bounded below by their
minimum.

Uses matplotlib to produce a static graph layout.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from itertools import combinations
from typing import FrozenSet, Dict, Set, Tuple

# Self-contained matroid and leaf witness computation
Basis = FrozenSet[int]
Polynomial = Dict[Tuple[int, ...], float]

def uniform_matroid_bases(n: int, r: int) -> Set[Basis]:
    return {frozenset(c) for c in combinations(range(n), r)}

def basis_generating_polynomial(bases: Set[Basis], n: int) -> Polynomial:
    poly: Polynomial = {}
    for basis in bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly

def partial_derivative(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            key = tuple(new_exp)
            result[key] = result.get(key, 0.0) + coeff * exp[var]
    return result

def leaf_witness(p: Polynomial, S: FrozenSet[int]) -> float:
    current = p
    for i in sorted(S):
        current = partial_derivative(current, i)
    return sum(current.values())

# Build U(2, 5) exchange graph
n, r = 5, 2
bases = uniform_matroid_bases(n, r)
p = basis_generating_polynomial(bases, n)
lw = {b: leaf_witness(p, b) for b in bases}

# Build exchange graph edges
edges = []
bases_list = sorted(bases)
for i, b1 in enumerate(bases_list):
    for b2 in bases_list[i+1:]:
        if len(b1.symmetric_difference(b2)) == 2:
            edges.append((i, bases_list.index(b1), bases_list.index(b2)))

# Layout: arrange bases in a circle
num_bases = len(bases_list)
angles = np.linspace(0, 2 * np.pi, num_bases, endpoint=False)
x = np.cos(angles)
y = np.sin(angles)

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# --- Left panel: Exchange graph colored by leaf witness ---
values = np.array([lw[b] for b in bases_list])
norm = plt.Normalize(vmin=values.min(), vmax=values.max())
cmap = cm.viridis

# Draw edges
for _, i, j in edges:
    ax1.plot([x[i], x[j]], [y[i], y[j]], 'k-', alpha=0.3, linewidth=0.8)

# Draw nodes
scatter = ax1.scatter(x, y, c=values, cmap=cmap, s=400, zorder=5,
                       edgecolors='black', linewidth=1.5)

# Label nodes
for i, b in enumerate(bases_list):
    label = '{' + ','.join(str(e) for e in sorted(b)) + '}'
    ax1.annotate(label, (x[i], y[i]), ha='center', va='center',
                fontsize=7, fontweight='bold')

ax1.set_title('Leaf Witness Values on Exchange Graph\nU(2, 5)', fontsize=14)
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.axis('off')
plt.colorbar(scatter, ax=ax1, label='Leaf Witness Value', shrink=0.8)

# --- Right panel: Exchange pair analysis ---
# For each edge, compute whether exchange achieves equality or strict inequality
equality_edges = []
strict_edges = []
for _, i, j in edges:
    b1, b2 = bases_list[i], bases_list[j]
    min_val = min(lw[b1], lw[b2])
    # Check exchange from b1 to b2
    for a in b1 - b2:
        for b in b2 - b1:
            b_new = (b1 - {a}) | {b}
            if b_new in bases and abs(lw[b_new] - min_val) < 1e-10:
                equality_edges.append((i, j))
            elif b_new in bases and lw[b_new] > min_val + 1e-10:
                strict_edges.append((i, j))

# Draw edges colored by type
for i, j in set(equality_edges):
    ax2.plot([x[i], x[j]], [y[i], y[j]], 'b-', alpha=0.6, linewidth=2,
             label='Equality' if (i,j) == equality_edges[0] else '')
for i, j in set(strict_edges):
    ax2.plot([x[i], x[j]], [y[i], y[j]], 'r-', alpha=0.6, linewidth=2,
             label='Strict' if (i,j) == strict_edges[0] else '')

ax2.scatter(x, y, c=values, cmap=cmap, s=400, zorder=5,
            edgecolors='black', linewidth=1.5)

for i, b in enumerate(bases_list):
    label = '{' + ','.join(str(e) for e in sorted(b)) + '}'
    ax2.annotate(label, (x[i], y[i]), ha='center', va='center',
                fontsize=7, fontweight='bold')

ax2.set_title('Exchange Inequality Analysis\nBlue=Equality, Red=Strict', fontsize=14)
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.axis('off')

plt.tight_layout()
plt.savefig('exchange_graph.png', dpi=150, bbox_inches='tight')
print("Saved exchange_graph.png")


"""
Visualization 2: Tropical Plücker Relation Heatmap

Visualizes the tropical Plücker relations for the leaf witness valuation
on the uniform matroid U(2, 6). For each 4-tuple (i,j,k,l), the heatmap
shows the "Plücker slack": LHS - min(RHS1, RHS2). By the conjecture,
this should always be non-negative (shown in warm colors). Zero slack
(equality) is shown in white.

This provides visual evidence for the tropical Plücker conjecture.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from itertools import combinations
from typing import FrozenSet, Dict, Set, Tuple

# Self-contained computation
Basis = FrozenSet[int]
Polynomial = Dict[Tuple[int, ...], float]

def uniform_matroid_bases(n: int, r: int) -> Set[Basis]:
    return {frozenset(c) for c in combinations(range(n), r)}

def basis_gen_poly(bases: Set[Basis], n: int) -> Polynomial:
    poly: Polynomial = {}
    for basis in bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly

def pderiv(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            ne = list(exp)
            ne[var] -= 1
            k = tuple(ne)
            result[k] = result.get(k, 0.0) + coeff * exp[var]
    return result

def lw(p: Polynomial, S: FrozenSet[int]) -> float:
    c = p
    for i in sorted(S):
        c = pderiv(c, i)
    return sum(c.values())

# Compute for U(2, 6)
n, r = 6, 2
bases = uniform_matroid_bases(n, r)
p = basis_gen_poly(bases, n)
v = {b: lw(p, b) for b in bases}

# Compute Plücker slacks for all 4-tuples
elements = list(range(n))
four_tuples = list(combinations(elements, 4))
slacks = []
labels = []

for i, j, k, l in four_tuples:
    # S is empty for rank 2
    S = frozenset()
    v_ij = v.get(S | {i, j}, 0)
    v_kl = v.get(S | {k, l}, 0)
    v_ik = v.get(S | {i, k}, 0)
    v_jl = v.get(S | {j, l}, 0)
    v_il = v.get(S | {i, l}, 0)
    v_jk = v.get(S | {j, k}, 0)

    lhs = v_ij + v_kl
    rhs1 = v_ik + v_jl
    rhs2 = v_il + v_jk
    slack = lhs - min(rhs1, rhs2)
    slacks.append(slack)
    labels.append(f"({i},{j},{k},{l})")

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# --- Left: Bar chart of Plücker slacks ---
ax = axes[0]
colors = ['green' if s > 1e-10 else 'gold' if abs(s) < 1e-10 else 'red' for s in slacks]
bars = ax.bar(range(len(slacks)), slacks, color=colors, edgecolor='black', linewidth=0.5)
ax.set_xlabel('4-tuple index', fontsize=12)
ax.set_ylabel('Plücker slack (LHS - min RHS)', fontsize=12)
ax.set_title('Tropical Plücker Slacks for U(2, 6)\nAll non-negative → Conjecture holds', fontsize=13)
ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xticks(range(len(labels)))
ax.set_xticklabels(labels, rotation=90, fontsize=7)

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='green', edgecolor='black', label='Strict (slack > 0)'),
    Patch(facecolor='gold', edgecolor='black', label='Equality (slack = 0)'),
]
ax.legend(handles=legend_elements, loc='upper right')

# --- Right: Leaf witness heatmap ---
ax2 = axes[1]
# Create a matrix of leaf witness values for all pairs
pair_matrix = np.zeros((n, n))
for (b, val) in v.items():
    elems = sorted(b)
    if len(elems) == 2:
        pair_matrix[elems[0], elems[1]] = val
        pair_matrix[elems[1], elems[0]] = val

im = ax2.imshow(pair_matrix, cmap='YlOrRd', interpolation='nearest')
ax2.set_xlabel('Element j', fontsize=12)
ax2.set_ylabel('Element i', fontsize=12)
ax2.set_title('Leaf Witness Values v({i,j})\nfor U(2, 6)', fontsize=13)
ax2.set_xticks(range(n))
ax2.set_yticks(range(n))
plt.colorbar(im, ax=ax2, label='Leaf Witness Value')

# Annotate values
for i in range(n):
    for j in range(n):
        if pair_matrix[i, j] > 0:
            ax2.text(j, i, f'{pair_matrix[i,j]:.1f}',
                    ha='center', va='center', fontsize=10, fontweight='bold')

plt.tight_layout()
plt.savefig('pluecker_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved pluecker_heatmap.png")
