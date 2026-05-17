#!/usr/bin/env python3
"""
Applications of Tropical SP Network Boundary Rigidity.

Demonstrates real-world applications:
1. Network routing: optimal path computation in communication networks
2. Supply chain optimization: series-parallel logistics networks
3. Tropical circuit analysis: min-plus circuit evaluation
4. Phylogenetic distance: tree metric reconstruction
5. Dynamic programming: Bellman equation structure
"""

import numpy as np
from typing import List, Dict, Tuple
from algorithms import (
    SPNode, atom, series, parallel,
    effective_distance, tropical_closure,
    tropical_vertex_elimination, boundary_distance_matrix,
    canonical_reduce
)


# ============================================================
# Application 1: Network Routing
# ============================================================

def network_routing_demo():
    """
    Tropical SP networks model routing in communication networks.

    In a network where edges represent links with latency (delay),
    the effective distance is the minimum end-to-end latency.
    Series = sequential hops (latencies add).
    Parallel = alternative routes (take the fastest).
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Optimization")
    print("=" * 60)

    # Model a network with two paths from source to destination
    # Path 1: fiber link (3ms) → satellite hop (50ms)
    # Path 2: terrestrial (10ms) → terrestrial (12ms)
    path1 = series(atom(3), atom(50))
    path2 = series(atom(10), atom(12))
    network = parallel(path1, path2)

    print(f"\nNetwork topology:")
    print(f"  Path 1 (fiber→satellite): latency = {effective_distance(path1)} ms")
    print(f"  Path 2 (terrestrial):     latency = {effective_distance(path2)} ms")
    print(f"  Best route:               latency = {effective_distance(network)} ms")
    print(f"\n  The min-plus algebra automatically selects the optimal route!")

    # Adding a third redundant path
    path3 = series(atom(8), atom(8), atom(8))
    enhanced = parallel(network, path3)
    print(f"\n  Adding path 3 (3 hops of 8ms each): {effective_distance(path3)} ms")
    print(f"  Enhanced network optimal:            {effective_distance(enhanced)} ms")


# ============================================================
# Application 2: Supply Chain Optimization
# ============================================================

def supply_chain_demo():
    """
    Supply chains have natural series-parallel structure:
    - Series = sequential processing stages
    - Parallel = alternative suppliers/routes
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Supply Chain Optimization")
    print("=" * 60)

    # Manufacturing pipeline
    # Stage 1: Raw materials (choice of 2 suppliers)
    supplier_a = atom(5)   # 5 days
    supplier_b = atom(3)   # 3 days
    sourcing = parallel(supplier_a, supplier_b)

    # Stage 2: Manufacturing (sequential steps)
    machining = atom(2)
    assembly = atom(4)
    testing = atom(1)
    manufacturing = series(machining, assembly, testing)

    # Stage 3: Shipping (choice of methods)
    air = atom(1)
    sea = atom(14)
    shipping = parallel(air, sea)

    # Total pipeline
    pipeline = series(sourcing, manufacturing, shipping)

    print(f"\n  Sourcing (best supplier):   {effective_distance(sourcing)} days")
    print(f"  Manufacturing:              {effective_distance(manufacturing)} days")
    print(f"  Shipping (fastest):         {effective_distance(shipping)} days")
    print(f"  Total pipeline (optimal):   {effective_distance(pipeline)} days")
    print(f"\n  Boundary rigidity tells us: the external lead time")
    print(f"  uniquely determines the reduced internal structure.")


# ============================================================
# Application 3: Tropical Circuit Analysis
# ============================================================

