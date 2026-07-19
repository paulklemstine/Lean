#!/usr/bin/env python3
"""Finite examples of canonical forbidden bases in partially ordered sets.

The script uses subset inclusion as a transparent model of a minor order.  It
extracts minimal forbidden objects, verifies the avoidance characterization,
and demonstrates the intersection theorem.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, Iterable, Sequence, TypeVar

T = TypeVar("T")
Order = Callable[[T, T], bool]


def powerset(items: Sequence[int]) -> list[FrozenSet[int]]:
    """Return all subsets of ``items`` as immutable sets."""
    return [
        frozenset(choice)
        for size in range(len(items) + 1)
        for choice in combinations(items, size)
    ]


def minimal_members(objects: Iterable[T], leq: Order[T]) -> list[T]:
    """Extract the elements having no distinct smaller member in ``objects``.

    For n objects this direct algorithm uses O(n^2) order tests and O(n)
    storage.  It is suitable for finite demonstrations and exact small data.
    """
    data = list(objects)
    return [
        x
        for x in data
        if not any(y != x and leq(y, x) for y in data)
    ]


def canonical_forbidden_basis(
    universe: Iterable[T], belongs: Callable[[T], bool], leq: Order[T]
) -> list[T]:
    """Return the minimal members of the complement of a lower class."""
    outsiders = [x for x in universe if not belongs(x)]
    return minimal_members(outsiders, leq)


def avoids_basis(x: T, basis: Iterable[T], leq: Order[T]) -> bool:
    """Decide membership by testing that no basis element lies below x."""
    return all(not leq(obstruction, x) for obstruction in basis)


def pretty_set(s: FrozenSet[int]) -> str:
    """Format a finite set deterministically."""
    return "{" + ", ".join(map(str, sorted(s))) + "}"


def verify_subset_example() -> None:
    """Verify the finite-basis theorem in the subset lattice on four points."""
    universe = powerset([1, 2, 3, 4])
    leq: Order[FrozenSet[int]] = lambda left, right: left <= right
    class_c = lambda s: len(s) <= 2
    basis_c = canonical_forbidden_basis(universe, class_c, leq)

    assert len(basis_c) == 4
    assert all(len(s) == 3 for s in basis_c)
    assert all(class_c(x) == avoids_basis(x, basis_c, leq) for x in universe)

    print("Example 1 — subsets of size at most two")
    print("Canonical forbidden basis:")
    print("  " + ", ".join(pretty_set(s) for s in basis_c))
    print("Avoidance criterion verified on all 16 subsets.\n")


def verify_intersection_example() -> None:
    """Verify that intersection obstructions come from constituent bases."""
    universe = powerset([1, 2, 3, 4])
    leq: Order[FrozenSet[int]] = lambda left, right: left <= right
    class_c = lambda s: len(s) <= 2
    class_d = lambda s: not frozenset({1, 2}) <= s
    intersection = lambda s: class_c(s) and class_d(s)

    basis_c = canonical_forbidden_basis(universe, class_c, leq)
    basis_d = canonical_forbidden_basis(universe, class_d, leq)
    basis_intersection = canonical_forbidden_basis(universe, intersection, leq)

    assert set(basis_intersection) <= set(basis_c) | set(basis_d)
    assert all(
        intersection(x) == avoids_basis(x, basis_intersection, leq)
        for x in universe
    )

    print("Example 2 — intersection of two lower classes")
    print("First basis:  " + ", ".join(pretty_set(s) for s in basis_c))
    print("Second basis: " + ", ".join(pretty_set(s) for s in basis_d))
    print("Intersection basis:")
    print("  " + ", ".join(pretty_set(s) for s in basis_intersection))
    print("Every intersection obstruction occurs in a constituent basis.\n")


def verify_divisibility_example(limit: int = 100) -> None:
    """Check the basis {6, 10} in a finite divisibility window."""
    universe = list(range(1, limit + 1))
    divides: Order[int] = lambda a, b: b % a == 0
    belongs = lambda n: n % 6 != 0 and n % 10 != 0
    basis = canonical_forbidden_basis(universe, belongs, divides)

    assert basis == [6, 10]
    assert all(belongs(n) == avoids_basis(n, basis, divides) for n in universe)

    print(f"Example 3 — divisibility order on 1 through {limit}")
    print(f"Canonical forbidden basis: {basis}")
    print(f"Avoidance criterion verified for all {limit} integers.")


def main() -> None:
    verify_subset_example()
    verify_intersection_example()
    verify_divisibility_example()


if __name__ == "__main__":
    main()
