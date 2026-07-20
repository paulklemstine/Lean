#!/usr/bin/env python3
"""Numerical demonstrations for the finite Library of Babel.

The script uses only Python's standard library.  It computes exact cardinal and
incompressibility bounds, constructs shortest Hamming-graph paths, checks small
Hamming sphere counts, and samples the distribution of distances between random
books.  It never attempts to enumerate astronomically large libraries.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from math import comb, log10
from random import Random
from typing import Iterable, Sequence, TypeVar

Symbol = TypeVar("Symbol")


@dataclass(frozen=True)
class LibraryAudit:
    """Exact counting data for a finite library and a program budget."""

    alphabet_size: int
    book_length: int
    program_budget: int
    total_books: int
    maximum_described: int
    minimum_incompressible: int

    @property
    def minimum_incompressible_fraction(self) -> float:
        """Return the guaranteed incompressible fraction as a float."""
        if self.total_books == 0:
            return 0.0
        return self.minimum_incompressible / self.total_books


def audit_library(alphabet_size: int, book_length: int, program_budget: int) -> LibraryAudit:
    """Compute exact cardinality and decoder-independent image bounds.

    A decoder with ``program_budget`` inputs can have no more than that many
    distinct outputs.  The returned incompressibility count is therefore a
    lower bound valid for every such decoder.
    """
    if alphabet_size < 0 or book_length < 0 or program_budget < 0:
        raise ValueError("alphabet size, book length, and program budget must be nonnegative")
    total = alphabet_size**book_length
    described = min(total, program_budget)
    return LibraryAudit(
        alphabet_size,
        book_length,
        program_budget,
        total,
        described,
        total - described,
    )


def hamming_distance(left: Sequence[Symbol], right: Sequence[Symbol]) -> int:
    """Return the number of coordinates on which two equal-length words differ."""
    if len(left) != len(right):
        raise ValueError("Hamming distance requires equal-length words")
    return sum(a != b for a, b in zip(left, right))


def shortest_edit_path(start: Sequence[Symbol], target: Sequence[Symbol]) -> list[tuple[Symbol, ...]]:
    """Construct a shortest path in the Hamming graph from start to target."""
    if len(start) != len(target):
        raise ValueError("the words must have equal length")
    current = list(start)
    path = [tuple(current)]
    for index, desired in enumerate(target):
        if current[index] != desired:
            current[index] = desired
            path.append(tuple(current))
    return path


def hamming_sphere_size(alphabet_size: int, book_length: int, radius: int) -> int:
    """Return the number of words at exactly ``radius`` from a fixed word."""
    if alphabet_size < 1 or book_length < 0 or not 0 <= radius <= book_length:
        raise ValueError("require A >= 1 and 0 <= radius <= L")
    return comb(book_length, radius) * (alphabet_size - 1) ** radius


def sample_distances(
    alphabet_size: int, book_length: int, trials: int, seed: int = 20260720
) -> Counter[int]:
    """Sample Hamming distances between independent uniformly random books."""
    if alphabet_size < 1 or book_length < 0 or trials < 0:
        raise ValueError("require A >= 1 and nonnegative length and trial count")
    rng = Random(seed)
    histogram: Counter[int] = Counter()
    for _ in range(trials):
        left = [rng.randrange(alphabet_size) for _ in range(book_length)]
        right = [rng.randrange(alphabet_size) for _ in range(book_length)]
        histogram[hamming_distance(left, right)] += 1
    return histogram


def decoder_image(programs: Iterable[str]) -> set[str]:
    """Evaluate a transparent toy decoder and return its distinct outputs.

    Programs have forms ``literal:text``, ``repeat:n:c``, and ``alternating:n:ab``.
    Invalid programs are ignored.  Collisions illustrate why a decoder image can
    be strictly smaller than its number of programs.
    """
    outputs: set[str] = set()
    for program in programs:
        parts = program.split(":", 2)
        if len(parts) == 2 and parts[0] == "literal":
            outputs.add(parts[1])
        elif len(parts) == 3 and parts[0] == "repeat":
            try:
                count = int(parts[1])
            except ValueError:
                continue
            if count >= 0 and len(parts[2]) == 1:
                outputs.add(parts[2] * count)
        elif len(parts) == 3 and parts[0] == "alternating":
            try:
                count = int(parts[1])
            except ValueError:
                continue
            pattern = parts[2]
            if count >= 0 and pattern:
                outputs.add((pattern * ((count + len(pattern) - 1) // len(pattern)))[:count])
    return outputs


def main() -> None:
    """Run four reproducible demonstrations of the principal results."""
    print("FINITE LIBRARY OF BABEL — NUMERICAL DEMONSTRATIONS\n")

    pages, lines, columns, alphabet_size = 410, 40, 80, 25
    length = pages * lines * columns
    digits = int(length * log10(alphabet_size)) + 1
    print("1. A Borges-scale library")
    print(f"   Positions per book: {length:,}")
    print(f"   Number of books: 25^{length:,}")
    print(f"   Decimal digits in that count: {digits:,}\n")

    print("2. Exact incompressibility bounds for binary books of length 64")
    for saving in (5, 10, 20):
        audit = audit_library(2, 64, 2 ** (64 - saving))
        print(
            f"   Saving {saving:2d} bits: at least "
            f"{audit.minimum_incompressible_fraction:.9%} are undescribed"
        )
    print()

    print("3. Topological isolation versus graph connectivity")
    start = tuple("BABEL")
    target = tuple("BOOKS")
    path = shortest_edit_path(start, target)
    print(f"   Hamming distance: {hamming_distance(start, target)}")
    print("   A shortest one-symbol edit path:")
    print("   " + " -> ".join("".join(word) for word in path))
    print("   Yet every singleton is an open ball of radius 1/2.\n")

    print("4. Hamming spheres and typical random distances")
    A, L = 3, 8
    spheres = [hamming_sphere_size(A, L, k) for k in range(L + 1)]
    print(f"   Sphere sizes for A={A}, L={L}: {spheres}")
    print(f"   Their sum is {sum(spheres)} = {A}^{L}.")
    histogram = sample_distances(A, L, trials=20_000)
    empirical_mean = sum(distance * count for distance, count in histogram.items()) / 20_000
    theoretical_mean = L * (1 - 1 / A)
    print(f"   Sample mean distance: {empirical_mean:.4f}")
    print(f"   Theoretical mean:     {theoretical_mean:.4f}\n")

    print("5. Decoder collisions")
    programs = [
        "literal:AAAA",
        "repeat:4:A",  # same output as the first program
        "literal:ABAB",
        "alternating:4:AB",  # another collision
        "repeat:4:B",
    ]
    outputs = decoder_image(programs)
    print(f"   {len(programs)} programs produce only {len(outputs)} distinct books: {sorted(outputs)}")
    print("   Collisions can only increase the number of undescribed books.")


if __name__ == "__main__":
    main()
