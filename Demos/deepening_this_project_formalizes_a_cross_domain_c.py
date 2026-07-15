#!/usr/bin/env python3
"""Numerical demonstrations of clique-count rigidity in Rips filtrations."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import hypot, sqrt
from typing import Iterable, Sequence

Matrix = list[list[float]]


@dataclass(frozen=True)
class FiltrationEvent:
    """A critical scale together with the resulting simplex count and jump."""

    scale: float
    simplex_count: int
    jump: int
    edges_added: int


def euclidean_distance_matrix(points: Sequence[tuple[float, float]]) -> Matrix:
    """Return the symmetric Euclidean distance matrix of planar points."""
    return [
        [hypot(x1 - x2, y1 - y2) for x2, y2 in points]
        for x1, y1 in points
    ]


def is_clique(mask: int, distances: Sequence[Sequence[float]], scale: float) -> bool:
    """Test whether the vertices selected by ``mask`` form a Rips simplex."""
    vertices = [i for i in range(len(distances)) if mask & (1 << i)]
    return all(distances[i][j] <= scale for i, j in combinations(vertices, 2))


def rips_simplex_count(distances: Sequence[Sequence[float]], scale: float) -> int:
    """Count all Rips simplices, including the empty simplex."""
    n = len(distances)
    if any(len(row) != n for row in distances):
        raise ValueError("The dissimilarity matrix must be square.")
    if any(distances[i][i] > scale for i in range(n)):
        raise ValueError("Every diagonal value must be at most the scale.")
    return sum(is_clique(mask, distances, scale) for mask in range(1 << n))


def filtration_profile(distances: Sequence[Sequence[float]]) -> list[FiltrationEvent]:
    """Compute counts at every distinct off-diagonal critical scale."""
    n = len(distances)
    critical = sorted({distances[i][j] for i in range(n) for j in range(i + 1, n)})
    previous_count = n + 1  # empty simplex and all singleton vertices
    previous_edges = 0
    events: list[FiltrationEvent] = []
    for scale in critical:
        count = rips_simplex_count(distances, scale)
        edges = sum(distances[i][j] <= scale for i in range(n) for j in range(i + 1, n))
        events.append(FiltrationEvent(scale, count, count - previous_count, edges - previous_edges))
        previous_count, previous_edges = count, edges
    return events


def complete_graph_with_missing_edges(n: int, missing: Iterable[tuple[int, int]]) -> Matrix:
    """Encode a graph as a 0/1 dissimilarity matrix: edges have value 0, nonedges 1."""
    absent = {tuple(sorted(edge)) for edge in missing}
    return [
        [0.0 if i == j or tuple(sorted((i, j))) not in absent else 1.0 for j in range(n)]
        for i in range(n)
    ]


def print_profile(name: str, distances: Matrix) -> None:
    """Print a professionally formatted filtration table."""
    n = len(distances)
    print(f"\n{name} (n={n}, maximum={2**n} simplices)")
    print("scale       edges born   simplex count   jump")
    print("----------  -----------  --------------  ----")
    for event in filtration_profile(distances):
        print(
            f"{event.scale:10.6g}  {event.edges_added:11d}  "
            f"{event.simplex_count:14d}  {event.jump:4d}"
        )


def main() -> None:
    """Run three examples illustrating strict growth and extremal saturation."""
    triangle: Matrix = [
        [0.0, 1.0, 3.0],
        [1.0, 0.0, 2.0],
        [3.0, 2.0, 0.0],
    ]
    print_profile("Three distinct edge-birth scales", triangle)

    square = euclidean_distance_matrix([(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)])
    print_profile("Unit square", square)
    assert rips_simplex_count(square, 1.0) == 9
    assert rips_simplex_count(square, sqrt(2.0)) == 16

    n = 6
    almost_complete = complete_graph_with_missing_edges(n, [(0, 1)])
    deficient = rips_simplex_count(almost_complete, 0.0)
    expected = 2**n - 2 ** (n - 2)
    print(f"\nComplete graph on {n} vertices with one missing edge")
    print(f"observed count: {deficient}; formula: 2^{n} - 2^{n-2} = {expected}")
    print(f"adding the final edge creates {2 ** (n - 2)} simplices")
    assert deficient == expected
    assert rips_simplex_count(almost_complete, 1.0) == 2**n

if __name__ == "__main__":
    main()
