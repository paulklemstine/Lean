#!/usr/bin/env python3
"""Numerical demonstrations for codiscrete bicategories from unital magmas.

The program studies the twisted product

    a ⋆ b = b       if a = 0
            a       if b = 0
            a + 2b  otherwise.

It verifies the unit law on a finite range, displays the 5-versus-7
associativity defect, enumerates defects, and evaluates the five vertices of
the associativity pentagon. No third-party packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Iterable, Sequence, TypeVar

T = TypeVar("T")
BinaryOperation = Callable[[T, T], T]


@dataclass(frozen=True)
class Defect:
    """A triple and the unequal values of its two bracketings."""

    a: int
    b: int
    c: int
    left: int
    right: int


def twisted_product(a: int, b: int) -> int:
    """Return the unital, nonassociative twisted product of naturals."""
    if a < 0 or b < 0:
        raise ValueError("twisted_product is defined on nonnegative integers")
    if a == 0:
        return b
    if b == 0:
        return a
    return a + 2 * b


def bracketings(op: BinaryOperation[T], a: T, b: T, c: T) -> tuple[T, T]:
    """Compute ((a*b)*c, a*(b*c))."""
    return op(op(a, b), c), op(a, op(b, c))


def verify_unit(
    elements: Iterable[T], op: BinaryOperation[T], unit: T
) -> bool:
    """Check the left and right unit laws on the supplied elements."""
    return all(op(unit, x) == x and op(x, unit) == x for x in elements)


def find_first_defect(
    elements: Sequence[T], op: BinaryOperation[T]
) -> tuple[T, T, T, T, T] | None:
    """Find the lexicographically first associativity defect, if one exists."""
    for a, b, c in product(elements, repeat=3):
        left, right = bracketings(op, a, b, c)
        if left != right:
            return a, b, c, left, right
    return None


def enumerate_twisted_defects(limit: int) -> list[Defect]:
    """Enumerate defects for triples in range(limit + 1)."""
    if limit < 0:
        raise ValueError("limit must be nonnegative")
    defects: list[Defect] = []
    for a, b, c in product(range(limit + 1), repeat=3):
        left, right = bracketings(twisted_product, a, b, c)
        if left != right:
            defects.append(Defect(a, b, c, left, right))
    return defects


def pentagon_vertices(
    op: BinaryOperation[T], a: T, b: T, c: T, d: T
) -> dict[str, T]:
    """Evaluate the five parenthesizations occurring in the pentagon."""
    return {
        "(((a*b)*c)*d)": op(op(op(a, b), c), d),
        "((a*(b*c))*d)": op(op(a, op(b, c)), d),
        "((a*b)*(c*d))": op(op(a, b), op(c, d)),
        "(a*((b*c)*d))": op(a, op(op(b, c), d)),
        "(a*(b*(c*d)))": op(a, op(b, op(c, d))),
    }


def positive_defect_formula(a: int, b: int, c: int) -> tuple[int, int, int]:
    """Return left, right, and right-left for a positive triple."""
    if min(a, b, c) <= 0:
        raise ValueError("the closed defect formula requires positive inputs")
    left, right = bracketings(twisted_product, a, b, c)
    return left, right, right - left


def main() -> None:
    """Run a reproducible suite of numerical demonstrations."""
    sample = list(range(9))
    print("CODISCRETE BICATEGORY NUMERICAL DEMO")
    print("=" * 43)
    print(f"Unit check for 0 through 8: {verify_unit(sample, twisted_product, 0)}")

    left, right = bracketings(twisted_product, 1, 1, 1)
    print("\nSmallest positive witness:")
    print(f"  (1 ⋆ 1) ⋆ 1 = {left}")
    print(f"  1 ⋆ (1 ⋆ 1) = {right}")
    print(f"  unequal endpoints: {left} != {right}")
    print("  the codiscrete construction supplies one invertible 2-cell between them")

    first = find_first_defect(sample, twisted_product)
    print(f"\nFirst defect in lexicographic order on 0..8: {first}")

    limit = 5
    defects = enumerate_twisted_defects(limit)
    total = (limit + 1) ** 3
    print(f"\nDefect census on {{0,...,{limit}}}^3:")
    print(f"  {len(defects)} of {total} triples are nonassociative")
    print(f"  defect density = {len(defects) / total:.3f}")
    print("  first five defects:")
    for defect in defects[:5]:
        print(f"    {defect}")

    a, b, c = 2, 3, 4
    pleft, pright, gap = positive_defect_formula(a, b, c)
    print(f"\nPositive defect formula at ({a},{b},{c}):")
    print(f"  left={pleft}, right={pright}, gap={gap}=2c")

    print("\nFive pentagon vertices for (1,1,1,1):")
    for name, value in pentagon_vertices(twisted_product, 1, 1, 1, 1).items():
        print(f"  {name:20s} = {value}")
    print("\nThe vertex values may differ, while each parallel 2-cell is unique;")
    print("therefore the two composite routes around the pentagon coincide.")


if __name__ == "__main__":
    main()
