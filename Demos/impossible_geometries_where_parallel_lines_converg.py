#!/usr/bin/env python3
"""Numerical demonstrations for the anisotropic split-metric curvature.

Uses only the Python standard library. It evaluates the exact curvature formula,
audits its sign on a grid, compares it with the schematic diagonal phase field,
computes coordinate-region areas, and integrates sample geodesics with RK4.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import atan, cosh, exp, isfinite, sinh, tanh
from typing import Callable, Iterable, Sequence


def sech_sq(t: float) -> float:
    """Return sech(t)^2 using a stable expression for large |t|."""
    q = exp(-2.0 * abs(t))
    return 4.0 * q / ((1.0 + q) ** 2)


def gaussian_curvature(x: float, y: float) -> float:
    """Evaluate K = -cosh(y)^2 - sech(x)^2 + 2 sech(x)^2 sech(y)^2."""
    try:
        cy2 = cosh(y) ** 2
    except OverflowError:
        return float("-inf")
    a, b = sech_sq(x), sech_sq(y)
    return -cy2 - a + 2.0 * a * b


def phase_field(x: float, y: float) -> float:
    """Evaluate the schematic field P = sech(x)^2 - sech(y)^2."""
    return sech_sq(x) - sech_sq(y)


def area_density(x: float, y: float) -> float:
    """Evaluate sqrt(det g) = cosh(x)/cosh(y)."""
    return cosh(x) / cosh(y)


def rectangle_area(x0: float, x1: float, y0: float, y1: float) -> float:
    """Exact metric area of a coordinate rectangle."""
    return (sinh(x1) - sinh(x0)) * (atan(sinh(y1)) - atan(sinh(y0)))


def simpson(f: Callable[[float], float], a: float, b: float, n: int = 2000) -> float:
    """Composite Simpson quadrature with an even number of panels."""
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2:
        n += 1
    h = (b - a) / n
    total = f(a) + f(b)
    for i in range(1, n):
        total += (4.0 if i % 2 else 2.0) * f(a + i * h)
    return total * h / 3.0


def coordinate_triangle_area(length: float, panels: int = 2000) -> float:
    """Area of {(x,y): 0 <= x <= L, 0 <= y <= L-x}."""
    if length < 0.0:
        raise ValueError("length must be nonnegative")
    return simpson(
        lambda x: cosh(x) * atan(sinh(length - x)), 0.0, length, panels
    )


@dataclass(frozen=True)
class GridAudit:
    minimum: float
    maximum: float
    maximum_point: tuple[float, float]
    positive_samples: int
    diagonal_samples: int
    negative_nonorigin_diagonal_samples: int


def audit_grid(bound: float = 3.0, steps: int = 121, tolerance: float = 1e-12) -> GridAudit:
    """Audit curvature and the phase-field diagonal zero set on a square grid."""
    if bound <= 0.0 or steps < 3:
        raise ValueError("bound must be positive and steps at least 3")
    values = [-bound + 2.0 * bound * i / (steps - 1) for i in range(steps)]
    minimum = float("inf")
    maximum = float("-inf")
    maximum_point = (0.0, 0.0)
    positive = diagonal = negative_diagonal = 0
    for x in values:
        for y in values:
            k = gaussian_curvature(x, y)
            if k < minimum:
                minimum = k
            if k > maximum:
                maximum, maximum_point = k, (x, y)
            if k > tolerance:
                positive += 1
            if abs(phase_field(x, y)) <= tolerance:
                diagonal += 1
                if abs(x) + abs(y) > tolerance and k < -tolerance:
                    negative_diagonal += 1
    return GridAudit(minimum, maximum, maximum_point, positive, diagonal, negative_diagonal)


State = tuple[float, float, float, float]


def geodesic_rhs(state: State) -> State:
    """First-order affine geodesic system for (x, y, dx/ds, dy/ds)."""
    x, y, u, v = state
    du = 2.0 * tanh(y) * u * v + cosh(x) ** 2 * cosh(y) ** 2 * tanh(x) * v * v
    dv = -sech_sq(x) * sech_sq(y) * tanh(y) * u * u - 2.0 * tanh(x) * u * v
    return (u, v, du, dv)


def add_scaled(a: State, b: State, scale: float) -> State:
    return tuple(a[i] + scale * b[i] for i in range(4))  # type: ignore[return-value]


def rk4_step(state: State, step: float) -> State:
    """Advance the geodesic state by one classical RK4 step."""
    k1 = geodesic_rhs(state)
    k2 = geodesic_rhs(add_scaled(state, k1, step / 2.0))
    k3 = geodesic_rhs(add_scaled(state, k2, step / 2.0))
    k4 = geodesic_rhs(add_scaled(state, k3, step))
    return tuple(
        state[i] + step * (k1[i] + 2.0 * k2[i] + 2.0 * k3[i] + k4[i]) / 6.0
        for i in range(4)
    )  # type: ignore[return-value]


def geodesic_energy(state: State) -> float:
    """Return the conserved affine energy of a geodesic state."""
    x, y, u, v = state
    return 0.5 * (sech_sq(y) * u * u + cosh(x) ** 2 * v * v)


def sign(value: float, tolerance: float = 1e-10) -> int:
    return 1 if value > tolerance else (-1 if value < -tolerance else 0)


def integrate_geodesic(initial: State, step: float = 0.002, count: int = 1500) -> tuple[State, int, int, float]:
    """Integrate a sample geodesic and report diagonal crossings and energy drift."""
    state = initial
    e0 = geodesic_energy(state)
    previous_minus = sign(state[1] - state[0])
    previous_plus = sign(state[1] + state[0])
    crossings_minus = crossings_plus = 0
    for _ in range(count):
        state = rk4_step(state, step)
        if not all(isfinite(z) for z in state):
            break
        current_minus = sign(state[1] - state[0])
        current_plus = sign(state[1] + state[0])
        if previous_minus and current_minus and previous_minus != current_minus:
            crossings_minus += 1
        if previous_plus and current_plus and previous_plus != current_plus:
            crossings_plus += 1
        if current_minus:
            previous_minus = current_minus
        if current_plus:
            previous_plus = current_plus
    e1 = geodesic_energy(state) if all(isfinite(z) for z in state) else float("inf")
    drift = abs(e1 - e0) / max(abs(e0), 1e-15)
    return state, crossings_minus, crossings_plus, drift


def print_landmarks(points: Iterable[tuple[float, float]]) -> None:
    print("Curvature landmarks")
    print("       x        y                 K                 P")
    for x, y in points:
        print(f"{x:8.3f} {y:8.3f} {gaussian_curvature(x,y):17.10f} {phase_field(x,y):17.10f}")


def main() -> None:
    print_landmarks([(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (1.0, -1.0), (2.0, 0.5)])

    audit = audit_grid()
    print("\nGrid audit on [-3,3]^2")
    print(f"  sampled minimum curvature: {audit.minimum:.10f}")
    print(f"  sampled maximum curvature: {audit.maximum:.10f} at {audit.maximum_point}")
    print(f"  positive samples: {audit.positive_samples}")
    print(f"  phase-field-zero samples: {audit.diagonal_samples}")
    print(f"  negative non-origin phase-field-zero samples: {audit.negative_nonorigin_diagonal_samples}")

    print("\nMetric areas")
    print(f"  rectangle [-1,1] x [-1,1]: {rectangle_area(-1.0, 1.0, -1.0, 1.0):.10f}")
    print(f"  coordinate triangle T_1:   {coordinate_triangle_area(1.0):.10f}")

    initial: State = (-0.5, 0.2, 0.9, 0.35)
    final, cross_minus, cross_plus, drift = integrate_geodesic(initial)
    print("\nSample RK4 geodesic (exploratory, not a crossing theorem)")
    print(f"  initial state: {initial}")
    print(f"  final state:   {tuple(round(z, 8) for z in final)}")
    print(f"  crossings of y=x: {cross_minus}; crossings of y=-x: {cross_plus}")
    print(f"  relative energy drift: {drift:.3e}")


if __name__ == "__main__":
    main()
