#!/usr/bin/env python3
"""Numerical demonstrations for completeness and finite-deletion fragility.

The infinite set E consists of every even nonnegative integer together with 1.
Every natural number has a direct distinct-subset representation from E, but
removing 1 leaves only even subset sums.  This script constructs direct
representations, enumerates bounded subset sums of finite truncations, and
reports the parity obstruction exposed by deletion.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class Experiment:
    """Summary of one bounded subset-sum experiment."""

    available: tuple[int, ...]
    target_bound: int
    reachable: frozenset[int]

    @property
    def missing(self) -> tuple[int, ...]:
        return tuple(n for n in range(self.target_bound + 1) if n not in self.reachable)


def parity_set_truncation(max_even: int, include_one: bool = True) -> list[int]:
    """Return all even integers through ``max_even``, optionally with 1."""
    if max_even < 0:
        raise ValueError("max_even must be nonnegative")
    values = list(range(0, max_even + 1, 2))
    if include_one:
        values.append(1)
    return sorted(set(values))


def direct_representation(n: int) -> tuple[int, ...]:
    """Construct a distinct-subset representation of n from 2N union {1}."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        return ()
    if n % 2 == 0:
        return (n,)
    if n == 1:
        return (1,)
    return (1, n - 1)


def bounded_subset_sums(values: Iterable[int], target_bound: int) -> set[int]:
    """Compute all distinct subset sums not exceeding ``target_bound``.

    Each input value is processed once.  The snapshot on each iteration is
    essential: it prevents an element from being reused in the same update.
    """
    if target_bound < 0:
        raise ValueError("target_bound must be nonnegative")
    unique_values = sorted(set(values))
    if any(value < 0 for value in unique_values):
        raise ValueError("all values must be nonnegative")
    reachable = {0}
    for value in unique_values:
        previous = tuple(reachable)
        reachable.update(total + value for total in previous if total + value <= target_bound)
    return reachable


def run_experiment(values: Iterable[int], target_bound: int) -> Experiment:
    """Package the inputs and output of bounded subset-sum enumeration."""
    available = tuple(sorted(set(values)))
    return Experiment(available, target_bound, frozenset(bounded_subset_sums(available, target_bound)))


def missing_residues(experiment: Experiment, modulus: int) -> dict[int, tuple[int, ...]]:
    """Group missing targets by residue class modulo ``modulus``."""
    if modulus < 2:
        raise ValueError("modulus must be at least 2")
    return {
        residue: tuple(n for n in experiment.missing if n % modulus == residue)
        for residue in range(modulus)
    }


def verify_direct_representations(limit: int) -> None:
    """Check the explicit representation formula through ``limit``."""
    if limit < 0:
        raise ValueError("limit must be nonnegative")
    for n in range(limit + 1):
        summands = direct_representation(n)
        assert len(summands) == len(set(summands)), (n, summands)
        assert sum(summands) == n, (n, summands)
        assert all(value == 1 or value % 2 == 0 for value in summands), (n, summands)


def text_bar(experiment: Experiment, width: int = 80) -> str:
    """Render reachable targets as filled squares and missing targets as dots."""
    symbols = ["■" if n in experiment.reachable else "·" for n in range(experiment.target_bound + 1)]
    return "\n".join("".join(symbols[i : i + width]) for i in range(0, len(symbols), width))


def main() -> None:
    max_even = 40
    target_bound = 100
    verify_direct_representations(target_bound)

    intact_values = parity_set_truncation(max_even, include_one=True)
    deleted_values = parity_set_truncation(max_even, include_one=False)
    intact = run_experiment(intact_values, target_bound)
    after_deletion = run_experiment(deleted_values, target_bound)

    print("Direct representations from E = 2N union {1}")
    for n in range(12):
        representation = direct_representation(n)
        expression = " + ".join(map(str, representation)) if representation else "empty sum"
        print(f"  {n:2d} = {expression}")

    print(f"\nFinite truncation through the even value {max_even}; targets 0..{target_bound}")
    print("■ = reachable, · = missing")
    print("\nBefore deleting 1:")
    print(text_bar(intact))
    print(f"Missing targets: {intact.missing}")

    print("\nAfter deleting 1:")
    print(text_bar(after_deletion))
    print(f"Missing targets: {after_deletion.missing}")

    residues = missing_residues(after_deletion, 2)
    print("\nMissing targets grouped modulo 2:")
    for residue, targets in residues.items():
        print(f"  residue {residue}: {targets}")

    assert all(total % 2 == 0 for total in after_deletion.reachable)
    assert all(odd in after_deletion.missing for odd in range(1, target_bound + 1, 2))
    print("\nConfirmed in the bounded experiment: deletion of 1 leaves only even sums.")


if __name__ == "__main__":
    main()
