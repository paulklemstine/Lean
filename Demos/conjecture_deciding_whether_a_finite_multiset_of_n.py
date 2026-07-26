#!/usr/bin/env python3
"""Numerical demonstrations of complementation orbits in finite assembly spaces."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Generic, Hashable, Iterable, List, Literal, Sequence, Tuple, TypeVar, Union

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
Side = Literal["L", "R"]
Polarity = Literal[-1, 0, 1]


@dataclass(frozen=True)
class Tagged(Generic[A]):
    """An assembly together with the side of the disjoint union it occupies."""

    side: Side
    assembly: A


@dataclass(frozen=True)
class Edge:
    """A flat edge (polarity 0) or a colored tab/blank (polarity +1/-1)."""

    color: str
    polarity: Polarity

    def complement(self) -> "Edge":
        return self if self.polarity == 0 else Edge(self.color, -self.polarity)  # type: ignore[arg-type]


@dataclass(frozen=True)
class Piece:
    """A non-rotatable square piece with edges ordered north, east, south, west."""

    name: str
    edges: Tuple[Edge, Edge, Edge, Edge]

    def complement(self) -> "Piece":
        return Piece(self.name + "^c", tuple(edge.complement() for edge in self.edges))  # type: ignore[arg-type]


def tagged_complement(
    item: Tagged[Hashable],
    forward: Dict[Hashable, Hashable],
    inverse: Dict[Hashable, Hashable],
) -> Tagged[Hashable]:
    """Apply the fixed-point-free involution to a tagged assembly."""

    if item.side == "L":
        return Tagged("R", forward[item.assembly])
    return Tagged("L", inverse[item.assembly])


def make_named_bijection(n: int) -> Tuple[List[str], List[str], Dict[str, str], Dict[str, str]]:
    """Construct two size-n assembly sets and an explicit bijection between them."""

    if n < 0:
        raise ValueError("n must be nonnegative")
    left = [f"assembly_{i}" for i in range(n)]
    right = [f"complement_{i}" for i in range(n)]
    forward = dict(zip(left, right))
    inverse = {value: key for key, value in forward.items()}
    return left, right, forward, inverse


def enumerate_orbits(n: int) -> List[Tuple[Tagged[str], Tagged[str]]]:
    """Return the n two-element orbits for a canonical size-n bijection."""

    left, _, forward, _ = make_named_bijection(n)
    return [(Tagged("L", item), Tagged("R", forward[item])) for item in left]


def audit_bijection(
    left: Sequence[A], right: Sequence[B], forward: Dict[A, B], inverse: Dict[B, A]
) -> bool:
    """Check that finite maps are mutual inverses and cover the supplied sets."""

    left_set, right_set = set(left), set(right)
    return (
        set(forward) == left_set
        and set(forward.values()) == right_set
        and set(inverse) == right_set
        and set(inverse.values()) == left_set
        and all(inverse[forward[x]] == x for x in left_set)
        and all(forward[inverse[y]] == y for y in right_set)
    )


def parity_table(max_side_count: int) -> List[Tuple[int, int, int]]:
    """Return (side count, combined count, orbit count) for counts from 0 upward."""

    if max_side_count < 0:
        raise ValueError("max_side_count must be nonnegative")
    return [(n, 2 * n, n) for n in range(max_side_count + 1)]


def demonstrate_self_dual_singleton() -> Tuple[Tagged[str], Tagged[str]]:
    """Exhibit the free tagged action for one self-dual assembly."""

    forward = {"*": "*"}
    inverse = {"*": "*"}
    point = Tagged("L", "*")
    image = tagged_complement(point, forward, inverse)
    assert image != point
    assert tagged_complement(image, forward, inverse) == point
    return point, image


def demonstrate_piece_complement() -> Tuple[Piece, Piece, Piece]:
    """Complement a colored piece twice and return original, complement, restoration."""

    flat = Edge("flat", 0)
    piece = Piece("p", (flat, Edge("red", 1), Edge("blue", -1), flat))
    complemented = piece.complement()
    restored_raw = complemented.complement()
    restored = Piece(piece.name, restored_raw.edges)
    assert restored.edges == piece.edges
    return piece, complemented, restored


def main() -> None:
    print("Complementation parity table")
    print("side assemblies | tagged total | two-element orbits")
    for side_count, combined, orbit_count in parity_table(8):
        print(f"{side_count:15d} | {combined:12d} | {orbit_count:18d}")

    left, right, forward, inverse = make_named_bijection(4)
    assert audit_bijection(left, right, forward, inverse)
    orbits = enumerate_orbits(4)
    assert len(orbits) == len(left)
    assert all(x != y for x, y in orbits)
    print("\nCanonical orbits for four assemblies:")
    for orbit in orbits:
        print(f"  {orbit[0]} <-> {orbit[1]}")

    start, partner = demonstrate_self_dual_singleton()
    print("\nSelf-dual singleton still forms a tagged pair:")
    print(f"  {start} <-> {partner}")

    original, complemented, restored = demonstrate_piece_complement()
    print("\nEdge polarities under double complementation:")
    print("  original:    ", [edge.polarity for edge in original.edges])
    print("  complement:  ", [edge.polarity for edge in complemented.edges])
    print("  restored:    ", [edge.polarity for edge in restored.edges])

    for n in range(20):
        assert 2 * n % 2 == 0
        assert len(enumerate_orbits(n)) == n
    print("\nAll numerical and involution checks passed.")


if __name__ == "__main__":
    main()
