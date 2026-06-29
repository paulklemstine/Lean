"""
Numerical demonstrations for:

    "Single Forbidden Minors Below Edge Density 3/2:
     An Order-Theoretic Skeleton and Two Sparse Witnesses"

Every routine below mirrors a formally proved theorem from the Lean development.
We use only the Python standard library; graphs are represented as
(vertex_count, edge_list) with edges as frozensets of two distinct vertices.

Theorems exercised:
  * edgeFinset_card_le_of_maxDegree_two   -> handshaking bound |E| <= |V|
  * maxDegree_two_edgeDensity_lt          -> density < 3/2 for max-degree <= 2
  * IsAcyclic.card_edgeSet_add_one_le     -> forest bound |E| + 1 <= |V|
  * acyclic_edgeDensity_lt_threshold      -> forest density < 3/2
  * maxDegree_mono                        -> degree monotone under subgraph order
  * obstructions_excl_singleton (illustrated combinatorially on the minor lattice)
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Dict, FrozenSet, List, Set, Tuple

Edge = FrozenSet[int]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph on vertices {0, ..., n-1}."""

    n: int
    edges: Tuple[Edge, ...]

    def vertex_count(self) -> int:
        return self.n

    def edge_count(self) -> int:
        return len(self.edges)

    def degree(self, v: int) -> int:
        return sum(1 for e in self.edges if v in e)

    def max_degree(self) -> int:
        return max((self.degree(v) for v in range(self.n)), default=0)

    def edge_density(self) -> Fraction:
        """rho(G) = |E| / |V|, defined as 0 on the empty vertex set."""
        if self.n == 0:
            return Fraction(0)
        return Fraction(self.edge_count(), self.n)


# --- Graph constructors ------------------------------------------------------

def path_graph(n: int) -> Graph:
    """Path P_n on n vertices: forest, max degree <= 2."""
    edges = tuple(frozenset((i, i + 1)) for i in range(n - 1))
    return Graph(n, edges)


def cycle_graph(n: int) -> Graph:
    """Cycle C_n on n vertices (n >= 3): NOT a forest, max degree exactly 2."""
    edges = tuple(frozenset((i, (i + 1) % n)) for i in range(n))
    return Graph(n, edges)


def disjoint_union(parts: List[Graph]) -> Graph:
    """Disjoint union; relabels vertices to keep them distinct."""
    offset = 0
    edges: List[Edge] = []
    for g in parts:
        edges.extend(frozenset({a + offset for a in e}) for e in g.edges)
        offset += g.n
    return Graph(offset, tuple(edges))


def complete_graph(n: int) -> Graph:
    edges = tuple(frozenset((i, j)) for i in range(n) for j in range(i + 1, n))
    return Graph(n, edges)


# --- Acyclicity (forest test) ------------------------------------------------

