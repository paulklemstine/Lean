#!/usr/bin/env python3
"""Numerical demonstrations for four-dimensional complex geometry.

The script uses only Python's standard library.  It checks the Hopf norm
identity and phase fibers, identifies the Clifford torus over the equator,
exhibits a fixed-point-free quarter-turn, evaluates four-ball volumes, and
enumerates all tesseract vertex distances.
"""

from __future__ import annotations

from itertools import combinations, product
from math import isclose, pi, sqrt
from typing import Iterable, TypeAlias

ComplexPair: TypeAlias = tuple[complex, complex]
Vector3: TypeAlias = tuple[float, float, float]
Vertex4: TypeAlias = tuple[int, int, int, int]


def norm_sq_pair(point: ComplexPair) -> float:
    """Return |z|^2 + |w|^2 for a point (z, w) in complex two-space."""
    z, w = point
    return abs(z) ** 2 + abs(w) ** 2


def normalize(point: ComplexPair) -> ComplexPair:
    """Normalize a nonzero complex pair to the unit three-sphere."""
    length = sqrt(norm_sq_pair(point))
    if length == 0.0:
        raise ValueError("the zero vector cannot be normalized")
    z, w = point
    return z / length, w / length


def hopf(point: ComplexPair) -> Vector3:
    """Compute the three real quadratic Hopf coordinates."""
    z, w = point
    cross = z * w.conjugate()
    return 2.0 * cross.real, 2.0 * cross.imag, abs(z) ** 2 - abs(w) ** 2


def vector3_norm_sq(vector: Vector3) -> float:
    """Return the squared Euclidean norm of a real three-vector."""
    return sum(coordinate * coordinate for coordinate in vector)


def phase_action(phase: complex, point: ComplexPair) -> ComplexPair:
    """Multiply both complex coordinates by a common phase."""
    z, w = point
    return phase * z, phase * w


def reconstruct_phase(source: ComplexPair, target: ComplexPair) -> complex:
    """Recover the common phase target = phase * source for unit pairs."""
    z, w = source
    zp, wp = target
    return z.conjugate() * zp + w.conjugate() * wp


def pair_distance(source: ComplexPair, target: ComplexPair) -> float:
    """Return Euclidean distance in complex two-space."""
    return sqrt(abs(source[0] - target[0]) ** 2 + abs(source[1] - target[1]) ** 2)


def quarter_turn(point: ComplexPair) -> ComplexPair:
    """Rotate both orthogonal complex coordinate planes by 90 degrees."""
    return phase_action(1j, point)


def four_ball_volume(radius: float) -> float:
    """Return the volume of an open four-ball; nonpositive radii give zero."""
    return 0.5 * pi**2 * max(radius, 0.0) ** 4


def tesseract_vertices() -> list[Vertex4]:
    """Return the sixteen sign vertices of the standard tesseract."""
    return [tuple(signs) for signs in product((-1, 1), repeat=4)]  # type: ignore[misc]


def hamming_distance(x: Vertex4, y: Vertex4) -> int:
    """Count coordinates in which two sign vertices differ."""
    return sum(a != b for a, b in zip(x, y))


def squared_vertex_distance(x: Vertex4, y: Vertex4) -> int:
    """Compute squared Euclidean distance between tesseract vertices."""
    return sum((a - b) ** 2 for a, b in zip(x, y))


def histogram(values: Iterable[int]) -> dict[int, int]:
    """Count integer values and return a key-sorted dictionary."""
    counts: dict[int, int] = {}
    for value in values:
        counts[value] = counts.get(value, 0) + 1
    return dict(sorted(counts.items()))


def demonstrate_hopf_geometry() -> None:
    """Print numerical checks of the Hopf and Clifford-torus results."""
    point = normalize((1.0 + 2.0j, -0.5 + 1.5j))
    image = hopf(point)
    phase = complex(3.0 / 5.0, 4.0 / 5.0)
    moved = phase_action(phase, point)
    moved_image = hopf(moved)
    recovered = reconstruct_phase(point, moved)

    print("HOPF GEOMETRY")
    print(f"unit point: {point}")
    print(f"Hopf image: {image}")
    print(f"squared image norm: {vector3_norm_sq(image):.15f}")
    print(f"phase-invariance residual: "
          f"{sqrt(sum((a-b)**2 for a, b in zip(image, moved_image))):.3e}")
    print(f"chosen phase:    {phase}")
    print(f"recovered phase: {recovered}")
    print(f"reconstruction error: "
          f"{pair_distance(moved, phase_action(recovered, point)):.3e}")

    clifford_point = (1.0 / sqrt(2.0), 1j / sqrt(2.0))
    clifford_image = hopf(clifford_point)
    print("\nCLIFFORD TORUS")
    print(f"point: {clifford_point}")
    print(f"equal coordinate moduli: "
          f"{isclose(abs(clifford_point[0]), abs(clifford_point[1]))}")
    print(f"Hopf image: {clifford_image}")
    print(f"equatorial height: {clifford_image[2]:.3e}")


def demonstrate_rotation_and_volume() -> None:
    """Print checks for the quarter-turn and four-ball volume scaling."""
    point: ComplexPair = (2.0 - 1.0j, -3.0 + 0.5j)
    turned = quarter_turn(point)
    print("\nFOUR-DIMENSIONAL QUARTER-TURN")
    print(f"point: {point}")
    print(f"quarter-turn: {turned}")
    print(f"norm squared before/after: "
          f"{norm_sq_pair(point):.6f} / {norm_sq_pair(turned):.6f}")
    print(f"distance from its image: {pair_distance(point, turned):.6f}")

    print("\nFOUR-BALL VOLUME")
    for radius in (0.5, 1.0, 2.0):
        print(f"radius {radius:>3}: volume {four_ball_volume(radius):.10f}")
    ratio = four_ball_volume(2.0) / four_ball_volume(1.0)
    print(f"doubling-radius volume ratio: {ratio:.1f} (expected 2^4 = 16)")


def demonstrate_tesseract() -> None:
    """Enumerate tesseract pairs and verify distance equals four times Hamming distance."""
    vertices = tesseract_vertices()
    pairs = list(combinations(vertices, 2))
    assert all(
        squared_vertex_distance(x, y) == 4 * hamming_distance(x, y)
        for x, y in pairs
    )
    distances = [squared_vertex_distance(x, y) for x, y in pairs]
    maximum = max(distances)
    maximizing_pairs = [(x, y) for x, y in pairs if squared_vertex_distance(x, y) == maximum]

    print("\nTESSERACT DISTANCES")
    print(f"vertices: {len(vertices)}; unordered pairs: {len(pairs)}")
    print(f"squared-distance histogram: {histogram(distances)}")
    print(f"maximum squared distance: {maximum}; diameter: {sqrt(maximum):.1f}")
    print(f"antipodal maximizing pairs: {len(maximizing_pairs)}")
    print(f"example: {maximizing_pairs[0]}")


def main() -> None:
    """Run every numerical demonstration."""
    demonstrate_hopf_geometry()
    demonstrate_rotation_and_volume()
    demonstrate_tesseract()


if __name__ == "__main__":
    main()
