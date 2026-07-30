#!/usr/bin/env python3
"""Numerical illustrations for exponential–logarithmic special values.

This script uses only the Python standard library. The computations demonstrate
positivity and screen a finite family of small integer polynomial relations.
They do not prove transcendence or algebraic independence.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import exp, log1p, sqrt
from typing import Iterable, Sequence


@dataclass(frozen=True)
class RelationCandidate:
    """A bounded polynomial candidate and its floating-point residual."""

    coefficients: tuple[int, ...]
    monomials: tuple[tuple[int, int], ...]
    residual: float


def eml_value(a: float) -> float:
    """Return exp(a) * log(1 + a), requiring a > -1."""
    if a <= -1.0:
        raise ValueError("real logarithm requires a > -1")
    return exp(a) * log1p(a)


def sign_classification(a: float) -> int:
    """Return -1, 0, or 1 according to the exact sign theorem."""
    if a <= -1.0:
        raise ValueError("real logarithm requires a > -1")
    return -1 if a < 0.0 else (1 if a > 0.0 else 0)


def monomials_through_degree(degree: int) -> tuple[tuple[int, int], ...]:
    """List exponent pairs (i, j) with i + j <= degree."""
    if degree < 0:
        raise ValueError("degree must be nonnegative")
    return tuple((i, total - i) for total in range(degree + 1)
                 for i in range(total + 1))


def evaluate_polynomial(
    coefficients: Sequence[int],
    monomials: Sequence[tuple[int, int]],
    x: float,
    y: float,
) -> float:
    """Evaluate sum c_ij x^i y^j in double precision."""
    if len(coefficients) != len(monomials):
        raise ValueError("coefficient and monomial counts differ")
    return sum(c * x**i * y**j
               for c, (i, j) in zip(coefficients, monomials))


def bounded_relation_search(
    x: float,
    y: float,
    degree: int = 1,
    height: int = 3,
) -> RelationCandidate:
    """Find the smallest residual in a finite normalized polynomial family.

    Coefficients lie in [-height, height]. To remove scalar sign duplicates,
    the last nonzero coefficient is required to be positive. This remains only
    a bounded numerical screen, never a proof of algebraic independence.
    """
    if height < 1:
        raise ValueError("height must be positive")
    mons = monomials_through_degree(degree)
    best: RelationCandidate | None = None
    for coeffs in product(range(-height, height + 1), repeat=len(mons)):
        if not any(coeffs):
            continue
        last_nonzero = next(c for c in reversed(coeffs) if c != 0)
        if last_nonzero < 0:
            continue
        residual = abs(evaluate_polynomial(coeffs, mons, x, y))
        candidate = RelationCandidate(tuple(coeffs), mons, residual)
        if best is None or candidate.residual < best.residual:
            best = candidate
    if best is None:
        raise RuntimeError("search family unexpectedly empty")
    return best


def format_polynomial(candidate: RelationCandidate) -> str:
    """Render a candidate polynomial in compact human-readable form."""
    terms: list[str] = []
    for coefficient, (i, j) in zip(candidate.coefficients, candidate.monomials):
        if coefficient == 0:
            continue
        monomial = ("X" if i == 1 else f"X^{i}" if i else "")
        monomial += ("Y" if j == 1 else f"Y^{j}" if j else "")
        terms.append(f"{coefficient:+d}*{monomial or '1'}")
    return " ".join(terms).lstrip("+")


def positivity_table(inputs: Iterable[float]) -> None:
    """Print values and compare their numerical signs with the theorem."""
    print("Input                 E(a)                    expected sign")
    for a in inputs:
        print(f"{a:12.8f}  {eml_value(a):24.16g}  {sign_classification(a):+d}")


def main() -> None:
    """Run the square-root example and a small relation screen."""
    inputs = [-0.5, 0.0, 0.25, sqrt(2.0), sqrt(3.0)]
    positivity_table(inputs)

    u = eml_value(sqrt(2.0))
    v = eml_value(sqrt(3.0))
    print("\nSquare-root pair")
    print(f"U = {u:.17g}")
    print(f"V = {v:.17g}")

    candidate = bounded_relation_search(u, v)
    print("\nBest residual in normalized degree <= 1, height <= 3 search")
    print("P(X,Y) =", format_polynomial(candidate))
    print(f"|P(U,V)| = {candidate.residual:.17g}")
    print("\nThis finite double-precision search is illustrative only; it does")
    print("not establish transcendence or algebraic independence.")


if __name__ == "__main__":
    main()
