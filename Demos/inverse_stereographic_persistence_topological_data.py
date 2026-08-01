#!/usr/bin/env python3
"""Numerical demonstrations of exact inverse-stereographic distance transport.

The script uses only Python's standard library.  It compares direct spherical
chordal/geodesic distances with their weighted stereographic counterparts,
exhibits the radial-formula counterexample, and checks Vietoris--Rips edge
sets at several scales for random clouds of 50, 100, and 200 points.
"""

from __future__ import annotations

import math
import random
from typing import Iterable, List, Sequence, Tuple

Vector = Tuple[float, ...]
Edge = Tuple[int, int]


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(x, y))


def norm(x: Sequence[float]) -> float:
    return math.sqrt(dot(x, x))


def subtract(x: Sequence[float], y: Sequence[float]) -> Vector:
    return tuple(a - b for a, b in zip(x, y))


def inverse_stereographic(x: Sequence[float]) -> Vector:
    """Map R^n to the unit sphere S^n, omitting the north pole."""
    r2 = dot(x, x)
    denominator = 1.0 + r2
    return tuple(2.0 * value / denominator for value in x) + (
        (r2 - 1.0) / denominator,
    )


def stereographic(p: Sequence[float]) -> Vector:
    """Map a unit spherical point other than the north pole to R^n."""
    denominator = 1.0 - p[-1]
    if denominator <= 1e-14:
        raise ValueError("point is too close to the omitted north pole")
    return tuple(value / denominator for value in p[:-1])


def chordal_on_sphere(p: Sequence[float], q: Sequence[float]) -> float:
    return norm(subtract(p, q))


def geodesic_on_sphere(p: Sequence[float], q: Sequence[float]) -> float:
    cosine = max(-1.0, min(1.0, dot(p, q)))
    return math.acos(cosine)


def weighted_chordal(x: Sequence[float], y: Sequence[float]) -> float:
    numerator = 2.0 * norm(subtract(x, y))
    denominator = math.sqrt((1.0 + dot(x, x)) * (1.0 + dot(y, y)))
    return numerator / denominator


def weighted_geodesic(x: Sequence[float], y: Sequence[float]) -> float:
    half_chord = max(0.0, min(1.0, weighted_chordal(x, y) / 2.0))
    return 2.0 * math.asin(half_chord)


def proposed_radial_weight(distance: float) -> float:
    return 2.0 * distance / (1.0 + distance * distance / 4.0)


def random_sphere_point(dimension: int, rng: random.Random) -> Vector:
    """Sample a point on S^dimension by normalizing Gaussian coordinates."""
    while True:
        values = tuple(rng.gauss(0.0, 1.0) for _ in range(dimension + 1))
        length = norm(values)
        if length > 1e-12:
            point = tuple(value / length for value in values)
            if 1.0 - point[-1] > 1e-10:
                return point


def pairwise_matrix(points: Sequence[Vector], metric) -> List[List[float]]:
    size = len(points)
    matrix = [[0.0] * size for _ in range(size)]
    for i in range(size):
        for j in range(i + 1, size):
            value = metric(points[i], points[j])
            matrix[i][j] = value
            matrix[j][i] = value
    return matrix


def rips_edges(matrix: Sequence[Sequence[float]], epsilon: float) -> set[Edge]:
    return {
        (i, j)
        for i in range(len(matrix))
        for j in range(i + 1, len(matrix))
        if matrix[i][j] <= epsilon
    }


def maximum_matrix_error(
    first: Sequence[Sequence[float]], second: Sequence[Sequence[float]]
) -> float:
    return max(
        abs(first[i][j] - second[i][j])
        for i in range(len(first))
        for j in range(len(first))
    )


def demonstrate_counterexample() -> None:
    x, y = (0.0,), (2.0,)
    euclidean = norm(subtract(x, y))
    proposed = proposed_radial_weight(euclidean)
    exact = weighted_chordal(x, y)
    print("Counterexample in the one-dimensional chart")
    print(f"  Euclidean separation:       {euclidean:.12f}")
    print(f"  Proposed radial value:      {proposed:.12f}")
    print(f"  Exact chordal value:        {exact:.12f}")
    print(f"  Closed form exact value:    4/sqrt(5) = {4/math.sqrt(5):.12f}")
    print(f"  Absolute discrepancy:       {abs(proposed - exact):.12f}\n")


def validate_cloud(size: int, sphere_dimension: int, seed: int) -> None:
    rng = random.Random(seed)
    spherical = [random_sphere_point(sphere_dimension, rng) for _ in range(size)]
    chart = [stereographic(point) for point in spherical]

    direct_chordal = pairwise_matrix(spherical, chordal_on_sphere)
    chart_chordal = pairwise_matrix(chart, weighted_chordal)
    direct_geodesic = pairwise_matrix(spherical, geodesic_on_sphere)
    chart_geodesic = pairwise_matrix(chart, weighted_geodesic)

    chord_error = maximum_matrix_error(direct_chordal, chart_chordal)
    geodesic_error = maximum_matrix_error(direct_geodesic, chart_geodesic)

    thresholds = (0.25, 0.5, 1.0, 1.5)
    edge_agreement = all(
        rips_edges(direct_chordal, epsilon) == rips_edges(chart_chordal, epsilon)
        for epsilon in thresholds
    )

    print(f"Random cloud: N={size}, sphere S^{sphere_dimension}")
    print(f"  maximum chordal discrepancy: {chord_error:.3e}")
    print(f"  maximum geodesic discrepancy: {geodesic_error:.3e}")
    print(f"  Rips edge sets agree at {len(thresholds)} scales: {edge_agreement}")


def main() -> None:
    demonstrate_counterexample()
    for size in (50, 100, 200):
        validate_cloud(size=size, sphere_dimension=2, seed=20260801 + size)


if __name__ == "__main__":
    main()
