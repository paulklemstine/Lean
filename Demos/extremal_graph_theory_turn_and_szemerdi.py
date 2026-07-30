#!/usr/bin/env python3
"""Numerical demonstrations for extremal combinatorics.

The script uses only the Python standard library. It evaluates exact Turán
numbers, constructs lower shadows and colex initial segments, searches for
three-term arithmetic progressions, and exhaustively computes small Roth
numbers.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Iterable, Iterator, Sequence

SetFamily = set[FrozenSet[int]]


def turan_part_sizes(n: int, r: int) -> list[int]:
    """Return balanced part sizes for the extremal K_r-free Turán graph."""
    if n < 0 or r < 2:
        raise ValueError("Require n >= 0 and r >= 2")
    parts = r - 1
    q, s = divmod(n, parts)
    return [q + 1] * s + [q] * (parts - s)


def turan_number(n: int, r: int) -> int:
    """Evaluate the exact maximum number of edges in an n-vertex K_r-free graph."""
    if n < 0 or r < 2:
        raise ValueError("Require n >= 0 and r >= 2")
    t = r - 1
    s = n % t
    return ((n * n - s * s) * (t - 1)) // (2 * t) + comb(s, 2)


def cross_edge_count(part_sizes: Sequence[int]) -> int:
    """Count edges in a complete multipartite graph from its part sizes."""
    return sum(a * b for a, b in combinations(part_sizes, 2))


def lower_shadow(family: Iterable[FrozenSet[int]]) -> SetFamily:
    """Return all sets obtained by deleting one element from a family member."""
    shadow: SetFamily = set()
    for face in family:
        for vertex in face:
            shadow.add(face - {vertex})
    return shadow


def iterated_shadow(family: SetFamily, depth: int) -> SetFamily:
    """Apply the lower-shadow operation a nonnegative number of times."""
    if depth < 0:
        raise ValueError("Shadow depth must be nonnegative")
    result = set(family)
    for _ in range(depth):
        result = lower_shadow(result)
    return result


def colex_key(face: FrozenSet[int]) -> int:
    """Rank equal-sized finite sets in colex order using the combinatorial number system."""
    return sum(comb(value, index) for index, value in enumerate(sorted(face), start=1))


def colex_initial_segment(n: int, r: int, size: int) -> SetFamily:
    """Return the first ``size`` r-subsets of {0,...,n-1} in colex order."""
    all_faces = [frozenset(face) for face in combinations(range(n), r)]
    if not 0 <= size <= len(all_faces):
        raise ValueError("Requested size exceeds the number of r-subsets")
    all_faces.sort(key=colex_key)
    return set(all_faces[:size])


def three_term_progressions(values: Iterable[int]) -> list[tuple[int, int, int]]:
    """List increasing nontrivial triples a < b < c satisfying a + c = 2b."""
    ordered = sorted(set(values))
    available = set(ordered)
    found: list[tuple[int, int, int]] = []
    for a, c in combinations(ordered, 2):
        if (a + c) % 2 == 0:
            b = (a + c) // 2
            if b in available and a < b < c:
                found.append((a, b, c))
    return found


def is_three_ap_free(values: Iterable[int]) -> bool:
    """Test whether a finite integer set has no nontrivial three-term progression."""
    return not three_term_progressions(values)


def subsets_of_range(n: int) -> Iterator[FrozenSet[int]]:
    """Yield all subsets of {0,...,n-1}."""
    for mask in range(1 << n):
        yield frozenset(i for i in range(n) if mask & (1 << i))


def roth_number_small(n: int) -> tuple[int, FrozenSet[int]]:
    """Compute the small finite Roth number by exhaustive search."""
    if not 0 <= n <= 24:
        raise ValueError("This exhaustive educational routine requires 0 <= n <= 24")
    best: FrozenSet[int] = frozenset()
    for candidate in subsets_of_range(n):
        if len(candidate) > len(best) and is_three_ap_free(candidate):
            best = candidate
    return len(best), best


def demonstrate_turan() -> None:
    print("=== Exact Turán numbers and balanced extremizers ===")
    for n, r in [(10, 4), (11, 4), (12, 5), (17, 3)]:
        parts = turan_part_sizes(n, r)
        exact = turan_number(n, r)
        smooth = (1.0 - 1.0 / (r - 1)) * n * n / 2.0
        print(
            f"n={n:2d}, forbidden K_{r}: parts={parts}, "
            f"exact={exact}, cross-check={cross_edge_count(parts)}, "
            f"smooth bound={smooth:.3f}"
        )


def demonstrate_shadows() -> None:
    print("\n=== Colex segments and iterated shadows ===")
    n, r, k = 7, 3, 5
    size = comb(k, r)
    colex = colex_initial_segment(n, r, size)
    first = iterated_shadow(colex, 1)
    second = iterated_shadow(colex, 2)
    print(f"First {size}=C({k},{r}) triples in colex on {n} points")
    print(f"shadow sizes: {len(colex)} -> {len(first)} -> {len(second)}")
    print(
        "Lovász targets: "
        f"C({k},{r})={comb(k, r)}, C({k},{r-1})={comb(k, r-1)}, "
        f"C({k},{r-2})={comb(k, r-2)}"
    )


def demonstrate_roth() -> None:
    print("\n=== Three-term arithmetic progressions ===")
    sample = {0, 1, 3, 4, 7, 10}
    print(f"sample set: {sorted(sample)}")
    print(f"progressions: {three_term_progressions(sample)}")
    print("small exact progression-free maxima:")
    for n in range(1, 11):
        maximum, witness = roth_number_small(n)
        print(f"N={n:2d}: R(N)={maximum}, witness={sorted(witness)}")


def main() -> None:
    demonstrate_turan()
    demonstrate_shadows()
    demonstrate_roth()


if __name__ == "__main__":
    main()
