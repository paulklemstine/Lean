#!/usr/bin/env python3
"""Numerical demonstrations for union-closed set families.

The script uses integer bit masks for finite sets.  It verifies the singleton
injection on an example, exhausts all families on a three-point universe, and
checks the Boolean-cube incidence identities for several dimensions.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, Iterable, List, Sequence, Set, Tuple

SubsetMask = int
Family = Set[SubsetMask]


def subsets(n: int) -> range:
    """Return all subset masks of an n-element universe."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return range(1 << n)


def decode(mask: SubsetMask, n: int) -> frozenset[int]:
    """Decode a subset mask as a frozenset of coordinates."""
    return frozenset(i for i in range(n) if mask & (1 << i))


def family_from_mask(family_mask: int, n: int) -> Family:
    """Decode a bit mask selecting members of the n-dimensional cube."""
    return {a for a in subsets(n) if family_mask & (1 << a)}


def is_union_closed(family: Family) -> bool:
    """Test whether every pairwise union remains in the family."""
    return all((a | b) in family for a in family for b in family)


def frequencies(family: Family, n: int) -> List[int]:
    """Count the number of family members containing each coordinate."""
    return [sum(bool(a & (1 << x)) for a in family) for x in range(n)]


def abundant_elements(family: Family, n: int) -> List[int]:
    """Return coordinates occurring in at least half the members."""
    count = len(family)
    return [x for x, degree in enumerate(frequencies(family, n))
            if 2 * degree >= count and degree > 0]


def singleton_injection(
    family: Family, element: int
) -> Dict[SubsetMask, SubsetMask]:
    """Map each member avoiding element to its union with the singleton.

    Raises ValueError unless the family is union-closed and contains the
    singleton.  The returned dictionary explicitly displays the injection.
    """
    singleton = 1 << element
    if singleton not in family:
        raise ValueError("the required singleton is absent")
    if not is_union_closed(family):
        raise ValueError("the family is not union-closed")
    mapping = {a: a | singleton for a in family if not (a & singleton)}
    assert all(image in family for image in mapping.values())
    assert len(set(mapping.values())) == len(mapping)
    return mapping


@dataclass(frozen=True)
class ThreePointReport:
    """Summary of exhaustive enumeration on a three-element universe."""

    total_families: int
    union_closed_with_nonempty_member: int
    singleton_branch: int
    no_singleton_branch: int
    counterexamples: int


def enumerate_three_point_families() -> ThreePointReport:
    """Exhaust all 256 families and test the three-point theorem."""
    total = 1 << (1 << 3)
    eligible = singleton_branch = residual = counterexamples = 0
    singleton_masks = {1, 2, 4}
    for code in range(total):
        family = family_from_mask(code, 3)
        if not any(a != 0 for a in family) or not is_union_closed(family):
            continue
        eligible += 1
        if family & singleton_masks:
            singleton_branch += 1
        else:
            residual += 1
        if not abundant_elements(family, 3):
            counterexamples += 1
    return ThreePointReport(total, eligible, singleton_branch, residual,
                            counterexamples)


def boolean_cube_statistics(n: int) -> Tuple[int, int, List[int]]:
    """Return member count, total size, and coordinate frequencies."""
    cube = set(subsets(n))
    return len(cube), sum(a.bit_count() for a in cube), frequencies(cube, n)


def demonstrate_singleton_injection() -> None:
    """Print an explicit injection for a representative family."""
    n = 3
    family: Family = {0b000, 0b001, 0b110, 0b111}
    mapping = singleton_injection(family, 0)
    print("Singleton injection example")
    print("  family:", sorted((decode(a, n) for a in family), key=lambda s: (len(s), tuple(s))))
    for source, target in sorted(mapping.items()):
        print(f"  {set(decode(source, n))} -> {set(decode(target, n))}")
    degree = frequencies(family, n)[0]
    print(f"  element 0 frequency: {degree}/{len(family)}; abundant = {2 * degree >= len(family)}")


def demonstrate_three_point_theorem() -> None:
    """Print the complete three-point enumeration report."""
    report = enumerate_three_point_families()
    print("\nThree-point exhaustive classification")
    print(f"  candidate families: {report.total_families}")
    print("  union-closed families with a nonempty member:",
          report.union_closed_with_nonempty_member)
    print(f"  singleton branch: {report.singleton_branch}")
    print(f"  no-singleton branch: {report.no_singleton_branch}")
    print(f"  counterexamples: {report.counterexamples}")
    assert report.counterexamples == 0


def demonstrate_boolean_cube(max_n: int = 8) -> None:
    """Tabulate and assert the exact Boolean-cube identities."""
    print("\nBoolean-cube identities")
    print("  n | members | total size | predicted | coordinate frequencies")
    for n in range(max_n + 1):
        members, total_size, degree = boolean_cube_statistics(n)
        predicted = 0 if n == 0 else n * (1 << (n - 1))
        assert members == 1 << n
        assert total_size == predicted
        assert 2 * total_size == n * members
        if n > 0:
            assert degree == [1 << (n - 1)] * n
        print(f"  {n:1d} | {members:7d} | {total_size:10d} | {predicted:9d} | {degree}")


def main() -> None:
    """Run all numerical demonstrations."""
    demonstrate_singleton_injection()
    demonstrate_three_point_theorem()
    demonstrate_boolean_cube()


if __name__ == "__main__":
    main()
