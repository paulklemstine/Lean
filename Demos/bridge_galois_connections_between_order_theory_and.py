#!/usr/bin/env python3
"""Numerical demonstrations of order–topology and closure phenomena."""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, Iterable, Sequence, TypeVar

T = TypeVar("T")
Subset = FrozenSet[int]


def powerset(items: Sequence[T]) -> list[FrozenSet[T]]:
    """Return all subsets of a finite sequence as frozensets."""
    return [frozenset(choice) for size in range(len(items) + 1)
            for choice in combinations(items, size)]


def is_upper_set(subset: FrozenSet[T], points: Sequence[T],
                 leq: Callable[[T, T], bool]) -> bool:
    """Test whether a subset is upward closed in a finite preorder."""
    return all(not (x in subset and leq(x, y)) or y in subset
               for x in points for y in points)


def is_monotone(points: Sequence[T], values: dict[T, T],
                leq: Callable[[T, T], bool]) -> bool:
    """Test monotonicity of a self-map on a finite preorder."""
    return all(not leq(x, y) or leq(values[x], values[y])
               for x in points for y in points)


def is_alexandrov_continuous(points: Sequence[T], values: dict[T, T],
                             leq: Callable[[T, T], bool]) -> bool:
    """Test continuity by checking inverse images of every upper open set."""
    opens = [u for u in powerset(points) if is_upper_set(u, points, leq)]
    return all(is_upper_set(frozenset(x for x in points if values[x] in u),
                            points, leq) for u in opens)


def bad_closure(subset: Subset) -> Subset:
    """Close to {0,1,2} exactly when both 0 and 1 are present."""
    universe = frozenset({0, 1, 2})
    return universe if {0, 1}.issubset(subset) else subset


def radical_monomial_exponent(exponent: int) -> int:
    """Return the exponent generating the radical of (x^exponent) in k[x]."""
    if exponent < 1:
        raise ValueError("the exponent must be positive")
    return 1


def demonstrate_order_topology() -> None:
    points = [0, 1, 2, 3]
    leq = lambda x, y: x <= y
    monotone_map = {0: 0, 1: 1, 2: 1, 3: 3}
    nonmonotone_map = {0: 0, 1: 2, 2: 1, 3: 3}
    opens = [u for u in powerset(points) if is_upper_set(u, points, leq)]

    print("Upper Alexandrov opens on the chain 0 ≤ 1 ≤ 2 ≤ 3:")
    print([sorted(u) for u in opens])
    for name, mapping in [("monotone", monotone_map),
                          ("nonmonotone", nonmonotone_map)]:
        print(f"{name:11s}: monotone={is_monotone(points, mapping, leq)}, "
              f"continuous={is_alexandrov_continuous(points, mapping, leq)}")


def demonstrate_fixed_points_and_union_failure() -> None:
    subsets = powerset([0, 1, 2])
    fixed = [s for s in subsets if bad_closure(s) == s]
    a, b = frozenset({0}), frozenset({1})

    print("\nFixed subsets of the three-point closure:")
    print([sorted(s) for s in fixed])
    print("Closure of A union B:", sorted(bad_closure(a | b)))
    print("Closure of A union closure of B:",
          sorted(bad_closure(a) | bad_closure(b)))
    print("Binary-union law holds:",
          bad_closure(a | b) == bad_closure(a) | bad_closure(b))
    ambient_join = a | b
    fixed_point_join = bad_closure(ambient_join)
    print("Ambient union of fixed sets:", sorted(ambient_join))
    print("Join inside the fixed-point lattice:", sorted(fixed_point_join))


def demonstrate_radicalization() -> None:
    print("\nMonomial ideals (x^n) and their radical generators:")
    for exponent in range(1, 7):
        radical = radical_monomial_exponent(exponent)
        print(f"rad((x^{exponent})) = (x^{radical})")


def main() -> None:
    demonstrate_order_topology()
    demonstrate_fixed_points_and_union_failure()
    demonstrate_radicalization()


if __name__ == "__main__":
    main()
