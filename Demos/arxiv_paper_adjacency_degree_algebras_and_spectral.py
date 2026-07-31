#!/usr/bin/env python3
"""Numerical demonstrations of adjacency-degree moments.

For each finite undirected graph, this script independently computes
    1^T A D A 1,
    sum_v degree(v)^3, and
    hom(K_{1,3}, G),
and checks that the three integers agree.  No third-party packages are needed.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence

Matrix = list[list[int]]
Edge = tuple[int, int]
StarMap = tuple[int, int, int, int]


@dataclass(frozen=True)
class Graph:
    """A finite simple undirected graph on vertices 0, ..., n-1."""

    name: str
    n: int
    edges: tuple[Edge, ...]

    def adjacency_matrix(self) -> Matrix:
        matrix = [[0 for _ in range(self.n)] for _ in range(self.n)]
        for u, v in self.edges:
            if not (0 <= u < self.n and 0 <= v < self.n):
                raise ValueError(f"edge {(u, v)} has a vertex outside 0..{self.n - 1}")
            if u == v:
                raise ValueError("loops are not allowed")
            if matrix[u][v] == 1:
                raise ValueError(f"duplicate edge {(u, v)}")
            matrix[u][v] = matrix[v][u] = 1
        return matrix


def mat_vec(matrix: Sequence[Sequence[int]], vector: Sequence[int]) -> list[int]:
    """Return a matrix-vector product."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("incompatible dimensions")
    return [sum(a * x for a, x in zip(row, vector)) for row in matrix]


def degree_sequence(graph: Graph) -> list[int]:
    """Compute graph degrees as row sums of the adjacency matrix."""
    return [sum(row) for row in graph.adjacency_matrix()]


def adjacency_degree_matrix_moment(graph: Graph) -> int:
    """Compute 1^T A D A 1 by successive matrix-vector operations."""
    adjacency = graph.adjacency_matrix()
    ones = [1] * graph.n
    a_ones = mat_vec(adjacency, ones)
    d_a_ones = [degree * value for degree, value in zip(a_ones, a_ones)]
    a_d_a_ones = mat_vec(adjacency, d_a_ones)
    return sum(a_d_a_ones)


def degree_cube_moment(graph: Graph) -> int:
    """Compute the third raw degree power sum."""
    return sum(degree**3 for degree in degree_sequence(graph))


def enumerate_three_star_homomorphisms(graph: Graph) -> list[StarMap]:
    """Enumerate (center, leaf1, leaf2, leaf3) star homomorphisms.

    Leaf images are ordered and may repeat, as graph homomorphisms need not be
    injective.
    """
    adjacency = graph.adjacency_matrix()
    neighborhoods = [
        [neighbor for neighbor, is_adjacent in enumerate(row) if is_adjacent]
        for row in adjacency
    ]
    return [
        (center, x, y, z)
        for center in range(graph.n)
        for x, y, z in product(neighborhoods[center], repeat=3)
    ]


def higher_star_moment(graph: Graph, leaf_count: int) -> int:
    """Compute hom(K_{1,leaf_count}, G) as a degree power sum."""
    if leaf_count < 0:
        raise ValueError("leaf_count must be nonnegative")
    return sum(degree**leaf_count for degree in degree_sequence(graph))


def path_graph(n: int) -> Graph:
    if n < 1:
        raise ValueError("a path must have at least one vertex")
    return Graph(f"Path P_{n}", n, tuple((i, i + 1) for i in range(n - 1)))


def cycle_graph(n: int) -> Graph:
    if n < 3:
        raise ValueError("a simple cycle must have at least three vertices")
    return Graph(f"Cycle C_{n}", n, tuple((i, (i + 1) % n) for i in range(n)))


def star_graph(leaves: int) -> Graph:
    if leaves < 1:
        raise ValueError("the demonstration uses at least one leaf")
    return Graph(
        f"Star K_(1,{leaves})", leaves + 1, tuple((0, i) for i in range(1, leaves + 1))
    )


def complete_graph(n: int) -> Graph:
    if n < 1:
        raise ValueError("a complete graph must have at least one vertex")
    return Graph(f"Complete graph K_{n}", n, tuple((i, j) for i in range(n) for j in range(i + 1, n)))


def disjoint_triangles() -> Graph:
    return Graph(
        "Two disjoint triangles",
        6,
        ((0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)),
    )


def demonstrate(graphs: Iterable[Graph]) -> None:
    """Print and assert the three-way identity for each input graph."""
    print("Adjacency-degree moment demonstration")
    print("=" * 72)
    for graph in graphs:
        degrees = degree_sequence(graph)
        matrix_value = adjacency_degree_matrix_moment(graph)
        degree_value = degree_cube_moment(graph)
        maps = enumerate_three_star_homomorphisms(graph)
        star_value = len(maps)
        assert matrix_value == degree_value == star_value
        print(f"{graph.name}")
        print(f"  degrees:                         {degrees}")
        print(f"  1^T A D A 1:                    {matrix_value}")
        print(f"  sum of degree cubes:            {degree_value}")
        print(f"  three-star homomorphism count:  {star_value}")
        print()

    print("Higher star moments for Star K_(1,4)")
    star = star_graph(4)
    for leaves in range(1, 7):
        value = higher_star_moment(star, leaves)
        print(f"  hom(K_(1,{leaves}), K_(1,4)) = {value}")

    cycle = cycle_graph(6)
    triangles = disjoint_triangles()
    assert degree_cube_moment(cycle) == degree_cube_moment(triangles) == 48
    print("\nLimitation example")
    print("  C_6 and two disjoint triangles are nonisomorphic,")
    print("  but both are 2-regular on six vertices and both moments equal 48.")


def main() -> None:
    graphs = [
        path_graph(6),
        cycle_graph(6),
        star_graph(5),
        complete_graph(5),
        disjoint_triangles(),
    ]
    demonstrate(graphs)


if __name__ == "__main__":
    main()
