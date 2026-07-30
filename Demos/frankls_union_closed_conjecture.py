#!/usr/bin/env python3
"""Numerical demonstrations for finite union-closed families.

The script uses integer bit masks for subsets. It exhaustively verifies the
three-point theorem, checks Boolean-cube incidence identities, illustrates the
greatest member, and computes the Euler--Mascheroni divergence partial sums.
Only the Python standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import log
from typing import Iterable, Iterator, Sequence

Subset = int
Family = tuple[Subset, ...]


def subsets(n: int) -> range:
    """Return all subset masks of an n-element universe."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return range(1 << n)


def decode_subset(mask: Subset, n: int) -> frozenset[int]:
    """Convert a bit mask to a readable immutable set."""
    return frozenset(i for i in range(n) if mask & (1 << i))


def families(n: int) -> Iterator[Family]:
    """Generate every family on n points exactly once."""
    subset_count = 1 << n
    for family_mask in range(1 << subset_count):
        yield tuple(a for a in range(subset_count) if family_mask & (1 << a))


def is_union_closed(family: Sequence[Subset]) -> bool:
    """Test whether every pairwise bitwise union remains in the family."""
    members = set(family)
    return all((a | b) in members for a in family for b in family)


def frequencies(family: Sequence[Subset], n: int) -> tuple[int, ...]:
    """Count how many family members contain each point."""
    return tuple(sum(bool(a & (1 << x)) for a in family) for x in range(n))


def abundant_points(family: Sequence[Subset], n: int) -> tuple[int, ...]:
    """Return active points occurring in at least half of the family."""
    active = 0
    for a in family:
        active |= a
    counts = frequencies(family, n)
    return tuple(
        x for x, count in enumerate(counts)
        if active & (1 << x) and 2 * count >= len(family)
    )


def top_member(family: Sequence[Subset]) -> Subset:
    """Compute the union of every member."""
    top = 0
    for a in family:
        top |= a
    return top


@dataclass(frozen=True)
class VerificationSummary:
    universe_size: int
    total_families: int
    nontrivial_union_closed: int
    singleton_branch: int
    no_singleton_branch: int
    counterexamples: int


def verify_frankl_small_universe(n: int) -> VerificationSummary:
    """Exhaustively test Frankl's property on an n-point universe."""
    total = 0
    qualifying = 0
    singleton_branch = 0
    no_singleton_branch = 0
    counterexamples = 0
    singleton_masks = {1 << x for x in range(n)}
    for family in families(n):
        total += 1
        if not any(a != 0 for a in family) or not is_union_closed(family):
            continue
        qualifying += 1
        if singleton_masks.intersection(family):
            singleton_branch += 1
        else:
            no_singleton_branch += 1
        if not abundant_points(family, n):
            counterexamples += 1
    return VerificationSummary(
        n, total, qualifying, singleton_branch, no_singleton_branch,
        counterexamples,
    )


def boolean_cube_statistics(n: int) -> tuple[int, int, tuple[int, ...]]:
    """Return cube cardinality, total member size, and point frequencies."""
    cube = tuple(subsets(n))
    return len(cube), sum(a.bit_count() for a in cube), frequencies(cube, n)


def exponential_kl(rate1: float, rate2: float) -> float:
    """KL divergence from Exp(rate1) to Exp(rate2)."""
    if rate1 <= 0.0 or rate2 <= 0.0:
        raise ValueError("rates must be positive")
    return log(rate1 / rate2) + rate2 / rate1 - 1.0


def gamma_divergence_partial_sum(n: int) -> float:
    """Sum consecutive exponential divergences from rates 1 through n+1."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return sum(exponential_kl(k + 1.0, k + 2.0) for k in range(n))


def harmonic_log_approximation(n: int) -> float:
    """Compute H_n - log(n+1), equal to the divergence partial sum."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    harmonic = sum(1.0 / j for j in range(1, n + 1))
    return harmonic - log(n + 1.0)


def main() -> None:
    print("THREE-POINT EXHAUSTIVE VERIFICATION")
    summary = verify_frankl_small_universe(3)
    print(summary)
    assert summary.total_families == 256
    assert summary.counterexamples == 0

    print("\nBOOLEAN-CUBE IDENTITIES")
    for n in range(0, 9):
        cardinality, total_size, point_counts = boolean_cube_statistics(n)
        assert cardinality == 2**n
        assert 2 * total_size == n * cardinality
        if n > 0:
            assert all(count == 2 ** (n - 1) for count in point_counts)
        print(
            f"n={n}: members={cardinality:3d}, total size={total_size:4d}, "
            f"frequencies={point_counts}"
        )

    print("\nGREATEST-MEMBER EXAMPLE")
    example: Family = (0b001, 0b010, 0b011, 0b101, 0b111)
    assert is_union_closed(example)
    top = top_member(example)
    assert top in example and all((a | top) == top for a in example)
    print("family:", [sorted(decode_subset(a, 3)) for a in example])
    print("top:", sorted(decode_subset(top, 3)))
    print("frequencies:", frequencies(example, 3))
    print("abundant points:", abundant_points(example, 3))

    print("\nEULER--MASCHERONI INFORMATION IDENTITY")
    for n in (1, 2, 5, 10, 100, 1000):
        divergence_sum = gamma_divergence_partial_sum(n)
        harmonic_form = harmonic_log_approximation(n)
        assert abs(divergence_sum - harmonic_form) < 1e-12
        print(f"n={n:4d}: cumulative divergence={divergence_sum:.12f}")


if __name__ == "__main__":
    main()
