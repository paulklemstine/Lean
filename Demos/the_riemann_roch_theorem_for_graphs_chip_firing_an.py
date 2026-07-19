#!/usr/bin/env python3
"""Numerical demonstrations for divisors and chip-firing on complete graphs."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations_with_replacement
from typing import Iterable, Iterator, Sequence


@dataclass(frozen=True)
class CompleteGraphData:
    """Canonical divisor data for the complete graph on n vertices."""

    n: int
    valency: int
    canonical_coefficient: int
    genus: int
    canonical_degree: int
    canonical_rank: int


def complete_graph_data(n: int) -> CompleteGraphData:
    """Compute the complete-graph formulas, with rank from Riemann--Roch."""
    if n < 1:
        raise ValueError("n must be positive")
    valency = n - 1
    coefficient = valency - 2
    genus = (n - 1) * (n - 2) // 2
    canonical_degree = n * coefficient
    canonical_rank = genus - 1
    assert canonical_degree == 2 * genus - 2
    return CompleteGraphData(
        n, valency, coefficient, genus, canonical_degree, canonical_rank
    )


def degree(divisor: Sequence[int]) -> int:
    """Return the sum of the divisor coefficients."""
    return sum(divisor)


def fire_vertex(divisor: Sequence[int], vertex: int) -> list[int]:
    """Fire one vertex of K_n once and return the new divisor."""
    n = len(divisor)
    if not 0 <= vertex < n:
        raise IndexError("vertex is outside the graph")
    result = [value + 1 for value in divisor]
    result[vertex] -= n
    assert degree(result) == degree(divisor)
    return result


def apply_firing_script(
    divisor: Sequence[int], script: Sequence[int]
) -> list[int]:
    """Apply simultaneous integral firings on K_n in linear time.

    Positive script entries fire vertices; negative entries reverse-fire them.
    """
    if len(divisor) != len(script):
        raise ValueError("divisor and script must have equal lengths")
    n = len(divisor)
    total_firings = sum(script)
    result = [
        divisor[i] - n * script[i] + total_firings for i in range(n)
    ]
    assert degree(result) == degree(divisor)
    return result


def effective_divisors(n: int, total: int) -> Iterator[tuple[int, ...]]:
    """Enumerate all effective divisors of a prescribed degree."""
    if n < 1 or total < 0:
        return
    for positions in combinations_with_replacement(range(n), total):
        values = [0] * n
        for position in positions:
            values[position] += 1
        yield tuple(values)


def canonical_divisor(n: int) -> list[int]:
    """Return the coefficient vector of the canonical divisor of K_n."""
    data = complete_graph_data(n)
    return [data.canonical_coefficient] * n


def print_invariant_table(ns: Iterable[int]) -> None:
    """Print complete-graph canonical data in aligned columns."""
    header = ("n", "valency", "K(v)", "genus", "deg(K)", "r(K)")
    print("  ".join(f"{item:>8}" for item in header))
    for n in ns:
        d = complete_graph_data(n)
        row = (
            d.n,
            d.valency,
            d.canonical_coefficient,
            d.genus,
            d.canonical_degree,
            d.canonical_rank,
        )
        print("  ".join(f"{item:>8}" for item in row))


def demonstrate_firing() -> None:
    """Show degree preservation for individual and scripted firing on K_5."""
    initial = canonical_divisor(5)
    once = fire_vertex(initial, 0)
    script = [2, -1, 0, 1, 0]
    scripted = apply_firing_script(initial, script)
    print("\nChip-firing on K_5")
    print(f"canonical divisor: {initial}, degree {degree(initial)}")
    print(f"fire vertex 0:    {once}, degree {degree(once)}")
    print(f"script {script}: {scripted}, degree {degree(scripted)}")


def demonstrate_effective_removals() -> None:
    """List the degree-two effective removals on K_3."""
    removals = list(effective_divisors(3, 2))
    print("\nEffective degree-two divisors on three vertices")
    print(*removals, sep="\n")
    assert len(removals) == 6


def main() -> None:
    """Run all numerical demonstrations."""
    print("Complete-graph canonical invariants")
    print_invariant_table(range(3, 7))
    demonstrate_firing()
    demonstrate_effective_removals()


if __name__ == "__main__":
    main()
