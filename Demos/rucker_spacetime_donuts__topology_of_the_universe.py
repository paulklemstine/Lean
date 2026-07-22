#!/usr/bin/env python3
"""Numerical illustrations of wrapping and causality on flat toroidal quotients."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import isclose
from typing import Iterable, Literal, Sequence

Vector3 = tuple[float, float, float]
IntegerVector3 = tuple[int, int, int]
CausalType = Literal["timelike", "null", "spacelike"]


@dataclass(frozen=True)
class Velocity:
    """A constant velocity with one temporal and three spatial components."""

    time: float
    space: Vector3


def torus_point(direction: IntegerVector3, parameter: float) -> Vector3:
    """Project a point on an integer-direction line to the unit three-torus."""
    return tuple((parameter * component) % 1.0 for component in direction)  # type: ignore[return-value]


def sample_geodesic(direction: IntegerVector3, samples: int = 16) -> list[Vector3]:
    """Sample one unit-period traversal of a projected straight line."""
    if samples <= 0:
        raise ValueError("samples must be positive")
    return [torus_point(direction, k / samples) for k in range(samples + 1)]


def same_torus_point(left: Sequence[float], right: Sequence[float], tol: float = 1e-10) -> bool:
    """Test equality modulo one, allowing floating-point tolerance."""
    return all(isclose((a - b) % 1.0, 0.0, abs_tol=tol) or
               isclose((a - b) % 1.0, 1.0, abs_tol=tol)
               for a, b in zip(left, right, strict=True))


def is_integral(value: float, tol: float = 1e-10) -> bool:
    """Test whether a floating-point value is numerically integral."""
    return isclose(value, round(value), abs_tol=tol)


def lorentzian_norm_squared(velocity: Velocity) -> float:
    """Return |space|^2 - time^2 for signature (-,+,+,+)."""
    return sum(component * component for component in velocity.space) - velocity.time**2


def causal_type(velocity: Velocity, tol: float = 1e-10) -> CausalType:
    """Classify a constant velocity by its Lorentzian norm."""
    norm = lorentzian_norm_squared(velocity)
    if isclose(norm, 0.0, abs_tol=tol):
        return "null"
    return "timelike" if norm < 0.0 else "spacelike"


def closes_in_product(velocity: Velocity, tol: float = 1e-10) -> bool:
    """Test unit-period closure in real time crossed with the three-torus."""
    return isclose(velocity.time, 0.0, abs_tol=tol) and all(
        is_integral(component, tol) for component in velocity.space
    )


def closes_with_compact_time(velocity: Velocity, tol: float = 1e-10) -> bool:
    """Test unit-period closure when time and all spatial coordinates are modulo one."""
    return is_integral(velocity.time, tol) and all(
        is_integral(component, tol) for component in velocity.space
    )


def wrapping_vectors(bound: int) -> Iterable[IntegerVector3]:
    """Generate all nonzero integer wrapping vectors in the cube [-bound,bound]^3."""
    if bound < 0:
        raise ValueError("bound must be nonnegative")
    for vector in product(range(-bound, bound + 1), repeat=3):
        if vector != (0, 0, 0):
            yield vector


def main() -> None:
    """Run three demonstrations of the central results."""
    direction = (2, -1, 3)
    points = sample_geodesic(direction, samples=12)
    print("TOROIDAL GEODESIC")
    print(f"direction: {direction}")
    print(f"start: {points[0]}; endpoint after one period: {points[-1]}")
    print(f"closed: {same_torus_point(points[0], points[-1])}")
    print(f"nonconstant witness at t=1/4: {torus_point(direction, 0.25)}")

    product_loop = Velocity(0.0, (1.0, 0.0, 0.0))
    timelike_motion = Velocity(1.0, (0.0, 0.0, 0.0))
    print("\nCAUSAL CONTRAST")
    for name, velocity in (("spatial wrapping", product_loop),
                           ("unit time motion", timelike_motion)):
        print(
            f"{name}: q={lorentzian_norm_squared(velocity):.1f}, "
            f"type={causal_type(velocity)}, "
            f"closes in R x T^3={closes_in_product(velocity)}, "
            f"closes in compact time={closes_with_compact_time(velocity)}"
        )

    bound = 2
    vectors = list(wrapping_vectors(bound))
    expected = (2 * bound + 1) ** 3 - 1
    print("\nWRAPPING LATTICE")
    print(f"nonzero vectors in [-{bound},{bound}]^3: {len(vectors)} (expected {expected})")
    print(f"first ten: {vectors[:10]}")


if __name__ == "__main__":
    main()
