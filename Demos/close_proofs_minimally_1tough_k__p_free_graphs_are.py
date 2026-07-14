"""
Numerical demonstrations for:

    Toughness, Minimal Toughness, and Forbidden Induced Subgraphs
    Toward Hamiltonicity of Minimally 1-Tough (K1 u P4)-Free Graphs

Everything is self-contained: graphs are represented as (vertex set,
adjacency set of frozenset pairs).  We demonstrate, by direct computation,
each headline result of the paper:

  * component count c(G - S) and its monotonicity under edge additions
  * monotonicity of 1-toughness (the Chvatal reduction)
  * the minimum-degree theorem (deg >= 2) for 1-tough graphs, n >= 3
  * the density theorem (|E| >= n) via the handshake identity
  * the triangle K3 as a minimally 1-tough, (K1 u P4)-free, Hamiltonian graph
  * K3 is the unique minimally 1-tough complete graph (checked for n = 3..6)

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[Set[Vertex], Set[Edge]]


# --------------------------------------------------------------------------
# Basic graph utilities
# --------------------------------------------------------------------------
def make_graph(vertices: Iterable[Vertex], edges: Iterable[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex list and an edge list."""
    V: Set[Vertex] = set(vertices)
    E: Set[Edge] = {frozenset((a, b)) for (a, b) in edges if a != b}
    return (V, E)


def complete_graph(n: int) -> Graph:
    """The complete graph K_n on vertices 0..n-1."""
    V = set(range(n))
    E = {frozenset((a, b)) for a, b in combinations(range(n), 2)}
    return (V, E)


def cycle_graph(n: int) -> Graph:
    """The pure cycle C_n on vertices 0..n-1."""
    V = set(range(n))
    E = {frozenset((i, (i + 1) % n)) for i in range(n)}
    return (V, E)


def neighbors(G: Graph, v: Vertex) -> Set[Vertex]:
    """Neighbour set of v."""
    _, E = G
    out: Set[Vertex] = set()
    for e in E:
        if v in e:
            out |= (e - {v})
    return out


def degree(G: Graph, v: Vertex) -> int:
    """Degree of v."""
    return len(neighbors(G, v))


def num_components(G: Graph) -> int:
    """Number of connected components of G (union-find style BFS)."""
    V, _ = G
    unseen: Set[Vertex] = set(V)
    comps = 0
    while unseen:
        start = next(iter(unseen))
        stack = [start]
        unseen.discard(start)
        while stack:
            x = stack.pop()
            for y in neighbors(G, x):
                if y in unseen:
                    unseen.discard(y)
                    stack.append(y)
        comps += 1
    return comps


def delete_vertices(G: Graph, S: Set[Vertex]) -> Graph:
    """G - S : delete vertices S and all incident edges."""
    V, E = G
    Vp = V - S
    Ep = {e for e in E if not (e & S)}
    return (Vp, Ep)


def component_count_after_deletion(G: Graph, S: Set[Vertex]) -> int:
    """c(G - S)."""
    return num_components(delete_vertices(G, S))


# --------------------------------------------------------------------------
# Toughness
# --------------------------------------------------------------------------
def is_connected(G: Graph) -> bool:
    V, _ = G
    return len(V) == 0 or num_components(G) == 1


def is_one_tough(G: Graph) -> bool:
    """
    G is 1-tough iff it is connected and for every S whose deletion
    disconnects G we have |S| >= c(G - S).  We check all subsets S.
    """
    V, _ = G
    if not is_connected(G):
        return False
    verts = sorted(V)
    for r in range(len(verts) + 1):
        for S_tuple in combinations(verts, r):
            S = set(S_tuple)
            c = component_count_after_deletion(G, S)
            if c > 1 and c > len(S):   # disconnected and violating the bound
                return False
    return True


def is_minimally_one_tough(G: Graph) -> bool:
    """G is 1-tough but G - e fails 1-toughness for every edge e."""
    V, E = G
    if not is_one_tough(G):
        return False
    for e in E:
        Gp = (set(V), set(E) - {e})
        if is_one_tough(Gp):
            return False
    return True


# --------------------------------------------------------------------------
# Forbidden induced subgraph K1 u P4
# --------------------------------------------------------------------------
def has_induced_K1_P4(G: Graph) -> bool:
    """
    Does G contain an induced K1 u P4?  We look for 5 vertices {e, a, b, c, d}
    where a-b-c-d is an induced path and e is adjacent to none of a,b,c,d.
    """
    V, E = G

    def adj(x: Vertex, y: Vertex) -> bool:
        return frozenset((x, y)) in E

    verts = sorted(V)
    for five in combinations(verts, 5):
        for perm in permutations(five):
            e, a, b, c, d = perm
            # induced P4 on a-b-c-d:
            path_ok = (adj(a, b) and adj(b, c) and adj(c, d)
                       and not adj(a, c) and not adj(a, d) and not adj(b, d))
            # e isolated from the path:
            iso_ok = (not adj(e, a) and not adj(e, b)
                      and not adj(e, c) and not adj(e, d))
            if path_ok and iso_ok:
                return True
    return False


