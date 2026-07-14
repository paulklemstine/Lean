"""
Numerical demonstrations for the sharp lower bound on adjacent-vertex-
distinguishing (AVD) total colourings of central graphs.

Main result illustrated here:

    For any finite simple graph G with at least one pair of distinct
    non-adjacent vertices, every AVD total colouring of the central graph
    C(G) uses at least |V(G)| + 1 colours.

The regular corollary chi''_a(C(G)) >= d + 3 and the sharpened five-cycle
estimate chi''_a(C(C_5)) >= 6 are both special cases.

Everything is self-contained: a graph is a pair (vertices, edges) with edges
given as frozensets of two vertices. All helper routines are inlined.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
# A node of the total graph of C(G) is either an original vertex ("V", v),
# a subdivision vertex ("S", edge), or a central-graph edge ("E", pair).
Node = Tuple[str, object]


# --------------------------------------------------------------------------
# Basic graph utilities
# --------------------------------------------------------------------------
def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Tuple[List[Vertex], List[Edge]]:
    """Build a simple graph on vertices 0..n-1 from a list of endpoint pairs."""
    V: List[Vertex] = list(range(n))
    E: List[Edge] = [frozenset(e) for e in edges]
    return V, E


def cycle_graph(n: int) -> Tuple[List[Vertex], List[Edge]]:
    """The n-cycle C_n."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def path_graph(n: int) -> Tuple[List[Vertex], List[Edge]]:
    """The path P_n on n vertices."""
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


def g_adjacent(E: List[Edge], u: Vertex, w: Vertex) -> bool:
    """Adjacency test in the base graph G."""
    return frozenset((u, w)) in E


def g_degree(V: List[Vertex], E: List[Edge], v: Vertex) -> int:
    """Degree of v in G."""
    return sum(1 for e in E if v in e)


# --------------------------------------------------------------------------
# The central graph C(G)
# --------------------------------------------------------------------------
def central_graph(
    V: List[Vertex], E: List[Edge]
) -> Tuple[List[Node], List[FrozenSet[Node]]]:
    """
    Construct the central graph C(G).

    Vertices: original vertices ("V", v) and subdivision vertices ("S", e).
    Edges:
      * ("V", u) -- ("V", w)  iff  u != w and u, w non-adjacent in G;
      * ("V", u) -- ("S", e)  iff  u is an endpoint of e.
    (Two subdivision vertices are never adjacent.)
    """
    nodes: List[Node] = [("V", v) for v in V] + [("S", e) for e in E]
    edges: List[FrozenSet[Node]] = []
    for u, w in combinations(V, 2):
        if not g_adjacent(E, u, w):
            edges.append(frozenset({("V", u), ("V", w)}))
    for e in E:
        for u in e:
            edges.append(frozenset({("V", u), ("S", e)}))
    return nodes, edges


def central_degree(nodes: List[Node], edges: List[FrozenSet[Node]], x: Node) -> int:
    """Degree of node x in C(G)."""
    return sum(1 for e in edges if x in e)


# --------------------------------------------------------------------------
# The total graph T(C(G)) and AVD total colourings
# --------------------------------------------------------------------------
def total_graph_of_central(
    V: List[Vertex], E: List[Edge]
) -> Tuple[List[Node], Dict[Node, Set[Node]], List[FrozenSet[Node]]]:
    """
    Build the total graph T(C(G)).

    Total-graph nodes = C(G)-vertices union C(G)-edges (edges tagged ("E", .)).
    Adjacency in T(C(G)):
      * two C(G)-vertices adjacent in C(G);
      * a C(G)-vertex incident to a C(G)-edge;
      * two C(G)-edges sharing a common endpoint.

    Returns the total-graph nodes, an adjacency map, and the list of C(G)-edges.
    """
    cg_nodes, cg_edges = central_graph(V, E)
    edge_nodes: List[Node] = [("E", e) for e in cg_edges]
    total_nodes: List[Node] = list(cg_nodes) + edge_nodes

    adj: Dict[Node, Set[Node]] = {x: set() for x in total_nodes}

    # vertex-vertex adjacency (already the central-graph adjacency)
    for e in cg_edges:
        a, b = tuple(e)
        adj[a].add(b)
        adj[b].add(a)

    # vertex-edge incidence
    for e in cg_edges:
        en: Node = ("E", e)
        for endpoint in e:
            adj[endpoint].add(en)
            adj[en].add(endpoint)

    # edge-edge (share an endpoint)
    for e1, e2 in combinations(cg_edges, 2):
        if e1 & e2:
            n1: Node = ("E", e1)
            n2: Node = ("E", e2)
            adj[n1].add(n2)
            adj[n2].add(n1)

    return total_nodes, adj, cg_edges


def color_set(
    coloring: Dict[Node, int], vertex: Node, cg_edges: List[FrozenSet[Node]]
) -> FrozenSet[int]:
    """Colour set of a C(G)-vertex: its own colour and the colours of its
    incident C(G)-edges."""
    cols = {coloring[vertex]}
    for e in cg_edges:
        if vertex in e:
            cols.add(coloring[("E", e)])
    return frozenset(cols)


