#!/usr/bin/env python3
"""Numerical demonstrations for ReLU width--depth capacity trade-offs.

The script uses only the Python standard library.  It evaluates the basic ReLU
constructions, computes exact integer capacities, compares shallow and fixed-
width designs, and confirms the sharp one-layer flattening formula.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


def relu(x: float) -> float:
    """Return max(x, 0)."""
    return max(x, 0.0)


def tent(x: float) -> float:
    """Evaluate the three-ReLU tent map."""
    return relu(x) - 2.0 * relu(x - 1.0) + relu(x - 2.0)


def iterated_tent(x: float, layers: int) -> float:
    """Compose the tent map with itself ``layers`` times."""
    if layers < 0:
        raise ValueError("layers must be nonnegative")
    value = x
    for _ in range(layers):
        value = tent(value)
    return value


def region_capacity(width: int, depth: int) -> int:
    """Return the exact model capacity (width + 1) ** depth."""
    if width < 0 or depth < 0:
        raise ValueError("width and depth must be nonnegative")
    return (width + 1) ** depth


def approximation_cell_demand(dimension: int, resolution: int) -> int:
    """Return the grid-scale demand resolution ** dimension."""
    if dimension < 0 or resolution < 0:
        raise ValueError("dimension and resolution must be nonnegative")
    return resolution**dimension


def minimum_depth(width: int, demand: int) -> int:
    """Find the least depth d such that (width + 1) ** d >= demand."""
    if width <= 0:
        raise ValueError("width must be positive")
    if demand < 0:
        raise ValueError("demand must be nonnegative")
    depth, capacity = 0, 1
    while capacity < demand:
        capacity *= width + 1
        depth += 1
    return depth


def exact_shallow_equivalent(width: int, deep_depth: int) -> int:
    """Return the one-layer width matching a given model capacity exactly."""
    if width < 0 or deep_depth < 0:
        raise ValueError("width and depth must be nonnegative")
    return region_capacity(width, deep_depth) - 1


@dataclass(frozen=True)
class Tradeoff:
    """A comparison for demand m^n."""

    dimension: int
    resolution: int
    demand: int
    exact_width_at_depth_n: int
    fixed_width: int
    fixed_width_depth: int
    fixed_width_capacity: int


def compare_designs(dimension: int, resolution: int) -> Tradeoff:
    """Compare exact depth-n width with fixed width n+4."""
    if dimension <= 0 or resolution <= 0:
        raise ValueError("dimension and resolution must be positive")
    demand = approximation_cell_demand(dimension, resolution)
    shallow_width = resolution - 1
    fixed_width = dimension + 4
    depth = minimum_depth(fixed_width, demand)
    return Tradeoff(
        dimension,
        resolution,
        demand,
        shallow_width,
        fixed_width,
        depth,
        region_capacity(fixed_width, depth),
    )


def print_table(rows: Iterable[Tradeoff]) -> None:
    """Print a compact table of architectural comparisons."""
    header = (
        " n   m      demand   width@m-depth   fixed width   needed depth   capacity"
    )
    print(header)
    print("-" * len(header))
    for row in rows:
        print(
            f"{row.dimension:2d} {row.resolution:3d} {row.demand:11d}"
            f" {row.exact_width_at_depth_n:15d} {row.fixed_width:13d}"
            f" {row.fixed_width_depth:14d} {row.fixed_width_capacity:10d}"
        )


def main() -> None:
    """Run all numerical demonstrations and internal consistency checks."""
    print("Two-ReLU identity and tent-map key values")
    for x in (-2.0, -0.5, 0.0, 0.5, 1.0, 2.0, 3.0):
        identity = relu(x) - relu(-x)
        print(f"x={x:4.1f}  rho(x)-rho(-x)={identity:4.1f}  T(x)={tent(x):4.1f}")
        assert abs(identity - x) < 1e-12
    assert [tent(x) for x in (0.0, 1.0, 2.0)] == [0.0, 1.0, 0.0]

    print("\nExact width versus logarithmic-depth fixed width")
    rows = [compare_designs(n, m) for n, m in [(2, 8), (3, 10), (5, 6)]]
    print_table(rows)
    for row in rows:
        assert region_capacity(row.exact_width_at_depth_n, row.dimension) == row.demand
        assert row.fixed_width_capacity >= row.demand
        if row.fixed_width_depth > 0:
            assert region_capacity(row.fixed_width, row.fixed_width_depth - 1) < row.demand

    print("\nSharp one-layer flattening cost")
    for width, depth in [(2, 4), (3, 5), (5, 6)]:
        shallow_width = exact_shallow_equivalent(width, depth)
        deep = region_capacity(width, depth)
        shallow = region_capacity(shallow_width, 1)
        print(
            f"width {width}, depth {depth}: capacity {deep:,}; "
            f"exact one-layer width {shallow_width:,}"
        )
        assert deep == shallow


if __name__ == "__main__":
    main()
