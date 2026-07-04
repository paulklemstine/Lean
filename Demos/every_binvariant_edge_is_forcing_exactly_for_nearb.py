"""
demo.py — Forcing edges via endpoint deletion.

This self-contained script demonstrates the central results of the accompanying
paper on *forcing edges* of perfect matchings:

  * A perfect matching is modelled as a fixed-point-free involution on the
    vertex set: a pairing rule f with f(f(v)) = v, f(v) != v, and {v, f(v)} an
    edge for every vertex v.

  * An edge uv is a FORCING EDGE if exactly one perfect matching contains it.

  * DELETION CHARACTERISATION (main theorem): uv is forcing  <=>  uv is an edge
    AND the graph with both u and v deleted has a UNIQUE perfect matching.

  * COMPLETENESS PRINCIPLE: if a graph has a unique perfect matching, every one
    of its matching edges is forcing.

  * SYMMETRY: forcing is a property of the undirected edge (uv forcing <=> vu).

The script verifies the deletion characterisation against brute force on several
graphs, and inspects the three classical exceptional bricks (the tetrahedron
K4, the complement of the six-cycle, and the Petersen graph).

Pure standard library; run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterator, List, Set, Tuple

# A graph is (vertices, edge set). Each edge is a frozenset of two vertices.
Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[Set[Vertex], Set[Edge]]
# A perfect matching is represented as a frozenset of its edges.
Matching = FrozenSet[Edge]


def make_graph(vertices: List[Vertex], edges: List[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex list and an edge list."""
    V: Set[Vertex] = set(vertices)
    E: Set[Edge] = {frozenset((a, b)) for a, b in edges if a != b}
    return (V, E)


def neighbors(g: Graph, v: Vertex) -> Set[Vertex]:
    """Return the set of neighbours of v."""
    V, E = g
    return {w for e in E if v in e for w in e if w != v}


def all_perfect_matchings(g: Graph) -> List[Matching]:
    """Enumerate all perfect matchings of g by backtracking.

    Returns a list of matchings, each a frozenset of edges covering every vertex
    exactly once. The empty graph has the single empty matching.
    """
    V, E = g
    verts: List[Vertex] = sorted(V)

    def backtrack(remaining: Tuple[Vertex, ...]) -> Iterator[Matching]:
        if not remaining:
            yield frozenset()
            return
        first = remaining[0]
        rest = remaining[1:]
        for other in rest:
            if frozenset((first, other)) in E:
                sub = tuple(x for x in rest if x != other)
                for m in backtrack(sub):
                    yield m | {frozenset((first, other))}

    return list(backtrack(tuple(verts)))


def delete_vertices(g: Graph, u: Vertex, v: Vertex) -> Graph:
    """Return the graph with vertices u and v (and incident edges) removed."""
    V, E = g
    Vn = {w for w in V if w != u and w != v}
    En = {e for e in E if u not in e and v not in e}
    return (Vn, En)


def is_forcing_bruteforce(g: Graph, u: Vertex, v: Vertex) -> bool:
    """Directly check: is uv an edge lying in exactly one perfect matching?"""
    V, E = g
    if frozenset((u, v)) not in E:
        return False
    containing = [m for m in all_perfect_matchings(g) if frozenset((u, v)) in m]
    return len(containing) == 1


def is_forcing_by_deletion(g: Graph, u: Vertex, v: Vertex) -> bool:
    """Deletion characterisation: uv is an edge and G - u - v has a UNIQUE PM."""
    V, E = g
    if frozenset((u, v)) not in E:
        return False
    deleted = delete_vertices(g, u, v)
    return len(all_perfect_matchings(deleted)) == 1


def forcing_edges(g: Graph) -> List[Edge]:
    """Return the complete forcing spectrum: all forcing edges of g."""
    V, E = g
    out: List[Edge] = []
    for e in E:
        u, v = tuple(e)
        if is_forcing_by_deletion(g, u, v):
            out.append(e)
    return out


def has_unique_perfect_matching(g: Graph) -> bool:
    """True iff g has exactly one perfect matching."""
    return len(all_perfect_matchings(g)) == 1


def fmt_edge(e: Edge) -> str:
    a, b = sorted(e)
    return f"{a}-{b}"


# --------------------------------------------------------------------------
# Named graphs
# --------------------------------------------------------------------------

def path_graph(n: int) -> Graph:
    """Path on n vertices 0-1-2-...-(n-1)."""
    return make_graph(list(range(n)), [(i, i + 1) for i in range(n - 1)])


def cycle_graph(n: int) -> Graph:
    """Cycle on n vertices."""
    return make_graph(list(range(n)), [(i, (i + 1) % n) for i in range(n)])


def complete_graph(n: int) -> Graph:
    """Complete graph K_n."""
    return make_graph(list(range(n)), list(combinations(range(n), 2)))