def is_K1P4_free(G: Graph) -> bool:
    return not has_induced_K1_P4(G)


# --------------------------------------------------------------------------
# Hamiltonicity
# --------------------------------------------------------------------------
def is_hamiltonian(G: Graph) -> bool:
    """Brute-force search for a Hamiltonian cycle (fine for small n)."""
    V, E = G
    verts = sorted(V)
    n = len(verts)
    if n < 3:
        return False

    def adj(x: Vertex, y: Vertex) -> bool:
        return frozenset((x, y)) in E

    start = verts[0]
    rest = verts[1:]
    for perm in permutations(rest):
        cyc = [start] + list(perm)
        ok = all(adj(cyc[i], cyc[(i + 1) % n]) for i in range(n))
        if ok:
            return True
    return False


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_component_monotonicity() -> None:
    print("=" * 68)
    print("1. Component count is monotone under edge additions:  c(G-S) <= c(C-S)")
    print("=" * 68)
    C = cycle_graph(6)                       # skeleton
    # G = C plus a chord
    Gv, Ge = cycle_graph(6)
    Ge = set(Ge) | {frozenset((0, 3))}
    G = (Gv, Ge)
    for S in ({0}, {0, 3}, {1, 4}, {0, 2, 4}):
        cC = component_count_after_deletion(C, S)
        cG = component_count_after_deletion(G, S)
        flag = "OK" if cG <= cC else "VIOLATION"
        print(f"  S={sorted(S)!s:<12} c(C-S)={cC}  c(G-S)={cG}   [{flag}]")
    print()


def demo_toughness_monotonicity() -> None:
    print("=" * 68)
    print("2. Toughness monotone under edge additions (Chvatal reduction)")
    print("=" * 68)
    C = cycle_graph(5)
    print(f"  Pure cycle C5 is 1-tough:            {is_one_tough(C)}")
    Gv, Ge = cycle_graph(5)
    G = (Gv, set(Ge) | {frozenset((0, 2)), frozenset((1, 3))})
    print(f"  C5 + chords (supergraph) is 1-tough: {is_one_tough(G)}")
    print("  => adding edges preserved 1-toughness, as the theorem predicts.")
    print()


def demo_min_degree_and_density() -> None:
    print("=" * 68)
    print("3. Minimum-degree theorem (deg>=2) and density theorem (|E|>=n)")
    print("=" * 68)
    families = [("C6", cycle_graph(6)), ("K4", complete_graph(4)),
                ("K5", complete_graph(5))]
    for name, G in families:
        V, E = G
        if is_one_tough(G):
            mind = min(degree(G, v) for v in V)
            print(f"  {name:<3}: 1-tough, min degree={mind} (>=2 OK), "
                  f"|V|={len(V)}, |E|={len(E)} (|E|>=|V|: {len(E) >= len(V)})")
    # a non-1-tough example: a path has a degree-1 vertex
    P = make_graph(range(4), [(0, 1), (1, 2), (2, 3)])
    print(f"  P4 (a path): 1-tough? {is_one_tough(P)}  "
          f"(has a degree-1 vertex -> not 1-tough, as predicted)")
    print()


def demo_triangle_witness() -> None:
    print("=" * 68)
    print("4. The triangle K3 : a full witness of the guiding theorem")
    print("=" * 68)
    K3 = complete_graph(3)
    print(f"  minimally 1-tough : {is_minimally_one_tough(K3)}")
    print(f"  (K1 u P4)-free    : {is_K1P4_free(K3)}")
    print(f"  Hamiltonian       : {is_hamiltonian(K3)}")
    print()


def demo_unique_minimal_complete() -> None:
    print("=" * 68)
    print("5. K3 is the unique minimally 1-tough complete graph (n = 3..6)")
    print("=" * 68)
    for n in range(3, 7):
        Kn = complete_graph(n)
        print(f"  K{n}: 1-tough={is_one_tough(Kn)}, "
              f"minimally 1-tough={is_minimally_one_tough(Kn)}")
    print()


def main() -> None:
    demo_component_monotonicity()
    demo_toughness_monotonicity()
    demo_min_degree_and_density()
    demo_triangle_witness()
    demo_unique_minimal_complete()


if __name__ == "__main__":
    main()
