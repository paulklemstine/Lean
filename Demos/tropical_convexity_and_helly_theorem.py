#!/usr/bin/env python3
"""Numerical demonstrations of tropical box convexity and Helly feasibility."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence

Vector = tuple[float, ...]


@dataclass(frozen=True)
class Box:
    """A closed axis-aligned box with matching lower and upper vectors."""

    lower: Vector
    upper: Vector

    def __post_init__(self) -> None:
        if len(self.lower) != len(self.upper):
            raise ValueError("lower and upper vectors must have the same dimension")

    @property
    def dimension(self) -> int:
        return len(self.lower)

    def contains(self, point: Sequence[float], tolerance: float = 1e-12) -> bool:
        if len(point) != self.dimension:
            return False
        return all(
            lo - tolerance <= value <= hi + tolerance
            for lo, value, hi in zip(self.lower, point, self.upper)
        )


@dataclass(frozen=True)
class InfeasibilityCertificate:
    """Two boxes and one coordinate witnessing incompatible bounds."""

    lower_box: int
    upper_box: int
    coordinate: int
    lower_value: float
    upper_value: float


def tropical_combine(t: float, x: Sequence[float], y: Sequence[float]) -> Vector:
    """Return C_t(x,y)_i = max(x_i, t + y_i), requiring t <= 0."""
    if t > 0:
        raise ValueError("the normalized tropical parameter must satisfy t <= 0")
    if len(x) != len(y):
        raise ValueError("points must have the same dimension")
    return tuple(max(xi, t + yi) for xi, yi in zip(x, y))


def tropical_hull_point(points: Sequence[Sequence[float]], weights: Sequence[float]) -> Vector:
    """Evaluate the weighted max-plus upper envelope of finite generators."""
    if not points:
        raise ValueError("at least one generator is required")
    if len(points) != len(weights):
        raise ValueError("there must be one weight per generator")
    dimension = len(points[0])
    if any(len(point) != dimension for point in points):
        raise ValueError("all generators must have the same dimension")
    return tuple(
        max(weight + point[i] for weight, point in zip(weights, points))
        for i in range(dimension)
    )


def boxes_intersect(first: Box, second: Box) -> bool:
    """Decide pairwise intersection by comparing coordinate intervals."""
    if first.dimension != second.dimension:
        raise ValueError("boxes must have the same dimension")
    return all(
        max(lo1, lo2) <= min(hi1, hi2)
        for lo1, hi1, lo2, hi2 in zip(
            first.lower, first.upper, second.lower, second.upper
        )
    )


def solve_boxes(
    boxes: Sequence[Box],
) -> Vector | InfeasibilityCertificate:
    """Return the canonical common point or a two-box infeasibility certificate.

    The scan costs O(n*d) time for n boxes in dimension d.
    """
    if not boxes:
        return ()
    dimension = boxes[0].dimension
    if any(box.dimension != dimension for box in boxes):
        raise ValueError("all boxes must have the same dimension")

    canonical: list[float] = []
    for coordinate in range(dimension):
        lower_box = max(range(len(boxes)), key=lambda k: boxes[k].lower[coordinate])
        upper_box = min(range(len(boxes)), key=lambda k: boxes[k].upper[coordinate])
        lower_value = boxes[lower_box].lower[coordinate]
        upper_value = boxes[upper_box].upper[coordinate]
        if lower_value > upper_value:
            return InfeasibilityCertificate(
                lower_box=lower_box,
                upper_box=upper_box,
                coordinate=coordinate,
                lower_value=lower_value,
                upper_value=upper_value,
            )
        canonical.append(lower_value)
    return tuple(canonical)


def pairwise_status(boxes: Sequence[Box]) -> list[tuple[int, int, bool]]:
    """List the intersection status of every unordered box pair."""
    return [
        (i, j, boxes_intersect(boxes[i], boxes[j]))
        for i in range(len(boxes))
        for j in range(i + 1, len(boxes))
    ]


def demonstrate_tropical_convexity() -> None:
    box = Box(lower=(0.0, -1.0, 2.0), upper=(5.0, 4.0, 7.0))
    x = (1.0, 3.5, 2.5)
    y = (4.5, 0.0, 6.0)
    print("\nTropical combinations inside one box")
    print(f"box = {box}")
    for t in (0.0, -0.5, -2.0, -10.0):
        z = tropical_combine(t, x, y)
        print(f"t={t:5.1f}: C_t(x,y)={z}, contained={box.contains(z)}")


def demonstrate_hull_identity() -> None:
    points = ((0.0, 2.0), (3.0, -1.0), (1.0, 4.0))
    first_weights = (0.0, -2.0, -1.0)
    second_weights = (-1.5, 0.0, -3.0)
    t = -0.75
    first = tropical_hull_point(points, first_weights)
    second = tropical_hull_point(points, second_weights)
    combined = tropical_combine(t, first, second)
    merged_weights = tuple(
        max(u, t + v) for u, v in zip(first_weights, second_weights)
    )
    represented_again = tropical_hull_point(points, merged_weights)
    print("\nTropical hull closure identity")
    print(f"first hull point       = {first}")
    print(f"second hull point      = {second}")
    print(f"tropical combination   = {combined}")
    print(f"new-weight upper hull  = {represented_again}")
    print(f"identity holds         = {combined == represented_again}")


def demonstrate_feasible_family() -> None:
    boxes = (
        Box((0.0, 1.0), (6.0, 7.0)),
        Box((2.0, 0.0), (8.0, 5.0)),
        Box((1.0, 3.0), (4.0, 9.0)),
        Box((2.5, 2.0), (7.0, 6.0)),
    )
    result = solve_boxes(boxes)
    print("\nPairwise-compatible family")
    print(f"pairwise statuses = {pairwise_status(boxes)}")
    print(f"solver result      = {result}")
    if isinstance(result, tuple):
        print(f"contained in all   = {all(box.contains(result) for box in boxes)}")


def demonstrate_infeasible_family() -> None:
    boxes = (
        Box((0.0, 0.0), (4.0, 8.0)),
        Box((1.0, 6.0), (7.0, 10.0)),
        Box((2.0, 3.0), (9.0, 5.0)),
    )
    result = solve_boxes(boxes)
    print("\nInfeasible family with a two-box certificate")
    print(f"solver result = {result}")
    if isinstance(result, InfeasibilityCertificate):
        p, q = result.lower_box, result.upper_box
        print(f"certified pair intersects = {boxes_intersect(boxes[p], boxes[q])}")
        print(
            f"coordinate {result.coordinate}: "
            f"lower {result.lower_value} > upper {result.upper_value}"
        )


def main() -> None:
    demonstrate_tropical_convexity()
    demonstrate_hull_identity()
    demonstrate_feasible_family()
    demonstrate_infeasible_family()


if __name__ == "__main__":
    main()
