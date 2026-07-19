#!/usr/bin/env python3
"""Numerical demonstrations of forced repetition in finite genetic alphabets."""

from __future__ import annotations

from collections import Counter
from itertools import product
import math
import random
from typing import Iterable, Optional, Sequence, TypeVar

T = TypeVar("T")
DNA = "ACGT"


def aligned_blocks(sequence: Sequence[T], motif_length: int) -> list[tuple[T, ...]]:
    """Return all complete, nonoverlapping blocks at the alignment starting at zero."""
    if motif_length <= 0:
        raise ValueError("motif_length must be positive")
    count = len(sequence) // motif_length
    return [tuple(sequence[i * motif_length : (i + 1) * motif_length]) for i in range(count)]


def first_aligned_collision(
    sequence: Sequence[T], motif_length: int
) -> Optional[tuple[int, int, tuple[T, ...]]]:
    """Find the first repeated aligned block, returning block indices and the word."""
    first_seen: dict[tuple[T, ...], int] = {}
    for index, block in enumerate(aligned_blocks(sequence, motif_length)):
        if block in first_seen:
            return first_seen[block], index, block
        first_seen[block] = index
    return None


def most_frequent_aligned_block(
    sequence: Sequence[T], motif_length: int
) -> tuple[tuple[T, ...], int]:
    """Return an aligned block of maximum multiplicity and its count."""
    blocks = aligned_blocks(sequence, motif_length)
    if not blocks:
        raise ValueError("sequence contains no complete block")
    block, count = Counter(blocks).most_common(1)[0]
    return block, count


def de_bruijn_linearization(alphabet: str, motif_length: int) -> str:
    """Concatenate every motif once, realizing the sharp aligned avoidance bound."""
    if motif_length <= 0:
        raise ValueError("motif_length must be positive")
    return "".join("".join(word) for word in product(alphabet, repeat=motif_length))


def max_disjoint_occurrences(window: str, motif: str) -> int:
    """Count a maximum family of disjoint contiguous occurrences of one motif."""
    if not motif:
        raise ValueError("motif must be nonempty")
    count = 0
    position = 0
    while True:
        found = window.find(motif, position)
        if found < 0:
            return count
        count += 1
        position = found + len(motif)


def window_has_multiplicity(window: str, motif_length: int, target: int) -> bool:
    """Test whether some motif has at least target disjoint occurrences in a window."""
    if motif_length <= 0 or target <= 0:
        raise ValueError("motif_length and target must be positive")
    motifs = {
        window[i : i + motif_length]
        for i in range(len(window) - motif_length + 1)
    }
    return any(max_disjoint_occurrences(window, motif) >= target for motif in motifs)


def window_uniform_statistic(genome: str, motif_length: int, target: int) -> Optional[int]:
    """Compute the least window length for which every window has target multiplicity."""
    if not genome:
        return None
    low, high = 1, len(genome)
    if not window_has_multiplicity(genome, motif_length, target):
        return None
    while low < high:
        middle = (low + high) // 2
        passes = all(
            window_has_multiplicity(genome[start : start + middle], motif_length, target)
            for start in range(len(genome) - middle + 1)
        )
        if passes:
            high = middle
        else:
            low = middle + 1
    return low


def birthday_collision_probability(samples: int, word_space: int) -> float:
    """Return the exact collision probability for independent uniform samples."""
    if samples < 0 or word_space <= 0:
        raise ValueError("invalid sample count or word-space size")
    if samples > word_space:
        return 1.0
    log_no_collision = sum(math.log1p(-i / word_space) for i in range(samples))
    return 1.0 - math.exp(log_no_collision)


def demonstrate() -> None:
    """Run deterministic and probabilistic examples with reproducible output."""
    q, m = 4, 4
    word_space = q**m
    print(f"DNA four-mer word space: {q}^{m} = {word_space}")
    print(f"Universal aligned deadline: {word_space + 1} blocks = {(word_space + 1) * m} bases")

    sharp_prefix = de_bruijn_linearization(DNA, m)
    assert len(aligned_blocks(sharp_prefix, m)) == word_space
    assert first_aligned_collision(sharp_prefix, m) is None
    forced = sharp_prefix + sharp_prefix[:m]
    collision = first_aligned_collision(forced, m)
    assert collision is not None
    i, j, word = collision
    print(f"Sharp construction: blocks {i} and {j} repeat {''.join(word)!r}; copies are disjoint")

    repeated = sharp_prefix * 3
    motif, count = most_frequent_aligned_block(repeated, m)
    assert count == 3
    print(f"Multiplicity example: {''.join(motif)!r} occurs {count} times among {len(repeated) // m} blocks")

    rng = random.Random(20260719)
    random_dna = "".join(rng.choice(DNA) for _ in range(1028))
    random_collision = first_aligned_collision(random_dna, m)
    assert random_collision is not None
    print(f"Seeded random DNA first aligned collision: {random_collision[:2]}")

    for samples in (10, 20, 40, 100, 257):
        probability = birthday_collision_probability(samples, word_space)
        print(f"Uniform model, {samples:3d} samples: collision probability {probability:.6f}")

    low_complexity = "ACGT" * 30 + "A" * 40 + "TGCA" * 30
    statistic = window_uniform_statistic(low_complexity, 4, 2)
    print(f"Low-complexity example U_g(4,2): {statistic}")


if __name__ == "__main__":
    demonstrate()
