#!/usr/bin/env python3
"""Numerical demonstrations for the pointwise Alcubierre shift model.

Uses only the Python standard library. Quantities are in units with c = 1.
"""
from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Iterable, Sequence

Vector4 = tuple[float, float, float, float]


def local_frame(beta: float, x: Vector4) -> Vector4:
    """Apply the longitudinal shear from chart to local-frame components."""
    return (x[0], x[1] - beta * x[0], x[2], x[3])


def from_local_frame(beta: float, u: Vector4) -> Vector4:
    """Invert the longitudinal shear."""
    return (u[0], u[1] + beta * u[0], u[2], u[3])


def metric_q(beta: float, x: Vector4) -> float:
    """Evaluate Q_beta(x) = -t^2 + (x-beta*t)^2 + y^2 + z^2."""
    u = local_frame(beta, x)
    return -u[0] ** 2 + u[1] ** 2 + u[2] ** 2 + u[3] ** 2


def bubble_time(beta: float) -> Vector4:
    """Return the unit timelike direction comoving with the bubble."""
    return (1.0, beta, 0.0, 0.0)


def causal_diagnostic(beta: float, x: Vector4, tolerance: float = 1e-12) -> tuple[bool, float]:
    """Return future-causality and longitudinal peculiar-speed magnitude."""
    if x[0] <= 0.0:
        return (False, float("inf"))
    peculiar = abs(x[1] / x[0] - beta)
    return (metric_q(beta, x) <= tolerance, peculiar)


def longitudinal_expansion(speed: float, shape_derivative: float) -> float:
    """Evaluate the expansion sign model speed times profile derivative."""
    return speed * shape_derivative


def energy_density(kappa: float, speed: float, dy: float, dz: float) -> float:
    """Evaluate rho = -kappa * speed^2 * (dy^2 + dz^2)."""
    return -kappa * speed**2 * (dy**2 + dz**2)


def sampled_energy(
    kappa: float,
    speed: float,
    weights: Sequence[float],
    dy: Sequence[float],
    dz: Sequence[float],
) -> float:
    """Compute a finite weighted quadrature of the density."""
    if not (len(weights) == len(dy) == len(dz)):
        raise ValueError("weights, dy, and dz must have equal lengths")
    return sum(w * energy_density(kappa, speed, gy, gz) for w, gy, gz in zip(weights, dy, dz))


def chronology_audit(times: Iterable[float]) -> bool:
    """Return whether every adjacent event strictly increases global time."""
    values = list(times)
    return len(values) > 1 and all(a < b for a, b in zip(values, values[1:]))


@dataclass(frozen=True)
class DemoResult:
    name: str
    passed: bool
    detail: str


def run_demo() -> list[DemoResult]:
    """Run reproducible checks of shear, causality, energy, and chronology."""
    results: list[DemoResult] = []

    beta = 2.5
    x: Vector4 = (2.0, 5.5, 0.3, -0.4)
    recovered = from_local_frame(beta, local_frame(beta, x))
    results.append(DemoResult("invertible shear", recovered == x, f"X={x}, recovered={recovered}"))

    comoving = bubble_time(beta)
    causal, peculiar = causal_diagnostic(beta, comoving)
    results.append(DemoResult(
        "coordinate-superluminal timelike motion",
        causal and beta > 1.0 and isclose(metric_q(beta, comoving), -1.0) and isclose(peculiar, 0.0),
        f"beta={beta}, coordinate speed={beta}, Q={metric_q(beta, comoving)}, peculiar={peculiar}",
    ))

    causal_edge: Vector4 = (1.0, beta + 0.8, 0.6, 0.0)
    edge_is_causal, edge_peculiar = causal_diagnostic(beta, causal_edge)
    results.append(DemoResult(
        "local causal bound",
        edge_is_causal and edge_peculiar <= 1.0 + 1e-12,
        f"Q={metric_q(beta, causal_edge):.6g}, |dx/dt-beta|={edge_peculiar:.6g}",
    ))

    rear = longitudinal_expansion(2.0, 0.4)
    front = longitudinal_expansion(2.0, -0.3)
    results.append(DemoResult("expansion and contraction signs", rear > 0.0 > front, f"rear={rear}, front={front}"))

    densities = [energy_density(1.0, v, 3.0, 4.0) for v in (0.0, 1.0, 2.0, 3.0)]
    results.append(DemoResult("negative density and quadratic scaling", densities == [0.0, -25.0, -100.0, -225.0], f"rho={densities}"))

    weights = [0.2, 0.3, 0.5]
    dys = [1.0, -2.0, 0.5]
    dzs = [0.0, 1.0, -1.5]
    base = sampled_energy(0.7, 1.2, weights, dys, dzs)
    scaled = sampled_energy(0.7, 3.0 * 1.2, weights, dys, dzs)
    results.append(DemoResult(
        "sampled energy scaling",
        base <= 0.0 and isclose(scaled, 9.0 * base),
        f"E(v)={base:.6g}, E(3v)={scaled:.6g}, ratio={scaled / base:.6g}",
    ))

    times = [0.0, 0.7, 1.4, 3.0]
    results.append(DemoResult(
        "strict-time chronology audit",
        chronology_audit(times) and times[-1] > times[0],
        f"times={times}; a strictly increasing chain cannot return to its initial event",
    ))
    return results


def main() -> None:
    results = run_demo()
    print("Alcubierre shift geometry numerical demonstrations (c = 1)\n")
    for result in results:
        status = "PASS" if result.passed else "FAIL"
        print(f"[{status}] {result.name}: {result.detail}")
    if not all(result.passed for result in results):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
