#!/usr/bin/env python3
"""Numerical demonstrations of chromatic counting identities.

The script uses only the Python standard library.  It compares exhaustive
coloring enumeration with deletion--contraction, displays the endpoint
partition behind the recurrence, and checks disjoint-union multiplicativity.
"""

from __future__ import annotations

from functools import lru_cache
from itertools import product
from typing import Iterable, Iterator, Sequence

Edge = tuple[int, int]
Graph = tuple[int, tuple[Edge, ...]]


def make_graph(vertex_count: int, edges: Iterable[Edge]) -> Graph:
    """Create a canonical simple graph on vertices 0,...,vertex_count-1."""
    if vertex_count < 0:
        raise ValueError("vertex_count must be nonnegative")
    clean: set[Edge] = set()
    for u, v in edges:
        if not (0 <= u < vertex_count and 0 <= v < vertex_count):
            raise ValueError(f"edge {(u, v)} has an out-of-range endpoint")
        if u == v:
            raise ValueError("simple graphs cannot contain loops")
        clean.add((min(u, v), max(u, v)))
    return vertex_count, tuple(sorted(clean))


def proper_colorings(graph: Graph, q: int) -> Iterator[tuple[int, ...]]:
    """Generate all proper colorings by colors 0,...,q-1."""
    n, edges = graph
    if q < 0:
        raise ValueError("q must be nonnegative")
    for coloring in product(range(q), repeat=n):
        if all(coloring[u] != coloring[v] for u, v in edges):
            yield coloring


def brute_force_count(graph: Graph, q: int) -> int:
    """Count proper colorings directly in O(|E| q^|V|) worst-case time."""
    return sum(1 for _ in proper_colorings(graph, q))


def delete_edge(graph: Graph, edge: Edge) -> Graph:
    """Delete one edge from a canonical graph."""
    n, edges = graph
    u, v = sorted(edge)
    if (u, v) not in edges:
        raise ValueError("the selected pair is not an edge")
    return make_graph(n, (e for e in edges if e != (u, v)))


def contract_edge(graph: Graph, edge: Edge) -> Graph:
    """Contract an edge, discard loops, and relabel remaining vertices."""
    n, edges = graph
    a, b = sorted(edge)
    if (a, b) not in edges:
        raise ValueError("the selected pair is not an edge")
    # Merge b into a, then compress labels to 0,...,n-2.
    remaining = [v for v in range(n) if v != b]
    relabel = {old: new for new, old in enumerate(remaining)}
    contracted: set[Edge] = set()
    for u, v in edges:
        u = a if u == b else u
        v = a if v == b else v
        if u != v:
            x, y = sorted((relabel[u], relabel[v]))
            contracted.add((x, y))
    return make_graph(n - 1, contracted)


def connected_components(graph: Graph) -> list[Graph]:
    """Return canonically relabeled connected components."""
    n, edges = graph
    adjacency = [set() for _ in range(n)]
    for u, v in edges:
        adjacency[u].add(v)
        adjacency[v].add(u)
    unseen = set(range(n))
    components: list[Graph] = []
    while unseen:
        root = min(unseen)
        stack = [root]
        vertices: list[int] = []
        unseen.remove(root)
        while stack:
            u = stack.pop()
            vertices.append(u)
            for v in sorted(adjacency[u]):
                if v in unseen:
                    unseen.remove(v)
                    stack.append(v)
        vertices.sort()
        relabel = {old: new for new, old in enumerate(vertices)}
        local_edges = [
            (relabel[u], relabel[v])
            for u, v in edges
            if u in relabel and v in relabel
        ]
        components.append(make_graph(len(vertices), local_edges))
    return components


