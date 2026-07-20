#!/usr/bin/env python3
"""Numerical demonstrations for coherent coordinate-deletion limits.

The script uses only Python's standard library. It demonstrates prefix assembly,
diagonal reconstruction, finite-stage lifting, exact Bernoulli coefficients, and
nonzero monomial representatives over the two-element field.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import Iterable, Sequence

Bit = int
Stage = tuple[Bit, ...]


def validate_bits(values: Iterable[int]) -> tuple[Bit, ...]:
    """Return values as a tuple after checking that every entry is 0 or 1."""
    result = tuple(values)
    if any(value not in (0, 1) for value in result):
        raise ValueError("Boolean coordinates must be 0 or 1")
    return result


def assemble_prefixes(sequence: Sequence[Bit]) -> list[Stage]:
    """Materialize all nonempty finite prefixes of a Boolean sequence."""
    bits = validate_bits(sequence)
    return [bits[: n + 1] for n in range(len(bits))]


def is_coherent(stages: Sequence[Stage]) -> bool:
    """Test whether deleting each final coordinate gives the preceding stage."""
    if any(len(stage) != n + 1 for n, stage in enumerate(stages)):
        return False
    return all(stages[n + 1][:-1] == stages[n] for n in range(len(stages) - 1))


def diagonal(stages: Sequence[Stage]) -> tuple[Bit, ...]:
    """Extract the last coordinate of each stage after checking coherence."""
    if not is_coherent(stages):
        raise ValueError("The supplied finite family is not coherent")
    return tuple(stage[-1] for stage in stages)


def lift_stage(stage: Sequence[Bit], total_length: int) -> list[Stage]:
    """Lift one stage by zero-extending it, then assemble through total_length."""
    prefix = validate_bits(stage)
    if not prefix:
        raise ValueError("A stage must contain at least one coordinate")
    if total_length < len(prefix):
        raise ValueError("total_length must include the supplied stage")
    extension = prefix + (0,) * (total_length - len(prefix))
    return assemble_prefixes(extension)


def bernoulli_numbers(count: int) -> list[Fraction]:
    """Compute B_0 through B_count exactly from the generating recurrence."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    values = [Fraction(1)]
    for n in range(1, count + 1):
        numerator = sum(Fraction(comb(n + 1, k)) * values[k] for k in range(n))
        values.append(-numerator / Fraction(n + 1))
    return values


def exponential_product_coefficients(values: Sequence[Fraction]) -> list[Fraction]:
    """Return coefficients of B(t)(exp(t)-1) in the t^m/m! basis.

    Coefficients are returned through degree len(values). The final coefficient
    only uses the supplied Bernoulli values and is therefore still exact.
    """
    result: list[Fraction] = [Fraction(0)]
    for m in range(1, len(values) + 1):
        coefficient = sum(
            Fraction(comb(m, k)) * values[k] for k in range(min(m, len(values)))
        )
        result.append(coefficient)
    return result


def polynomial_power_over_f2(n: int) -> dict[int, Bit]:
    """Represent w^n in F_2[w] as a sparse degree-to-coefficient dictionary."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return {n: 1}


def format_egf(values: Sequence[Fraction]) -> str:
    """Format a truncated exponential generating series."""
    terms = []
    for n, value in enumerate(values):
        terms.append(f"({value}) t^{n}/{factorial(n)}")
    return " + ".join(terms)


def main() -> None:
    sequence = (1, 0, 1, 1, 0, 0, 1)
    stages = assemble_prefixes(sequence)
    recovered = diagonal(stages)
    print("COORDINATE-DELETION LIMIT")
    for n, stage in enumerate(stages):
        print(f"  X_{n}: {stage}")
    print(f"  coherent: {is_coherent(stages)}")
    print(f"  diagonal: {recovered}")
    print(f"  exact reconstruction: {recovered == sequence}\n")

    requested_stage = (1, 1, 0, 1)
    lifted = lift_stage(requested_stage, total_length=8)
    print("FINITE-STAGE SURJECTIVITY")
    print(f"  requested X_3 vector: {requested_stage}")
    print(f"  projected lift:       {lifted[3]}")
    print(f"  recovered exactly:    {lifted[3] == requested_stage}\n")

    values = bernoulli_numbers(10)
    product = exponential_product_coefficients(values)
    print("BERNOULLI GENERATING IDENTITY")
    print(f"  B_0 through B_10: {values}")
    print(f"  truncated B(t): {format_egf(values[:7])}")
    print(f"  coefficients of B(t)(exp(t)-1): {product}")
    print("  expected beginning: [0, 1, 0, ..., 0]\n")

    print("NONVANISHING POWERS IN F_2[w]")
    for n in range(9):
        polynomial = polynomial_power_over_f2(n)
        print(f"  w^{n}: {polynomial}; nonzero = {bool(polynomial)}")


if __name__ == "__main__":
    main()
