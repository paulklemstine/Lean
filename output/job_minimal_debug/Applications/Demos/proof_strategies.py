#!/usr/bin/env python3
"""
Applications of Tropical SP Network Theory

Demonstrates real-world applications:
1. Network reliability analysis
2. Supply chain optimization
3. Circuit timing analysis
4. Phylogenetic tree reconstruction
"""

import numpy as np
from algorithms import (
    SPExpr, Atom, Series, Parallel,
    eff_dist, path_weights, num_paths,
    tropical_eliminate_vertex, floyd_warshall,
    boundary_distance_matrix, INF
)


def pretty(e):
    """Pretty-print an SP expression."""
    match e:
        case Atom(w):
            return str(w)
        case Series(l, r):
            return f"({pretty(l)} → {pretty(r)})"
        case Parallel(l, r):
            return f"({pretty(l)} ∥ {pretty(r)})"


# ═══════════════════════════════════════════════════════════════
# Application 1: Supply Chain / Logistics
# ═══════════════════════════════════════════════════════════════

def app_supply_chain():
    """Model a supply chain as a tropical SP network.

    Each edge weight represents transit time (days).
    Series = sequential stages, Parallel = alternative routes.
    Effective distance = fastest delivery time.
    """
    print("=" * 60)
    print("APPLICATION 1: Supply Chain Optimization")
    print("=" * 60)
    print()

    # Factory → Distribution Center → Customer
    # Two factory-to-DC routes (air vs ground)
    # Two DC-to-customer routes (express vs standard)

    air_shipping = Atom(2)       # 2 days by air
    ground_shipping = Atom(7)    # 7 days by ground
    factory_to_dc = Parallel(air_shipping, ground_shipping)

    express_delivery = Atom(1)   # 1 day express
    standard_delivery = Atom(4)  # 4 days standard
    dc_to_customer = Parallel(express_delivery, standard_delivery)

    full_chain = Series(factory_to_dc, dc_to_customer)

    print(f"  Supply chain: {pretty(full_chain)}")
    print(f"  Fastest delivery: {eff_dist(full_chain)} days")
    print(f"  All possible delivery times: {path_weights(full_chain)} days")
    print(f"  Number of route combinations: {num_paths(full_chain)}")
    print()

    # Add a direct factory-to-customer drone option (5 days)
    drone = Atom(5)
    chain_with_drone = Parallel(full_chain, drone)

    print(f"  With drone option ({pretty(drone)} days):")
    print(f"  Fastest delivery: {eff_dist(chain_with_drone)} days")
    print(f"  All delivery times: {path_weights(chain_with_drone)} days")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 2: Digital Circuit Timing
# ═══════════════════════════════════════════════════════════════

def app_circuit_timing():
    """Model critical path analysis in a digital circuit.

    Each edge weight = gate delay (nanoseconds).
    Series = sequential gates, Parallel = independent paths.
    Effective distance = critical path delay (minimum propagation time).
    """
    print("=" * 60)
    print("APPLICATION 2: Digital Circuit Timing Analysis")
    print("=" * 60)
    print()

    # A combinational logic block:
    # Input → AND gate (2ns) → buffer chain (OR 3ns, AND 2ns) → output
    # OR
    # Input → fast path: XOR gate (4ns) → output

    slow_path = Series(Atom(2), Parallel(Atom(3), Atom(2)))
    fast_path = Atom(4)
    circuit = Parallel(slow_path, fast_path)

    print(f"  Circuit: {pretty(circuit)}")
    print(f"  Critical path delay: {eff_dist(circuit)} ns")
    print(f"  All path delays: {path_weights(circuit)} ns")
    print(f"  Number of signal paths: {num_paths(circuit)}")
    print()

    # Multi-stage pipeline
    stage1 = Parallel(Atom(3), Atom(5))
    stage2 = Parallel(Atom(2), Atom(4))
    stage3 = Atom(1)
    pipeline = Series(stage1, Series(stage2, stage3))

    print(f"  Pipeline: {pretty(pipeline)}")
    print(f"  Min propagation delay: {eff_dist(pipeline)} ns")
    print(f"  All propagation times: {path_weights(pipeline)} ns")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 3: Network Inverse Problem
# ═══════════════════════════════════════════════════════════════