def complement_of_c6() -> Graph:
    """Complement of the 6-cycle: an exceptional brick."""
    V = list(range(6))
    c6 = {frozenset(((i, (i + 1) % 6))) for i in range(6)}
    edges = [tuple(e) for e in (
        {frozenset(p) for p in combinations(V, 2)} - c6
    )]
    return make_graph(V, edges)


def petersen_graph() -> Graph:
    """The Petersen graph: outer 5-cycle, inner pentagram, spokes."""
    outer = [(i, (i + 1) % 5) for i in range(5)]
    spokes = [(i, i + 5) for i in range(5)]
    inner = [(5 + i, 5 + (i + 2) % 5) for i in range(5)]
    return make_graph(list(range(10)), outer + spokes + inner)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_deletion_agrees_with_bruteforce() -> None:
    print("=" * 70)
    print("1. Deletion characterisation agrees with brute force")
    print("=" * 70)
    graphs = {
        "Path P4": path_graph(4),
        "Path P6": path_graph(6),
        "Cycle C4": cycle_graph(4),
        "Cycle C6": cycle_graph(6),
        "K4": complete_graph(4),
        "K6": complete_graph(6),
        "complement(C6)": complement_of_c6(),
        "Petersen": petersen_graph(),
    }
    for name, g in graphs.items():
        V, E = g
        ok = True
        for e in E:
            u, v = tuple(e)
            if is_forcing_bruteforce(g, u, v) != is_forcing_by_deletion(g, u, v):
                ok = False
                break
        status = "AGREE" if ok else "MISMATCH!"
        n_pm = len(all_perfect_matchings(g))
        print(f"  {name:16s}: {status:9s} (#perfect matchings = {n_pm})")
    print()


def demo_completeness_principle() -> None:
    print("=" * 70)
    print("2. Completeness principle: unique PM => every matching edge forcing")
    print("=" * 70)
    for name, g in [("Path P4", path_graph(4)), ("Path P6", path_graph(6))]:
        pms = all_perfect_matchings(g)
        assert len(pms) == 1, "expected a unique perfect matching"
        the_pm = pms[0]
        all_forcing = all(is_forcing_by_deletion(g, *tuple(e)) for e in the_pm)
        print(f"  {name:10s}: unique PM = "
              f"{{{', '.join(fmt_edge(e) for e in sorted(the_pm, key=lambda s: sorted(s)))}}}")
        print(f"             every matching edge forcing? {all_forcing}")
    print()


def demo_symmetry() -> None:
    print("=" * 70)
    print("3. Symmetry: forcing is a property of the undirected edge")
    print("=" * 70)
    g = path_graph(6)
    V, E = g
    ok = all(
        is_forcing_by_deletion(g, u, v) == is_forcing_by_deletion(g, v, u)
        for e in E for (u, v) in [tuple(e)]
    )
    print(f"  Path P6: forcing(u,v) == forcing(v,u) for all edges? {ok}")
    print()


def demo_forcing_spectrum() -> None:
    print("=" * 70)
    print("4. Forcing spectrum of several graphs")
    print("=" * 70)
    for name, g in [
        ("Path P6", path_graph(6)),
        ("Cycle C6", cycle_graph(6)),
        ("K4", complete_graph(4)),
        ("complement(C6)", complement_of_c6()),
        ("Petersen", petersen_graph()),
    ]:
        fe = forcing_edges(g)
        V, E = g
        print(f"  {name:16s}: {len(fe):2d}/{len(E):2d} edges forcing", end="")
        if fe:
            shown = ", ".join(fmt_edge(e) for e in sorted(fe, key=lambda s: sorted(s))[:8])
            print(f"   [{shown}]")
        else:
            print()
    print()


def demo_exceptional_bricks() -> None:
    print("=" * 70)
    print("5. The three classical exceptional bricks")
    print("=" * 70)
    for name, g in [
        ("K4 (tetrahedron)", complete_graph(4)),
        ("complement(C6)", complement_of_c6()),
        ("Petersen graph", petersen_graph()),
    ]:
        V, E = g
        n_pm = len(all_perfect_matchings(g))
        fe = forcing_edges(g)
        print(f"  {name:20s}: |V|={len(V)}, |E|={len(E)}, "
              f"#PM={n_pm}, forcing edges={len(fe)}")
    print("  (These graphs are the exceptions to the forcing/near-bipartite")
    print("   dichotomy for bricks.)")
    print()


def main() -> None:
    print()
    print("FORCING EDGES VIA ENDPOINT DELETION — numerical demonstration")
    print()
    demo_deletion_agrees_with_bruteforce()
    demo_completeness_principle()
    demo_symmetry()
    demo_forcing_spectrum()
    demo_exceptional_bricks()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