def circuit_analysis_demo():
    """
    SP networks are tropical circuits: min-plus analogues of Boolean circuits.
    - Parallel = tropical OR (min)
    - Series = tropical AND (add)
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Circuit Analysis")
    print("=" * 60)

    # Build a tropical circuit that computes min(a+b, c+d, a+d)
    a, b, c, d = 3.0, 7.0, 5.0, 2.0

    circuit = parallel(
        series(atom(a), atom(b)),   # a + b = 10
        series(atom(c), atom(d)),   # c + d = 7
        series(atom(a), atom(d))    # a + d = 5
    )

    print(f"\n  Inputs: a={a}, b={b}, c={c}, d={d}")
    print(f"  Circuit computes: min(a+b, c+d, a+d)")
    print(f"    a+b = {a+b}")
    print(f"    c+d = {c+d}")
    print(f"    a+d = {a+d}")
    print(f"  Circuit output: {effective_distance(circuit)}")
    print(f"  Expected: {min(a+b, c+d, a+d)}")

    # Demonstrate that circuit complexity = SP expression size
    from algorithms import sp_size, sp_depth
    print(f"\n  Circuit size (# gates): {sp_size(circuit)}")
    print(f"  Circuit depth: {sp_depth(circuit)}")


# ============================================================
# Application 4: Phylogenetic Distance Reconstruction
# ============================================================

def phylogenetics_demo():
    """
    Tree metrics (phylogenetic distances) are a special case of SP networks.
    The boundary rigidity theorem generalizes tree metric reconstruction.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Phylogenetic Tree Metric")
    print("=" * 60)

    # A simple phylogenetic tree:
    #        root
    #       /    \
    #      v      w
    #     / \      \
    #    A   B      C
    # Distances: root-v = 2, v-A = 1, v-B = 3, root-w = 4, w-C = 1

    # Tree as SP network (from A to C through the tree)
    # d(A, B) = 1 + 3 = 4 (through v)
    # d(A, C) = 1 + 2 + 4 + 1 = 8 (through root)
    # d(B, C) = 3 + 2 + 4 + 1 = 10 (through root)

    # Build the pairwise distance matrix
    D = np.array([
        [0, 4, 8],
        [4, 0, 10],
        [8, 10, 0]
    ])
    print(f"\n  Leaf distance matrix:")
    print(f"    d(A,B) = {D[0,1]}")
    print(f"    d(A,C) = {D[0,2]}")
    print(f"    d(B,C) = {D[1,2]}")

    # Four-point condition check (tree-likeness)
    # For tree metrics: d(w,x) + d(y,z) ≤ max(d(w,y)+d(x,z), d(w,z)+d(x,y))
    labels = ['A', 'B', 'C']
    print(f"\n  Four-point condition (tree-likeness test):")
    lhs = D[0,1] + D[2,2]  # d(A,B) + d(C,C)
    rhs = max(D[0,2] + D[1,2], D[0,2] + D[1,2])
    print(f"    d(A,B) + d(C,C) = {lhs} ≤ max(...) = {rhs}: {'✓' if lhs <= rhs else '✗'}")

    print(f"\n  Tree metric reconstruction is a boundary rigidity problem:")
    print(f"  the leaf-to-leaf distances determine the tree structure.")


# ============================================================
# Application 5: Dynamic Programming (Bellman)
# ============================================================

