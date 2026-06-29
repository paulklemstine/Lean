"""
Chip-Firing, Divisors, and the Riemann-Roch Theorem for Complete Graphs
=======================================================================

A self-contained numerical companion to the formally verified development of
Baker-Norine divisor theory on finite graphs, specialized to the complete
graphs K_n.

Every function is inlined and uses only the Python standard library.  The code
demonstrates, by direct computation, the verified theorems:

  * graph Laplacian (chip-firing operator) and its four structural properties
  * every principal divisor has degree zero (the conservation law)
  * genus  g(K_n) = (n-1)(n-2)/2
  * canonical coefficient  K(v) = deg(v) - 2 = n - 3  on K_n
  * canonical degree  deg K = n(n-3) = 2g - 2

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Tuple

# A graph is represented by its vertex list and an adjacency predicate / set of
# undirected edges (frozensets of two vertices).
Vertex = int
Edge = frozenset
Divisor = Dict[Vertex, int]
FiringPattern = Dict[Vertex, int]


# ---------------------------------------------------------------------------
# Graph construction
# ---------------------------------------------------------------------------
def complete_graph(n: int) -> Tuple[List[Vertex], List[Edge]]:
    """Return (vertices, edges) of the complete graph K_n on {0,...,n-1}."""
    vertices: List[Vertex] = list(range(n))
    edges: List[Edge] = [frozenset(pair) for pair in combinations(vertices, 2)]
    return vertices, edges


def neighbors(v: Vertex, edges: List[Edge]) -> List[Vertex]:
    """All vertices adjacent to v."""
    out: List[Vertex] = []
    for e in edges:
        if v in e:
            (other,) = e - {v}
            out.append(other)
    return sorted(out)


def degree(v: Vertex, edges: List[Edge]) -> int:
    """Number of edges incident to v."""
    return len(neighbors(v, edges))


# ---------------------------------------------------------------------------
# Divisor arithmetic
# ---------------------------------------------------------------------------
def divisor_degree(D: Divisor, vertices: List[Vertex]) -> int:
    """deg D = sum of coefficients."""
    return sum(D.get(v, 0) for v in vertices)


def is_effective(D: Divisor, vertices: List[Vertex]) -> bool:
    """D >= 0 iff every coefficient is non-negative."""
    return all(D.get(v, 0) >= 0 for v in vertices)


def single_vertex_divisor(v0: Vertex, k: int, vertices: List[Vertex]) -> Divisor:
    """The divisor k[v0]."""
    return {v: (k if v == v0 else 0) for v in vertices}


# ---------------------------------------------------------------------------
# The graph Laplacian (chip-firing operator)
# ---------------------------------------------------------------------------
def laplacian(f: FiringPattern, vertices: List[Vertex], edges: List[Edge]) -> Divisor:
    """(lap f)(v) = sum_{u ~ v} (f[v] - f[u])."""
    return {
        v: sum(f.get(v, 0) - f.get(u, 0) for u in neighbors(v, edges))
        for v in vertices
    }


# ---------------------------------------------------------------------------
# Genus and canonical divisor
# ---------------------------------------------------------------------------
def genus(vertices: List[Vertex], edges: List[Edge]) -> int:
    """g = |E| - |V| + 1 (first Betti number)."""
    return len(edges) - len(vertices) + 1


def canonical_divisor(vertices: List[Vertex], edges: List[Edge]) -> Divisor:
    """K(v) = deg(v) - 2."""
    return {v: degree(v, edges) - 2 for v in vertices}


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_closed_forms() -> None:
    print("=" * 68)
    print("Closed-form invariants of complete graphs K_n")
    print("=" * 68)
    header = f"{'n':>3} | {'|E|':>5} | {'genus':>6} | {'K-coeff':>8} | {'deg K':>6} | {'2g-2':>5}"
    print(header)
    print("-" * len(header))
    for n in range(3, 8):
        V, E = complete_graph(n)
        g = genus(V, E)
        K = canonical_divisor(V, E)
        kcoeff = K[0]                      # constant across vertices
        degK = divisor_degree(K, V)
        # verify the predicted formulas
        assert len(E) == n * (n - 1) // 2
        assert g == (n - 1) * (n - 2) // 2
        assert kcoeff == n - 3
        assert degK == n * (n - 3)
        assert degK == 2 * g - 2
        print(f"{n:>3} | {len(E):>5} | {g:>6} | {kcoeff:>8} | {degK:>6} | {2*g-2:>5}")
    print("All closed-form assertions PASSED.\n")


def demo_conservation_law() -> None:
    print("=" * 68)
    print("Conservation law: every principal divisor has degree zero")
    print("=" * 68)
    V, E = complete_graph(5)
    test_patterns: List[FiringPattern] = [
        {0: 1, 1: 0, 2: 0, 3: 0, 4: 0},       # fire vertex 0 once
        {v: v for v in V},                     # ramp
        {0: 3, 1: -2, 2: 7, 3: -5, 4: 1},      # arbitrary
        {v: 4 for v in V},                     # constant -> should give 0 divisor
    ]
    for f in test_patterns:
        D = laplacian(f, V, E)
        deg = divisor_degree(D, V)
        print(f"  pattern {f}  ->  lap = {D},  deg = {deg}")
        assert deg == 0
    # constant pattern kills everything
    const = laplacian({v: 4 for v in V}, V, E)
    assert all(c == 0 for c in const.values())
    print("All principal divisors have degree 0; constant patterns are invisible.\n")


def demo_laplacian_homomorphism() -> None:
    print("=" * 68)
    print("Structural properties of the Laplacian (homomorphism layer)")
    print("=" * 68)
    V, E = complete_graph(4)
    f = {0: 2, 1: -1, 2: 5, 3: 0}
    g = {0: 1, 1: 1, 2: -3, 3: 4}
    # additivity
    fg = {v: f[v] + g[v] for v in V}
    lhs = laplacian(fg, V, E)
    rhs = {v: laplacian(f, V, E)[v] + laplacian(g, V, E)[v] for v in V}
    assert lhs == rhs
    print("  lap(f+g) = lap f + lap g           : OK")
    # negation
    nf = {v: -f[v] for v in V}
    assert laplacian(nf, V, E) == {v: -laplacian(f, V, E)[v] for v in V}
    print("  lap(-f) = -lap f                   : OK")
    # zero
    assert all(c == 0 for c in laplacian({v: 0 for v in V}, V, E).values())
    print("  lap 0 = 0                          : OK")
    print()


def demo_winnability_obstruction() -> None:
    print("=" * 68)
    print("Degree obstruction to winnability on K_4")
    print("=" * 68)
    V, E = complete_graph(4)
    # A divisor in net debt can never be made effective by firing.
    D = {0: -2, 1: 1, 2: 0, 3: 0}   # degree -1 < 0  => never winnable
    print(f"  divisor {D}, degree = {divisor_degree(D, V)}")
    print("  degree < 0  =>  not winnable (firing preserves degree).")
    assert divisor_degree(D, V) < 0
    # canonical divisor degree on K_4 is positive (= 4)
    K = canonical_divisor(V, E)
    print(f"  canonical divisor {K}, degree = {divisor_degree(K, V)} = 2g-2.\n")


def demo_riemann_roch_prediction() -> None:
    print("=" * 68)
    print("Riemann-Roch prediction at D = K  ->  r(K) = g - 1")
    print("=" * 68)
    print("  r(K) - r(0) = deg K + 1 - g = (2g-2) + 1 - g = g - 1,  with r(0) = 0.")
    for n in range(3, 8):
        V, E = complete_graph(n)
        g = genus(V, E)
        print(f"  K_{n}: g = {g:>2},  predicted r(K) = g - 1 = {g - 1}")
    print()


if __name__ == "__main__":
    demo_closed_forms()
    demo_conservation_law()
    demo_laplacian_homomorphism()
    demo_winnability_obstruction()
    demo_riemann_roch_prediction()
    print("All demonstrations completed successfully.")
