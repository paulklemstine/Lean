#!/usr/bin/env python3
"""Numerical demonstrations of zero forcing and harmonic uniqueness.

The program uses only the Python standard library.  It constructs finite simple
graphs, computes forcing closures and exact zero forcing numbers for small
examples, checks cubic and claw-free structure, tests triangle-unit parity,
and performs exact rational linear algebra for weighted neighbor matrices.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Move = Tuple[Vertex, Vertex]
Matrix = List[List[Fraction]]


@dataclass(frozen=True)
class Graph:
    """A finite simple graph represented by immutable adjacency sets."""

    adjacency: Tuple[FrozenSet[Vertex], ...]

    @property
    def order(self) -> int:
        return len(self.adjacency)

    @property
    def size(self) -> int:
        return sum(len(nbrs) for nbrs in self.adjacency) // 2

    def neighbors(self, vertex: Vertex) -> FrozenSet[Vertex]:
        return self.adjacency[vertex]

    def degree(self, vertex: Vertex) -> int:
        return len(self.adjacency[vertex])

    def is_cubic(self) -> bool:
        return all(self.degree(v) == 3 for v in range(self.order))

    def is_claw_free(self) -> bool:
        for center in range(self.order):
            nbrs = sorted(self.neighbors(center))
            for leaves in combinations(nbrs, 3):
                if all(b not in self.neighbors(a) for a, b in combinations(leaves, 2)):
                    return False
        return True

    @staticmethod
    def from_edges(order: int, edges: Iterable[Tuple[Vertex, Vertex]]) -> "Graph":
        mutable: List[Set[Vertex]] = [set() for _ in range(order)]
        for u, v in edges:
            if u == v or not (0 <= u < order and 0 <= v < order):
                raise ValueError(f"invalid simple edge {(u, v)}")
            mutable[u].add(v)
            mutable[v].add(u)
        return Graph(tuple(frozenset(nbrs) for nbrs in mutable))


def forcing_closure(graph: Graph, initial: Iterable[Vertex]) -> Tuple[Set[Vertex], List[Move]]:
    """Apply legal forces until no force remains, returning closure and certificate."""
    colored = set(initial)
    if any(v < 0 or v >= graph.order for v in colored):
        raise ValueError("initial set contains a vertex outside the graph")
    moves: List[Move] = []
    while True:
        chosen: Optional[Move] = None
        for u in sorted(colored):
            uncolored = sorted(graph.neighbors(u) - colored)
            if len(uncolored) == 1:
                chosen = (u, uncolored[0])
                break
        if chosen is None:
            return colored, moves
        u, w = chosen
        colored.add(w)
        moves.append((u, w))


def validate_certificate(graph: Graph, initial: Iterable[Vertex], moves: Sequence[Move]) -> bool:
    """Check every move against the exact state in which it occurs."""
    colored = set(initial)
    for u, w in moves:
        if u not in colored or w in colored or w not in graph.neighbors(u):
            return False
        if graph.neighbors(u) - colored != {w}:
            return False
        colored.add(w)
    return True


def zero_forcing_number(graph: Graph) -> Tuple[int, Set[Vertex], List[Move]]:
    """Find an exact minimum zero forcing set by exhaustive subset search."""
    vertices = range(graph.order)
    for cardinality in range(graph.order + 1):
        for candidate_tuple in combinations(vertices, cardinality):
            candidate = set(candidate_tuple)
            closure, moves = forcing_closure(graph, candidate)
            if len(closure) == graph.order:
                return cardinality, candidate, moves
    raise RuntimeError("the full vertex set must always be zero forcing")


def weighted_neighbor_matrix(
    graph: Graph, weights: Dict[Tuple[Vertex, Vertex], Fraction]
) -> Matrix:
    """Build the directed weighted neighbor matrix with exact fractions."""
    matrix = [[Fraction(0) for _ in range(graph.order)] for _ in range(graph.order)]
    for u in range(graph.order):
        for v in graph.neighbors(u):
            weight = weights.get((u, v), Fraction(1))
            if weight == 0:
                raise ValueError("edge weights must be nonzero")
            matrix[u][v] = weight
    return matrix


def matrix_rank(matrix: Matrix) -> int:
    """Compute exact row rank by rational Gaussian elimination."""
    work = [row[:] for row in matrix]
    if not work:
        return 0
    rows, cols = len(work), len(work[0])
    rank = 0
    for col in range(cols):
        pivot = next((r for r in range(rank, rows) if work[r][col] != 0), None)
        if pivot is None:
            continue
        work[rank], work[pivot] = work[pivot], work[rank]
        pivot_value = work[rank][col]
        work[rank] = [entry / pivot_value for entry in work[rank]]
        for r in range(rows):
            if r != rank and work[r][col] != 0:
                factor = work[r][col]
                work[r] = [a - factor * b for a, b in zip(work[r], work[rank])]
        rank += 1
        if rank == rows:
            break
    return rank


def augmented_uniqueness_nullity(matrix: Matrix, sampled: Set[Vertex]) -> int:
    """Nullity after adding equations x(v)=0 at sampled vertices."""
    if not matrix:
        return 0
    augmented = [row[:] for row in matrix]
    order = len(matrix[0])
    for vertex in sorted(sampled):
        row = [Fraction(0) for _ in range(order)]
        row[vertex] = Fraction(1)
        augmented.append(row)
    return order - matrix_rank(augmented)


def path_graph(order: int) -> Graph:
    return Graph.from_edges(order, ((i, i + 1) for i in range(order - 1)))


def complete_graph(order: int) -> Graph:
    return Graph.from_edges(order, combinations(range(order), 2))


def triangular_prism() -> Graph:
    edges = [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5), (5, 3),
             (0, 3), (1, 4), (2, 5)]
    return Graph.from_edges(6, edges)


def print_forcing_demo(name: str, graph: Graph) -> None:
    number, seed, moves = zero_forcing_number(graph)
    closure, repeated_moves = forcing_closure(graph, seed)
    assert validate_certificate(graph, seed, repeated_moves)
    assert len(repeated_moves) == graph.order - len(seed)
    print(f"{name}: |V|={graph.order}, |E|={graph.size}, Z(G)={number}")
    print(f"  minimum seed={sorted(seed)}")
    print(f"  certificate={repeated_moves}; closure={sorted(closure)}")
    print(f"  cubic={graph.is_cubic()}, claw-free={graph.is_claw_free()}")


def demonstrate_harmonic_uniqueness() -> None:
    graph = triangular_prism()
    number, seed, moves = zero_forcing_number(graph)
    # Unit weights make the prism's neighbor matrix singular (nullity two),
    # so the zero constraints visibly remove genuine harmonic freedom.
    weights: Dict[Tuple[Vertex, Vertex], Fraction] = {
        (u, v): Fraction(1)
        for u in range(graph.order)
        for v in graph.neighbors(u)
    }
    matrix = weighted_neighbor_matrix(graph, weights)
    unconstrained_nullity = graph.order - matrix_rank(matrix)
    constrained_nullity = augmented_uniqueness_nullity(matrix, seed)
    print("Weighted harmonic uniqueness on the triangular prism:")
    print(f"  zero forcing seed={sorted(seed)} with {len(moves)} forces")
    print(f"  harmonic nullity before sampling={unconstrained_nullity}")
    print(f"  nullity after imposing x=0 on the seed={constrained_nullity}")
    assert number == len(seed)
    assert constrained_nullity == 0


def demonstrate_domination_and_parity() -> None:
    graph = triangular_prism()
    dominating_set = {0, 4}
    covered = set(dominating_set)
    for vertex in dominating_set:
        covered.update(graph.neighbors(vertex))
    assert covered == set(range(graph.order))
    assert graph.order <= 4 * len(dominating_set)
    print("Degree-three domination example:")
    print(f"  D={sorted(dominating_set)} covers all {graph.order} vertices")
    print(f"  bound check: {graph.order} <= 4*{len(dominating_set)}")
    for triangles, diamonds in [(4, 3), (3, 3)]:
        order = 3 * triangles + 4 * diamonds
        compatible = (order % 2 == 0) and (triangles % 2 == 0)
        print(f"  T={triangles}, D={diamonds}: order={order}, parity-compatible={compatible}")


def main() -> None:
    print("ZERO FORCING, LOCAL PROPAGATION, AND HARMONIC UNIQUENESS\n")
    print_forcing_demo("Path P6", path_graph(6))
    print_forcing_demo("Triangle K3", complete_graph(3))
    print_forcing_demo("Complete cubic graph K4", complete_graph(4))
    print_forcing_demo("Triangular prism", triangular_prism())
    print()
    demonstrate_harmonic_uniqueness()
    print()
    demonstrate_domination_and_parity()


if __name__ == "__main__":
    main()
