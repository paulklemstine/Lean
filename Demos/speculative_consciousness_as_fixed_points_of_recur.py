#!/usr/bin/env python3
"""Numerical demonstrations of proposition-valued fixed-point collapse.

A proposition contributes cardinality 0 when false and 1 when true.  The
cardinality of a finite dependent product is the product of those cardinalities,
with the empty product equal to 1.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, Iterator, Sequence


def proposition_product_cardinality(truth_values: Iterable[bool]) -> int:
    """Return the cardinality of the product represented by truth values."""
    return int(all(truth_values))


def truth_assignments(size: int) -> Iterator[tuple[bool, ...]]:
    """Generate all proposition families on a finite type of given size."""
    if size < 0:
        raise ValueError("size must be nonnegative")
    yield from product((False, True), repeat=size)


def fixed_point_witnesses(size: int) -> list[tuple[bool, ...]]:
    """List truth assignments whose product cardinality equals the domain size."""
    return [
        assignment
        for assignment in truth_assignments(size)
        if proposition_product_cardinality(assignment) == size
    ]


def structural_classification(size: int) -> bool:
    """Decide whether any proposition-valued fixed-point witness can exist."""
    if size < 0:
        raise ValueError("size must be nonnegative")
    return size == 1


def cardinality_table(max_size: int) -> list[dict[str, int | bool]]:
    """Summarize exhaustive witness counts from size zero through max_size."""
    if max_size < 0:
        raise ValueError("max_size must be nonnegative")
    return [
        {
            "size": size,
            "predicate_families": 2**size,
            "witnesses": len(fixed_point_witnesses(size)),
            "classified_as_fixed_point": structural_classification(size),
        }
        for size in range(max_size + 1)
    ]


def data_valued_product_cardinality(fiber_sizes: Sequence[int]) -> int:
    """Compute a finite product cardinality for nonnegative data-fiber sizes."""
    result = 1
    for fiber_size in fiber_sizes:
        if fiber_size < 0:
            raise ValueError("fiber sizes must be nonnegative")
        result *= fiber_size
    return result


def demonstrate() -> None:
    """Print the collapse table and contrast it with data-valued fibers."""
    print("Proposition-valued fixed-point search")
    print("n | families | witnesses | structural result")
    print("--+----------+-----------+------------------")
    for row in cardinality_table(8):
        print(
            f"{row['size']:>1} | {row['predicate_families']:>8} | "
            f"{row['witnesses']:>9} | {row['classified_as_fixed_point']}"
        )

    print("\nThe unique finite witness occurs at n = 1:")
    print(fixed_point_witnesses(1))

    fibers = (2, 2, 1, 1)
    print("\nData-valued contrast")
    print(
        f"A four-element domain with fiber sizes {fibers} has product "
        f"cardinality {data_valued_product_cardinality(fibers)}."
    )


if __name__ == "__main__":
    demonstrate()