def dynamic_programming_demo():
    """
    The tropical semiring is the algebraic foundation of dynamic programming.
    SP network evaluation IS Bellman's principle of optimality.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Dynamic Programming (Bellman's Principle)")
    print("=" * 60)

    # Shortest path problem as tropical matrix multiplication
    # Graph: 0 → 1 (cost 2), 0 → 2 (cost 5), 1 → 2 (cost 1), 1 → 3 (cost 4), 2 → 3 (cost 3)
    INF = np.inf
    W = np.array([
        [0,   2,   5,   INF],
        [INF, 0,   1,   4  ],
        [INF, INF, 0,   3  ],
        [INF, INF, INF, 0  ]
    ])

    print(f"\n  Weight matrix (DAG with 4 vertices):")
    print(f"  {W}")

    D = tropical_closure(W)
    print(f"\n  All-pairs shortest paths (tropical closure):")
    print(f"  {D}")

    print(f"\n  Shortest path 0→3: {D[0,3]}")
    print(f"    Via 0→1→2→3: cost = {2 + 1 + 3}")
    print(f"    Via 0→1→3:   cost = {2 + 4}")
    print(f"    Via 0→2→3:   cost = {5 + 3}")
    print(f"    Optimal: {min(2+1+3, 2+4, 5+3)}")

    # As SP expression
    route_012_3 = series(atom(2), atom(1), atom(3))   # 0→1→2→3
    route_01_3 = series(atom(2), atom(4))              # 0→1→3
    route_02_3 = series(atom(5), atom(3))              # 0→2→3
    all_routes = parallel(route_012_3, route_01_3, route_02_3)

    print(f"\n  As SP expression: parallel(series(2,1,3), series(2,4), series(5,3))")
    print(f"  Effective distance: {effective_distance(all_routes)}")
    print(f"  Reduced form: {canonical_reduce(all_routes)}")


# ============================================================
# Application 6: Sensitivity Analysis
# ============================================================

def sensitivity_demo():
    """
    Demonstrate how boundary distance changes with weight perturbations.
    The monotonicity theorems guarantee controlled sensitivity.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 6: Sensitivity Analysis")
    print("=" * 60)

    base_network = parallel(
        series(atom(3), atom(5)),   # path 1: cost 8
        series(atom(4), atom(2))    # path 2: cost 6
    )
    base_dist = effective_distance(base_network)
    print(f"\n  Base network effective distance: {base_dist}")

    # Perturb weights and observe changes
    print(f"\n  Weight perturbation analysis:")
    print(f"  {'Perturbation':30s} {'New dist':>10s} {'Change':>10s}")
    print(f"  {'-'*50}")

    perturbations = [
        ("Path 1, edge 1: 3→2", parallel(series(atom(2), atom(5)), series(atom(4), atom(2)))),
        ("Path 1, edge 1: 3→4", parallel(series(atom(4), atom(5)), series(atom(4), atom(2)))),
        ("Path 2, edge 2: 2→1", parallel(series(atom(3), atom(5)), series(atom(4), atom(1)))),
        ("Path 2, edge 2: 2→3", parallel(series(atom(3), atom(5)), series(atom(4), atom(3)))),
        ("Both paths +1 each edge", parallel(series(atom(4), atom(6)), series(atom(5), atom(3)))),
    ]

    for desc, net in perturbations:
        d = effective_distance(net)
        print(f"  {desc:30s} {d:10.1f} {d - base_dist:+10.1f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    network_routing_demo()
    supply_chain_demo()
    circuit_analysis_demo()
    phylogenetics_demo()
    dynamic_programming_demo()
    sensitivity_demo()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of Series-Parallel Tropical Network Boundary Rigidity.

This script illustrates the key theorems with concrete numerical examples:
1. Compositional tropical semantics (series = add, parallel = min)
2. Canonical reduction to atoms
3. Boundary distance matrix computation
4. Tropical vertex elimination (Schur complement)
5. Boundary rigidity for reduced expressions
"""

import numpy as np
from typing import Union, Tuple


# ============================================================
# SP Expression Tree
# ============================================================

class SPExpr:
    """Two-terminal series-parallel network expression."""
    pass


class Atom(SPExpr):
    """A single edge with weight w."""
    def __init__(self, w: float):
        self.w = w

    def __repr__(self):
        return f"Atom({self.w})"

    def __eq__(self, other):
        return isinstance(other, Atom) and self.w == other.w


class Series(SPExpr):
    """Series composition: connect two networks end-to-end."""
    def __init__(self, e1: SPExpr, e2: SPExpr):
        self.e1 = e1
        self.e2 = e2

    def __repr__(self):
        return f"Series({self.e1}, {self.e2})"

    def __eq__(self, other):
        return isinstance(other, Series) and self.e1 == other.e1 and self.e2 == other.e2


class Parallel(SPExpr):
    """Parallel composition: connect two networks between the same terminals."""
    def __init__(self, e1: SPExpr, e2: SPExpr):
        self.e1 = e1
        self.e2 = e2

    def __repr__(self):
        return f"Parallel({self.e1}, {self.e2})"

    def __eq__(self, other):
        return isinstance(other, Parallel) and self.e1 == other.e1 and self.e2 == other.e2


# ============================================================
# Effective Distance
# ============================================================

def eff_dist(e: SPExpr) -> float:
    """
    Compute the effective distance (boundary observable) of an SP expression.
    - Atom(w): distance = w
    - Series(e1, e2): distance = eff_dist(e1) + eff_dist(e2)
    - Parallel(e1, e2): distance = min(eff_dist(e1), eff_dist(e2))
    """
    if isinstance(e, Atom):
        return e.w
    elif isinstance(e, Series):
        return eff_dist(e.e1) + eff_dist(e.e2)
    elif isinstance(e, Parallel):
        return min(eff_dist(e.e1), eff_dist(e.e2))
    else:
        raise TypeError(f"Unknown SPExpr type: {type(e)}")


def pos_weights(e: SPExpr) -> bool:
    """Check that all atom weights are positive."""
    if isinstance(e, Atom):
        return e.w > 0
    elif isinstance(e, Series):
        return pos_weights(e.e1) and pos_weights(e.e2)
    elif isinstance(e, Parallel):
        return pos_weights(e.e1) and pos_weights(e.e2)
    return False


def reduce(e: SPExpr) -> Atom:
    """Canonical reduction: replace any SP expression with Atom(eff_dist(e))."""
    return Atom(eff_dist(e))


def boundary_matrix(e: SPExpr) -> np.ndarray:
    """
    Boundary distance matrix for a two-terminal network.
    Returns the 2x2 matrix [[0, d], [d, 0]] where d = eff_dist(e).
    """
    d = eff_dist(e)
    return np.array([[0, d], [d, 0]])


# ============================================================
# Tropical Vertex Elimination
# ============================================================

def path_graph_3(w1: float, w2: float) -> np.ndarray:
    """
    Distance matrix for a 3-vertex path graph s--v--t.
    Vertices: 0=s, 1=v, 2=t.
    Edge weights: w1 (s-v), w2 (v-t).
    """
    return np.array([
        [0,      w1,     w1 + w2],
        [w1,     0,      w2     ],
        [w1+w2,  w2,     0      ]
    ])


def boundary_restrict(D: np.ndarray) -> np.ndarray:
    """
    Extract the boundary submatrix for boundary vertices {0, 2}
    from a 3x3 distance matrix.
    """
    indices = [0, 2]
    return D[np.ix_(indices, indices)]


# ============================================================
# Demonstrations
# ============================================================

def demo_compositionality():
    """Demonstrate tropical compositional semantics."""
    print("=" * 60)
    print("DEMO 1: Compositional Tropical Semantics")
    print("=" * 60)

    e1 = Atom(3.0)
    e2 = Atom(5.0)
    e3 = Atom(2.0)

    series_e = Series(e1, e2)
    parallel_e = Parallel(e1, e3)

    print(f"\ne1 = {e1}, eff_dist = {eff_dist(e1)}")
    print(f"e2 = {e2}, eff_dist = {eff_dist(e2)}")
    print(f"e3 = {e3}, eff_dist = {eff_dist(e3)}")
    print(f"\nSeries(e1, e2) = {series_e}")
    print(f"  eff_dist = {eff_dist(series_e)}  (= {eff_dist(e1)} + {eff_dist(e2)})")
    print(f"\nParallel(e1, e3) = {parallel_e}")
    print(f"  eff_dist = {eff_dist(parallel_e)}  (= min({eff_dist(e1)}, {eff_dist(e3)}))")

    # Verify compositionality
    assert eff_dist(series_e) == eff_dist(e1) + eff_dist(e2)
    assert eff_dist(parallel_e) == min(eff_dist(e1), eff_dist(e3))
    print("\n✓ Compositionality verified: series = add, parallel = min")


def demo_algebraic_laws():
    """Demonstrate tropical algebraic laws."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Algebraic Laws")
    print("=" * 60)

    a, b, c = Atom(3.0), Atom(5.0), Atom(2.0)

    # Series associativity
    lhs = eff_dist(Series(Series(a, b), c))
    rhs = eff_dist(Series(a, Series(b, c)))
    print(f"\nSeries associativity: {lhs} = {rhs}  ✓" if lhs == rhs else f"FAIL: {lhs} ≠ {rhs}")

    # Parallel commutativity
    lhs = eff_dist(Parallel(a, b))
    rhs = eff_dist(Parallel(b, a))
    print(f"Parallel commutativity: {lhs} = {rhs}  ✓" if lhs == rhs else f"FAIL")

    # Parallel idempotency
    lhs = eff_dist(Parallel(a, a))
    rhs = eff_dist(a)
    print(f"Parallel idempotency: {lhs} = {rhs}  ✓" if lhs == rhs else f"FAIL")

    # Distributivity: series over parallel
    lhs = eff_dist(Series(a, Parallel(b, c)))
    rhs = eff_dist(Parallel(Series(a, b), Series(a, c)))
    print(f"Left distributivity: {lhs} = {rhs}  ✓" if lhs == rhs else f"FAIL")

    lhs = eff_dist(Series(Parallel(a, b), c))
    rhs = eff_dist(Parallel(Series(a, c), Series(b, c)))
    print(f"Right distributivity: {lhs} = {rhs}  ✓" if lhs == rhs else f"FAIL")


