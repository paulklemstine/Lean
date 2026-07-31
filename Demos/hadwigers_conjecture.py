#!/usr/bin/env python3
"""Numerical demonstrations for complete graph minors and graph coloring.

The program uses only Python's standard library.  Graphs are represented by
sets of normalized undirected edges (u, v) with u < v.  It demonstrates exact
coloring, degeneracy coloring, and verification/search of complete-minor
branch-set certificates on small examples.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations, product
from typing import Iterable, Optional, Sequence

Vertex = int
Edge = tuple[Vertex, Vertex]
BranchSets = tuple[frozenset[Vertex], ...]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph on vertices 0, ..., n-1."""

    n: int
    edges: frozenset[Edge]

    @staticmethod
    def make(n: int, edges: Iterable[tuple[int, int]]) -> "Graph":
        if n < 0:
            raise ValueError("The number of vertices must be nonnegative")
        normalized: set[Edge] = set()
        for a, b in edges:
            if not (0 <= a < n and 0 <= b < n):
                raise ValueError(f"Edge {(a, b)} has a vertex outside 0..{n - 1}")
            if a == b:
                raise ValueError("Loops are not allowed")
            normalized.add((min(a, b), max(a, b)))
        return Graph(n, frozenset(normalized))

    def adjacent(self, a: int, b: int) -> bool:
        return a != b and (min(a, b), max(a, b)) in self.edges

    def neighbors(self, v: int, within: Optional[set[int]] = None) -> set[int]:
        universe = set(range(self.n)) if within is None else within
        return {w for w in universe if self.adjacent(v, w)}

    def average_degree(self) -> float:
        return 0.0 if self.n == 0 else 2.0 * len(self.edges) / self.n


def complete_graph(n: int) -> Graph:
    """Return K_n."""
    return Graph.make(n, combinations(range(n), 2))


def cycle_graph(n: int) -> Graph:
    """Return the n-cycle (with the conventional simple graph for n >= 3)."""
    if n < 3:
        raise ValueError("A simple cycle requires at least three vertices")
    return Graph.make(n, ((v, (v + 1) % n) for v in range(n)))


def complete_bipartite_graph(left: int, right: int) -> Graph:
    """Return K_{left,right}."""
    return Graph.make(
        left + right,
        ((u, left + v) for u in range(left) for v in range(right)),
    )


def coloring_with_q_colors(graph: Graph, q: int) -> Optional[list[int]]:
    """Find a proper q-coloring by backtracking, or return None."""
    if q < 0:
        return None
    if graph.n == 0:
        return []
    if q == 0:
        return None

    colors = [-1] * graph.n
    degrees = [len(graph.neighbors(v)) for v in range(graph.n)]

    def search(colored_count: int) -> bool:
        if colored_count == graph.n:
            return True
        uncolored = [v for v in range(graph.n) if colors[v] < 0]
        # DSATUR-style choice: maximize colored-neighbor saturation, then degree.
        v = max(
            uncolored,
            key=lambda x: (
                len({colors[w] for w in graph.neighbors(x) if colors[w] >= 0}),
                degrees[x],
            ),
        )
        forbidden = {colors[w] for w in graph.neighbors(v) if colors[w] >= 0}
        for color in range(q):
            if color not in forbidden:
                colors[v] = color
                if search(colored_count + 1):
                    return True
                colors[v] = -1
        return False

    return colors.copy() if search(0) else None


def chromatic_number(graph: Graph) -> tuple[int, list[int]]:
    """Compute the exact chromatic number and one optimal coloring."""
    for q in range(graph.n + 1):
        coloring = coloring_with_q_colors(graph, q)
        if coloring is not None:
            return q, coloring
    raise AssertionError("Every n-vertex graph is n-colorable")


def induced_connected(graph: Graph, vertices: frozenset[int]) -> bool:
    """Test whether a nonempty vertex set induces a connected subgraph."""
    if not vertices:
        return False
    seen = {next(iter(vertices))}
    frontier = list(seen)
    while frontier:
        v = frontier.pop()
        for w in graph.neighbors(v, set(vertices)) - seen:
            seen.add(w)
            frontier.append(w)
    return seen == set(vertices)