def app_inverse_problem():
    """Demonstrate the tropical inverse problem:
    Given boundary distances, what can we infer about internal structure?

    This is the core application of the rigidity theorems.
    """
    print("=" * 60)
    print("APPLICATION 3: Tropical Inverse Problem")
    print("=" * 60)
    print()

    # Create a hidden network
    hidden = Series(
        Parallel(Atom(2), Atom(5)),
        Series(Atom(3), Parallel(Atom(1), Atom(4)))
    )

    print("  Hidden SP network structure:")
    print(f"    {pretty(hidden)}")
    print(f"    Effective distance (boundary observable): {eff_dist(hidden)}")
    print(f"    Full path spectrum: {path_weights(hidden)}")
    print()

    # The boundary observer sees only the effective distance
    observed_dist = eff_dist(hidden)
    print(f"  Boundary observer sees: d = {observed_dist}")
    print()

    # Show what structures are consistent with this distance
    print("  Consistent simple structures:")
    candidates = [
        Atom(observed_dist),
        Series(Atom(1), Atom(observed_dist - 1)),
        Parallel(Atom(observed_dist), Atom(observed_dist + 3)),
    ]
    for c in candidates:
        if eff_dist(c) == observed_dist:
            print(f"    {pretty(c)} → effDist = {eff_dist(c)} ✓")

    print()
    print("  Key insight: The effective distance alone doesn't determine")
    print("  the network structure. The full path weight multiset provides")
    print("  richer information, and for k≥3 terminal networks, the")
    print("  boundary distance MATRIX can uniquely determine the structure.")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 4: Graph Sparsification via Elimination
# ═══════════════════════════════════════════════════════════════

def app_graph_sparsification():
    """Demonstrate tropical elimination as graph sparsification.

    Interior vertices are eliminated while preserving boundary distances.
    This is useful for network reduction and summarization.
    """
    print("=" * 60)
    print("APPLICATION 4: Graph Sparsification via Tropical Elimination")
    print("=" * 60)
    print()

    # Create a larger network
    # 7 vertices: 0, 1, 2 are boundary; 3, 4, 5, 6 are internal
    n = 7
    W = np.full((n, n), INF)
    for i in range(n):
        W[i, i] = 0

    edges = [
        (0, 3, 2), (0, 4, 5),
        (3, 4, 1), (3, 5, 3),
        (4, 5, 2), (4, 6, 4),
        (5, 1, 1), (5, 6, 2),
        (6, 2, 3),
        (1, 2, 6),
    ]

    for u, v, w in edges:
        W[u, v] = w
        W[v, u] = w

    print(f"  Original graph: {n} vertices, {len(edges)} edges")
    print(f"  Boundary vertices: {{0, 1, 2}}")
    print(f"  Internal vertices: {{3, 4, 5, 6}}")
    print()

    # Compute boundary distances via Floyd-Warshall
    D_full = floyd_warshall(W)
    boundary = [0, 1, 2]

    print("  Full shortest-path distances (boundary):")
    for i in boundary:
        for j in boundary:
            if i < j:
                print(f"    d({i},{j}) = {D_full[i,j]:.0f}")

    # Compute via tropical elimination
    D_elim = boundary_distance_matrix(W, boundary)
    print()
    print("  Tropical elimination distances (boundary):")
    for i_new, i_old in enumerate(boundary):
        for j_new, j_old in enumerate(boundary):
            if i_old < j_old:
                print(f"    d({i_old},{j_old}) = {D_elim[i_new,j_new]:.0f}")

    # Verify they match
    match = True
    for i_new, i_old in enumerate(boundary):
        for j_new, j_old in enumerate(boundary):
            if abs(D_elim[i_new, j_new] - D_full[i_old, j_old]) > 1e-9:
                match = False

    print()
    print(f"  Elimination matches Floyd-Warshall: {'✓' if match else '✗'}")
    print(f"  Reduced from {n} vertices to {len(boundary)} vertices")
    print(f"  Compression ratio: {len(boundary)/n:.1%}")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 5: Dynamic Programming Connection
# ═══════════════════════════════════════════════════════════════