def demo_canonical_reduction():
    """Demonstrate canonical reduction to atoms."""
    print("\n" + "=" * 60)
    print("DEMO 3: Canonical Reduction")
    print("=" * 60)

    # Complex expression
    e = Parallel(
        Series(Atom(2.0), Atom(3.0)),   # effective distance = 5
        Series(Atom(1.0), Atom(6.0))    # effective distance = 7
    )
    # Parallel takes min: eff_dist = min(5, 7) = 5
    print(f"\nExpression: {e}")
    print(f"Effective distance: {eff_dist(e)}")
    print(f"Reduced form: {reduce(e)}")
    print(f"Effective distance of reduced: {eff_dist(reduce(e))}")
    assert eff_dist(e) == eff_dist(reduce(e))
    print("✓ Reduction preserves effective distance")


def demo_boundary_matrix():
    """Demonstrate boundary distance matrix computation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Boundary Distance Matrix")
    print("=" * 60)

    e1 = Atom(3.0)
    e2 = Atom(5.0)

    M1 = boundary_matrix(e1)
    M2 = boundary_matrix(e2)

    print(f"\ne1 = {e1}")
    print(f"Boundary matrix:\n{M1}")

    print(f"\ne2 = {e2}")
    print(f"Boundary matrix:\n{M2}")

    # Series: off-diagonal entries add
    series_e = Series(e1, e2)
    M_series = boundary_matrix(series_e)
    M_series_expected = np.array([[0, 8], [8, 0]])
    print(f"\nSeries(e1, e2) boundary matrix:\n{M_series}")
    assert np.allclose(M_series, M_series_expected)
    print("✓ Series boundary matrix = add off-diagonal entries")

    # Parallel: off-diagonal entries take min
    parallel_e = Parallel(e1, e2)
    M_parallel = boundary_matrix(parallel_e)
    M_parallel_expected = np.array([[0, 3], [3, 0]])
    print(f"\nParallel(e1, e2) boundary matrix:\n{M_parallel}")
    assert np.allclose(M_parallel, M_parallel_expected)
    print("✓ Parallel boundary matrix = min off-diagonal entries")


def demo_vertex_elimination():
    """Demonstrate tropical vertex elimination (Schur complement)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Tropical Vertex Elimination (Schur Complement)")
    print("=" * 60)

    w1, w2 = 3.0, 5.0

    # Full 3-vertex distance matrix
    D = path_graph_3(w1, w2)
    print(f"\n3-vertex path graph (weights {w1}, {w2}):")
    print(f"Full distance matrix:\n{D}")

    # Boundary restriction (eliminate interior vertex)
    D_boundary = boundary_restrict(D)
    print(f"\nBoundary distance matrix (after eliminating vertex 1):\n{D_boundary}")

    # Compare with atom
    M_atom = boundary_matrix(Atom(w1 + w2))
    print(f"\nAtom({w1 + w2}) boundary matrix:\n{M_atom}")
    assert np.allclose(D_boundary, M_atom)
    print("✓ Vertex elimination = tropical Schur complement")

    # Compare with series
    M_series = boundary_matrix(Series(Atom(w1), Atom(w2)))
    print(f"\nSeries(Atom({w1}), Atom({w2})) boundary matrix:\n{M_series}")
    assert np.allclose(D_boundary, M_series)
    print("✓ Vertex elimination = series composition")


