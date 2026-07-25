#!/usr/bin/env python3
"""Finite demonstrations of order correspondences and obstruction extraction."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, FrozenSet, Generic, Iterable, Mapping, Sequence, TypeVar

A = TypeVar("A")
B = TypeVar("B")
C = TypeVar("C")


@dataclass(frozen=True)
class FiniteCorrespondence(Generic[A, B]):
    """A finite relation equipped with source and target preorder tests."""

    source: tuple[A, ...]
    target: tuple[B, ...]
    source_leq: Callable[[A, A], bool]
    target_leq: Callable[[B, B], bool]
    relation: Callable[[A, B], bool]

    def fibre(self, a: A) -> FrozenSet[B]:
        return frozenset(b for b in self.target if self.relation(a, b))

    def extension_failures(self) -> list[tuple[A, A, B]]:
        failures: list[tuple[A, A, B]] = []
        for a0 in self.source:
            for a1 in self.source:
                if not self.source_leq(a0, a1):
                    continue
                for b0 in self.fibre(a0):
                    if not any(
                        self.target_leq(b0, b1) and self.relation(a1, b1)
                        for b1 in self.target
                    ):
                        failures.append((a0, a1, b0))
        return failures

    def pull(self, target_class: Iterable[B]) -> FrozenSet[A]:
        accepted = frozenset(target_class)
        return frozenset(a for a in self.source if self.fibre(a) <= accepted)


def compose(
    first: FiniteCorrespondence[A, B],
    second: FiniteCorrespondence[B, C],
) -> FiniteCorrespondence[A, C]:
    """Return relational composition, using the shared intermediate universe."""
    if first.target != second.source:
        raise ValueError("Intermediate universes must agree in order and content")
    return FiniteCorrespondence(
        first.source,
        second.target,
        first.source_leq,
        second.target_leq,
        lambda a, c: any(first.relation(a, b) and second.relation(b, c)
                         for b in first.target),
    )


def minimal_complement(
    universe: Sequence[A],
    leq: Callable[[A, A], bool],
    lower_class: Iterable[A],
) -> FrozenSet[A]:
    """Compute inequivalent minimal elements outside a lower class."""
    inside = frozenset(lower_class)
    outside = [x for x in universe if x not in inside]

    def strict_below(y: A, x: A) -> bool:
        return leq(y, x) and not leq(x, y)

    return frozenset(x for x in outside
                     if not any(strict_below(y, x) for y in outside))


def divisibility_demo() -> None:
    """Demonstrate lower pullback and a finite obstruction basis."""
    source = (1, 2, 3, 6)
    target = (1, 2, 4, 8)
    divides = lambda x, y: y % x == 0
    corr = FiniteCorrespondence(
        source,
        target,
        divides,
        divides,
        lambda a, b: (2 ** a) % b == 0,
    )
    target_class = frozenset({1, 2, 4})
    pulled = corr.pull(target_class)
    obstructions = minimal_complement(source, divides, pulled)

    print("=== Divisibility correspondence ===")
    for a in source:
        print(f"fibre({a}) = {sorted(corr.fibre(a))}")
    print("extension failures:", corr.extension_failures())
    print("universal pullback:", sorted(pulled))
    print("minimal obstructions:", sorted(obstructions))
    assert not corr.extension_failures()
    assert pulled == frozenset({1, 2})
    assert obstructions == frozenset({3})


def composition_demo() -> None:
    """Numerically check contravariant pullback through composition."""
    divides = lambda x, y: y % x == 0
    first = FiniteCorrespondence(
        (1, 2, 3, 6), (1, 2, 4, 8), divides, divides,
        lambda a, b: (2 ** a) % b == 0,
    )
    second = FiniteCorrespondence(
        (1, 2, 4, 8), (0, 1, 2, 3), divides, lambda x, y: x <= y,
        lambda b, d: (2 ** d) <= b,
    )
    final_class = frozenset({0, 1, 2})
    composite = compose(first, second)
    direct = composite.pull(final_class)
    iterated = first.pull(second.pull(final_class))
    print("\n=== Composition law ===")
    print("composite pullback:", sorted(direct))
    print("iterated pullback: ", sorted(iterated))
    assert direct == iterated


def intersection_demo() -> None:
    """Check preservation of an intersection of target requirements."""
    divides = lambda x, y: y % x == 0
    corr = FiniteCorrespondence(
        (1, 2, 3, 6), (1, 2, 4, 8), divides, divides,
        lambda a, b: (2 ** a) % b == 0,
    )
    c1 = frozenset({1, 2, 4})
    c2 = frozenset({1, 2, 8})
    together = corr.pull(c1 & c2)
    separately = corr.pull(c1) & corr.pull(c2)
    print("\n=== Intersection law ===")
    print("pullback of intersection:", sorted(together))
    print("intersection of pullbacks:", sorted(separately))
    assert together == separately


def main() -> None:
    divisibility_demo()
    composition_demo()
    intersection_demo()
    print("\nAll demonstrations passed.")


if __name__ == "__main__":
    main()
