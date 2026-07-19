#!/usr/bin/env python3
"""Numerical demonstrations for CSS homology and hypercube graph codes.

The script uses only Python's standard library.  It computes ranks over GF(2),
checks a length-two chain complex, evaluates its logical dimension, constructs
small hypercube graphs, and confirms the requested Q4, Q6, and Q8 parameters.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Iterable, Sequence

BinaryMatrix = list[list[int]]


@dataclass(frozen=True)
class HypercubeParameters:
    dimension: int
    vertices: int
    edges: int
    logical_qubits: int
    girth: int | None


def gf2_rank(matrix: Sequence[Sequence[int]]) -> int:
    """Return the rank of a rectangular binary matrix over GF(2)."""
    if not matrix:
        return 0
    width = len(matrix[0])
    if any(len(row) != width for row in matrix):
        raise ValueError("matrix must be rectangular")
    rows = [[entry & 1 for entry in row] for row in matrix]
    pivot_row = 0
    for column in range(width):
        pivot = next(
            (row for row in range(pivot_row, len(rows)) if rows[row][column]),
            None,
        )
        if pivot is None:
            continue
        rows[pivot_row], rows[pivot] = rows[pivot], rows[pivot_row]
        for row in range(len(rows)):
            if row != pivot_row and rows[row][column]:
                rows[row] = [a ^ b for a, b in zip(rows[row], rows[pivot_row])]
        pivot_row += 1
        if pivot_row == len(rows):
            break
    return pivot_row


def gf2_product(left: Sequence[Sequence[int]], right: Sequence[Sequence[int]]) -> BinaryMatrix:
    """Multiply two matrices over GF(2)."""
    if not left:
        return []
    inner = len(left[0])
    if any(len(row) != inner for row in left):
        raise ValueError("left matrix must be rectangular")
    if len(right) != inner:
        raise ValueError("incompatible matrix dimensions")
    width = len(right[0]) if right else 0
    if any(len(row) != width for row in right):
        raise ValueError("right matrix must be rectangular")
    return [
        [sum(left[i][t] * right[t][j] for t in range(inner)) & 1 for j in range(width)]
        for i in range(len(left))
    ]


def css_logical_dimension(d1: Sequence[Sequence[int]], d2: Sequence[Sequence[int]]) -> int:
    """Compute k = dim(B) - rank(d1) - rank(d2), checking d1*d2 = 0."""
    if d1:
        middle_dimension = len(d1[0])
        if any(len(row) != middle_dimension for row in d1):
            raise ValueError("d1 must be rectangular")
    else:
        middle_dimension = len(d2)
    if len(d2) != middle_dimension:
        raise ValueError("d2 must have one row per basis element of the middle space")
    if any(any(entry for entry in row) for row in gf2_product(d1, d2)):
        raise ValueError("the chain condition d1*d2 = 0 fails")
    logical = middle_dimension - gf2_rank(d1) - gf2_rank(d2)
    if logical < 0:
        raise ArithmeticError("invalid negative logical dimension")
    return logical


def hypercube_parameters(n: int) -> HypercubeParameters:
    """Return exact graph-homological parameters of Q_n without enumeration."""
    if n < 1:
        raise ValueError("n must be positive")
    vertices = 1 << n
    edges = n * (1 << (n - 1))
    logical = edges - vertices + 1
    return HypercubeParameters(n, vertices, edges, logical, 4 if n >= 2 else None)


def hypercube_adjacency(n: int) -> list[list[int]]:
    """Construct the adjacency lists of Q_n using integer bit-vectors."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return [[vertex ^ (1 << bit) for bit in range(n)] for vertex in range(1 << n)]


def graph_girth(adjacency: Sequence[Sequence[int]]) -> int | None:
    """Compute undirected graph girth by breadth-first search from every vertex."""
    best: int | None = None
    for source in range(len(adjacency)):
        distance = [-1] * len(adjacency)
        parent = [-1] * len(adjacency)
        distance[source] = 0
        queue: deque[int] = deque([source])
        while queue:
            vertex = queue.popleft()
            for neighbor in adjacency[vertex]:
                if distance[neighbor] == -1:
                    distance[neighbor] = distance[vertex] + 1
                    parent[neighbor] = vertex
                    queue.append(neighbor)
                elif parent[vertex] != neighbor:
                    cycle_length = distance[vertex] + distance[neighbor] + 1
                    best = cycle_length if best is None else min(best, cycle_length)
    return best


def cycle_incidence_matrix(vertex_count: int, edges: Iterable[tuple[int, int]]) -> BinaryMatrix:
    """Build the vertex-by-edge incidence matrix of a binary graph complex."""
    edge_list = list(edges)
    matrix = [[0] * len(edge_list) for _ in range(vertex_count)]
    for column, (u, v) in enumerate(edge_list):
        matrix[u][column] = 1
        matrix[v][column] = 1
    return matrix


def run_demo() -> None:
    """Run three demonstrations and assert all advertised identities."""
    print("CSS homology: dimension, hypercube counts, and graph girth\n")

    # A square graph: four edge qubits, connected incidence rank three, k = 1.
    square_edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    square_d1 = cycle_incidence_matrix(4, square_edges)
    square_d2 = [[] for _ in range(4)]
    square_k = css_logical_dimension(square_d1, square_d2)
    print(f"Square graph: rank(d1)={gf2_rank(square_d1)}, rank(d2)=0, k={square_k}")
    assert square_k == 1

    print("\nHypercube graph parameters:")
    for n in (2, 4, 6, 8):
        p = hypercube_parameters(n)
        print(f"Q_{n}: V={p.vertices:4d}, E={p.edges:4d}, k={p.logical_qubits:4d}, girth={p.girth}")
    assert [hypercube_parameters(n).logical_qubits for n in (4, 6, 8)] == [17, 129, 769]

    print("\nIndependent breadth-first girth checks:")
    for n in range(2, 7):
        measured = graph_girth(hypercube_adjacency(n))
        print(f"Q_{n}: computed girth={measured}")
        assert measured == 4

    print("\nAll identities and numerical test cases passed.")


if __name__ == "__main__":
    run_demo()