def demo_boundary_rigidity():
    """Demonstrate boundary rigidity for reduced expressions."""
    print("\n" + "=" * 60)
    print("DEMO 6: Boundary Rigidity")
    print("=" * 60)

    # Two different complex expressions with the same effective distance
    e1 = Parallel(
        Series(Atom(1.0), Atom(4.0)),  # eff_dist = 5
        Series(Atom(2.0), Atom(3.0))   # eff_dist = 5
    )
    e2 = Series(
        Atom(2.0),
        Atom(3.0)
    )

    print(f"\ne1 = {e1}")
    print(f"  eff_dist = {eff_dist(e1)}")
    print(f"\ne2 = {e2}")
    print(f"  eff_dist = {eff_dist(e2)}")
    print(f"\nBoth have same effective distance: {eff_dist(e1) == eff_dist(e2)}")

    # But their reduced forms are equal!
    r1 = reduce(e1)
    r2 = reduce(e2)
    print(f"\nReduced e1: {r1}")
    print(f"Reduced e2: {r2}")
    print(f"Reduced forms equal: {r1 == r2}")
    assert r1 == r2
    print("✓ Boundary rigidity: same effective distance → same reduced form")


def demo_tropical_semiring():
    """Show that effective distance is a tropical semiring homomorphism."""
    print("\n" + "=" * 60)
    print("DEMO 7: Tropical Semiring Homomorphism")
    print("=" * 60)

    print("\nThe SP expression algebra maps to the tropical semiring (ℝ, +, min):")
    print("  series  ↦  + (tropical multiplication)")
    print("  parallel ↦ min (tropical addition)")
    print()

    # Build a complex expression tree
    a, b, c, d = Atom(1.0), Atom(4.0), Atom(2.0), Atom(3.0)
    expr = Series(
        Parallel(a, b),    # min(1, 4) = 1
        Parallel(c, d)     # min(2, 3) = 2
    )
    # Series: 1 + 2 = 3

    print(f"Expression: Series(Parallel(1, 4), Parallel(2, 3))")
    print(f"Tropical evaluation: ({min(1,4)} ⊕ {min(2,3)}) ⊙ = {min(1,4)} + {min(2,3)} = {min(1,4) + min(2,3)}")
    print(f"eff_dist = {eff_dist(expr)}")
    assert eff_dist(expr) == min(1, 4) + min(2, 3)
    print("✓ Homomorphism verified")


