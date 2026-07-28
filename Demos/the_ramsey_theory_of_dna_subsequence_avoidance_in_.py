#!/usr/bin/env python3
"""Numerical demonstrations of deterministic repeated-k-mer thresholds."""

from __future__ import annotations

from dataclasses import dataclass
from random import Random
from typing import Callable, Hashable, Iterable, Optional, Sequence, TypeVar

Symbol = TypeVar("Symbol", bound=Hashable)
Decoded = TypeVar("Decoded", bound=Hashable)


@dataclass(frozen=True)
class Collision:
    """Two distinct starting positions carrying the same contiguous block."""

    first: int
    second: int
    block: tuple[Hashable, ...]


def repetition_threshold(alphabet_size: int, k: int) -> int:
    """Return the sufficient threshold q**k + k from the theorem."""
    if alphabet_size < 0 or k < 0:
        raise ValueError("alphabet_size and k must be nonnegative")
    return alphabet_size**k + k


def first_repeated_kmer(word: Sequence[Symbol], k: int) -> Optional[Collision]:
    """Find the first repeated contiguous k-mer in a left-to-right scan."""
    if not 0 <= k <= len(word):
        raise ValueError("k must satisfy 0 <= k <= len(word)")
    first_seen: dict[tuple[Symbol, ...], int] = {}
    for start in range(len(word) - k + 1):
        block = tuple(word[start : start + k])
        if block in first_seen:
            return Collision(first_seen[block], start, block)
        first_seen[block] = start
    return None


def decode_word(encoded: Iterable[Symbol], decoder: Callable[[Symbol], Decoded]) -> list[Decoded]:
    """Apply a symbolwise decoder to an encoded word."""
    return [decoder(symbol) for symbol in encoded]


def deterministic_dna(length: int, seed: int = 20260728) -> str:
    """Generate a reproducible DNA example; no theorem claim relies on randomness."""
    rng = Random(seed)
    return "".join(rng.choice("ACGT") for _ in range(length))


def format_block(block: tuple[Hashable, ...]) -> str:
    return "".join(str(x) for x in block)


def demonstrate_general_threshold() -> None:
    length = repetition_threshold(4, 4)
    word = deterministic_dna(length)
    collision = first_repeated_kmer(word, 4)
    assert collision is not None
    assert word[collision.first : collision.first + 4] == word[collision.second : collision.second + 4]
    print("DNA threshold demonstration")
    print(f"  length={length}, windows={length - 4 + 1}, possible four-mers={4**4}")
    print(
        f"  repeated four-mer {format_block(collision.block)} "
        f"at zero-based positions {collision.first} and {collision.second}"
    )


def demonstrate_binary_compression() -> None:
    length = repetition_threshold(2, 4)
    encoded = [(3 * i * i + i + 1) % 2 for i in range(length)]
    decoder = {0: "A", 1: "G"}
    dna = decode_word(encoded, decoder.__getitem__)
    collision = first_repeated_kmer(dna, 4)
    assert collision is not None
    print("\nBinary effective-alphabet demonstration")
    print(f"  length={length}, windows={length - 4 + 1}, possible encoded four-mers={2**4}")
    print(
        f"  repeated decoded four-mer {format_block(collision.block)} "
        f"at zero-based positions {collision.first} and {collision.second}"
    )


def demonstrate_threshold_table() -> None:
    print("\nEffective-alphabet threshold table for four-mers")
    print("  b | b^4 | b^4 + 4")
    print(" ---+-----+--------")
    for b in range(1, 5):
        print(f"  {b} | {b**4:3d} | {repetition_threshold(b, 4):7d}")
    assert repetition_threshold(4, 4) == 260
    assert repetition_threshold(2, 4) == 20


def demonstrate_selection() -> None:
    genome = deterministic_dna(1000, seed=7)
    # A reproducible order-preserving selection of 260 genomic positions.
    selected_positions = list(range(0, 520, 2))
    selected = "".join(genome[i] for i in selected_positions)
    collision = first_repeated_kmer(selected, 4)
    assert len(selected) == 260 and collision is not None
    source_a = selected_positions[collision.first : collision.first + 4]
    source_b = selected_positions[collision.second : collision.second + 4]
    print("\nOrder-preserving selection demonstration")
    print(f"  selected-word positions: {collision.first} and {collision.second}")
    print(f"  genomic source positions: {source_a} and {source_b}")
    print(f"  common selected four-mer: {format_block(collision.block)}")


def main() -> None:
    demonstrate_general_threshold()
    demonstrate_binary_compression()
    demonstrate_threshold_table()
    demonstrate_selection()


if __name__ == "__main__":
    main()
