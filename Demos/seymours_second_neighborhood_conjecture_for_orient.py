"""
Numerical demonstrations for the structural base cases of
Seymour's Second Neighborhood Conjecture (SSNC).

An *oriented graph* is a directed graph with no loops and no digons
(no pair of opposite arcs). Equivalently its adjacency relation is
asymmetric: adj[u][v] implies not adj[v][u].

For a vertex v:
  - N+(v)  = { w : adj[v][w] }                       (first out-neighborhood)
  - N++(v) = { w : w != v, w not in N+(v),
                    exists x with adj[v][x] and adj[x][w] }  (second out-neighborhood)

A *Seymour vertex* satisfies |N+(v)| <= |N++(v)|. SSNC asserts every finite
oriented graph has one. This script demonstrates the proven base cases:

  * minimum out-degree <= 1  => a Seymour vertex exists
  * transitive               => a sink (hence Seymour vertex) exists
  * functional (out-deg 1)   => every vertex is a Seymour vertex
  * the 2-vertex digon       => NO Seymour vertex (needs asymmetry!)

and exhaustively verifies SSNC on all small oriented graphs.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Set, Tuple

Graph = List[List[bool]]  # adjacency matrix; Graph[u][v] == arc u -> v


# --------------------------------------------------------------------------
# Core neighborhood computations
# --------------------------------------------------------------------------
def is_asymmetric(adj: Graph) -> bool:
    """True iff adj encodes an oriented graph (no loops, no digons)."""
    n = len(adj)
    for u in range(n):
        if adj[u][u]:
            return False
        for v in range(n):
            if adj[u][v] and adj[v][u]:
                return False
    return True


def out_neighborhood(adj: Graph, v: int) -> Set[int]:
    """N+(v): direct out-neighbors of v."""
    return {w for w in range(len(adj)) if adj[v][w]}


def second_out_neighborhood(adj: Graph, v: int) -> Set[int]:
    """N++(v): vertices at directed distance exactly two from v."""
    n = len(adj)
    first = out_neighborhood(adj, v)
    reach2: Set[int] = set()
    for x in first:
        for w in range(n):
            if adj[x][w]:
                reach2.add(w)
    return {w for w in reach2 if w != v and w not in first}


def out_degree(adj: Graph, v: int) -> int:
    return len(out_neighborhood(adj, v))


def is_seymour_vertex(adj: Graph, v: int) -> bool:
    """|N+(v)| <= |N++(v)|."""
    return out_degree(adj, v) <= len(second_out_neighborhood(adj, v))


def seymour_vertices(adj: Graph) -> List[int]:
    return [v for v in range(len(adj)) if is_seymour_vertex(adj, v)]


# --------------------------------------------------------------------------
# Structural constructors
# --------------------------------------------------------------------------
def relation_to_matrix(n: int, arcs: Set[Tuple[int, int]]) -> Graph:
    return [[(u, v) in arcs for v in range(n)] for u in range(n)]


def transitive_chain(n: int) -> Graph:
    """Strict total order 0 < 1 < ... < n-1 as arcs i -> j for i < j."""
    return [[i < j for j in range(n)] for i in range(n)]


def functional_cycle(n: int) -> Graph:
    """Directed n-cycle 0 -> 1 -> ... -> n-1 -> 0 (needs n >= 3 to be oriented)."""
    arcs = {(i, (i + 1) % n) for i in range(n)}
    return relation_to_matrix(n, arcs)


def digon() -> Graph:
    """The 2-vertex symmetric digraph a <-> b (NOT oriented)."""
    return relation_to_matrix(2, {(0, 1), (1, 0)})


# --------------------------------------------------------------------------
# Exhaustive verification of SSNC on small oriented graphs
# --------------------------------------------------------------------------
def all_oriented_graphs(n: int):
    """Yield every oriented graph on n labeled vertices.

    Each unordered pair {i,j} gets one of three states: no arc, i->j, or j->i.
    """
    pairs = [(i, j) for i in range(n) for j in range(i + 1, n)]
    for choice in product((0, 1, 2), repeat=len(pairs)):
        arcs: Set[Tuple[int, int]] = set()
        for (i, j), c in zip(pairs, choice):
            if c == 1:
                arcs.add((i, j))
            elif c == 2:
                arcs.add((j, i))
        yield relation_to_matrix(n, arcs)


def verify_ssnc_up_to(nmax: int) -> Dict[int, Tuple[int, bool]]:
    """For each n in 1..nmax, check every oriented graph has a Seymour vertex."""
    results: Dict[int, Tuple[int, bool]] = {}
    for n in range(1, nmax + 1):
        count = 0
        ok = True
        for adj in all_oriented_graphs(n):
            count += 1
            if not seymour_vertices(adj):
                ok = False
                break
        results[n] = (count, ok)
    return results


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Seymour's Second Neighborhood Conjecture -- base cases")
    print("=" * 70)

    print("\n[1] Transitive chain on 5 vertices (0<1<2<3<4)")
    g = transitive_chain(5)
    print(f"    oriented?           {is_asymmetric(g)}")
    for v in range(5):
        print(f"    v={v}: d+={out_degree(g, v)}  |N++|="
              f"{len(second_out_neighborhood(g, v))}  seymour={is_seymour_vertex(g, v)}")
    print(f"    sink (Seymour) vertex: {seymour_vertices(g)}  (vertex 4 is the sink)")

    print("\n[2] Functional directed 5-cycle (every out-degree = 1)")
    g = functional_cycle(5)
    print(f"    oriented?           {is_asymmetric(g)}")
    print(f"    Seymour vertices:   {seymour_vertices(g)}  (expected: ALL)")

    print("\n[3] Minimum-out-degree <= 1 example")
    # vertex 0 -> 1 -> 2 -> 3, a path; vertex 0 has out-degree 1 and is minimum.
    g = relation_to_matrix(4, {(0, 1), (1, 2), (2, 3)})
    print(f"    oriented?           {is_asymmetric(g)}")
    print(f"    out-degrees:        {[out_degree(g, v) for v in range(4)]}")
    print(f"    Seymour vertices:   {seymour_vertices(g)}")

    print("\n[4] The 2-vertex DIGON a<->b (symmetric, NOT oriented)")
    g = digon()
    print(f"    oriented?           {is_asymmetric(g)}  (digon => not oriented)")
    print(f"    Seymour vertices:   {seymour_vertices(g)}  (expected: NONE)")

    print("\n[5] Exhaustive verification of SSNC on all small oriented graphs")
    res = verify_ssnc_up_to(4)
    for n, (count, ok) in res.items():
        print(f"    n={n}: checked {count:6d} oriented graphs -> "
              f"{'ALL have a Seymour vertex' if ok else 'COUNTEREXAMPLE FOUND'}")

    print("\nDone.")


if __name__ == "__main__":
    main()