if __name__ == "__main__":
    demo_compositionality()
    demo_algebraic_laws()
    demo_canonical_reduction()
    demo_boundary_matrix()
    demo_vertex_elimination()
    demo_boundary_rigidity()
    demo_tropical_semiring()

    print("\n" + "=" * 60)
    print("ALL DEMOS PASSED ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Series-Parallel Tropical Network Boundary Rigidity.

Generates publication-quality figures illustrating the key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_sp_composition():
    """Visualize series and parallel composition with tropical semantics."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    # Atom
    ax = axes[0]
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-1, 1)
    ax.plot([0, 3], [0, 0], 'b-', linewidth=3)
    ax.plot(0, 0, 'ko', markersize=12, zorder=5)
    ax.plot(3, 0, 'ko', markersize=12, zorder=5)
    ax.text(0, -0.3, 's', fontsize=14, ha='center', fontweight='bold')
    ax.text(3, -0.3, 't', fontsize=14, ha='center', fontweight='bold')
    ax.text(1.5, 0.2, 'w', fontsize=16, ha='center', color='blue', fontweight='bold')
    ax.set_title('Atom(w)\nd(s,t) = w', fontsize=13, fontweight='bold')
    ax.axis('off')

    # Series
    ax = axes[1]
    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-1, 1)
    ax.plot([0, 3], [0, 0], 'b-', linewidth=3)
    ax.plot([3, 6], [0, 0], 'r-', linewidth=3)
    ax.plot(0, 0, 'ko', markersize=12, zorder=5)
    ax.plot(3, 0, 'ko', markersize=12, zorder=5)
    ax.plot(6, 0, 'ko', markersize=12, zorder=5)
    ax.text(0, -0.3, 's', fontsize=14, ha='center', fontweight='bold')
    ax.text(3, -0.3, 'v', fontsize=14, ha='center', fontweight='bold')
    ax.text(6, -0.3, 't', fontsize=14, ha='center', fontweight='bold')
    ax.text(1.5, 0.2, 'w₁', fontsize=16, ha='center', color='blue', fontweight='bold')
    ax.text(4.5, 0.2, 'w₂', fontsize=16, ha='center', color='red', fontweight='bold')
    ax.set_title('Series(N₁, N₂)\nd(s,t) = w₁ + w₂', fontsize=13, fontweight='bold')
    ax.axis('off')

    # Parallel
    ax = axes[2]
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-1.5, 1.5)
    theta1 = np.linspace(0, 1, 50)
    x_top = 3 * theta1
    y_top = 0.8 * np.sin(np.pi * theta1)
    x_bot = 3 * theta1
    y_bot = -0.8 * np.sin(np.pi * theta1)
    ax.plot(x_top, y_top, 'b-', linewidth=3)
    ax.plot(x_bot, y_bot, 'r-', linewidth=3)
    ax.plot(0, 0, 'ko', markersize=12, zorder=5)
    ax.plot(3, 0, 'ko', markersize=12, zorder=5)
    ax.text(0, -0.35, 's', fontsize=14, ha='center', fontweight='bold')
    ax.text(3, -0.35, 't', fontsize=14, ha='center', fontweight='bold')
    ax.text(1.5, 0.95, 'w₁', fontsize=16, ha='center', color='blue', fontweight='bold')
    ax.text(1.5, -1.0, 'w₂', fontsize=16, ha='center', color='red', fontweight='bold')
    ax.set_title('Parallel(N₁, N₂)\nd(s,t) = min(w₁, w₂)', fontsize=13, fontweight='bold')
    ax.axis('off')

    fig.suptitle('Series-Parallel Network Composition', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def viz_tropical_algebra():
    """Visualize the tropical semiring laws."""
    fig, ax = plt.subplots(figsize=(10, 7))

    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')

    # Title
    ax.text(5, 7.5, 'Tropical Semiring Laws for SP Networks',
            fontsize=18, ha='center', fontweight='bold')

    # Laws
    laws = [
        ('Series Associativity:', 'S(S(A,B), C) ≡ S(A, S(B,C))', '(a+b)+c = a+(b+c)'),
        ('Series Commutativity:', 'S(A, B) ≡ S(B, A)', 'a+b = b+a'),
        ('Parallel Associativity:', 'P(P(A,B), C) ≡ P(A, P(B,C))', 'min(min(a,b),c) = min(a,min(b,c))'),
        ('Parallel Commutativity:', 'P(A, B) ≡ P(B, A)', 'min(a,b) = min(b,a)'),
        ('Parallel Idempotency:', 'P(A, A) ≡ A', 'min(a,a) = a'),
        ('Left Distributivity:', 'S(A, P(B,C)) ≡ P(S(A,B), S(A,C))', 'a+min(b,c) = min(a+b,a+c)'),
        ('Right Distributivity:', 'S(P(A,B), C) ≡ P(S(A,C), S(B,C))', 'min(a,b)+c = min(a+c,b+c)'),
    ]

    for i, (name, sp_form, trop_form) in enumerate(laws):
        y = 6.5 - i * 0.85
        ax.text(0.3, y, name, fontsize=12, fontweight='bold', color='#333')
        ax.text(3.5, y, sp_form, fontsize=11, fontfamily='monospace', color='#0066cc')
        ax.text(7.5, y, f'⟹  {trop_form}', fontsize=11, fontfamily='monospace', color='#cc3300')

    # Footer
    ax.text(5, 0.3,
            'SP Algebra ─→ Tropical Semiring (ℝ, +, min)\n'
            'series ↦ + (tropical ⊗)    parallel ↦ min (tropical ⊕)',
            fontsize=13, ha='center', style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

    fig.tight_layout()
    return fig


def viz_vertex_elimination():
    """Visualize tropical vertex elimination (Schur complement)."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    # Before elimination
    ax = axes[0]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-1.5, 1.5)
    # Triangle: s(0,0), v(2,1), t(4,0)
    ax.plot([0, 2], [0, 1], 'b-', linewidth=3)
    ax.plot([2, 4], [1, 0], 'r-', linewidth=3)
    ax.plot(0, 0, 'go', markersize=15, zorder=5)  # boundary
    ax.plot(2, 1, 'o', color='orange', markersize=15, zorder=5)  # interior
    ax.plot(4, 0, 'go', markersize=15, zorder=5)  # boundary
    ax.text(0, -0.5, 's (boundary)', fontsize=11, ha='center')
    ax.text(2, 1.4, 'v (interior)', fontsize=11, ha='center', color='orange')
    ax.text(4, -0.5, 't (boundary)', fontsize=11, ha='center')
    ax.text(0.7, 0.7, 'w₁=3', fontsize=14, color='blue', fontweight='bold')
    ax.text(3.3, 0.7, 'w₂=5', fontsize=14, color='red', fontweight='bold')
    ax.set_title('Before Elimination', fontsize=13, fontweight='bold')
    ax.axis('off')

    # Arrow
    ax = axes[1]
    ax.set_xlim(0, 4)
    ax.set_ylim(-1, 1)
    ax.annotate('', xy=(3.5, 0), xytext=(0.5, 0),
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    ax.text(2, 0.3, 'Tropical\nSchur Complement', fontsize=12,
            ha='center', fontweight='bold', color='purple')
    ax.text(2, -0.5, 'Eliminate vertex v', fontsize=11,
            ha='center', style='italic')
    ax.axis('off')

    # After elimination
    ax = axes[2]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-1.5, 1.5)
    ax.plot([0, 4], [0, 0], 'purple', linewidth=3)
    ax.plot(0, 0, 'go', markersize=15, zorder=5)
    ax.plot(4, 0, 'go', markersize=15, zorder=5)
    ax.text(0, -0.5, 's', fontsize=11, ha='center')
    ax.text(4, -0.5, 't', fontsize=11, ha='center')
    ax.text(2, 0.3, 'w₁+w₂ = 8', fontsize=14, ha='center',
            color='purple', fontweight='bold')
    ax.set_title('After Elimination', fontsize=13, fontweight='bold')
    ax.axis('off')

    fig.suptitle('Tropical Vertex Elimination = Series Composition',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def viz_boundary_rigidity():
    """Visualize the boundary rigidity theorem."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Two different internal structures
    ax = axes[0]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-2, 2)
    # Complex network 1
    ax.plot([0, 2, 4], [0, 1, 0], 'b-', linewidth=2)
    ax.plot([0, 2, 4], [0, -1, 0], 'r-', linewidth=2)
    ax.plot(0, 0, 'go', markersize=15, zorder=5)
    ax.plot(4, 0, 'go', markersize=15, zorder=5)
    ax.plot(2, 1, 'ko', markersize=8, zorder=5)
    ax.plot(2, -1, 'ko', markersize=8, zorder=5)
    ax.text(0.7, 0.8, '2', fontsize=12, color='blue')
    ax.text(3.3, 0.8, '3', fontsize=12, color='blue')
    ax.text(0.7, -0.7, '1', fontsize=12, color='red')
    ax.text(3.3, -0.7, '4', fontsize=12, color='red')
    ax.text(2, -1.8, 'P(S(2,3), S(1,4))\nd = min(5, 5) = 5', fontsize=11, ha='center')
    ax.set_title('Network N₁', fontsize=13, fontweight='bold')
    ax.axis('off')

    ax = axes[1]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-2, 2)
    # Simple network 2
    ax.plot([0, 4], [0, 0], 'purple', linewidth=3)
    ax.plot(0, 0, 'go', markersize=15, zorder=5)
    ax.plot(4, 0, 'go', markersize=15, zorder=5)
    ax.text(2, 0.3, '5', fontsize=14, ha='center', color='purple', fontweight='bold')
    ax.text(2, -1.8, 'Atom(5)\nd = 5', fontsize=11, ha='center')
    ax.set_title('Network N₂ (Reduced)', fontsize=13, fontweight='bold')
    ax.axis('off')

    # Rigidity statement
    ax = axes[2]
    ax.set_xlim(0, 6)
    ax.set_ylim(0, 6)
    ax.axis('off')

    props = dict(boxstyle='round,pad=1', facecolor='lightblue', alpha=0.8)
    ax.text(3, 5, 'Boundary Rigidity Theorem', fontsize=14,
            ha='center', fontweight='bold')
    ax.text(3, 3.8,
            'If two reduced SP networks\nhave the same boundary\ndistance matrix...',
            fontsize=12, ha='center', bbox=props)
    ax.annotate('', xy=(3, 1.8), xytext=(3, 2.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='darkgreen'))
    props2 = dict(boxstyle='round,pad=1', facecolor='lightgreen', alpha=0.8)
    ax.text(3, 1,
            '...then they are\nthe same network!',
            fontsize=13, ha='center', fontweight='bold',
            bbox=props2)

    fig.suptitle('Boundary Distance Determines Reduced SP Structure',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def viz_tropical_homomorphism():
    """Visualize the tropical semiring homomorphism."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 7)
    ax.axis('off')

    # SP Algebra box
    props_sp = dict(boxstyle='round,pad=0.8', facecolor='#E8F4FD', alpha=0.9, edgecolor='#2196F3', linewidth=2)
    ax.text(2.5, 5.5, 'SP Expression Algebra', fontsize=14, ha='center',
            fontweight='bold', bbox=props_sp)
    ax.text(2.5, 4.5, 'Operations:', fontsize=12, ha='center')
    ax.text(2.5, 3.8, '• series(e₁, e₂)', fontsize=11, ha='center', fontfamily='monospace')
    ax.text(2.5, 3.2, '• parallel(e₁, e₂)', fontsize=11, ha='center', fontfamily='monospace')
    ax.text(2.5, 2.5, '• atom(w)', fontsize=11, ha='center', fontfamily='monospace')

    # Arrow
    ax.annotate('effDist', xy=(6.5, 4), xytext=(4.5, 4),
                fontsize=14, fontweight='bold', color='#E91E63',
                arrowprops=dict(arrowstyle='->', lw=3, color='#E91E63'),
                va='center', ha='center')

    # Tropical semiring box
    props_trop = dict(boxstyle='round,pad=0.8', facecolor='#FFF3E0', alpha=0.9, edgecolor='#FF9800', linewidth=2)
    ax.text(7.5, 5.5, 'Tropical Semiring (ℝ, +, min)', fontsize=14, ha='center',
            fontweight='bold', bbox=props_trop)
    ax.text(7.5, 4.5, 'Operations:', fontsize=12, ha='center')
    ax.text(7.5, 3.8, '• a + b  (⊗ tropical mul)', fontsize=11, ha='center', fontfamily='monospace')
    ax.text(7.5, 3.2, '• min(a, b)  (⊕ tropical add)', fontsize=11, ha='center', fontfamily='monospace')
    ax.text(7.5, 2.5, '• w ∈ ℝ', fontsize=11, ha='center', fontfamily='monospace')

    # Homomorphism equations
    props_eq = dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', alpha=0.9, edgecolor='#4CAF50', linewidth=2)
    ax.text(5, 1.2,
            'effDist(series(e₁,e₂)) = effDist(e₁) + effDist(e₂)\n'
            'effDist(parallel(e₁,e₂)) = min(effDist(e₁), effDist(e₂))',
            fontsize=12, ha='center', fontfamily='monospace', bbox=props_eq)

    ax.text(5, 0.3, 'The effective distance is a tropical semiring homomorphism',
            fontsize=11, ha='center', style='italic', color='#666')

    fig.suptitle('Tropical Semiring Homomorphism', fontsize=16, fontweight='bold')
    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and save as files."""

    print("Generating visualizations...")

    figs = {
        'sp_composition': viz_sp_composition(),
        'tropical_algebra': viz_tropical_algebra(),
        'vertex_elimination': viz_vertex_elimination(),
        'boundary_rigidity': viz_boundary_rigidity(),
        'tropical_homomorphism': viz_tropical_homomorphism(),
    }

    for name, fig in figs.items():
        filename = f'{name}.png'
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        print(f"  Saved {filename}")
        plt.close(fig)

    print("All visualizations generated ✓")
    return figs


def get_all_base64():
    """Return all visualizations as base64 data URIs."""
    return {
        'sp_composition': fig_to_base64(viz_sp_composition()),
        'tropical_algebra': fig_to_base64(viz_tropical_algebra()),
        'vertex_elimination': fig_to_base64(viz_vertex_elimination()),
        'boundary_rigidity': fig_to_base64(viz_boundary_rigidity()),
        'tropical_homomorphism': fig_to_base64(viz_tropical_homomorphism()),
    }


if __name__ == "__main__":
    generate_all_visualizations()
