#!/usr/bin/env python3
"""Numerical demonstrations of finite-tag amplification.

The script illustrates only the explicit finite combinatorics: quotient-remainder
naming, coverage of all tagged names, multiplication of a witness into distinct
tagged witnesses, and downward witness-count selection. It makes no attempt to
decide whether an underlying mathematical predicate is dark.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Hashable, Iterable, TypeVar

T = TypeVar("T", bound=Hashable)


@dataclass(frozen=True, order=True)
class TaggedName:
    """A finite tag paired with the index of an underlying named object."""

    tag: int
    payload_index: int


def encode_tagged_name(tag: int, payload_index: int, tag_count: int) -> int:
    """Encode ``(tag, payload_index)`` as ``tag_count * payload_index + tag``."""
    if tag_count < 1:
        raise ValueError("tag_count must be positive")
    if not 0 <= tag < tag_count:
        raise ValueError("tag must satisfy 0 <= tag < tag_count")
    if payload_index < 0:
        raise ValueError("payload_index must be nonnegative")
    return tag_count * payload_index + tag


def decode_tagged_name(code: int, tag_count: int) -> TaggedName:
    """Decode a natural-number code by Euclidean quotient and remainder."""
    if tag_count < 1:
        raise ValueError("tag_count must be positive")
    if code < 0:
        raise ValueError("code must be nonnegative")
    payload_index, tag = divmod(code, tag_count)
    return TaggedName(tag=tag, payload_index=payload_index)


def tagged_witnesses(witness: T, tag_count: int) -> list[tuple[int, T]]:
    """Create ``tag_count`` distinct tagged copies of one payload witness."""
    if tag_count < 1:
        raise ValueError("tag_count must be positive")
    return [(tag, witness) for tag in range(tag_count)]


def evaluate_tagged_predicate(
    predicate: Callable[[T], bool], tagged_object: tuple[int, T]
) -> bool:
    """Evaluate a tag-insensitive predicate on the payload component."""
    _, payload = tagged_object
    return predicate(payload)


def select_lower_level(witnesses: Iterable[T], level: int) -> list[T]:
    """Select ``level`` distinct witnesses, demonstrating downward monotonicity."""
    if level < 0:
        raise ValueError("level must be nonnegative")
    distinct = list(dict.fromkeys(witnesses))
    if len(distinct) < level:
        raise ValueError("not enough distinct witnesses")
    return distinct[:level]


def demonstrate_round_trips(tag_count: int, payload_count: int) -> None:
    """Print and assert all encode/decode round trips in a finite rectangle."""
    print(f"\nTag naming table for {tag_count} tags and {payload_count} payload names")
    print("code -> (tag, payload index) -> reconstructed code")
    for payload_index in range(payload_count):
        for tag in range(tag_count):
            code = encode_tagged_name(tag, payload_index, tag_count)
            decoded = decode_tagged_name(code, tag_count)
            reconstructed = encode_tagged_name(
                decoded.tag, decoded.payload_index, tag_count
            )
            assert decoded == TaggedName(tag, payload_index)
            assert reconstructed == code
            print(f"{code:>4} -> ({decoded.tag}, {decoded.payload_index}) -> {reconstructed:>4}")


def demonstrate_amplification(max_level: int) -> None:
    """Show that one payload creates every requested positive finite level."""
    payload = 42
    predicate = lambda x: x == payload
    print("\nFinite-tag amplification of the illustrative payload 42")
    for level in range(1, max_level + 1):
        witnesses = tagged_witnesses(payload, level)
        assert len(set(witnesses)) == level
        assert all(evaluate_tagged_predicate(predicate, z) for z in witnesses)
        print(f"level {level}: {witnesses}")


def demonstrate_downward_monotonicity(source_level: int) -> None:
    """Select witness sets at every lower level from one tagged witness set."""
    source = tagged_witnesses("hidden payload", source_level)
    print(f"\nDownward selection from {source_level} distinct tagged witnesses")
    for level in range(source_level + 1):
        selected = select_lower_level(source, level)
        assert len(selected) == level
        print(f"at least {level}: {selected}")


def main() -> None:
    """Run all demonstrations with assertions serving as executable checks."""
    demonstrate_round_trips(tag_count=3, payload_count=4)
    demonstrate_amplification(max_level=6)
    demonstrate_downward_monotonicity(source_level=5)
    print("\nAll finite-tag identities passed.")


if __name__ == "__main__":
    main()
