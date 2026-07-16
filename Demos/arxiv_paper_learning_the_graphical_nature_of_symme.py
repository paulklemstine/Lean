#!/usr/bin/env python3
"""Numerical demonstrations of translation invariants in finite Cayley graphs.

The script uses only the Python standard library.  It checks cyclic groups and
the noncommutative symmetric group S3, verifies all translation and difference
identities, and prints representative common-neighborhood signatures.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from typing import Callable, Generic, Hashable, Iterable, TypeVar

T = TypeVar("T", bound=Hashable)


@dataclass(frozen=True)
class FiniteGroup(Generic[T]):
    """A finite group supplied by its elements, product, inverse, and identity."""

    elements: tuple[T, ...]
    multiply: Callable[[T, T], T]
    inverse: Callable[[T], T]
    identity: T


def cyclic_group(n: int) -> FiniteGroup[int]:
    """Return the additive cyclic group of order n."""
    if n <= 0:
        raise ValueError("The order must be positive")
    return FiniteGroup(tuple(range(n)), lambda a, b: (a + b) % n,
                       lambda a: (-a) % n, 0)


Permutation = tuple[int, ...]


def symmetric_group_3() -> FiniteGroup[Permutation]:
    """Return S3; multiplication composes maps from right to left."""
    elements = tuple(permutations(range(3)))

    def multiply(p: Permutation, q: Permutation) -> Permutation:
        return tuple(p[q[i]] for i in range(3))

    def inverse(p: Permutation) -> Permutation:
        result = [0, 0, 0]
        for i, image in enumerate(p):
            result[image] = i
        return tuple(result)

    return FiniteGroup(elements, multiply, inverse, (0, 1, 2))


def difference(group: FiniteGroup[T], a: T, b: T) -> T:
    """Compute the left-relative element a^{-1}b."""
    return group.multiply(group.inverse(a), b)


def validate_connection_set(group: FiniteGroup[T], connection: set[T]) -> None:
    """Check that the connection set defines a simple undirected Cayley graph."""
    if group.identity in connection:
        raise ValueError("The identity would create loops")
    if any(group.inverse(s) not in connection for s in connection):
        raise ValueError("The connection set must be inverse-closed")


def adjacent(group: FiniteGroup[T], connection: set[T], a: T, b: T) -> bool:
    """Test Cayley adjacency."""
    return difference(group, a, b) in connection


def neighbors(group: FiniteGroup[T], connection: set[T], a: T) -> set[T]:
    """Return the neighborhood of a."""
    return {x for x in group.elements if adjacent(group, connection, a, x)}


def common_neighbors(
    group: FiniteGroup[T], connection: set[T], a: T, b: T
) -> set[T]:
    """Return vertices adjacent to both a and b."""
    return neighbors(group, connection, a) & neighbors(group, connection, b)


def induced_edges(
    group: FiniteGroup[T], connection: set[T], vertices: Iterable[T]
) -> set[frozenset[T]]:
    """Return undirected edges induced by the supplied vertices."""
    items = tuple(vertices)
    return {
        frozenset((items[i], items[j]))
        for i in range(len(items))
        for j in range(i + 1, len(items))
        if adjacent(group, connection, items[i], items[j])
    }


def common_profile(group: FiniteGroup[T], connection: set[T]) -> dict[T, int]:
    """Compute kappa(g)=|C(e,g)| for all differences g."""
    return {
        g: len(common_neighbors(group, connection, group.identity, g))
        for g in group.elements
    }


def verify_theorems(group: FiniteGroup[T], connection: set[T]) -> None:
    """Exhaustively check degree, pair-difference, and induced-edge transport."""
    validate_connection_set(group, connection)
    identity_degree = len(neighbors(group, connection, group.identity))
    assert all(len(neighbors(group, connection, a)) == identity_degree
               for a in group.elements)

    for a in group.elements:
        inv_a = group.inverse(a)
        for b in group.elements:
            g = difference(group, a, b)
            source = common_neighbors(group, connection, a, b)
            target = common_neighbors(group, connection, group.identity, g)
            transported = {group.multiply(inv_a, x) for x in source}
            assert transported == target
            source_edges = induced_edges(group, connection, source)
            transported_edges = {
                frozenset(group.multiply(inv_a, x) for x in edge)
                for edge in source_edges
            }
            assert transported_edges == induced_edges(group, connection, target)


def demonstrate_cyclic_group() -> None:
    """Display the worked Z/8Z example and its complete difference profile."""
    group = cyclic_group(8)
    connection = {1, 2, 6, 7}
    verify_theorems(group, connection)
    a, b = 2, 5
    g = difference(group, a, b)
    source = common_neighbors(group, connection, a, b)
    target = common_neighbors(group, connection, group.identity, g)
    transported = {group.multiply(group.inverse(a), x) for x in source}
    print("Z/8Z with steps ±1, ±2")
    print(f"  all degrees: {[len(neighbors(group, connection, x)) for x in group.elements]}")
    print(f"  pair ({a}, {b}) has difference {g}")
    print(f"  C({a},{b}) = {sorted(source)} -> C(0,{g}) = {sorted(target)}")
    print(f"  translated common neighbors: {sorted(transported)}")
    print(f"  difference profile: {common_profile(group, connection)}")
    print(f"  induced edges before/after: {len(induced_edges(group, connection, source))}/"
          f"{len(induced_edges(group, connection, target))}")


def demonstrate_noncommutative_group() -> None:
    """Exhaustively verify the results for S3 generated by transpositions."""
    group = symmetric_group_3()
    identity = group.identity
    connection = {p for p in group.elements if p != identity and group.inverse(p) == p}
    verify_theorems(group, connection)
    profile = common_profile(group, connection)
    print("\nS3 with all transpositions")
    print(f"  vertices: {len(group.elements)}, connection size: {len(connection)}")
    print(f"  uniform degree: {len(connection)}")
    print(f"  common-neighbor counts by difference: {list(profile.values())}")
    print("  exhaustive translation and induced-edge checks passed")


def main() -> None:
    demonstrate_cyclic_group()
    demonstrate_noncommutative_group()


if __name__ == "__main__":
    main()