@lru_cache(maxsize=None)
def deletion_contraction_count(graph: Graph, q: int) -> int:
    """Evaluate P(G,q) recursively, factoring disconnected components."""
    n, edges = graph
    if q < 0:
        raise ValueError("q must be nonnegative")
    if not edges:
        return q**n
    components = connected_components(graph)
    if len(components) > 1:
        result = 1
        for component in components:
            result *= deletion_contraction_count(component, q)
        return result
    edge = edges[0]
    return (
        deletion_contraction_count(delete_edge(graph, edge), q)
        - deletion_contraction_count(contract_edge(graph, edge), q)
    )


def disjoint_union(left: Graph, right: Graph) -> Graph:
    """Form a disjoint union, shifting the vertices of the right graph."""
    n, left_edges = left
    m, right_edges = right
    shifted = [(u + n, v + n) for u, v in right_edges]
    return make_graph(n + m, [*left_edges, *shifted])


def endpoint_partition(graph: Graph, edge: Edge, q: int) -> tuple[int, int]:
    """Count deletion colorings with unequal and equal endpoint colors."""
    a, b = sorted(edge)
    deleted = delete_edge(graph, (a, b))
    unequal = 0
    equal = 0
    for coloring in proper_colorings(deleted, q):
        if coloring[a] == coloring[b]:
            equal += 1
        else:
            unequal += 1
    return unequal, equal


def falling_factorial(q: int, n: int) -> int:
    """Compute q(q-1)...(q-n+1), interpreted as an injection count."""
    if q < 0 or n < 0:
        raise ValueError("arguments must be nonnegative")
    if n > q:
        return 0
    result = 1
    for k in range(n):
        result *= q - k
    return result


def run_demo() -> None:
    """Run three reproducible demonstrations and assert every identity."""
    triangle = make_graph(3, [(0, 1), (1, 2), (0, 2)])
    path3 = delete_edge(triangle, (0, 2))
    edge_graph = make_graph(2, [(0, 1)])
    isolated = make_graph(1, [])
    edge_plus_isolated = disjoint_union(edge_graph, isolated)
    cycle4 = make_graph(4, [(0, 1), (1, 2), (2, 3), (0, 3)])

    print("Chromatic Counting Demonstrations")
    print("=" * 36)

    print("\n1. Empty and complete graph formulas")
    for q in range(0, 6):
        empty4 = make_graph(4, [])
        complete4 = make_graph(4, [(u, v) for u in range(4) for v in range(u + 1, 4)])
        empty_count = brute_force_count(empty4, q)
        complete_count = brute_force_count(complete4, q)
        assert empty_count == q**4
        assert complete_count == falling_factorial(q, 4)
        print(f"q={q}: P(E4,q)={empty_count:4d}, P(K4,q)={complete_count:3d}")

    print("\n2. Deletion--contraction partition for a triangle edge")
    q = 3
    unequal, equal = endpoint_partition(triangle, (0, 2), q)
    original = brute_force_count(triangle, q)
    contracted = brute_force_count(contract_edge(triangle, (0, 2)), q)
    deleted = brute_force_count(path3, q)
    assert (unequal, equal) == (original, contracted)
    assert deleted == original + contracted
    assert deleted == deletion_contraction_count(path3, q)
    print(f"P(K3 - e, 3) = {deleted}")
    print(f"  unequal endpoint class = P(K3, 3)   = {unequal}")
    print(f"  equal endpoint class   = P(K3/e, 3) = {equal}")
    print(f"  identity: {deleted} = {original} + {contracted}")

    print("\n3. Disjoint-union multiplicativity and a cycle check")
    union_count = deletion_contraction_count(edge_plus_isolated, q)
    product_count = (
        deletion_contraction_count(edge_graph, q)
        * deletion_contraction_count(isolated, q)
    )
    assert union_count == product_count == 18
    cycle_count = deletion_contraction_count(cycle4, q)
    assert cycle_count == brute_force_count(cycle4, q) == (q - 1) ** 4 + (q - 1)
    print(f"P(K2 disjoint-union E1, 3) = {union_count} = 6 * 3")
    print(f"P(C4, 3) = {cycle_count}; exhaustive and recursive counts agree")


if __name__ == "__main__":
    run_demo()
