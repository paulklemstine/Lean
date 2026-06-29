"""
demo.py — Numerical demonstrations of the parity theory of Eulerian trails
in finite undirected multigraphs with loops.

This script is fully self-contained (standard library only) and mirrors the
formal development:

  * Multigraph                -> two endpoint arrays endpt1, endpt2
  * degree(G, v)              -> loops counted twice
  * Trail                     -> a walk + an edge permutation + adjacency
  * Local parity identity     -> deg(v) + s(v) + e(v) = 2 * vis(v)
  * odd_degree -> endpoint
  * at most two odd vertices
  * closed trail -> all even degrees

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, Tuple, Dict, Set, Optional


# ---------------------------------------------------------------------------
# Combinatorial model
# ---------------------------------------------------------------------------

@dataclass
class Multigraph:
    """Finite undirected multigraph with loops.

    Vertices are 0..n_vertices-1. Edge e has endpoints endpt1[e], endpt2[e].
    A loop is an edge with endpt1[e] == endpt2[e].
    """
    n_vertices: int
    endpt1: List[int]
    endpt2: List[int]

    @property
    def n_edges(self) -> int:
        return len(self.endpt1)

    def is_loop(self, e: int) -> bool:
        return self.endpt1[e] == self.endpt2[e]


def degree(g: Multigraph, v: int) -> int:
    """Degree of v: incidences over BOTH endpoint slots. A loop adds 2."""
    return (sum(1 for e in range(g.n_edges) if g.endpt1[e] == v)
            + sum(1 for e in range(g.n_edges) if g.endpt2[e] == v))


def degree_sequence(g: Multigraph) -> List[int]:
    return [degree(g, v) for v in range(g.n_vertices)]


def odd_degree_vertices(g: Multigraph) -> Set[int]:
    return {v for v in range(g.n_vertices) if degree(g, v) % 2 == 1}


# ---------------------------------------------------------------------------
# Eulerian trails
# ---------------------------------------------------------------------------

@dataclass
class Trail:
    """An Eulerian trail: a walk of n_edges+1 vertices and an edge permutation.

    edge_perm[i] is the edge crossed at step i; it must be a permutation of
    range(n_edges) (every edge used exactly once).
    """
    graph: Multigraph
    verts: List[int]          # length n_edges + 1
    edge_perm: List[int]      # length n_edges, a permutation

    def start(self) -> int:
        return self.verts[0]

    def last(self) -> int:
        return self.verts[-1]

    def is_closed(self) -> bool:
        return self.start() == self.last()

    def is_permutation(self) -> bool:
        return sorted(self.edge_perm) == list(range(self.graph.n_edges))

    def adjacency_holds(self) -> bool:
        """Each step crosses its edge in one of the two orientations."""
        g = self.graph
        for i in range(g.n_edges):
            e = self.edge_perm[i]
            a, b = self.verts[i], self.verts[i + 1]
            ok = ((g.endpt1[e] == a and g.endpt2[e] == b)
                  or (g.endpt1[e] == b and g.endpt2[e] == a))
            if not ok:
                return False
        return True

    def is_valid(self) -> bool:
        return (len(self.verts) == self.graph.n_edges + 1
                and self.is_permutation()
                and self.adjacency_holds())


# Counting functionals (mirroring the Lean definitions)

def visit_count(t: Trail, v: int) -> int:
    return sum(1 for x in t.verts if x == v)


def start_indicator(t: Trail, v: int) -> int:
    return 1 if t.verts[0] == v else 0


def end_indicator(t: Trail, v: int) -> int:
    return 1 if t.verts[-1] == v else 0


# ---------------------------------------------------------------------------
# Verification of the theorems on concrete instances
# ---------------------------------------------------------------------------

def check_parity_identity(t: Trail) -> bool:
    """deg(v) + s(v) + e(v) == 2 * vis(v) for every vertex."""
    g = t.graph
    for v in range(g.n_vertices):
        lhs = degree(g, v) + start_indicator(t, v) + end_indicator(t, v)
        rhs = 2 * visit_count(t, v)
        if lhs != rhs:
            return False
    return True


def check_odd_are_endpoints(t: Trail) -> bool:
    g = t.graph
    for v in odd_degree_vertices(g):
        if v != t.start() and v != t.last():
            return False
    return True


def check_at_most_two_odd(g: Multigraph) -> bool:
    return len(odd_degree_vertices(g)) <= 2


# ---------------------------------------------------------------------------
# Examples
# ---------------------------------------------------------------------------

def example_path_triangle() -> Tuple[Multigraph, Trail]:
    """Open trail on a path 0-1-2 plus the edge 2-0 ... actually a triangle
    traversed as an open trail 0->1->2->0 is closed; here an OPEN trail.

    Graph: a 'P' shape: edges {0-1, 1-2, 2-0, 0-3}. Degrees:
      v0: 0-1, 2-0, 0-3 -> 3 (odd)
      v1: 0-1, 1-2      -> 2
      v2: 1-2, 2-0      -> 2
      v3: 0-3           -> 1 (odd)
    Odd vertices {0,3} -> open trail with endpoints 3 and 0 (or 0 and 3).
    Trail: 3 ->(0-3) 0 ->(2-0) 2 ->(1-2) 1 ->(0-1) 0.
    """
    g = Multigraph(
        n_vertices=4,
        endpt1=[0, 1, 2, 0],   # edges: e0=0-1, e1=1-2, e2=2-0, e3=0-3
        endpt2=[1, 2, 0, 3],
    )
    # walk vertices: 3,0,2,1,0   edges in order: e3,e2,e1,e0
    t = Trail(graph=g, verts=[3, 0, 2, 1, 0], edge_perm=[3, 2, 1, 0])
    return g, t


def example_closed_triangle_with_loop() -> Tuple[Multigraph, Trail]:
    """Closed trail on a triangle with a loop at vertex 0.

    Edges: e0=0-1, e1=1-2, e2=2-0, e3=loop at 0.
    Degrees: v0: e0,e2,e3(x2) = 1+1+2 = 4 ; v1: e0,e1 = 2 ; v2: e1,e2 = 2.
    All even -> closed Eulerian trail exists.
    Trail: 0 ->(loop) 0 ->(0-1) 1 ->(1-2) 2 ->(2-0) 0.
    """
    g = Multigraph(
        n_vertices=3,
        endpt1=[0, 1, 2, 0],   # e3 is the loop 0-0
        endpt2=[1, 2, 0, 0],
    )
    t = Trail(graph=g, verts=[0, 0, 1, 2, 0], edge_perm=[3, 0, 1, 2])
    return g, t


def koenigsberg() -> Multigraph:
    """The Seven Bridges of Koenigsberg multigraph.

    4 landmasses A=0, B=1, C=2, D=3 ; 7 bridges.
    A-B (x2), A-C (x2), A-D, B-D, C-D.
    """
    return Multigraph(
        n_vertices=4,
        endpt1=[0, 0, 0, 0, 0, 1, 2],
        endpt2=[1, 1, 2, 2, 3, 3, 3],
    )


def banner(title: str) -> None:
    print("\n" + "=" * 68)
    print(title)
    print("=" * 68)


def main() -> None:
    banner("Example 1 — Open Eulerian trail (two odd-degree endpoints)")
    g1, t1 = example_path_triangle()
    print("degree sequence :", degree_sequence(g1))
    print("odd vertices    :", sorted(odd_degree_vertices(g1)))
    print("trail valid     :", t1.is_valid())
    print("start, end      :", t1.start(), t1.last())
    print("parity identity :", check_parity_identity(t1))
    print("odd->endpoint   :", check_odd_are_endpoints(t1))
    print("<=2 odd         :", check_at_most_two_odd(g1))
    print("per-vertex (deg + s + e, 2*vis):")
    for v in range(g1.n_vertices):
        lhs = degree(g1, v) + start_indicator(t1, v) + end_indicator(t1, v)
        print(f"   v{v}: {lhs} = {2 * visit_count(t1, v)}")

    banner("Example 2 — Closed Eulerian trail with a loop (all even degrees)")
    g2, t2 = example_closed_triangle_with_loop()
    print("degree sequence :", degree_sequence(g2), "(loop at 0 counts twice)")
    print("odd vertices    :", sorted(odd_degree_vertices(g2)))
    print("trail valid     :", t2.is_valid())
    print("is closed       :", t2.is_closed())
    print("parity identity :", check_parity_identity(t2))
    print("all even degree :", len(odd_degree_vertices(g2)) == 0)

    banner("Example 3 — Seven Bridges of Koenigsberg (impossible)")
    gk = koenigsberg()
    odd = sorted(odd_degree_vertices(gk))
    print("degree sequence :", degree_sequence(gk))
    print("odd vertices    :", odd, f"(count = {len(odd)})")
    print("at most two odd :", check_at_most_two_odd(gk))
    print("=> Eulerian trail exists? ", check_at_most_two_odd(gk))
    print("Conclusion: 4 > 2 odd-degree vertices, so NO Eulerian trail exists.")

    banner("Global handshake check: sum of degrees = 2 * #edges")
    for name, g in [("Ex1", g1), ("Ex2", g2), ("Koenigsberg", gk)]:
        s = sum(degree_sequence(g))
        print(f"   {name:12s}: sum(deg) = {s}, 2*E = {2 * g.n_edges}, "
              f"#odd = {len(odd_degree_vertices(g))} (even: {len(odd_degree_vertices(g)) % 2 == 0})")


if __name__ == "__main__":
    main()
