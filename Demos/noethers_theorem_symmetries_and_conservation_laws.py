#!/usr/bin/env python3
"""Numerical demonstrations of Noether charges and Kepler invariants.

Only the Python standard library is required. The script checks exact sampled
motions, verifies the Runge--Lenz conic identity, and integrates an elliptic
Kepler orbit with velocity Verlet while reporting invariant drift.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, pi, sin, sqrt
from typing import Callable, Iterable, Sequence

Vec3 = tuple[float, float, float]


def add(a: Vec3, b: Vec3) -> Vec3:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def sub(a: Vec3, b: Vec3) -> Vec3:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def scale(c: float, a: Vec3) -> Vec3:
    return (c * a[0], c * a[1], c * a[2])


def dot(a: Vec3, b: Vec3) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def cross(a: Vec3, b: Vec3) -> Vec3:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def norm(a: Vec3) -> float:
    return sqrt(dot(a, a))


def max_vec_error(values: Sequence[Vec3]) -> float:
    base = values[0]
    return max(norm(sub(value, base)) for value in values)


def noether_charge(p: Vec3, xi: Vec3, boundary: float) -> float:
    """Return J = p dot xi - B."""
    return dot(p, xi) - boundary


def kepler_energy(mu: float, q: Vec3, v: Vec3) -> float:
    return 0.5 * dot(v, v) - mu / norm(q)


def angular_momentum(q: Vec3, v: Vec3) -> Vec3:
    return cross(q, v)


def runge_lenz(mu: float, q: Vec3, v: Vec3) -> Vec3:
    radius = norm(q)
    return sub(cross(v, cross(q, v)), scale(mu / radius, q))


def conic_bridge_residual(mu: float, q: Vec3, v: Vec3) -> float:
    """Return A dot q - (|q x v|^2 - mu |q|), theoretically zero."""
    a = runge_lenz(mu, q, v)
    ell = angular_momentum(q, v)
    return dot(a, q) - (dot(ell, ell) - mu * norm(q))


def acceleration(mu: float, q: Vec3) -> Vec3:
    radius = norm(q)
    if radius == 0.0:
        raise ValueError("Kepler acceleration is undefined at collision")
    return scale(-mu / radius**3, q)


@dataclass(frozen=True)
class State:
    time: float
    position: Vec3
    velocity: Vec3


def velocity_verlet(
    mu: float, q0: Vec3, v0: Vec3, step: float, steps: int
) -> list[State]:
    """Integrate q'' = -mu q/|q|^3 with velocity Verlet."""
    if step <= 0.0 or steps < 0:
        raise ValueError("step must be positive and steps nonnegative")
    q, v = q0, v0
    result = [State(0.0, q, v)]
    a = acceleration(mu, q)
    for index in range(1, steps + 1):
        q_next = add(add(q, scale(step, v)), scale(0.5 * step * step, a))
        a_next = acceleration(mu, q_next)
        v_next = add(v, scale(0.5 * step, add(a, a_next)))
        q, v, a = q_next, v_next, a_next
        result.append(State(index * step, q, v))
    return result


def invariant_report(mu: float, states: Sequence[State]) -> dict[str, float]:
    energies = [kepler_energy(mu, s.position, s.velocity) for s in states]
    momenta = [angular_momentum(s.position, s.velocity) for s in states]
    runge = [runge_lenz(mu, s.position, s.velocity) for s in states]
    bridges = [abs(conic_bridge_residual(mu, s.position, s.velocity)) for s in states]
    return {
        "maximum energy drift": max(abs(e - energies[0]) for e in energies),
        "maximum angular-momentum drift": max_vec_error(momenta),
        "maximum Runge-Lenz drift": max_vec_error(runge),
        "maximum conic-identity residual": max(bridges),
    }


def demonstrate_translation_charge() -> None:
    """A free particle has constant momentum in every translation direction."""
    p: Vec3 = (2.0, -1.0, 0.5)
    q0: Vec3 = (1.0, 2.0, -1.0)
    axis: Vec3 = (0.0, 1.0, 0.0)
    charges = []
    for time in (0.0, 0.5, 1.0, 2.0):
        _q = add(q0, scale(time, p))
        charges.append(noether_charge(p, axis, 0.0))
    print("Directional momentum charges:", charges)


def demonstrate_exact_circular_orbit() -> None:
    """Sample the exact unit circular Kepler orbit."""
    mu = 1.0
    states = [
        State(t, (cos(t), sin(t), 0.0), (-sin(t), cos(t), 0.0))
        for t in (0.0, 0.4, 1.2, 2.5, 2.0 * pi)
    ]
    print("Exact circular-orbit invariant report:")
    for name, value in invariant_report(mu, states).items():
        print(f"  {name}: {value:.3e}")


def demonstrate_elliptic_integration() -> None:
    """Integrate an eccentric bound orbit and measure invariant drift."""
    mu = 1.0
    eccentricity = 0.5
    periapsis = 1.0 - eccentricity
    speed = sqrt((1.0 + eccentricity) / (1.0 - eccentricity))
    states = velocity_verlet(mu, (periapsis, 0.0, 0.0), (0.0, speed, 0.0), 0.001, 7000)
    initial_a = runge_lenz(mu, states[0].position, states[0].velocity)
    initial_l = angular_momentum(states[0].position, states[0].velocity)
    recovered_e = norm(initial_a) / mu
    semilatus = dot(initial_l, initial_l) / mu
    print("Elliptic velocity-Verlet invariant report:")
    for name, value in invariant_report(mu, states).items():
        print(f"  {name}: {value:.3e}")
    print(f"  recovered eccentricity: {recovered_e:.6f}")
    print(f"  recovered semilatus rectum: {semilatus:.6f}")


def main() -> None:
    demonstrate_translation_charge()
    demonstrate_exact_circular_orbit()
    demonstrate_elliptic_integration()


if __name__ == "__main__":
    main()
