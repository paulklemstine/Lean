#!/usr/bin/env python3
"""Numerical demonstrations of finite dependent-product fixed points.

The Boolean model has two base points.  Its fiber sizes are 2 and 1, so its
section space has two elements.  Encoding stores a Boolean at the informative
coordinate; decoding reads that coordinate.  The script also explores
concentrated finite profiles and constant-fiber obstructions.
"""

from __future__ import annotations

from itertools import product
from math import prod
from typing import Hashable, Iterable, Mapping, Sequence, TypeVar

T = TypeVar("T", bound=Hashable)
V = TypeVar("V", bound=Hashable)
Section = tuple[V, ...]


def enumerate_sections(
    base: Sequence[T], fibers: Mapping[T, Sequence[V]]
) -> list[Section[V]]:
    """Return every section as a tuple ordered according to ``base``."""
    return list(product(*(fibers[x] for x in base)))


def section_cardinality(
    base: Sequence[T], fibers: Mapping[T, Sequence[V]]
) -> int:
    """Compute the product of fiber cardinalities."""
    return prod(len(fibers[x]) for x in base)


def satisfies_cardinality_equation(
    base: Sequence[T], fibers: Mapping[T, Sequence[V]]
) -> bool:
    """Test the necessary finite fixed-point cardinality equation."""
    return len(base) == section_cardinality(base, fibers)


BOOL_BASE: tuple[bool, bool] = (False, True)
BOOL_FIBERS: dict[bool, tuple[object, ...]] = {
    False: (False, True),
    True: ("★",),
}


def encode_bool(value: bool) -> tuple[object, object]:
    """Encode a Boolean as the section (value, ★)."""
    return (value, "★")


def decode_bool(section: Sequence[object]) -> bool:
    """Decode a Boolean section by evaluating it at the False coordinate."""
    if len(section) != 2 or section[1] != "★" or not isinstance(section[0], bool):
        raise ValueError("not a section of the Boolean family")
    return section[0]


def verify_boolean_equivalence() -> bool:
    """Exhaustively check both inverse laws for the Boolean construction."""
    sections = enumerate_sections(BOOL_BASE, BOOL_FIBERS)
    states_round_trip = all(decode_bool(encode_bool(b)) == b for b in BOOL_BASE)
    sections_round_trip = all(encode_bool(decode_bool(s)) == s for s in sections)
    return states_round_trip and sections_round_trip


def concentrated_profile(n: int) -> tuple[int, ...]:
    """Return the proposed finite profile (n, 1, ..., 1) of length n."""
    if n <= 0:
        raise ValueError("n must be positive")
    return (n,) + (1,) * (n - 1)


def constant_fiber_candidates(max_n: int, max_a: int) -> list[tuple[int, int]]:
    """Find positive integer pairs (n, a) in range satisfying n = a**n."""
    if max_n < 1 or max_a < 1:
        return []
    return [
        (n, a)
        for n in range(1, max_n + 1)
        for a in range(1, max_a + 1)
        if n == a**n
    ]


def render_rows(rows: Iterable[tuple[object, ...]]) -> str:
    """Format tuples as an aligned plain-text table."""
    materialized = [tuple(map(str, row)) for row in rows]
    if not materialized:
        return "(none)"
    widths = [max(len(row[i]) for row in materialized) for i in range(len(materialized[0]))]
    return "\n".join(
        "  ".join(value.ljust(widths[i]) for i, value in enumerate(row))
        for row in materialized
    )


def main() -> None:
    """Print the Boolean model and a finite-cardinality exploration."""
    sections = enumerate_sections(BOOL_BASE, BOOL_FIBERS)
    print("BOOLEAN DEPENDENT-PRODUCT FIXED POINT")
    print(f"base cardinality: {len(BOOL_BASE)}")
    print(f"fiber cardinalities: {[len(BOOL_FIBERS[x]) for x in BOOL_BASE]}")
    print(f"section cardinality: {section_cardinality(BOOL_BASE, BOOL_FIBERS)}")
    print(f"cardinality equation holds: {satisfies_cardinality_equation(BOOL_BASE, BOOL_FIBERS)}")
    print(f"fibers have unequal sizes: {len(BOOL_FIBERS[False]) != len(BOOL_FIBERS[True])}")
    print("\nstate  encoded section  decoded state")
    rows = [(b, encode_bool(b), decode_bool(encode_bool(b))) for b in BOOL_BASE]
    print(render_rows(rows))
    print(f"\nall sections: {sections}")
    print(f"both inverse laws hold: {verify_boolean_equivalence()}")

    print("\nCONCENTRATED FINITE PROFILES")
    print("n  profile             product")
    profiles = [(n, concentrated_profile(n), prod(concentrated_profile(n))) for n in range(1, 9)]
    print(render_rows(profiles))

    print("\nCONSTANT-FIBER SEARCH")
    candidates = constant_fiber_candidates(12, 8)
    print("solutions to n = a^n for 1 <= n <= 12 and 1 <= a <= 8:")
    print(candidates)
    nontrivial = [(n, a) for n, a in candidates if n >= 2 and a >= 2]
    print(f"nontrivial solutions with n >= 2 and a >= 2: {nontrivial}")


if __name__ == "__main__":
    main()
