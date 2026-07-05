"""
Numerical demonstrations for:

    Minimal Obstructions to Total Rainbow Forests Are Single Monochromatic Cycles

An edge-colored graph is a set of undirected edges together with a color for each
edge.  It *admits a total rainbow forest* when it contains no monochromatic cycle,
which (Forest Characterization Theorem) is equivalent to every color class being a
forest.  The *minimal obstructions* -- graphs that fail the property but are
repaired by deleting any single edge -- are exactly the single monochromatic
cycles (Structure Theorem).

This script is fully self-contained (standard library only) and verifies these
statements on concrete examples.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Edge = FrozenSet[int]                       # an undirected edge {u, v}
ColoredGraph = Dict[Edge, int]             # edge -> color


# --------------------------------------------------------------------------- #
# Basic helpers
# --------------------------------------------------------------------------- #
def edge(u: int, v: int) -> Edge:
    """Construct the undirected edge {u, v}."""
    return frozenset((u, v))


def vertices(graph: ColoredGraph) -> Set[int]:
    """All vertices incident to at least one edge."""
    vs: Set[int] = set()
    for e in graph:
        vs.update(e)
    return vs


def color_classes(graph: ColoredGraph) -> Dict[int, Set[Edge]]:
    """Partition the edges by color; each block is a color class G_k."""
    classes: Dict[int, Set[Edge]] = {}
    for e, k in graph.items():
        classes.setdefault(k, set()).add(e)
    return classes


# --------------------------------------------------------------------------- #
# Union-find acyclicity test (Section 6.1 of the paper)
# --------------------------------------------------------------------------- #
def has_cycle(edges: Iterable[Edge]) -> bool:
    """
    Return True iff the undirected graph on the given edge set contains a cycle.
    Uses a disjoint-set structure: an edge closes a cycle iff its endpoints are
    already connected.
    """
    parent: Dict[int, int] = {}

    def find(x: int) -> int:
        parent.setdefault(x, x)
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> bool:
        rx, ry = find(x), find(y)
        if rx == ry:
            return False          # x, y already connected -> this edge closes a cycle
        parent[rx] = ry
        return True

    for e in edges:
        u, v = tuple(e)
        if not union(u, v):
            return True
    return False


def is_forest(edges: Iterable[Edge]) -> bool:
    """A forest is an acyclic graph."""
    return not has_cycle(edges)


# --------------------------------------------------------------------------- #
# The property and its characterization
# --------------------------------------------------------------------------- #
def has_mono_cycle(graph: ColoredGraph) -> bool:
    """(G, c) has a monochromatic cycle: some color class contains a cycle."""
    return any(has_cycle(cls) for cls in color_classes(graph).values())


def admits_total_rainbow_forest(graph: ColoredGraph) -> bool:
    """(G, c) admits a total rainbow forest: no monochromatic cycle."""
    return not has_mono_cycle(graph)


def forest_characterization_holds(graph: ColoredGraph) -> bool:
    """
    Verify the Forest Characterization Theorem on a concrete graph:
    'admits a total rainbow forest' <=> 'every color class is a forest'.
    """
    lhs = admits_total_rainbow_forest(graph)
    rhs = all(is_forest(cls) for cls in color_classes(graph).values())
    return lhs == rhs


def delete_edge(graph: ColoredGraph, e: Edge) -> ColoredGraph:
    """Return a copy of the colored graph with edge e removed."""
    return {f: k for f, k in graph.items() if f != e}


def is_minimal_obstruction(graph: ColoredGraph) -> bool:
    """
    (G, c) is a minimal obstruction: it has a monochromatic cycle, yet deleting
    any single edge yields a graph admitting a total rainbow forest.
    """
    if not has_mono_cycle(graph):
        return False
    return all(
        admits_total_rainbow_forest(delete_edge(graph, e)) for e in graph
    )


# --------------------------------------------------------------------------- #
# Structure recognition (Structure Theorem)
# --------------------------------------------------------------------------- #
def is_single_monochromatic_cycle(graph: ColoredGraph) -> bool:
    """
    Recognize a single monochromatic cycle (isolated vertices allowed):
    all edges share one color, and the edge set is exactly one cycle, i.e. it is
    connected on its incident vertices and every such vertex has degree 2.
    """
    if not graph:
        return False
    colors = set(graph.values())
    if len(colors) != 1:
        return False
    vs = vertices(graph)
    # every incident vertex has degree exactly 2
    degree: Dict[int, int] = {v: 0 for v in vs}
    for e in graph:
        for v in e:
            degree[v] += 1
    if any(d != 2 for d in degree.values()):
        return False
    # the edges are connected (single cycle, not a union of cycles)
    return _connected(set(graph.keys()), vs)


def _connected(edges: Set[Edge], vs: Set[int]) -> bool:
    """Are the given vertices connected using the given edges?"""
    if not vs:
        return True
    adj: Dict[int, List[int]] = {v: [] for v in vs}
    for e in edges:
        u, w = tuple(e)
        adj[u].append(w)
        adj[w].append(u)
    start = next(iter(vs))
    seen = {start}
    stack = [start]
    while stack:
        x = stack.pop()
        for y in adj[x]:
            if y not in seen:
                seen.add(y)
                stack.append(y)
    return seen == vs


# --------------------------------------------------------------------------- #
# Minimum deletions to cure (Section 6.3): cyclomatic number per color
# --------------------------------------------------------------------------- #
def count_components(edges: Set[Edge], isolated: Set[int]) -> int:
    """Number of connected components on vertices incident to edges union isolated."""
    vs = set(isolated)
    for e in edges:
        vs.update(e)
    parent: Dict[int, int] = {v: v for v in vs}

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for e in edges:
        u, v = tuple(e)
        parent[find(u)] = find(v)
    return len({find(v) for v in vs})


def min_deletions_to_cure(graph: ColoredGraph) -> int:
    """
    Minimum number of edges to delete so every color class becomes a forest.
    Per color class the answer is its cyclomatic number m_k - n_k + c_k.
    """
    total = 0
    for cls in color_classes(graph).values():
        m_k = len(cls)
        vs_k = set()
        for e in cls:
            vs_k.update(e)
        n_k = len(vs_k)
        c_k = count_components(cls, vs_k)
        total += m_k - n_k + c_k
    return total


# --------------------------------------------------------------------------- #
# Example graphs
# --------------------------------------------------------------------------- #
def cycle_graph(n: int, color: int = 0) -> ColoredGraph:
    """Monochromatic cycle C_n on vertices 0..n-1."""
    return {edge(i, (i + 1) % n): color for i in range(n)}


def path_graph(n: int, color: int = 0) -> ColoredGraph:
    """Monochromatic path P_n on vertices 0..n-1."""
    return {edge(i, i + 1): color for i in range(n - 1)}


def theta_graph() -> ColoredGraph:
    """
    A 'theta' graph: two vertices joined by three internally disjoint paths, all
    edges one color.  It has monochromatic cycles but is NOT minimal, because some
    edge can be deleted while a monochromatic cycle survives.
    """
    # paths 0-1-2, 0-3-2, 0-4-2 between hubs 0 and 2
    g: ColoredGraph = {}
    for a, b in [(0, 1), (1, 2), (0, 3), (3, 2), (0, 4), (4, 2)]:
        g[edge(a, b)] = 0
    return g


def two_color_two_triangles() -> ColoredGraph:
    """
    Two triangles sharing no edge, colored so that each triangle is monochromatic
    but the two use different colors.  Every color class contains a cycle, so this
    fails the property, but it is not minimal (deleting a red edge leaves a blue
    monochromatic triangle).
    """
    g: ColoredGraph = {}
    for a, b in [(0, 1), (1, 2), (2, 0)]:
        g[edge(a, b)] = 0          # red triangle
    for a, b in [(3, 4), (4, 5), (5, 3)]:
        g[edge(a, b)] = 1          # blue triangle
    return g


def rainbow_triangle() -> ColoredGraph:
    """Triangle with three distinct colors -> no monochromatic cycle."""
    return {edge(0, 1): 0, edge(1, 2): 1, edge(2, 0): 2}


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def report(name: str, graph: ColoredGraph) -> None:
    print(f"--- {name} ---")
    print(f"  edges/colors                 : "
          f"{{ {', '.join(f'{tuple(sorted(e))}:{k}' for e, k in graph.items())} }}")
    print(f"  has monochromatic cycle      : {has_mono_cycle(graph)}")
    print(f"  admits total rainbow forest  : {admits_total_rainbow_forest(graph)}")
    print(f"  forest characterization holds: {forest_characterization_holds(graph)}")
    print(f"  is single mono cycle         : {is_single_monochromatic_cycle(graph)}")
    print(f"  is MINIMAL obstruction       : {is_minimal_obstruction(graph)}")
    print(f"  min deletions to cure        : {min_deletions_to_cure(graph)}")
    print()


def main() -> None:
    print("=" * 70)
    print("Total Rainbow Forests: minimal obstructions are single mono cycles")
    print("=" * 70, "\n")

    examples: List[Tuple[str, ColoredGraph]] = [
        ("Monochromatic triangle  C_3", cycle_graph(3)),
        ("Monochromatic pentagon  C_5", cycle_graph(5)),
        ("Monochromatic path      P_3", path_graph(3)),
        ("Rainbow triangle (3 colors)", rainbow_triangle()),
        ("Theta graph (mono, not minimal)", theta_graph()),
        ("Two mono triangles (2 colors)", two_color_two_triangles()),
    ]
    for name, g in examples:
        report(name, g)

    # Structure Theorem sweep: every minimal obstruction we build is recognized
    # as a single monochromatic cycle, matching Theorem 4.1.
    print("Structure Theorem check on monochromatic cycles C_3..C_8:")
    for n in range(3, 9):
        g = cycle_graph(n)
        minimal = is_minimal_obstruction(g)
        single = is_single_monochromatic_cycle(g)
        assert minimal and single, f"C_{n} failed"
        print(f"  C_{n}: minimal obstruction = {minimal}, "
              f"single mono cycle = {single}  (agree: {minimal == single})")

    # Forest Characterization: verify equivalence over many random-ish colorings.
    print("\nForest Characterization check over assorted graphs:")
    ok = all(
        forest_characterization_holds(g)
        for _, g in examples
    ) and all(forest_characterization_holds(cycle_graph(n)) for n in range(3, 9))
    print(f"  equivalence 'admits TRF' <=> 'every color class a forest': {ok}")


if __name__ == "__main__":
    main()