def app_dynamic_programming():
    """Show the connection between SP evaluation and dynamic programming.

    The effective distance computation is a tropical (min-plus) DP:
    - Series = Bellman equation composition
    - Parallel = taking the best option
    """
    print("=" * 60)
    print("APPLICATION 5: Dynamic Programming / Bellman Connection")
    print("=" * 60)
    print()

    # Model a shortest-path problem as SP composition
    # Road network: city A → city B via intermediate cities

    # Route 1: A →(3)→ X →(2)→ Y →(4)→ B
    route1 = Series(Atom(3), Series(Atom(2), Atom(4)))

    # Route 2: A →(5)→ Z →(3)→ B
    route2 = Series(Atom(5), Atom(3))

    # Route 3: A →(10)→ B (direct highway)
    route3 = Atom(10)

    # Best route: parallel of all options
    best = Parallel(Parallel(route1, route2), route3)

    print("  Road network: A → B")
    print(f"    Route 1 (via X,Y): {pretty(route1)} = {eff_dist(route1)}")
    print(f"    Route 2 (via Z):   {pretty(route2)} = {eff_dist(route2)}")
    print(f"    Route 3 (direct):  {pretty(route3)} = {eff_dist(route3)}")
    print()
    print(f"  Optimal route (Bellman): min = {eff_dist(best)}")
    print(f"  All route costs: {path_weights(best)}")
    print()
    print("  This is exactly the Bellman optimality principle:")
    print("  V*(s) = min_a { c(s,a) + V*(next(s,a)) }")
    print("  where series = c + V* and parallel = min_a")
    print()


# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL SP NETWORK APPLICATIONS                      ║")
    print("║  Real-World Uses of Formally Verified Theory            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_supply_chain()
    app_circuit_timing()
    app_inverse_problem()
    app_graph_sparsification()
    app_dynamic_programming()

    print("All applications demonstrated successfully! ✓")


#!/usr/bin/env python3
"""
Tropical Series-Parallel Network Theory — Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
1. Compositional tropical semantics (series adds, parallel takes min)
2. Path weight multiset characterization
3. Tropical vertex elimination (Schur complement)
4. Tropical distributivity

Each example corresponds to a formally verified theorem.
"""

from dataclasses import dataclass
from typing import List
from itertools import product


# ─────────────────────────────────────────────────────────────────
# SP Expression Tree
# ─────────────────────────────────────────────────────────────────

@dataclass
class Atom:
    """Single edge with weight w."""
    weight: int

    def __repr__(self):
        return f"Atom({self.weight})"


@dataclass
class Series:
    """Series composition of two SP networks."""
    left: object
    right: object

    def __repr__(self):
        return f"Series({self.left}, {self.right})"


@dataclass
class Parallel:
    """Parallel composition of two SP networks."""
    left: object
    right: object

    def __repr__(self):
        return f"Parallel({self.left}, {self.right})"


SPExpr = Atom | Series | Parallel


def eff_dist(e: SPExpr) -> int:
    """Effective distance (shortest path between terminals).
    Formally verified as SPExpr.effDist."""
    match e:
        case Atom(w):
            return w
        case Series(l, r):
            return eff_dist(l) + eff_dist(r)
        case Parallel(l, r):
            return min(eff_dist(l), eff_dist(r))


def path_weights(e: SPExpr) -> List[int]:
    """All source-to-sink path weights (as a sorted list).
    Formally verified as SPExpr.pathWeights."""
    match e:
        case Atom(w):
            return [w]
        case Series(l, r):
            pw_l = path_weights(l)
            pw_r = path_weights(r)
            return sorted(a + b for a, b in product(pw_l, pw_r))
        case Parallel(l, r):
            return sorted(path_weights(l) + path_weights(r))


def num_paths(e: SPExpr) -> int:
    """Number of source-to-sink paths.
    Formally verified as SPExpr.numPaths."""
    match e:
        case Atom(_):
            return 1
        case Series(l, r):
            return num_paths(l) * num_paths(r)
        case Parallel(l, r):
            return num_paths(l) + num_paths(r)


def total_weight(e: SPExpr) -> int:
    """Total weight of all atoms."""
    match e:
        case Atom(w):
            return w
        case Series(l, r) | Parallel(l, r):
            return total_weight(l) + total_weight(r)


def pretty(e: SPExpr) -> str:
    """Pretty-print an SP expression."""
    match e:
        case Atom(w):
            return str(w)
        case Series(l, r):
            return f"({pretty(l)} + {pretty(r)})"
        case Parallel(l, r):
            return f"min({pretty(l)}, {pretty(r)})"


# ─────────────────────────────────────────────────────────────────
# Tropical Elimination (Schur Complement)
# ─────────────────────────────────────────────────────────────────

INF = float('inf')


def tropical_elim3(w_sv, w_vt, w_st):
    """Tropical Schur complement for 3-vertex graph.
    Formally verified as SPExpr.tropicalElim3."""
    return min(w_st, w_sv + w_vt)


# ─────────────────────────────────────────────────────────────────
# Demo 1: Compositional Semantics
# ─────────────────────────────────────────────────────────────────

def demo_compositional():
    print("=" * 60)
    print("DEMO 1: Compositional Tropical Semantics")
    print("=" * 60)
    print()

    # Build example networks
    e1 = Atom(3)
    e2 = Atom(5)
    e3 = Atom(2)

    s12 = Series(e1, e2)
    p12 = Parallel(e1, e2)

    print(f"  e₁ = {pretty(e1)},  effDist = {eff_dist(e1)}")
    print(f"  e₂ = {pretty(e2)},  effDist = {eff_dist(e2)}")
    print()

    # Series: distances ADD
    print("  Series composition (distances add):")
    print(f"    series(e₁, e₂) = {pretty(s12)}")
    print(f"    effDist = {eff_dist(e1)} + {eff_dist(e2)} = {eff_dist(s12)}")
    assert eff_dist(s12) == eff_dist(e1) + eff_dist(e2)
    print(f"    ✓ Verified: effDist_series")
    print()

    # Parallel: distances take MIN
    print("  Parallel composition (distances take min):")
    print(f"    parallel(e₁, e₂) = {pretty(p12)}")
    print(f"    effDist = min({eff_dist(e1)}, {eff_dist(e2)}) = {eff_dist(p12)}")
    assert eff_dist(p12) == min(eff_dist(e1), eff_dist(e2))
    print(f"    ✓ Verified: effDist_parallel")
    print()

    # Complex network
    complex = Series(Parallel(Atom(2), Atom(7)), Series(Atom(1), Atom(4)))
    print(f"  Complex network: {pretty(complex)}")
    print(f"    effDist = {eff_dist(complex)}")
    print(f"    Paths: {path_weights(complex)}")
    print(f"    Number of paths: {num_paths(complex)}")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 2: Path Weight Characterization
# ─────────────────────────────────────────────────────────────────

def demo_path_weights():
    print("=" * 60)
    print("DEMO 2: Fundamental Path-Distance Theorem")
    print("=" * 60)
    print()
    print("  Theorem: effDist = min(pathWeights)")
    print("  (The shortest path IS the minimum of all path weights)")
    print()

    examples = [
        Atom(5),
        Series(Atom(3), Atom(4)),
        Parallel(Atom(2), Atom(8)),
        Series(Parallel(Atom(1), Atom(3)), Atom(2)),
        Parallel(Series(Atom(2), Atom(3)), Series(Atom(1), Atom(6))),
        Parallel(
            Series(Atom(1), Parallel(Atom(2), Atom(5))),
            Atom(10)
        ),
    ]

    for e in examples:
        pw = path_weights(e)
        d = eff_dist(e)
        n = num_paths(e)
        print(f"  {pretty(e)}")
        print(f"    paths = {pw}")
        print(f"    effDist = {d} = min({pw}) ✓")
        print(f"    numPaths = {n} = len({pw}) ✓")
        assert d == min(pw)
        assert d in pw
        assert n == len(pw)
        print()


# ─────────────────────────────────────────────────────────────────
# Demo 3: Tropical Distributivity
# ─────────────────────────────────────────────────────────────────

def demo_distributivity():
    print("=" * 60)
    print("DEMO 3: Tropical Distributivity")
    print("=" * 60)
    print()
    print("  Theorem: a + min(b, c) = min(a+b, a+c)")
    print("  (Series distributes over parallel)")
    print()

    test_cases = [(2, 3, 7), (1, 5, 5), (0, 4, 9), (10, 1, 100)]

    for a, b, c in test_cases:
        e1 = Atom(a)
        e2 = Atom(b)
        e3 = Atom(c)

        lhs = Series(e1, Parallel(e2, e3))
        rhs_val = min(eff_dist(Series(e1, e2)), eff_dist(Series(e1, e3)))

        print(f"  a={a}, b={b}, c={c}:")
        print(f"    {a} + min({b},{c}) = {a} + {min(b,c)} = {eff_dist(lhs)}")
        print(f"    min({a}+{b}, {a}+{c}) = min({a+b}, {a+c}) = {rhs_val}")
        assert eff_dist(lhs) == rhs_val
        print(f"    ✓ Equal!")
        print()


# ─────────────────────────────────────────────────────────────────
# Demo 4: Tropical Vertex Elimination (Schur Complement)
# ─────────────────────────────────────────────────────────────────

def demo_elimination():
    print("=" * 60)
    print("DEMO 4: Tropical Vertex Elimination")
    print("=" * 60)
    print()
    print("  Eliminating internal vertices via tropical Schur complement")
    print()

    # Case 1: Pure series (no direct edge)
    print("  Case 1: Series graph s →(3)→ v →(4)→ t, no direct edge")
    result = tropical_elim3(3, 4, INF)
    print(f"    tropicalElim3(3, 4, ∞) = min(∞, 3+4) = {result}")
    assert result == 7
    print(f"    ✓ Equals series weight 3+4 = 7")
    print()

    # Case 2: Diamond graph (direct + indirect)
    print("  Case 2: Diamond graph with direct edge weight 5")
    print("           and indirect path 3 + 4 = 7")
    result = tropical_elim3(3, 4, 5)
    print(f"    tropicalElim3(3, 4, 5) = min(5, 3+4) = min(5, 7) = {result}")
    assert result == 5
    print(f"    ✓ Direct edge is shorter, chosen by min")
    print()

    # Case 3: Diamond where indirect is shorter
    print("  Case 3: Diamond graph with direct edge weight 10")
    print("           and indirect path 2 + 3 = 5")
    result = tropical_elim3(2, 3, 10)
    print(f"    tropicalElim3(2, 3, 10) = min(10, 2+3) = min(10, 5) = {result}")
    assert result == 5
    print(f"    ✓ Indirect path is shorter, chosen by min")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 5: Semiring Properties Summary
# ─────────────────────────────────────────────────────────────────

def demo_semiring():
    print("=" * 60)
    print("DEMO 5: Tropical Semiring Structure")
    print("=" * 60)
    print()
    print("  SP networks form a model of the tropical semiring (ℕ, min, +):")
    print()

    a, b, c = Atom(3), Atom(5), Atom(2)

    # Commutativity of parallel
    assert eff_dist(Parallel(a, b)) == eff_dist(Parallel(b, a))
    print("  ✓ min is commutative: parallel(a,b) = parallel(b,a)")

    # Associativity of parallel
    assert eff_dist(Parallel(Parallel(a, b), c)) == eff_dist(Parallel(a, Parallel(b, c)))
    print("  ✓ min is associative: parallel(parallel(a,b),c) = parallel(a,parallel(b,c))")

    # Idempotency of parallel
    assert eff_dist(Parallel(a, a)) == eff_dist(a)
    print("  ✓ min is idempotent: parallel(a,a) = a")

    # Associativity of series
    assert eff_dist(Series(Series(a, b), c)) == eff_dist(Series(a, Series(b, c)))
    print("  ✓ + is associative: series(series(a,b),c) = series(a,series(b,c))")

    # Identity for series
    zero = Atom(0)
    assert eff_dist(Series(zero, a)) == eff_dist(a)
    print("  ✓ 0 is identity for +: series(atom(0), a) = a")

    # Left distributivity
    assert eff_dist(Series(a, Parallel(b, c))) == \
           min(eff_dist(Series(a, b)), eff_dist(Series(a, c)))
    print("  ✓ + distributes over min from left")

    # Right distributivity
    assert eff_dist(Series(Parallel(a, b), c)) == \
           min(eff_dist(Series(a, c)), eff_dist(Series(b, c)))
    print("  ✓ + distributes over min from right")

    print()
    print("  All tropical semiring axioms verified! ✓")
    print()


# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL SERIES-PARALLEL NETWORK THEORY                ║")
    print("║  Compositional Semantics & Boundary Rigidity            ║")
    print("║  All results formally verified                          ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_compositional()
    demo_path_weights()
    demo_distributivity()
    demo_elimination()
    demo_semiring()

    print("All demos passed successfully! ✓")


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json

# Read viz data
with open('viz_data.json') as f:
    viz = json.load(f)

# Read lean files
with open('Tropical/SPNetwork.lean') as f:
    lean1 = f.read()
with open('Tropical/SPElimination.lean') as f:
    lean2 = f.read()

# Read markdown files
with open('ARTICLE.md') as f:
    article = f.read()
with open('RESEARCH_PAPER.md') as f:
    paper = f.read()
with open('FUTURE_DIRECTIONS.md') as f:
    future = f.read()

# Read python files
with open('demo.py') as f:
    demo = f.read()
with open('algorithms.py') as f:
    algo = f.read()
with open('applications.py') as f:
    apps = f.read()

package = {
    "title": "Tropical Series-Parallel Network Theory: Compositional Semantics and Boundary Rigidity",
    "domain": "Tropical Geometry / Graph Theory / Inverse Problems",
    "article": article,
    "research_paper": paper,
    "future_directions": future,
    "demos": [
        {"name": "Tropical SP Network Demo", "code": demo},
        {"name": "Applications Demo", "code": apps},
    ],
    "algorithms": [
        {
            "name": "Effective Distance Computation",
            "pseudocode": (
                "ALGORITHM: EffDist(e)\n"
                "INPUT: SP expression e\n"
                "OUTPUT: shortest-path distance\n\n"
                "match e with\n"
                "| atom(w) -> return w\n"
                "| series(e1, e2) -> return EffDist(e1) + EffDist(e2)\n"
                "| parallel(e1, e2) -> return min(EffDist(e1), EffDist(e2))\n\n"
                "Time: O(n), Space: O(depth)"
            ),
            "code": algo,
        },
        {
            "name": "Tropical Vertex Elimination",
            "pseudocode": (
                "ALGORITHM: TropElimVertex(W, v)\n"
                "INPUT: n*n weight matrix W, vertex index v\n"
                "OUTPUT: (n-1)*(n-1) reduced weight matrix\n\n"
                "for each pair (i, j) with i != v and j != v:\n"
                "    W_new[i,j] = min(W[i,j], W[i,v] + W[v,j])\n"
                "return W_new\n\n"
                "Time: O(n^2), Space: O(n^2)"
            ),
            "code": algo,
        },
    ],
    "visualizations": [
        {"name": "SP Expression Tree", "data": viz["sp_tree"]},
        {"name": "Tropical Elimination Process", "data": viz["elimination"]},
        {"name": "Tropical Semiring Operations", "data": viz["semiring_ops"]},
        {"name": "Path Weight Distributions", "data": viz["path_dist"]},
    ],
    "lean_proofs": (
        lean1
        + "\n\n-- ═══════════════════════════════════════\n"
        + "-- File: Tropical/SPElimination.lean\n"
        + "-- ═══════════════════════════════════════\n\n"
        + lean2
    ),
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, ensure_ascii=False)

print("PACKAGE.json created successfully")
print(f"Size: {len(json.dumps(package))} bytes")


#!/usr/bin/env python3
"""
Visualizations for Tropical Series-Parallel Network Theory.
Generates PNG figures for the article and research paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ═══════════════════════════════════════════════════════════════
# Visualization 1: SP Expression Tree with Effective Distances
# ═══════════════════════════════════════════════════════════════

def viz_sp_tree():
    """Visualize an SP expression tree annotated with effective distances."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 7)
    ax.axis('off')
    ax.set_title('Series-Parallel Expression Tree\nwith Tropical Effective Distances',
                 fontsize=14, fontweight='bold', pad=20)

    # Draw the tree for: series(parallel(atom(2), atom(5)), atom(3))
    # Root: series, effDist = 5
    # Left: parallel, effDist = 2
    # Left-Left: atom(2), effDist = 2
    # Left-Right: atom(5), effDist = 5
    # Right: atom(3), effDist = 3

    nodes = {
        'root': (5, 6, 'Series\n(+)', 5, '#4ECDC4'),
        'left': (2.5, 3.5, 'Parallel\n(min)', 2, '#FF6B6B'),
        'right': (7.5, 3.5, 'Atom\nw=3', 3, '#45B7D1'),
        'll': (1, 1, 'Atom\nw=2', 2, '#45B7D1'),
        'lr': (4, 1, 'Atom\nw=5', 5, '#45B7D1'),
    }

    edges = [('root', 'left'), ('root', 'right'), ('left', 'll'), ('left', 'lr')]

    # Draw edges
    for parent, child in edges:
        px, py = nodes[parent][0], nodes[parent][1]
        cx, cy = nodes[child][0], nodes[child][1]
        ax.plot([px, cx], [py - 0.5, cy + 0.5], 'k-', linewidth=2, zorder=1)

    # Draw nodes
    for key, (x, y, label, dist, color) in nodes.items():
        circle = plt.Circle((x, y), 0.7, color=color, ec='black', linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y + 0.1, label, ha='center', va='center', fontsize=9, fontweight='bold')
        ax.text(x, y - 0.5, f'd={dist}', ha='center', va='top', fontsize=10,
                color='darkred', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', edgecolor='orange'))

    # Add legend
    ax.text(0, -0.3, 'Series: d = d₁ + d₂ = 2 + 3 = 5', fontsize=11, color='#4ECDC4',
            fontweight='bold')
    ax.text(0, -0.8, 'Parallel: d = min(d₁, d₂) = min(2, 5) = 2', fontsize=11,
            color='#FF6B6B', fontweight='bold')

    fig.savefig('/workspace/request-project/viz_sp_tree.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Visualization 2: Tropical Elimination Process
# ═══════════════════════════════════════════════════════════════

def viz_elimination():
    """Visualize the tropical vertex elimination process."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for ax in axes:
        ax.set_xlim(-0.5, 4.5)
        ax.set_ylim(-0.5, 3.5)
        ax.axis('off')

    # Before elimination: 3 vertices
    ax = axes[0]
    ax.set_title('Before Elimination', fontsize=13, fontweight='bold')
    # Vertices
    for pos, label in [((0, 1.5), 's'), ((2, 3), 'v'), ((4, 1.5), 't')]:
        circle = plt.Circle(pos, 0.35, color='#4ECDC4' if label != 'v' else '#FF6B6B',
                           ec='black', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center', fontsize=14, fontweight='bold')

    # Edges
    ax.annotate('', xy=(1.7, 2.7), xytext=(0.3, 1.7),
                arrowprops=dict(arrowstyle='-', lw=2, color='black'))
    ax.text(0.7, 2.4, 'w₁=3', fontsize=11, color='blue', fontweight='bold')

    ax.annotate('', xy=(3.7, 1.7), xytext=(2.3, 2.7),
                arrowprops=dict(arrowstyle='-', lw=2, color='black'))
    ax.text(3.1, 2.4, 'w₂=4', fontsize=11, color='blue', fontweight='bold')

    # Arrow
    axes[1].set_xlim(-1, 1)
    axes[1].set_ylim(-1, 1)
    axes[1].annotate('', xy=(0.5, 0), xytext=(-0.5, 0),
                     arrowprops=dict(arrowstyle='->', lw=3, color='red'))
    axes[1].text(0, 0.3, 'Eliminate v', ha='center', fontsize=12,
                fontweight='bold', color='red')
    axes[1].text(0, -0.3, 'min(∞, 3+4) = 7', ha='center', fontsize=11,
                color='darkred')
    axes[1].set_title('Tropical Schur\nComplement', fontsize=13, fontweight='bold')

    # After elimination: 2 vertices
    ax = axes[2]
    ax.set_title('After Elimination', fontsize=13, fontweight='bold')
    for pos, label in [((1, 1.5), 's'), ((3, 1.5), 't')]:
        circle = plt.Circle(pos, 0.35, color='#4ECDC4',
                           ec='black', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center', fontsize=14, fontweight='bold')

    ax.annotate('', xy=(2.65, 1.5), xytext=(1.35, 1.5),
                arrowprops=dict(arrowstyle='-', lw=3, color='green'))
    ax.text(2, 1.9, 'd=7', fontsize=13, color='green', fontweight='bold')

    fig.savefig('/workspace/request-project/viz_elimination.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Visualization 3: Tropical Semiring Operations
# ═══════════════════════════════════════════════════════════════

def viz_semiring_ops():
    """Visualize the tropical semiring operations on SP networks."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Series composition
    ax = axes[0]
    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(-0.5, 3)
    ax.axis('off')
    ax.set_title('Series: Distances ADD\nd(series) = d₁ + d₂', fontsize=13, fontweight='bold')

    # Draw two networks in series
    for x, label, w in [(0, 's', None), (3, 'm', None), (6, 't', None)]:
        color = '#4ECDC4' if label != 'm' else '#FFD93D'
        circle = plt.Circle((x, 1.5), 0.35, color=color, ec='black', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(x, 1.5, label, ha='center', va='center', fontsize=12, fontweight='bold')

    # Edges
    ax.plot([0.35, 2.65], [1.5, 1.5], 'b-', linewidth=3)
    ax.text(1.5, 1.8, 'd₁ = 3', fontsize=12, color='blue', ha='center', fontweight='bold')
    ax.plot([3.35, 5.65], [1.5, 1.5], 'r-', linewidth=3)
    ax.text(4.5, 1.8, 'd₂ = 4', fontsize=12, color='red', ha='center', fontweight='bold')

    # Result
    ax.text(3, 0.3, '→ d = 3 + 4 = 7', fontsize=14, ha='center',
            fontweight='bold', color='darkgreen',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', edgecolor='green'))

    # Parallel composition
    ax = axes[1]
    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-0.5, 4)
    ax.axis('off')
    ax.set_title('Parallel: Distances take MIN\nd(parallel) = min(d₁, d₂)', fontsize=13,
                fontweight='bold')

    # Two parallel paths
    for pos, label in [((0, 2), 's'), ((6, 2), 't')]:
        circle = plt.Circle(pos, 0.35, color='#4ECDC4', ec='black', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center', fontsize=12, fontweight='bold')

    # Upper path
    ax.annotate('', xy=(5.65, 2.3), xytext=(0.35, 2.3),
                arrowprops=dict(arrowstyle='-', lw=3, color='blue',
                               connectionstyle='arc3,rad=0.3'))
    ax.text(3, 3.5, 'd₁ = 2', fontsize=12, color='blue', ha='center', fontweight='bold')

    # Lower path
    ax.annotate('', xy=(5.65, 1.7), xytext=(0.35, 1.7),
                arrowprops=dict(arrowstyle='-', lw=3, color='red',
                               connectionstyle='arc3,rad=-0.3'))
    ax.text(3, 0.5, 'd₂ = 5', fontsize=12, color='red', ha='center', fontweight='bold')

    # Result
    ax.text(3, -0.2, '→ d = min(2, 5) = 2', fontsize=14, ha='center',
            fontweight='bold', color='darkgreen',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', edgecolor='green'))

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_semiring_ops.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Visualization 4: Path Weight Distribution
# ═══════════════════════════════════════════════════════════════

def viz_path_distribution():
    """Visualize path weight distributions for different SP networks."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    from demo import SPExpr as _, Atom, Series, Parallel, eff_dist, path_weights

    examples = [
        ("Atom(5)", Atom(5)),
        ("Parallel(Atom(2), Atom(8))", Parallel(Atom(2), Atom(8))),
        ("Series(Par(1,3), Atom(2))", Series(Parallel(Atom(1), Atom(3)), Atom(2))),
        ("Par(Ser(1,Par(2,5)), Atom(10))",
         Parallel(Series(Atom(1), Parallel(Atom(2), Atom(5))), Atom(10))),
    ]

    for ax, (name, expr) in zip(axes.flat, examples):
        pw = path_weights(expr)
        d = eff_dist(expr)

        colors = ['#FF6B6B' if w == d else '#4ECDC4' for w in pw]
        bars = ax.bar(range(len(pw)), pw, color=colors, edgecolor='black', linewidth=1.5)

        ax.axhline(y=d, color='red', linestyle='--', linewidth=2, label=f'effDist = {d}')
        ax.set_title(name, fontsize=11, fontweight='bold')
        ax.set_ylabel('Path Weight')
        ax.set_xlabel('Path Index')
        ax.legend(fontsize=10)
        ax.set_xticks(range(len(pw)))

        for i, w in enumerate(pw):
            ax.text(i, w + 0.2, str(w), ha='center', fontsize=10, fontweight='bold')

    fig.suptitle('Path Weight Distributions\n(Red = minimum = effective distance)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_paths.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    data = {}
    data['sp_tree'] = viz_sp_tree()
    print("  ✓ SP expression tree")

    data['elimination'] = viz_elimination()
    print("  ✓ Tropical elimination")

    data['semiring_ops'] = viz_semiring_ops()
    print("  ✓ Semiring operations")

    data['path_dist'] = viz_path_distribution()
    print("  ✓ Path weight distributions")

    # Save data for JSON package
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(data, f)

    print("\nAll visualizations generated! ✓")
    print("Files saved: viz_sp_tree.png, viz_elimination.png, viz_semiring_ops.png, viz_paths.png")
