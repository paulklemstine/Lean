#!/usr/bin/env python3
"""Numerical demonstrations for non-Archimedean tropical bridges.

The script uses only the Python standard library. It demonstrates:
1. non-Archimedean cancellation with exact p-adic orders of integers;
2. max-corner detection and invariance under positive scaling;
3. weighted intersection transfer under a multiplicity-preserving bijection.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Hashable, Mapping, Sequence, TypeVar

Label = TypeVar("Label", bound=Hashable)


def p_adic_order(value: int, prime: int) -> int:
    """Return ord_prime(value) for a nonzero integer and a prime base."""
    if value == 0:
        raise ValueError("p-adic order of zero is not finite")
    if prime < 2:
        raise ValueError("prime must be at least 2")
    n = abs(value)
    order = 0
    while n % prime == 0:
        n //= prime
        order += 1
    return order


def maximal_p_adic_indices(values: Sequence[int], prime: int) -> list[int]:
    """Indices having maximal p-adic norm, equivalently minimal p-adic order."""
    if not values or any(value == 0 for value in values):
        raise ValueError("provide a nonempty sequence of nonzero integers")
    orders = [p_adic_order(value, prime) for value in values]
    minimum = min(orders)
    return [index for index, order in enumerate(orders) if order == minimum]


def verify_vanishing_sum_cancellation(values: Sequence[int], prime: int) -> bool:
    """Check that a vanishing nonzero integer sum has at least two maximal norms."""
    if sum(values) != 0:
        raise ValueError("the terms must sum to zero")
    return len(maximal_p_adic_indices(values, prime)) >= 2


def maximizing_indices(values: Sequence[Fraction]) -> list[int]:
    """Return all indices attaining the exact maximum of rational values."""
    if not values:
        raise ValueError("at least one tropical term is required")
    maximum = max(values)
    return [index for index, value in enumerate(values) if value == maximum]


def is_max_corner(values: Sequence[Fraction]) -> bool:
    """Decide whether at least two tropical terms attain the maximum."""
    return len(maximizing_indices(values)) >= 2


def tropical_line_terms(x: Fraction, y: Fraction) -> list[Fraction]:
    """Evaluate the affine terms 0, x, and y of the standard tropical line."""
    return [Fraction(0), x, y]


def verify_positive_scale_invariance(
    values: Sequence[Fraction], scale: Fraction
) -> bool:
    """Check equality of maximizer sets before and after positive scaling."""
    if scale <= 0:
        raise ValueError("scale must be positive")
    scaled = [scale * value for value in values]
    return maximizing_indices(values) == maximizing_indices(scaled)


@dataclass(frozen=True)
class WeightedCorrespondence:
    """Finite source-to-target matching with multiplicities on both sides."""

    mapping: Mapping[str, str]
    source_multiplicity: Mapping[str, int]
    target_multiplicity: Mapping[str, int]

    def validate(self) -> None:
        """Validate bijectivity, support equality, and nonnegative weights."""
        sources = set(self.mapping)
        targets = set(self.mapping.values())
        if sources != set(self.source_multiplicity):
            raise ValueError("source multiplicities must match mapping domain")
        if targets != set(self.target_multiplicity):
            raise ValueError("target multiplicities must match mapping image")
        if len(targets) != len(self.mapping):
            raise ValueError("the correspondence must be injective")
        all_weights = list(self.source_multiplicity.values()) + list(
            self.target_multiplicity.values()
        )
        if any(weight < 0 for weight in all_weights):
            raise ValueError("multiplicities must be nonnegative")
        for source, target in self.mapping.items():
            if self.source_multiplicity[source] != self.target_multiplicity[target]:
                raise ValueError(f"multiplicity mismatch at {source!r} -> {target!r}")

    def intersection_numbers(self) -> tuple[int, int]:
        """Return classical and tropical weighted totals after validation."""
        self.validate()
        return (
            sum(self.source_multiplicity.values()),
            sum(self.target_multiplicity.values()),
        )

    def verifies_bezout(self, degree_one: int, degree_two: int) -> bool:
        """Check that both transferred totals equal degree_one * degree_two."""
        classical, tropical = self.intersection_numbers()
        return classical == tropical == degree_one * degree_two


def render_tropical_line_ascii(radius: int = 6) -> str:
    """Render grid points of max(0,x,y)'s corner locus as an ASCII diagram."""
    if radius < 1:
        raise ValueError("radius must be positive")
    rows: list[str] = []
    for y in range(radius, -radius - 1, -1):
        row: list[str] = []
        for x in range(-radius, radius + 1):
            terms = tropical_line_terms(Fraction(x), Fraction(y))
            row.append("#" if is_max_corner(terms) else ".")
        rows.append("".join(row))
    return "\n".join(rows)


def main() -> None:
    """Run all demonstrations and print their exact numerical conclusions."""
    p = 2
    terms = [12, 20, -32]
    orders = [p_adic_order(value, p) for value in terms]
    maximal = maximal_p_adic_indices(terms, p)
    print("NON-ARCHIMEDEAN CANCELLATION")
    print(f"terms: {terms}; sum: {sum(terms)}")
    print(f"2-adic orders: {orders}")
    print(f"indices of maximal 2-adic norm: {maximal}")
    print(f"maximum attained at least twice: {verify_vanishing_sum_cancellation(terms, p)}")

    point = (Fraction(3), Fraction(3))
    values = tropical_line_terms(*point)
    print("\nTROPICAL CORNER AND SCALE INVARIANCE")
    print(f"point: {point}; term values [0,x,y]: {values}")
    print(f"maximizing indices: {maximizing_indices(values)}")
    print(f"is a corner: {is_max_corner(values)}")
    for scale in [Fraction(1), Fraction(2), Fraction(17, 3)]:
        print(
            f"scale {scale}: same maximizers = "
            f"{verify_positive_scale_invariance(values, scale)}"
        )
    print("\nASCII SAMPLE OF THE TROPICAL LINE")
    print(render_tropical_line_ascii())

    correspondence = WeightedCorrespondence(
        mapping={"P1": "Q2", "P2": "Q4", "P3": "Q1", "P4": "Q3"},
        source_multiplicity={"P1": 1, "P2": 2, "P3": 1, "P4": 2},
        target_multiplicity={"Q1": 1, "Q2": 1, "Q3": 2, "Q4": 2},
    )
    classical, tropical = correspondence.intersection_numbers()
    print("\nWEIGHTED INTERSECTION CORRESPONDENCE")
    print(f"classical total: {classical}; tropical total: {tropical}")
    print(f"matches degrees 2 and 3: {correspondence.verifies_bezout(2, 3)}")


if __name__ == "__main__":
    main()
