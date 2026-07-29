#!/usr/bin/env python3
"""Exact numerical demonstrations of the unramified symmetric-square transfer."""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, Sequence, TypeVar

Number = TypeVar("Number", int, Fraction)
Polynomial = list[Number]  # coefficients in increasing degree


def multiply_polynomials(p: Sequence[Number], q: Sequence[Number]) -> Polynomial[Number]:
    """Return the coefficient array of p(X)q(X) using exact convolution."""
    if not p or not q:
        return []
    result = [p[0] * 0 for _ in range(len(p) + len(q) - 1)]
    for i, left in enumerate(p):
        for j, right in enumerate(q):
            result[i + j] += left * right
    return result


def euler_denominator(parameters: Iterable[Number]) -> Polynomial[Number]:
    """Compute the coefficients of product (1 - alpha*X)."""
    coefficients: Polynomial[Number] = [1]  # type: ignore[list-item]
    for alpha in parameters:
        coefficients = multiply_polynomials(coefficients, [1, -alpha])  # type: ignore[list-item]
    return coefficients


def symmetric_square(a: Number, b: Number) -> tuple[Number, Number, Number]:
    """Return the rank-three symmetric-square Satake parameters."""
    return (a * a, a * b, b * b)


def tensor_square(a: Number, b: Number) -> tuple[Number, Number, Number, Number]:
    """Return the rank-four tensor-square parameters, with multiplicity."""
    return (a * a, a * b, a * b, b * b)


def product(values: Iterable[Number]) -> Number:
    """Multiply a nonempty iterable exactly."""
    iterator = iter(values)
    result = next(iterator)
    for value in iterator:
        result *= value
    return result


def format_polynomial(coefficients: Sequence[Number]) -> str:
    """Format an increasing-degree coefficient array as a readable expression."""
    terms: list[str] = []
    for degree, coefficient in enumerate(coefficients):
        if coefficient == 0:
            continue
        magnitude = abs(coefficient)
        if degree == 0:
            body = str(magnitude)
        elif degree == 1:
            body = "X" if magnitude == 1 else f"{magnitude}X"
        else:
            body = f"X^{degree}" if magnitude == 1 else f"{magnitude}X^{degree}"
        if not terms:
            terms.append(body if coefficient > 0 else f"-{body}")
        else:
            terms.append((" + " if coefficient > 0 else " - ") + body)
    return "".join(terms) if terms else "0"


def demonstrate(a: Number, b: Number) -> None:
    """Print and assert all principal local identities for a parameter pair."""
    lifted = symmetric_square(a, b)
    determinant = (a * b,)
    tensor = tensor_square(a, b)

    lifted_denominator = euler_denominator(lifted)
    determinant_denominator = euler_denominator(determinant)
    tensor_denominator = euler_denominator(tensor)
    factored_denominator = multiply_polynomials(
        lifted_denominator, determinant_denominator
    )

    original_central_character = a * b
    lifted_central_character = product(lifted)
    lifted_trace = sum(lifted)

    assert lifted_central_character == original_central_character**3
    assert tensor_denominator == factored_denominator
    assert lifted_trace == a * a + a * b + b * b
    assert (a - b) * lifted_trace == a**3 - b**3

    print(f"Input parameters: ({a}, {b})")
    print(f"Symmetric-square parameters: {lifted}")
    print(f"Tensor-square parameters:    {tensor}")
    print(f"Original central character:  {original_central_character}")
    print(f"Lifted central character:    {lifted_central_character}")
    print(f"Lifted trace:                {lifted_trace}")
    print(f"Symmetric-square denominator: {format_polynomial(lifted_denominator)}")
    print(f"Determinant denominator:      {format_polynomial(determinant_denominator)}")
    print(f"Tensor-square denominator:    {format_polynomial(tensor_denominator)}")
    print("All identities hold exactly.\n")


def demonstrate_scalar_reduction(a: int, b: int, modulus: int) -> None:
    """Show that reducing parameters commutes with the symmetric-square lift."""
    lift_then_reduce = tuple(x % modulus for x in symmetric_square(a, b))
    reduce_then_lift = tuple(
        x % modulus for x in symmetric_square(a % modulus, b % modulus)
    )
    assert lift_then_reduce == reduce_then_lift
    print(f"Scalar reduction modulo {modulus}: {lift_then_reduce}")
    print("Lifting before or after reduction gives the same parameters.\n")


def main() -> None:
    """Run integer, rational, degenerate, and finite-ring examples."""
    demonstrate(2, 3)
    demonstrate(-2, 5)
    demonstrate(Fraction(2, 3), Fraction(5, 7))
    demonstrate(0, 4)
    demonstrate_scalar_reduction(11, 17, 5)


if __name__ == "__main__":
    main()
