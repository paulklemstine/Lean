#!/usr/bin/env python3
"""Numerical audits for equal geodesic-cap packings on the unit two-sphere."""

from __future__ import annotations

from dataclasses import dataclass
from math import acos, cos, degrees, floor, pi, sin, sqrt
from typing import Iterable, Sequence

Vector = tuple[float, float, float]


@dataclass(frozen=True)
class RadiusAudit:
    """Computed bounds and distortion data for one cap radius."""

    radius_radians: float
    radius_degrees: float
    cap_area: float
    area_bound: float
    integer_area_bound: int
    proposed_correction: float | None
    proposed_bound: float | None


def cap_area(radius: float) -> float:
    """Return the surface area 2π(1-cos r) of a unit-sphere cap."""
    if not 0.0 <= radius <= pi:
        raise ValueError("radius must lie in [0, π]")
    # The half-angle formula is stable when radius is small.
    return 4.0 * pi * sin(radius / 2.0) ** 2


def direct_area_bound(radius: float) -> float:
    """Return 2/(1-cos r), the direct real-valued packing bound."""
    if not 0.0 < radius < pi:
        raise ValueError("radius must lie in (0, π)")
    return 1.0 / sin(radius / 2.0) ** 2


def proposed_correction(radius: float) -> float:
    """Return (2/cos r)^2 where it is finite."""
    c = cos(radius)
    if abs(c) < 1e-15:
        raise ValueError("correction is singular when cos(radius) = 0")
    return (2.0 / c) ** 2


def audit_radius(radius: float) -> RadiusAudit:
    """Compute intrinsic and proposed bounds for one radius."""
    area_bound = direct_area_bound(radius)
    correction: float | None = None
    corrected_bound: float | None = None
    if radius < pi / 2.0:
        correction = proposed_correction(radius)
        corrected_bound = correction * area_bound
    return RadiusAudit(
        radius_radians=radius,
        radius_degrees=degrees(radius),
        cap_area=cap_area(radius),
        area_bound=area_bound,
        integer_area_bound=floor(area_bound + 1e-12),
        proposed_correction=correction,
        proposed_bound=corrected_bound,
    )


def dot(u: Vector, v: Vector) -> float:
    """Euclidean inner product in R^3."""
    return sum(x * y for x, y in zip(u, v))


def normalize(v: Vector) -> Vector:
    """Normalize a nonzero vector."""
    norm = sqrt(dot(v, v))
    if norm == 0.0:
        raise ValueError("cannot normalize the zero vector")
    return tuple(x / norm for x in v)  # type: ignore[return-value]


def minimum_angular_separation(centers: Sequence[Vector]) -> float:
    """Return the minimum pairwise angular separation in radians."""
    if len(centers) < 2:
        return pi
    unit = [normalize(v) for v in centers]
    minimum = pi
    for i, u in enumerate(unit):
        for v in unit[i + 1 :]:
            angle = acos(max(-1.0, min(1.0, dot(u, v))))
            minimum = min(minimum, angle)
    return minimum


def supports_open_caps(centers: Sequence[Vector], radius: float, tolerance: float = 1e-12) -> bool:
    """Test whether centers support open caps of the requested radius."""
    return minimum_angular_separation(centers) + tolerance >= 2.0 * radius


def tetrahedron_centers() -> list[Vector]:
    """Return four unit vectors at the vertices of a regular tetrahedron."""
    raw = [(1.0, 1.0, 1.0), (1.0, -1.0, -1.0), (-1.0, 1.0, -1.0), (-1.0, -1.0, 1.0)]
    return [normalize(v) for v in raw]


def octahedron_centers() -> list[Vector]:
    """Return the six vertices of a regular octahedron."""
    return [(1.0, 0.0, 0.0), (-1.0, 0.0, 0.0), (0.0, 1.0, 0.0),
            (0.0, -1.0, 0.0), (0.0, 0.0, 1.0), (0.0, 0.0, -1.0)]


def equatorial_triangle_centers() -> list[Vector]:
    """Return three equatorial centers separated by 120 degrees."""
    return [(cos(2.0 * pi * k / 3.0), sin(2.0 * pi * k / 3.0), 0.0) for k in range(3)]


def print_table(audits: Iterable[RadiusAudit]) -> None:
    """Print a readable comparison table."""
    print("radius   cap area   area bound  floor  correction  proposed bound")
    for a in audits:
        correction = "n/a" if a.proposed_correction is None else f"{a.proposed_correction:10.4f}"
        proposed = "n/a" if a.proposed_bound is None else f"{a.proposed_bound:14.4f}"
        print(f"{a.radius_degrees:5.1f}°  {a.cap_area:8.4f}  {a.area_bound:10.4f}  "
              f"{a.integer_area_bound:5d}  {correction:>10}  {proposed:>14}")


def main() -> None:
    """Demonstrate the bounds and corrected polyhedral radii."""
    print("Spherical cap area and upper-bound audit")
    print_table(audit_radius(r) for r in (pi / 6.0, pi / 4.0, pi / 3.0))

    tetra = tetrahedron_centers()
    tetra_angle = minimum_angular_separation(tetra)
    tetra_radius = tetra_angle / 2.0
    print("\nTetrahedral audit")
    print(f"minimum center angle: {degrees(tetra_angle):.6f}°")
    print(f"maximum tangent open-cap radius: {degrees(tetra_radius):.6f}°")
    print(f"supports radius 60°: {supports_open_caps(tetra, pi / 3.0)}")
    print(f"pairwise inner product: {dot(tetra[0], tetra[1]):.6f} (required at 60°: <= -0.5)")

    octa = octahedron_centers()
    triangle = equatorial_triangle_centers()
    print("\nMatching constructions")
    print(f"octahedron: {len(octa)} centers, minimum angle "
          f"{degrees(minimum_angular_separation(octa)):.1f}°, supports 45° caps: "
          f"{supports_open_caps(octa, pi / 4.0)}")
    print(f"equatorial triangle: {len(triangle)} centers, minimum angle "
          f"{degrees(minimum_angular_separation(triangle)):.1f}°, supports 60° caps: "
          f"{supports_open_caps(triangle, pi / 3.0)}")

    print("\nNormalization check")
    print(f"proposed correction at zero: {proposed_correction(0.0):.1f}")
    print("A correction of the form 1 + O(r²) would instead approach 1.")


if __name__ == "__main__":
    main()
