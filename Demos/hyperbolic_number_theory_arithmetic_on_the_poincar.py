#!/usr/bin/env python3
"""Numerical demonstrations for the modular translation orbit in the Poincare disk."""

from __future__ import annotations

import argparse
import cmath
import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable


@dataclass(frozen=True)
class OrbitSample:
    """Computed data for one integer index."""

    index: int
    point: complex
    radius_squared_exact: Fraction
    boundary_defect_exact: Fraction
    hyperbolic_distance: float


def modular_orbit(n: int) -> complex:
    """Return p_n = n / (n + 2i)."""
    return n / complex(n, 2)


def exact_radius_squared(n: int) -> Fraction:
    """Return |p_n|^2 exactly as n^2/(n^2+4)."""
    return Fraction(n * n, n * n + 4)


def exact_boundary_defect(n: int) -> Fraction:
    """Return 1-|p_n|^2 exactly, avoiding floating-point cancellation."""
    return Fraction(4, n * n + 4)


def hyperbolic_distance(n: int) -> float:
    """Return the disk distance d(0,p_n) = 2 asinh(|n|/2)."""
    return 2.0 * math.asinh(abs(n) / 2.0)


def orbit_sample(n: int) -> OrbitSample:
    """Collect exact and numerical data for an index."""
    return OrbitSample(
        index=n,
        point=modular_orbit(n),
        radius_squared_exact=exact_radius_squared(n),
        boundary_defect_exact=exact_boundary_defect(n),
        hyperbolic_distance=hyperbolic_distance(n),
    )


def cutoff_indices(N: int) -> range:
    """Return exactly the indices in the radial cutoff through p_N."""
    if N < 0:
        raise ValueError("N must be nonnegative")
    return range(-N, N + 1)


def cutoff_count(N: int) -> int:
    """Return the exact number 2N+1 of points in the endpoint cutoff."""
    if N < 0:
        raise ValueError("N must be nonnegative")
    return 2 * N + 1


def count_within_hyperbolic_radius(radius: float) -> int:
    """Count orbit points at intrinsic distance at most radius."""
    if radius < 0:
        raise ValueError("radius must be nonnegative")
    bound = math.floor(2.0 * math.sinh(radius / 2.0) + 1e-12)
    return 2 * bound + 1


def verify_identities(indices: Iterable[int]) -> None:
    """Numerically check radius, reflection, defect, and distance identities."""
    for n in indices:
        p = modular_orbit(n)
        expected_r2 = float(exact_radius_squared(n))
        assert math.isclose(abs(p) ** 2, expected_r2, rel_tol=1e-12, abs_tol=1e-12)
        assert math.isclose(
            1.0 - expected_r2,
            float(exact_boundary_defect(n)),
            rel_tol=1e-12,
            abs_tol=1e-12,
        )
        assert cmath.isclose(modular_orbit(-n), p.conjugate(), rel_tol=1e-12, abs_tol=1e-12)
        disk_distance = 2.0 * math.atanh(abs(p)) if n != 0 else 0.0
        assert math.isclose(disk_distance, hyperbolic_distance(n), rel_tol=1e-12)


def print_table(N: int) -> None:
    """Print an explanatory table for indices from -N through N."""
    print("Modular orbit p_n = n/(n+2i)")
    print(" n |       Re(p_n)       Im(p_n) | exact |p_n|^2 | defect | distance")
    print("---+-----------------------------+---------------+--------+---------")
    for n in cutoff_indices(N):
        sample = orbit_sample(n)
        print(
            f"{n:3d} | {sample.point.real:13.9f} {sample.point.imag:13.9f} | "
            f"{str(sample.radius_squared_exact):>13} | "
            f"{str(sample.boundary_defect_exact):>6} | "
            f"{sample.hyperbolic_distance:7.4f}"
        )
    print(f"\nEndpoint cutoff count: {cutoff_count(N)} = 2({N})+1")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-N", type=int, default=5, help="nonnegative endpoint index")
    parser.add_argument(
        "--hyperbolic-radius", type=float, default=4.0, help="radius for intrinsic count"
    )
    args = parser.parse_args()
    if args.N < 0:
        parser.error("-N must be nonnegative")
    if args.hyperbolic_radius < 0:
        parser.error("--hyperbolic-radius must be nonnegative")

    verify_identities(range(-max(args.N, 20), max(args.N, 20) + 1))
    print_table(args.N)
    print(
        f"Points within hyperbolic radius {args.hyperbolic_radius:g}: "
        f"{count_within_hyperbolic_radius(args.hyperbolic_radius)}"
    )
    print("All numerical identity checks passed.")


if __name__ == "__main__":
    main()
