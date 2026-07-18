#!/usr/bin/env python3
"""Numerical demonstrations for the anisotropic split metric.

The script uses only the Python standard library.  It checks the Gram determinant
identity, frame independence of sectional curvature, the curvature sign on a
grid, and the metric area of a rectangle.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import atan, cosh, isclose, pi, sinh, tanh
from random import Random
from typing import Iterable, Tuple

Vector = Tuple[float, float]
Point = Tuple[float, float]


@dataclass(frozen=True)
class FrameReport:
    """Computed invariants for one point and one tangent frame."""

    point: Point
    wedge: float
    gram_direct: float
    gram_factored: float
    gaussian_curvature: float
    sectional_curvature: float


def gaussian_curvature(x: float, y: float) -> float:
    """Return K(x,y) for the split metric."""
    cx, cy, sy = cosh(x), cosh(y), sinh(y)
    return -(cy * cy) + (1.0 - sy * sy) / ((cx * cx) * (cy * cy))


def metric_inner(point: Point, u: Vector, v: Vector) -> float:
    """Return the metric inner product g_p(u,v)."""
    x, y = point
    return u[0] * v[0] / cosh(y) ** 2 + cosh(x) ** 2 * u[1] * v[1]


def wedge(u: Vector, v: Vector) -> float:
    """Return the oriented coordinate area u_1 v_2-u_2 v_1."""
    return u[0] * v[1] - u[1] * v[0]


def metric_determinant(point: Point) -> float:
    """Return det(g) = cosh(x)^2/cosh(y)^2."""
    x, y = point
    return cosh(x) ** 2 / cosh(y) ** 2


def gram_determinant(point: Point, u: Vector, v: Vector) -> float:
    """Compute squared metric area directly from metric inner products."""
    return (
        metric_inner(point, u, u) * metric_inner(point, v, v)
        - metric_inner(point, u, v) ** 2
    )


def curvature4_self(point: Point, u: Vector, v: Vector) -> float:
    """Evaluate R_p(u,v,u,v) using the reconstructed curvature tensor."""
    return gaussian_curvature(*point) * gram_determinant(point, u, v)


def sectional_curvature(point: Point, u: Vector, v: Vector) -> float:
    """Compute the sectional quotient for a nondegenerate frame."""
    gram = gram_determinant(point, u, v)
    if abs(wedge(u, v)) <= 1e-12:
        raise ValueError("The tangent frame is degenerate or numerically unstable.")
    return curvature4_self(point, u, v) / gram


def analyze_frame(point: Point, u: Vector, v: Vector) -> FrameReport:
    """Compare direct and factored frame invariants."""
    area = wedge(u, v)
    if abs(area) <= 1e-12:
        raise ValueError("Choose nonparallel vectors.")
    direct = gram_determinant(point, u, v)
    factored = metric_determinant(point) * area * area
    return FrameReport(
        point=point,
        wedge=area,
        gram_direct=direct,
        gram_factored=factored,
        gaussian_curvature=gaussian_curvature(*point),
        sectional_curvature=sectional_curvature(point, u, v),
    )


def curvature_grid(
    x_min: float, x_max: float, y_min: float, y_max: float, steps: int
) -> Iterable[Tuple[Point, float]]:
    """Yield curvature samples on a square grid including both endpoints."""
    if steps < 2:
        raise ValueError("steps must be at least 2")
    for i in range(steps):
        x = x_min + (x_max - x_min) * i / (steps - 1)
        for j in range(steps):
            y = y_min + (y_max - y_min) * j / (steps - 1)
            yield (x, y), gaussian_curvature(x, y)


def sech_integral(y: float) -> float:
    """An antiderivative of sech(y), normalized to vanish at zero."""
    return 2.0 * atan(tanh(y / 2.0))


def rectangle_area(a: float, b: float, c: float, d: float) -> float:
    """Exact floating-point evaluation of metric area on [a,b] x [c,d]."""
    horizontal = sinh(b) - sinh(a)
    vertical = sech_integral(d) - sech_integral(c)
    return horizontal * vertical


def main() -> None:
    """Run deterministic demonstrations and assert the predicted identities."""
    print("Intrinsic curvature demonstrations for the split metric\n")

    sample_points = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, -0.75)]
    print("Curvature samples:")
    for point in sample_points:
        value = gaussian_curvature(*point)
        print(f"  K{point} = {value: .10f}")
        assert value <= 1e-12
        if point == (0.0, 0.0):
            assert isclose(value, 0.0, abs_tol=1e-12)
        else:
            assert value < 0.0
    print(f"  horizontal-axis check: K(1,0) = -tanh(1)^2 = {-tanh(1.0) ** 2:.10f}\n")

    print("Frame-independence samples at p=(0.7,-0.4):")
    point = (0.7, -0.4)
    frames = [
        ((1.0, 0.0), (0.0, 1.0)),
        ((2.0, -1.0), (0.5, 3.0)),
        ((-1.2, 2.5), (3.1, 0.4)),
    ]
    for u, v in frames:
        report = analyze_frame(point, u, v)
        print(
            f"  wedge={report.wedge: .4f}, "
            f"Gram={report.gram_direct: .10f}, "
            f"det(g)*wedge^2={report.gram_factored: .10f}, "
            f"Sec={report.sectional_curvature: .10f}"
        )
        assert isclose(report.gram_direct, report.gram_factored, rel_tol=1e-10)
        assert isclose(
            report.sectional_curvature,
            report.gaussian_curvature,
            rel_tol=1e-10,
            abs_tol=1e-12,
        )

    rng = Random(20260718)
    worst_error = 0.0
    for _ in range(200):
        p = (rng.uniform(-2.0, 2.0), rng.uniform(-2.0, 2.0))
        u = (rng.uniform(-3.0, 3.0), rng.uniform(-3.0, 3.0))
        v = (rng.uniform(-3.0, 3.0), rng.uniform(-3.0, 3.0))
        if abs(wedge(u, v)) < 0.1:
            continue
        report = analyze_frame(p, u, v)
        scale = max(1.0, abs(report.gram_factored))
        worst_error = max(worst_error, abs(report.gram_direct - report.gram_factored) / scale)
    print(f"\nWorst relative Gram-identity error in random test: {worst_error:.3e}")

    samples = list(curvature_grid(-2.0, 2.0, -2.0, 2.0, 41))
    maximum_point, maximum_value = max(samples, key=lambda item: item[1])
    minimum_point, minimum_value = min(samples, key=lambda item: item[1])
    print(f"Grid maximum: K{maximum_point} = {maximum_value:.10f}")
    print(f"Grid minimum: K{minimum_point} = {minimum_value:.10f}")
    assert maximum_point == (0.0, 0.0)
    assert isclose(maximum_value, 0.0, abs_tol=1e-12)

    area = rectangle_area(-1.0, 1.0, -0.5, 0.5)
    print(f"\nMetric area of [-1,1] x [-0.5,0.5]: {area:.10f}")
    print("All numerical demonstrations passed.")


if __name__ == "__main__":
    main()
