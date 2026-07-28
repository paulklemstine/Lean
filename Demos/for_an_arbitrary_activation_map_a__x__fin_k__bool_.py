#!/usr/bin/env python3
"""Numerical demonstrations of feasible cells and affine ReLU formulas.

The script uses only the Python standard library. It evaluates a shallow
scalar-output ReLU network, extracts activation patterns and their selected
affine coefficients, checks cellwise identities, and enumerates patterns on a
finite grid to exhibit an infeasible formal pattern.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import isclose
from typing import Iterable, Sequence

Vector = tuple[float, ...]
Pattern = tuple[bool, ...]


def dot(a: Sequence[float], b: Sequence[float]) -> float:
    """Return the Euclidean dot product of equally sized vectors."""
    if len(a) != len(b):
        raise ValueError("dot-product vectors must have equal length")
    return sum(x * y for x, y in zip(a, b))


def affine_combine(x: Sequence[float], y: Sequence[float], t: float) -> Vector:
    """Return t*x + (1-t)*y."""
    if len(x) != len(y):
        raise ValueError("vectors must have equal length")
    return tuple(t * xi + (1.0 - t) * yi for xi, yi in zip(x, y))


@dataclass(frozen=True)
class ShallowReLUNetwork:
    """A scalar-output network with one ReLU hidden layer."""

    weights: tuple[Vector, ...]
    hidden_bias: Vector
    output_weights: Vector
    output_bias: float

    def __post_init__(self) -> None:
        k = len(self.weights)
        if len(self.hidden_bias) != k or len(self.output_weights) != k:
            raise ValueError("hidden-layer arrays must have equal length")
        if k and any(len(row) != len(self.weights[0]) for row in self.weights):
            raise ValueError("all weight rows must have equal length")

    def preactivations(self, x: Sequence[float]) -> Vector:
        return tuple(dot(row, x) + bias for row, bias in zip(self.weights, self.hidden_bias))

    def activation_pattern(self, x: Sequence[float]) -> Pattern:
        """Use strict positivity; zero belongs to the inactive branch."""
        return tuple(z > 0.0 for z in self.preactivations(x))

    def output(self, x: Sequence[float]) -> float:
        return sum(
            v * max(z, 0.0)
            for v, z in zip(self.output_weights, self.preactivations(x))
        ) + self.output_bias

    def selected_coefficients(self, pattern: Pattern) -> tuple[Vector, float]:
        """Return slope g and intercept d for the formula selected by pattern."""
        if len(pattern) != len(self.weights):
            raise ValueError("pattern has wrong length")
        n = len(self.weights[0]) if self.weights else 0
        slope = [0.0] * n
        intercept = self.output_bias
        for active, row, bias, out_weight in zip(
            pattern, self.weights, self.hidden_bias, self.output_weights
        ):
            if active:
                for i, coefficient in enumerate(row):
                    slope[i] += out_weight * coefficient
                intercept += out_weight * bias
        return tuple(slope), intercept

    def selected_output(self, pattern: Pattern, x: Sequence[float]) -> float:
        slope, intercept = self.selected_coefficients(pattern)
        return dot(slope, x) + intercept

    def satisfies_pattern(self, pattern: Pattern, x: Sequence[float]) -> bool:
        """Check the exact strict/weak inequalities defining a cell."""
        if len(pattern) != len(self.weights):
            return False
        return all(
            z > 0.0 if active else z <= 0.0
            for active, z in zip(pattern, self.preactivations(x))
        )


def enumerate_grid_patterns(
    network: ShallowReLUNetwork, points: Iterable[Vector]
) -> dict[Pattern, list[Vector]]:
    """Group finite sample points by their activation patterns."""
    groups: dict[Pattern, list[Vector]] = {}
    for point in points:
        groups.setdefault(network.activation_pattern(point), []).append(point)
    return groups


def bits(pattern: Pattern) -> str:
    return "".join("1" if bit else "0" for bit in pattern)


def one_dimensional_demo() -> None:
    print("\n1. One-dimensional activation mosaic")
    net = ShallowReLUNetwork(
        weights=((1.0,), (-1.0,)),
        hidden_bias=(1.0, 2.0),
        output_weights=(2.0, -1.0),
        output_bias=0.5,
    )
    points = ((x / 2.0,) for x in range(-8, 9))
    groups = enumerate_grid_patterns(net, points)
    for pattern in sorted(groups, key=bits):
        slope, intercept = net.selected_coefficients(pattern)
        samples = ", ".join(f"{p[0]:g}" for p in groups[pattern])
        print(
            f"  pattern {bits(pattern)}: F(x)={slope[0]:g}x{intercept:+g}; "
            f"sampled at x={samples}"
        )
    formal = set(product((False, True), repeat=2))
    absent = sorted(formal - set(groups), key=bits)
    print("  formal patterns absent from the grid:", ", ".join(map(bits, absent)))
    print("  Pattern 00 is globally infeasible: it requires x <= -1 and x >= 2.")


def cellwise_equality_demo() -> None:
    print("\n2. Exact selected formula on a two-dimensional cell")
    net = ShallowReLUNetwork(
        weights=((1.0, 1.0), (-1.0, 2.0)),
        hidden_bias=(-1.0, 0.0),
        output_weights=(3.0, -2.0),
        output_bias=1.0,
    )
    pattern = (True, False)
    points: tuple[Vector, ...] = ((2.0, 0.0), (3.0, 0.5), (4.0, 1.0))
    slope, intercept = net.selected_coefficients(pattern)
    print(f"  selected pattern: {bits(pattern)}")
    print(f"  selected formula: g={slope}, d={intercept:g}")
    for point in points:
        direct = net.output(point)
        selected = net.selected_output(pattern, point)
        assert net.satisfies_pattern(pattern, point)
        assert isclose(direct, selected, rel_tol=1e-12, abs_tol=1e-12)
        print(f"  x={point}: network={direct:g}, selected={selected:g}")


def affine_interpolation_demo() -> None:
    print("\n3. Affine interpolation within one activation cell")
    net = ShallowReLUNetwork(
        weights=((1.0, 1.0), (-1.0, 2.0)),
        hidden_bias=(-1.0, 0.0),
        output_weights=(3.0, -2.0),
        output_bias=1.0,
    )
    x: Vector = (2.0, 0.0)
    y: Vector = (4.0, 1.0)
    pattern = net.activation_pattern(x)
    assert net.activation_pattern(y) == pattern
    for t in (0.0, 0.25, 0.5, 0.75, 1.0):
        mixed = affine_combine(x, y, t)
        lhs = net.output(mixed)
        rhs = t * net.output(x) + (1.0 - t) * net.output(y)
        assert net.activation_pattern(mixed) == pattern
        assert isclose(lhs, rhs, rel_tol=1e-12, abs_tol=1e-12)
        print(f"  t={t:4.2f}, point={mixed}, F(point)={lhs:6.3f}, affine RHS={rhs:6.3f}")


def main() -> None:
    print("Feasible activation cells and affine ReLU semantics")
    one_dimensional_demo()
    cellwise_equality_demo()
    affine_interpolation_demo()
    print("\nAll numerical identity checks passed.")


if __name__ == "__main__":
    main()
