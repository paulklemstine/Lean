#!/usr/bin/env python3
"""Numerical demonstrations for inverse stereographic neural-field geometry.

The script uses only the Python standard library.  It checks the sphere identity,
illustrates radial decay versus convergence to the north-pole value, and prints
the spherical-harmonic multiplicities for the first reciprocal radii.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import comb
from typing import Iterable, Sequence


@dataclass(frozen=True)
class SpherePoint:
    """A point represented by three Cartesian coordinates."""

    x: float
    y: float
    z: float


def inverse_stereographic(x: float, y: float) -> SpherePoint:
    """Map a finite planar point to the unit sphere minus its north pole."""
    radius_squared = x * x + y * y
    denominator = 1.0 + radius_squared
    return SpherePoint(
        x=2.0 * x / denominator,
        y=2.0 * y / denominator,
        z=(radius_squared - 1.0) / denominator,
    )


def sphere_residual(point: SpherePoint) -> float:
    """Return the absolute residual in X^2 + Y^2 + Z^2 = 1."""
    return abs(point.x * point.x + point.y * point.y + point.z * point.z - 1.0)


def harmonic_multiplicity(k: int) -> int:
    """Return the dimension 2k+1 of degree-k harmonics on the two-sphere."""
    if k < 0:
        raise ValueError("The harmonic degree k must be nonnegative.")
    return 2 * k + 1


def binomial_multiplicity(k: int) -> int:
    """Evaluate C(k+2,2)-C(k,2), interpreting C(k,2)=0 for k<2."""
    if k < 0:
        raise ValueError("The harmonic degree k must be nonnegative.")
    return comb(k + 2, 2) - (comb(k, 2) if k >= 2 else 0)


def projection_table(points: Iterable[tuple[float, float]]) -> list[str]:
    """Format projection coordinates and sphere residuals for planar points."""
    rows = []
    for x, y in points:
        point = inverse_stereographic(x, y)
        rows.append(
            f"({x:7.2f}, {y:7.2f}) -> "
            f"({point.x: .8f}, {point.y: .8f}, {point.z: .8f}); "
            f"sphere residual={sphere_residual(point):.3e}"
        )
    return rows


def radial_table(radii: Sequence[float]) -> list[str]:
    """Compare exact radial values with their decay and error formulas."""
    rows = []
    for radius in radii:
        if radius < 1.0:
            raise ValueError("Decay-bound diagnostics require radii R >= 1.")
        point = inverse_stereographic(radius, 0.0)
        x_bound = 2.0 / radius
        z_error_formula = 2.0 / (1.0 + radius * radius)
        rows.append(
            f"R={radius:6.1f}: X={point.x: .10f}, 2/R={x_bound:.10f}, "
            f"|1-Z|={abs(1.0-point.z):.10f}, "
            f"2/(1+R^2)={z_error_formula:.10f}"
        )
    return rows


def multiplicity_table(degrees: Sequence[int]) -> list[str]:
    """Show agreement of direct and binomial dimension formulas."""
    rows = []
    for k in degrees:
        direct = harmonic_multiplicity(k)
        binomial = binomial_multiplicity(k)
        radius = "undefined" if k == 0 else f"1/{k}"
        rows.append(
            f"k={k}: radius={radius:>9}, 2k+1={direct}, "
            f"binomial difference={binomial}"
        )
    return rows


def main() -> None:
    """Run all demonstrations and assert the exact numerical relationships."""
    points = [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (3.0, -4.0), (100.0, 0.0)]
    print("INVERSE STEREOGRAPHIC PROJECTION")
    for row in projection_table(points):
        print(row)
    assert all(sphere_residual(inverse_stereographic(x, y)) < 1e-12 for x, y in points)

    radii = [1.0, 2.0, 5.0, 10.0, 100.0]
    print("\nRADIAL ASYMPTOTICS")
    for row in radial_table(radii):
        print(row)
    for radius in radii:
        point = inverse_stereographic(radius, 0.0)
        assert abs(point.x) <= 2.0 / radius + 1e-15
        expected_error = 2.0 / (1.0 + radius * radius)
        assert abs(abs(1.0 - point.z) - expected_error) < 1e-14

    print("\nSPHERICAL-HARMONIC MULTIPLICITIES")
    for row in multiplicity_table([1, 2, 3]):
        print(row)
    assert [harmonic_multiplicity(k) for k in (1, 2, 3)] == [3, 5, 7]
    assert all(harmonic_multiplicity(k) == binomial_multiplicity(k) for k in range(20))

    print("\nAll numerical diagnostics passed.")
    print("These checks concern geometry and mode dimension, not nonlinear stability.")


if __name__ == "__main__":
    main()
