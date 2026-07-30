"""Numerical demonstrations for finite three-level Hahn series.

A rank (e, p, l) is ordered lexicographically and may be read as an
exponential, polynomial, and logarithmic growth level.  Sparse dictionaries
store only nonzero coefficients.  The examples illustrate first disagreement,
monomial separation, and compatibility with addition and multiplication.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, Optional, Tuple

Rank = Tuple[int, int, int]


@dataclass(frozen=True)
class Disagreement:
    """The least rank where two finite sparse series differ."""

    rank: Rank
    left: float
    right: float


Series = Dict[Rank, float]


def normalize(series: Series, tolerance: float = 1e-12) -> Series:
    """Remove coefficients numerically indistinguishable from zero."""
    return {rank: value for rank, value in series.items()
            if abs(value) > tolerance}


def coefficient(series: Series, rank: Rank) -> float:
    """Return a coefficient, using zero outside the sparse support."""
    return series.get(rank, 0.0)


def add(left: Series, right: Series, tolerance: float = 1e-12) -> Series:
    """Add two finite sparse series coefficientwise."""
    result = dict(left)
    for rank, value in right.items():
        result[rank] = result.get(rank, 0.0) + value
    return normalize(result, tolerance)


def subtract(left: Series, right: Series, tolerance: float = 1e-12) -> Series:
    """Subtract two finite sparse series coefficientwise."""
    return add(left, {rank: -value for rank, value in right.items()}, tolerance)


def add_ranks(left: Rank, right: Rank) -> Rank:
    """Apply the additive group law on growth ranks."""
    return tuple(a + b for a, b in zip(left, right))  # type: ignore[return-value]


def multiply(left: Series, right: Series, tolerance: float = 1e-12) -> Series:
    """Multiply finite sparse series by Hahn convolution."""
    result: Series = {}
    for left_rank, left_value in left.items():
        for right_rank, right_value in right.items():
            rank = add_ranks(left_rank, right_rank)
            result[rank] = result.get(rank, 0.0) + left_value * right_value
    return normalize(result, tolerance)


def first_disagreement(
    left: Series, right: Series, tolerance: float = 1e-12
) -> Optional[Disagreement]:
    """Return the lexicographically first unequal coefficient, if one exists."""
    ranks = sorted(set(left) | set(right))
    for rank in ranks:
        left_value = coefficient(left, rank)
        right_value = coefficient(right, rank)
        if abs(left_value - right_value) > tolerance:
            return Disagreement(rank, left_value, right_value)
    return None


def order(series: Series, tolerance: float = 1e-12) -> Optional[Rank]:
    """Return the least nonzero rank, or None for the zero series."""
    support = normalize(series, tolerance)
    return min(support) if support else None


def format_series(series: Series) -> str:
    """Render a finite sparse series in increasing-rank order."""
    if not series:
        return "0"
    return " + ".join(
        f"{value:g}*m^{rank}" for rank, value in sorted(series.items())
    )


def assert_agree_below(left: Series, right: Series, cut: Rank) -> None:
    """Check agreement at every represented rank strictly below a cut."""
    ranks: Iterable[Rank] = set(left) | set(right)
    assert all(coefficient(left, rank) == coefficient(right, rank)
               for rank in ranks if rank < cut)


def run_demo() -> None:
    """Run three deterministic demonstrations and print their witnesses."""
    print("DEMO 1 — First formal disagreement")
    f: Series = {(0, 0, 0): 2.0, (0, 1, -1): -3.0, (1, -2, 0): 5.0}
    g: Series = {(0, 0, 0): 2.0, (0, 1, -1): -3.0, (1, -2, 0): 7.0}
    witness = first_disagreement(f, g)
    assert witness is not None
    difference_order = order(subtract(f, g))
    assert witness.rank == difference_order
    assert_agree_below(f, g, witness.rank)
    print("F =", format_series(f))
    print("G =", format_series(g))
    print("first disagreement:", witness)
    print("order(F-G):", difference_order)

    print("\nDEMO 2 — Distinct monomial ranks")
    r, s = (0, 2, 0), (1, -5, 3)
    monomial_r: Series = {r: 4.0}
    monomial_s: Series = {s: 9.0}
    separation = first_disagreement(monomial_r, monomial_s)
    assert separation == Disagreement(r, 4.0, 0.0)
    print("coefficient witness:", separation)

    print("\nDEMO 3 — Arithmetic compatibility")
    f1: Series = {(-1, 0, 2): 1.5, (0, 0, 0): 2.0}
    g1 = dict(f1)
    f2: Series = {(0, 1, 0): -4.0, (1, 0, 0): 3.0}
    g2 = dict(f2)
    sum_gap = first_disagreement(add(f1, f2), add(g1, g2))
    product_gap = first_disagreement(multiply(f1, f2), multiply(g1, g2))
    assert sum_gap is None and product_gap is None
    print("sum agreement:", sum_gap is None)
    print("product agreement:", product_gap is None)
    print("product =", format_series(multiply(f1, f2)))


if __name__ == "__main__":
    run_demo()
