#!/usr/bin/env python3
"""Numerical demonstrations of extensive co-index laws for finite antipodal systems."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence


@dataclass(frozen=True)
class AntipodalSystem:
    """A complete finite antipodal system, represented by its orbit count."""

    name: str
    orbit_count: int

    def __post_init__(self) -> None:
        if self.orbit_count < 1:
            raise ValueError("A system must have at least one antipodal orbit")

    @property
    def coindex(self) -> int:
        return self.orbit_count - 1

    @property
    def vertex_count(self) -> int:
        return 2 * self.orbit_count

    @property
    def face_count(self) -> int:
        # For each orbit choose its positive vertex, negative vertex, or neither.
        return 3 ** self.orbit_count


def composite_from_orbits(name: str, orbit_counts: Sequence[int]) -> AntipodalSystem:
    """Compose systems by join using only their antipodal orbit counts."""
    if not orbit_counts or any(q < 1 for q in orbit_counts):
        raise ValueError("Provide a nonempty sequence of positive orbit counts")
    return AntipodalSystem(name, sum(orbit_counts))


def coindex_from_factor_coindices(coindices: Sequence[int]) -> int:
    """Return the join co-index as sum(c + 1) - 1 in linear time."""
    if not coindices or any(c < 0 for c in coindices):
        raise ValueError("Provide a nonempty sequence of natural-number co-indices")
    return sum(c + 1 for c in coindices) - 1


def enumerate_faces(orbit_count: int) -> list[tuple[int, ...]]:
    """Enumerate faces as choices -1, 0, or +1 on every antipodal axis."""
    if orbit_count < 1:
        raise ValueError("orbit_count must be positive")
    return list(product((-1, 0, 1), repeat=orbit_count))


def audit_systems(systems: Iterable[AntipodalSystem]) -> bool:
    """Check the identity 2(coindex + 1) = vertex count factor by factor."""
    return all(2 * (system.coindex + 1) == system.vertex_count for system in systems)


def print_composition_demo() -> None:
    factors = [
        AntipodalSystem("sector A", 2),
        AntipodalSystem("sector B", 3),
        AntipodalSystem("sector C", 5),
    ]
    composite = composite_from_orbits("A * B * C", [x.orbit_count for x in factors])
    predicted = coindex_from_factor_coindices([x.coindex for x in factors])

    print("Exact three-factor composition")
    for factor in factors:
        print(
            f"  {factor.name}: pairs={factor.orbit_count}, "
            f"vertices={factor.vertex_count}, co-index={factor.coindex}"
        )
    print(f"  composite co-index from shifted sum: {predicted}")
    print(f"  composite orbit calculation:         {composite.coindex}")
    print(f"  composite vertices:                  {composite.vertex_count}")
    assert predicted == composite.coindex == 9
    assert composite.vertex_count == 20


def print_suspension_demo(max_factors: int = 7) -> None:
    print("\nRepeated join of zero-spheres")
    print(" factors | shifted co-index | co-index | vertices | faces")
    for count in range(1, max_factors + 1):
        system = composite_from_orbits(f"join of {count} zero-spheres", [1] * count)
        print(
            f" {count:7d} | {system.coindex + 1:16d} | {system.coindex:8d} | "
            f"{system.vertex_count:8d} | {system.face_count:5d}"
        )
        assert len(enumerate_faces(count)) == system.face_count


def print_large_composite_demo() -> None:
    coindices = [7, 12, 0, 4]
    composite_coindex = coindex_from_factor_coindices(coindices)
    shifted = composite_coindex + 1
    print("\nLarge composite without face construction")
    print(f"  factor co-indices: {coindices}")
    print(f"  shifted co-index:  {shifted}")
    print(f"  co-index:          {composite_coindex}")
    print(f"  vertices:          {2 * shifted}")
    print(f"  implicit faces:    {3 ** shifted:,}")
    assert shifted == 27 and composite_coindex == 26


def main() -> None:
    print_composition_demo()
    print_suspension_demo()
    print_large_composite_demo()
    sample = [AntipodalSystem("sample", q) for q in range(1, 10)]
    assert audit_systems(sample)
    print("\nAll numerical identities passed.")


if __name__ == "__main__":
    main()
