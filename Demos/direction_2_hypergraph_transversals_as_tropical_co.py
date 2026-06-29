#!/usr/bin/env python3
"""
Applications of Tropical Hypergraph Transversal Theory

Demonstrates real-world applications of tropical threshold rounding:
1. Sensor placement for network monitoring
2. Minimum-weight set cover approximation
3. Fault-tolerant system design
"""

from fractions import Fraction
from typing import List, Set, FrozenSet, Dict
from algorithms import threshold_round, certify_active_witnesses, detect_tropical_extremality


# ──────────────────────────────────────────────────────────────────────────────
# Application 1: Sensor Placement
# ──────────────────────────────────────────────────────────────────────────────

def sensor_placement_demo():
    """
    Network monitoring: place sensors to cover all communication paths.

    Model: vertices = possible sensor locations, edges = paths that need monitoring.
    A transversal ensures every path has at least one sensor.
    Threshold rounding gives a d-approximate solution.
    """
    print("APPLICATION 1: Network Sensor Placement")
    print("=" * 50)
    print()

    # Network with 8 nodes, paths are edges
    locations = set(range(8))
    paths = [
        frozenset({0, 1, 2}),      # Path A
        frozenset({2, 3, 4}),      # Path B
        frozenset({4, 5, 6}),      # Path C
        frozenset({6, 7, 0}),      # Path D
        frozenset({1, 3, 5, 7}),   # Path E (diagonal)
    ]
    d = max(len(p) for p in paths)

    # Fractional solution from LP relaxation (simulated)
    x = {
        0: Fraction(1, 4), 1: Fraction(1, 4), 2: Fraction(1, 3),
        3: Fraction(1, 4), 4: Fraction(1, 3), 5: Fraction(1, 4),
        6: Fraction(1, 3), 7: Fraction(1, 4),
    }

    print(f"Network: {len(locations)} locations, {len(paths)} paths")
    print(f"Max path length (rank d) = {d}")
    print(f"Fractional LP solution: {dict(x)}")
    print(f"Fractional cost = {sum(x.values())}")
    print()

    # Apply threshold rounding
    S, info = threshold_round(locations, paths, x, d)
    print(f"Threshold τ = 1/{d} = {info['tau']}")
    print(f"Sensor locations: {sorted(S)}")
    print(f"Number of sensors: {info['integral_cost']}")
    print(f"All paths covered: {info['is_transversal']}")
    print(f"Approximation ratio: {info['approximation_ratio']} ≤ {d}")
    print()

    for i, p in enumerate(paths):
        covered_by = sorted(p & S)
        print(f"  Path {chr(65+i)} {set(p)}: covered by sensors at {covered_by}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 2: Weighted Set Cover
# ──────────────────────────────────────────────────────────────────────────────

def weighted_set_cover_demo():
    """
    Weighted set cover: select sets to cover a universe, minimizing total weight.

    The dual view: vertices = sets, edges = elements (each covered by a collection of sets).
    Cost w(v) = weight of set v.
    Threshold rounding gives a d-approximation to the weighted objective.
    """
    print("APPLICATION 2: Weighted Set Cover Approximation")
    print("=" * 50)
    print()

    # Universe U = {a, b, c, d, e}, Sets = S0..S5 with costs
    set_costs = {
        0: Fraction(3),   # S0 covers {a, b}
        1: Fraction(5),   # S1 covers {b, c, d}
        2: Fraction(2),   # S2 covers {a, c}
        3: Fraction(4),   # S3 covers {d, e}
        4: Fraction(6),   # S4 covers {a, b, c, d, e}
        5: Fraction(1),   # S5 covers {e}
    }

    # Edges = elements; each element is "covered by" certain sets
    coverage = {
        'a': frozenset({0, 2, 4}),
        'b': frozenset({0, 1, 4}),
        'c': frozenset({1, 2, 4}),
        'd': frozenset({1, 3, 4}),
        'e': frozenset({3, 4, 5}),
    }
    edges = list(coverage.values())
    vertices = set(range(6))
    d = max(len(e) for e in edges)

    # Fractional solution (LP relaxation)
    x = {
        0: Fraction(1, 3), 1: Fraction(1, 3), 2: Fraction(1, 3),
        3: Fraction(1, 3), 4: Fraction(0), 5: Fraction(2, 3),
    }

    frac_cost = sum(set_costs[v] * x[v] for v in vertices)
    print(f"Universe: {list(coverage.keys())}")
    print(f"Sets: {len(vertices)}, max frequency (rank d) = {d}")
    print(f"Fractional solution: {dict(x)}")
    print(f"Fractional cost = {frac_cost}")
    print()

    # Threshold rounding
    S, info = threshold_round(vertices, edges, x, d)
    int_cost = sum(set_costs[v] for v in S)
    print(f"Selected sets: {sorted(S)}")
    print(f"Integral cost = {int_cost}")
    print(f"Cost ratio = {int_cost / frac_cost if frac_cost > 0 else 'N/A'}")
    print(f"Bound: cost ≤ d × fractional = {d} × {frac_cost} = {d * frac_cost}")
    print(f"Bound satisfied: {int_cost <= d * frac_cost}")
    print()

    for elem, covering_sets in coverage.items():
        selected_covering = sorted(covering_sets & S)
        print(f"  Element {elem}: covered by sets {selected_covering}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 3: Fault-Tolerant System Design
# ──────────────────────────────────────────────────────────────────────────────

def fault_tolerant_demo():
    """
    Design fault-tolerant systems using tropical transversal theory.

    Each "edge" represents a critical subsystem with redundant components.
    A transversal selects components ensuring every subsystem has backup.
    The retraction property guarantees that integral solutions are stable
    under the threshold operator.
    """
    print("APPLICATION 3: Fault-Tolerant System Design")
    print("=" * 50)
    print()

    # System with 6 components, 4 subsystems
    components = set(range(6))
    subsystems = [
        frozenset({0, 1}),       # Power supply (2 redundant units)
        frozenset({1, 2, 3}),    # Computing (3 redundant processors)
        frozenset({3, 4}),       # Storage (2 redundant drives)
        frozenset({4, 5, 0}),    # Network (3 redundant links)
    ]
    d = max(len(s) for s in subsystems)

    print(f"Components: {sorted(components)}")
    print(f"Subsystems: {[sorted(s) for s in subsystems]}")
    print(f"Max redundancy level (rank d) = {d}")
    print()

    # Fractional reliability assignment
    x = {0: Fraction(1, 2), 1: Fraction(1, 2), 2: Fraction(1, 3),
         3: Fraction(1, 2), 4: Fraction(1, 2), 5: Fraction(1, 3)}

    print(f"Fractional reliability: {dict(x)}")
    S, info = threshold_round(components, subsystems, x, d)
    print(f"Active components (threshold 1/{d}): {sorted(S)}")
    print(f"All subsystems have backup: {info['is_transversal']}")
    print()

    # Verify retraction: integral assignment is fixed
    chi_S = {v: Fraction(1) if v in S else Fraction(0) for v in components}
    S2, _ = threshold_round(components, subsystems, chi_S, d)
    print(f"Retraction check: T_τ(χ_S) = {sorted(S2)}")
    print(f"Fixed point: {S == S2} (Theorem 2b)")
    print()

    # Tropical extremality analysis
    ext = detect_tropical_extremality(components, subsystems, S, d)
    print(f"Tropical extremality analysis of selected components:")
    print(f"  Minimal: {ext['is_minimal']}")
    print(f"  Irreducible: {ext['is_irreducible']}")
    print(f"  Tropically extremal: {ext['tropically_extremal']}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   APPLICATIONS OF TROPICAL HYPERGRAPH TRANSVERSAL THEORY       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    sensor_placement_demo()
    weighted_set_cover_demo()
    fault_tolerant_demo()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Demo: Tropical Hypergraph Transversal Theory

This script demonstrates the core theorems of tropical hypergraph transversal theory:

1. Threshold rounding at 1/d produces transversals for rank-d hypergraphs
2. Threshold monotonicity and indicator retraction
3. Unique active witness forces integrality
4. Upward closure of the threshold family
5. Conjecture testing: threshold of BFS is tropically extremal

We enumerate hypergraphs on small vertex sets, compute fractional transversals,
apply threshold rounding, and test the tropical extremality conjecture.
"""

from itertools import combinations, product
from fractions import Fraction
from typing import List, Set, FrozenSet, Dict, Tuple, Optional
import sys


# ──────────────────────────────────────────────────────────────────────────────
# Core definitions (matching the Lean formalization)
# ──────────────────────────────────────────────────────────────────────────────

def threshold_set(tau: Fraction, x: Dict[int, Fraction]) -> FrozenSet[int]:
    """The threshold rounding operator: T_τ(x) = {v | x(v) ≥ τ}."""
    return frozenset(v for v, xv in x.items() if xv >= tau)


def indicator_weight(S: FrozenSet[int], vertices: Set[int]) -> Dict[int, Fraction]:
    """Indicator function: 1 on S, 0 elsewhere."""
    return {v: Fraction(1) if v in S else Fraction(0) for v in vertices}


def support(x: Dict[int, Fraction]) -> FrozenSet[int]:
    """Support of x: {v | x(v) ≠ 0}."""
    return frozenset(v for v, xv in x.items() if xv != 0)


def edge_slack(edge: FrozenSet[int], x: Dict[int, Fraction]) -> Fraction:
    """Slack of the covering constraint on edge e: Σ_{v∈e} x(v) - 1."""
    return sum(x.get(v, Fraction(0)) for v in edge) - 1


def is_active_on(edge: FrozenSet[int], x: Dict[int, Fraction]) -> bool:
    """Whether the covering constraint on edge e is active (tight) at x."""
    return sum(x.get(v, Fraction(0)) for v in edge) == 1


def is_feasible(edges: List[FrozenSet[int]], x: Dict[int, Fraction]) -> bool:
    """Whether x is a feasible fractional transversal."""
    return (all(xv >= 0 for xv in x.values()) and
            all(sum(x.get(v, Fraction(0)) for v in e) >= 1 for e in edges))


def is_transversal(edges: List[FrozenSet[int]], S: FrozenSet[int]) -> bool:
    """Whether S is an integral transversal (hits every edge)."""
    return all(len(e & S) > 0 for e in edges)


def is_minimal_transversal(edges: List[FrozenSet[int]], S: FrozenSet[int]) -> bool:
    """Whether S is a minimal transversal (no proper subset is a transversal)."""
    if not is_transversal(edges, S):
        return False
    for v in S:
        if is_transversal(edges, S - {v}):
            return False
    return True


def has_unique_active_witness(edges: List[FrozenSet[int]],
                               x: Dict[int, Fraction]) -> bool:
    """Check the unique active witness property:
    each support vertex has an active edge isolating it from other support vertices."""
    supp = support(x)
    for v in supp:
        found_witness = False
        for e in edges:
            if v in e and is_active_on(e, x):
                other_supp_in_e = {u for u in supp if u != v and u in e}
                if len(other_supp_in_e) == 0:
                    found_witness = True
                    break
        if not found_witness:
            return False
    return True


def hypergraph_rank(edges: List[FrozenSet[int]]) -> int:
    """Maximum edge size."""
    return max(len(e) for e in edges) if edges else 0


# ──────────────────────────────────────────────────────────────────────────────
# Hypergraph enumeration
# ──────────────────────────────────────────────────────────────────────────────

def enumerate_hypergraphs(n: int, min_edges: int = 1, max_edges: int = None):
    """Enumerate non-trivial hypergraphs on vertex set {0,...,n-1}.
    We restrict to non-empty edges and reasonable sizes."""
    vertices = set(range(n))
    # All possible non-empty edges
    all_edges = []
    for k in range(1, n + 1):
        for edge in combinations(range(n), k):
            all_edges.append(frozenset(edge))

    if max_edges is None:
        max_edges = min(len(all_edges), 6)  # cap for efficiency

    for num_edges in range(min_edges, max_edges + 1):
        for edge_combo in combinations(all_edges, num_edges):
            yield list(edge_combo)


# ──────────────────────────────────────────────────────────────────────────────
# Demo 1: Threshold Transversal Theorem
# ──────────────────────────────────────────────────────────────────────────────

def demo_threshold_transversal():
    """Demonstrate Theorem 1: threshold at 1/d yields a transversal."""
    print("=" * 70)
    print("DEMO 1: Threshold Rounding Produces Transversals")
    print("=" * 70)
    print()

    # Example hypergraph
    edges = [frozenset({0, 1, 2}), frozenset({1, 2, 3}), frozenset({0, 3})]
    vertices = {0, 1, 2, 3}
    d = hypergraph_rank(edges)
    tau = Fraction(1, d)

    print(f"Hypergraph: V = {vertices}, E = {[set(e) for e in edges]}")
    print(f"Rank d = {d}, threshold τ = 1/d = {tau}")
    print()

    # Fractional transversal: x = (1/3, 1/3, 1/3, 1/2)
    x = {0: Fraction(1, 3), 1: Fraction(1, 3), 2: Fraction(1, 3), 3: Fraction(1, 2)}
    print(f"Fractional assignment x = {dict(x)}")
    print(f"Feasible: {is_feasible(edges, x)}")

    for e in edges:
        s = sum(x[v] for v in e)
        print(f"  Edge {set(e)}: sum = {s} {'≥' if s >= 1 else '<'} 1")

    S = threshold_set(tau, x)
    print(f"\nThreshold set T_{{1/{d}}}(x) = {set(S)}")
    print(f"Is transversal: {is_transversal(edges, S)}")

    for e in edges:
        hit = e & S
        print(f"  Edge {set(e)} ∩ S = {set(hit)} {'✓' if hit else '✗'}")
    print()

    # Verify by contradiction principle
    print("Tropical witness principle verification:")
    for e in edges:
        witnesses = [v for v in e if x[v] >= tau]
        print(f"  Edge {set(e)}: witnesses with x(v) ≥ 1/{d} = {witnesses}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 2: Monotonicity and Retraction
# ──────────────────────────────────────────────────────────────────────────────

def demo_monotonicity_retraction():
    """Demonstrate Theorems 2a and 2b."""
    print("=" * 70)
    print("DEMO 2: Threshold Monotonicity and Indicator Retraction")
    print("=" * 70)
    print()

    vertices = {0, 1, 2, 3}
    tau = Fraction(1, 3)

    # Monotonicity: x ≤ y ⟹ T_τ(x) ⊆ T_τ(y)
    x = {0: Fraction(1, 6), 1: Fraction(1, 3), 2: Fraction(1, 2), 3: Fraction(0)}
    y = {0: Fraction(1, 3), 1: Fraction(1, 2), 2: Fraction(2, 3), 3: Fraction(1, 6)}

    print(f"τ = {tau}")
    print(f"x = {dict(x)}")
    print(f"y = {dict(y)}")
    print(f"x ≤ y coordinatewise: {all(x[v] <= y[v] for v in vertices)}")
    Sx = threshold_set(tau, x)
    Sy = threshold_set(tau, y)
    print(f"T_τ(x) = {set(Sx)}")
    print(f"T_τ(y) = {set(Sy)}")
    print(f"T_τ(x) ⊆ T_τ(y): {Sx <= Sy}")
    print()

    # Retraction: T_τ(χ_S) = S for τ ∈ (0, 1]
    S = frozenset({1, 3})
    chi_S = indicator_weight(S, vertices)
    print(f"S = {set(S)}")
    print(f"χ_S = {dict(chi_S)}")
    for tau_test in [Fraction(1, 3), Fraction(1, 2), Fraction(1), Fraction(1, 10)]:
        result = threshold_set(tau_test, chi_S)
        print(f"  T_{{{tau_test}}}(χ_S) = {set(result)} {'= S ✓' if result == S else '≠ S ✗'}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 3: Active Witness Forces Integrality
# ──────────────────────────────────────────────────────────────────────────────

def demo_active_witness():
    """Demonstrate Theorem 3: unique active witness ⟹ integrality."""
    print("=" * 70)
    print("DEMO 3: Active-Edge Witness Forces Integrality")
    print("=" * 70)
    print()

    # Construct a fractional transversal with unique active witnesses
    # Edges: {0,1}, {2,3}, {0,2}
    edges = [frozenset({0, 1}), frozenset({2, 3}), frozenset({0, 2})]
    x = {0: Fraction(1), 1: Fraction(0), 2: Fraction(0), 3: Fraction(1)}

    print(f"Edges: {[set(e) for e in edges]}")
    print(f"x = {dict(x)}")
    print(f"Support(x) = {set(support(x))}")
    print()

    # Check active witness property
    supp = support(x)
    for v in supp:
        print(f"  Vertex {v} (x({v}) = {x[v]}):")
        for e in edges:
            if v in e and is_active_on(e, x):
                other = {u for u in supp if u != v and u in e}
                status = "WITNESS ✓" if len(other) == 0 else f"shared with {other}"
                print(f"    Active edge {set(e)}: {status}")

    print(f"\nHas unique active witness: {has_unique_active_witness(edges, x)}")
    print(f"All support values equal 1: {all(x[v] == 1 for v in supp)}")
    print()

    # Counter-example: non-unique witness
    x2 = {0: Fraction(1, 2), 1: Fraction(1, 2), 2: Fraction(1, 2), 3: Fraction(1, 2)}
    print(f"Counter-example: x = {dict(x2)}")
    print(f"Support(x) = {set(support(x2))}")
    print(f"Has unique active witness: {has_unique_active_witness(edges, x2)}")
    print(f"All support values equal 1: {all(x2[v] == 1 for v in support(x2))}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 4: Upward Closure
# ──────────────────────────────────────────────────────────────────────────────

def demo_upward_closure():
    """Demonstrate Theorem 4: threshold family is upward closed."""
    print("=" * 70)
    print("DEMO 4: Upward Closure of Threshold Family")
    print("=" * 70)
    print()

    vertices = {0, 1, 2, 3}
    tau = Fraction(1, 3)

    x = {0: Fraction(1, 2), 1: Fraction(1, 6), 2: Fraction(2, 3), 3: Fraction(0)}
    S = threshold_set(tau, x)
    print(f"x = {dict(x)}, τ = {tau}")
    print(f"S = T_τ(x) = {set(S)}")

    # For each superset S' ⊇ S, construct y with T_τ(y) = S'
    for extra_size in range(1, len(vertices - S) + 1):
        for extra in combinations(vertices - S, extra_size):
            S_prime = S | frozenset(extra)
            # Construct y: keep x on S, set τ on S' \ S, keep x elsewhere
            y = {}
            for v in vertices:
                if v in S_prime and v not in S:
                    y[v] = tau  # raise to threshold
                else:
                    y[v] = x[v]
            T = threshold_set(tau, y)
            status = "✓" if T == S_prime else "✗"
            print(f"  S' = {set(S_prime)}: y = {dict(y)}, T_τ(y) = {set(T)} {status}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 5: Conjecture Testing - BFS Tropical Extremality
# ──────────────────────────────────────────────────────────────────────────────

def find_fractional_transversals_on_grid(edges, vertices, d, grid_denom=None):
    """Find feasible fractional transversals on a rational grid {0, 1/d, ..., 1}."""
    if grid_denom is None:
        grid_denom = d
    grid_values = [Fraction(k, grid_denom) for k in range(grid_denom + 1)]
    results = []

    for assignment in product(grid_values, repeat=len(vertices)):
        x = dict(zip(sorted(vertices), assignment))
        if is_feasible(edges, x):
            results.append(x)
    return results


def demo_conjecture_testing():
    """Test the tropical extremality conjecture on small hypergraphs."""
    print("=" * 70)
    print("DEMO 5: Conjecture Testing — BFS Tropical Extremality")
    print("=" * 70)
    print()
    print("Conjecture: Thresholding a 'basic' feasible fractional transversal")
    print("at 1/d produces a minimal (tropically extremal) integral transversal.")
    print()

    n_max = 5
    counterexamples = 0
    total_tests = 0

    for n in range(2, n_max + 1):
        count = 0
        for edges in enumerate_hypergraphs(n, min_edges=1, max_edges=min(4, n)):
            if not edges:
                continue
            d = hypergraph_rank(edges)
            if d == 0:
                continue
            tau = Fraction(1, d)
            vertices = set(range(n))

            # Find feasible points on grid
            feasible = find_fractional_transversals_on_grid(edges, vertices, d)
            if not feasible:
                continue

            for x in feasible[:10]:  # sample up to 10
                S = threshold_set(tau, x)
                if not is_transversal(edges, S):
                    print(f"  BUG: threshold failed! n={n}, edges={edges}, x={x}")
                    continue

                total_tests += 1
                minimal = is_minimal_transversal(edges, S)
                if not minimal:
                    counterexamples += 1
                    if counterexamples <= 5:
                        print(f"  Non-minimal result: n={n}")
                        print(f"    Edges: {[set(e) for e in edges]}")
                        print(f"    x = {dict(x)}, S = {set(S)}")
                        removable = [v for v in S if is_transversal(edges, S - {v})]
                        print(f"    Removable vertices: {removable}")

            count += 1
            if count >= 50:  # cap per n
                break

        print(f"n = {n}: tested {min(count, 50)} hypergraphs")

    print(f"\nTotal tests: {total_tests}")
    print(f"Non-minimal threshold results: {counterexamples}")
    if counterexamples > 0:
        print("→ Minimality is NOT guaranteed by threshold rounding alone.")
        print("  This is expected: tropical extremality requires witness structure.")
    else:
        print("→ All threshold results were minimal in this sample!")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 6: Comprehensive Example
# ──────────────────────────────────────────────────────────────────────────────

def demo_comprehensive():
    """A comprehensive example tying all theorems together."""
    print("=" * 70)
    print("DEMO 6: Comprehensive Example — All Theorems in Action")
    print("=" * 70)
    print()

    # Fano-plane-like hypergraph (small version)
    edges = [
        frozenset({0, 1, 2}),
        frozenset({0, 3, 4}),
        frozenset({1, 3, 5}),
        frozenset({2, 4, 5}),
    ]
    vertices = set(range(6))
    d = hypergraph_rank(edges)
    tau = Fraction(1, d)

    print(f"Hypergraph: V = {vertices}")
    print(f"Edges: {[set(e) for e in edges]}")
    print(f"Rank d = {d}, threshold τ = 1/d = {tau}")
    print()

    # Fractional transversal
    x = {v: Fraction(1, 3) for v in vertices}
    print(f"1. Uniform fractional transversal: x(v) = 1/3 for all v")
    print(f"   Feasible: {is_feasible(edges, x)}")

    S = threshold_set(tau, x)
    print(f"   T_{{1/3}}(x) = {set(S)}")
    print(f"   Is transversal: {is_transversal(edges, S)} (Theorem 1 ✓)")
    print()

    # Indicator retraction
    chi_S = indicator_weight(S, vertices)
    T = threshold_set(tau, chi_S)
    print(f"2. Indicator retraction: T_τ(χ_S) = {set(T)}")
    print(f"   Equals S: {T == S} (Theorem 2b ✓)")
    print()

    # Active witness
    x_int = {0: Fraction(1), 1: Fraction(0), 2: Fraction(0),
             3: Fraction(0), 4: Fraction(1), 5: Fraction(1)}
    print(f"3. Integral solution: x = {dict(x_int)}")
    print(f"   Support: {set(support(x_int))}")
    has_wit = has_unique_active_witness(edges, x_int)
    print(f"   Has unique active witness: {has_wit}")
    if has_wit:
        print(f"   All support values = 1: {all(x_int[v] == 1 for v in support(x_int))} (Theorem 3 ✓)")
    print()

    # Upward closure
    S_small = frozenset({0, 5})
    x_small = {0: Fraction(1, 2), 1: Fraction(1, 4), 2: Fraction(1, 4),
               3: Fraction(1, 4), 4: Fraction(1, 4), 5: Fraction(1, 2)}
    S_check = threshold_set(tau, x_small)
    print(f"4. Upward closure: x = {dict(x_small)}")
    print(f"   T_τ(x) = {set(S_check)}")
    S_bigger = S_check | frozenset({1, 3})
    y = {v: (max(x_small[v], tau) if v in S_bigger else x_small[v]) for v in vertices}
    T_bigger = threshold_set(tau, y)
    print(f"   S' = {set(S_bigger)} ⊇ T_τ(x)")
    print(f"   Constructed y: T_τ(y) = {set(T_bigger)}")
    print(f"   T_τ(y) = S': {T_bigger == S_bigger} (Theorem 4 ✓)")
    feas_y = is_feasible(edges, y)
    print(f"   y is feasible: {feas_y} (Theorem 5 ✓)")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   TROPICAL HYPERGRAPH TRANSVERSAL THEORY — Interactive Demo        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_threshold_transversal()
    demo_monotonicity_retraction()
    demo_active_witness()
    demo_upward_closure()
    demo_conjecture_testing()
    demo_comprehensive()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_threshold = read_file('visualize_threshold.py')
viz_witness = read_file('visualize_witness.py')
viz_upward = read_file('visualize_upward_closure.py')
lean_code = read_file('Pythagorean/TropicalHypergraphTransversal.lean')

# Interactive demo HTML
interactive_threshold = '''<div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
  <h3 style="color: #2185a8;">Interactive Threshold Rounding Demo</h3>
  <p>Adjust the threshold τ and vertex values to see how threshold rounding works.</p>

  <div style="margin: 15px 0;">
    <label>Threshold τ: <span id="tau-val">0.33</span></label>
    <input type="range" id="tau-slider" min="0" max="100" value="33" style="width: 300px;"
           oninput="updateThreshold()">
  </div>

  <div id="vertex-controls" style="margin: 15px 0;"></div>

  <div style="display: flex; gap: 20px; margin: 20px 0;">
    <div style="flex: 1;">
      <h4>Vertex Values</h4>
      <canvas id="bar-chart" width="350" height="200"></canvas>
    </div>
    <div style="flex: 1;">
      <h4>Threshold Set T_τ(x)</h4>
      <div id="threshold-result" style="font-size: 18px; padding: 20px; background: #f0f8ff; border-radius: 8px; min-height: 60px;"></div>
    </div>
  </div>

  <div id="edge-check" style="margin: 15px 0; padding: 15px; background: #f9f9f9; border-radius: 8px;">
    <h4>Edge Coverage Check</h4>
    <p>Edge {v₀, v₁, v₂}: <span id="edge-status"></span></p>
  </div>

  <script>
    const n = 5;
    const vals = [0.5, 0.3, 0.7, 0.1, 0.4];
    const edge = [0, 1, 2];

    function initControls() {
      const container = document.getElementById('vertex-controls');
      for (let i = 0; i < n; i++) {
        const div = document.createElement('div');
        div.style.marginBottom = '5px';
        div.innerHTML = `v${i}: <input type="range" id="v${i}" min="0" max="100" value="${vals[i]*100}"
          style="width:200px;" oninput="updateThreshold()"> <span id="v${i}-val">${vals[i].toFixed(2)}</span>`;
        container.appendChild(div);
      }
    }

    function updateThreshold() {
      const tau = document.getElementById('tau-slider').value / 100;
      document.getElementById('tau-val').textContent = tau.toFixed(2);

      const canvas = document.getElementById('bar-chart');
      const ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const barW = 50, gap = 20, startX = 30;
      const maxH = 160;

      // Draw threshold line
      const tauY = canvas.height - tau * maxH - 20;
      ctx.strokeStyle = '#ff4444';
      ctx.lineWidth = 2;
      ctx.setLineDash([5, 5]);
      ctx.beginPath();
      ctx.moveTo(0, tauY);
      ctx.lineTo(canvas.width, tauY);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.fillStyle = '#ff4444';
      ctx.font = '10px Arial';
      ctx.fillText('τ=' + tau.toFixed(2), canvas.width - 50, tauY - 5);

      const thresholdSet = [];

      for (let i = 0; i < n; i++) {
        const v = document.getElementById('v' + i).value / 100;
        document.getElementById('v' + i + '-val').textContent = v.toFixed(2);
        vals[i] = v;

        const x = startX + i * (barW + gap);
        const h = v * maxH;
        const y = canvas.height - h - 20;

        const inThreshold = v >= tau;
        if (inThreshold) thresholdSet.push('v' + i);

        ctx.fillStyle = inThreshold ? '#2185a8' : '#cccccc';
        ctx.fillRect(x, y, barW, h);
        ctx.strokeStyle = '#333';
        ctx.lineWidth = 1;
        ctx.strokeRect(x, y, barW, h);

        ctx.fillStyle = '#333';
        ctx.font = '12px Arial';
        ctx.textAlign = 'center';
        ctx.fillText('v' + i, x + barW/2, canvas.height - 5);
      }

      document.getElementById('threshold-result').innerHTML =
        thresholdSet.length > 0
          ? '{' + thresholdSet.join(', ') + '}'
          : '∅ (empty set)';

      // Edge check
      const edgeHit = edge.some(i => vals[i] >= tau);
      const edgeSum = edge.reduce((s, i) => s + vals[i], 0);
      document.getElementById('edge-status').innerHTML =
        `Sum = ${edgeSum.toFixed(2)} ${edgeSum >= 1 ? '≥' : '<'} 1 | ` +
        `Hit by threshold: ${edgeHit ? '<span style="color:green">✓ YES</span>' : '<span style="color:red">✗ NO</span>'}`;
    }

    initControls();
    updateThreshold();
  </script>
</div>'''

interactive_witness = '''<div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
  <h3 style="color: #2185a8;">Active Witness Visualization</h3>
  <p>Click vertices to toggle their values between 0 and 1. Active edges (sum = 1) are highlighted red.
     The unique active witness property holds when each blue vertex has a red edge containing only that blue vertex.</p>

  <svg id="witness-svg" width="400" height="400" viewBox="-150 -150 300 300">
    <defs>
      <marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="4" markerHeight="4" orient="auto">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="gold"/>
      </marker>
    </defs>
  </svg>

  <div id="witness-info" style="margin: 15px 0; padding: 15px; background: #f0f8ff; border-radius: 8px;">
  </div>

  <script>
    const wn = 5;
    const wedges = [[0,1],[1,2],[2,3],[3,4],[4,0]];
    let wvals = [1, 0, 1, 0, 1];

    function drawWitness() {
      const svg = document.getElementById('witness-svg');
      svg.innerHTML = svg.querySelector('defs').outerHTML;

      const r = 100;
      const positions = [];
      for (let i = 0; i < wn; i++) {
        const a = (2 * Math.PI * i / wn) - Math.PI / 2;
        positions.push([r * Math.cos(a), r * Math.sin(a)]);
      }

      // Draw edges
      for (let ei = 0; ei < wedges.length; ei++) {
        const [u, v] = wedges[ei];
        const esum = wvals[u] + wvals[v];
        const active = esum === 1;
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', positions[u][0]);
        line.setAttribute('y1', positions[u][1]);
        line.setAttribute('x2', positions[v][0]);
        line.setAttribute('y2', positions[v][1]);
        line.setAttribute('stroke', active ? '#ff4444' : '#cccccc');
        line.setAttribute('stroke-width', active ? 4 : 2);
        svg.appendChild(line);

        // Edge label
        const mx = (positions[u][0] + positions[v][0]) / 2;
        const my = (positions[u][1] + positions[v][1]) / 2;
        const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        label.setAttribute('x', mx + 10);
        label.setAttribute('y', my);
        label.setAttribute('font-size', '10');
        label.setAttribute('fill', active ? '#ff4444' : '#999');
        label.textContent = 'e' + ei + '(Σ=' + esum + ')';
        svg.appendChild(label);
      }

      // Draw vertices
      for (let i = 0; i < wn; i++) {
        const [cx, cy] = positions[i];
        const inSupp = wvals[i] !== 0;
        const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        circle.setAttribute('cx', cx);
        circle.setAttribute('cy', cy);
        circle.setAttribute('r', 20);
        circle.setAttribute('fill', inSupp ? '#2185a8' : '#e8e8e8');
        circle.setAttribute('stroke', '#333');
        circle.setAttribute('stroke-width', 2);
        circle.setAttribute('cursor', 'pointer');
        circle.onclick = () => { wvals[i] = wvals[i] === 0 ? 1 : 0; drawWitness(); };
        svg.appendChild(circle);

        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', cx);
        text.setAttribute('y', cy + 5);
        text.setAttribute('text-anchor', 'middle');
        text.setAttribute('fill', inSupp ? 'white' : '#666');
        text.setAttribute('font-size', '14');
        text.setAttribute('font-weight', 'bold');
        text.setAttribute('pointer-events', 'none');
        text.textContent = 'v' + i + '=' + wvals[i];
        svg.appendChild(text);
      }

      // Check witness property
      const supp = [];
      for (let i = 0; i < wn; i++) if (wvals[i] !== 0) supp.push(i);

      let hasWitness = true;
      let witnessInfo = '';
      for (const v of supp) {
        let found = false;
        for (let ei = 0; ei < wedges.length; ei++) {
          const e = wedges[ei];
          if (!e.includes(v)) continue;
          const esum = e.reduce((s, u) => s + wvals[u], 0);
          if (esum !== 1) continue;
          const otherSupp = e.filter(u => u !== v && wvals[u] !== 0);
          if (otherSupp.length === 0) {
            found = true;
            witnessInfo += `<br>v${v}: witness = e${ei}`;
            break;
          }
        }
        if (!found) { hasWitness = false; witnessInfo += `<br>v${v}: NO witness`; }
      }

      document.getElementById('witness-info').innerHTML =
        `<b>Support:</b> {${supp.map(v => 'v' + v).join(', ')}}<br>` +
        `<b>Unique active witness:</b> ${hasWitness ? '<span style="color:green">YES ✓</span>' : '<span style="color:red">NO ✗</span>'}` +
        witnessInfo +
        (hasWitness && supp.length > 0 ? '<br><b>→ Theorem 3: all support values must equal 1 ✓</b>' : '');
    }

    drawWitness();
  </script>
</div>'''

package = {
    "title": "Hypergraph Transversals as Tropical Convex Optimization",
    "domain": "Tropical Geometry / Combinatorial Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Hypergraph Transversal Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Threshold Rounding",
            "pseudocode": "Algorithm ThresholdRound(V, E, x, d):\n  1. τ ← 1/d\n  2. S ← {v ∈ V : x_v ≥ τ}\n  3. Return S\nComplexity: O(|V|) time, O(|V|) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Threshold Regions and Retraction",
            "code": viz_threshold,
            "description": "Three-panel visualization showing threshold regions in 2D assignment space, monotonicity of the threshold operator, and the retraction property on indicator functions."
        },
        {
            "name": "Active-Edge Witness Structure",
            "code": viz_witness,
            "description": "Visualization of the unique active witness property on a pentagon hypergraph, showing the incidence heatmap with active constraints and the witness structure diagram."
        },
        {
            "name": "Upward Closure in the Subset Lattice",
            "code": viz_upward,
            "description": "Hasse diagram of the subset lattice showing upward closure of threshold sets, and a bar chart demonstrating feasibility-preserving construction."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Threshold Rounding",
            "html": interactive_threshold,
            "description": "Adjust threshold τ and vertex values with sliders to see how threshold rounding produces transversals in real-time."
        },
        {
            "name": "Active Witness Explorer",
            "html": interactive_witness,
            "description": "Click vertices to toggle values and explore the unique active witness property on a pentagon hypergraph."
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"Size: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualization: Threshold Rounding as Tropical Projection

This script visualizes the core geometric insight: threshold rounding
acts as a projection from the fractional feasible region onto integral
transversals. We show:
1. The threshold boundary in 2D assignment space
2. How different fractional points map to the same integral transversal
3. The monotonicity structure of the threshold operator
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import PatchCollection

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ──────────────────────────────────────────────────────────────────────────────
# Panel 1: Threshold regions in 2D
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[0]
ax.set_title("Threshold Regions in 2D\n(τ = 1/2, rank d = 2)", fontsize=12, fontweight='bold')

tau = 0.5
# Draw the four threshold regions
colors = ['#e8f4f8', '#b3d9e8', '#6bb3d1', '#2185a8']
labels = ['T = ∅', 'T = {v₂}', 'T = {v₁}', 'T = {v₁,v₂}']

# Region T = ∅: [0,τ) × [0,τ)
rect1 = patches.Rectangle((0, 0), tau, tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[0], alpha=0.7)
ax.add_patch(rect1)
ax.text(tau/4, tau/4, 'T = ∅', ha='center', va='center', fontsize=9)

# Region T = {v₁}: [τ,1] × [0,τ)
rect2 = patches.Rectangle((tau, 0), 1-tau, tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[2], alpha=0.7)
ax.add_patch(rect2)
ax.text(tau + (1-tau)/2, tau/4, 'T = {v₁}', ha='center', va='center', fontsize=9)

# Region T = {v₂}: [0,τ) × [τ,1]
rect3 = patches.Rectangle((0, tau), tau, 1-tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[1], alpha=0.7)
ax.add_patch(rect3)
ax.text(tau/4, tau + (1-tau)/2, 'T = {v₂}', ha='center', va='center', fontsize=9)

# Region T = {v₁,v₂}: [τ,1] × [τ,1]
rect4 = patches.Rectangle((tau, tau), 1-tau, 1-tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[3], alpha=0.7)
ax.add_patch(rect4)
ax.text(tau + (1-tau)/2, tau + (1-tau)/2, 'T = {v₁,v₂}', ha='center', va='center',
        fontsize=9, color='white')

# Draw threshold lines
ax.axhline(y=tau, color='red', linewidth=2, linestyle='--', alpha=0.8)
ax.axvline(x=tau, color='red', linewidth=2, linestyle='--', alpha=0.8)

# Draw the feasibility constraint: x₁ + x₂ ≥ 1 for single edge {v₁, v₂}
xs = np.linspace(0, 1, 100)
ax.fill_between(xs, 1 - xs, 1, alpha=0.15, color='green')
ax.plot(xs, np.maximum(1 - xs, 0), 'g-', linewidth=2, label='x₁ + x₂ = 1')

# Sample points
points = [(0.7, 0.6), (0.3, 0.8), (0.6, 0.4), (0.9, 0.2)]
for p in points:
    ax.plot(*p, 'ko', markersize=6)
    ax.annotate(f'({p[0]:.1f},{p[1]:.1f})', p, textcoords="offset points",
                xytext=(5, 5), fontsize=7)

# Mark indicator (retraction) points
ax.plot(1, 1, 'r*', markersize=15, label='Indicator χ_{v₁,v₂}')
ax.plot(1, 0, 'r*', markersize=15)
ax.plot(0, 1, 'r*', markersize=15)

ax.set_xlim(-0.05, 1.1)
ax.set_ylim(-0.05, 1.1)
ax.set_xlabel('x(v₁)', fontsize=11)
ax.set_ylabel('x(v₂)', fontsize=11)
ax.legend(loc='upper right', fontsize=8)
ax.set_aspect('equal')

# ──────────────────────────────────────────────────────────────────────────────
# Panel 2: Monotonicity visualization
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[1]
ax.set_title("Monotonicity: x ≤ y ⟹ T(x) ⊆ T(y)\n(coordinatewise order)", fontsize=12, fontweight='bold')

tau = 1/3
# Show two points x ≤ y and their threshold sets
x_point = np.array([0.2, 0.4, 0.1, 0.5, 0.35])
y_point = np.array([0.4, 0.5, 0.3, 0.6, 0.4])

vertices = ['v₀', 'v₁', 'v₂', 'v₃', 'v₄']
x_pos = np.arange(len(vertices))
width = 0.35

bars_x = ax.bar(x_pos - width/2, x_point, width, label='x(v)', color='#6bb3d1', alpha=0.8)
bars_y = ax.bar(x_pos + width/2, y_point, width, label='y(v)', color='#2185a8', alpha=0.8)

ax.axhline(y=tau, color='red', linewidth=2, linestyle='--', label=f'τ = 1/3')

# Mark threshold memberships
for i in range(len(vertices)):
    if x_point[i] >= tau:
        ax.text(i - width/2, x_point[i] + 0.02, '∈T(x)', ha='center', fontsize=7, color='#6bb3d1')
    if y_point[i] >= tau:
        ax.text(i + width/2, y_point[i] + 0.02, '∈T(y)', ha='center', fontsize=7, color='#2185a8')

ax.set_xlabel('Vertices', fontsize=11)
ax.set_ylabel('Assignment value', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels(vertices)
ax.legend(fontsize=9)
ax.set_ylim(0, 0.8)

# Add T(x) ⊆ T(y) annotation
Tx = {v for v, val in zip(vertices, x_point) if val >= tau}
Ty = {v for v, val in zip(vertices, y_point) if val >= tau}
ax.text(0.5, -0.12, f'T(x) = {Tx}  ⊆  T(y) = {Ty}', transform=ax.transAxes,
        ha='center', fontsize=10, style='italic')

# ──────────────────────────────────────────────────────────────────────────────
# Panel 3: Retraction property
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[2]
ax.set_title("Retraction: T_τ(χ_S) = S\n(threshold fixes integral points)", fontsize=12, fontweight='bold')

# Show the indicator function and its threshold set for different τ
S = {0, 2, 4}  # The set S
n = 6
vertices_idx = list(range(n))
chi_S = [1 if i in S else 0 for i in vertices_idx]

tau_values = [0.1, 0.3, 0.5, 0.7, 1.0]
colors_tau = plt.cm.viridis(np.linspace(0.2, 0.9, len(tau_values)))

bar_width = 0.6
ax.bar(vertices_idx, chi_S, bar_width, color=['#2185a8' if i in S else '#e8f4f8'
       for i in vertices_idx], edgecolor='gray', linewidth=1)

for i, tau_val in enumerate(tau_values):
    ax.axhline(y=tau_val, color=colors_tau[i], linewidth=1.5, linestyle='--',
               alpha=0.7, label=f'τ = {tau_val}')
    # All return S since 0 < τ ≤ 1
    T = {v for v in vertices_idx if chi_S[v] >= tau_val}
    # Add small annotation
    ax.text(n + 0.2, tau_val, f'T = {T}', fontsize=7, va='center', color=colors_tau[i])

ax.set_xlabel('Vertices', fontsize=11)
ax.set_ylabel('χ_S(v)', fontsize=11)
ax.set_xticks(vertices_idx)
ax.set_xticklabels([f'v{i}' for i in vertices_idx])
ax.legend(loc='center right', fontsize=7, bbox_to_anchor=(1.45, 0.5))
ax.set_ylim(-0.1, 1.3)
ax.set_xlim(-0.5, n + 1.5)

# Annotate S
ax.text(0.5, -0.12, f'S = {S}: T_τ(χ_S) = S for all τ ∈ (0, 1]',
        transform=ax.transAxes, ha='center', fontsize=10, style='italic')

plt.tight_layout()
plt.savefig('threshold_visualization.png', dpi=150, bbox_inches='tight')
print("Saved threshold_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Upward Closure of Threshold Family

This script visualizes the lattice structure of threshold sets,
showing how the threshold family is upward closed and how
feasibility is preserved under set inclusion.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from itertools import combinations

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# ──────────────────────────────────────────────────────────────────────────────
# Panel 1: Lattice of subsets with threshold-achievable sets highlighted
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[0]
ax.set_title("Upward Closure in the Subset Lattice\n(3 vertices, τ = 1/2)", fontsize=12, fontweight='bold')

# For V = {0,1,2}, show the full power set lattice
# Highlight: if S is achievable, all supersets are achievable
all_subsets = [
    frozenset(),
    frozenset({0}), frozenset({1}), frozenset({2}),
    frozenset({0,1}), frozenset({0,2}), frozenset({1,2}),
    frozenset({0,1,2}),
]

# Positions in Hasse diagram
positions = {
    frozenset(): (3, 0),
    frozenset({0}): (1, 1), frozenset({1}): (3, 1), frozenset({2}): (5, 1),
    frozenset({0,1}): (1.5, 2), frozenset({0,2}): (3, 2), frozenset({1,2}): (4.5, 2),
    frozenset({0,1,2}): (3, 3),
}

# All subsets are achievable as threshold sets (trivially: use indicator)
# But mark a specific example: x = (0.6, 0.3, 0.7), τ = 0.5
# T = {0, 2}. Upward closure: {0,2}, {0,1,2}
base_set = frozenset({0, 2})
upward_closure = {s for s in all_subsets if base_set <= s}

# Draw edges (Hasse diagram)
hasse_edges = []
for s1 in all_subsets:
    for s2 in all_subsets:
        if len(s2) == len(s1) + 1 and s1 < s2:
            hasse_edges.append((s1, s2))

for s1, s2 in hasse_edges:
    p1, p2 = positions[s1], positions[s2]
    both_up = s1 in upward_closure and s2 in upward_closure
    color = '#2185a8' if both_up else '#cccccc'
    lw = 2.5 if both_up else 1
    ax.plot([p1[0], p2[0]], [p1[1], p2[1]], '-', color=color, linewidth=lw, zorder=1)

# Draw nodes
for s in all_subsets:
    p = positions[s]
    in_closure = s in upward_closure
    is_base = s == base_set
    if is_base:
        color = '#ff6b35'
        edgecolor = '#cc4400'
        size = 800
    elif in_closure:
        color = '#2185a8'
        edgecolor = '#1a6b87'
        size = 600
    else:
        color = '#e8e8e8'
        edgecolor = '#999999'
        size = 400

    ax.scatter(*p, s=size, c=color, edgecolors=edgecolor, linewidth=2, zorder=3)

    label = '{' + ','.join(str(v) for v in sorted(s)) + '}' if s else '∅'
    text_color = 'white' if in_closure else '#666666'
    ax.text(p[0], p[1], label, ha='center', va='center', fontsize=9,
            fontweight='bold' if in_closure else 'normal', color=text_color, zorder=4)

# Annotations
ax.text(0.5, -0.08,
        'Orange = base set T_τ(x) = {0,2}\nBlue = upward closure (all achievable)\n'
        'Gray = not in upward closure of {0,2}',
        transform=ax.transAxes, ha='center', fontsize=9, style='italic')

ax.set_xlim(-0.5, 6.5)
ax.set_ylim(-0.7, 3.8)
ax.axis('off')

# ──────────────────────────────────────────────────────────────────────────────
# Panel 2: Feasibility preservation under upward closure
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[1]
ax.set_title("Feasibility-Preserving Upward Closure\n(constructing y from x)", fontsize=12, fontweight='bold')

# Show how to construct y from x when S ⊂ S'
# Example: V = {0,1,2,3}, edge = {0,1,2}, d = 3, τ = 1/3
# x = (0.5, 0.1, 0.4, 0.0) → T = {0, 2}
# S' = {0, 1, 2} ⊃ S = {0, 2}
# y = (0.5, 1/3, 0.4, 0.0) → T = {0, 1, 2}

vertices = [0, 1, 2, 3]
x_vals = [0.5, 0.1, 0.4, 0.0]
y_vals = [0.5, 1/3, 0.4, 0.0]
tau = 1/3

x_pos = np.arange(len(vertices))
width = 0.35

bars_x = ax.bar(x_pos - width/2, x_vals, width, label='x(v) — original',
                color='#6bb3d1', alpha=0.8, edgecolor='#4a93a8')
bars_y = ax.bar(x_pos + width/2, y_vals, width, label='y(v) — constructed',
                color='#2185a8', alpha=0.8, edgecolor='#1a6b87')

# Threshold line
ax.axhline(y=tau, color='red', linewidth=2, linestyle='--', label=f'τ = 1/3', alpha=0.8)

# Mark the raised coordinate
ax.annotate('↑ raised\nto τ', xy=(1 + width/2, y_vals[1]),
            xytext=(1 + width/2 + 0.3, y_vals[1] + 0.15),
            arrowprops=dict(arrowstyle='->', color='#ff6b35', lw=2),
            fontsize=10, color='#ff6b35', fontweight='bold')

# Mark threshold membership
for i in range(len(vertices)):
    if x_vals[i] >= tau:
        ax.text(i - width/2, x_vals[i] + 0.02, '∈S', ha='center', fontsize=8, color='#6bb3d1')
    if y_vals[i] >= tau:
        ax.text(i + width/2, y_vals[i] + 0.02, "∈S'", ha='center', fontsize=8, color='#2185a8')

ax.set_xlabel('Vertices', fontsize=11)
ax.set_ylabel('Assignment value', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels([f'v{v}' for v in vertices])
ax.legend(fontsize=9, loc='upper right')
ax.set_ylim(0, 0.75)

# Edge feasibility check
edge = {0, 1, 2}
sum_x = sum(x_vals[v] for v in edge)
sum_y = sum(y_vals[v] for v in edge)
ax.text(0.5, -0.12,
        f'Edge {{0,1,2}}: Σx = {sum_x:.2f} ≥ 1 ✓   |   Σy = {sum_y:.2f} ≥ 1 ✓\n'
        f'S = {{0,2}} → S\' = {{0,1,2}}: feasibility preserved!',
        transform=ax.transAxes, ha='center', fontsize=10, style='italic')

plt.tight_layout()
plt.savefig('upward_closure_visualization.png', dpi=150, bbox_inches='tight')
print("Saved upward_closure_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Active-Edge Witness Structure

This script visualizes the unique active witness property that forces
integrality in fractional transversals. It shows:
1. A hypergraph with active edges highlighted
2. The witness structure linking support vertices to isolating edges
3. A heatmap of edge-vertex incidence with active constraints marked
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ──────────────────────────────────────────────────────────────────────────────
# Example hypergraph with unique active witnesses
# ──────────────────────────────────────────────────────────────────────────────

# Vertices: 0,1,2,3,4
# Edges: e0={0,1}, e1={2,3}, e2={0,2,4}, e3={3,4}
# Assignment: x = (1, 0, 1, 0, 0) — integral with support {0, 2}
# Active edges for vertex 0: e0 (sum=1, only support vertex is 0)
# Active edges for vertex 2: e1... no. Let's redesign.

# Better example:
# Vertices: 0,1,2,3,4
# Edges: e0={0,1}, e1={1,2}, e2={2,3}, e3={3,4}, e4={4,0}
# x = (1, 0, 1, 0, 1) — support = {0, 2, 4}
# e0={0,1}: sum = 1+0 = 1, active, isolates 0 (only supp vertex)
# e2={2,3}: sum = 1+0 = 1, active, isolates 2
# e3={3,4}: sum = 0+1 = 1, active, isolates 4

vertices = [0, 1, 2, 3, 4]
edges = [
    frozenset({0, 1}),  # e0
    frozenset({1, 2}),  # e1
    frozenset({2, 3}),  # e2
    frozenset({3, 4}),  # e3
    frozenset({4, 0}),  # e4
]
edge_labels = ['e₀', 'e₁', 'e₂', 'e₃', 'e₄']
x_vals = {0: 1, 1: 0, 2: 1, 3: 0, 4: 1}
support_verts = {v for v, xv in x_vals.items() if xv != 0}

# Witness mapping
witnesses = {0: 0, 2: 2, 4: 3}  # vertex -> witness edge index

# ──────────────────────────────────────────────────────────────────────────────
# Panel 1: Incidence heatmap with active constraints
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[0]
ax.set_title("Edge-Vertex Incidence & Active Constraints", fontsize=12, fontweight='bold')

n_edges = len(edges)
n_verts = len(vertices)
incidence = np.zeros((n_edges, n_verts))
for i, e in enumerate(edges):
    for v in e:
        incidence[i, v] = x_vals[v]

# Custom colormap
cmap = plt.cm.Blues
im = ax.imshow(incidence, cmap=cmap, aspect='auto', vmin=0, vmax=1)

# Mark active edges
for i, e in enumerate(edges):
    edge_sum = sum(x_vals[v] for v in e)
    if edge_sum == 1:
        # Highlight active row
        for j in range(n_verts):
            if j in e:
                ax.add_patch(patches.Rectangle((j-0.5, i-0.5), 1, 1,
                             linewidth=3, edgecolor='red', facecolor='none'))

# Mark witness relationships
for v, ei in witnesses.items():
    ax.annotate('★', (v, ei), ha='center', va='center', fontsize=16,
                color='gold', fontweight='bold')

ax.set_xticks(range(n_verts))
ax.set_xticklabels([f'v{v}\nx={x_vals[v]}' for v in vertices], fontsize=9)
ax.set_yticks(range(n_edges))
ax.set_yticklabels([f'{el} = {set(e)}' for el, e in zip(edge_labels, edges)], fontsize=9)
ax.set_xlabel('Vertices (with assignment values)', fontsize=11)
ax.set_ylabel('Edges', fontsize=11)

# Legend
ax.text(0.5, -0.18, 'Red border = active constraint (Σ = 1)\n★ = unique witness edge',
        transform=ax.transAxes, ha='center', fontsize=9, style='italic')

plt.colorbar(im, ax=ax, label='x(v) contribution', shrink=0.8)

# ──────────────────────────────────────────────────────────────────────────────
# Panel 2: Witness structure diagram
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[1]
ax.set_title("Witness Structure Forces Integrality", fontsize=12, fontweight='bold')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)

# Draw vertices in a circle
angles = np.linspace(0, 2*np.pi, n_verts, endpoint=False) - np.pi/2
vx = np.cos(angles)
vy = np.sin(angles)

# Draw edges as colored arcs/regions
edge_colors = ['#ffcccc', '#ccffcc', '#ccccff', '#ffffcc', '#ffccff']
for i, e in enumerate(edges):
    vs = sorted(e)
    # Draw edge as line between vertices
    for j in range(len(vs)):
        for k in range(j+1, len(vs)):
            v1, v2 = vs[j], vs[k]
            is_active = sum(x_vals[v] for v in e) == 1
            lw = 4 if is_active else 1
            color = 'red' if is_active else 'gray'
            alpha = 0.8 if is_active else 0.3
            ax.plot([vx[v1], vx[v2]], [vy[v1], vy[v2]], '-',
                    color=color, linewidth=lw, alpha=alpha, zorder=1)
            if is_active:
                mid_x = (vx[v1] + vx[v2]) / 2
                mid_y = (vy[v1] + vy[v2]) / 2
                # Offset label slightly
                offset = 0.15
                ax.text(mid_x + offset * np.cos(angles[vs[0]] + np.pi/4),
                       mid_y + offset * np.sin(angles[vs[0]] + np.pi/4),
                       edge_labels[i], fontsize=8, ha='center', color='red')

# Draw vertices
for v in vertices:
    in_support = v in support_verts
    color = '#2185a8' if in_support else '#e8f4f8'
    edgecolor = '#2185a8' if in_support else 'gray'
    size = 600 if in_support else 400
    ax.scatter(vx[v], vy[v], s=size, c=color, edgecolors=edgecolor,
              linewidth=2, zorder=3)
    ax.text(vx[v], vy[v], f'v{v}\n{x_vals[v]}', ha='center', va='center',
            fontsize=9, fontweight='bold' if in_support else 'normal',
            color='white' if in_support else 'gray', zorder=4)

# Draw witness arrows
for v, ei in witnesses.items():
    e = edges[ei]
    other = [u for u in e if u != v]
    if other:
        u = other[0]
        mid_x = (vx[v] + vx[u]) / 2
        mid_y = (vy[v] + vy[u]) / 2
        ax.annotate('', xy=(mid_x, mid_y),
                   xytext=(vx[v]*0.7, vy[v]*0.7),
                   arrowprops=dict(arrowstyle='->', color='gold', lw=2))

ax.text(0, -1.4, 'Blue = support vertex (x(v) = 1)\nRed edges = active (Σ = 1)\n'
        'Each support vertex isolated by its witness edge',
        ha='center', fontsize=9, style='italic')
ax.set_aspect('equal')
ax.axis('off')

plt.tight_layout()
plt.savefig('witness_visualization.png', dpi=150, bbox_inches='tight')
print("Saved witness_visualization.png")
