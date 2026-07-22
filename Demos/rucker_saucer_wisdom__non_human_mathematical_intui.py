#!/usr/bin/env python3
"""Numerical demonstrations of universal cores, finite geometry, and primes."""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Callable, Iterable


@dataclass(frozen=True)
class FiniteGeometry:
    """A finite incidence geometry represented by an incidence predicate."""

    name: str
    points: tuple[int, ...]
    lines: tuple[int, ...]
    incident: Callable[[int, int], bool]


def are_parallel(geometry: FiniteGeometry, first: int, second: int) -> bool:
    """Return whether two lines have no common incident point."""
    return not any(
        geometry.incident(point, first) and geometry.incident(point, second)
        for point in geometry.points
    )


def playfair_report(
    geometry: FiniteGeometry,
) -> list[tuple[int, int, tuple[int, ...]]]:
    """List each external point-line pair and all admissible parallels."""
    report: list[tuple[int, int, tuple[int, ...]]] = []
    for point in geometry.points:
        for line in geometry.lines:
            if not geometry.incident(point, line):
                candidates = tuple(
                    candidate
                    for candidate in geometry.lines
                    if geometry.incident(point, candidate)
                    and are_parallel(geometry, candidate, line)
                )
                report.append((point, line, candidates))
    return report


def satisfies_playfair(geometry: FiniteGeometry) -> bool:
    """Check Playfair's unique-parallel condition by exhaustive enumeration."""
    return all(len(candidates) == 1 for _, _, candidates in playfair_report(geometry))


def is_prime(number: int) -> bool:
    """Test ordinary primality by trial division."""
    if number < 2:
        return False
    if number % 2 == 0:
        return number == 2
    return all(number % divisor != 0 for divisor in range(3, isqrt(number) + 1, 2))


def primes_above(bound: int, count: int) -> list[int]:
    """Return the first ``count`` ordinary primes strictly above ``bound``."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    result: list[int] = []
    candidate = max(2, bound + 1)
    while len(result) < count:
        if is_prime(candidate):
            result.append(candidate)
        candidate += 1
    return result


def tropical_factorizations(number: int) -> list[tuple[int, int]]:
    """Return nontrivial factorizations for tropical multiplication a⊙b=a+b."""
    if number < 0:
        raise ValueError("tropical natural numbers must be nonnegative")
    return [(left, number - left) for left in range(1, number) if number - left > 0]


def is_tropically_irreducible(number: int) -> bool:
    """Test nonzero tropical irreducibility in the natural numbers."""
    return number != 0 and not tropical_factorizations(number)


def finite_universal_core(
    base_closure: set[str], consistent_extension_closures: Iterable[set[str]]
) -> set[str]:
    """Intersect finite consequence sets used to illustrate a universal core."""
    core: set[str] | None = None
    for closure in consistent_extension_closures:
        if not base_closure <= closure:
            raise ValueError("every extension closure must contain the base closure")
        core = set(closure) if core is None else core & closure
    if core is None:
        raise ValueError("at least one consistent extension is required")
    return core


def main() -> None:
    points = lines = (0, 1, 2)
    affine = FiniteGeometry("affine", points, lines, lambda p, line: p == line)
    intersecting = FiniteGeometry(
        "intersecting", points, lines, lambda p, line: p == 0 or p == line
    )

    print("FINITE PARALLEL-POSTULATE EXPERIMENT")
    for geometry in (affine, intersecting):
        print(f"\n{geometry.name.title()} world")
        for point, line, candidates in playfair_report(geometry):
            print(f"  external point {point}, line {line}: parallels {candidates}")
        print(f"  Playfair holds: {satisfies_playfair(geometry)}")

    print("\nORDINARY AND TROPICAL FACTORIZATION")
    print(f"  First five primes above 100: {primes_above(100, 5)}")
    for number in range(0, 9):
        factors = tropical_factorizations(number)
        print(
            f"  {number}: irreducible={is_tropically_irreducible(number)}, "
            f"nontrivial tropical factorizations={factors}"
        )

    print("\nFINITE UNIVERSAL-CORE ILLUSTRATION")
    base = {"A", "B"}
    extensions = [{"A", "B", "C"}, {"A", "B", "D"}, {"A", "B", "E", "F"}, base]
    print(f"  Base closure: {sorted(base)}")
    print(f"  Intersection of extension closures: {sorted(finite_universal_core(base, extensions))}")


if __name__ == "__main__":
    main()
