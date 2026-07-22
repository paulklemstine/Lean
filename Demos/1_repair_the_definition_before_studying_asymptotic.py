#!/usr/bin/env python3
"""Numerical demonstrations for a globally pair-sum-avoiding greedy sequence.

The repaired rule starts at 1 and repeatedly chooses the least integer larger
than the current term that is not a sum of two terms already present. Repeated
summands are allowed. This script generates examples, checks finite prefixes,
enumerates chronological additive triples, and contrasts the construction with
the triangular list 1, 1, 2, 4, 7, ... .
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class PrefixReport:
    """A diagnostic report for a proposed finite greedy prefix."""

    valid: bool
    checked_terms: int
    message: str


def pair_sums(values: Sequence[int]) -> set[int]:
    """Return all x + y from values, allowing x and y to be the same entry."""
    return {x + y for x in values for y in values}


def greedy_sequence(length: int, initial: int = 1) -> list[int]:
    """Generate a globally pair-sum-avoiding greedy prefix.

    The pair-sum set is maintained incrementally. ``initial`` must be positive,
    and ``length`` must be nonnegative.
    """
    if length < 0:
        raise ValueError("length must be nonnegative")
    if initial <= 0:
        raise ValueError("initial must be positive")
    if length == 0:
        return []

    values = [initial]
    forbidden = {2 * initial}
    while len(values) < length:
        candidate = values[-1] + 1
        while candidate in forbidden:
            candidate += 1
        old_values = tuple(values)
        values.append(candidate)
        for value in old_values:
            forbidden.add(value + candidate)
        forbidden.add(2 * candidate)
    return values


def chronological_additive_triples(
    values: Sequence[int],
) -> list[tuple[int, int, int]]:
    """List ordered triples (i, j, k) with i,j < k and a[i] + a[j] = a[k]."""
    triples: list[tuple[int, int, int]] = []
    for k in range(len(values)):
        for i in range(k):
            for j in range(k):
                if values[i] + values[j] == values[k]:
                    triples.append((i, j, k))
    return triples


def verify_greedy_prefix(values: Sequence[int], required_initial: int = 1) -> PrefixReport:
    """Check initial value, admissibility, and minimality at every finite step."""
    if not values:
        return PrefixReport(False, 0, "the prefix is empty")
    if values[0] != required_initial:
        return PrefixReport(
            False, 1, f"expected initial value {required_initial}, found {values[0]}"
        )

    for n in range(len(values) - 1):
        history = values[: n + 1]
        current = values[n]
        successor = values[n + 1]
        forbidden = pair_sums(history)
        if successor <= current:
            return PrefixReport(
                False,
                n + 2,
                f"step {n + 1}: {successor} does not exceed {current}",
            )
        if successor in forbidden:
            return PrefixReport(
                False,
                n + 2,
                f"step {n + 1}: {successor} is a prior pair sum",
            )
        skipped = [w for w in range(current + 1, successor) if w not in forbidden]
        if skipped:
            return PrefixReport(
                False,
                n + 2,
                f"step {n + 1}: smaller admissible candidate {skipped[0]} was skipped",
            )
    return PrefixReport(True, len(values), "every checked successor is greedily admissible")


def growth_ceiling_margins(values: Sequence[int]) -> list[int]:
    """Return (2*a[n] + 1) - a[n+1] for each adjacent pair."""
    return [2 * values[n] + 1 - values[n + 1] for n in range(len(values) - 1)]


def triangular_display(length: int) -> list[int]:
    """Return the displayed values 1 + n(n-1)/2 for n = 0,...,length-1."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    return [1 + n * (n - 1) // 2 for n in range(length)]


def format_triples(values: Sequence[int], triples: Iterable[tuple[int, int, int]]) -> str:
    """Format additive triples with both their indices and values."""
    rendered = [
        f"({i}, {j}, {k}): {values[i]} + {values[j]} = {values[k]}"
        for i, j, k in triples
    ]
    return "none" if not rendered else "; ".join(rendered)


def run_demo(length: int = 16) -> None:
    """Print three demonstrations of generation, bounds, and prefix failure."""
    generated = greedy_sequence(length)
    report = verify_greedy_prefix(generated)
    triples = chronological_additive_triples(generated)
    margins = growth_ceiling_margins(generated)

    print("DEMO 1 — Greedy global pair-sum avoidance")
    print(f"first {length} terms: {generated}")
    print(f"prefix certificate: {report.message}")
    print(f"chronological additive triples: {format_triples(generated, triples)}")
    print(f"matches 2n+1 on this finite range: {generated == [2*n+1 for n in range(length)]}")
    print()

    print("DEMO 2 — One-step ceiling a[n+1] <= 2*a[n] + 1")
    for n, margin in enumerate(margins):
        print(
            f"n={n:2d}: a[n+1]={generated[n+1]:3d}, "
            f"ceiling={2*generated[n]+1:3d}, slack={margin:3d}"
        )
    print()

    displayed = triangular_display(max(6, min(length, 12)))
    displayed_report = verify_greedy_prefix(displayed)
    displayed_triples = chronological_additive_triples(displayed)
    print("DEMO 3 — Diagnostic for the triangular displayed list")
    print(f"displayed values: {displayed}")
    print(f"prefix certificate: {displayed_report.message}")
    print(
        "chronological additive triples: "
        f"{format_triples(displayed, displayed_triples[:8])}"
    )


if __name__ == "__main__":
    run_demo()
