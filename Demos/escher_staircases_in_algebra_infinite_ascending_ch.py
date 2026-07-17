#!/usr/bin/env python3
"""Numerical demonstrations for Escher staircases and separated filtrations.

The script uses only the Python standard library.  It demonstrates:
1. strict descent and separation at finite resolution for powers-of-two ideals;
2. strict ascent of variable ideals through explicit monomial witnesses;
3. stabilization of the coordinate chain when only finitely many variables exist.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple


ExponentVector = Mapping[int, int]
SparsePolynomial = Sequence[ExponentVector]


def divisible_by_power_of_two(value: int, level: int) -> bool:
    """Return whether 2**level divides value."""
    if level < 0:
        raise ValueError("level must be nonnegative")
    return value % (1 << level) == 0


def values_in_divisibility_ideal(values: Iterable[int], level: int) -> bool:
    """Test membership in D_level on a finite sample of function values."""
    sample = tuple(values)
    return all(divisible_by_power_of_two(value, level) for value in sample)


def two_adic_valuation(value: int) -> int | None:
    """Return v_2(value), or None for zero (which has unbounded valuation)."""
    if value == 0:
        return None
    magnitude = abs(value)
    valuation = 0
    while magnitude % 2 == 0:
        magnitude //= 2
        valuation += 1
    return valuation


def deepest_common_level(values: Iterable[int]) -> int | None:
    """Find the largest n for which all sampled values lie in 2**n Z.

    Return None when every value is zero, representing membership at all levels.
    """
    valuations = [two_adic_valuation(value) for value in values if value != 0]
    return min(valuations) if valuations else None


def monomial_in_variable_ideal(monomial: ExponentVector, level: int) -> bool:
    """Test whether a monomial belongs to V_level = (x_0,...,x_{level-1})."""
    if level < 0:
        raise ValueError("level must be nonnegative")
    return any(index < level and exponent > 0 for index, exponent in monomial.items())


def polynomial_in_variable_ideal(polynomial: SparsePolynomial, level: int) -> bool:
    """Test ideal membership from a sparse list of monomial exponent maps.

    Coefficients are irrelevant here: a polynomial is in the monomial ideal V_level
    precisely when every nonzero monomial is divisible by one of its generators.
    """
    return all(monomial_in_variable_ideal(monomial, level) for monomial in polynomial)


def coordinate_ideal_generators(level: int, variable_count: int | None = None) -> Tuple[int, ...]:
    """Return indices generating the coordinate ideal at a given level.

    If variable_count is finite, the chain stabilizes after all variables appear.
    """
    if level < 0:
        raise ValueError("level must be nonnegative")
    if variable_count is not None and variable_count < 0:
        raise ValueError("variable_count must be nonnegative")
    stop = level if variable_count is None else min(level, variable_count)
    return tuple(range(stop))


@dataclass(frozen=True)
class StrictnessWitness:
    """A compact report describing one strict inclusion."""

    level: int
    witness: str
    in_current: bool
    in_next: bool


def divisibility_witness(level: int) -> StrictnessWitness:
    """Use the constant value 2**level to witness D_{level+1} < D_level."""
    value = 1 << level
    return StrictnessWitness(
        level=level,
        witness=f"constant value {value}",
        in_current=divisible_by_power_of_two(value, level),
        in_next=divisible_by_power_of_two(value, level + 1),
    )


def variable_witness(level: int) -> StrictnessWitness:
    """Use x_level to witness V_level < V_{level+1}."""
    monomial: Dict[int, int] = {level: 1}
    return StrictnessWitness(
        level=level,
        witness=f"x_{level}",
        in_current=monomial_in_variable_ideal(monomial, level),
        in_next=monomial_in_variable_ideal(monomial, level + 1),
    )


def print_divisibility_demo(max_level: int = 7) -> None:
    """Display strict descent and sampled separation."""
    print("\n1. POWERS-OF-TWO FILTRATION")
    print("D_(n+1) is strictly contained in D_n; 2^n is the witness.")
    for level in range(max_level + 1):
        report = divisibility_witness(level)
        print(
            f"n={level:2d}: {report.witness:18s} "
            f"in D_n={report.in_current!s:5s}, in D_(n+1)={report.in_next}"
        )

    samples: Dict[str, List[int]] = {
        "zero function sample": [0, 0, 0, 0],
        "mixed even sample": [8, -24, 40, 0],
        "highly divisible sample": [64, -192, 320, 0],
    }
    print("\nFinite samples and their deepest common divisibility level:")
    for name, values in samples.items():
        depth = deepest_common_level(values)
        label = "all levels (all values are zero)" if depth is None else str(depth)
        pattern = [values_in_divisibility_ideal(values, n) for n in range(max_level + 1)]
        print(f"  {name:25s}: values={values}, deepest={label}, levels={pattern}")


def print_polynomial_staircase_demo(max_level: int = 7) -> None:
    """Display the fresh-variable witness at each ascending step."""
    print("\n2. COUNTABLE-VARIABLE POLYNOMIAL STAIRCASE")
    print("V_n=(x_0,...,x_(n-1)); x_n lies in V_(n+1) but not V_n.")
    for level in range(max_level + 1):
        report = variable_witness(level)
        print(
            f"n={level:2d}: witness {report.witness:5s} "
            f"in V_n={report.in_current!s:5s}, in V_(n+1)={report.in_next}"
        )

    examples: Dict[str, SparsePolynomial] = {
        "x_0*x_4 + x_1^2": [{0: 1, 4: 1}, {1: 2}],
        "x_3 + x_0*x_5": [{3: 1}, {0: 1, 5: 1}],
        "1 + x_0": [{}, {0: 1}],
    }
    print("\nSparse polynomial membership examples:")
    for name, polynomial in examples.items():
        memberships = [polynomial_in_variable_ideal(polynomial, n) for n in range(6)]
        print(f"  {name:18s}: membership in V_0,...,V_5 = {memberships}")


def print_finite_boundary_demo(variable_count: int = 4, max_level: int = 8) -> None:
    """Compare finite coordinate-chain stabilization with unbounded ascent."""
    print("\n3. FINITE VERSUS UNBOUNDED VARIABLE SUPPLY")
    print(f"With {variable_count} variables, the coordinate chain stabilizes at level {variable_count}.")
    previous: Tuple[int, ...] | None = None
    for level in range(max_level + 1):
        generators = coordinate_ideal_generators(level, variable_count)
        changed = previous is None or generators != previous
        labels = "{" + ", ".join(f"x_{i}" for i in generators) + "}"
        print(f"n={level:2d}: generators={labels:22s} changed={changed}")
        previous = generators

    print("For an unbounded supply, the first few generator sets keep growing:")
    for level in range(min(max_level, 6) + 1):
        generators = coordinate_ideal_generators(level)
        print(f"  n={level}: {generators}")
    print("The general finite-variable nonexistence theorem is stronger: every ideal chain stabilizes,")
    print("not merely this coordinate-generated example.")


def main() -> None:
    """Run all demonstrations."""
    print("ESCHER STAIRCASES AND SEPARATED FILTRATIONS")
    print("=" * 49)
    print_divisibility_demo()
    print_polynomial_staircase_demo()
    print_finite_boundary_demo()


if __name__ == "__main__":
    main()
