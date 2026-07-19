#!/usr/bin/env python3
"""Numerical illustrations for infinite-dimensional Hilbert geometry.

The script uses only the Python standard library.  Its finite calculations
illustrate exact coordinate-padding isometries, finite landmark coordinates for
a Hilbert-cube embedding, and the strict finite-dimensional obstruction.
"""

from __future__ import annotations

import math
import random
from typing import Iterable, Sequence

Vector = list[float]


def l2_distance(x: Sequence[float], y: Sequence[float]) -> float:
    """Return Euclidean distance between equal-length real vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have equal length")
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def pad_isometrically(x: Sequence[float], ambient_dimension: int) -> Vector:
    """Embed R^n into R^N by appending zeros, where N >= n."""
    if ambient_dimension < len(x):
        raise ValueError("ambient dimension must be at least the source dimension")
    return [float(value) for value in x] + [0.0] * (ambient_dimension - len(x))


def compressed_distance_coordinate(distance: float) -> float:
    """Map a nonnegative distance continuously and injectively into [0, 1)."""
    if distance < 0:
        raise ValueError("distance must be nonnegative")
    return distance / (1.0 + distance)


def landmark_embedding(x: Sequence[float], landmarks: Sequence[Sequence[float]]) -> Vector:
    """Return finite Hilbert-cube coordinates based on distances to landmarks."""
    return [compressed_distance_coordinate(l2_distance(x, q)) for q in landmarks]


def antilipschitz_dimension_obstruction(source_dimension: int, target_dimension: int) -> bool:
    """Report whether dimension alone rules out an antilipschitz map."""
    if source_dimension < 0 or target_dimension < 0:
        raise ValueError("dimensions must be nonnegative")
    return target_dimension < source_dimension


def rational_truncation(x: Sequence[float], digits: int, cutoff: int) -> Vector:
    """Approximate a finite sequence by rounding its first cutoff coordinates."""
    if cutoff < 0 or cutoff > len(x):
        raise ValueError("cutoff must lie between zero and the vector length")
    return [round(float(value), digits) for value in x[:cutoff]] + [0.0] * (len(x) - cutoff)


def random_vector(dimension: int, rng: random.Random) -> Vector:
    """Generate a reproducible vector with coordinates in [-1, 1]."""
    return [rng.uniform(-1.0, 1.0) for _ in range(dimension)]


def demonstrate_isometry() -> None:
    """Check exact distance preservation at several finite stages."""
    rng = random.Random(20260719)
    print("\n1. Coordinate-padding isometries")
    for n in (1, 2, 5, 12):
        x, y = random_vector(n, rng), random_vector(n, rng)
        source = l2_distance(x, y)
        target = l2_distance(pad_isometrically(x, 40), pad_isometrically(y, 40))
        print(f"R^{n:2d} -> R^40: source={source:.12f}, target={target:.12f}, error={abs(source-target):.3e}")


def demonstrate_landmarks() -> None:
    """Show finite distance-coordinate addresses and point separation."""
    landmarks = [[0.0, 0.0], [1.0, 0.0], [0.0, 1.0], [-1.0, -1.0]]
    x, y = [0.25, -0.40], [0.30, -0.40]
    phi_x = landmark_embedding(x, landmarks)
    phi_y = landmark_embedding(y, landmarks)
    print("\n2. Finite Hilbert-cube landmark coordinates")
    print("Phi(x) =", [round(v, 6) for v in phi_x])
    print("Phi(y) =", [round(v, 6) for v in phi_y])
    print("Maximum coordinate separation:", f"{max(abs(a-b) for a, b in zip(phi_x, phi_y)):.6f}")


def demonstrate_obstruction() -> None:
    """Display the strict dimension region forbidden to antilipschitz maps."""
    print("\n3. Strict dimension obstruction table")
    print("Rows are source dimensions n; columns are target dimensions m.")
    print("X means that m < n rules out a global antilipschitz map.\n")
    max_dimension = 7
    print("n\\m | " + " ".join(str(m) for m in range(max_dimension + 1)))
    print("----+" + "--" * (max_dimension + 1))
    for n in range(max_dimension + 1):
        row = ["X" if antilipschitz_dimension_obstruction(n, m) else "." for m in range(max_dimension + 1)]
        print(f" {n:2d} | " + " ".join(row))


def demonstrate_dense_approximation() -> None:
    """Illustrate approximation by finitely supported rational data."""
    x = [((-1.0) ** j) / (j + 1) for j in range(30)]
    print("\n4. Finite rational approximations")
    for cutoff in (2, 5, 10, 20, 30):
        q = rational_truncation(x, digits=4, cutoff=cutoff)
        print(f"cutoff={cutoff:2d}, approximation error={l2_distance(x, q):.8f}")


def main() -> None:
    """Run all numerical demonstrations."""
    print("INFINITE-DIMENSIONAL HILBERT GEOMETRY: NUMERICAL DEMONSTRATIONS")
    demonstrate_isometry()
    demonstrate_landmarks()
    demonstrate_obstruction()
    demonstrate_dense_approximation()


if __name__ == "__main__":
    main()
