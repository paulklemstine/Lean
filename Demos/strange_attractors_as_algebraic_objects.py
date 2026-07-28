#!/usr/bin/env python3
"""Numerical demonstrations for binary de Bruijn inverse-limit approximants."""

from __future__ import annotations

from itertools import product
from typing import Iterable, Optional, Sequence, TypeAlias

Bit: TypeAlias = int
Word: TypeAlias = tuple[Bit, ...]
Edge: TypeAlias = tuple[Word, Word]


def validate_word(word: Sequence[Bit]) -> None:
    """Raise ValueError unless every entry is a binary digit."""
    if any(bit not in (0, 1) for bit in word):
        raise ValueError(f"not a binary word: {word!r}")


def binary_words(length: int) -> list[Word]:
    """Enumerate all binary words of the requested nonnegative length."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    return [tuple(bits) for bits in product((0, 1), repeat=length)]


def truncate(word: Word) -> Word:
    """Delete the final symbol of a nonempty binary word."""
    validate_word(word)
    if not word:
        raise ValueError("the empty word cannot be truncated")
    return word[:-1]


def de_bruijn_edge(source: Word, target: Word) -> bool:
    """Test whether equal-length words overlap after a one-symbol shift."""
    validate_word(source)
    validate_word(target)
    if len(source) != len(target):
        raise ValueError("source and target must have equal length")
    return source[1:] == target[:-1]


def de_bruijn_edges(word_length: int) -> list[Edge]:
    """Generate the binary de Bruijn graph using its two-successor rule."""
    if word_length <= 0:
        raise ValueError("word_length must be positive")
    edges: list[Edge] = []
    for source in binary_words(word_length):
        for appended in (0, 1):
            target = source[1:] + (appended,)
            edges.append((source, target))
    return edges


def prefixes(stream: Sequence[Bit], depth: Optional[int] = None) -> list[Word]:
    """Return prefixes from length zero through the requested depth."""
    validate_word(stream)
    actual_depth = len(stream) if depth is None else depth
    if actual_depth < 0 or actual_depth > len(stream):
        raise ValueError("depth must lie between zero and the sample length")
    return [tuple(stream[:n]) for n in range(actual_depth + 1)]


def is_compatible_thread(thread: Sequence[Word]) -> bool:
    """Check lengths and all adjacent truncation equations."""
    for level, word in enumerate(thread):
        validate_word(word)
        if len(word) != level:
            return False
    return all(truncate(thread[level + 1]) == thread[level]
               for level in range(len(thread) - 1))


def first_difference(left: Sequence[Bit], right: Sequence[Bit]) -> Optional[int]:
    """Find the first differing sampled coordinate, or None if samples agree."""
    validate_word(left)
    validate_word(right)
    for index, (a, b) in enumerate(zip(left, right)):
        if a != b:
            return index
    if len(left) != len(right):
        return min(len(left), len(right))
    return None


def edge_preservation_checks(max_word_length: int) -> tuple[int, int]:
    """Exhaustively count tested and successful nontrivial truncation checks."""
    if max_word_length < 2:
        raise ValueError("max_word_length must be at least two")
    tested = 0
    passed = 0
    for length in range(2, max_word_length + 1):
        for source, target in de_bruijn_edges(length):
            tested += 1
            if de_bruijn_edge(truncate(source), truncate(target)):
                passed += 1
    return tested, passed


def format_word(word: Iterable[Bit]) -> str:
    """Format a word, displaying the empty word with a conventional symbol."""
    text = "".join(str(bit) for bit in word)
    return text if text else "ε"


def main() -> None:
    """Run reproducible examples of all key finite statements."""
    print("BINARY LEVEL CARDINALITIES")
    for n in range(11):
        observed = len(binary_words(n))
        expected = 2 ** n
        print(f"n={n:2d}: observed={observed:4d}, 2^n={expected:4d}")
        assert observed == expected

    print("\nEDGE PRESERVATION UNDER TRUNCATION")
    tested, passed = edge_preservation_checks(max_word_length=8)
    print(f"exhaustive finite checks passed: {passed}/{tested}")
    assert tested == passed

    print("\nA COMPATIBLE PREFIX THREAD")
    sample: Word = (1, 0, 1, 1, 0, 0, 1, 0)
    thread = prefixes(sample)
    print(" -> ".join(format_word(word) for word in thread))
    print(f"compatible: {is_compatible_thread(thread)}")
    assert is_compatible_thread(thread)

    print("\nFINITE DETECTION OF DISTINCT TRAJECTORIES")
    left: Word = (0, 0, 1, 0, 1, 1)
    right: Word = (0, 0, 1, 1, 1, 1)
    difference = first_difference(left, right)
    assert difference is not None
    separation_level = difference + 1
    print(f"first differing coordinate: {difference}")
    print(f"first separating prefix level: {separation_level}")
    print(f"left prefix:  {format_word(prefixes(left)[separation_level])}")
    print(f"right prefix: {format_word(prefixes(right)[separation_level])}")
    assert prefixes(left)[separation_level] != prefixes(right)[separation_level]

    print("\nA PERIODIC CYCLE IN THE ORDER-3 GRAPH")
    cycle: list[Word] = [(0, 1, 0), (1, 0, 1), (0, 1, 0)]
    for source, target in zip(cycle, cycle[1:]):
        print(f"{format_word(source)} -> {format_word(target)}")
        assert de_bruijn_edge(source, target)


if __name__ == "__main__":
    main()
