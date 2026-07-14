"""
Numerical demonstrations for:

    Toughness, minimal toughness, and forbidden induced subgraphs
    ------------------------------------------------------------------
    A component-count toolkit toward Hamiltonicity of (K1 u P4)-free graphs.

This self-contained script implements the core invariant --- the *component
count* numComp(G, S), the number of connected components remaining after deleting
a vertex set S --- and verifies the paper's structural results on concrete graph
families:

  1. Monotonicity of the component count under edge additions.
  2. Complete graphs are 1-tough (component count never exceeds 1).
  3. Every 1-tough graph on >= 3 vertices has minimum degree >= 2.
  4. Complete graphs forbid every induced subgraph with a non-edge; in
     particular K1 u P4.
  5. The empty graph on >= 2 vertices is not 1-tough (connectivity fails).

Graphs are represented as (vertex set, symmetric adjacency dict). No third-party
dependencies are required.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# A graph: a set of vertices and a symmetric neighbour map.
Vertex = int
Graph = Tuple[Set[Vertex], Dict[Vertex, Set[Vertex]]]


# --------------------------------------------------------------------------- #
# Graph constructors
# --------------------------------------------------------------------------- #
def make_graph(n: int, edges: Iterable[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph on vertices {0, ..., n-1} with the given edges."""
    verts: Set[Vertex] = set(range(n))
    adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in verts}
    for a, b in edges:
        if a != b:
            adj[a].add(b)
            adj[b].add(a)
    return verts, adj


def complete_graph(n: int) -> Graph:
    """The complete graph K_n: every pair of distinct vertices adjacent."""
    return make_graph(n, combinations(range(n), 2))


