#!/usr/bin/env python3
"""Numerical demonstrations of the graded Euler–Jones state-sum identity.

A Laurent polynomial is represented by a dictionary mapping an integer exponent
to its integer coefficient.  The examples compare explicit circle-label
enumeration with the compressed binomial state sum.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import comb
from typing import Dict, Iterable, Iterator, List, Mapping, Sequence, Tuple

Laurent = Dict[int, int]


@dataclass(frozen=True)
class SmoothingState:
    """Summary data for one complete smoothing of a diagram."""

    num_a: int
    num_b: int
    loops: int

    def __post_init__(self) -> None:
        if min(self.num_a, self.num_b, self.loops) < 0:
            raise ValueError("State counts must be nonnegative")


def add_term(poly: Laurent, exponent: int, coefficient: int) -> None:
    """Add one Laurent monomial, deleting a coefficient if it becomes zero."""
    poly[exponent] = poly.get(exponent, 0) + coefficient
    if poly[exponent] == 0:
        del poly[exponent]


def enhancement_degree(labels: Sequence[int]) -> int:
    """Return the sum of labels, each of which must be +1 or -1."""
    if any(label not in (-1, 1) for label in labels):
        raise ValueError("Circle labels must be +1 or -1")
    return sum(labels)


def enhancements(number_of_circles: int) -> Iterator[Tuple[int, ...]]:
    """Generate all binary enhancements of a collection of circles."""
    if number_of_circles < 0:
        raise ValueError("The number of circles must be nonnegative")
    yield from product((-1, 1), repeat=number_of_circles)


def enhancement_polynomial_explicit(number_of_circles: int) -> Laurent:
    """Compute the circle-label polynomial by listing all 2^m enhancements."""
    result: Laurent = {}
    for labels in enhancements(number_of_circles):
        add_term(result, enhancement_degree(labels), 1)
    return result


def enhancement_polynomial_binomial(number_of_circles: int) -> Laurent:
    """Compute (q + q^-1)^m from its binomial coefficients."""
    if number_of_circles < 0:
        raise ValueError("The number of circles must be nonnegative")
    return {
        2 * positives - number_of_circles: comb(number_of_circles, positives)
        for positives in range(number_of_circles + 1)
    }


def graded_euler_explicit(states: Iterable[SmoothingState]) -> Laurent:
    """Enumerate every enhancement and sum its signed quantum monomial."""
    result: Laurent = {}
    for state in states:
        sign = -1 if state.num_b % 2 else 1
        shift = state.num_a - state.num_b
        for labels in enhancements(state.loops):
            add_term(result, shift + enhancement_degree(labels), sign)
    return result


def jones_state_sum_compressed(states: Iterable[SmoothingState]) -> Laurent:
    """Evaluate the Jones state sum using binomially compressed circle factors."""
    result: Laurent = {}
    for state in states:
        sign = -1 if state.num_b % 2 else 1
        shift = state.num_a - state.num_b
        for exponent, coefficient in enhancement_polynomial_binomial(state.loops).items():
            add_term(result, shift + exponent, sign * coefficient)
    return result


def writhe_shift(poly: Mapping[int, int], writhe: int) -> Laurent:
    """Multiply a Laurent polynomial by q^(-3w)."""
    return {exponent - 3 * writhe: coefficient for exponent, coefficient in poly.items()}


def format_laurent(poly: Mapping[int, int]) -> str:
    """Format a Laurent polynomial in descending exponent order."""
    if not poly:
        return "0"
    pieces: List[Tuple[str, str]] = []
    for exponent in sorted(poly, reverse=True):
        coefficient = poly[exponent]
        if coefficient == 0:
            continue
        sign = "+" if coefficient > 0 else "-"
        magnitude = abs(coefficient)
        if exponent == 0:
            body = str(magnitude)
        else:
            variable = "q" if exponent == 1 else f"q^{exponent}"
            body = variable if magnitude == 1 else f"{magnitude}{variable}"
        pieces.append((sign, body))
    if not pieces:
        return "0"
    first_sign, first_body = pieces[0]
    output = ("-" if first_sign == "-" else "") + first_body
    for sign, body in pieces[1:]:
        output += f" {sign} {body}"
    return output


def run_demo() -> None:
    """Print enhancement identities, an unknot, and a sample smoothing cube."""
    print("Binary enhancement identity")
    for circles in range(6):
        explicit = enhancement_polynomial_explicit(circles)
        compressed = enhancement_polynomial_binomial(circles)
        assert explicit == compressed
        print(f"  m={circles}: {format_laurent(explicit)}")

    unknot = [SmoothingState(num_a=0, num_b=0, loops=1)]
    unknot_poly = graded_euler_explicit(unknot)
    assert unknot_poly == {1: 1, -1: 1}
    print(f"\nCrossingless unknot: {format_laurent(unknot_poly)}")

    # A transparent synthetic two-crossing cube.  Each tuple gives
    # (number of A-smoothings, number of B-smoothings, number of circles).
    sample_states = [
        SmoothingState(2, 0, 2),
        SmoothingState(1, 1, 1),
        SmoothingState(1, 1, 1),
        SmoothingState(0, 2, 2),
    ]
    explicit = graded_euler_explicit(sample_states)
    compressed = jones_state_sum_compressed(sample_states)
    assert explicit == compressed
    print(f"Sample two-crossing state data: {format_laurent(explicit)}")
    print(f"Writhe-normalized at w=1: {format_laurent(writhe_shift(explicit, 1))}")
    print("All explicit and compressed calculations agree.")


if __name__ == "__main__":
    run_demo()
