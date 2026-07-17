#!/usr/bin/env python3
"""Numerical illustrations of consensus topology and directional witnesses.

The finite calculations are exact. Real-line grids illustrate the local geometry;
the underlying theorems concern all real points, not only sampled values.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Iterable, Sequence

SubsetMask = int
Topology = FrozenSet[SubsetMask]


@dataclass(frozen=True)
class BallCertificate:
    """An ordinary ball certified by one lower and one upper witness."""

    left_endpoint: float
    point: float
    right_endpoint: float
    radius: float


def consensus(topologies: Sequence[Topology]) -> Topology:
    """Return the exact common-open-set topology of a nonempty finite family."""
    if not topologies:
        raise ValueError("At least one observer topology is required")
    result = set(topologies[0])
    for topology in topologies[1:]:
        result.intersection_update(topology)
    return frozenset(result)


def is_strict_refinement(observer: Topology, shared: Topology) -> bool:
    """Test whether an observer contains the consensus and adds an open set."""
    return shared < observer


def certify_euclidean_ball(a: float, x: float, b: float) -> BallCertificate:
    """Convert (a,x] and [x,b) witnesses into an ordinary ball at x."""
    if not a < x < b:
        raise ValueError("Expected strict inequalities a < x < b")
    radius = min(x - a, b - x)
    return BallCertificate(a, x, b, radius)


def sample_ball(certificate: BallCertificate, samples: int = 11) -> list[float]:
    """Sample interior points of the certified open ball."""
    if samples < 1:
        raise ValueError("samples must be positive")
    x, r = certificate.point, certificate.radius
    return [x - r + 2.0 * r * (k + 1) / (samples + 1) for k in range(samples)]


def two_point_demo() -> None:
    """Compute the exact Sierpiński consensus on {F,T}."""
    empty, false_only, true_only, whole = 0b00, 0b01, 0b10, 0b11
    indiscrete: Topology = frozenset({empty, whole})
    sees_true: Topology = frozenset({empty, true_only, whole})
    sees_false: Topology = frozenset({empty, false_only, whole})
    shared = consensus([sees_true, sees_false])
    print("Two-point observer calculation")
    print(f"  true-observer opens:  {sorted(sees_true)}")
    print(f"  false-observer opens: {sorted(sees_false)}")
    print(f"  consensus opens:      {sorted(shared)}")
    print(f"  equals indiscrete:    {shared == indiscrete}")
    print(f"  both strict:          {all(is_strict_refinement(t, shared) for t in [sees_true, sees_false])}")


def directional_demo() -> None:
    """Display an ordinary neighborhood recovered from one-sided witnesses."""
    cert = certify_euclidean_ball(a=-0.7, x=0.2, b=1.4)
    points = sample_ball(cert, samples=9)
    covered = all(cert.left_endpoint < y < cert.right_endpoint for y in points)
    print("\nDirectional real-line calculation")
    print(f"  witnesses: ({cert.left_endpoint}, {cert.point}] and [{cert.point}, {cert.right_endpoint})")
    print(f"  certified Euclidean radius: {cert.radius:.3f}")
    print(f"  sampled ball points covered by their union: {covered}")


def boundary_demo(epsilons: Iterable[float] = (1.0, 0.2, 0.01)) -> None:
    """Show numerically why [0,1) and (0,1] are not Euclidean-open."""
    print("\nHalf-open boundary calculation")
    for epsilon in epsilons:
        if epsilon <= 0:
            raise ValueError("epsilon values must be positive")
        left_witness = -epsilon / 2.0
        right_witness = 1.0 + epsilon / 2.0
        print(
            f"  epsilon={epsilon:g}: {left_witness:g} lies near 0 but outside [0,1); "
            f"{right_witness:g} lies near 1 but outside (0,1]"
        )


def main() -> None:
    two_point_demo()
    directional_demo()
    boundary_demo()


if __name__ == "__main__":
    main()
