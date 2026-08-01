#!/usr/bin/env python3
"""Exact symbolic demonstrations for finite--cofinite infinitesimal probability.

A probability is represented as ``standard + infinitesimal * epsilon``.
No floating-point surrogate is used: the script demonstrates the cardinality
and affine-arithmetic identities, while the genuinely non-Archimedean order of
``epsilon`` is a mathematical property rather than a numerical approximation.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Hashable, Iterable, TypeVar

T = TypeVar("T", bound=Hashable)


@dataclass(frozen=True)
class AffineEpsilon:
    """An exact affine surreal expression a + b*epsilon with integer coefficients."""

    standard: int
    infinitesimal: int

    def __add__(self, other: "AffineEpsilon") -> "AffineEpsilon":
        return AffineEpsilon(
            self.standard + other.standard,
            self.infinitesimal + other.infinitesimal,
        )

    def __sub__(self, other: "AffineEpsilon") -> "AffineEpsilon":
        return AffineEpsilon(
            self.standard - other.standard,
            self.infinitesimal - other.infinitesimal,
        )

    def __str__(self) -> str:
        a, b = self.standard, self.infinitesimal
        if b == 0:
            return str(a)
        epsilon_term = "epsilon" if abs(b) == 1 else f"{abs(b)}*epsilon"
        if a == 0:
            return epsilon_term if b > 0 else f"-{epsilon_term}"
        sign = "+" if b > 0 else "-"
        return f"{a} {sign} {epsilon_term}"


@dataclass(frozen=True)
class FiniteCofiniteEvent:
    """A finite set, or a cofinite set represented by its finite missing set."""

    points: FrozenSet[T]
    is_cofinite: bool = False

    @classmethod
    def finite(cls, points: Iterable[T]) -> "FiniteCofiniteEvent[T]":
        return cls(frozenset(points), False)

    @classmethod
    def cofinite(cls, missing: Iterable[T]) -> "FiniteCofiniteEvent[T]":
        return cls(frozenset(missing), True)

    def probability(self) -> AffineEpsilon:
        """Return |A|*epsilon or 1-|A^c|*epsilon exactly."""
        if self.is_cofinite:
            return AffineEpsilon(1, -len(self.points))
        return AffineEpsilon(0, len(self.points))

    def disjoint_from(self, other: "FiniteCofiniteEvent[T]") -> bool:
        """Decide disjointness using only finite representatives."""
        if not self.is_cofinite and not other.is_cofinite:
            return self.points.isdisjoint(other.points)
        if not self.is_cofinite and other.is_cofinite:
            return self.points <= other.points
        if self.is_cofinite and not other.is_cofinite:
            return other.points <= self.points
        # Two cofinite subsets of an infinite universe cannot be disjoint.
        return False

    def union(self, other: "FiniteCofiniteEvent[T]") -> "FiniteCofiniteEvent[T]":
        """Form the union using finite sets and finite complements."""
        if not self.is_cofinite and not other.is_cofinite:
            return FiniteCofiniteEvent.finite(self.points | other.points)
        if not self.is_cofinite and other.is_cofinite:
            return FiniteCofiniteEvent.cofinite(other.points - self.points)
        if self.is_cofinite and not other.is_cofinite:
            return FiniteCofiniteEvent.cofinite(self.points - other.points)
        # (X\M) union (X\N) = X\(M intersection N)
        return FiniteCofiniteEvent.cofinite(self.points & other.points)


def audit_disjoint_additivity(
    left: FiniteCofiniteEvent[T], right: FiniteCofiniteEvent[T]
) -> bool:
    """Check P(A union B) = P(A) + P(B) for a disjoint represented pair."""
    if not left.disjoint_from(right):
        raise ValueError("The supplied events are not disjoint.")
    return left.union(right).probability() == left.probability() + right.probability()


def demonstrate() -> None:
    """Print representative finite, cofinite, normalization, and additivity cases."""
    singleton = FiniteCofiniteEvent.finite({"x"})
    five_points = FiniteCofiniteEvent.finite(range(5))
    whole_space = FiniteCofiniteEvent.cofinite(set())
    missing_five = FiniteCofiniteEvent.cofinite({1, 2, 3, 4, 5})
    restored_two = FiniteCofiniteEvent.finite({1, 2})
    remaining_union = missing_five.union(restored_two)

    print("Surreal finite--cofinite probability: exact symbolic demo")
    print("=" * 64)
    print(f"Singleton mass:              {singleton.probability()}")
    print(f"Five-point mass:             {five_points.probability()}")
    print(f"Whole-space mass:            {whole_space.probability()}")
    print(f"Cofinite, five missing:      {missing_five.probability()}")
    print(f"Finite, two restored:        {restored_two.probability()}")
    print(f"Union, three still missing:  {remaining_union.probability()}")
    print(
        "Additivity identity:         "
        f"{missing_five.probability()} + {restored_two.probability()} "
        f"= {remaining_union.probability()}"
    )
    print(
        "Audit passed:                "
        f"{audit_disjoint_additivity(missing_five, restored_two)}"
    )

    first = FiniteCofiniteEvent.finite({"a", "b", "c"})
    second = FiniteCofiniteEvent.finite({"d", "e"})
    print("\nDisjoint finite example")
    print(f"P(A) = {first.probability()}, P(B) = {second.probability()}")
    print(f"P(A union B) = {first.union(second).probability()}")
    print(f"Audit passed: {audit_disjoint_additivity(first, second)}")

    print("\nDyadic comparison represented symbolically")
    for n in range(8):
        print(f"0 < epsilon < 2^(-{n})")
    print("These inequalities describe the surreal cut; they are not decimal tests.")


if __name__ == "__main__":
    demonstrate()
