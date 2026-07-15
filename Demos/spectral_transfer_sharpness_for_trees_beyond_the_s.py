#!/usr/bin/env python3
"""Numerical demonstrations of the sharp five-vertex path inequality.

The script uses only the Python standard library.  It evaluates a symmetric
weighted network in O(n^2) time, compares S^4 with n^3 P, exhibits equality
for constant kernels, checks a signed example, and runs reproducible random
experiments.
"""

from __future__ import annotations

from dataclasses import dataclass
import math
import random
from typing import Iterable, Sequence

Matrix = list[list[float]]


@dataclass(frozen=True)
class PathStatistics:
    """All quantities in the two-step proof of the P5 inequality."""

    size: int
    degrees: tuple[float, ...]
    two_step: tuple[float, ...]
    edge_weight: float
    degree_energy: float
    path_five_count: float
    left_side: float
    right_side: float
    gap: float
    edge_density: float | None
    path_density: float | None
    degree_slack: float
    two_step_slack: float


def validate_symmetric(matrix: Sequence[Sequence[float]], tolerance: float = 1e-12) -> None:
    """Raise ValueError unless matrix is square and symmetric to tolerance."""
    n = len(matrix)
    if any(len(row) != n for row in matrix):
        raise ValueError("the matrix must be square")
    for i in range(n):
        for j in range(i + 1, n):
            if not math.isclose(matrix[i][j], matrix[j][i], rel_tol=tolerance, abs_tol=tolerance):
                raise ValueError(f"matrix is not symmetric at ({i}, {j})")


def matrix_vector(matrix: Sequence[Sequence[float]], vector: Sequence[float]) -> list[float]:
    """Multiply a dense matrix by a vector."""
    return [sum(value * vector[j] for j, value in enumerate(row)) for row in matrix]


def path_statistics(matrix: Sequence[Sequence[float]]) -> PathStatistics:
    """Compute the edge and P5 quantities using two matrix-vector products."""
    validate_symmetric(matrix)
    n = len(matrix)
    ones = [1.0] * n
    degrees = matrix_vector(matrix, ones)
    two_step = matrix_vector(matrix, degrees)
    edge_weight = sum(degrees)
    degree_energy = sum(value * value for value in degrees)
    path_count = sum(value * value for value in two_step)
    left = edge_weight**4
    right = (n**3) * path_count
    edge_density = edge_weight / (n**2) if n else None
    path_density = path_count / (n**5) if n else None
    return PathStatistics(
        size=n,
        degrees=tuple(degrees),
        two_step=tuple(two_step),
        edge_weight=edge_weight,
        degree_energy=degree_energy,
        path_five_count=path_count,
        left_side=left,
        right_side=right,
        gap=right - left,
        edge_density=edge_density,
        path_density=path_density,
        degree_slack=n * degree_energy - edge_weight**2,
        two_step_slack=n * path_count - degree_energy**2,
    )


def constant_matrix(size: int, value: float) -> Matrix:
    """Return the size-by-size constant symmetric matrix."""
    if size < 0:
        raise ValueError("size must be nonnegative")
    return [[value for _ in range(size)] for _ in range(size)]


def random_symmetric_matrix(size: int, rng: random.Random, scale: float = 1.0) -> Matrix:
    """Generate a signed symmetric matrix with reproducible uniform entries."""
    matrix = [[0.0] * size for _ in range(size)]
    for i in range(size):
        for j in range(i, size):
            value = rng.uniform(-scale, scale)
            matrix[i][j] = value
            matrix[j][i] = value
    return matrix


def print_report(title: str, stats: PathStatistics) -> None:
    """Print a compact mathematical report."""
    print(f"\n{title}")
    print("-" * len(title))
    print(f"n                       = {stats.size}")
    print(f"degrees                 = {stats.degrees}")
    print(f"two-step weights        = {stats.two_step}")
    print(f"S                       = {stats.edge_weight:.12g}")
    print(f"T = sum(d_i^2)          = {stats.degree_energy:.12g}")
    print(f"P = sum((Ad)_i^2)       = {stats.path_five_count:.12g}")
    print(f"S^4                     = {stats.left_side:.12g}")
    print(f"n^3 P                   = {stats.right_side:.12g}")
    print(f"gap                     = {stats.gap:.12g}")
    print(f"degree slack            = {stats.degree_slack:.12g}")
    print(f"two-step slack          = {stats.two_step_slack:.12g}")
    if stats.edge_density is not None and stats.path_density is not None:
        print(f"t(K2)                   = {stats.edge_density:.12g}")
        print(f"t(P5)                   = {stats.path_density:.12g}")
        print(f"t(K2)^4                 = {stats.edge_density**4:.12g}")


def verify_gap_identity(stats: PathStatistics, tolerance: float = 1e-8) -> bool:
    """Check n^3 P-S^4 = n^2 Delta_u + Delta_d(nT+S^2)."""
    n = stats.size
    reconstructed = (
        n**2 * stats.two_step_slack
        + stats.degree_slack * (n * stats.degree_energy + stats.edge_weight**2)
    )
    scale = max(1.0, abs(stats.gap), abs(reconstructed))
    return abs(stats.gap - reconstructed) <= tolerance * scale


def run_random_trials(count: int = 100, size: int = 6, seed: int = 20260715) -> float:
    """Return the smallest numerical gap among reproducible signed trials."""
    rng = random.Random(seed)
    minimum_gap = math.inf
    for _ in range(count):
        stats = path_statistics(random_symmetric_matrix(size, rng))
        scale = max(1.0, abs(stats.left_side), abs(stats.right_side))
        if stats.gap < -1e-10 * scale:
            raise AssertionError("a trial violated the inequality beyond rounding tolerance")
        if not verify_gap_identity(stats):
            raise AssertionError("the gap decomposition failed numerically")
        minimum_gap = min(minimum_gap, stats.gap)
    return minimum_gap


def main() -> None:
    equality = path_statistics(constant_matrix(3, 0.5))
    print_report("Constant kernel: sharp equality", equality)

    signed = path_statistics([
        [1.0, -1.0, 2.0],
        [-1.0, 3.0, 0.0],
        [2.0, 0.0, -2.0],
    ])
    print_report("Signed symmetric kernel: strict inequality", signed)

    if not math.isclose(equality.gap, 0.0, abs_tol=1e-10):
        raise AssertionError("constant kernels should attain equality")
    if signed.gap < -1e-10:
        raise AssertionError("the signed example should satisfy the theorem")
    if not verify_gap_identity(signed):
        raise AssertionError("the exact gap decomposition should hold")

    minimum = run_random_trials()
    print("\nReproducible random experiment")
    print("------------------------------")
    print("100 signed symmetric 6-by-6 matrices checked.")
    print(f"Smallest raw gap observed: {minimum:.12g}")
    print("All inequalities and gap decompositions passed within tolerance.")


if __name__ == "__main__":
    main()