def find_avd_total_coloring(
    V: List[Vertex], E: List[Edge], k: int
) -> Optional[Dict[Node, int]]:
    """
    Backtracking search for an AVD total colouring of C(G) with k colours.
    Returns a colouring (as a dict) if one exists, else None.
    """
    total_nodes, adj, cg_edges = total_graph_of_central(V, E)
    cg_vertices = [x for x in total_nodes if x[0] in ("V", "S")]

    # Order nodes by descending degree for stronger pruning.
    order = sorted(total_nodes, key=lambda x: len(adj[x]), reverse=True)
    coloring: Dict[Node, int] = {}

    def avd_ok() -> bool:
        # Compare colour sets of adjacent C(G)-vertices.
        for a, b in combinations(cg_vertices, 2):
            if b in adj[a]:  # adjacent in C(G)
                if color_set(coloring, a, cg_edges) == color_set(coloring, b, cg_edges):
                    return False
        return True

    def backtrack(i: int) -> bool:
        if i == len(order):
            return avd_ok()
        node = order[i]
        used = {coloring[nb] for nb in adj[node] if nb in coloring}
        # symmetry breaking on the very first node
        upper = 1 if i == 0 else k
        for c in range(min(k, upper) if i == 0 else k):
            if c in used:
                continue
            coloring[node] = c
            if backtrack(i + 1):
                return True
            del coloring[node]
        return False

    return dict(coloring) if backtrack(0) else None


def avd_total_chromatic(V: List[Vertex], E: List[Edge], k_max: int = 12) -> int:
    """Smallest k <= k_max admitting an AVD total colouring of C(G)."""
    for k in range(1, k_max + 1):
        if find_avd_total_coloring(V, E, k) is not None:
            return k
    raise RuntimeError("no AVD total colouring found within k_max colours")


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_uniform_core_degree() -> None:
    """Verify Proposition 4.1: every original vertex of C(G) has degree |V|-1."""
    print("=" * 68)
    print("Uniform core degree: every original vertex of C(G) has degree |V|-1")
    print("=" * 68)
    for name, (V, E) in [
        ("C_5 (5-cycle)", cycle_graph(5)),
        ("P_4 (path)", path_graph(4)),
        ("C_6 (6-cycle)", cycle_graph(6)),
        ("K_4 minus an edge", make_graph(4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3)])),
    ]:
        nodes, edges = central_graph(V, E)
        degs = {v: central_degree(nodes, edges, ("V", v)) for v in V}
        ok = all(d == len(V) - 1 for d in degs.values())
        print(f"  {name:22s}  |V|={len(V)}  core degrees={list(degs.values())}  "
              f"all == |V|-1 ? {ok}")
    print()


def demo_lower_bound_certificate() -> None:
    """Certify the |V|+1 lower bound locally, without colouring."""
    print("=" * 68)
    print("Local certificate of the |V|+1 lower bound (Theorem 5.3)")
    print("=" * 68)
    for name, (V, E) in [
        ("C_5", cycle_graph(5)),
        ("P_4", path_graph(4)),
        ("C_6", cycle_graph(6)),
    ]:
        # find a non-adjacent distinct pair
        pair = None
        for u, w in combinations(V, 2):
            if not g_adjacent(E, u, w):
                pair = (u, w)
                break
        if pair is None:
            print(f"  {name}: complete graph, bound vacuous")
            continue
        u, w = pair
        nodes, edges = central_graph(V, E)
        du = central_degree(nodes, edges, ("V", u))
        dw = central_degree(nodes, edges, ("V", w))
        print(f"  {name}: non-adjacent pair ({u},{w}) becomes adjacent in C(G) "
              f"with equal degrees {du}={dw}=|V|-1  =>  chi''_a >= |V|+1 = {len(V)+1}")
    print()


def demo_exact_search() -> None:
    """Brute-force the AVD-total chromatic number on small graphs and compare
    with the theoretical lower bound |V|+1."""
    print("=" * 68)
    print("Exact AVD-total chromatic number by search vs. lower bound |V|+1")
    print("=" * 68)
    for name, (V, E) in [
        ("P_3 (path on 3)", path_graph(3)),
        ("P_4 (path on 4)", path_graph(4)),
    ]:
        lb = len(V) + 1
        val = avd_total_chromatic(V, E, k_max=lb + 2)
        print(f"  {name:18s}  lower bound |V|+1 = {lb};  "
              f"searched minimum = {val};  match ? {val == lb}")
    print()


def demo_five_cycle() -> None:
    """The five-cycle: sharpened bound >= 6 rather than the regular >= 5."""
    print("=" * 68)
    print("Five-cycle C_5: regular estimate d+3=5 vs. sharp order bound |V|+1=6")
    print("=" * 68)
    V, E = cycle_graph(5)
    print(f"  C_5 is 2-regular:      degrees = {[g_degree(V, E, v) for v in V]}")
    print(f"  |V| = {len(V)}")
    print(f"  regular bound d+3      = {2 + 3}")
    print(f"  sharp bound   |V|+1    = {len(V) + 1}")
    # Confirm C_5 has no AVD total colouring with 5 colours (may be slow):
    has5 = find_avd_total_coloring(V, E, 5) is not None
    print(f"  AVD total colouring with 5 colours exists ? {has5}  "
          f"(theory predicts False)")
    print()


if __name__ == "__main__":
    demo_uniform_core_degree()
    demo_lower_bound_certificate()
    demo_exact_search()
    demo_five_cycle()
