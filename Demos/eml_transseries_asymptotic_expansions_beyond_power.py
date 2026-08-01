#!/usr/bin/env python3
"""Numerical demonstrations for integer-ranked finite Hahn transseries.

The examples model finite truncations as sparse coefficient dictionaries.  They
illustrate unique first disagreement, the parity obstruction for square orders,
and failure of injectivity of evaluation at a single point.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Iterable, Mapping, Optional, Sequence, TypeAlias

Rank: TypeAlias = tuple[int, int, int]
Coefficient: TypeAlias = Fraction
Series: TypeAlias = Mapping[Rank, Coefficient]


def coefficient(series: Series, rank: Rank) -> Coefficient:
    """Return the coefficient at ``rank``, interpreting missing entries as zero."""
    return series.get(rank, Fraction(0))


def first_disagreement(left: Series, right: Series) -> Optional[Rank]:
    """Return the lexicographically least rank with unequal coefficients.

    For finite sparse series this is the constructive version of the unique
    first-disagreement theorem.  ``None`` means that the finite series agree.
    """
    ranks = sorted(set(left) | set(right))
    return next(
        (rank for rank in ranks if coefficient(left, rank) != coefficient(right, rank)),
        None,
    )


def agreement_certificate(left: Series, right: Series) -> str:
    """Build a readable certificate for equality or first disagreement."""
    rank = first_disagreement(left, right)
    if rank is None:
        return "The two finite series agree at every represented rank."
    earlier = sorted(r for r in set(left) | set(right) if r < rank)
    assert all(coefficient(left, r) == coefficient(right, r) for r in earlier)
    return (
        f"First disagreement rank: {rank}; "
        f"left coefficient = {coefficient(left, rank)}, "
        f"right coefficient = {coefficient(right, rank)}."
    )


def doubled_rank(rank: Rank) -> Rank:
    """Return twice a growth rank, coordinate by coordinate."""
    return tuple(2 * coordinate for coordinate in rank)  # type: ignore[return-value]


def candidate_square_root_order(rank: Rank) -> Optional[Rank]:
    """Return the possible order of a square root, or reject odd coordinates.

    This checks the necessary equation ``2 * root_order = rank``.  Passing this
    test is not sufficient for a whole series to be a square; failing it is a
    conclusive obstruction.
    """
    if any(coordinate % 2 != 0 for coordinate in rank):
        return None
    return tuple(coordinate // 2 for coordinate in rank)  # type: ignore[return-value]


@dataclass(frozen=True)
class NamedExpression:
    """A named real expression used to exhibit point-evaluation collisions."""

    name: str
    evaluate: Callable[[float], float]


def evaluation_collisions(
    expressions: Sequence[NamedExpression], point: float
) -> dict[float, list[str]]:
    """Group distinct expression names that share a value at ``point``."""
    buckets: dict[float, list[str]] = {}
    for expression in expressions:
        value = expression.evaluate(point)
        buckets.setdefault(value, []).append(expression.name)
    return {value: names for value, names in buckets.items() if len(names) > 1}


def format_series(series: Series) -> str:
    """Format a finite sparse transseries in increasing rank order."""
    if not series:
        return "0"
    return " + ".join(f"({coefficient(series, rank)}) t^{rank}" for rank in sorted(series))


def run_demo() -> None:
    """Run deterministic examples of all three principal results."""
    left: dict[Rank, Coefficient] = {
        (0, 0, 0): Fraction(3),
        (1, 0, 0): Fraction(2),
        (1, 1, 0): Fraction(-1),
    }
    right: dict[Rank, Coefficient] = {
        (0, 0, 0): Fraction(3),
        (1, 0, 0): Fraction(5),
        (1, 1, 0): Fraction(-1),
    }

    print("=== Unique first disagreement ===")
    print("F =", format_series(left))
    print("G =", format_series(right))
    print(agreement_certificate(left, right))
    print()

    print("=== Square-order parity obstruction ===")
    test_ranks: Iterable[Rank] = ((1, 0, 0), (2, -4, 6), (0, 3, 0))
    for rank in test_ranks:
        candidate = candidate_square_root_order(rank)
        if candidate is None:
            print(f"Rank {rank} cannot equal twice an integer rank.")
        else:
            assert doubled_rank(candidate) == rank
            print(f"Rank {rank} passes the order test with half-rank {candidate}.")
    print()

    print("=== Point-evaluation collisions ===")
    expressions = [
        NamedExpression("x", lambda x: x),
        NamedExpression("0", lambda x: 0.0),
        NamedExpression("x^2", lambda x: x * x),
    ]
    for point in (0.0, 2.0):
        values = {expression.name: expression.evaluate(point) for expression in expressions}
        print(f"At x = {point:g}: values = {values}")
        print(f"Collisions: {evaluation_collisions(expressions, point) or 'none'}")


if __name__ == "__main__":
    run_demo()
