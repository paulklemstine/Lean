#!/usr/bin/env python3
"""Numerical demonstrations of coherent nonassociative composition.

The script uses only the Python standard library. It checks the three-arrow
composition table, constructs the quotient by coherent equivalence, compares
bounded continuation traces, and audits a real-valued hybrid telescope.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from itertools import product
from typing import Callable, Iterable, Sequence, TypeVar


class Arrow(str, Enum):
    E = "e"
    A = "a"
    B = "b"


def compose(x: Arrow, y: Arrow) -> Arrow:
    """Return x composed with y in the three-arrow example."""
    table: dict[tuple[Arrow, Arrow], Arrow] = {
        (Arrow.E, Arrow.E): Arrow.E, (Arrow.E, Arrow.A): Arrow.A,
        (Arrow.E, Arrow.B): Arrow.B, (Arrow.A, Arrow.E): Arrow.A,
        (Arrow.A, Arrow.A): Arrow.B, (Arrow.A, Arrow.B): Arrow.A,
        (Arrow.B, Arrow.E): Arrow.B, (Arrow.B, Arrow.A): Arrow.E,
        (Arrow.B, Arrow.B): Arrow.B,
    }
    return table[(x, y)]


Word = tuple[Arrow, ...]
T = TypeVar("T")


def words(alphabet: Sequence[T], maximum_length: int) -> Iterable[tuple[T, ...]]:
    """Generate all words over alphabet of length at most maximum_length."""
    for length in range(maximum_length + 1):
        yield from product(alphabet, repeat=length)


def bounded_right_trace(radius: int, prefix: tuple[T, ...], alphabet: Sequence[T]) -> set[tuple[T, ...]]:
    """Compute all words of length at most radius beginning with prefix."""
    if len(prefix) > radius:
        return set()
    return {prefix + suffix for suffix in words(alphabet, radius - len(prefix))}


def quotient_class(_: Arrow) -> int:
    """Map an arrow to its class for the indiscrete coherent relation."""
    return 0


def hybrid_audit(scores: Sequence[float]) -> tuple[float, list[float], float, float]:
    """Return endpoint gap, local gaps, telescoping sum, and uniform bound."""
    if len(scores) < 2:
        raise ValueError("at least two scores are required")
    local = [abs(x - y) for x, y in zip(scores, scores[1:])]
    endpoint = abs(scores[0] - scores[-1])
    telescope = sum(local)
    uniform = len(local) * max(local)
    if endpoint > telescope + 1e-12 or telescope > uniform + 1e-12:
        raise AssertionError("triangle-inequality audit failed")
    return endpoint, local, telescope, uniform


@dataclass(frozen=True)
class Expr:
    """A small binary expression tree."""
    atom: Arrow | None = None
    left: "Expr | None" = None
    right: "Expr | None" = None

    def evaluate(self) -> Arrow:
        if self.atom is not None:
            return self.atom
        if self.left is None or self.right is None:
            raise ValueError("malformed expression")
        return compose(self.left.evaluate(), self.right.evaluate())


def main() -> None:
    a = Arrow.A
    left = compose(compose(a, a), a)
    right = compose(a, compose(a, a))
    print("Three-arrow composition")
    print(f"  (a∘a)∘a = {left.value}")
    print(f"  a∘(a∘a) = {right.value}")
    print(f"  Strictly equal? {left == right}")
    print(f"  Equal after coherent quotient? {quotient_class(left) == quotient_class(right)}")
    assert left == Arrow.E and right == Arrow.A and left != right

    atoms = [Arrow.E, Arrow.A, Arrow.B]
    radius = 3
    w: Word = (Arrow.A, Arrow.B)
    w_prime: Word = (Arrow.A, Arrow.A)
    trace = bounded_right_trace(radius, w, atoms)
    trace_prime = bounded_right_trace(radius, w_prime, atoms)
    print("\nBounded continuation fingerprints")
    print(f"  |T_{radius}(ab)| = {len(trace)}")
    print(f"  |T_{radius}(aa)| = {len(trace_prime)}")
    print(f"  Traces equal? {trace == trace_prime}")
    assert trace != trace_prime
    # Exhaustively demonstrate separation for every word within a small radius.
    all_words = list(words(atoms, radius))
    signatures = [frozenset(bounded_right_trace(radius, x, atoms)) for x in all_words]
    assert len(signatures) == len(set(signatures))
    print(f"  Distinct traces for all {len(all_words)} words of length at most {radius}: yes")

    scores = [0.12, 0.15, 0.19, 0.18, 0.22]
    endpoint, local, telescope, uniform = hybrid_audit(scores)
    print("\nHybrid reassociation audit")
    print(f"  Scores: {scores}")
    print(f"  Local drifts: {[round(x, 4) for x in local]}")
    print(f"  Endpoint drift: {endpoint:.4f}")
    print(f"  Sum of local drifts: {telescope:.4f}")
    print(f"  Number of steps × largest local drift: {uniform:.4f}")
    assert endpoint <= telescope <= uniform


if __name__ == "__main__":
    main()
