"""Chip-Firing and Divisor Theory on a Finite Graph — Numerical Demonstrations.

This self-contained script demonstrates the key results of the Baker-Norine
divisor-theory foundation:

  * the graph Laplacian (chip-firing operator) and its homomorphism layer
    (lap_zero, lap_const, lap_add, lap_neg, lap_deg_zero);
  * linear (chip-firing) equivalence as an equivalence relation, with degree
    as a class invariant;
  * the easy direction of Riemann-Roch (negative degree => no effective
    representative);
  * the discrete maximum principle: on a connected graph the Laplacian kernel
    is exactly the constant firing patterns;
  * the Brill-Noether number rho(g,r,d) = g - (r+1)(g-d+r) and its four
    identities (Serre duality, genus-zero formula, unit increment, monotonicity).

Everything is inlined; no third-party dependencies are required.
"""

from __future__ import annotations

from collections import deque
from itertools import product
from typing import Dict, List, Set, Tuple

# ---------------------------------------------------------------------------
# Graph representation
# ---------------------------------------------------------------------------

# A graph is given by a vertex list and a symmetric adjacency dictionary.
Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
Divisor = Dict[Vertex, int]
FiringPattern = Dict[Vertex, int]


def make_graph(vertices: List[Vertex], edges: List[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple undirected graph as a symmetric adjacency map."""
    adj: Graph = {v: set() for v in vertices}
    for u, v in edges:
        if u == v:
            continue  # simple graph: no loops
        adj[u].add(v)
        adj[v].add(u)
    return adj


def neighbors(g: Graph, v: Vertex) -> Set[Vertex]:
    return g[v]


def degree(g: Graph, v: Vertex) -> int:
    return len(g[v])


# ---------------------------------------------------------------------------
# The graph Laplacian (chip-firing operator):  (lap f)(v) = sum_{u~v} (f v - f u)
# ---------------------------------------------------------------------------

def lap(g: Graph, f: FiringPattern) -> Divisor:
    """Apply the graph Laplacian to a firing pattern f : V -> Z."""
    return {v: sum(f[v] - f[u] for u in g[v]) for v in g}


def divisor_degree(d: Divisor) -> int:
    """Degree = sum of coefficients."""
    return sum(d.values())


def is_effective(d: Divisor) -> bool:
    """A divisor is effective iff every coefficient is non-negative."""
    return all(c >= 0 for c in d.values())


def add_div(d: Divisor, e: Divisor) -> Divisor:
    return {v: d[v] + e[v] for v in d}


def neg_div(d: Divisor) -> Divisor:
    return {v: -c for v, c in d.items()}


# ---------------------------------------------------------------------------
# Demonstration 1: the homomorphism layer of the Laplacian
# ---------------------------------------------------------------------------

def demo_homomorphism_layer() -> None:
    print("=" * 70)
    print("DEMO 1: The five homomorphism facts of the Laplacian")
    print("=" * 70)
    # A small connected graph: a 4-cycle with a chord (vertices 0,1,2,3).
    g = make_graph([0, 1, 2, 3], [(0, 1), (1, 2), (2, 3), (3, 0), (0, 2)])
    zero: FiringPattern = {v: 0 for v in g}
    const: FiringPattern = {v: 7 for v in g}
    f: FiringPattern = {0: 3, 1: -1, 2: 5, 3: 2}
    h: FiringPattern = {0: -2, 1: 4, 2: 0, 3: 1}

    # lap_zero
    print("lap(0)              =", lap(g, zero), "  (expected all zeros)")
    # lap_const
    print("lap(const 7)        =", lap(g, const), "  (expected all zeros)")
    # lap_add
    fg = {v: f[v] + h[v] for v in g}
    lhs = lap(g, fg)
    rhs = add_div(lap(g, f), lap(g, h))
    print("lap(f+h) == lap f + lap h :", lhs == rhs)
    # lap_neg
    print("lap(-f) == -lap f         :", lap(g, {v: -f[v] for v in g}) == neg_div(lap(g, f)))
    # lap_deg_zero  (conservation of chips)
    print("deg(lap f)          =", divisor_degree(lap(g, f)), "  (expected 0)")
    print("deg(lap h)          =", divisor_degree(lap(g, h)), "  (expected 0)")
    print()


# ---------------------------------------------------------------------------
# Demonstration 2: linear equivalence and degree invariance
# ---------------------------------------------------------------------------

def linearly_equivalent_by(g: Graph, d: Divisor, f: FiringPattern) -> Divisor:
    """Return the divisor obtained from d by firing according to f: d + lap(f)."""
    return add_div(d, lap(g, f))


def demo_linear_equivalence() -> None:
    print("=" * 70)
    print("DEMO 2: Linear (chip-firing) equivalence preserves degree")
    print("=" * 70)
    g = make_graph([0, 1, 2, 3], [(0, 1), (1, 2), (2, 3), (3, 0)])  # 4-cycle
    d: Divisor = {0: 2, 1: 0, 2: -1, 3: 1}
    print("Start divisor D    =", d, " degree =", divisor_degree(d))
    for f in [{0: 1, 1: 0, 2: 0, 3: 0},
              {0: 0, 1: 2, 2: 1, 3: 0},
              {0: -3, 1: 1, 2: 4, 3: 2}]:
        e = linearly_equivalent_by(g, d, f)
        print(f"  fire {f} -> {e}  degree = {divisor_degree(e)}")
    print("Degree is invariant across the whole equivalence class.")
    print()


# ---------------------------------------------------------------------------
# Demonstration 3: easy Riemann-Roch (negative degree => no effective rep)
# ---------------------------------------------------------------------------

def reachable_effective(g: Graph, d: Divisor, bound: int = 4) -> bool:
    """Brute-force search: is some divisor linearly equivalent to d effective?

    We search over firing patterns with entries in [-bound, bound]. Since degree
    is invariant, if deg d < 0 the search is guaranteed to fail (no effective
    divisor of negative degree exists).
    """
    verts = list(g.keys())
    n = len(verts)
    for combo in product(range(-bound, bound + 1), repeat=n):
        f = {verts[i]: combo[i] for i in range(n)}
        if is_effective(linearly_equivalent_by(g, d, f)):
            return True
    return False


def demo_easy_riemann_roch() -> None:
    print("=" * 70)
    print("DEMO 3: Negative degree forces an empty linear system")
    print("=" * 70)
    g = make_graph([0, 1, 2], [(0, 1), (1, 2), (2, 0)])  # triangle
    d_neg: Divisor = {0: 0, 1: -1, 2: -2}   # degree -3
    d_pos: Divisor = {0: 0, 1: -1, 2: 2}    # degree  1
    print("D_neg =", d_neg, " degree =", divisor_degree(d_neg))
    print("  effective representative found?", reachable_effective(g, d_neg),
          "  (theory: impossible, deg < 0)")
    print("D_pos =", d_pos, " degree =", divisor_degree(d_pos))
    print("  effective representative found?", reachable_effective(g, d_pos))
    print()


# ---------------------------------------------------------------------------
# Demonstration 4: the discrete maximum principle (kernel = constants)
# ---------------------------------------------------------------------------

def is_connected(g: Graph) -> bool:
    verts = list(g.keys())
    if not verts:
        return True
    seen: Set[Vertex] = {verts[0]}
    queue = deque([verts[0]])
    while queue:
        v = queue.popleft()
        for u in g[v]:
            if u not in seen:
                seen.add(u)
                queue.append(u)
    return len(seen) == len(verts)


def is_constant(f: FiringPattern) -> bool:
    vals = set(f.values())
    return len(vals) <= 1


def flood_argmax_levelset(g: Graph, f: FiringPattern) -> Set[Vertex]:
    """Propagate the argmax level set across edges that tie the maximum.

    This realizes the proof of the discrete maximum principle: starting at a
    global maximum, repeatedly add any neighbour whose value equals the maximum.
    On a silent (kernel) pattern over a connected graph, this fills the graph.
    """
    m = max(f.values())
    start = next(v for v in g if f[v] == m)
    level: Set[Vertex] = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for u in g[v]:
            if f[u] == m and u not in level:
                level.add(u)
                queue.append(u)
    return level


def demo_maximum_principle() -> None:
    print("=" * 70)
    print("DEMO 4: Discrete maximum principle  (kernel of lap = constants)")
    print("=" * 70)
    g = make_graph([0, 1, 2, 3, 4], [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0), (0, 2)])
    print("Graph connected?", is_connected(g))
    # A non-constant pattern produces a non-zero Laplacian (NOT in the kernel).
    f1: FiringPattern = {0: 0, 1: 1, 2: 0, 3: 2, 4: 1}
    print("Pattern f1        =", f1, " constant?", is_constant(f1))
    print("  lap f1          =", lap(g, f1), " -> in kernel?", all(c == 0 for c in lap(g, f1).values()))
    # A constant pattern is silent.
    f2: FiringPattern = {v: 5 for v in g}
    print("Pattern f2 (const)=", f2)
    print("  lap f2          =", lap(g, f2), " -> in kernel?", all(c == 0 for c in lap(g, f2).values()))
    print("  level-set flood from argmax fills graph:",
          flood_argmax_levelset(g, f2) == set(g.keys()))
    print()


# ---------------------------------------------------------------------------
# Demonstration 5: the Brill-Noether number and its identities
# ---------------------------------------------------------------------------

def bn_number(g: int, r: int, d: int) -> int:
    """Brill-Noether number rho(g,r,d) = g - (r+1)(g - d + r)."""
    return g - (r + 1) * (g - d + r)


def demo_brill_noether() -> None:
    print("=" * 70)
    print("DEMO 5: Brill-Noether number rho(g,r,d) = g - (r+1)(g-d+r)")
    print("=" * 70)
    # Serre duality:  rho(g,r,d) = rho(g, g-1-d+r, 2g-2-d)
    print("Serre duality check (rho(g,r,d) == rho(g, g-1-d+r, 2g-2-d)):")
    ok = True
    for g, r, d in product(range(0, 6), range(0, 5), range(-2, 8)):
        lhs = bn_number(g, r, d)
        rhs = bn_number(g, g - 1 - d + r, 2 * g - 2 - d)
        if lhs != rhs:
            ok = False
            print("  MISMATCH at", (g, r, d))
    print("  holds for all tested (g,r,d):", ok)

    # Genus-zero formula: rho(0,r,d) = (r+1)(d-r)
    print("Genus-zero formula check (rho(0,r,d) == (r+1)(d-r)):",
          all(bn_number(0, r, d) == (r + 1) * (d - r)
              for r in range(0, 6) for d in range(-3, 8)))

    # Unit increment: rho(g,r,d+1) = rho(g,r,d) + (r+1)
    print("Unit increment check (rho(g,r,d+1) - rho(g,r,d) == r+1):",
          all(bn_number(g, r, d + 1) - bn_number(g, r, d) == r + 1
              for g in range(0, 6) for r in range(0, 6) for d in range(-3, 8)))

    # Strict monotonicity in d (for r >= 0)
    print("Strict monotonicity in d (r>=0):",
          all(bn_number(3, r, d) < bn_number(3, r, d + 1)
              for r in range(0, 6) for d in range(-3, 8)))

    print("\nSample table rho(g=3, r, d):")
    print("        d=-1   d=0   d=1   d=2   d=3   d=4   d=5")
    for r in range(0, 4):
        row = "  ".join(f"{bn_number(3, r, d):5d}" for d in range(-1, 6))
        print(f"  r={r}:  {row}")
    print()


# ---------------------------------------------------------------------------
# Bonus: genus and canonical divisor of a graph
# ---------------------------------------------------------------------------

def graph_genus(g: Graph) -> int:
    """Combinatorial genus g = |E| - |V| + 1."""
    num_edges = sum(len(adj) for adj in g.values()) // 2
    num_vertices = len(g)
    return num_edges - num_vertices + 1


def canonical_divisor(g: Graph) -> Divisor:
    """Canonical divisor: coefficient deg(v) - 2 at each vertex."""
    return {v: degree(g, v) - 2 for v in g}


def demo_genus_canonical() -> None:
    print("=" * 70)
    print("DEMO 6: Genus and canonical divisor (deg K = 2g - 2)")
    print("=" * 70)
    examples = {
        "tree (path on 4)": make_graph([0, 1, 2, 3], [(0, 1), (1, 2), (2, 3)]),
        "triangle (K3)": make_graph([0, 1, 2], [(0, 1), (1, 2), (2, 0)]),
        "K4": make_graph([0, 1, 2, 3],
                         [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]),
    }
    for name, g in examples.items():
        gen = graph_genus(g)
        k = canonical_divisor(g)
        print(f"{name:18s}: genus = {gen}, K = {k}, "
              f"deg K = {divisor_degree(k)} (should be {2 * gen - 2})")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_homomorphism_layer()
    demo_linear_equivalence()
    demo_easy_riemann_roch()
    demo_maximum_principle()
    demo_brill_noether()
    demo_genus_canonical()


if __name__ == "__main__":
    main()
