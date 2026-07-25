#!/usr/bin/env python3
"""Numerical demonstrations of boundary–tropical incidence and genus invariance."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, Iterator, Literal, Mapping, Sequence, TypeVar

Label = TypeVar("Label")
Face = FrozenSet[str]
ContractionKind = Literal["nonloop", "loop"]


def powerset(items: Iterable[str]) -> FrozenSet[Face]:
    """Return every subset of a finite collection as immutable faces."""
    data = tuple(items)
    return frozenset(
        frozenset(choice)
        for size in range(len(data) + 1)
        for choice in combinations(data, size)
    )


def downward_closure(maximal_faces: Iterable[Iterable[str]]) -> FrozenSet[Face]:
    """Generate the simplicial face family determined by maximal faces."""
    result: set[Face] = set()
    for maximal in maximal_faces:
        result.update(powerset(maximal))
    return frozenset(result)


def transport(face: Face, divisor_ray: Mapping[str, str]) -> Face:
    """Transport a boundary face elementwise to tropical rays."""
    return frozenset(divisor_ray[item] for item in face)


def validate_atlas(
    divisors: FrozenSet[str],
    rays: FrozenSet[str],
    boundary_faces: FrozenSet[Face],
    tropical_faces: FrozenSet[Face],
    divisor_ray: Mapping[str, str],
) -> bool:
    """Check bijectivity, downward closure, and complete incidence compatibility."""
    if set(divisor_ray) != set(divisors):
        return False
    if set(divisor_ray.values()) != set(rays):
        return False
    if len(set(divisor_ray.values())) != len(divisors):
        return False
    if frozenset() not in boundary_faces or frozenset() not in tropical_faces:
        return False
    for face in boundary_faces:
        if not powerset(face).issubset(boundary_faces):
            return False
    for face in tropical_faces:
        if not powerset(face).issubset(tropical_faces):
            return False
    return all(
        (face in boundary_faces)
        == (transport(face, divisor_ray) in tropical_faces)
        for face in powerset(divisors)
    )


def face_link(face: Face, family: FrozenSet[Face]) -> FrozenSet[Face]:
    """Compute all faces disjoint from a fixed face whose union is a face."""
    return frozenset(
        candidate
        for candidate in family
        if candidate.isdisjoint(face) and candidate | face in family
    )


@dataclass(frozen=True)
class WeightedDualSignature:
    """Numerical signature of a connected weighted dual graph."""

    vertices: int
    edges: int
    weight: int
    legs: int

    def __post_init__(self) -> None:
        if min(self.vertices, self.edges, self.weight, self.legs) < 0:
            raise ValueError("Signature entries must be nonnegative")

    @property
    def genus(self) -> int:
        return self.weight + self.edges + 1 - self.vertices

    @property
    def augmented_complexity(self) -> int:
        return 2 * self.genus + self.legs

    def contract(self, kind: ContractionKind) -> "WeightedDualSignature":
        if self.edges < 1:
            raise ValueError("Contraction requires at least one edge")
        if kind == "nonloop":
            if self.vertices < 2:
                raise ValueError("Non-loop contraction requires at least two vertices")
            result = WeightedDualSignature(
                self.vertices - 1, self.edges - 1, self.weight, self.legs
            )
        elif kind == "loop":
            result = WeightedDualSignature(
                self.vertices, self.edges - 1, self.weight + 1, self.legs
            )
        else:
            raise ValueError(f"Unknown contraction kind: {kind}")
        if result.genus != self.genus:
            raise AssertionError("Genus invariance failed")
        return result


def contraction_history(
    initial: WeightedDualSignature, steps: Sequence[ContractionKind]
) -> list[WeightedDualSignature]:
    """Apply contractions and return the invariant-preserving history."""
    history = [initial]
    for step in steps:
        history.append(history[-1].contract(step))
    return history


def format_face(face: Face) -> str:
    return "{" + ", ".join(sorted(face)) + "}"


def incidence_demo() -> None:
    divisors = frozenset({"a", "b", "c", "d"})
    divisor_ray: Dict[str, str] = {name: f"rho_{name}" for name in divisors}
    rays = frozenset(divisor_ray.values())
    boundary = downward_closure([{"a", "b", "c"}, {"b", "c", "d"}])
    tropical = frozenset(transport(face, divisor_ray) for face in boundary)
    assert validate_atlas(divisors, rays, boundary, tropical, divisor_ray)

    left = frozenset({"a", "b", "c"})
    right = frozenset({"b", "c", "d"})
    assert transport(left & right, divisor_ray) == (
        transport(left, divisor_ray) & transport(right, divisor_ray)
    )
    assert transport(left | right, divisor_ray) == (
        transport(left, divisor_ray) | transport(right, divisor_ray)
    )

    print("INCIDENCE ATLAS")
    print(f"  compatible faces: {len(boundary)} boundary = {len(tropical)} tropical")
    print(f"  sample face: {format_face(left)} -> {format_face(transport(left, divisor_ray))}")
    print(f"  cardinality preserved: {len(left)} = {len(transport(left, divisor_ray))}")


def link_demo() -> None:
    mapping = {name: f"rho_{name}" for name in {"a", "b", "c", "d"}}
    boundary = downward_closure([{"a", "b", "c"}, {"b", "c", "d"}])
    tropical = frozenset(transport(face, mapping) for face in boundary)
    sigma = frozenset({"b"})
    boundary_link = face_link(sigma, boundary)
    tropical_link = face_link(transport(sigma, mapping), tropical)
    transported_link = frozenset(transport(face, mapping) for face in boundary_link)
    assert transported_link == tropical_link
    print("\nLINK CORRESPONDENCE")
    print(f"  link around {format_face(sigma)} has {len(boundary_link)} faces")
    print(f"  transported link equals tropical link: {transported_link == tropical_link}")


def genus_demo() -> None:
    start = WeightedDualSignature(vertices=4, edges=6, weight=2, legs=3)
    history = contraction_history(start, ["nonloop", "loop", "nonloop"])
    assert {state.genus for state in history} == {start.genus}
    assert {state.augmented_complexity for state in history} == {
        start.augmented_complexity
    }
    print("\nGENUS-PRESERVING SPECIALIZATION")
    for index, state in enumerate(history):
        print(
            f"  step {index}: (V,E,W,N)="
            f"({state.vertices},{state.edges},{state.weight},{state.legs}), "
            f"g={state.genus}, A={state.augmented_complexity}"
        )


def main() -> None:
    incidence_demo()
    link_demo()
    genus_demo()


if __name__ == "__main__":
    main()
