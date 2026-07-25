#!/usr/bin/env python3
"""Numerical demonstrations of finite dense sumset avoidance.

The program uses only the Python standard library.  Run it directly to see:
1. exact containment counts for one fixed configuration;
2. exact versus union-bound counts for overlapping forbidden configurations;
3. an additive dense-avoidance certificate and an explicit witness.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Iterable, Iterator, Sequence, TypeVar

T = TypeVar("T")
IntSet = FrozenSet[int]
Pair = tuple[IntSet, IntSet]


def powerset(items: Sequence[T]) -> Iterator[FrozenSet[T]]:
    """Yield every subset of items as a frozenset."""
    for size in range(len(items) + 1):
        for choice in combinations(items, size):
            yield frozenset(choice)


def sumset(a: Iterable[int], b: Iterable[int]) -> IntSet:
    """Return the integer sumset A+B."""
    return frozenset(x + y for x in a for y in b)


def lower_tail_count(n: int, d: int) -> int:
    """Count subsets of an n-element universe having cardinality below d."""
    if n < 0 or d < 0:
        raise ValueError("n and d must be nonnegative")
    return sum(comb(n, j) for j in range(min(d, n + 1)))


def exact_superset_count(universe: IntSet, target: IntSet) -> int:
    """Enumerate subsets of universe containing target."""
    if not target <= universe:
        return 0
    return sum(target <= candidate for candidate in powerset(sorted(universe)))


def bad_subset_count(universe: IntSet, forbidden: Iterable[IntSet]) -> int:
    """Count subsets containing at least one forbidden configuration."""
    family = tuple(forbidden)
    return sum(
        any(target <= candidate for target in family)
        for candidate in powerset(sorted(universe))
    )


def union_bound_cost(universe: IntSet, forbidden: Iterable[IntSet]) -> int:
    """Compute the finite containment union bound."""
    n = len(universe)
    family = tuple(forbidden)
    if any(not target <= universe for target in family):
        raise ValueError("every forbidden configuration must lie in the universe")
    return sum(1 << (n - len(target)) for target in family)


def additive_certificate(
    universe: IntSet, pairs: Sequence[Pair], d: int, k: int
) -> tuple[int, int, int, bool]:
    """Return density cost, uniform additive cost, total subsets, and validity."""
    if any(not sumset(a, b) <= universe for a, b in pairs):
        raise ValueError("every prescribed sumset must lie in the universe")
    if any(not a or not b or len(a) < k or len(b) < k for a, b in pairs):
        raise ValueError("each summand must be nonempty and have size at least k")
    n = len(universe)
    exponent = n - (2 * k - 1)
    if exponent < 0:
        # The hypotheses cannot then hold for a sumset contained in U.
        uniform_cost = 0
    else:
        uniform_cost = len(pairs) * (1 << exponent)
    density_cost = lower_tail_count(n, d)
    total = 1 << n
    return density_cost, uniform_cost, total, density_cost + uniform_cost < total


def find_dense_avoider(
    universe: IntSet, forbidden: Iterable[IntSet], d: int
) -> IntSet | None:
    """Find a subset of size at least d containing no forbidden set."""
    family = tuple(dict.fromkeys(forbidden))
    ordered = sorted(universe)
    for size in range(max(d, 0), len(ordered) + 1):
        for choice in combinations(ordered, size):
            candidate = frozenset(choice)
            if all(not target <= candidate for target in family):
                return candidate
    return None


def demo_exact_containment() -> None:
    """Demonstrate the identity 2^(N-|T|)."""
    universe = frozenset(range(8))
    target = frozenset({1, 3, 6})
    observed = exact_superset_count(universe, target)
    predicted = 1 << (len(universe) - len(target))
    print("DEMO 1 — Exact containment count")
    print(f"U has {len(universe)} elements; T has {len(target)} elements.")
    print(f"Enumerated supersets: {observed}; formula: {predicted}.\n")
    assert observed == predicted


def demo_union_bound_overlap() -> None:
    """Show that overlap makes the union bound conservative."""
    universe = frozenset(range(9))
    forbidden = (
        frozenset({0, 1, 2}),
        frozenset({1, 2, 3}),
        frozenset({0, 1, 2, 3}),
    )
    exact = bad_subset_count(universe, forbidden)
    bound = union_bound_cost(universe, forbidden)
    print("DEMO 2 — Overlap among forbidden events")
    print(f"Exact bad subsets: {exact}; union-bound cost: {bound}.")
    print(f"Overcount due to overlap: {bound - exact}.\n")
    assert exact <= bound


def demo_additive_avoidance() -> None:
    """Certify and construct a dense set avoiding prescribed sumsets."""
    universe = frozenset(range(13))
    pairs: list[Pair] = [
        (frozenset({0, 1, 2}), frozenset({0, 1, 2})),
        (frozenset({1, 2, 3}), frozenset({2, 3, 4})),
        (frozenset({0, 2, 4}), frozenset({1, 3, 5})),
    ]
    d, k = 3, 3
    density, additive, total, certified = additive_certificate(universe, pairs, d, k)
    forbidden = tuple(sumset(a, b) for a, b in pairs)
    witness = find_dense_avoider(universe, forbidden, d)
    print("DEMO 3 — Additive dense avoidance")
    print(f"Density-tail cost: {density}")
    print(f"Uniform sumset cost: {additive}")
    print(f"Total subsets: {total}; certificate succeeds: {certified}")
    print(f"Distinct forbidden sumsets: {len(set(forbidden))}")
    print(f"Constructed witness: {sorted(witness) if witness is not None else None}")
    assert certified and witness is not None and len(witness) >= d
    assert all(not target <= witness for target in forbidden)


def main() -> None:
    demo_exact_containment()
    demo_union_bound_overlap()
    demo_additive_avoidance()


if __name__ == "__main__":
    main()
