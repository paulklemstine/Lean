#!/usr/bin/env python3
"""Symbolic demonstrations of finite–cofinite surreal probability.

The program represents a probability exactly as a + b*epsilon.  It never
replaces the infinitesimal epsilon by a floating-point number; optional dyadic
proxies are used only to illustrate finitely many defining inequalities.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import FrozenSet, Hashable, Iterable, TypeVar

T = TypeVar("T", bound=Hashable)


@dataclass(frozen=True)
class SurrealAffine:
    """The symbolic surreal value a + b*epsilon with integer coefficients."""

    constant: int
    epsilon_coefficient: int

    def __add__(self, other: "SurrealAffine") -> "SurrealAffine":
        return SurrealAffine(
            self.constant + other.constant,
            self.epsilon_coefficient + other.epsilon_coefficient,
        )

    def __sub__(self, other: "SurrealAffine") -> "SurrealAffine":
        return SurrealAffine(
            self.constant - other.constant,
            self.epsilon_coefficient - other.epsilon_coefficient,
        )

    def __str__(self) -> str:
        a, b = self.constant, self.epsilon_coefficient
        if b == 0:
            return str(a)
        infinitesimal = "epsilon" if abs(b) == 1 else f"{abs(b)}*epsilon"
        if a == 0:
            return infinitesimal if b > 0 else f"-{infinitesimal}"
        sign = "+" if b > 0 else "-"
        return f"{a} {sign} {infinitesimal}"


@dataclass(frozen=True)
class FiniteCofiniteEvent:
    """An event represented by its finite included set or finite excluded set."""

    mode: str
    points: FrozenSet[T]

    @classmethod
    def finite(cls, points: Iterable[T]) -> "FiniteCofiniteEvent[T]":
        return cls("finite", frozenset(points))

    @classmethod
    def cofinite(cls, excluded: Iterable[T]) -> "FiniteCofiniteEvent[T]":
        return cls("cofinite", frozenset(excluded))

    def probability(self) -> SurrealAffine:
        """Return |A|*epsilon or 1-|A^c|*epsilon exactly and symbolically."""
        size = len(self.points)
        if self.mode == "finite":
            return SurrealAffine(0, size)
        if self.mode == "cofinite":
            return SurrealAffine(1, -size)
        raise ValueError("mode must be 'finite' or 'cofinite'")

    def complement(self) -> "FiniteCofiniteEvent[T]":
        mode = "cofinite" if self.mode == "finite" else "finite"
        return FiniteCofiniteEvent(mode, self.points)

    def is_disjoint(self, other: "FiniteCofiniteEvent[T]") -> bool:
        if self.mode == "finite" and other.mode == "finite":
            return self.points.isdisjoint(other.points)
        if self.mode == "finite" and other.mode == "cofinite":
            return self.points <= other.points
        if self.mode == "cofinite" and other.mode == "finite":
            return other.points <= self.points
        return False  # two cofinite events cannot be disjoint in an infinite space

    def union(self, other: "FiniteCofiniteEvent[T]") -> "FiniteCofiniteEvent[T]":
        if self.mode == "finite" and other.mode == "finite":
            return FiniteCofiniteEvent.finite(self.points | other.points)
        if self.mode == "finite" and other.mode == "cofinite":
            return FiniteCofiniteEvent.cofinite(other.points - self.points)
        if self.mode == "cofinite" and other.mode == "finite":
            return FiniteCofiniteEvent.cofinite(self.points - other.points)
        return FiniteCofiniteEvent.cofinite(self.points & other.points)


def dyadic_proxy(depth: int) -> Fraction:
    """Return 2^(-(depth+1)), a proxy below the first depth+1 dyadic bounds."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return Fraction(1, 2 ** (depth + 1))


def demonstrate() -> None:
    """Print normalization, singleton masses, additivity, and strict increments."""
    empty = FiniteCofiniteEvent.finite([])
    whole = FiniteCofiniteEvent.cofinite([])
    singleton = FiniteCofiniteEvent.finite(["x"])
    finite_a = FiniteCofiniteEvent.finite(["a", "b"])
    finite_b = FiniteCofiniteEvent.finite(["c", "d", "e"])
    almost_all = FiniteCofiniteEvent.cofinite(["a", "b", "z"])

    print("SURREAL FINITE–COFINITE PROBABILITY")
    print("P(empty) =", empty.probability())
    print("P(whole space) =", whole.probability())
    print("P({x}) =", singleton.probability())
    print("P(complement of {x}) =", singleton.complement().probability())
    print("Complement sum =", singleton.probability() + singleton.complement().probability())

    union = finite_a.union(finite_b)
    print("\nDisjoint finite union:")
    print("disjoint:", finite_a.is_disjoint(finite_b))
    print("P(A union B) =", union.probability())
    print("P(A) + P(B) =", finite_a.probability() + finite_b.probability())
    assert union.probability() == finite_a.probability() + finite_b.probability()

    print("\nDisjoint finite/cofinite union:")
    print("disjoint:", finite_a.is_disjoint(almost_all))
    mixed_union = finite_a.union(almost_all)
    print("P(A union C) =", mixed_union.probability())
    print("P(A) + P(C) =", finite_a.probability() + almost_all.probability())
    assert mixed_union.probability() == finite_a.probability() + almost_all.probability()

    enlarged = finite_a.union(FiniteCofiniteEvent.finite(["new"]))
    print("\nStrict finite insertion:")
    print("P(A) =", finite_a.probability())
    print("P(A union {new}) =", enlarged.probability())
    print("increment =", enlarged.probability() - finite_a.probability())

    depth = 12
    proxy = dyadic_proxy(depth)
    print(f"\nFinite-resolution illustration through n={depth}:")
    print(f"proxy epsilon = {proxy} (illustrative only)")
    assert all(proxy < Fraction(1, 2**n) for n in range(depth + 1))
    for n in (0, 1, 2, 4, 8, 12):
        print(f"epsilon_proxy < 2^-{n}: {proxy < Fraction(1, 2**n)}")


if __name__ == "__main__":
    demonstrate()
