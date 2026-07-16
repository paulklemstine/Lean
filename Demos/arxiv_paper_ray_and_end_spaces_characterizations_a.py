#!/usr/bin/env python3
"""Numerical demonstrations of ray relabelling and prime-adic clusters."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Hashable, Iterable, Mapping, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


def relabel_prefix(prefix: Sequence[A], relabelling: Mapping[A, B]) -> tuple[B, ...]:
    """Apply a bijective alphabet relabelling coordinate by coordinate."""
    return tuple(relabelling[symbol] for symbol in prefix)


def is_prefix(prefix: Sequence[A], word: Sequence[A]) -> bool:
    """Return whether prefix is an initial segment of word."""
    return len(prefix) <= len(word) and tuple(word[: len(prefix)]) == tuple(prefix)


def padic_valuation(value: Fraction, p: int) -> int:
    """Return v_p(value) for a nonzero rational value and a prime p."""
    if value == 0:
        raise ValueError("The finite-valued convention leaves v_p(0) undefined")
    if p < 2:
        raise ValueError("p must be at least 2")
    numerator = abs(value.numerator)
    denominator = value.denominator
    exponent = 0
    while numerator % p == 0:
        numerator //= p
        exponent += 1
    while denominator % p == 0:
        denominator //= p
        exponent -= 1
    return exponent


def in_cluster(y: Fraction, x: Fraction, p: int, threshold: int) -> bool:
    """Test membership in the valuation cluster C_{p,threshold}(x)."""
    return y == x or padic_valuation(x - y, p) >= threshold


def cluster(
    sample: Iterable[Fraction], x: Fraction, p: int, threshold: int
) -> frozenset[Fraction]:
    """Intersect a valuation cluster with a finite rational sample."""
    return frozenset(y for y in sample if in_cluster(y, x, p, threshold))


@dataclass(frozen=True)
class ClusterLevel:
    """A threshold and the partition it induces on a finite sample."""

    threshold: int
    blocks: tuple[frozenset[Fraction], ...]


def cluster_hierarchy(
    sample: Sequence[Fraction], p: int, thresholds: Sequence[int]
) -> tuple[ClusterLevel, ...]:
    """Build finite prime-adic cluster partitions at increasing thresholds."""
    points = tuple(dict.fromkeys(sample))
    levels: list[ClusterLevel] = []
    for threshold in sorted(set(thresholds)):
        unseen = set(points)
        blocks: list[frozenset[Fraction]] = []
        while unseen:
            center = min(unseen)
            block = cluster(points, center, p, threshold)
            blocks.append(block)
            unseen.difference_update(block)
        levels.append(ClusterLevel(threshold, tuple(blocks)))
    return tuple(levels)


def verify_cluster_laws(
    sample: Sequence[Fraction], p: int, thresholds: Sequence[int]
) -> None:
    """Check transitivity, center-independence, and threshold nesting on a sample."""
    for k in thresholds:
        for x in sample:
            cx = cluster(sample, x, p, k)
            for y in cx:
                assert cluster(sample, y, p, k) == cx
                for z in cx:
                    assert in_cluster(z, y, p, k)
    ordered = sorted(set(thresholds))
    for x in sample:
        for low, high in zip(ordered, ordered[1:]):
            assert cluster(sample, x, p, high) <= cluster(sample, x, p, low)


def format_block(block: frozenset[Fraction]) -> str:
    """Format a finite block deterministically."""
    return "{" + ", ".join(str(x) for x in sorted(block)) + "}"


def demonstrate_relabelling() -> None:
    """Show that relabelling and inverse relabelling preserve finite prefixes."""
    ray = (0, 1, 1, 0, 1, 0, 0, 1)
    forward = {0: "L", 1: "R"}
    inverse = {value: key for key, value in forward.items()}
    image = relabel_prefix(ray, forward)
    recovered = relabel_prefix(image, inverse)
    print("Coordinate relabelling")
    print("  original: ", ray)
    print("  image:    ", image)
    print("  recovered:", recovered)
    assert recovered == ray
    for n in range(len(ray) + 1):
        assert relabel_prefix(ray[:n], forward) == image[:n]
    print("  Every tested finite prefix commutes with relabelling.\n")


def demonstrate_clusters() -> None:
    """Display exact cluster partitions and validate the structural laws."""
    sample = tuple(Fraction(i) for i in range(16))
    thresholds = (0, 1, 2, 3)
    levels = cluster_hierarchy(sample, p=2, thresholds=thresholds)
    verify_cluster_laws(sample, p=2, thresholds=thresholds)
    print("2-adic cluster hierarchy on {0, ..., 15}")
    for level in levels:
        blocks = "  ".join(format_block(block) for block in level.blocks)
        print(f"  threshold {level.threshold}: {blocks}")
    assert Fraction(2) in cluster(sample, Fraction(0), 2, 1)
    assert cluster(sample, Fraction(0), 2, 1) == cluster(
        sample, Fraction(2), 2, 1
    )
    print("  Center-independence and threshold nesting checks passed.\n")


def demonstrate_rational_valuations() -> None:
    """Evaluate examples involving positive and negative rational valuations."""
    examples = (Fraction(12, 5), Fraction(3, 8), Fraction(20, 3))
    print("Exact rational 2-adic valuations")
    for value in examples:
        print(f"  v_2({value}) = {padic_valuation(value, 2)}")


def main() -> None:
    demonstrate_relabelling()
    demonstrate_clusters()
    demonstrate_rational_valuations()


if __name__ == "__main__":
    main()
