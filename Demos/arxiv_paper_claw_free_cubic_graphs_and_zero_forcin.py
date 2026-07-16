#!/usr/bin/env python3
"""Numerical demonstrations of zero forcing on finite simple graphs.

The script uses only the Python standard library.  It validates forcing
certificates, computes zero forcing numbers by exhaustive search, checks the
co-singleton construction, and finds triangle witnesses in claw-free cubic
examples.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Force = Tuple[Vertex, Vertex]
Adjacency = Dict[Vertex, Set[Vertex]]


@dataclass(frozen=True)
class ForcingResult:
    """Outcome of deterministic zero-forcing propagation."""

    initial: FrozenSet[Vertex]
    final: FrozenSet[Vertex]
    forces: Tuple[Force, ...]


def graph_from_edges(n: int, edges: Iterable[Tuple[int, int]]) -> Adjacency:
    """Create an undirected simple graph on vertices 0,...,n-1."""
    graph: Adjacency = {v: set() for v in range(n)}
    for u, v in edges:
        if not (0 <= u < n and 0 <= v < n):
            raise ValueError("edge endpoint outside the vertex range")
        if u == v:
            raise ValueError("loops are not allowed")
        graph[u].add(v)
        graph[v].add(u)
    return graph


def complete_graph(n: int) -> Adjacency:
    return graph_from_edges(n, combinations(range(n), 2))


def path_graph(n: int) -> Adjacency:
    return graph_from_edges(n, ((v, v + 1) for v in range(n - 1)))


def cycle_graph(n: int) -> Adjacency:
    if n < 3:
        raise ValueError("a simple cycle needs at least three vertices")
    return graph_from_edges(n, ((v, (v + 1) % n) for v in range(n)))


def triangular_prism() -> Adjacency:
    """Return two triangles joined by a perfect matching."""
    return graph_from_edges(
        6,
        [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5), (5, 3),
         (0, 3), (1, 4), (2, 5)],
    )


def propagate(graph: Adjacency, initial: Iterable[Vertex]) -> ForcingResult:
    """Apply the first available legal force until success or stagnation."""
    colored = set(initial)
    if not colored <= graph.keys():
        raise ValueError("the initial set contains a nonvertex")
    forces: List[Force] = []
    while len(colored) < len(graph):
        move: Optional[Force] = None
        for u in sorted(colored):
            uncolored_neighbors = graph[u] - colored
            if len(uncolored_neighbors) == 1:
                move = (u, next(iter(uncolored_neighbors)))
                break
        if move is None:
            break
        u, w = move
        colored.add(w)
        forces.append((u, w))
    return ForcingResult(frozenset(initial), frozenset(colored), tuple(forces))


def is_zero_forcing(graph: Adjacency, initial: Iterable[Vertex]) -> bool:
    return len(propagate(graph, initial).final) == len(graph)


def validate_certificate(
    graph: Adjacency, initial: Iterable[Vertex], forces: Sequence[Force]
) -> bool:
    """Check every proposed force and require the final set to be all vertices."""
    colored = set(initial)
    for u, w in forces:
        if u not in colored or w in colored or w not in graph[u]:
            return False
        if graph[u] - colored != {w}:
            return False
        colored.add(w)
    return colored == set(graph)


def zero_forcing_number(graph: Adjacency) -> Tuple[int, FrozenSet[Vertex], Tuple[Force, ...]]:
    """Compute Z(G) exactly by examining subsets in increasing cardinality."""
    vertices = sorted(graph)
    for size in range(len(vertices) + 1):
        for candidate in combinations(vertices, size):
            result = propagate(graph, candidate)
            if len(result.final) == len(vertices):
                return size, frozenset(candidate), result.forces
    raise RuntimeError("the full vertex set must always be zero forcing")


def is_cubic(graph: Adjacency) -> bool:
    return all(len(neighbors) == 3 for neighbors in graph.values())


def is_claw_free(graph: Adjacency) -> bool:
    """Test the local definition: no three neighbors are pairwise nonadjacent."""
    for neighbors in graph.values():
        for a, b, c in combinations(neighbors, 3):
            if b not in graph[a] and c not in graph[a] and c not in graph[b]:
                return False
    return True


def triangle_witnesses(graph: Adjacency) -> Dict[Vertex, Tuple[Vertex, Vertex]]:
    """Find adjacent neighbors a,b witnessing a triangle v-a-b-v at each v."""
    witnesses: Dict[Vertex, Tuple[Vertex, Vertex]] = {}
    for v, neighbors in graph.items():
        for a, b in combinations(sorted(neighbors), 2):
            if b in graph[a]:
                witnesses[v] = (a, b)
                break
    return witnesses


def demonstrate_graph(name: str, graph: Adjacency) -> None:
    z, witness, forces = zero_forcing_number(graph)
    print(f"{name}: |V|={len(graph)}, |E|={sum(map(len, graph.values())) // 2}")
    print(f"  Z(G)={z}; minimum witness={sorted(witness)}")
    print(f"  forcing sequence={list(forces)}")
    assert validate_certificate(graph, witness, forces)


def main() -> None:
    print("Exact zero forcing numbers")
    print("=" * 50)
    examples = [
        ("Path P6", path_graph(6)),
        ("Cycle C6", cycle_graph(6)),
        ("Complete graph K5", complete_graph(5)),
        ("Triangular prism", triangular_prism()),
    ]
    for name, graph in examples:
        demonstrate_graph(name, graph)

    print("\nComplete-graph formula Z(K_n)=n-1")
    print("=" * 50)
    for n in range(2, 8):
        z, _, _ = zero_forcing_number(complete_graph(n))
        print(f"  n={n}: computed Z={z}, predicted={n - 1}")
        assert z == n - 1

    print("\nCo-singleton certificates")
    print("=" * 50)
    for name, graph in examples:
        if graph and all(graph[v] for v in graph):
            omitted = min(graph)
            initial = set(graph) - {omitted}
            result = propagate(graph, initial)
            print(f"  {name}: omit {omitted}, forces={list(result.forces)}")
            assert result.final == frozenset(graph)

    print("\nLocal triangles in a claw-free cubic graph")
    print("=" * 50)
    prism = triangular_prism()
    assert is_cubic(prism) and is_claw_free(prism)
    witnesses = triangle_witnesses(prism)
    assert len(witnesses) == len(prism)
    for v, (a, b) in witnesses.items():
        print(f"  vertex {v}: triangle ({v}, {a}, {b})")

    print("\nAll numerical demonstrations passed.")


if __name__ == "__main__":
    main()