def verify_complete_minor(graph: Graph, branches: Sequence[Iterable[int]]) -> bool:
    """Verify that branches form a K_t minor model in graph."""
    sets = [frozenset(branch) for branch in branches]
    if any(not branch for branch in sets):
        return False
    if any(v < 0 or v >= graph.n for branch in sets for v in branch):
        return False
    if len(set().union(*sets)) != sum(len(branch) for branch in sets):
        return False
    if any(not induced_connected(graph, branch) for branch in sets):
        return False
    for i, j in combinations(range(len(sets)), 2):
        if not any(graph.adjacent(u, v) for u in sets[i] for v in sets[j]):
            return False
    return True


def find_complete_minor(graph: Graph, t: int) -> Optional[BranchSets]:
    """Exhaustively find a K_t branch-set model in a small graph.

    Each vertex receives label 0 (unused) or a branch label 1..t.  The search
    has O((t+1)^n) assignments before certificate checks, so it is intended
    only for small numerical demonstrations.
    """
    if t < 0:
        return None
    if t == 0:
        return tuple()
    if t > graph.n:
        return None
    for labels in product(range(t + 1), repeat=graph.n):
        branches = tuple(
            frozenset(v for v, label in enumerate(labels) if label == i)
            for i in range(1, t + 1)
        )
        if any(not branch for branch in branches):
            continue
        # Symmetry breaking: order branch sets by their least vertices.
        if list(map(min, branches)) != sorted(map(min, branches)):
            continue
        if verify_complete_minor(graph, branches):
            return branches
    return None


def degeneracy_order(graph: Graph) -> tuple[int, list[int]]:
    """Compute the degeneracy and an elimination order in O(n(n+m)) here."""
    remaining = set(range(graph.n))
    order: list[int] = []
    degeneracy = 0
    while remaining:
        v = min(remaining, key=lambda x: len(graph.neighbors(x, remaining)))
        current_degree = len(graph.neighbors(v, remaining))
        degeneracy = max(degeneracy, current_degree)
        order.append(v)
        remaining.remove(v)
    return degeneracy, order


def greedy_from_degeneracy(graph: Graph) -> tuple[list[int], int]:
    """Color in reverse elimination order and return coloring and color count."""
    _, order = degeneracy_order(graph)
    colors = [-1] * graph.n
    for v in reversed(order):
        forbidden = {colors[w] for w in graph.neighbors(v) if colors[w] >= 0}
        color = 0
        while color in forbidden:
            color += 1
        colors[v] = color
    count = 0 if graph.n == 0 else max(colors) + 1
    return colors, count


def describe(name: str, graph: Graph) -> None:
    """Print coloring, density, degeneracy, and a K_chi minor certificate."""
    chi, coloring = chromatic_number(graph)
    degeneracy, order = degeneracy_order(graph)
    greedy, used = greedy_from_degeneracy(graph)
    model = find_complete_minor(graph, chi)
    print(f"\n{name}")
    print("-" * len(name))
    print(f"vertices={graph.n}, edges={len(graph.edges)}, average degree={graph.average_degree():.3f}")
    print(f"chromatic number={chi}, optimal coloring={coloring}")
    print(f"degeneracy={degeneracy}, elimination order={order}")
    print(f"reverse-order greedy coloring={greedy} (uses {used} <= {degeneracy + 1} colors)")
    print(f"K_{chi} branch sets={model}")
    assert used <= degeneracy + 1
    assert model is not None and verify_complete_minor(graph, model)


def main() -> None:
    examples = [
        ("Empty graph on four vertices", Graph.make(4, [])),
        ("One edge plus two isolated vertices", Graph.make(4, [(0, 1)])),
        ("Five-cycle C5", cycle_graph(5)),
        ("Complete bipartite graph K3,3", complete_bipartite_graph(3, 3)),
        ("Complete graph K4", complete_graph(4)),
    ]
    for name, graph in examples:
        describe(name, graph)

    # An explicit non-singleton model: C5 contracts to a triangle.
    c5 = cycle_graph(5)
    triangle_model = ({0, 1}, {2, 3}, {4})
    print("\nExplicit C5 -> K3 model:", triangle_model)
    print("certificate valid:", verify_complete_minor(c5, triangle_model))
    assert verify_complete_minor(c5, triangle_model)


if __name__ == "__main__":
    main()