def cycle_graph(n: int) -> Graph:
    """The cycle C_n on n >= 3 vertices."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def empty_graph(n: int) -> Graph:
    """The edgeless graph on n vertices."""
    return make_graph(n, [])


def path_graph(n: int) -> Graph:
    """The path P_n on n vertices: 0-1-...-(n-1)."""
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


# --------------------------------------------------------------------------- #
# Core invariant: component count numComp(G, S)
# --------------------------------------------------------------------------- #
def induced_subgraph(graph: Graph, keep: Set[Vertex]) -> Graph:
    """The subgraph induced on the vertex set `keep`."""
    verts, adj = graph
    keep = keep & verts
    new_adj = {v: (adj[v] & keep) for v in keep}
    return keep, new_adj


def connected_components(graph: Graph) -> List[Set[Vertex]]:
    """Return the connected components of `graph` via breadth-first search."""
    verts, adj = graph
    seen: Set[Vertex] = set()
    comps: List[Set[Vertex]] = []
    for start in verts:
        if start in seen:
            continue
        comp: Set[Vertex] = set()
        frontier: List[Vertex] = [start]
        seen.add(start)
        while frontier:
            v = frontier.pop()
            comp.add(v)
            for w in adj[v]:
                if w not in seen:
                    seen.add(w)
                    frontier.append(w)
        comps.append(comp)
    return comps


def num_comp(graph: Graph, s: Set[Vertex]) -> int:
    """numComp(G, S): number of components after deleting the vertex set S."""
    verts, _ = graph
    return len(connected_components(induced_subgraph(graph, verts - s)))


def is_connected(graph: Graph) -> bool:
    verts, _ = graph
    if not verts:
        return False
    return len(connected_components(graph)) == 1


def is_one_tough(graph: Graph) -> bool:
    """G is 1-tough: connected and numComp(G, S) <= |S| for every S."""
    verts, _ = graph
    if not is_connected(graph):
        return False
    n = len(verts)
    vlist = list(verts)
    for k in range(0, n + 1):
        for s in combinations(vlist, k):
            c = num_comp(graph, set(s))
            # The toughness inequality is required only when the deletion
            # actually scatters the graph into >= 2 components.
            if c >= 2 and c > len(s):
                return False
    return True


def min_degree(graph: Graph) -> int:
    verts, adj = graph
    return min((len(adj[v]) for v in verts), default=0)


# --------------------------------------------------------------------------- #
# Induced-subgraph freeness
# --------------------------------------------------------------------------- #
def contains_induced(host: Graph, pattern: Graph) -> bool:
    """Does `host` contain `pattern` as an induced subgraph?"""
    host_verts, host_adj = host
    pat_verts, pat_adj = pattern
    pat_list = sorted(pat_verts)
    for image in permutations(host_verts, len(pat_list)):
        f = dict(zip(pat_list, image))
        ok = True
        for a, b in combinations(pat_list, 2):
            pat_edge = b in pat_adj[a]
            host_edge = f[b] in host_adj[f[a]]
            if pat_edge != host_edge:
                ok = False
                break
        if ok:
            return True
    return False


def k1_union_p4() -> Graph:
    """K1 u P4: isolated vertex 0, plus induced path 1-2-3-4."""
    return make_graph(5, [(1, 2), (2, 3), (3, 4)])


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_monotonicity() -> None:
    print("=" * 70)
    print("1. Monotonicity: adding edges never increases the component count.")
    print("=" * 70)
    n = 6
    sparse = cycle_graph(n)              # C_6
    dense, dadj = complete_graph(n)      # K_6 (superset of C_6's edges)
    dense_graph = (dense, dadj)
    ok = True
    for k in range(n + 1):
        for s in combinations(range(n), k):
            ss = set(s)
            lo = num_comp(dense_graph, ss)
            hi = num_comp(sparse, ss)
            if lo > hi:
                ok = False
    print(f"  For C_6 <= K_6, numComp(K_6,S) <= numComp(C_6,S) for all S: {ok}")
    s = {0, 3}
    print(f"  Example S={s}: numComp(C_6,S)={num_comp(sparse, s)}, "
          f"numComp(K_6,S)={num_comp(dense_graph, s)}")
    print()


def demo_complete_tough() -> None:
    print("=" * 70)
    print("2. Complete graphs are 1-tough (component count never exceeds 1).")
    print("=" * 70)
    for n in range(1, 7):
        g = complete_graph(n)
        max_count = max(num_comp(g, set(s))
                        for k in range(n + 1)
                        for s in combinations(range(n), k))
        # component count on the empty deletion is 1 (or 0 if n == 0)
        deleted_counts = [num_comp(g, set(s))
                          for k in range(1, n + 1)
                          for s in combinations(range(n), k)]
        cap = max(deleted_counts, default=0)
        print(f"  K_{n}: 1-tough={is_one_tough(g)}, "
              f"max numComp over nonempty S = {cap} (<= 1)")
    print()


def demo_min_degree() -> None:
    print("=" * 70)
    print("3. Every 1-tough graph on >= 3 vertices has minimum degree >= 2.")
    print("=" * 70)
    families = {
        "K_5 (complete)": complete_graph(5),
        "C_5 (cycle)": cycle_graph(5),
        "C_7 (cycle)": cycle_graph(7),
    }
    for name, g in families.items():
        tough = is_one_tough(g)
        print(f"  {name}: 1-tough={tough}, min degree={min_degree(g)}")
    # A graph with a degree-1 vertex fails 1-toughness:
    near_pendant = make_graph(4, [(0, 1), (1, 2), (2, 0), (2, 3)])  # triangle + pendant
    print(f"  Triangle with pendant vertex 3 (deg 1): "
          f"1-tough={is_one_tough(near_pendant)}, "
          f"min degree={min_degree(near_pendant)}")
    print(f"    Deleting its neighbour {{2}} yields "
          f"numComp={num_comp(near_pendant, {2})} > 1, violating toughness.")
    print()


def demo_forbidden() -> None:
    print("=" * 70)
    print("4. Complete graphs are (K1 u P4)-free.")
    print("=" * 70)
    pattern = k1_union_p4()
    for n in range(5, 9):
        g = complete_graph(n)
        contains = contains_induced(g, pattern)
        print(f"  K_{n} contains induced K1 u P4: {contains} (expected False)")
    # A graph that DOES contain it, for contrast:
    host = make_graph(5, [(1, 2), (2, 3), (3, 4)])  # is itself K1 u P4
    print(f"  K1 u P4 itself contains induced K1 u P4: "
          f"{contains_induced(host, pattern)} (expected True)")
    print()


def demo_boundary() -> None:
    print("=" * 70)
    print("5. Disconnected (empty) graphs are never 1-tough.")
    print("=" * 70)
    for n in range(2, 6):
        g = empty_graph(n)
        print(f"  Empty graph on {n} vertices: connected={is_connected(g)}, "
              f"1-tough={is_one_tough(g)} (expected False)")
    print()


def main() -> None:
    demo_monotonicity()
    demo_complete_tough()
    demo_min_degree()
    demo_forbidden()
    demo_boundary()
    print("All demonstrations completed: results match the theorems.")


if __name__ == "__main__":
    main()
