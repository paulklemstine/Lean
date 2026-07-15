#!/usr/bin/env python3
"""Numerical demonstrations of coindex classification and the sharp join law."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Hashable, Iterable, Mapping, Sequence, Tuple, TypeVar

Vertex = TypeVar("Vertex", bound=Hashable)
TaggedVertex = Tuple[str, Hashable]


@dataclass(frozen=True)
class FreeZ2Set:
    """A finite vertex system represented by its fixed-point-free involution."""

    antipode: Mapping[Hashable, Hashable]

    def validate(self) -> None:
        """Raise ValueError unless the table is a fixed-point-free involution."""
        vertices = set(self.antipode)
        for vertex, opposite in self.antipode.items():
            if opposite not in vertices:
                raise ValueError(f"antipode {opposite!r} is not a vertex")
            if opposite == vertex:
                raise ValueError(f"fixed point at {vertex!r}")
            if self.antipode[opposite] != vertex:
                raise ValueError(f"involution law fails at {vertex!r}")

    @property
    def vertices(self) -> frozenset[Hashable]:
        self.validate()
        return frozenset(self.antipode)

    def orbits(self) -> Tuple[frozenset[Hashable], ...]:
        """Return the antipodal pairs in deterministic display order."""
        self.validate()
        unseen = set(self.antipode)
        pairs = []
        while unseen:
            vertex = min(unseen, key=repr)
            opposite = self.antipode[vertex]
            pair = frozenset((vertex, opposite))
            pairs.append(pair)
            unseen.difference_update(pair)
        return tuple(pairs)

    def coindex(self) -> int:
        """Compute orbit count minus one; the object must be nonempty."""
        orbit_count = len(self.orbits())
        if orbit_count == 0:
            raise ValueError("coindex formula requires a nonempty object")
        return orbit_count - 1


def octahedral_sphere(dimension: int, prefix: str = "x") -> FreeZ2Set:
    """Build the signed coordinate model of the octahedral dimension sphere."""
    if dimension < 0:
        raise ValueError("dimension must be nonnegative")
    table: Dict[Hashable, Hashable] = {}
    for axis in range(dimension + 1):
        positive = f"+{prefix}{axis}"
        negative = f"-{prefix}{axis}"
        table[positive] = negative
        table[negative] = positive
    return FreeZ2Set(table)


def from_orbit_count(count: int, prefix: str) -> FreeZ2Set:
    """Construct a normal-form object with the requested number of orbits."""
    if count <= 0:
        raise ValueError("a nonempty object needs at least one orbit")
    return octahedral_sphere(count - 1, prefix)


def join(left: FreeZ2Set, right: FreeZ2Set) -> FreeZ2Set:
    """Form the disjoint-union join, tagging each summand."""
    left.validate()
    right.validate()
    table: Dict[Hashable, Hashable] = {}
    for vertex, opposite in left.antipode.items():
        table[("L", vertex)] = ("L", opposite)
    for vertex, opposite in right.antipode.items():
        table[("R", vertex)] = ("R", opposite)
    return FreeZ2Set(table)


def validate_equivariant_map(
    source: FreeZ2Set,
    target: FreeZ2Set,
    mapping: Mapping[Hashable, Hashable],
) -> bool:
    """Test totality, target membership, equivariance, and injectivity."""
    source.validate()
    target.validate()
    if set(mapping) != set(source.antipode):
        return False
    if any(image not in target.antipode for image in mapping.values()):
        return False
    if len(set(mapping.values())) != len(mapping):
        return False
    return all(
        mapping[source.antipode[v]] == target.antipode[mapping[v]]
        for v in source.antipode
    )


def sphere_embedding(source_dimension: int, target: FreeZ2Set) -> Dict[Hashable, Hashable]:
    """Construct an embedding from a standard sphere when the vertex bound allows it."""
    source = octahedral_sphere(source_dimension, "s")
    target_pairs = target.orbits()
    if source_dimension + 1 > len(target_pairs):
        raise ValueError("vertex bound forbids this embedding")
    mapping: Dict[Hashable, Hashable] = {}
    for axis, pair in enumerate(target_pairs[: source_dimension + 1]):
        first = min(pair, key=repr)
        second = target.antipode[first]
        mapping[f"+s{axis}"] = first
        mapping[f"-s{axis}"] = second
    assert validate_equivariant_map(source, target, mapping)
    return mapping


def demonstrate_join_law(orbit_pairs: Iterable[Tuple[int, int]]) -> None:
    """Print exact numerical instances of the classification and join theorem."""
    print("Sharp join law examples")
    print("r  s | c(K) c(L) | vertices(K*L) | c(K*L) | RHS")
    for r, s in orbit_pairs:
        left = from_orbit_count(r, "a")
        right = from_orbit_count(s, "b")
        product = join(left, right)
        rhs = left.coindex() + right.coindex() + 1
        print(
            f"{r:2d} {s:2d} | {left.coindex():4d} {right.coindex():4d} |"
            f" {len(product.vertices):13d} | {product.coindex():7d} | {rhs:3d}"
        )
        assert product.coindex() == rhs
        assert 2 * (product.coindex() + 1) == len(product.vertices)


def demonstrate_vertex_bound(target_orbits: int) -> None:
    """Show exactly which source sphere dimensions fit in a target."""
    target = from_orbit_count(target_orbits, "t")
    print(f"\nTarget: {len(target.vertices)} vertices, coindex {target.coindex()}")
    for dimension in range(target_orbits + 2):
        bound = 2 * (dimension + 1) <= len(target.vertices)
        constructed = False
        if bound:
            embedding = sphere_embedding(dimension, target)
            constructed = validate_equivariant_map(
                octahedral_sphere(dimension, "s"), target, embedding
            )
        print(
            f"dimension {dimension:2d}: vertex bound={str(bound):5s}, "
            f"embedding constructed={constructed}"
        )
        assert constructed == bound


def demonstrate_associativity(counts: Sequence[int]) -> None:
    """Compare both parenthesizations for three nonempty factors."""
    if len(counts) != 3:
        raise ValueError("provide exactly three orbit counts")
    a, b, c = (from_orbit_count(n, name) for n, name in zip(counts, "abc"))
    left = join(join(a, b), c)
    right = join(a, join(b, c))
    expected = a.coindex() + b.coindex() + c.coindex() + 2
    print("\nTriple join")
    print(f"orbit counts: {tuple(counts)}")
    print(f"left coindex={left.coindex()}, right coindex={right.coindex()}")
    print(f"sum formula={expected}")
    assert left.coindex() == right.coindex() == expected


def main() -> None:
    demonstrate_join_law([(1, 1), (2, 3), (4, 7), (8, 5)])
    demonstrate_vertex_bound(6)
    demonstrate_associativity((2, 3, 5))


if __name__ == "__main__":
    main()