def is_acyclic(g: Graph) -> bool:
    """Union-find acyclicity test: a graph is a forest iff adding edges never
    joins two vertices already in the same component."""
    parent = list(range(g.n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for e in g.edges:
        a, b = tuple(e)
        ra, rb = find(a), find(b)
        if ra == rb:
            return False
        parent[ra] = rb
    return True


# --- Theorem demonstrations --------------------------------------------------

THRESHOLD = Fraction(3, 2)


def check_handshaking_bound(g: Graph) -> bool:
    """edgeFinset_card_le_of_maxDegree_two: max degree <= 2  =>  |E| <= |V|."""
    assert g.max_degree() <= 2
    # Direct handshaking identity check too: sum of degrees == 2|E|.
    assert sum(g.degree(v) for v in range(g.n)) == 2 * g.edge_count()
    return g.edge_count() <= g.vertex_count()


def check_bounded_degree_below_threshold(g: Graph) -> bool:
    """maxDegree_two_edgeDensity_lt: max degree <= 2  =>  rho(G) < 3/2."""
    assert g.max_degree() <= 2
    return g.edge_density() < THRESHOLD


def check_forest_bound(g: Graph) -> bool:
    """IsAcyclic.card_edgeSet_add_one_le: nonempty forest => |E| + 1 <= |V|."""
    assert is_acyclic(g) and g.n > 0
    return g.edge_count() + 1 <= g.vertex_count()


def check_forest_below_threshold(g: Graph) -> bool:
    """acyclic_edgeDensity_lt_threshold: forest => rho(G) < 3/2."""
    assert is_acyclic(g)
    return g.edge_density() < THRESHOLD


def subgraph_remove_edge(g: Graph, e: Edge) -> Graph:
    return Graph(g.n, tuple(x for x in g.edges if x != e))


def check_max_degree_monotone(g: Graph) -> bool:
    """maxDegree_mono: G <= G' (subgraph) => maxDegree G <= maxDegree G'.
    We verify on every single-edge-deletion subgraph."""
    for e in g.edges:
        sub = subgraph_remove_edge(g, e)
        if not sub.max_degree() <= g.max_degree():
            return False
    return True


def obstruction_demo_triangle() -> Tuple[bool, str]:
    """Illustrates obstructions_excl_singleton on the subgraph minor lattice:
    the triangle K_3 is the unique minimal obstruction of the triangle-free
    class excl({K_3}).  Every PROPER subgraph of K_3 (>=1 edge removed) is
    triangle-free, while K_3 itself is not."""
    k3 = complete_graph(3)

    def has_triangle(g: Graph) -> bool:
        adj: Dict[int, Set[int]] = {v: set() for v in range(g.n)}
        for e in g.edges:
            a, b = tuple(e)
            adj[a].add(b)
            adj[b].add(a)
        for a in range(g.n):
            for b in adj[a]:
                if b > a:
                    if adj[a] & adj[b]:
                        return True
        return False

    k3_not_free = has_triangle(k3)  # K_3 not in excl({K_3})
    # all proper subgraphs are triangle-free
    proper_all_free = all(
        not has_triangle(subgraph_remove_edge(k3, e)) for e in k3.edges
    )
    ok = k3_not_free and proper_all_free
    return ok, "K_3 is the unique minimal obstruction of excl({K_3})"


def main() -> None:
    print("=" * 70)
    print("Single Forbidden Minors Below Density 3/2 — numerical demonstrations")
    print("=" * 70)

    # 1. Bounded-degree witness: cycles are tight, contain loops, stay below 3/2.
    print("\n[1] Bounded-degree-<=2 class (paths and cycles), threshold 3/2:")
    print(f"{'graph':<14}{'|V|':>5}{'|E|':>5}{'Delta':>7}{'density':>10}"
          f"{'|E|<=|V|':>10}{'<3/2':>7}{'forest?':>9}")
    samples = [
        ("P_5", path_graph(5)),
        ("C_3", cycle_graph(3)),
        ("C_4", cycle_graph(4)),
        ("C_7", cycle_graph(7)),
        ("C_4 u C_5", disjoint_union([cycle_graph(4), cycle_graph(5)])),
        ("P_3 u C_6", disjoint_union([path_graph(3), cycle_graph(6)])),
    ]
    for name, g in samples:
        assert check_handshaking_bound(g)
        assert check_bounded_degree_below_threshold(g)
        print(f"{name:<14}{g.vertex_count():>5}{g.edge_count():>5}"
              f"{g.max_degree():>7}{str(g.edge_density()):>10}"
              f"{'yes':>10}{'yes':>7}{str(is_acyclic(g)):>9}")

    # 2. Cycles realize tightness |E| = |V|: density exactly 1, still below 3/2.
    print("\n[2] Tightness of |E| <= |V| (cycles): density == 1 < 3/2, not forests")
    for n in (3, 5, 8, 13):
        c = cycle_graph(n)
        assert c.edge_count() == c.vertex_count()  # tight
        assert not is_acyclic(c)  # genuinely beyond the forest class
        assert c.edge_density() == Fraction(1)
        print(f"  C_{n:<3} density = {c.edge_density()} (tight), forest? {is_acyclic(c)}")

    # 3. Forest witness.
    print("\n[3] Forest class, bound |E|+1 <= |V| and density < 3/2:")
    forests = [
        ("P_6", path_graph(6)),
        ("P_2 u P_3", disjoint_union([path_graph(2), path_graph(3)])),
        ("star-ish P_4 u P_4", disjoint_union([path_graph(4), path_graph(4)])),
    ]
    for name, g in forests:
        assert is_acyclic(g)
        assert check_forest_bound(g)
        assert check_forest_below_threshold(g)
        print(f"  {name:<18} |E|+1={g.edge_count()+1} <= |V|={g.vertex_count()},"
              f" density={g.edge_density()} < 3/2")

    # 4. Degree monotonicity under subgraph order.
    print("\n[4] Degree monotonicity (maxDegree_mono) on edge-deletion subgraphs:")
    for name, g in [("C_7", cycle_graph(7)), ("K_4", complete_graph(4))]:
        assert check_max_degree_monotone(g)
        print(f"  {name}: every single-edge subgraph has max degree <= {g.max_degree()}")

    # 5. Strict enlargement: forest class ( bounded-degree-2 class.
    print("\n[5] Strict containment F(V) ( D_2(V):")
    c5 = cycle_graph(5)
    print(f"  C_5 has max degree {c5.max_degree()} (in D_2) but forest? {is_acyclic(c5)}"
          f"  =>  D_2 strictly larger than the forest class")

    # 6. Single-obstruction dictionary illustration.
    print("\n[6] obstructions_excl_singleton (triangle example):")
    ok, msg = obstruction_demo_triangle()
    print(f"  {msg}: {'verified' if ok else 'FAILED'}")

    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
