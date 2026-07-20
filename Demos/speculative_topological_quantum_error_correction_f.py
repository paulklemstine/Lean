#!/usr/bin/env python3
"""Numerical demonstrations of weighted systoles and topological-code bounds."""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Callable, Hashable, Mapping, Sequence, TypeVar

T = TypeVar("T", bound=Hashable)
U = TypeVar("U", bound=Hashable)


@dataclass(frozen=True)
class WeightedModel:
    """A finite pointed class space with nonnegative integer weights."""

    zero: Hashable
    weights: Mapping[Hashable, int]

    def __post_init__(self) -> None:
        if self.zero not in self.weights:
            raise ValueError("The distinguished zero class must occur in the weight table.")
        if any(weight < 0 for weight in self.weights.values()):
            raise ValueError("Weights must be nonnegative integers.")

    def systole(self) -> tuple[int, Hashable]:
        """Return the minimum nonzero weight and one class attaining it."""
        candidates = [(weight, cls) for cls, weight in self.weights.items() if cls != self.zero]
        if not candidates:
            raise ValueError("A systole requires at least one nonzero class.")
        return min(candidates, key=lambda pair: pair[0])


def check_weighted_isometry(
    source: WeightedModel,
    target: WeightedModel,
    mapping: Mapping[Hashable, Hashable],
) -> bool:
    """Check bijectivity, preservation of zero, and preservation of every weight."""
    if set(mapping) != set(source.weights):
        return False
    images = list(mapping.values())
    if len(set(images)) != len(images) or set(images) != set(target.weights):
        return False
    if mapping[source.zero] != target.zero:
        return False
    return all(target.weights[mapping[x]] == source.weights[x] for x in source.weights)


def square_torus_parameters(n: int) -> tuple[int, int, int]:
    """Return genus, distance, and edge count for an n-by-n square torus."""
    if n <= 0:
        raise ValueError("The linear size n must be positive.")
    genus = 1
    distance = n
    edges = 2 * n * n
    assert 2 * distance * distance == edges
    return genus, distance, edges


def certify_genus_transfer(
    distance: int,
    systole: int,
    area: int,
    genus: int,
    systolic_constant: int,
    area_constant: int,
) -> tuple[bool, int]:
    """Check the transfer hypotheses and return validity and conclusion slack."""
    values = (distance, systole, area, genus, systolic_constant, area_constant)
    if any(value < 0 for value in values):
        raise ValueError("All parameters must be nonnegative.")
    hypotheses = (
        distance == systole
        and systole * systole <= systolic_constant * area
        and area <= area_constant * genus
    )
    slack = systolic_constant * area_constant * genus - distance * distance
    return hypotheses and slack >= 0, slack


def demonstrate_weight_transport() -> None:
    """Show exact preservation of a finite nonzero minimum."""
    logical = WeightedModel("I", {"I": 0, "X-loop": 7, "Z-loop": 5, "XZ-loop": 9})
    geometric = WeightedModel("0", {"0": 0, "a": 5, "b": 7, "a+b": 9})
    identification = {"I": "0", "X-loop": "b", "Z-loop": "a", "XZ-loop": "a+b"}
    assert check_weighted_isometry(logical, geometric, identification)
    logical_sys, logical_witness = logical.systole()
    geometric_sys, geometric_witness = geometric.systole()
    assert logical_sys == geometric_sys
    print("Weighted distance-systole transport")
    print(f"  logical minimum: {logical_sys}, attained by {logical_witness}")
    print(f"  geometric systole: {geometric_sys}, attained by {geometric_witness}")


def demonstrate_square_tori(sizes: Sequence[int]) -> None:
    """Print exact square-torus distance and edge identities."""
    print("\nSquare torus family")
    print("  n   genus   distance   edges   check 2d^2=E")
    for n in sizes:
        genus, distance, edges = square_torus_parameters(n)
        print(f"  {n:2d}    {genus:2d}       {distance:3d}      {edges:4d}       {2 * distance**2 == edges}")


def demonstrate_genus_obstruction(bounds: Sequence[int]) -> None:
    """Exhibit distance above each proposed bound while genus remains one."""
    print("\nFailure of genus-only distance bounds")
    for bound in bounds:
        n = bound + 1
        genus, distance, edges = square_torus_parameters(n)
        assert genus == 1 and distance > bound
        print(f"  proposed bound {bound:3d}: genus={genus}, distance={distance}, edges={edges}")


def demonstrate_transfer_certificate() -> None:
    """Check a concrete square-root genus transfer instance."""
    distance, systole = 12, 12
    area, genus = 96, 24
    alpha, beta = 2, 4
    valid, slack = certify_genus_transfer(distance, systole, area, genus, alpha, beta)
    upper_square = alpha * beta * genus
    print("\nSquare-root genus certificate")
    print(f"  hypotheses valid: {valid}")
    print(f"  d^2={distance**2} <= alpha*beta*g={upper_square}; slack={slack}")
    print(f"  integer upper bound for d: {isqrt(upper_square)}")


def main() -> None:
    demonstrate_weight_transport()
    demonstrate_square_tori([2, 3, 5, 8, 13])
    demonstrate_genus_obstruction([1, 5, 20, 100])
    demonstrate_transfer_certificate()


if __name__ == "__main__":
    main()
